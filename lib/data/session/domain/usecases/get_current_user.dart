import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/domain/entities/user.dart';
import 'package:health_duel/data/session/domain/repositories/session_repository.dart';

/// Get Current User Use Case (Global)
///
/// Business logic for retrieving currently authenticated user.
/// Can be used by any feature that needs current user info.
class GetCurrentUser {
  final SessionRepository repository;

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
