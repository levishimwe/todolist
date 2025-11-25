import 'package:dartz/dartz.dart';
import 'package:savesmart/core/error/failures.dart';
import 'package:savesmart/features/goals/domain/entities/savings_goal.dart';

/// Goals repository interface
abstract class GoalsRepository {
  /// Create a new savings goal
  Future<Either<Failure, SavingsGoal>> createGoal(SavingsGoal goal);

  /// Get all goals for a user
  Future<Either<Failure, List<SavingsGoal>>> getGoals(String userId);

  /// Get a single goal by ID
  Future<Either<Failure, SavingsGoal>> getGoalById(String goalId);

  /// Update a goal
  Future<Either<Failure, SavingsGoal>> updateGoal(SavingsGoal goal);

  /// Delete a goal
  Future<Either<Failure, void>> deleteGoal(String goalId);

  /// Add money to a goal
  Future<Either<Failure, SavingsGoal>> addToGoal({
    required String goalId,
    required double amount,
  });

  /// Stream of goals for real-time updates
  Stream<Either<Failure, List<SavingsGoal>>> watchGoals(String userId);
}
