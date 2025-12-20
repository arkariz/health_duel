import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Sign Out Use Case
///
/// Business logic for signing out current user.
class SignOut {
  final AuthRepository repository;

  const SignOut(this.repository);

  /// Execute sign out
  ///
  /// Clears Firebase Auth session and local cache.
  ///
  /// Possible failures:
  /// - [ServerFailure]: Firebase error during sign out
  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}
