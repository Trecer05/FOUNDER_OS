import 'models.dart';

enum FinanceTransactionCategory {
  product,
  contract,
  payroll,
  infrastructure,
  security,
  marketing,
  investment,
  financing,
  other,
}

class ContractEmployeeAssignment {
  const ContractEmployeeAssignment({
    required this.contractId,
    required this.employeeId,
    required this.assignedAtMinutes,
  });

  final String contractId;
  final String employeeId;
  final int assignedAtMinutes;

  Map<String, Object?> toJson() => <String, Object?>{
    'contractId': contractId,
    'employeeId': employeeId,
    'assignedAtMinutes': assignedAtMinutes,
  };

  factory ContractEmployeeAssignment.fromJson(Map<String, Object?> json) =>
      ContractEmployeeAssignment(
        contractId: json['contractId']! as String,
        employeeId: json['employeeId']! as String,
        assignedAtMinutes: (json['assignedAtMinutes']! as num).toInt(),
      );
}

class ProductMonetizationChange {
  const ProductMonetizationChange({
    required this.productId,
    required this.model,
    required this.changedAtMinutes,
  });

  final String productId;
  final MonetizationModel model;
  final int changedAtMinutes;

  Map<String, Object?> toJson() => <String, Object?>{
    'productId': productId,
    'model': model.name,
    'changedAtMinutes': changedAtMinutes,
  };

  factory ProductMonetizationChange.fromJson(Map<String, Object?> json) =>
      ProductMonetizationChange(
        productId: json['productId']! as String,
        model: MonetizationModel.values.byName(json['model']! as String),
        changedAtMinutes: (json['changedAtMinutes']! as num).toInt(),
      );
}

class FinanceHistoryPoint {
  const FinanceHistoryPoint({
    required this.simulationMinutes,
    required this.cash,
    required this.incomeRunRate,
    required this.expenseRunRate,
    required this.profitRunRate,
  });

  final int simulationMinutes;
  final double cash;
  final double incomeRunRate;
  final double expenseRunRate;
  final double profitRunRate;

  Map<String, Object?> toJson() => <String, Object?>{
    'simulationMinutes': simulationMinutes,
    'cash': cash,
    'incomeRunRate': incomeRunRate,
    'expenseRunRate': expenseRunRate,
    'profitRunRate': profitRunRate,
  };

  factory FinanceHistoryPoint.fromJson(Map<String, Object?> json) =>
      FinanceHistoryPoint(
        simulationMinutes: (json['simulationMinutes']! as num).toInt(),
        cash: (json['cash']! as num).toDouble(),
        incomeRunRate: (json['incomeRunRate']! as num).toDouble(),
        expenseRunRate: (json['expenseRunRate']! as num).toDouble(),
        profitRunRate: (json['profitRunRate']! as num).toDouble(),
      );
}

class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.simulationMinutes,
    required this.amount,
    required this.category,
    required this.description,
  });

  final String id;
  final int simulationMinutes;
  final double amount;
  final FinanceTransactionCategory category;
  final String description;

  bool get income => amount >= 0;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'simulationMinutes': simulationMinutes,
    'amount': amount,
    'category': category.name,
    'description': description,
  };

  factory FinanceTransaction.fromJson(Map<String, Object?> json) =>
      FinanceTransaction(
        id: json['id']! as String,
        simulationMinutes: (json['simulationMinutes']! as num).toInt(),
        amount: (json['amount']! as num).toDouble(),
        category: FinanceTransactionCategory.values.byName(
          json['category']! as String,
        ),
        description: json['description']! as String,
      );
}

class RevenueForecast {
  const RevenueForecast({
    required this.low,
    required this.expected,
    required this.high,
    required this.assumedMau,
    required this.note,
  });

  final double low;
  final double expected;
  final double high;
  final int assumedMau;
  final String note;
}
