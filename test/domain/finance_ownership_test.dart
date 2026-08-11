import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/management_models.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/product_strategy_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

import '../support/fixtures.dart';

void main() {
  const engine = GameEngine();

  test(
    'larger business loan relative to valuation has lower approval chance',
    () {
      final state = fundedInitial().copyWith(
        products: <Product>[productFixture(monthlyRevenue: 3000000)],
      );
      final small = state.businessLoanApprovalChance(500000);
      final medium = state.businessLoanApprovalChance(5000000);
      final huge = state.businessLoanApprovalChance(25000000);
      expect(small, greaterThan(medium));
      expect(medium, greaterThan(huge));
    },
  );

  test('approved business loan issues exactly requested amount', () {
    const requested = 250000.0;
    GameState? approved;
    for (var seed = 1; seed <= 500 && approved == null; seed += 1) {
      final state = fundedInitial(
        seed: seed,
        cash: 1000000,
      ).copyWith(products: <Product>[productFixture(monthlyRevenue: 5000000)]);
      final result = engine.reduce(
        state,
        const RequestBusinessLoan(amount: requested),
      );
      if (result.activeLoan != null) {
        approved = result;
        expect(result.cash - state.cash, closeTo(requested, 0.01));
        expect(
          result.financeTransactions.first.amount,
          closeTo(requested, 0.01),
        );
      }
    }
    expect(approved, isNotNull);
  });

  test('business loan uses weekly repayment schedule', () {
    const loan = CompanyLoan(
      principal: 160000,
      remaining: 160000,
      issuedAtMinutes: 0,
      weeklyPayment: 10000,
      interestRate: 0.10,
    );
    expect(loan.repaidFraction, 0);
    expect(loan.weeklyPayment, 10000);
  });

  test('runway at two months or less creates one warning per 30 days', () {
    final employee = employeeFixture(id: 'burn', salary: 600000);
    var state = GameState.initial().copyWith(
      paused: false,
      cash: 900000,
      employees: <Employee>[employee],
    );
    expect(state.monthlyProfit, lessThan(0));
    expect(state.runwayMonths, lessThanOrEqualTo(2));
    state = engine.reduce(state, const AdvanceTime(360));
    expect(
      state.companyNotifications
          .where((item) => item.id.startsWith('runway_low_'))
          .length,
      1,
    );
    state = engine.reduce(state, const AdvanceTime(360));
    expect(
      state.companyNotifications
          .where((item) => item.id.startsWith('runway_low_'))
          .length,
      1,
    );
  });

  test('monthly P&L includes employee payroll', () {
    final base = GameState.initial();
    final withEmployee = base.copyWith(
      employees: <Employee>[employeeFixture(salary: 300000)],
    );
    expect(withEmployee.monthlyPayroll, 300000);
    expect(withEmployee.monthlyCosts, greaterThan(base.monthlyCosts));
  });

  test('investor decision is delayed instead of instant', () {
    final product = productFixture(
      id: 'funding',
      blueprintId: 'ai_assistant',
      stage: ProductStage.development,
      users: 0,
      dau: 0,
      mau: 0,
    ).copyWith(developmentProgress: 0.5);
    var state = fundedInitial(
      cash: 10000000,
    ).copyWith(paused: false, products: <Product>[product]);
    state = engine.reduce(
      state,
      const RequestInvestorFunding(
        investorId: 'inv_aurora',
        productId: 'funding',
        requestedAmount: 1000000,
      ),
    );
    expect(state.investorOffers, hasLength(1));
    expect(state.investorOffers.single.requestedAmount, 1000000);
    expect(state.investorOffers.single.offeredAmount, lessThan(0));
  });

  test('accepting deal that crosses below 50 percent loses control', () {
    const offer = InvestorOffer(
      id: 'danger_offer',
      investorId: 'inv_frontier',
      productId: 'p',
      requestedAmount: 500000,
      offeredAmount: 500000,
      equityPercent: 3,
      revenueSharePercent: 2,
      createdAtMinutes: 0,
    );
    final state = fundedInitial().copyWith(
      founderOwnershipPercent: 52,
      investorOffers: const <InvestorOffer>[offer],
    );
    final next = engine.reduce(
      state,
      const AcceptInvestorOffer('danger_offer'),
    );
    expect(next.founderOwnershipPercent, 49);
    expect(next.gameOver, isTrue);
    expect(next.criticalEvent, CriticalEventType.lostControl);
  });

  test('finance transaction categories preserve source meaning', () {
    final tx = FinanceTransaction(
      id: 'tx',
      simulationMinutes: 0,
      amount: -1000,
      category: FinanceTransactionCategory.marketing,
      description: 'Marketing',
    );
    expect(tx.category, FinanceTransactionCategory.marketing);
    expect(tx.amount, lessThan(0));
  });
}
