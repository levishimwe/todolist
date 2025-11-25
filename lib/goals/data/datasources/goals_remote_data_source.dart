import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savesmart/core/utils/constants.dart';
import 'package:savesmart/features/goals/data/models/savings_goal_model.dart';

/// Goals remote data source
abstract class GoalsRemoteDataSource {
  Future<SavingsGoalModel> createGoal(SavingsGoalModel goal);
  Future<List<SavingsGoalModel>> getGoals(String userId);
  Future<SavingsGoalModel> getGoalById(String goalId);
  Future<SavingsGoalModel> updateGoal(SavingsGoalModel goal);
  Future<void> deleteGoal(String goalId);
  Future<SavingsGoalModel> addToGoal(String goalId, double amount);
  Stream<List<SavingsGoalModel>> watchGoals(String userId);
}

class GoalsRemoteDataSourceImpl implements GoalsRemoteDataSource {
  final FirebaseFirestore firestore;

  GoalsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<SavingsGoalModel> createGoal(SavingsGoalModel goal) async {
    try {
      final docRef = await firestore
          .collection(AppConstants.goalsCollection)
          .add(goal.toFirestore());

      final doc = await docRef.get();
      return SavingsGoalModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  @override
  Future<List<SavingsGoalModel>> getGoals(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(AppConstants.goalsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SavingsGoalModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get goals: $e');
    }
  }

  @override
  Future<SavingsGoalModel> getGoalById(String goalId) async {
    try {
      final doc = await firestore
          .collection(AppConstants.goalsCollection)
          .doc(goalId)
          .get();

      if (!doc.exists) {
        throw Exception('Goal not found');
      }

      return SavingsGoalModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get goal: $e');
    }
  }

  @override
  Future<SavingsGoalModel> updateGoal(SavingsGoalModel goal) async {
    try {
      await firestore
          .collection(AppConstants.goalsCollection)
          .doc(goal.id)
          .update(goal.toFirestore());

      final doc = await firestore
          .collection(AppConstants.goalsCollection)
          .doc(goal.id)
          .get();

      return SavingsGoalModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    try {
      await firestore
          .collection(AppConstants.goalsCollection)
          .doc(goalId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  @override
  Future<SavingsGoalModel> addToGoal(String goalId, double amount) async {
    try {
      final doc = await firestore
          .collection(AppConstants.goalsCollection)
          .doc(goalId)
          .get();

      if (!doc.exists) {
        throw Exception('Goal not found');
      }

      final goal = SavingsGoalModel.fromFirestore(doc);
      final newAmount = goal.currentAmount + amount;

      await firestore
          .collection(AppConstants.goalsCollection)
          .doc(goalId)
          .update({'currentAmount': newAmount});

      final updatedDoc = await firestore
          .collection(AppConstants.goalsCollection)
          .doc(goalId)
          .get();

      return SavingsGoalModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw Exception('Failed to add to goal: $e');
    }
  }

  @override
  Stream<List<SavingsGoalModel>> watchGoals(String userId) {
    try {
      return firestore
          .collection(AppConstants.goalsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => SavingsGoalModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      throw Exception('Failed to watch goals: $e');
    }
  }
}
