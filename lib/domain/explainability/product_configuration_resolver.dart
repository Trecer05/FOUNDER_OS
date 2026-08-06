import 'dart:math' as math;

import '../catalog/product_strategy_catalog.dart';
import '../entities/game_state.dart';
import '../entities/models.dart';
import '../entities/product_strategy_models.dart';
import '../entities/v9_models.dart';

abstract final class ProductConfigurationResolver {
  static TechnologyLimitExplanation technologyLimit({
    required GameState state,
    required String blueprintId,
    required String frameworkId,
    required Iterable<String> featureIds,
    required Iterable<String> selectedTechnologyIds,
  }) {
    final strategy = ProductStrategyCatalog.strategyFor(blueprintId);
    final framework = ProductStrategyCatalog.frameworkProfile(frameworkId);
    final features = featureIds.toSet();
    final technologies = selectedTechnologyIds.toSet();

    final base = math.max(1, strategy.maximumTechnologyCount - 1);
    final scopeAdjustment = switch (strategy.scope) {
      ProductScope.starter => 0,
      ProductScope.standard => 1,
      ProductScope.advanced => 2,
      ProductScope.moonshot => 3,
    };
    final frameworkAdjustment = framework.complexityMultiplier <= 0.95
        ? 1
        : framework.complexityMultiplier >= 1.28
        ? -1
        : 0;
    final featureAdjustment = features.length >= 6
        ? 2
        : features.length >= 3
        ? 1
        : 0;
    final engineering = state.employees.where(
      (employee) => const <EmployeeRole>{
        EmployeeRole.frontend,
        EmployeeRole.backend,
        EmployeeRole.mobile,
        EmployeeRole.aiMl,
        EmployeeRole.devOps,
        EmployeeRole.security,
      }.contains(employee.role),
    );
    final teamScore = engineering.isEmpty
        ? 0.0
        : engineering
                  .map(
                    (employee) =>
                        employee.skill * 0.55 +
                        employee.autonomy * 0.25 +
                        employee.reliability * 0.20,
                  )
                  .reduce((a, b) => a + b) /
              engineering.length;
    final teamAdjustment = teamScore >= 78
        ? 2
        : teamScore >= 60
        ? 1
        : teamScore < 42
        ? -1
        : 0;
    final maintenancePenalty = math.max(0, technologies.length - 4) ~/ 2;
    final allowed =
        (base +
                scopeAdjustment +
                frameworkAdjustment +
                featureAdjustment +
                teamAdjustment -
                maintenancePenalty)
            .clamp(1, 9)
            .toInt();
    final reasons = <String>[
      'База продукта: $base.',
      'Масштаб ${_scopeName(strategy.scope)}: ${_signed(scopeAdjustment)}.',
      'Сложность framework ×${framework.complexityMultiplier.toStringAsFixed(2)}: ${_signed(frameworkAdjustment)}.',
      'Функций ${features.length}: ${_signed(featureAdjustment)}.',
      'Возможности команды: ${_signed(teamAdjustment)}.',
      if (maintenancePenalty > 0)
        'Штраф за сопровождение большого стека: −$maintenancePenalty.',
      'Итоговый лимит пересчитывается после изменения framework, функций, технологий и команды.',
    ];
    return TechnologyLimitExplanation(
      allowed: allowed,
      selected: technologies.length,
      baseLimit: base,
      scopeAdjustment: scopeAdjustment,
      frameworkAdjustment: frameworkAdjustment,
      featureAdjustment: featureAdjustment,
      teamAdjustment: teamAdjustment,
      maintenancePenalty: maintenancePenalty,
      reasons: List<String>.unmodifiable(reasons),
    );
  }

  static TechnologyAvailability availability({
    required String frameworkId,
    required Iterable<String> languageIds,
    required Iterable<String> selectedTechnologyIds,
    required TechnologyOption technology,
  }) {
    final languages = languageIds.toSet();
    final selected = selectedTechnologyIds.toSet();
    final mandatory = mandatoryTechnologyId(frameworkId) == technology.id;
    if (technology.id == 'kubernetes' &&
        !const <String>{
          'go_microservices',
          'java_enterprise',
        }.contains(frameworkId)) {
      return const TechnologyAvailability(
        enabled: false,
        mandatory: false,
        reason:
            'Kubernetes оправдан только для microservices или enterprise framework.',
        nextStep: 'Смените framework или уберите Kubernetes.',
      );
    }
    if (technology.id == 'vector_db' && !languages.contains('python')) {
      return const TechnologyAvailability(
        enabled: false,
        mandatory: false,
        reason:
            'Vector database требует Python/AI-стек для эффективной интеграции.',
        nextStep: 'Добавьте Python или уберите Vector database.',
      );
    }
    if (technology.id == 'hsm' &&
        !languages.any(
          const <String>{'rust', 'go', 'kotlin', 'swift'}.contains,
        )) {
      return const TechnologyAvailability(
        enabled: false,
        mandatory: false,
        reason:
            'HSM требует системный или mobile-язык: Rust, Go, Kotlin или Swift.',
        nextStep: 'Добавьте подходящий язык или уберите HSM.',
      );
    }
    if (technology.id == 'redis' && selected.contains('edge_cache')) {
      return const TechnologyAvailability(
        enabled: false,
        mandatory: false,
        reason: 'Redis cache дублирует выбранный edge cache на этом масштабе.',
        nextStep: 'Оставьте один слой cache.',
      );
    }
    return TechnologyAvailability(
      enabled: true,
      mandatory: mandatory,
      reason: null,
      nextStep: null,
    );
  }

  static TechnologyImpact impact(TechnologyOption technology) {
    final hiring =
        technology.id == 'kubernetes' ||
            technology.id == 'hsm' ||
            technology.id == 'vector_db'
        ? 0.24
        : 0.08;
    final debt =
        (technology.computeMultiplier - 1) * 0.8 +
        (technology.monthlyCost / 200000);
    return TechnologyImpact(
      developmentHoursDelta: technology.developmentCost / 520,
      technicalDebtDelta: debt,
      infrastructureCostDelta: technology.monthlyCost,
      hiringDifficultyDelta: hiring,
      developmentSpeedDelta: technology.performanceDelta / 100,
      supportDifficultyDelta: (technology.computeMultiplier - 1) + hiring * 0.5,
      stabilityDelta: technology.reliabilityDelta,
    );
  }

  static String? mandatoryTechnologyId(String frameworkId) =>
      switch (frameworkId) {
        'chromium_fork' => 'observability_stack',
        'go_microservices' => 'observability_stack',
        'java_enterprise' => 'postgresql',
        _ => null,
      };

  static String _scopeName(ProductScope scope) => switch (scope) {
    ProductScope.starter => 'starter',
    ProductScope.standard => 'standard',
    ProductScope.advanced => 'advanced',
    ProductScope.moonshot => 'moonshot',
  };

  static String _signed(int value) => value > 0 ? '+$value' : '$value';
}
