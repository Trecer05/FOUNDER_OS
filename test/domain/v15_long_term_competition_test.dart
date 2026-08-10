import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/operations_models.dart';
import 'package:founder_os/domain/explainability/product_configuration_resolver.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('every category has twenty varied and beatable ranked competitors', () {
    for (final category in ProductCategory.values) {
      final competitors = GameCatalog.competitorsFor(category, 424242);
      expect(competitors, hasLength(20));
      expect(competitors.first.marketScore, 100);
      expect(
        competitors.where((item) => item.marketScore == 100),
        hasLength(1),
      );
      expect(
        competitors.map((item) => item.featureIds.length).toSet().length,
        greaterThan(1),
      );
      expect(
        competitors.skip(1).every((item) => item.marketScore < 100),
        isTrue,
      );
    }
  });

  test(
    'a rival cyberattack lowers that generated competitor in the live ranking',
    () {
      final state = GameState.initial();
      final rival = state.competitorsForCategory(ProductCategory.saas).first;
      final affected = state.copyWith(
        news: <NewsItem>[
          NewsItem(
            id: 'rival_attack_fixture',
            kind: NewsKind.security,
            title: '${rival.productName}: кибератака',
            body: 'fixture',
            simulationMinutes: state.simulationMinutes,
            critical: false,
          ),
        ],
      );
      final after = affected
          .competitorsForCategory(ProductCategory.saas)
          .firstWhere((item) => item.id == rival.id);

      expect(after.users, lessThan(rival.users));
      expect(after.marketScore, lessThan(rival.marketScore));
    },
  );

  test('Dart makes HSM available', () {
    final result = ProductConfigurationResolver.availability(
      frameworkId: 'flutter_firebase',
      languageIds: const <String>['dart'],
      selectedTechnologyIds: const <String>[],
      technology: GameCatalog.technologyById('hsm'),
    );

    expect(result.enabled, isTrue);
    expect(result.reason, isNull);
  });

  test('VPS works without DevOps at a visible 82 percent efficiency', () {
    final state = GameState.initial().copyWith(
      selectedHostingPlanId: 'vps_core',
    );
    final rawCompute = state.hostingPlan.computeUnits;

    expect(state.hasDevOps, isFalse);
    expect(state.totalComputeUnits, closeTo(rawCompute * 0.82, 0.001));
  });

  test('owned hardware combines compute memory and storage', () {
    final state = GameState.initial().copyWith(
      selectedHostingPlanId: 'owned',
      installedServers: const <InstalledServer>[
        InstalledServer(hardwareId: 'compute_m4', count: 2),
        InstalledServer(hardwareId: 'storage_r8', count: 1),
      ],
    );

    expect(state.preparedComputeUnits, 1170);
    expect(state.preparedMemoryGb, 448);
    expect(state.preparedStorageGb, 56000);
  });

  test('product names and weighted bugs survive snapshot round-trip', () {
    final source = _liveSaas(engine);
    final product = source.products.single.copyWith(
      name: 'Renamed Product',
      openBugs: const <ProductBug>[
        ProductBug(
          id: 'bug_1',
          title: 'Payment failure',
          severity: ProductBugSeverity.critical,
          openedAtMinutes: 100,
        ),
      ],
      fixedBugCount: 3,
    );
    final restored = GameState.decode(
      source.copyWith(products: <Product>[product]).encode(),
    );

    expect(restored.snapshotVersion, 13);
    expect(restored.products.single.name, 'Renamed Product');
    expect(restored.products.single.openBugs.single.weight, 7);
    expect(restored.products.single.fixedBugCount, 3);
    expect(
      restored.productBugPenalty(restored.products.single),
      greaterThan(0),
    );
  });

  test(
    'released product can be renamed and receives queued evolution work',
    () {
      var state = _liveSaas(engine);
      final product = state.products.single;
      state = engine.reduce(
        state,
        RenameProduct(productId: product.id, name: 'Second Generation'),
      );
      expect(state.products.single.name, 'Second Generation');

      final feature = GameCatalog.features.firstWhere(
        (item) =>
            item.supportedCategories.contains(product.category) &&
            !product.featureIds.contains(item.id),
      );
      state = engine.reduce(
        state,
        AddProductFeature(productId: product.id, featureId: feature.id),
      );
      expect(state.activeFeatureDevelopmentFor(product.id), isNotNull);

      final cleanQueue = state.copyWith(productFeatureDevelopments: const []);
      final technology = GameCatalog.technologyById('redis');
      final expanded = engine.reduce(
        cleanQueue,
        AddProductTechnology(
          productId: product.id,
          technologyId: technology.id,
        ),
      );
      expect(
        expanded.activeFeatureDevelopmentFor(product.id)?.featureId,
        '__technology_${technology.id}',
      );
    },
  );

  test('technical freshness ceiling falls irreversibly to zero', () {
    final base = _liveSaas(engine);
    final product = base.products.single;
    final young = base.copyWith(simulationMinutes: 180 * 1440);
    final old = base.copyWith(simulationMinutes: 800 * 1440);

    expect(young.productFreshnessCeiling(product), 100);
    expect(old.productFreshnessCeiling(product), 0);
    expect(old.productFreshnessScore(product), 0);
  });

  test('advertising produces a material paid-user forecast', () {
    final state = _liveSaas(engine);
    final product = state.products.single;
    final forecast = state.advertisingForecast(
      product: product,
      agencyId: 'signal_labs',
      channelId: 'search_ads',
      budget: 300000,
    );

    expect(forecast.usersLow, greaterThan(0));
    expect(forecast.usersHigh, greaterThan(forecast.usersLow));
  });

  test(
    'a second ready product launches even when it starts with zero allocation',
    () {
      var state = GameState.initial().copyWith(
        cash: 10000000,
        onboardingCompleted: true,
        selectedHostingPlanId: 'vps_core',
      );
      for (final name in <String>['First', 'Second']) {
        state = engine.reduce(
          state,
          CreateConfiguredProduct(
            name: name,
            blueprintId: 'team_saas',
            frameworkId: 'flutter_firebase',
            languageIds: const <String>['dart'],
            technologyIds: const <String>['postgresql'],
            featureIds: const <String>['realtime_collaboration'],
          ),
        );
      }
      state = state.copyWith(
        products: <Product>[
          state.products.first.copyWith(
            stage: ProductStage.live,
            developmentProgress: 1,
            allocatedCapacityPercent: 100,
          ),
          state.products.last.copyWith(
            developmentProgress: 1,
            allocatedCapacityPercent: 0,
          ),
        ],
      );

      state = engine.reduce(state, LaunchProduct(state.products.last.id));

      expect(state.products.last.stage, ProductStage.live);
      expect(state.products.last.allocatedCapacityPercent, 10);
      expect(state.totalAllocatedPercent, closeTo(100, 0.001));
    },
  );

  test('crunch has one boost week and one recovery week', () {
    var state = _liveSaas(engine);
    final product = state.products.single;
    final employee = state.candidates
        .firstWhere((item) => !item.isHr)
        .toEmployee();
    state = state.copyWith(
      employees: <Employee>[employee],
      employeeAssignments: <EmployeeAssignment>[
        EmployeeAssignment(
          employeeId: employee.id,
          productId: product.id,
          assignedAtMinutes: state.simulationMinutes,
        ),
      ],
    );

    state = engine.reduce(state, StartProductCrunch(product.id));
    expect(state.productCrunchMultiplier(product.id), 1.28);
    expect(state.canStartProductCrunch(product.id), isFalse);

    state = state.copyWith(
      simulationMinutes: state.simulationMinutes + 8 * 1440,
    );
    expect(state.productCrunchMultiplier(product.id), 0.78);

    state = state.copyWith(
      simulationMinutes: state.simulationMinutes + 7 * 1440,
    );
    expect(state.productCrunchMultiplier(product.id), 1);
    expect(state.canStartProductCrunch(product.id), isTrue);
  });

  test(
    'office bonus applies only to on-site staff and grows with office tier',
    () {
      final base = GameState.initial();
      final remote = base.candidates
          .firstWhere((item) => item.remote && !item.isHr)
          .toEmployee();
      final onsite = remote.managedCopyWith(remote: false);
      final garage = base.copyWith(selectedOfficeId: 'garage');
      final hq = base.copyWith(selectedOfficeId: 'hq');

      expect(garage.officeProductivityMultiplier(remote), 1);
      expect(garage.officeProductivityMultiplier(onsite), greaterThan(1));
      expect(
        hq.officeProductivityMultiplier(onsite),
        greaterThan(garage.officeProductivityMultiplier(onsite)),
      );
    },
  );

  test('monetization tuning is persisted and affects the revenue forecast', () {
    var state = _liveSaas(engine);
    final product = state.products.single;
    final before = state.revenueForecastFor(product).high;
    state = engine.reduce(
      state,
      SetProductMonetizationSettings(
        productId: product.id,
        intensity: 0.9,
        freeTierPercent: 0.05,
      ),
    );
    final tuned = state.products.single;

    expect(tuned.monetizationIntensity, 0.9);
    expect(tuned.freeTierPercent, 0.05);
    expect(state.revenueForecastFor(tuned).high, greaterThan(before));
    final restored = GameState.decode(state.encode()).products.single;
    expect(restored.monetizationIntensity, 0.9);
    expect(restored.freeTierPercent, 0.05);
  });

  test(
    'resource load follows the scarcest compute, RAM, or storage budget',
    () {
      final state = _liveSaas(
        engine,
      ).copyWith(selectedHostingPlanId: 'vps_core');
      final product = state.products.single.copyWith(
        users: 100000,
        allocatedCapacityPercent: 100,
      );
      final loaded = state.copyWith(products: <Product>[product]);
      final expected = <double>[
        loaded.productComputeDemand(product) / loaded.totalComputeUnits,
        loaded.productMemoryDemand(product) / loaded.totalMemoryGb,
        loaded.productStorageDemand(product) / loaded.totalStorageGb,
      ].reduce((left, right) => left > right ? left : right);

      expect(loaded.productResourceLoad(product), closeTo(expected, 0.0001));
    },
  );

  test(
    'training promotes grades, PM bonus scales by grade, and firing detaches staff',
    () {
      var state = _liveSaas(engine).copyWith(cash: 1000000);
      final product = state.products.single;
      final employee = const Candidate(
        id: 'pm_fixture',
        name: 'PM Fixture',
        role: EmployeeRole.productManager,
        skill: 43,
        speed: 45,
        quality: 48,
        autonomy: 45,
        communication: 55,
        reliability: 50,
        salary: 100000,
        loyalty: 80,
        remote: true,
        grade: EmployeeGrade.intern,
      ).toEmployee();
      state = state.copyWith(
        employees: <Employee>[employee],
        employeeAssignments: <EmployeeAssignment>[
          EmployeeAssignment(
            employeeId: employee.id,
            productId: product.id,
            assignedAtMinutes: state.simulationMinutes,
          ),
        ],
      );
      expect(state.productManagerBonusPercentFor(product.id), 0.04);

      state = engine.reduce(
        state,
        TrainEmployee(employeeId: employee.id, programId: 'security'),
      );
      expect(state.employeeById(employee.id)!.grade, EmployeeGrade.junior);
      expect(state.productManagerBonusPercentFor(product.id), 0.08);

      state = engine.reduce(state, FireEmployee(employee.id));
      expect(state.employeeById(employee.id), isNull);
      expect(state.assignmentsForEmployee(employee.id), isEmpty);
    },
  );
}

GameState _liveSaas(GameEngine engine) {
  var state = engine.reduce(
    GameState.initial().copyWith(cash: 10000000, onboardingCompleted: true),
    const CreateConfiguredProduct(
      name: 'Founder SaaS',
      blueprintId: 'team_saas',
      frameworkId: 'flutter_firebase',
      languageIds: <String>['dart'],
      technologyIds: <String>['postgresql'],
      featureIds: <String>['realtime_collaboration'],
      monetization: MonetizationModel.subscription,
    ),
  );
  final product = state.products.single;
  return state.copyWith(
    products: <Product>[
      product.copyWith(stage: ProductStage.live, developmentProgress: 1),
    ],
  );
}
