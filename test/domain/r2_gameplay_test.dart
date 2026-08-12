import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/catalog/product_strategy_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/operations_models.dart';
import 'package:founder_os/domain/entities/r2_gameplay_extensions.dart';
import 'package:founder_os/domain/entities/v17_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

import '../support/fixtures.dart';

void main() {
  const engine = GameEngine();

  test('website can start empty but unresearched features are rejected', () {
    var state = fundedInitial();
    state = engine.reduce(
      state,
      const CreateConfiguredProduct(
        name: 'Empty Website',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>[],
        featureIds: <String>[],
      ),
    );
    expect(state.products, hasLength(1));
    expect(state.products.single.featureIds, isEmpty);

    final blocked = engine.reduce(
      fundedInitial(),
      const CreateConfiguredProduct(
        name: 'Free Feature Website',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>[],
        featureIds: <String>['contact_form'],
      ),
    );
    expect(blocked.products, isEmpty);
    expect(blocked.feed.first, contains('исследовать'));
  });

  test('investor-required product exists but waits before development', () {
    final strategy = ProductStrategyCatalog.products.firstWhere(
      (item) => item.requiredInvestorCount > 0,
    );
    final product = productFixture(
      id: 'funding_wait',
      blueprintId: strategy.blueprintId,
      name: 'Funding Wait',
      stage: ProductStage.development,
      featureIds: const <String>[],
    ).copyWith(developmentProgress: 0.25);
    final employee = employeeFixture(
      id: 'builder',
      role: EmployeeRole.backend,
      languageIds: product.languageIds,
    );
    var state = fundedInitial().copyWith(
      products: <Product>[product],
      employees: <Employee>[employee],
      employeeAssignments: <EmployeeAssignment>[
        EmployeeAssignment(
          employeeId: employee.id,
          productId: product.id,
          assignedAtMinutes: 0,
        ),
      ],
    );
    expect(state.productMissingInvestorCount(product), greaterThan(0));
    expect(state.productDevelopmentCapacity(product.id), 0);

    final agreements = List<InvestorAgreement>.generate(
      strategy.requiredInvestorCount,
      (index) => InvestorAgreement(
        id: 'agreement_$index',
        investorId: 'investor_$index',
        productId: product.id,
        investedAmount: 1000000,
        equityPercent: 1,
        revenueSharePercent: 0,
        buybackPrice: 1300000,
      ),
    );
    state = state.copyWith(investorAgreements: agreements);
    expect(state.productFundingReady(product), isTrue);
    expect(state.productDevelopmentCapacity(product.id), greaterThan(0));
  });

  test('missing project language keeps specialist at fifty percent fit', () {
    final product = productFixture(
      id: 'language_product',
      stage: ProductStage.development,
      featureIds: const <String>[],
    ).copyWith(developmentProgress: 0.45);
    final matching = employeeFixture(
      id: 'matching',
      role: EmployeeRole.backend,
      languageIds: product.languageIds,
    );
    final missing = employeeFixture(
      id: 'missing',
      role: EmployeeRole.backend,
      languageIds: const <String>['dart'],
    );
    final state = fundedInitial().copyWith(products: <Product>[product]);
    expect(state.employeeLanguageFitForProduct(matching, product), 1);
    expect(state.employeeLanguageFitForProduct(missing, product), 0.5);
  });

  test('one undersized team remains productive instead of collapsing', () {
    final strategy = ProductStrategyCatalog.products.firstWhere(
      (item) => item.minimumTeamSize >= 2 && item.requiredInvestorCount == 0,
    );
    final product = productFixture(
      id: 'small_team',
      blueprintId: strategy.blueprintId,
      stage: ProductStage.development,
      featureIds: const <String>[],
    );
    final employee = employeeFixture(
      id: 'only_one',
      role: EmployeeRole.backend,
      languageIds: product.languageIds,
    );
    final state = fundedInitial().copyWith(
      products: <Product>[product],
      employees: <Employee>[employee],
      employeeAssignments: <EmployeeAssignment>[
        EmployeeAssignment(
          employeeId: employee.id,
          productId: product.id,
          assignedAtMinutes: 0,
        ),
      ],
    );
    final staffing = state.developmentStaffingFor(product.id);
    expect(staffing.efficiency, greaterThanOrEqualTo(0.42));
    expect(state.productDevelopmentCapacity(product.id), greaterThan(0));
  });

  test(
    'free tier improves subscription satisfaction and retention experience',
    () {
      final base = productFixture(
        id: 'paywall',
        blueprintId: 'team_saas',
        monetization: MonetizationModel.subscription,
        intensity: 0.8,
        freeTierPercent: 0,
      );
      final generous = base.copyWith(freeTierPercent: 0.8);
      final state = fundedInitial().copyWith(products: <Product>[base]);
      expect(
        state.productUserSatisfaction(generous),
        greaterThan(state.productUserSatisfaction(base)),
      );
      expect(
        state.monetizationExperienceImpact(generous).retentionDelta,
        greaterThan(state.monetizationExperienceImpact(base).retentionDelta),
      );
    },
  );

  test('rejected business loan creates seven day retry cooldown', () {
    final rejected = engine.reduce(
      fundedInitial(),
      const RequestBusinessLoan(amount: 50000),
    );
    expect(rejected.businessLoanRetryRemainingDays, 7);

    final second = engine.reduce(
      rejected,
      const RequestBusinessLoan(amount: 50000),
    );
    expect(second.feed.first, contains('повторную заявку'));
    expect(second.cash, rejected.cash);
  });

  test('product services can use independent dedicated hosting routes', () {
    var state = liveWebsiteState(cash: 100000000);
    state = engine.reduce(
      state,
      const AssignProductInfrastructureService(
        productId: 'website',
        service: InfrastructureService.appApi,
        dataCenterSiteId: 'hosting:shared_launch',
      ),
    );
    state = engine.reduce(
      state,
      const AssignProductInfrastructureService(
        productId: 'website',
        service: InfrastructureService.dataStorage,
        dataCenterSiteId: 'hosting:object_storage',
      ),
    );
    final api = state.dataCenterRouteFor(
      'website',
      InfrastructureService.appApi,
    );
    final storage = state.dataCenterRouteFor(
      'website',
      InfrastructureService.dataStorage,
    );
    expect(api, startsWith('hosting:shared_launch:website:appApi'));
    expect(storage, startsWith('hosting:object_storage:website:dataStorage'));
    expect(
      state.routedHostingFor('website', InfrastructureService.appApi)!.id,
      'shared_launch',
    );
    expect(
      state.routedHostingFor('website', InfrastructureService.dataStorage)!.id,
      'object_storage',
    );
  });

  test('selling website never changes surviving AI product name', () {
    final website = productFixture(
      id: 'website',
      blueprintId: 'company_website',
      name: 'Sold Website',
    );
    final ai = productFixture(
      id: 'ai',
      blueprintId: 'ai_assistant',
      name: 'AURA Intelligence',
      featureIds: const <String>[],
    );
    var state = fundedInitial().copyWith(products: <Product>[website, ai]);
    state = engine.reduce(state, const SellProduct('website'));
    expect(state.productById('website'), isNull);
    expect(state.productById('ai')!.name, 'AURA Intelligence');
  });

  test('DevOps product exposes dedicated server setup workstream', () {
    final blueprint = GameCatalog.productBlueprints.firstWhere((candidate) {
      final product = productFixture(
        id: 'probe',
        blueprintId: candidate.id,
        stage: ProductStage.development,
        featureIds: const <String>[],
      );
      return fundedInitial()
          .roleRequirementsFor(product)
          .any(
            (item) => item.role == EmployeeRole.devOps && item.minimumCount > 0,
          );
    });
    final product = productFixture(
      id: 'devops',
      blueprintId: blueprint.id,
      stage: ProductStage.development,
      featureIds: const <String>[],
    ).copyWith(developmentProgress: 0.66);
    final state = fundedInitial().copyWith(products: <Product>[product]);
    expect(
      state.r2DevelopmentWorkstreamFor(product).workstream,
      R2DevelopmentWorkstream.serverSetup,
    );
  });

  test('notification read/delete/clear actions are explicit', () {
    const first = CompanyNotification(
      id: 'first',
      kind: CompanyNotificationKind.contract,
      title: 'Contract',
      body: 'Done',
      simulationMinutes: 1,
      read: false,
    );
    const second = CompanyNotification(
      id: 'second',
      kind: CompanyNotificationKind.development,
      title: 'Feature',
      body: 'Done',
      simulationMinutes: 2,
      read: false,
    );
    var state = fundedInitial().copyWith(
      companyNotifications: const <CompanyNotification>[first, second],
    );
    state = engine.reduce(state, const MarkCompanyNotificationRead('first'));
    expect(state.companyNotifications.first.read, isTrue);
    expect(state.companyNotifications.last.read, isFalse);
    state = engine.reduce(state, const DeleteCompanyNotification('first'));
    expect(state.companyNotifications.map((item) => item.id), ['second']);
    state = engine.reduce(state, const ClearCompanyNotifications());
    expect(state.companyNotifications, isEmpty);
  });

  test('launch emits one development completion notification', () {
    final product = productFixture(
      id: 'launch_r2',
      stage: ProductStage.development,
      featureIds: const <String>[],
    ).copyWith(developmentProgress: 1);
    final state = fundedInitial().copyWith(
      selectedHostingPlanId: 'shared_launch',
      products: <Product>[product],
    );
    final launched = engine.reduce(state, const LaunchProduct('launch_r2'));
    expect(
      launched.companyNotifications.where(
        (item) => item.kind == CompanyNotificationKind.development,
      ),
      hasLength(1),
    );
  });
}
