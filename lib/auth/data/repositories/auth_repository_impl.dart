import 'package:dartz/dartz.dart';
import 'package:savesmart/core/error/failures.dart';
import 'package:savesmart/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:savesmart/features/auth/domain/entities/user.dart';
import 'package:savesmart/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await remoteDataSource.isAuthenticated();
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        uid: uid,
        fullName: fullName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
      );
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
