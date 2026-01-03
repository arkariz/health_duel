/// Mock factories for testing
///
/// Uses mocktail for type-safe mocking.
/// Register fallback values in setUpAll().
library;

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/auth/domain/entities/user.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';
import 'package:health_duel/features/auth/domain/usecases/get_current_user.dart';
import 'package:health_duel/features/auth/domain/usecases/register_with_email.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:health_duel/features/auth/domain/usecases/sign_out.dart';
import 'package:mocktail/mocktail.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Auth Feature Mocks
// ═══════════════════════════════════════════════════════════════════════════

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignInWithApple extends Mock implements SignInWithApple {}

class MockRegisterWithEmail extends Mock implements RegisterWithEmail {}

class MockSignOut extends Mock implements SignOut {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

// ═══════════════════════════════════════════════════════════════════════════
// Fallback Values
// ═══════════════════════════════════════════════════════════════════════════

/// Register fallback values for mocktail
///
/// Call this in setUpAll() before using any mocks:
/// ```dart
/// setUpAll(() {
///   registerFallbackValues();
/// });
/// ```
void registerFallbackValues() {
  // Auth
  registerFallbackValue(Right<Failure, User>(FakeUser()));
  registerFallbackValue(const Right<Failure, User?>(null));
  registerFallbackValue(const Right<Failure, void>(null));
  registerFallbackValue(const Left<Failure, User>(AuthFailure(message: 'test')));
}

/// Fake User for fallback registration
class FakeUser extends Fake implements User {}

// ═══════════════════════════════════════════════════════════════════════════
// Auth Mock Setup Helpers
// ═══════════════════════════════════════════════════════════════════════════

extension MockAuthRepositoryX on MockAuthRepository {
  /// Setup auth state stream with provided controller
  void setupAuthStateChanges(StreamController<User?> controller) {
    when(() => authStateChanges()).thenAnswer((_) => controller.stream);
  }

  /// Setup getCurrentUser to return user
  void setupGetCurrentUser(User? user) {
    when(() => getCurrentUser()).thenAnswer(
      (_) async => Right(user),
    );
  }

  /// Setup getCurrentUser to return failure
  void setupGetCurrentUserFailure(Failure failure) {
    when(() => getCurrentUser()).thenAnswer(
      (_) async => Left(failure),
    );
  }
}

extension MockSignInWithEmailX on MockSignInWithEmail {
  /// Setup successful sign in
  void setupSuccess(User user) {
    when(
      () => call(email: any(named: 'email'), password: any(named: 'password')),
    ).thenAnswer((_) async => Right(user));
  }

  /// Setup failed sign in
  void setupFailure(Failure failure) {
    when(
      () => call(email: any(named: 'email'), password: any(named: 'password')),
    ).thenAnswer((_) async => Left(failure));
  }
}

extension MockSignInWithGoogleX on MockSignInWithGoogle {
  void setupSuccess(User user) {
    when(() => call()).thenAnswer((_) async => Right(user));
  }

  void setupFailure(Failure failure) {
    when(() => call()).thenAnswer((_) async => Left(failure));
  }
}

extension MockSignInWithAppleX on MockSignInWithApple {
  void setupSuccess(User user) {
    when(() => call()).thenAnswer((_) async => Right(user));
  }

  void setupFailure(Failure failure) {
    when(() => call()).thenAnswer((_) async => Left(failure));
  }
}

extension MockRegisterWithEmailX on MockRegisterWithEmail {
  void setupSuccess(User user) {
    when(
      () => call(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => Right(user));
  }

  void setupFailure(Failure failure) {
    when(
      () => call(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => Left(failure));
  }
}

extension MockSignOutX on MockSignOut {
  void setupSuccess() {
    when(() => call()).thenAnswer((_) async => const Right(null));
  }

  void setupFailure(Failure failure) {
    when(() => call()).thenAnswer((_) async => Left(failure));
  }
}

extension MockGetCurrentUserX on MockGetCurrentUser {
  void setupSuccess(User? user) {
    when(() => call()).thenAnswer((_) async => Right(user));
  }

  void setupFailure(Failure failure) {
    when(() => call()).thenAnswer((_) async => Left(failure));
  }
}
