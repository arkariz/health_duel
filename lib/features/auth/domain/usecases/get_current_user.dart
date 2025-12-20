import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/auth/domain/entities/user.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Get Current User Use Case
///
/// Business logic for retrieving currently authenticated user.
class GetCurrentUser {
  final AuthRepository repository;

  const GetCurrentUser(this.repository);

  /// Execute get current user
  ///
  /// Returns [User] if authenticated, null if not.
  ///
  /// Possible failures:
  /// - [ServerFailure]: Error retrieving user data
  Future<Either<Failure, User?>> call() {
    return repository.getCurrentUser();
  }
}
