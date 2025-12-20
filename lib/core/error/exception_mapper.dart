import 'package:exception/exception.dart';
import 'package:fintrack_lite/core/error/failures.dart';

/// Maps CoreException from infrastructure to domain Failure types
///
/// Follows [ADR-002 Exception Isolation Strategy].
/// This prevents CoreException from leaking into the domain layer.
///
/// Usage in repositories:
/// ```dart
/// class MyRepositoryImpl implements MyRepository {
///   @override
///   Future<Either<Failure, Data>> getData() async {
///     try {
///       final data = await dataSource.getData();
///       return Right(data);
///     } on CoreException catch (e) {
///       return Left(ExceptionMapper.toFailure(e));
///     }
///   }
/// }
/// ```

/// Maps CoreException from infrastructure to domain Failure types
///
/// Follows [ADR-002 Exception Isolation Strategy].
/// Prevents CoreException from leaking into the domain layer.
class ExceptionMapper {
  ExceptionMapper._();

  /// Map CoreException to appropriate Failure type (exhaustive)
  static Failure toFailure(CoreException exception) {
    return switch (exception) {
      ApiErrorException() => ServerFailure(message: exception.message, errorCode: exception.code, statusCode: exception.response?.statusCode, metadata: {'module': exception.module, 'function': exception.function, 'layer': exception.layer}),

      LocalStorageCorruptionException() => CacheFailure(message: exception.message ?? 'Storage corrupted', errorCode: exception.code),
      LocalStorageClosedException() => CacheFailure(message: exception.message ?? 'Storage is closed', errorCode: exception.code),
      LocalStorageAlreadyOpenedException() => CacheFailure(message: exception.message ?? 'Storage already opened', errorCode: exception.code),

      PermissionDeniedException() => AuthFailure(message: exception.message ?? 'Permission denied', errorCode: exception.code),

      DecodeFailedException() => UnexpectedFailure(message: exception.message, errorCode: exception.code, originalException: 'DecodeFailedException'),
      GeneralException() => UnexpectedFailure(message: exception.message, errorCode: exception.code, originalException: 'GeneralException'),

      _ => UnexpectedFailure(message: exception.message ?? 'An unexpected error occurred', errorCode: exception.code, originalException: exception.runtimeType.toString()),
    };
  }

  /// Get user-friendly message from Failure
  ///
  /// Converts technical failure messages to user-readable text.
  /// Useful for displaying errors in UI.
  static String getUserMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure() => 'Unable to connect. Please check your internet connection.',
      ServerFailure() => 'Server is unavailable. Please try again later.',
      CacheFailure() => 'Local data error. Please restart the app.',
      ValidationFailure() => failure.message,
      AuthFailure() => 'Authentication failed. Please login again.',
      UnexpectedFailure() => 'Something went wrong. Please try again.',
    };
  }
}
