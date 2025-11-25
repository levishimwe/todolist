import 'package:dartz/dartz.dart';
import 'package:savesmart/core/error/failures.dart';
import 'package:savesmart/core/usecase/usecase.dart';
import 'package:savesmart/features/auth/domain/repositories/auth_repository.dart';

/// Sign out use case
class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.signOut();
  }
}
