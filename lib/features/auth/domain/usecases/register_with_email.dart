import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/auth/domain/entities/user.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Register With Email Use Case
///
/// Business logic for creating new user account with email/password.
class RegisterWithEmail {
  final AuthRepository repository;

  const RegisterWithEmail(this.repository);

  /// Execute registration with email, password, and display name
  ///
  /// Creates Firebase Auth account and Firestore user document.
  ///
  /// Returns [User] on success or [Failure] on error.
  ///
  /// Possible failures:
  /// - [ValidationFailure]: Invalid inputs
  /// - [AuthenticationFailure]: Email already in use
  /// - [NetworkFailure]: No internet connection
  /// - [ServerFailure]: Firebase error
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String name,
  }) async {
    // Validate email format
    final trimmedEmail = email.trim().toLowerCase();
    if (!_isValidEmail(trimmedEmail)) {
      return const Left(ValidationFailure(message: 'Invalid email format'));
    }

    // Validate password strength (min 6 characters - Firebase requirement)
    if (password.length < 6) {
      return const Left(
        ValidationFailure(message: 'Password must be at least 6 characters'),
      );
    }

    // Validate name not empty
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return const Left(ValidationFailure(message: 'Name cannot be empty'));
    }

    // Delegate to repository
    return repository.registerWithEmail(
      email: trimmedEmail,
      password: password,
      name: trimmedName,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
