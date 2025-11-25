import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savesmart/features/goals/domain/entities/savings_goal.dart';

/// SavingsGoal model for data layer
class SavingsGoalModel extends SavingsGoal {
  const SavingsGoalModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.targetAmount,
    super.currentAmount,
    required super.deadline,
    required super.createdAt,
    super.description,
    super.category,
  });

  /// Convert from domain entity
  factory SavingsGoalModel.fromEntity(SavingsGoal goal) {
    return SavingsGoalModel(
      id: goal.id,
      userId: goal.userId,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      deadline: goal.deadline,
      createdAt: goal.createdAt,
      description: goal.description,
      category: goal.category,
    );
  }

  /// Convert from Firestore document
  factory SavingsGoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SavingsGoalModel(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      targetAmount: (data['targetAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0.0,
      deadline: (data['deadline'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'] as String?,
      category: data['category'] as String?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
      'category': category,
    };
  }

  /// Convert from JSON
  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      deadline: DateTime.parse(json['deadline'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      category: json['category'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'category': category,
    };
  }
}
