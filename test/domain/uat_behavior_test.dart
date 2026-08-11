import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/candidate_market_catalog.dart';
import 'package:founder_os/domain/catalog/contract_catalog.dart';
import 'package:founder_os/domain/catalog/feature_impact_catalog.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/business_models.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/product_strategy_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  test('female Russian surnames use the feminine form', () {
    expect(CandidateMarketCatalog.surnameForFirstName('Анна', 'Юдин'), 'Юдина');
    expect(
      CandidateMarketCatalog.surnameForFirstName('Мария', 'Воробьёв'),
      'Воробьёва',
    );
    expect(
      CandidateMarketCatalog.surnameForFirstName('Елена', 'Сафин'),
      'Сафина',
    );
    expect(CandidateMarketCatalog.surnameForFirstName('Анна', 'Ким'), 'Ким');
    expect(
      CandidateMarketCatalog.surnameForFirstName('Анна', 'Руденко'),
      'Руденко',
    );
  });

  test('weekly contract market rotates and scales with completed work', () {
    final firstWeek = ContractCatalog.weeklyOffers(
      seed: 20260804,
      week: 1,
      completedCount: 0,
    );
    final nextWeek = ContractCatalog.weeklyOffers(
      seed: 20260804,
      week: 2,
      completedCount: 0,
    );
    final mature = ContractCatalog.weeklyOffers(
      seed: 20260804,
      week: 10,
      completedCount: 18,
    );

    expect(
      firstWeek.map((item) => item.id).toList(),
      isNot(equals(nextWeek.map((item) => item.id).toList())),
    );

    double averageReward(List<ContractTemplate> items) =>
        items.fold<double>(0, (sum, item) => sum + item.reward) / items.length;
    double averageHours(List<ContractTemplate> items) =>
        items.fold<double>(0, (sum, item) => sum + item.developmentHours) /
        items.length;

    expect(averageReward(mature), greaterThan(averageReward(firstWeek)));
    expect(averageHours(mature), greaterThan(averageHours(firstWeek)));
    expect(ContractCatalog.byId(mature.first.id).id, mature.first.id);
  });

  test('early loan payoff removes future scheduled interest', () {
    const engine = GameEngine();
    final loan = CompanyLoan(
      principal: 275000,
      remaining: 275000,
      issuedAtMinutes: 0,
      weeklyPayment: 17187.5,
      interestRate: 0.10,
    );
    final state = GameState.initial().copyWith(cash: 500000, activeLoan: loan);
    final payoff = loan.earlyPayoffAmountAt(state.simulationMinutes);
    final savings = loan.earlyPayoffSavingsAt(state.simulationMinutes);
    expect(payoff, lessThan(loan.remaining));
    expect(savings, greaterThan(0));

    final next = engine.reduce(state, const RepayBusinessLoanEarly());
    expect(next.activeLoan, isNull);
    expect(next.cash, closeTo(state.cash - payoff, 0.01));
    expect(
      next.financeTransactions.last.description,
      contains('Досрочное погашение'),
    );
  });

  test('feature fit creates demand only where the feature belongs', () {
    final primary = GameCatalog.productBlueprints.firstWhere(
      (item) => item.expectedFeatureIds.isNotEmpty,
    );
    final feature = GameCatalog.featureById(primary.expectedFeatureIds.first);
    final unrelated = GameCatalog.productBlueprints.firstWhere(
      (item) =>
          !feature.supportedCategories.contains(item.category) &&
          !item.expectedFeatureIds.contains(feature.id),
    );

    expect(FeatureImpactCatalog.featureMark(primary, feature), '++');
    expect(FeatureImpactCatalog.fitWeight(primary, feature), 1);
    expect(FeatureImpactCatalog.featureMark(unrelated, feature), '-');
    expect(FeatureImpactCatalog.fitWeight(unrelated, feature), lessThan(0.2));
  });
}
