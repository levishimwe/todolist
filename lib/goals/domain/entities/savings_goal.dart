import 'package:equatable/equatable.dart';

/// Savings Goal entity
class SavingsGoal extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final DateTime createdAt;
  final String? description;
  final String? category;

  const SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.deadline,
    required this.createdAt,
    this.description,
    this.category,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

  bool get isCompleted => currentAmount >= targetAmount;

  int get daysRemaining {
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    targetAmount,
    currentAmount,
    deadline,
    createdAt,
    description,
    category,
  ];

  SavingsGoal copyWith({
    String? id,
    String? userId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    DateTime? createdAt,
    String? description,
    String? category,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }
}
