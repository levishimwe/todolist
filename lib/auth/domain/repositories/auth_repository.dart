import 'package:dartz/dartz.dart';
import 'package:savesmart/core/error/failures.dart';
import 'package:savesmart/features/auth/domain/entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  });

  /// Sign in with Google
  Future<Either<Failure, User>> signInWithGoogle();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Get current user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
  });
}
