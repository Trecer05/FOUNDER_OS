import 'models.dart';

enum TrainingFocus { engineering, quality, security, leadership }

class EmployeeAssignment {
  const EmployeeAssignment({
    required this.employeeId,
    required this.productId,
    required this.assignedAtMinutes,
  });

  final String employeeId;
  final String productId;
  final int assignedAtMinutes;

  Map<String, Object?> toJson() => <String, Object?>{
    'employeeId': employeeId,
    'productId': productId,
    'assignedAtMinutes': assignedAtMinutes,
  };

  factory EmployeeAssignment.fromJson(Map<String, Object?> json) =>
      EmployeeAssignment(
        employeeId: json['employeeId']! as String,
        productId: json['productId']! as String,
        assignedAtMinutes: (json['assignedAtMinutes']! as num).toInt(),
      );
}

class SecurityControlOption {
  const SecurityControlOption({
    required this.id,
    required this.name,
    required this.description,
    required this.setupCost,
    required this.monthlyCost,
    required this.securityDelta,
    required this.reliabilityDelta,
    required this.incidentMultiplier,
  });

  final String id;
  final String name;
  final String description;
  final double setupCost;
  final double monthlyCost;
  final double securityDelta;
  final double reliabilityDelta;
  final double incidentMultiplier;
}

class ProductSecurityControl {
  const ProductSecurityControl({
    required this.productId,
    required this.controlId,
    required this.installedAtMinutes,
  });

  final String productId;
  final String controlId;
  final int installedAtMinutes;

  Map<String, Object?> toJson() => <String, Object?>{
    'productId': productId,
    'controlId': controlId,
    'installedAtMinutes': installedAtMinutes,
  };

  factory ProductSecurityControl.fromJson(Map<String, Object?> json) =>
      ProductSecurityControl(
        productId: json['productId']! as String,
        controlId: json['controlId']! as String,
        installedAtMinutes: (json['installedAtMinutes']! as num).toInt(),
      );
}

class SecurityAuditRecord {
  const SecurityAuditRecord({
    required this.productId,
    required this.simulationMinutes,
    required this.riskPercent,
    required this.findingsCount,
  });

  final String productId;
  final int simulationMinutes;
  final double riskPercent;
  final int findingsCount;

  Map<String, Object?> toJson() => <String, Object?>{
    'productId': productId,
    'simulationMinutes': simulationMinutes,
    'riskPercent': riskPercent,
    'findingsCount': findingsCount,
  };

  factory SecurityAuditRecord.fromJson(Map<String, Object?> json) =>
      SecurityAuditRecord(
        productId: json['productId']! as String,
        simulationMinutes: (json['simulationMinutes']! as num).toInt(),
        riskPercent: (json['riskPercent']! as num).toDouble(),
        findingsCount: (json['findingsCount']! as num).toInt(),
      );
}

class TrainingProgramOption {
  const TrainingProgramOption({
    required this.id,
    required this.name,
    required this.focus,
    required this.description,
    required this.cost,
    required this.skillDelta,
    required this.speedDelta,
    required this.qualityDelta,
    required this.autonomyDelta,
    required this.communicationDelta,
    required this.reliabilityDelta,
  });

  final String id;
  final String name;
  final TrainingFocus focus;
  final String description;
  final double cost;
  final int skillDelta;
  final int speedDelta;
  final int qualityDelta;
  final int autonomyDelta;
  final int communicationDelta;
  final int reliabilityDelta;
}

extension ManagedEmployee on Employee {
  Employee managedCopyWith({
    int? skill,
    int? speed,
    int? quality,
    int? autonomy,
    int? communication,
    int? reliability,
    double? salary,
    int? loyalty,
    int? morale,
    int? workload,
  }) {
    return Employee(
      id: id,
      name: name,
      role: role,
      skill: skill ?? this.skill,
      speed: speed ?? this.speed,
      quality: quality ?? this.quality,
      autonomy: autonomy ?? this.autonomy,
      communication: communication ?? this.communication,
      reliability: reliability ?? this.reliability,
      salary: salary ?? this.salary,
      loyalty: loyalty ?? this.loyalty,
      morale: morale ?? this.morale,
      workload: workload ?? this.workload,
      remote: remote,
      languageIds: languageIds,
    );
  }
}
