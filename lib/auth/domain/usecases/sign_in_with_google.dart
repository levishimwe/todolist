import 'package:dartz/dartz.dart';
import 'package:savesmart/core/error/failures.dart';
import 'package:savesmart/core/usecase/usecase.dart';
import 'package:savesmart/features/auth/domain/entities/user.dart';
import 'package:savesmart/features/auth/domain/repositories/auth_repository.dart';

/// Sign in with Google use case
class SignInWithGoogle implements UseCase<User, NoParams> {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}
