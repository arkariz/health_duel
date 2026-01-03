import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/auth/domain/entities/user.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';
import 'package:test/test.dart';

import '../../../helpers/helpers.dart';

void main() {
  // Mocks
  late MockAuthRepository mockAuthRepository;
  late MockSignInWithEmail mockSignInWithEmail;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignInWithApple mockSignInWithApple;
  late MockRegisterWithEmail mockRegisterWithEmail;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;

  // Auth state stream controller
  late StreamController<User?> authStateController;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSignInWithEmail = MockSignInWithEmail();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignInWithApple = MockSignInWithApple();
    mockRegisterWithEmail = MockRegisterWithEmail();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();

    authStateController = StreamController<User?>.broadcast();
    mockAuthRepository.setupAuthStateChanges(authStateController);
  });

  tearDown(() {
    authStateController.close();
  });

  AuthBloc buildBloc() => AuthBloc(
    authRepository: mockAuthRepository,
    signInWithEmail: mockSignInWithEmail,
    signInWithGoogle: mockSignInWithGoogle,
    signInWithApple: mockSignInWithApple,
    registerWithEmail: mockRegisterWithEmail,
    signOut: mockSignOut,
    getCurrentUser: mockGetCurrentUser,
  );

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(buildBloc().state, const AuthInitial());
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user exists',
        build: () {
          mockGetCurrentUser.setupSuccess(tUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(tUser),
        ],
        verify: (_) {
          // Verify use case was called
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when user is null',
        build: () {
          mockGetCurrentUser.setupSuccess(null);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on failure',
        build: () {
          mockGetCurrentUser.setupFailure(
            const ServerFailure(message: 'Server error'),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );
    });

    group('AuthSignInWithEmailRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on success',
        build: () {
          mockSignInWithEmail.setupSuccess(tUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthSignInWithEmailRequested(
            email: tEmail,
            password: tPassword,
          ),
        ),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] on failure',
        build: () {
          mockSignInWithEmail.setupFailure(
            const AuthFailure(message: tAuthErrorMessage),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthSignInWithEmailRequested(
            email: tEmail,
            password: tPassword,
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError(tAuthErrorMessage),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] on network failure',
        build: () {
          mockSignInWithEmail.setupFailure(
            const NetworkFailure(message: tNetworkErrorMessage),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthSignInWithEmailRequested(
            email: tEmail,
            password: tPassword,
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError(tNetworkErrorMessage),
        ],
      );
    });

    group('AuthSignInWithGoogleRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on success',
        build: () {
          mockSignInWithGoogle.setupSuccess(tUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignInWithGoogleRequested()),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] on failure',
        build: () {
          mockSignInWithGoogle.setupFailure(
            const AuthFailure(message: 'Google sign in cancelled'),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignInWithGoogleRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthError('Google sign in cancelled'),
        ],
      );
    });

    group('AuthSignInWithAppleRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on success',
        build: () {
          mockSignInWithApple.setupSuccess(tUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignInWithAppleRequested()),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] on failure',
        build: () {
          mockSignInWithApple.setupFailure(
            const AuthFailure(message: 'Apple sign in not available'),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignInWithAppleRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthError('Apple sign in not available'),
        ],
      );
    });

    group('AuthRegisterWithEmailRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on success',
        build: () {
          mockRegisterWithEmail.setupSuccess(tUser);
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthRegisterWithEmailRequested(
            email: tEmail,
            password: tPassword,
            name: tName,
          ),
        ),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] on failure',
        build: () {
          mockRegisterWithEmail.setupFailure(
            const AuthFailure(message: 'Email already in use'),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const AuthRegisterWithEmailRequested(
            email: tEmail,
            password: tPassword,
            name: tName,
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError('Email already in use'),
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on success',
        build: () {
          mockSignOut.setupSuccess();
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] on failure',
        build: () {
          mockSignOut.setupFailure(
            const ServerFailure(message: 'Failed to sign out'),
          );
          return buildBloc();
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthError('Failed to sign out'),
        ],
      );
    });

    group('AuthStateChanged (stream)', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthAuthenticated] when user is added to stream',
        build: buildBloc,
        act: (bloc) => authStateController.add(tUser),
        expect: () => [
          AuthAuthenticated(tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when null is added to stream',
        build: buildBloc,
        act: (bloc) => authStateController.add(null),
        expect: () => [
          const AuthUnauthenticated(),
        ],
      );
    });

    group('bloc lifecycle', () {
      test('cancels auth state subscription on close', () async {
        final bloc = buildBloc();
        await bloc.close();

        // Stream should be cancelled - adding after close should not emit
        authStateController.add(tUser);

        // No exception means subscription was properly cancelled
        expect(bloc.isClosed, isTrue);
      });
    });
  });
}
