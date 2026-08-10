import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/candidate_market_catalog.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/catalog/product_evolution_catalog.dart';
import 'package:founder_os/domain/catalog/product_strategy_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/product_evolution_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('procedural labour market has four grades and never reuses a name', () {
    const seed = 20260804;
    final candidates = <Candidate>[
      ...CandidateMarketCatalog.initialMarket(seed: seed),
      for (var week = 1; week <= 20; week++)
        ...CandidateMarketCatalog.weeklyArrivals(seed: seed, week: week),
    ];
    final names = candidates.map((item) => item.name).toSet();

    expect(names, hasLength(candidates.length));
    expect(
      candidates.map((item) => item.grade).toSet(),
      containsAll(EmployeeGrade.values),
    );
    expect(
      candidates.map((item) => item.role).toSet(),
      containsAll(EmployeeRole.values),
    );

    final internMax = candidates
        .where((item) => item.grade == EmployeeGrade.intern)
        .map((item) => item.salary)
        .reduce((a, b) => a > b ? a : b);
    final seniorMin = candidates
        .where((item) => item.grade == EmployeeGrade.senior)
        .map((item) => item.salary)
        .reduce((a, b) => a < b ? a : b);
    expect(seniorMin, greaterThan(internMax));
    expect(candidates.first.toEmployee().grade, candidates.first.grade);
  });

  test('catalog contains 17 strategies and a deep feature roadmap', () {
    expect(GameCatalog.productBlueprints.length, greaterThanOrEqualTo(17));
    expect(GameCatalog.features.length, greaterThanOrEqualTo(95));
    expect(GameState.initial().requiredReleasedBlueprintsForLegacy, 0);

    final featureIds = GameCatalog.features.map((item) => item.id).toSet();
    expect(featureIds, hasLength(GameCatalog.features.length));
    for (final blueprint in GameCatalog.productBlueprints) {
      expect(
        () => ProductStrategyCatalog.strategyFor(blueprint.id),
        returnsNormally,
        reason: 'Missing strategy for ${blueprint.id}',
      );
      expect(
        featureIds,
        containsAll(blueprint.expectedFeatureIds),
        reason: 'Missing expected feature for ${blueprint.id}',
      );
    }
  });

  test(
    'million-ruble premium campaign has a meaningful prelaunch forecast',
    () {
      var state = GameState.initial().copyWith(cash: 5000000);
      state = engine.reduce(
        state,
        const CreateConfiguredProduct(
          name: 'Launch Site',
          blueprintId: 'company_website',
          frameworkId: 'static_web',
          languageIds: <String>['html_css'],
          technologyIds: <String>[],
          featureIds: <String>['landing_page'],
        ),
      );
      final product = state.products.single;
      final forecast = state.advertisingForecast(
        product: product,
        agencyId: 'titan_growth',
        channelId: 'search_ads',
        budget: 1000000,
      );

      expect(forecast.usersExpected, greaterThan(200));
      expect(forecast.usersHigh, greaterThan(forecast.usersLow));
      for (final channel in ProductStrategyCatalog.channels) {
        final channelForecast = state.advertisingForecast(
          product: product,
          agencyId: 'titan_growth',
          channelId: channel.id,
          budget: 1000000,
        );
        expect(channelForecast.impressions, greaterThan(0));
        expect(channelForecast.usersExpected, greaterThan(0));
      }
    },
  );

  test(
    'technical improvements are fast enough and overload navigation is free',
    () {
      final initial = GameState.initial().copyWith(
        cash: 987654,
        criticalEvent: CriticalEventType.serverOverload,
        paused: true,
      );
      for (final type in ProductImprovementType.values) {
        expect(
          initial.improvementRequiredHours('fixture', type),
          lessThan(250),
        );
        expect(
          ProductEvolutionCatalog.improvementByType(type).baseCost,
          greaterThan(0),
        );
      }

      final resolved = engine.reduce(initial, const ResolveCriticalEvent());
      expect(resolved.cash, initial.cash);
      expect(resolved.criticalEvent, CriticalEventType.none);
    },
  );

  test(
    'rival landscape is billion-scale and final acquisition is independent from campaign victory',
    () {
      final totalValuation = GameCatalog.marketCompanies.fold<double>(
        0,
        (sum, company) => sum + company.valuation,
      );
      expect(totalValuation, greaterThan(100000000000));
      expect(
        GameCatalog.marketCompanies
            .map((item) => item.users)
            .reduce((a, b) => a > b ? a : b),
        greaterThanOrEqualTo(1000000000),
      );

      final last = GameCatalog.marketCompanies.last;
      var state = GameState.initial().copyWith(cash: 1000000000000);
      for (final company in GameCatalog.marketCompanies.where(
        (item) => item.id != last.id,
      )) {
        state = engine.reduce(state, AcquireMarketCompany(company.id));
      }
      expect(state.acquiredRivalCount, GameCatalog.marketCompanies.length - 1);
      expect(
        GameState.decode(state.encode()).acquiredRivalCount,
        GameCatalog.marketCompanies.length - 1,
      );
      final legacyPayload = jsonDecode(state.encode()) as Map<String, dynamic>
        ..remove('fullyAcquiredCompanyIds');
      expect(
        GameState.decode(jsonEncode(legacyPayload)).acquiredRivalCount,
        GameCatalog.marketCompanies.length - 1,
      );
      final acquired = engine.reduce(state, AcquireMarketCompany(last.id));

      expect(acquired.acquiredRivalCount, GameCatalog.marketCompanies.length);
      expect(acquired.founderLegacyCompleted, isFalse);
    },
  );
}
