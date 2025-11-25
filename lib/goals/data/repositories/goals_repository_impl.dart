import 'package:dartz/dartz.dart';
import 'package:savesmart/core/error/failures.dart';
import 'package:savesmart/features/goals/data/datasources/goals_remote_data_source.dart';
import 'package:savesmart/features/goals/domain/entities/savings_goal.dart';
import 'package:savesmart/features/goals/domain/repositories/goals_repository.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  final GoalsRemoteDataSource remoteDataSource;

  GoalsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SavingsGoal>> createGoal(SavingsGoal goal) async {
    try {
      final result = await remoteDataSource.createGoal(goal as dynamic);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SavingsGoal>>> getGoals(String userId) async {
    try {
      final goals = await remoteDataSource.getGoals(userId);
      return Right(goals);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SavingsGoal>> getGoalById(String goalId) async {
    try {
      final goal = await remoteDataSource.getGoalById(goalId);
      return Right(goal);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SavingsGoal>> updateGoal(SavingsGoal goal) async {
    try {
      final result = await remoteDataSource.updateGoal(goal as dynamic);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGoal(String goalId) async {
    try {
      await remoteDataSource.deleteGoal(goalId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SavingsGoal>> addToGoal({
    required String goalId,
    required double amount,
  }) async {
    try {
      final result = await remoteDataSource.addToGoal(goalId, amount);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<SavingsGoal>>> watchGoals(String userId) {
    try {
      return remoteDataSource.watchGoals(userId).map((goals) => Right(goals));
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }
}
