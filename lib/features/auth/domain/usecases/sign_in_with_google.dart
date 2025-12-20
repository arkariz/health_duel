import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/auth/domain/entities/user.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Sign In With Google Use Case
///
/// Business logic for Google OAuth authentication.
class SignInWithGoogle {
  final AuthRepository repository;

  const SignInWithGoogle(this.repository);

  /// Execute Google sign in flow
  ///
  /// Opens Google sign-in sheet and returns authenticated user.
  ///
  /// Possible failures:
  /// - [AuthenticationFailure]: User canceled or auth failed
  /// - [NetworkFailure]: No internet connection
  /// - [ServerFailure]: Firebase error
  Future<Either<Failure, User>> call() {
    return repository.signInWithGoogle();
  }
}
