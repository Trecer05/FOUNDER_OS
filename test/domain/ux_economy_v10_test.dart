import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/contract_catalog.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/business_models.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/product_evolution_models.dart';
import 'package:founder_os/domain/entities/v10_models.dart';
import 'package:founder_os/domain/explainability/language_limit_resolver.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('language limit explicitly depends on framework', () {
    final staticLimit = LanguageLimitResolver.resolve(
      blueprintId: 'company_website',
      frameworkId: 'static_web',
    );
    final laravelLimit = LanguageLimitResolver.resolve(
      blueprintId: 'company_website',
      frameworkId: 'laravel_web',
    );

    expect(
      staticLimit.allowed,
      greaterThanOrEqualTo(staticLimit.requiredLanguages),
    );
    expect(
      laravelLimit.allowed,
      greaterThanOrEqualTo(laravelLimit.requiredLanguages),
    );
    expect(staticLimit.reasons.join(' '), contains('Framework'));
    expect(staticLimit.reasons.join(' '), contains('Итого'));
  });

  test(
    'remote rented start has no office bill or purchased physical servers',
    () {
      final state = GameState.initial();

      expect(state.monthlyOfficeCost, 0);
      expect(state.usingOwnedInfrastructure, isFalse);
      expect(state.installedServers, isEmpty);
      expect(state.preparedComputeUnits, 0);
      expect(state.totalComputeUnits, state.hostingPlan.computeUnits);
    },
  );

  test(
    'employee can participate in two products at seventy percent efficiency',
    () {
      var state = _twoProducts();
      final employee = state.candidates.firstWhere((item) => !item.isHr).toEmployee();
      state = state.copyWith(
        employees: <Employee>[employee],
        candidates: state.candidates
            .where((candidate) => candidate.id != employee.id)
            .toList(growable: false),
      );

      state = engine.reduce(
        state,
        AssignEmployeeToProduct(
          employeeId: employee.id,
          productId: state.products[0].id,
        ),
      );
      state = engine.reduce(
        state,
        AssignEmployeeToProduct(
          employeeId: employee.id,
          productId: state.products[1].id,
        ),
      );

      expect(state.assignmentsForEmployee(employee.id), hasLength(2));
      expect(
        state.employeeAllocationForProduct(employee.id, state.products[0].id),
        closeTo(70, 0.01),
      );
      expect(
        state.employeeAllocationForProduct(employee.id, state.products[1].id),
        closeTo(70, 0.01),
      );
    },
  );

  test('HR auto-hire assigns specialists and applies premium salaries', () {
    var state = _oneProduct();
    final hrId = state.candidates.singleWhere((candidate) => candidate.isHr).id;
    state = engine.reduce(state, HireCandidate(hrId));
    final beforeCandidates = <String, double>{
      for (final candidate in state.candidates) candidate.id: candidate.salary,
    };

    state = engine.reduce(state, AutoHireProjectTeam(state.products.single.id));

    final autoHires = state.employees
        .where((employee) => !employee.isHr)
        .toList(growable: false);
    expect(autoHires, isNotEmpty);
    expect(state.employeeAssignments, isNotEmpty);
    expect(
      autoHires.any(
        (employee) =>
            beforeCandidates[employee.id] != null &&
            employee.salary >= beforeCandidates[employee.id]! * 1.24,
      ),
      isTrue,
    );
  });

  test('product improvement queues hours without immediate cash charge', () {
    var state = _oneProduct();
    final product = state.products.single;
    state = state.copyWith(
      products: <Product>[
        product.copyWith(stage: ProductStage.live, developmentProgress: 1),
      ],
    );
    final cash = state.cash;

    state = engine.reduce(
      state,
      ApplyProductImprovement(
        productId: product.id,
        type: ProductImprovementType.performance,
      ),
    );

    expect(state.cash, cash);
    expect(state.activeFeatureDevelopmentFor(product.id), isNotNull);
    expect(
      state.activeFeatureDevelopmentFor(product.id)!.featureId,
      startsWith('__improvement_'),
    );
  });

  test(
    'investor request enters deterministic negotiation up to fourteen days',
    () {
      var state = _oneProduct().copyWith(paused: false);
      final product = state.products.single;
      final investor = GameCatalog.investors.firstWhere(
        (item) => item.preferredCategories.contains(product.category),
      );

      state = engine.reduce(
        state,
        RequestInvestorFunding(
          investorId: investor.id,
          productId: product.id,
          requestedAmount: 500000,
        ),
      );

      expect(state.investorOffers, hasLength(1));
      final pending = state.investorOffers.single;
      expect(pending.offeredAmount, lessThan(0));
      final decisionDays = int.parse(pending.id.split('_').last);
      expect(decisionDays, inInclusiveRange(1, 14));

      state = engine.reduce(state, AdvanceTime(decisionDays * 360 + 1));
      expect(
        state.investorOffers.isEmpty ||
            state.investorOffers.single.offeredAmount >= 0,
        isTrue,
      );
    },
  );

  test('required compute grows with website users', () {
    final state = _website();
    final product = state.products.single;
    final low = state.productComputeDemand(product.copyWith(users: 100));
    final high = state.productComputeDemand(product.copyWith(users: 100000));

    expect(high, greaterThan(low));
  });

  test('business credit is discoverable before a cash crisis', () {
    final state = engine.reduce(_oneProduct(), const RequestBusinessLoan());

    expect(state.activeLoan, isNotNull);
    expect(state.cash, greaterThan(_oneProduct().cash));
  });

  test(
    'contract remains active during grace and pays partial result after it',
    () {
      var state = _oneProduct().copyWith(paused: false);
      final template = ContractCatalog.templates.first;
      final contract = ClientContract(
        id: 'grace_test',
        templateId: template.id,
        status: ContractStatus.active,
        progress: 0.42,
        acceptedAtMinutes:
            state.simulationMinutes - template.deadlineDays * 1440,
        deadlineAtMinutes: state.simulationMinutes,
        reward: template.reward,
      );
      state = state.copyWith(clientContracts: <ClientContract>[contract]);

      final duringGrace = engine.reduce(state, const AdvanceTime(60));
      expect(duringGrace.clientContracts.single.status, ContractStatus.active);

      final afterGrace = engine.reduce(
        duringGrace,
        AdvanceTime(template.graceDays * 360 + 1),
      );
      expect(afterGrace.clientContracts.single.status, ContractStatus.failed);
      expect(
        afterGrace.financeTransactions
            .map((transaction) => transaction.description)
            .join(' | '),
        contains('Частичная выплата'),
      );
    },
  );

  test('v11 metric history survives snapshot round trip', () {
    final state = GameState.initial().copyWith(
      productMetricHistory: const <ProductMetricPoint>[
        ProductMetricPoint(
          productId: 'p',
          simulationMinutes: 1440,
          users: 10,
          dau: 3,
          mau: 8,
          revenue: 100,
          requiredCompute: 4,
          rating: 4.2,
          retention30d: 0.5,
          churnRate: 0.1,
        ),
      ],
    );
    final restored = GameState.decode(jsonEncode(state.toJson()));

    expect(restored.snapshotVersion, currentSnapshotVersion);
    expect(restored.productMetricHistory, hasLength(1));
    expect(restored.productMetricHistory.single.requiredCompute, 4);
  });
}

GameState _oneProduct() {
  const engine = GameEngine();
  return engine.reduce(
    GameState.initial().copyWith(cash: 100000000),
    const CreateConfiguredProduct(
      name: 'Workspace',
      blueprintId: 'team_saas',
      frameworkId: 'next_nest',
      languageIds: <String>['typescript'],
      technologyIds: <String>['postgresql'],
      featureIds: <String>['team_spaces'],
    ),
  );
}

GameState _twoProducts() {
  const engine = GameEngine();
  var state = _oneProduct();
  state = engine.reduce(
    state,
    const CreateConfiguredProduct(
      name: 'Workspace Two',
      blueprintId: 'team_saas',
      frameworkId: 'next_nest',
      languageIds: <String>['typescript'],
      technologyIds: <String>['postgresql'],
      featureIds: <String>['team_spaces'],
    ),
  );
  return state;
}

GameState _website() {
  const engine = GameEngine();
  return engine.reduce(
    GameState.initial().copyWith(cash: 100000000),
    const CreateConfiguredProduct(
      name: 'Founder Site',
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: <String>['html_css'],
      technologyIds: <String>[],
      featureIds: <String>['landing_page'],
      monetization: MonetizationModel.advertising,
    ),
  );
}
