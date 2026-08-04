import 'models.dart';

enum AiDeploymentMode { publicMarket, corporate }

enum ProductImprovementType {
  performance,
  algorithms,
  design,
  security,
  reliability,
}

class ProductAiDeployment {
  const ProductAiDeployment({required this.productId, required this.mode});

  final String productId;
  final AiDeploymentMode mode;

  Map<String, Object?> toJson() => <String, Object?>{
    'productId': productId,
    'mode': mode.name,
  };

  factory ProductAiDeployment.fromJson(Map<String, Object?> json) =>
      ProductAiDeployment(
        productId: json['productId']! as String,
        mode: AiDeploymentMode.values.byName(json['mode']! as String),
      );
}

class ProductUpdateRecord {
  const ProductUpdateRecord({
    required this.productId,
    required this.updatedAtMinutes,
    required this.reason,
  });

  final String productId;
  final int updatedAtMinutes;
  final String reason;

  Map<String, Object?> toJson() => <String, Object?>{
    'productId': productId,
    'updatedAtMinutes': updatedAtMinutes,
    'reason': reason,
  };

  factory ProductUpdateRecord.fromJson(Map<String, Object?> json) =>
      ProductUpdateRecord(
        productId: json['productId']! as String,
        updatedAtMinutes: (json['updatedAtMinutes']! as num).toInt(),
        reason: json['reason']! as String,
      );
}

class ProductAiIntegration {
  const ProductAiIntegration({
    required this.aiProductId,
    required this.targetProductId,
    required this.connectedAtMinutes,
  });

  final String aiProductId;
  final String targetProductId;
  final int connectedAtMinutes;

  Map<String, Object?> toJson() => <String, Object?>{
    'aiProductId': aiProductId,
    'targetProductId': targetProductId,
    'connectedAtMinutes': connectedAtMinutes,
  };

  factory ProductAiIntegration.fromJson(Map<String, Object?> json) =>
      ProductAiIntegration(
        aiProductId: json['aiProductId']! as String,
        targetProductId: json['targetProductId']! as String,
        connectedAtMinutes: (json['connectedAtMinutes']! as num).toInt(),
      );
}

class ProductRoleRequirement {
  const ProductRoleRequirement({
    required this.role,
    required this.minimumCount,
    required this.reason,
  });

  final EmployeeRole role;
  final int minimumCount;
  final String reason;
}

class ProductImprovementOption {
  const ProductImprovementOption({
    required this.type,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.monthlyCostDelta,
    required this.speedMultiplier,
    required this.designDelta,
    required this.securityDelta,
    required this.reliabilityDelta,
    required this.qualityDelta,
    required this.retentionDelta,
    required this.computeMultiplier,
  });

  final ProductImprovementType type;
  final String name;
  final String description;
  final double baseCost;
  final double monthlyCostDelta;
  final double speedMultiplier;
  final double designDelta;
  final double securityDelta;
  final double reliabilityDelta;
  final double qualityDelta;
  final double retentionDelta;
  final double computeMultiplier;
}

class ProductImprovementRecord {
  const ProductImprovementRecord({
    required this.productId,
    required this.type,
    required this.level,
    required this.appliedAtMinutes,
  });

  final String productId;
  final ProductImprovementType type;
  final int level;
  final int appliedAtMinutes;

  Map<String, Object?> toJson() => <String, Object?>{
    'productId': productId,
    'type': type.name,
    'level': level,
    'appliedAtMinutes': appliedAtMinutes,
  };

  factory ProductImprovementRecord.fromJson(Map<String, Object?> json) =>
      ProductImprovementRecord(
        productId: json['productId']! as String,
        type: ProductImprovementType.values.byName(json['type']! as String),
        level: (json['level']! as num).toInt(),
        appliedAtMinutes: (json['appliedAtMinutes']! as num).toInt(),
      );
}
