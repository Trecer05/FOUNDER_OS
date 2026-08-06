import 'dart:math' as math;

import '../catalog/product_strategy_catalog.dart';

class LanguageLimitExplanation {
  const LanguageLimitExplanation({
    required this.allowed,
    required this.base,
    required this.frameworkAdjustment,
    required this.requiredLanguages,
    required this.reasons,
  });

  final int allowed;
  final int base;
  final int frameworkAdjustment;
  final int requiredLanguages;
  final List<String> reasons;
}

abstract final class LanguageLimitResolver {
  static LanguageLimitExplanation resolve({
    required String blueprintId,
    required String frameworkId,
  }) {
    final strategy = ProductStrategyCatalog.strategyFor(blueprintId);
    final framework = ProductStrategyCatalog.frameworkProfile(frameworkId);
    final required = framework.requiredLanguageIds.length;
    final adjustment = framework.complexityMultiplier >= 1.18
        ? 1
        : framework.complexityMultiplier <= 0.84
        ? -1
        : 0;
    final allowed = math
        .max(required, strategy.maximumLanguageCount + adjustment)
        .clamp(1, 6)
        .toInt();
    final reasons = <String>[
      'База масштаба продукта: ${strategy.maximumLanguageCount}.',
      'Framework ×${framework.complexityMultiplier.toStringAsFixed(2)}: ${adjustment > 0 ? '+' : ''}$adjustment.',
      'Обязательных языков framework: $required.',
      'Итого можно выбрать $allowed. Лимит защищает скорость команды и стоимость поддержки.',
    ];
    return LanguageLimitExplanation(
      allowed: allowed,
      base: strategy.maximumLanguageCount,
      frameworkAdjustment: adjustment,
      requiredLanguages: required,
      reasons: List<String>.unmodifiable(reasons),
    );
  }
}
