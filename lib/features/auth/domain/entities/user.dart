import 'package:equatable/equatable.dart';

/// User Entity (Domain Layer - Pure Dart)
///
/// Represents authenticated user in the application.
/// This is a pure domain entity with no external dependencies.
///
/// Note: In Clean Architecture, entities should not depend on any framework
/// (no Firebase, no JSON serialization, etc.)
class User extends Equatable {
  /// Unique user identifier from Firebase Auth
  final String id;

  /// User display name (from Firebase profile or email)
  final String name;

  /// User email address
  final String email;

  /// Optional profile photo URL
  final String? photoUrl;

  /// User creation timestamp
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
  });

  /// Check if user has a profile photo
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  /// Get display name or fallback to email
  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  /// Create empty user (for initial state)
  factory User.empty() => User(
        id: '',
        name: '',
        email: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Check if user is empty/invalid
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  @override
  List<Object?> get props => [id, name, email, photoUrl, createdAt];

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
