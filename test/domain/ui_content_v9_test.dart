import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/catalog/v9_content_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/business_models.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/v9_models.dart';
import 'package:founder_os/domain/explainability/product_configuration_resolver.dart';
import 'package:founder_os/domain/explainability/staffing_deficit_resolver.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/domain/validation/v9_content_validator.dart';

void main() {
  const engine = GameEngine();

  test('snapshot v9 migrates v8 and preserves RNG', () {
    final original = GameState.initial().copyWith(rngSeed: 77, rngCounter: 19);
    final json = original.toJson()..['snapshotVersion'] = 8;
    json.remove('selectedHostingPlanId');
    final migrated = GameState.decode(jsonEncode(json));

    expect(migrated.snapshotVersion, 9);
    expect(migrated.selectedHostingPlanId, 'shared_launch');
    expect(migrated.rngSeed, 77);
    expect(migrated.rngCounter, 19);
    expect(
      GameState.decode(migrated.encode()).selectedHostingPlanId,
      'shared_launch',
    );
  });

  test('technology limit is dynamic and explained', () {
    final lean = ProductConfigurationResolver.technologyLimit(
      state: GameState.initial(),
      blueprintId: 'team_saas',
      frameworkId: 'next_nest',
      featureIds: const <String>['team_spaces'],
      selectedTechnologyIds: const <String>[],
    );
    final strongTeam = List<Employee>.generate(
      4,
      (index) => Employee(
        id: 'engineer_$index',
        name: 'Engineer $index',
        role: index.isEven ? EmployeeRole.backend : EmployeeRole.devOps,
        skill: 90,
        speed: 85,
        quality: 88,
        autonomy: 90,
        communication: 75,
        reliability: 92,
        salary: 200000,
        loyalty: 80,
        morale: 80,
        workload: 20,
        remote: true,
        languageIds: const <String>['typescript'],
      ),
    );
    final expanded = ProductConfigurationResolver.technologyLimit(
      state: GameState.initial().copyWith(employees: strongTeam),
      blueprintId: 'team_saas',
      frameworkId: 'next_nest',
      featureIds: const <String>[
        'team_spaces',
        'realtime_collaboration',
        'automation',
        'mobile_client',
        'analytics_dashboard',
        'contact_form',
      ],
      selectedTechnologyIds: const <String>[],
    );

    expect(expanded.allowed, greaterThan(lean.allowed));
    expect(expanded.reasons.join(' '), contains('Возможности команды'));
    expect(expanded.reasons.join(' '), contains('Функций 6'));
  });

  test('incompatible technology has concrete deterministic reason', () {
    final availability = ProductConfigurationResolver.availability(
      frameworkId: 'next_nest',
      languageIds: const <String>['typescript'],
      selectedTechnologyIds: const <String>[],
      technology: GameCatalog.technologyById('kubernetes'),
    );
    expect(availability.enabled, isFalse);
    expect(availability.reason, contains('microservices'));
    expect(availability.nextStep, contains('framework'));
  });

  test('specialist deficits are concrete and stably ordered', () {
    var state = engine.reduce(
      GameState.initial().copyWith(cash: 10000000),
      const CreateConfiguredProduct(
        name: 'Stack Test',
        blueprintId: 'team_saas',
        frameworkId: 'next_nest',
        languageIds: <String>['typescript'],
        technologyIds: <String>['postgresql'],
        featureIds: <String>['team_spaces'],
      ),
    );
    final product = state.products.single;
    final first = StaffingDeficitResolver.forProduct(state, product);
    final second = StaffingDeficitResolver.forProduct(state, product);

    expect(
      first.map((item) => item.message),
      second.map((item) => item.message),
    );
    expect(first, isNotEmpty);
    expect(first.first.message, contains('навык'));
    expect(first.first.solutions, isNotEmpty);
  });

  test('hire charges signing bonus, never full monthly salary', () {
    final initial = GameState.initial().copyWith(cash: 10000000);
    final candidate = initial.candidates.first;
    final hired = engine.reduce(initial, HireCandidate(candidate.id));
    final charged = initial.cash - hired.cash;

    expect(charged, greaterThan(0));
    expect(charged, lessThanOrEqualTo(candidate.salary * 0.15));
    expect(hired.employees.single.hiredAtMinutes, initial.simulationMinutes);
    expect(
      hired.financeTransactions.first.description,
      contains('Signing bonus'),
    );
  });

  test('payroll accrues for the actual partial period and is explained', () {
    var state = GameState.initial().copyWith(cash: 10000000, paused: false);
    final candidate = state.candidates.first;
    state = engine.reduce(state, HireCandidate(candidate.id));
    final afterHire = state;
    state = engine.reduce(
      state,
      const AdvanceTime(5400),
    ); // 21,600 game minutes

    final payroll = state.financeTransactions.firstWhere(
      (item) => item.category.name == 'payroll',
    );
    expect(payroll.amount.abs(), closeTo(candidate.salary * 0.5, 1));
    expect(payroll.description, contains(candidate.name));
    expect(payroll.description, contains('период'));
    expect(state.cash, lessThan(afterHire.cash));
  });

  test('contract uses advance, milestone and final payment', () {
    var state = _releasedWebsite().copyWith(cash: 10000000, paused: false);
    state = engine.reduce(state, const AcceptClientContract('landing_launch'));
    expect(state.financeTransactions.first.description, contains('Аванс'));

    final accepted = state.activeContracts.single;
    state = state.copyWith(
      clientContracts: <ClientContract>[accepted.copyWith(progress: 0.99)],
    );
    state = engine.reduce(state, const AdvanceTime(3600));

    final descriptions = state.financeTransactions
        .map((item) => item.description)
        .join(' | ');
    expect(descriptions, contains('Этап 50%'));
    expect(state.completedContracts, isNotEmpty);
    expect(descriptions, contains('Финальная выплата'));
  });

  test(
    'company starts on rented hosting and owned migration has requirements',
    () {
      final initial = GameState.initial();
      expect(initial.hostingPlan.kind, isNot(HostingKind.owned));
      expect(initial.totalComputeUnits, initial.hostingPlan.computeUnits);

      final blocked = engine.reduce(
        initial,
        const MigrateToOwnedInfrastructure(),
      );
      expect(blocked.selectedHostingPlanId, initial.selectedHostingPlanId);
      expect(blocked.feed.first.toLowerCase(), contains('миграц'));
    },
  );

  test('hosting limits influence compute and persist after restart', () {
    var state = GameState.initial().copyWith(cash: 10000000);
    state = engine.reduce(state, const RentHostingPlan('managed_scale'));
    expect(
      state.totalComputeUnits,
      V9ContentCatalog.hostingById('managed_scale').computeUnits,
    );
    final restored = GameState.decode(state.encode());
    expect(restored.selectedHostingPlanId, 'managed_scale');
    expect(restored.totalComputeUnits, state.totalComputeUnits);
  });

  test('runtime v9 help and hosting catalogs validate', () {
    expect(V9ContentValidator.validate(), isEmpty);
    expect(V9ContentCatalog.glossary.length, greaterThanOrEqualTo(34));
    expect(
      V9ContentCatalog.hostingPlans.map((item) => item.kind),
      containsAll(<HostingKind>[
        HostingKind.shared,
        HostingKind.vps,
        HostingKind.managed,
        HostingKind.cloudCompute,
        HostingKind.managedDatabase,
        HostingKind.objectStorage,
        HostingKind.cdn,
        HostingKind.serverless,
        HostingKind.owned,
      ]),
    );
  });

  test(
    'expanded data catalog grows by more than seven times without duplicate IDs',
    () {
      final root =
          jsonDecode(
                File('assets/data/content_catalog_v9.json').readAsStringSync(),
              )
              as Map<String, dynamic>;
      final totals = root['totals'] as Map<String, dynamic>;
      expect((totals['v9'] as num), greaterThan((totals['v8'] as num) * 7));
      final categories = root['categories'] as Map<String, dynamic>;
      final allIds = <String>[];
      for (final value in categories.values) {
        for (final item in value as List<dynamic>) {
          final map = item as Map<String, dynamic>;
          expect((map['name'] as String).trim(), isNotEmpty);
          expect((map['tooltip'] as String).trim(), isNotEmpty);
          allIds.add(map['id'] as String);
        }
      }
      expect(allIds.toSet().length, allIds.length);
    },
  );

  test('ecosystem pair remains unique and delayed integration persists', () {
    var state = _twoProducts();
    final first = state.products[0];
    final second = state.products[1];
    state = state.copyWith(
      employees: <Employee>[
        Employee(
          id: 'free_backend',
          name: 'Free Backend',
          role: EmployeeRole.backend,
          skill: 80,
          speed: 80,
          quality: 80,
          autonomy: 80,
          communication: 80,
          reliability: 80,
          salary: 150000,
          loyalty: 80,
          morale: 80,
          workload: 20,
          remote: true,
          languageIds: const <String>['typescript'],
        ),
      ],
      cash: 10000000,
    );
    state = engine.reduce(
      state,
      ConnectProducts(firstProductId: first.id, secondProductId: second.id),
    );
    final once = state.ecosystemLinks.length;
    state = engine.reduce(
      state,
      ConnectProducts(firstProductId: second.id, secondProductId: first.id),
    );
    expect(state.ecosystemLinks.length, once);
    expect(
      state.ecosystemLinks.single.activeAtMinutes,
      greaterThan(state.ecosystemLinks.single.connectedAtMinutes),
    );
    expect(
      GameState.decode(state.encode()).ecosystemLinks.single.activeAtMinutes,
      state.ecosystemLinks.single.activeAtMinutes,
    );
  });
}

GameState _releasedWebsite() {
  const engine = GameEngine();
  var state = engine.reduce(
    GameState.initial().copyWith(cash: 10000000),
    const CreateConfiguredProduct(
      name: 'Founder Site',
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: <String>['html_css'],
      technologyIds: <String>[],
      featureIds: <String>['landing_page'],
    ),
  );
  final product = state.products.single;
  state = state.copyWith(
    products: <Product>[
      product.copyWith(developmentProgress: 1, allocatedCapacityPercent: 50),
    ],
  );
  return engine.reduce(state, LaunchProduct(product.id));
}

GameState _twoProducts() {
  const engine = GameEngine();
  var state = _releasedWebsite();
  state = engine.reduce(
    state.copyWith(cash: 10000000),
    const CreateConfiguredProduct(
      name: 'Second Product',
      blueprintId: 'team_saas',
      frameworkId: 'next_nest',
      languageIds: <String>['typescript'],
      technologyIds: <String>['postgresql'],
      featureIds: <String>['team_spaces'],
    ),
  );
  return state;
}
