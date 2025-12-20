import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exception/exception.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_duel/features/auth/data/models/user_model.dart';

/// Auth Remote Data Source Interface
///
/// Defines the contract for Firebase Authentication operations.
/// Returns [UserModel] (DTO) instead of raw UID for atomic auth + bootstrap.
abstract class AuthRemoteDataSource {
  /// Sign in with email and password
  Future<UserModel> signInWithEmail(String email, String password);

  /// Sign in with Google OAuth
  Future<UserModel> signInWithGoogle();

  /// Sign in with Apple OAuth (iOS only)
  Future<UserModel> signInWithApple();

  /// Register new user with email, password, and name
  Future<UserModel> registerWithEmail(String email, String password, String name);

  /// Sign out current user
  Future<void> signOut();

  /// Get currently authenticated user (null if not signed in)
  Future<UserModel?> getCurrentUser();

  /// Stream of auth state changes
  Stream<UserModel?> authStateChanges();
}

/// Auth Remote Data Source Implementation
///
/// Implements Firebase Auth with atomic user bootstrap pattern:
/// - Every auth method ensures user document exists in Firestore
/// - Document ID = Firebase Auth UID (critical for security rules)
/// - Uses processFireauthCall and processFirestoreCall for exception handling
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  /// Storage key for users collection (ADR-003 compliant)
  static const String _usersCollection = 'users';

  AuthRemoteDataSourceImpl({firebase_auth.FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore, GoogleSignIn? googleSignIn}) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance, _firestore = firestore ?? FirebaseFirestore.instance, _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    return processFireauthCall(
      module: 'Auth',
      function: 'signInWithEmail',
      call: () async {
        final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

        return _bootstrapUser(credential.user!);
      },
    );
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    return processFireauthCall(
      module: 'Auth',
      function: 'signInWithGoogle',
      call: () async {
        // Trigger Google sign-in flow
        final googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          throw firebase_auth.FirebaseAuthException(code: 'sign-in-canceled', message: 'Google sign in was canceled');
        }

        // Obtain auth details
        final googleAuth = await googleUser.authentication;
        final credential = firebase_auth.GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

        // Sign in with Firebase
        final authResult = await _firebaseAuth.signInWithCredential(credential);

        return _bootstrapUser(authResult.user!);
      },
    );
  }

  @override
  Future<UserModel> signInWithApple() async {
    return processFireauthCall(
      module: 'Auth',
      function: 'signInWithApple',
      call: () async {
        // Note: Requires sign_in_with_apple package
        // Implementation will be platform-specific
        // For now, we create a placeholder that indicates
        // Apple Sign In needs platform-specific setup

        final appleProvider =
            firebase_auth.AppleAuthProvider()
              ..addScope('email')
              ..addScope('name');

        final authResult = await _firebaseAuth.signInWithProvider(appleProvider);

        return _bootstrapUser(authResult.user!);
      },
    );
  }

  @override
  Future<UserModel> registerWithEmail(String email, String password, String name) async {
    return processFireauthCall(
      module: 'Auth',
      function: 'registerWithEmail',
      call: () async {
        // Create Firebase Auth account
        final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

        final user = credential.user!;

        // Update display name
        await user.updateDisplayName(name);

        // Bootstrap with provided name (not from Firebase yet)
        return _bootstrapUserWithName(user, name);
      },
    );
  }

  @override
  Future<void> signOut() async {
    return processFireauthCall(
      module: 'Auth',
      function: 'signOut',
      call: () async {
        // Sign out from Google if signed in
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }

        // Sign out from Firebase
        await _firebaseAuth.signOut();
      },
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) return null;

    return processFirestoreCall(
      module: 'Auth',
      function: 'getCurrentUser',
      call: () async {
        final doc = await _firestore.collection(_usersCollection).doc(firebaseUser.uid).get();

        if (!doc.exists) {
          // Edge case: Auth exists but Firestore doesn't
          // Bootstrap the user document
          return _bootstrapUser(firebaseUser);
        }

        return UserModel.fromFirestore(doc);
      },
    );
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final doc = await _firestore.collection(_usersCollection).doc(firebaseUser.uid).get();

        if (!doc.exists) {
          return await _bootstrapUser(firebaseUser);
        }

        return UserModel.fromFirestore(doc);
      } catch (e) {
        // If Firestore fails, still return basic user info
        return UserModel(id: firebaseUser.uid, name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User', email: firebaseUser.email ?? '', photoUrl: firebaseUser.photoURL, createdAt: DateTime.now());
      }
    });
  }

  /// Bootstrap user in Firestore (idempotent)
  ///
  /// Creates user document if it doesn't exist, returns existing if it does.
  /// Document ID = Firebase Auth UID for security rules.
  ///
  /// Flow:
  /// 1. Check if document exists in Firestore
  /// 2. If not → Create new document with auth data
  /// 3. Return UserModel (new or existing)
  Future<UserModel> _bootstrapUser(firebase_auth.User authUser) async {
    return processFirestoreCall(
      module: 'Auth',
      function: '_bootstrapUser',
      call: () async {
        final userDoc = _firestore.collection(_usersCollection).doc(authUser.uid);
        final snapshot = await userDoc.get();

        if (!snapshot.exists) {
          // Create new user document
          final newUser = UserModel(id: authUser.uid, name: authUser.displayName ?? authUser.email?.split('@').first ?? 'User', email: authUser.email ?? '', photoUrl: authUser.photoURL, createdAt: DateTime.now());

          await userDoc.set(newUser.toFirestore());
          return newUser;
        }

        // User exists, return existing
        return UserModel.fromFirestore(snapshot);
      },
    );
  }

  /// Bootstrap user with explicit name (for registration)
  ///
  /// Used when we have the name from registration form
  /// (displayName might not be updated in Firebase yet)
  Future<UserModel> _bootstrapUserWithName(firebase_auth.User authUser, String name) async {
    return processFirestoreCall(
      module: 'Auth',
      function: '_bootstrapUserWithName',
      call: () async {
        final userDoc = _firestore.collection(_usersCollection).doc(authUser.uid);

        final newUser = UserModel(id: authUser.uid, name: name, email: authUser.email ?? '', photoUrl: authUser.photoURL, createdAt: DateTime.now());

        await userDoc.set(newUser.toFirestore());
        return newUser;
      },
    );
  }
}
