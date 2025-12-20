import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/auth/domain/entities/user.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Sign In With Email Use Case
///
/// Business logic for email/password authentication.
/// Validates inputs and delegates to repository.
class SignInWithEmail {
  final AuthRepository repository;

  const SignInWithEmail(this.repository);

  /// Execute sign in with email and password
  ///
  /// Returns [User] on success or [Failure] on error.
  ///
  /// Possible failures:
  /// - [ValidationFailure]: Invalid email format or empty password
  /// - [AuthenticationFailure]: Invalid credentials
  /// - [NetworkFailure]: No internet connection
  /// - [ServerFailure]: Firebase error
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    // Validate email format
    final trimmedEmail = email.trim().toLowerCase();
    if (!_isValidEmail(trimmedEmail)) {
      return const Left(ValidationFailure(message: 'Invalid email format'));
    }

    // Validate password not empty
    if (password.isEmpty) {
      return const Left(ValidationFailure(message: 'Password cannot be empty'));
    }

    // Delegate to repository
    return repository.signInWithEmail(email: trimmedEmail, password: password);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
