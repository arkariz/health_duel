import 'package:dartz/dartz.dart';
import 'package:exception/exception.dart';
import 'package:health_duel/core/error/exception_mapper.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:health_duel/features/auth/domain/entities/user.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Auth Repository Implementation (Data Layer)
///
/// Implements [AuthRepository] interface from domain layer.
/// Responsible for:
/// - Delegating to [AuthRemoteDataSource] for Firebase operations
/// - Mapping [CoreException] to [Failure] types via [ExceptionMapper] (ADR-002)
/// - Converting [UserModel] to domain [User] entity
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource}) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, User>> signInWithEmail({required String email, required String password}) async {
    try {
      final userModel = await _remoteDataSource.signInWithEmail(email, password);
      return Right(userModel.toEntity());
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'An unexpected error occurred during sign in', originalException: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      return Right(userModel.toEntity());
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'An unexpected error occurred during Google sign in', originalException: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      final userModel = await _remoteDataSource.signInWithApple();
      return Right(userModel.toEntity());
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'An unexpected error occurred during Apple sign in', originalException: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> registerWithEmail({required String email, required String password, required String name}) async {
    try {
      final userModel = await _remoteDataSource.registerWithEmail(email, password, name);
      return Right(userModel.toEntity());
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'An unexpected error occurred during registration', originalException: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'An unexpected error occurred during sign out', originalException: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      return Right(userModel?.toEntity());
    } on CoreException catch (e) {
      return Left(ExceptionMapper.toFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'An unexpected error occurred while getting current user', originalException: e.toString()));
    }
  }

  @override
  Stream<User?> authStateChanges() {
    // Stream returns User? directly without Either wrapper
    // Errors in stream are handled by Firebase and logged
    // Empty/null user indicates signed out state
    return _remoteDataSource.authStateChanges().map((userModel) {
      return userModel?.toEntity();
    });
  }
}
