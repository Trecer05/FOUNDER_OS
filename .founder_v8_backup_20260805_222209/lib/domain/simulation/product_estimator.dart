import 'dart:math' as math;

import '../catalog/game_catalog.dart';

class ProductProjection {
  const ProductProjection({
    required this.developmentCost,
    required this.developmentHours,
    required this.speedMs,
    required this.designScore,
    required this.securityScore,
    required this.reliability,
    required this.featureCoverage,
    required this.qualityScore,
    required this.computeMultiplier,
    required this.monthlyTechCost,
  });

  final double developmentCost;
  final double developmentHours;
  final double speedMs;
  final double designScore;
  final double securityScore;
  final double reliability;
  final double featureCoverage;
  final double qualityScore;
  final double computeMultiplier;
  final double monthlyTechCost;
}

abstract final class ProductEstimator {
  static ProductProjection estimate({
    required String blueprintId,
    required String frameworkId,
    required List<String> languageIds,
    required List<String> technologyIds,
    required List<String> featureIds,
  }) {
    final blueprint = GameCatalog.blueprintById(blueprintId);
    final framework = GameCatalog.frameworkById(frameworkId);
    final languages = languageIds.map(GameCatalog.languageById).toList();
    final technologies = technologyIds.map(GameCatalog.technologyById).toList();
    final features = featureIds.map(GameCatalog.featureById).toList();

    final performancePoints =
        framework.performanceDelta +
        languages.fold<double>(0, (sum, item) => sum + item.performanceDelta) +
        technologies.fold<double>(
          0,
          (sum, item) => sum + item.performanceDelta,
        ) +
        features.fold<double>(0, (sum, item) => sum + item.performanceDelta);
    final speedMs = (blueprint.baseLatencyMs * (1 - performancePoints / 180))
        .clamp(55, blueprint.baseLatencyMs * 1.45)
        .toDouble();

    final designScore =
        (blueprint.baseDesignScore +
                framework.designDelta +
                features.fold<double>(0, (sum, item) => sum + item.designDelta))
            .clamp(10, 100)
            .toDouble();

    final securityScore =
        (blueprint.baseSecurityScore +
                framework.securityDelta +
                technologies.fold<double>(
                  0,
                  (sum, item) => sum + item.securityDelta,
                ) +
                features.fold<double>(
                  0,
                  (sum, item) => sum + item.securityDelta,
                ))
            .clamp(5, 100)
            .toDouble();

    final reliability =
        (blueprint.baseReliability +
                languages.fold<double>(
                  0,
                  (sum, item) => sum + item.reliabilityDelta,
                ) +
                technologies.fold<double>(
                  0,
                  (sum, item) => sum + item.reliabilityDelta,
                ))
            .clamp(0.75, 0.9995)
            .toDouble();

    final expected = blueprint.expectedFeatureIds.toSet();
    final selected = featureIds.toSet();
    final featureCoverage = expected.isEmpty
        ? 1.0
        : expected.intersection(selected).length / expected.length;

    final qualityScore =
        (designScore * 0.24 +
                securityScore * 0.24 +
                (100 - speedMs / blueprint.baseLatencyMs * 55).clamp(10, 100) *
                    0.22 +
                reliability * 100 * 0.18 +
                featureCoverage * 100 * 0.12)
            .clamp(1, 100)
            .toDouble();

    final developmentCost =
        blueprint.baseDevelopmentCost +
        technologies.fold<double>(
          0,
          (sum, item) => sum + item.developmentCost,
        ) +
        features.fold<double>(0, (sum, item) => sum + item.developmentCost);
    final languageComplexity = (math.max(0, languageIds.length - 1) * 0.08)
        .toDouble();
    final technologyComplexity = technologyIds.length * 0.035;
    final featureComplexity = featureIds.length * 0.06;
    final developmentHours =
        (blueprint.baseDevelopmentHours *
                (1 +
                    languageComplexity +
                    technologyComplexity +
                    featureComplexity) *
                (1 - framework.developmentSpeedDelta / 100).clamp(0.55, 1.45))
            .toDouble();

    final computeMultiplier =
        technologies.fold<double>(
          1,
          (value, item) => value * item.computeMultiplier,
        ) *
        features.fold<double>(
          1,
          (value, item) => value * item.computeMultiplier,
        );

    final monthlyTechCost =
        framework.monthlyCost +
        languages.fold<double>(0, (sum, item) => sum + item.monthlyCost) +
        technologies.fold<double>(0, (sum, item) => sum + item.monthlyCost);

    return ProductProjection(
      developmentCost: developmentCost,
      developmentHours: developmentHours,
      speedMs: speedMs,
      designScore: designScore,
      securityScore: securityScore,
      reliability: reliability,
      featureCoverage: featureCoverage,
      qualityScore: qualityScore,
      computeMultiplier: computeMultiplier,
      monthlyTechCost: monthlyTechCost,
    );
  }
}
