import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:savesmart/core/error/failures.dart';
import 'package:savesmart/core/usecase/usecase.dart';
import 'package:savesmart/features/auth/domain/entities/user.dart';
import 'package:savesmart/features/auth/domain/repositories/auth_repository.dart';

/// Sign up with email use case
class SignUpWithEmail implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      phoneNumber: params.phoneNumber,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [email, password, fullName, phoneNumber];
}
