import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/auth/domain/entities/user.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Sign In With Apple Use Case
///
/// Business logic for Apple Sign In authentication (iOS only).
class SignInWithApple {
  final AuthRepository repository;

  const SignInWithApple(this.repository);

  /// Execute Apple sign in flow
  ///
  /// Opens Apple sign-in sheet and returns authenticated user.
  /// Only works on iOS 13+ and macOS 10.15+.
  ///
  /// Possible failures:
  /// - [UnsupportedFailure]: Platform doesn't support Apple Sign In
  /// - [AuthenticationFailure]: User canceled or auth failed
  /// - [NetworkFailure]: No internet connection
  /// - [ServerFailure]: Firebase error
  Future<Either<Failure, User>> call() {
    return repository.signInWithApple();
  }
}
