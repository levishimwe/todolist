import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:savesmart/core/error/failures.dart';
import 'package:savesmart/core/usecase/usecase.dart';
import 'package:savesmart/features/auth/domain/entities/user.dart';
import 'package:savesmart/features/auth/domain/repositories/auth_repository.dart';

/// Sign in with email use case
class SignInWithEmail implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
