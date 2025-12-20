import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/auth/domain/entities/user.dart';

/// Authentication Repository Interface (Domain Layer)
///
/// Defines contracts for authentication operations.
/// This interface lives in the domain layer and is implemented by the data layer.
///
/// All methods return Either<Failure, T> for functional error handling (ADR-002).
abstract class AuthRepository {
  /// Sign in with email and password
  ///
  /// Returns authenticated user on success or failure on error.
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google account
  ///
  /// Opens Google sign-in flow and returns authenticated user.
  Future<Either<Failure, User>> signInWithGoogle();

  /// Sign in with Apple account (iOS only)
  ///
  /// Opens Apple sign-in flow and returns authenticated user.
  /// On Android, this will return an UnsupportedFailure.
  Future<Either<Failure, User>> signInWithApple();

  /// Register new user with email and password
  ///
  /// Creates new Firebase Auth account and Firestore user document.
  Future<Either<Failure, User>> registerWithEmail({
    required String email,
    required String password,
    required String name,
  });

  /// Sign out current user
  ///
  /// Clears Firebase Auth session and local cache.
  Future<Either<Failure, void>> signOut();

  /// Get current authenticated user
  ///
  /// Returns user if session is valid, null if unauthenticated.
  Future<Either<Failure, User?>> getCurrentUser();

  /// Stream of authentication state changes
  ///
  /// Emits user on sign in, null on sign out.
  /// Useful for reactive UI updates.
  Stream<User?> authStateChanges();
}
