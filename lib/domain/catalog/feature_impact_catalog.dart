// UAT_FIXPACK_R1
import '../entities/models.dart';

class ProductFeaturePortfolioImpact {
  const ProductFeaturePortfolioImpact({
    required this.acquisitionMultiplier,
    required this.retentionBonus,
    required this.qualityBonus,
  });

  final double acquisitionMultiplier;
  final double retentionBonus;
  final double qualityBonus;
}

/// Product-specific feature/stack fit.
///
/// A core feature can materially accelerate acquisition and retention.
/// A generally compatible feature gives a smaller effect.
/// A feature researched for another product category does not create users by
/// itself and only contributes a tiny completeness/quality benefit.
abstract final class FeatureImpactCatalog {
  static int featureFitScore(
    ProductBlueprint blueprint,
    FeatureOption feature,
  ) {
    if (blueprint.expectedFeatureIds.contains(feature.id)) return 2;
    if (feature.supportedCategories.contains(blueprint.category)) return 1;
    return -1;
  }

  static double fitWeight(ProductBlueprint blueprint, FeatureOption feature) =>
      switch (featureFitScore(blueprint, feature)) {
        2 => 1.0,
        1 => 0.62,
        _ => 0.10,
      };

  static String featureMark(
    ProductBlueprint blueprint,
    FeatureOption feature,
  ) => switch (featureFitScore(blueprint, feature)) {
    2 => '++',
    1 => '+',
    _ => '-',
  };

  static String featureFitLabel(
    ProductBlueprint blueprint,
    FeatureOption feature,
  ) => switch (featureFitScore(blueprint, feature)) {
    2 => 'ключевая',
    1 => 'подходит',
    _ => 'слабая связь',
  };

  static ProductFeaturePortfolioImpact portfolioImpact({
    required Product product,
    required ProductBlueprint blueprint,
    required Iterable<FeatureOption> features,
  }) {
    var acquisition = 1.0;
    var retention = 0.0;
    var quality = 0.0;

    for (final id in product.featureIds) {
      final matches = features.where((item) => item.id == id);
      if (matches.isEmpty) continue;
      final feature = matches.first;
      final score = featureFitScore(blueprint, feature);
      if (score == 2) {
        acquisition +=
            0.055 + feature.retentionDelta.clamp(0.0, 0.08).toDouble() * 0.60;
        retention += feature.retentionDelta * 0.85;
        quality += 1.20;
      } else if (score == 1) {
        acquisition +=
            0.020 + feature.retentionDelta.clamp(0.0, 0.08).toDouble() * 0.25;
        retention += feature.retentionDelta * 0.45;
        quality += 0.60;
      } else {
        // Cross-category experiments cost time/compute but do not magically
        // create demand. A tiny quality bump represents completeness.
        quality += 0.18;
      }
    }

    return ProductFeaturePortfolioImpact(
      acquisitionMultiplier: acquisition.clamp(1.0, 1.65).toDouble(),
      retentionBonus: retention.clamp(0.0, 0.12).toDouble(),
      qualityBonus: quality.clamp(0.0, 8.0).toDouble(),
    );
  }

  static String technologyMark(
    ProductBlueprint blueprint,
    TechnologyOption technology,
  ) {
    final id = technology.id;
    final strong = switch (blueprint.category) {
      ProductCategory.aiAssistant => <String>{
        'vector_db',
        'observability_stack',
      },
      ProductCategory.cloud => <String>{'kubernetes', 'observability_stack'},
      ProductCategory.saas => <String>{'postgresql', 'redis'},
      ProductCategory.browser => <String>{'e2ee', 'cdn'},
      ProductCategory.cryptoWallet => <String>{'hsm', 'e2ee'},
      ProductCategory.developerTool => <String>{
        'observability_stack',
        'kubernetes',
      },
    };
    final useful = switch (blueprint.category) {
      ProductCategory.aiAssistant => <String>{
        'postgresql',
        'redis',
        'kubernetes',
      },
      ProductCategory.cloud => <String>{'postgresql', 'redis', 'cdn', 'hsm'},
      ProductCategory.saas => <String>{
        'observability_stack',
        'cdn',
        'e2ee',
        'kubernetes',
      },
      ProductCategory.browser => <String>{'observability_stack', 'hsm'},
      ProductCategory.cryptoWallet => <String>{
        'postgresql',
        'observability_stack',
      },
      ProductCategory.developerTool => <String>{
        'postgresql',
        'redis',
        'hsm',
        'cdn',
      },
    };
    if (strong.contains(id)) return '++';
    if (useful.contains(id)) return '+';
    return '-';
  }
}
