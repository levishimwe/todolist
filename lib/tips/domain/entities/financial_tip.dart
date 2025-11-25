import 'package:equatable/equatable.dart';

/// Financial Tip entity
class FinancialTip extends Equatable {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final int? orderIndex;

  const FinancialTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.orderIndex,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    category,
    createdAt,
    orderIndex,
  ];

  FinancialTip copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    DateTime? createdAt,
    int? orderIndex,
  }) {
    return FinancialTip(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
