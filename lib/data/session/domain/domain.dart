/// Session Domain Layer Exports
///
/// Provides shared domain contracts for cross-feature usage:
/// - [User] entity for user identity
/// - [SessionRepository] interface for session management
/// - [GetCurrentUser] and [SignOut] use cases
library;

// Entities
export 'entities/user.dart';

// Repositories
export 'repositories/session_repository.dart';

// Use Cases
export 'usecases/get_current_user.dart';
export 'usecases/sign_out.dart';
