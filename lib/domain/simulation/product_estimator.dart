// UAT_FIXPACK_R1
import 'dart:math' as math;

import '../catalog/game_catalog.dart';
import '../catalog/feature_impact_catalog.dart';
import '../catalog/product_strategy_catalog.dart';

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
    required this.stackCoherence,
    required this.warnings,
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
  final double stackCoherence;
  final List<String> warnings;
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
    final strategy = ProductStrategyCatalog.strategyFor(blueprintId);
    final frameworkStrategy = ProductStrategyCatalog.frameworkProfile(
      frameworkId,
    );
    final frameworkAllowed = strategy.allowedFrameworkIds.contains(frameworkId);
    final languages = languageIds.map(GameCatalog.languageById).toList();
    final languageStrategies = languageIds
        .map(ProductStrategyCatalog.languageProfile)
        .toList(growable: false);
    final technologies = technologyIds.map(GameCatalog.technologyById).toList();
    final features = featureIds.map(GameCatalog.featureById).toList();
    final warnings = <String>[];

    final requiredLanguages = frameworkStrategy.requiredLanguageIds.toSet();
    final selectedLanguages = languageIds.toSet();
    final missingFrameworkLanguages = requiredLanguages
        .difference(selectedLanguages)
        .length;
    final excessLanguages = math
        .max(0, languageIds.length - strategy.maximumLanguageCount)
        .toInt();
    final excessTechnologies = math
        .max(0, technologyIds.length - strategy.maximumTechnologyCount)
        .toInt();
    final recommendedMatches = selectedLanguages
        .intersection(strategy.recommendedLanguageIds.toSet())
        .length;
    final recommendationRatio = strategy.recommendedLanguageIds.isEmpty
        ? 1.0
        : recommendedMatches / strategy.recommendedLanguageIds.length;

    if (!frameworkAllowed) {
      warnings.add(
        'Этот framework не предназначен для выбранного масштаба продукта.',
      );
    }
    if (missingFrameworkLanguages > 0) {
      warnings.add(
        'Framework требует: ${requiredLanguages.difference(selectedLanguages).map((id) => GameCatalog.languageById(id).name).join(', ')}.',
      );
    }
    if (excessLanguages > 0) {
      warnings.add(
        'Лишних языков: $excessLanguages. Коммуникация и интеграции замедлят разработку.',
      );
    }
    if (recommendationRatio < 0.5) {
      warnings.add('Стек плохо соответствует типу продукта.');
    }
    if (excessTechnologies > 0) {
      warnings.add(
        'Лишних технологий: $excessTechnologies. Интеграции, поддержка и compute съедят выгоду.',
      );
    }

    final stackCoherence =
        (1 -
                (frameworkAllowed ? 0 : 0.24) -
                missingFrameworkLanguages * 0.22 -
                excessLanguages * 0.14 -
                excessTechnologies * 0.11 -
                (1 - recommendationRatio) * 0.18)
            .clamp(0.35, 1.0)
            .toDouble();

    final performancePoints =
        framework.performanceDelta +
        languages.fold<double>(0, (sum, item) => sum + item.performanceDelta) +
        technologies.fold<double>(
          0,
          (sum, item) => sum + item.performanceDelta,
        ) +
        features.fold<double>(
          0,
          (sum, item) =>
              sum +
              item.performanceDelta *
                  FeatureImpactCatalog.fitWeight(blueprint, item),
        );
    final speedMs =
        (blueprint.baseLatencyMs *
                (1 - performancePoints / 220) /
                (0.82 + stackCoherence * 0.18))
            .clamp(55, blueprint.baseLatencyMs * 1.75)
            .toDouble();

    final designScore =
        (blueprint.baseDesignScore +
                framework.designDelta +
                features.fold<double>(
                  0,
                  (sum, item) =>
                      sum +
                      item.designDelta *
                          FeatureImpactCatalog.fitWeight(blueprint, item),
                ))
            .clamp(10, 96)
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
                  (sum, item) =>
                      sum +
                      item.securityDelta *
                          FeatureImpactCatalog.fitWeight(blueprint, item),
                ) -
                missingFrameworkLanguages * 4 -
                excessTechnologies * 2.5)
            .clamp(5, 96)
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
                ) -
                excessLanguages * 0.004 -
                excessTechnologies * 0.003)
            .clamp(0.75, 0.9985)
            .toDouble();

    final expected = blueprint.expectedFeatureIds.toSet();
    final selected = featureIds.toSet();
    final featureCoverage = expected.isEmpty
        ? 1.0
        : expected.intersection(selected).length / expected.length;

    final rawQuality =
        designScore * 0.22 +
        securityScore * 0.24 +
        (100 - speedMs / blueprint.baseLatencyMs * 55).clamp(10, 100) * 0.20 +
        reliability * 100 * 0.18 +
        featureCoverage * 100 * 0.16;
    final qualityScore = (rawQuality * (0.72 + stackCoherence * 0.28))
        .clamp(1, 92)
        .toDouble();

    final featureHours = features.fold<double>(
      0,
      (sum, item) => sum + math.max(20, item.developmentCost / 520),
    );
    final technologyHours = technologies.fold<double>(
      0,
      (sum, item) => sum + math.max(12, item.developmentCost / 850),
    );
    final languageComplexity = languageStrategies.fold<double>(
      1,
      (value, item) => value * item.complexityMultiplier,
    );
    final multiLanguageCoordination =
        1 + math.max(0, languageIds.length - 1) * 0.12 + excessLanguages * 0.18;
    final missingRequirementPenalty = 1 + missingFrameworkLanguages * 0.30;
    final technologyCoordination =
        1 +
        math.max(0, technologyIds.length - 2) * 0.06 +
        excessTechnologies * 0.22;
    final developmentHours =
        ((strategy.baseHours + featureHours + technologyHours) *
                frameworkStrategy.complexityMultiplier *
                languageComplexity.clamp(0.72, 1.75).toDouble() *
                multiLanguageCoordination *
                technologyCoordination *
                missingRequirementPenalty *
                (1 - framework.developmentSpeedDelta / 220)
                    .clamp(0.72, 1.35)
                    .toDouble())
            .toDouble();

    final setupCost =
        strategy.setupCost +
        technologies.fold<double>(
          0,
          (sum, item) => sum + item.developmentCost * 0.18,
        ) +
        framework.monthlyCost * 0.5;

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

    if (technologyIds.length == strategy.maximumTechnologyCount) {
      warnings.add(
        'Технологический лимит выбран полностью. Это не гарантирует успех: срок, burn и найм уже выросли.',
      );
    }

    if (featureIds.length > blueprint.expectedFeatureIds.length + 2) {
      warnings.add(
        'Roadmap перегружен. Лишние функции увеличивают срок до первой проверки рынка.',
      );
    }

    return ProductProjection(
      developmentCost: setupCost,
      developmentHours: developmentHours,
      speedMs: speedMs,
      designScore: designScore,
      securityScore: securityScore,
      reliability: reliability,
      featureCoverage: featureCoverage,
      qualityScore: qualityScore,
      computeMultiplier: computeMultiplier,
      monthlyTechCost: monthlyTechCost,
      stackCoherence: stackCoherence,
      warnings: List<String>.unmodifiable(warnings),
    );
  }
}
