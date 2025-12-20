import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:health_duel/features/auth/domain/entities/user.dart';

/// User Model (Data Layer - Firestore DTO)
///
/// Handles serialization between Firestore documents and domain entities.
/// This model is specific to Firestore and should not leak into domain layer.
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
  });

  /// Create from Firestore document snapshot
  ///
  /// Document ID is used as user ID (same as Firebase Auth UID).
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create from Firestore data map (for queries)
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document data
  ///
  /// Note: ID is not included as it's the document ID, not a field.
  Map<String, dynamic> toFirestore() => {
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  /// Convert to domain entity
  User toEntity() => User(
    id: id,
    name: name,
    email: email,
    photoUrl: photoUrl,
    createdAt: createdAt,
  );

  /// Create from domain entity (for updates)
  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    name: user.name,
    email: user.email,
    photoUrl: user.photoUrl,
    createdAt: user.createdAt,
  );

  /// Create empty model
  factory UserModel.empty() => UserModel(
    id: '',
    name: '',
    email: '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  @override
  List<Object?> get props => [id, name, email, photoUrl, createdAt];

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';
}
