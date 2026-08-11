import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/operations_catalog.dart';
import 'package:founder_os/domain/catalog/world_economy_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/v16_models.dart';
import 'package:founder_os/domain/entities/v17_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

import '../support/fixtures.dart';

void main() {
  const engine = GameEngine();

  test(
    'remote-first bootstrap has no office server-room or owned-site OPEX',
    () {
      final state = GameState.initial();
      expect(state.monthlyOfficeCost, 0);
      expect(state.monthlyServerRoomCost, 0);
      expect(state.ownedOfficeMonthlyCost, 0);
      expect(state.ownedDataCenterMonthlyCost, 0);
    },
  );

  test('VPS works without DevOps at 82 percent nominal compute', () {
    final state = GameState.initial().copyWith(
      selectedHostingPlanId: 'vps_core',
    );
    expect(state.hasDevOps, isFalse);
    expect(
      state.totalComputeUnits,
      closeTo(state.hostingPlan.computeUnits * 0.82, 0.001),
    );
  });

  test('server hardware is constrained by rented rack power and cooling', () {
    var state = fundedInitial();
    final rejected = engine.reduce(state, const InstallServer('cluster_x12'));
    expect(rejected.installedCount('cluster_x12'), 0);

    state = engine.reduce(state, const RentServerRoom('regional_dc'));
    state = engine.reduce(state, const InstallServer('cluster_x12'));
    expect(state.installedCount('cluster_x12'), 1);
    expect(state.infrastructureFitsRoom, isTrue);
  });

  test('servers in owned data center have concrete physical site', () {
    var state = fundedInitial(cash: 500000000);
    state = engine.reduce(
      state,
      const BuildOwnedDataCenter(
        cityId: 'helsinki',
        size: FacilitySize.small,
        facilityQuality: FacilityQuality.standard,
        equipmentQuality: FacilityQuality.standard,
      ),
    );
    final site = state.ownedDataCenters.single;
    state = engine.reduce(
      state,
      InstallServer(
        'edge_s1',
        dataCenterSiteId: site.id,
        service: InfrastructureService.appApi,
      ),
    );
    expect(state.installedServers.single.dataCenterSiteId, site.id);
    expect(state.installedServers.single.service, InfrastructureService.appApi);
    expect(state.usedRackUnitsAtDataCenter(site.id), greaterThan(0));
  });

  test(
    'owned data-center hardware does not consume rented-room rack capacity',
    () {
      var state = fundedInitial(cash: 500000000);
      state = engine.reduce(
        state,
        const BuildOwnedDataCenter(
          cityId: 'moscow',
          size: FacilitySize.small,
          facilityQuality: FacilityQuality.standard,
          equipmentQuality: FacilityQuality.standard,
        ),
      );
      final site = state.ownedDataCenters.single;
      state = engine.reduce(
        state,
        InstallServer(
          'ai_gpu_g2',
          dataCenterSiteId: site.id,
          service: InfrastructureService.aiCompute,
        ),
      );
      expect(state.usedRackUnitsAtDataCenter(site.id), greaterThan(0));
      expect(state.usedRackUnitsAtDataCenter(''), 0);
    },
  );

  test('service routes isolate product resource pools by data center', () {
    var state = liveWebsiteState(cash: 500000000);
    state = engine.reduce(
      state,
      const BuildOwnedDataCenter(
        cityId: 'helsinki',
        size: FacilitySize.small,
        facilityQuality: FacilityQuality.standard,
        equipmentQuality: FacilityQuality.standard,
      ),
    );
    state = engine.reduce(
      state,
      const BuildOwnedDataCenter(
        cityId: 'warsaw',
        size: FacilitySize.small,
        facilityQuality: FacilityQuality.standard,
        equipmentQuality: FacilityQuality.standard,
      ),
    );
    final computeSite = state.ownedDataCenters[0];
    final dataSite = state.ownedDataCenters[1];

    state = engine.reduce(
      state,
      InstallServer(
        'edge_s1',
        dataCenterSiteId: computeSite.id,
        service: InfrastructureService.appApi,
      ),
    );
    state = engine.reduce(
      state,
      InstallServer(
        'cluster_x12',
        dataCenterSiteId: dataSite.id,
        service: InfrastructureService.dataStorage,
      ),
    );
    state = state.copyWith(selectedHostingPlanId: 'owned');
    final product = state.products.single;

    state = engine.reduce(
      state,
      AssignProductInfrastructureService(
        productId: product.id,
        service: InfrastructureService.appApi,
        dataCenterSiteId: computeSite.id,
      ),
    );
    state = engine.reduce(
      state,
      AssignProductInfrastructureService(
        productId: product.id,
        service: InfrastructureService.dataStorage,
        dataCenterSiteId: dataSite.id,
      ),
    );

    expect(
      state.dataCenterRouteFor(product.id, InfrastructureService.appApi),
      computeSite.id,
    );
    expect(
      state.dataCenterRouteFor(product.id, InfrastructureService.dataStorage),
      dataSite.id,
    );
    expect(
      state.preparedComputeUnitsAtDataCenterForService(
        dataSite.id,
        InfrastructureService.appApi,
      ),
      0,
    );
    expect(
      state.preparedStorageGbAtDataCenterForService(
        computeSite.id,
        InfrastructureService.dataStorage,
      ),
      0,
    );
  });

  test('bootstrap website remains safe on shared launch', () {
    var state = liveWebsiteState().copyWith(
      selectedHostingPlanId: 'shared_launch',
    );
    final bootstrap = state.products.single.copyWith(users: 0, dau: 0, mau: 0);
    state = state.copyWith(products: [bootstrap]);

    expect(state.productServerLoad(bootstrap), lessThanOrEqualTo(1.35));
  });

  test('security controls cost money and reduce product incident risk', () {
    var state = liveWebsiteState(cash: 10000000);
    final product = state.products.single;
    final riskBefore = state.productSecurityRisk(product);
    final control = OperationsCatalog.securityControlById('secure_sdlc');
    final cashBefore = state.cash;

    state = engine.reduce(
      state,
      PurchaseSecurityControl(productId: product.id, controlId: control.id),
    );
    expect(state.securityControls, hasLength(1));
    expect(state.cash, closeTo(cashBefore - control.setupCost, 0.01));
    expect(
      state.productSecurityRisk(state.products.single),
      lessThan(riskBefore),
    );
  });

  test('security audit stores a measurable risk snapshot', () {
    var state = liveWebsiteState(cash: 10000000);
    state = engine.reduce(state, const RunSecurityAudit('website'));
    expect(state.securityAudits, hasLength(1));
    expect(state.securityAudits.single.productId, 'website');
    expect(state.securityAudits.single.riskPercent, inInclusiveRange(0, 100));
  });

  test('security incident exposes localization price before resolution', () {
    final state = liveWebsiteState(cash: 10000000);
    final next = engine.reduce(state, const TriggerSecurityIncident('website'));
    final notification = next.companyNotifications.firstWhere(
      (item) => item.id.startsWith('security_response_'),
    );
    expect(notification.body, contains('локализация стоит'));
    expect(notification.body, contains('₽'));
    expect(next.news.first.body, contains('Локализация атаки:'));
  });

  test(
    'city and facility quality materially change owned infrastructure CAPEX',
    () {
      final cheap = WorldEconomyCatalog.dataCenterBuildCost(
        cityId: 'bangalore',
        size: FacilitySize.medium,
        facility: FacilityQuality.basic,
        equipment: FacilityQuality.basic,
      );
      final expensive = WorldEconomyCatalog.dataCenterBuildCost(
        cityId: 'san_francisco',
        size: FacilitySize.medium,
        facility: FacilityQuality.premium,
        equipment: FacilityQuality.premium,
      );
      expect(expensive, greaterThan(cheap));
    },
  );
}
