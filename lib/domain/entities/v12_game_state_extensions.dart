import 'dart:math' as math;

import 'game_state.dart';
import 'models.dart';
import 'v12_models.dart';

extension FounderV12GameState on GameState {
  FounderDevelopmentStage founderStageFor(Product product) {
    final progress = product.developmentProgress.clamp(0, 1).toDouble();
    if (progress < 0.20) {
      return FounderDevelopmentStage.planning;
    }
    if (progress < 0.38) {
      return FounderDevelopmentStage.design;
    }
    if (progress < 0.82) {
      return FounderDevelopmentStage.implementation;
    }
    return FounderDevelopmentStage.debugging;
  }

  double founderDevelopmentCapacityFor(Product product) {
    if (!companyProfile.configured ||
        product.stage != ProductStage.development) {
      return 0;
    }
    final stage = founderStageFor(product);
    final relevantSkill = switch (stage) {
      FounderDevelopmentStage.planning => FounderSkill.product,
      FounderDevelopmentStage.design => FounderSkill.design,
      FounderDevelopmentStage.implementation => FounderSkill.engineering,
      FounderDevelopmentStage.debugging => FounderSkill.operations,
    };
    final primary = companyProfile.effectiveSkill(relevantSkill);
    final support = switch (stage) {
      FounderDevelopmentStage.planning => companyProfile.effectiveSkill(
        FounderSkill.negotiation,
      ),
      FounderDevelopmentStage.design => companyProfile.effectiveSkill(
        FounderSkill.product,
      ),
      FounderDevelopmentStage.implementation => companyProfile.effectiveSkill(
        FounderSkill.operations,
      ),
      FounderDevelopmentStage.debugging => companyProfile.effectiveSkill(
        FounderSkill.engineering,
      ),
    };

    final base = 0.12 + primary * 0.055 + support * 0.018;
    final activeDevelopmentProducts = math.max(
      1,
      products.where((item) => item.stage == ProductStage.development).length,
    );
    return (base / activeDevelopmentProducts).clamp(0.08, 0.62).toDouble();
  }

  double totalDevelopmentCapacityFor(Product product) =>
      productDevelopmentCapacity(product.id) +
      founderDevelopmentCapacityFor(product);

  double founderFeatureWorkCapacityFor(Product product) {
    if (!companyProfile.configured || product.stage != ProductStage.live) {
      return 0;
    }
    final engineering = companyProfile.effectiveSkill(FounderSkill.engineering);
    final operations = companyProfile.effectiveSkill(FounderSkill.operations);
    final base = 0.08 + engineering * 0.040 + operations * 0.026;
    final concurrentWork = math.max(
      1,
      productFeatureDevelopments.where((item) => item.progress < 1).length,
    );
    return (base / concurrentWork).clamp(0.06, 0.44).toDouble();
  }

  double get founderSalaryMultiplier => companyProfile.employeeSalaryMultiplier;
  double get founderOfficeMultiplier => companyProfile.officeRentMultiplier;
  double get founderProductSetupMultiplier =>
      companyProfile.productSetupCostMultiplier;
  double get founderImprovementMultiplier =>
      companyProfile.improvementHoursMultiplier;
  double get founderGrowthMultiplier =>
      companyProfile.growthEfficiencyMultiplier;

  String founderStageNameRu(FounderDevelopmentStage stage) => switch (stage) {
    FounderDevelopmentStage.planning => 'Проектирование',
    FounderDevelopmentStage.design => 'Дизайн',
    FounderDevelopmentStage.implementation => 'Разработка',
    FounderDevelopmentStage.debugging => 'Отладка',
  };

  String founderStageNameEn(FounderDevelopmentStage stage) => switch (stage) {
    FounderDevelopmentStage.planning => 'Planning',
    FounderDevelopmentStage.design => 'Design',
    FounderDevelopmentStage.implementation => 'Development',
    FounderDevelopmentStage.debugging => 'Debugging',
  };

  double founderStageStart(FounderDevelopmentStage stage) => switch (stage) {
    FounderDevelopmentStage.planning => 0,
    FounderDevelopmentStage.design => 0.20,
    FounderDevelopmentStage.implementation => 0.38,
    FounderDevelopmentStage.debugging => 0.82,
  };

  double founderStageEnd(FounderDevelopmentStage stage) => switch (stage) {
    FounderDevelopmentStage.planning => 0.20,
    FounderDevelopmentStage.design => 0.38,
    FounderDevelopmentStage.implementation => 0.82,
    FounderDevelopmentStage.debugging => 1,
  };

  double founderStageProgress(Product product) {
    final stage = founderStageFor(product);
    final start = founderStageStart(stage);
    final end = founderStageEnd(stage);
    if (end <= start) {
      return 1;
    }
    return ((product.developmentProgress - start) / (end - start))
        .clamp(0, 1)
        .toDouble();
  }

  // Kept for v12 save/test compatibility. v12.2 no longer exposes a daily
  // challenge; the project-wide key below is authoritative for new gameplay.
  String developmentChallengeKey(
    Product product,
    FounderDevelopmentStage stage,
  ) => 'v12_challenge:${product.id}:${stage.name}:$day';

  bool developmentChallengeCompletedToday(
    Product product,
    FounderDevelopmentStage stage,
  ) {
    final key = developmentChallengeKey(product, stage);
    return productUpdates.any(
      (item) => item.productId == product.id && item.reason == key,
    );
  }

  String projectChallengeKey(Product product) =>
      'v12_2_project_challenge:${product.id}';

  bool projectChallengeHandled(Product product) {
    final key = projectChallengeKey(product);
    return productUpdates.any(
      (item) => item.productId == product.id && item.reason == key,
    );
  }

  bool projectChallengeEligible(Product product) {
    if (!miniGamesEnabled ||
        product.stage != ProductStage.development ||
        projectChallengeHandled(product)) {
      return false;
    }
    final stage = founderStageFor(product);
    if (stage != FounderDevelopmentStage.implementation &&
        stage != FounderDevelopmentStage.debugging) {
      return false;
    }
    // Do not interrupt the exact transition frame. The challenge appears once
    // the player has visibly entered the coding/debugging phase.
    return founderStageProgress(product) >= 0.12;
  }

  Product? get pendingProjectChallengeProduct {
    for (final product in products) {
      if (projectChallengeEligible(product)) {
        return product;
      }
    }
    return null;
  }
}
