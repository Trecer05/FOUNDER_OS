import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/v12_game_state_extensions.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('fresh company has no office or infrastructure operating cost', () {
    final state = GameState.initial();

    expect(state.selectedOfficeId, 'remote_first');
    expect(state.selectedServerRoomId, 'no_server_room');
    expect(state.selectedHostingPlanId, 'no_hosting');
    expect(state.installedServers, isEmpty);
    expect(state.monthlyOfficeCost, 0);
    expect(state.monthlyServerRoomCost, 0);
    expect(state.monthlyHardwareCost, 0);
    expect(state.totalComputeUnits, 0);
    expect(state.totalNetworkGbps, 0);
    expect(state.monthlyCosts, 0);
  });

  test('simulation starts on a real deterministic calendar date', () {
    final state = GameState.initial();
    expect(state.formattedDateTime, '05.01.2026 08:00');
    expect(
      state.formatDateAt(state.simulationMinutes + 7 * 1440),
      '12.01.2026',
    );
  });

  test('founder receives ten extra distributable skill points', () {
    expect(FounderCompanyProfile.distributableSkillPoints, 22);
    expect(FounderCompanyProfile.maximumSkill, 7);
  });

  test('founder defaults remain valid after expanding the point budget', () {
    const fresh = FounderCompanyProfile.unconfigured();
    const legacy = FounderCompanyProfile.legacy();

    expect(
      fresh.skills.values.fold<int>(0, (sum, value) => sum + value),
      FounderCompanyProfile.distributableSkillPoints,
    );
    expect(legacy.hasValidSkillBudget, isTrue);
  });

  test(
    'legacy founder JSON without skills migrates to a valid 22-point profile',
    () {
      final profile = FounderCompanyProfile.fromJson(<String, Object?>{
        'configured': true,
        'companyName': 'Legacy Co',
        'founderName': 'Legacy CEO',
        'logoId': 'company_logo_01',
        'startingBudget': 450000,
        'background': 'product',
      });

      expect(profile.hasValidSkillBudget, isTrue);
      expect(
        profile.skills.values.fold<int>(0, (sum, value) => sum + value),
        22,
      );
    },
  );

  test(
    'content expansion adds products frameworks languages and candidates',
    () {
      expect(GameCatalog.productBlueprints.length, greaterThanOrEqualTo(12));
      expect(GameCatalog.frameworks.length, greaterThanOrEqualTo(13));
      expect(GameCatalog.languages.length, greaterThanOrEqualTo(16));
      expect(GameCatalog.initialCandidates.length, greaterThanOrEqualTo(30));
    },
  );

  test('fresh released product sale floor is exactly thirty percent', () {
    var state = engine.reduce(
      GameState.initial().copyWith(cash: 10000000),
      const CreateConfiguredProduct(
        name: 'Sale Floor',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>[],
        featureIds: <String>['landing_page'],
      ),
    );
    final created = state.products.single;
    final product = created.copyWith(
      stage: ProductStage.live,
      developmentProgress: 1,
      users: 0,
      dau: 0,
      mau: 0,
      monthlyRevenue: 0,
    );
    state = state.copyWith(products: <Product>[product]);
    final blueprint = GameCatalog.blueprintById(product.blueprintId);

    expect(
      state.productSaleValue(product),
      closeTo(blueprint.baseDevelopmentCost * 0.30, 0.01),
    );
    expect(state.productBuyerFor(product).category, product.category);
  });

  test('live product keeps founder capacity after release', () {
    var state = engine.reduce(
      GameState.initial().copyWith(cash: 10000000),
      const CreateConfiguredProduct(
        name: 'Live CEO',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>[],
        featureIds: <String>['landing_page'],
      ),
    );
    final product = state.products.single.copyWith(
      stage: ProductStage.live,
      developmentProgress: 1,
    );
    const profile = FounderCompanyProfile(
      configured: true,
      companyName: 'Test',
      founderName: 'Founder',
      logoId: 'company_logo_01',
      startingBudget: 450000,
      background: FounderBackground.engineer,
      skills: <FounderSkill, int>{
        FounderSkill.engineering: 5,
        FounderSkill.design: 3,
        FounderSkill.product: 4,
        FounderSkill.growth: 3,
        FounderSkill.negotiation: 3,
        FounderSkill.operations: 4,
      },
    );
    state = state.copyWith(
      companyProfile: profile,
      products: <Product>[product],
    );

    expect(state.founderDevelopmentCapacityFor(product), greaterThan(0));
    expect(state.totalDevelopmentCapacityFor(product), greaterThan(0));
  });
}
