import 'package:dartz/dartz.dart';
import 'package:savesmart/core/error/failures.dart';
import 'package:savesmart/features/tips/domain/entities/financial_tip.dart';

/// Tips repository interface
abstract class TipsRepository {
  /// Get all financial tips
  Future<Either<Failure, List<FinancialTip>>> getTips();

  /// Get tips by category
  Future<Either<Failure, List<FinancialTip>>> getTipsByCategory(
    String category,
  );

  /// Get a single tip by ID
  Future<Either<Failure, FinancialTip>> getTipById(String tipId);

  /// Create a new tip (admin functionality)
  Future<Either<Failure, FinancialTip>> createTip(FinancialTip tip);

  /// Stream of tips for real-time updates
  Stream<Either<Failure, List<FinancialTip>>> watchTips();
}
