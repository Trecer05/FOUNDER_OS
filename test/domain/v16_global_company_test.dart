import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/operations_catalog.dart';
import 'package:founder_os/domain/catalog/world_economy_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/operations_models.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/domain/entities/v16_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('v15 snapshot migrates to v16 geography and tax defaults', () {
    final raw =
        jsonDecode(GameState.initial().encode()) as Map<String, dynamic>;
    raw['snapshotVersion'] = 13;
    for (final key in <String>[
      'headquartersCityId',
      'ownedOffices',
      'ownedDataCenters',
      'employeeTrainings',
      'employeeGradeUpgrades',
      'taxRecords',
      'taxYearRevenueAccrued',
      'taxYearExpensesAccrued',
      'taxYearPayrollAccrued',
    ]) {
      raw.remove(key);
    }

    final restored = GameState.decode(jsonEncode(raw));

    expect(restored.snapshotVersion, 16);
    expect(restored.headquartersCityId, 'moscow');
    expect(restored.ownedOffices, isEmpty);
    expect(restored.ownedDataCenters, isEmpty);
    expect(restored.employeeTrainings, isEmpty);
    expect(restored.taxRecords, isEmpty);
  });

  test('courses take game days and do not upgrade instantly', () {
    final candidate = GameState.initial().candidates.firstWhere(
      (item) => item.remote && !item.isHr,
    );
    final employee = candidate.toEmployee().managedCopyWith(
      skill: 40,
      grade: EmployeeGrade.intern,
    );
    var state = GameState.initial().copyWith(
      cash: 10000000,
      paused: false,
      employees: <Employee>[employee],
    );
    final before = state.employeeById(employee.id)!;
    final program = OperationsCatalog.trainingProgramById('quality');

    state = engine.reduce(
      state,
      TrainEmployee(employeeId: employee.id, programId: program.id),
    );

    expect(state.trainingForEmployee(employee.id), isNotNull);
    expect(state.employeeById(employee.id)!.skill, before.skill);
    expect(
      state.trainingForEmployee(employee.id)!.completesAtMinutes,
      state.simulationMinutes + program.durationDays * 1440,
    );

    state = engine.reduce(state, AdvanceTime(program.durationDays * 360 - 1));
    expect(state.trainingForEmployee(employee.id), isNotNull);

    state = engine.reduce(state, const AdvanceTime(1));
    expect(state.trainingForEmployee(employee.id), isNull);
    expect(state.employeeById(employee.id)!.skill, greaterThan(before.skill));
  });

  test(
    'active product development grows employee skill and grade follows skill',
    () {
      var state = GameState.initial().copyWith(cash: 10000000, paused: false);
      state = engine.reduce(
        state,
        const CreateConfiguredProduct(
          name: 'Skill Lab',
          blueprintId: 'team_saas',
          frameworkId: 'flutter_firebase',
          languageIds: <String>['dart'],
          technologyIds: <String>['postgresql'],
          featureIds: <String>['realtime_collaboration'],
        ),
      );
      final product = state.products.single;
      final candidate = state.candidates.firstWhere(
        (item) => item.remote && !item.isHr,
      );
      state = state.copyWith(
        employees: <Employee>[
          candidate.toEmployee().managedCopyWith(
            skill: 43,
            grade: EmployeeGrade.intern,
          ),
        ],
        candidates: state.candidates
            .where((item) => item.id != candidate.id)
            .toList(growable: false),
      );
      state = engine.reduce(
        state,
        AssignEmployeeToProduct(
          employeeId: candidate.id,
          productId: product.id,
        ),
      );
      final before = state.employeeById(candidate.id)!;

      state = engine.reduce(state, const AdvanceTime(3 * 360));

      final after = state.employeeById(candidate.id)!;
      expect(after.skill, greaterThan(before.skill));
      expect(after.grade, employeeGradeForSkill(after.skill));
    },
  );

  test('bulk training and target-grade upgrade queue selected employees', () {
    final candidates = GameState.initial().candidates
        .where((item) => item.remote && !item.isHr)
        .take(2)
        .toList(growable: false);
    final employees = candidates
        .map(
          (item) => item.toEmployee().managedCopyWith(
            skill: 40,
            grade: EmployeeGrade.intern,
          ),
        )
        .toList(growable: false);
    var state = GameState.initial().copyWith(
      cash: 20000000,
      paused: false,
      employees: employees,
    );

    state = engine.reduce(
      state,
      TrainEmployees(
        employeeIds: employees.map((item) => item.id).toList(),
        programId: 'architecture',
      ),
    );
    expect(state.employeeTrainings, hasLength(2));

    state = engine.reduce(state, const AdvanceTime(3 * 360));
    expect(state.employeeTrainings, isEmpty);

    state = engine.reduce(
      state,
      UpgradeEmployeesToGrade(
        employeeIds: employees.map((item) => item.id).toList(),
        targetGrade: EmployeeGrade.senior,
      ),
    );
    expect(state.employeeGradeUpgrades, isNotEmpty);
    expect(
      state.employeeById(employees.first.id)!.grade,
      isNot(EmployeeGrade.senior),
    );

    state = engine.reduce(state, const AdvanceTime(13 * 360));
    expect(state.employeeGradeUpgrades, isEmpty);
    expect(
      state.employees.every(
        (employee) => employee.grade == EmployeeGrade.senior,
      ),
      isTrue,
    );
  });

  test('company geography changes taxes and hiring cost', () {
    GameState configured(String cityId) => engine.reduce(
      GameState.initial(),
      ConfigureCompany(
        companyName: 'Geo Labs',
        founderName: 'Alex',
        logoId: 'company_logo_01',
        startingBudget: 1200000,
        background: FounderBackground.engineer,
        skills: _founderSkills,
        headquartersCityId: cityId,
      ),
    );

    final moscow = configured('moscow');
    final sf = configured('san_francisco');
    expect(
      sf.effectiveCorporateTaxRate,
      greaterThan(moscow.effectiveCorporateTaxRate),
    );
    expect(
      WorldEconomyCatalog.cityById('san_francisco').talentScore,
      greaterThan(WorldEconomyCatalog.cityById('moscow').talentScore),
    );

    final candidateId = moscow.candidates
        .firstWhere((item) => item.remote && !item.isHr)
        .id;
    final hiredMoscow = engine.reduce(moscow, HireCandidate(candidateId));
    final hiredSf = engine.reduce(sf, HireCandidate(candidateId));
    expect(
      hiredSf.employeeById(candidateId)!.salary,
      greaterThan(hiredMoscow.employeeById(candidateId)!.salary),
    );
  });

  test('multiple owned offices and data centers persist with real capex', () {
    var state = engine.reduce(
      GameState.initial(),
      ConfigureCompany(
        companyName: 'Global Labs',
        founderName: 'Alex',
        logoId: 'company_logo_01',
        startingBudget: 1200000,
        background: FounderBackground.operations,
        skills: _founderSkills,
        headquartersCityId: 'dubai',
      ),
    );
    state = state.copyWith(cash: 500000000);
    final cashBefore = state.cash;

    state = engine.reduce(
      state,
      const BuildOwnedOffice(
        cityId: 'dubai',
        size: FacilitySize.medium,
        fitoutQuality: FacilityQuality.standard,
        equipmentQuality: FacilityQuality.premium,
      ),
    );
    state = engine.reduce(
      state,
      const BuildOwnedOffice(
        cityId: 'warsaw',
        size: FacilitySize.small,
        fitoutQuality: FacilityQuality.basic,
        equipmentQuality: FacilityQuality.standard,
      ),
    );
    state = engine.reduce(
      state,
      const BuildOwnedDataCenter(
        cityId: 'helsinki',
        size: FacilitySize.medium,
        facilityQuality: FacilityQuality.premium,
        equipmentQuality: FacilityQuality.premium,
      ),
    );

    expect(state.ownedOffices, hasLength(2));
    expect(state.ownedDataCenters, hasLength(1));
    expect(state.cash, lessThan(cashBefore));
    expect(state.ownedOfficeMonthlyCost, greaterThan(0));
    expect(state.ownedDataCenterMonthlyCost, greaterThan(0));

    final restored = GameState.decode(state.encode());
    expect(restored.snapshotVersion, 16);
    expect(restored.headquartersCityId, 'dubai');
    expect(restored.ownedOffices, hasLength(2));
    expect(restored.ownedDataCenters, hasLength(1));
  });

  test('servers are placed in a concrete data center', () {
    var state = GameState.initial().copyWith(cash: 500000000);
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
      InstallServer('edge_s1', dataCenterSiteId: site.id),
    );

    expect(state.installedCount('edge_s1'), 1);
    expect(state.installedServers.single.dataCenterSiteId, site.id);
    expect(state.usedRackUnitsAtDataCenter(site.id), greaterThan(0));

    state = engine.reduce(
      state,
      RemoveServer('edge_s1', dataCenterSiteId: site.id),
    );
    expect(state.installedCount('edge_s1'), 0);
  });

  test(
    'owned data-center servers do not consume rented server-room capacity',
    () {
      var state = GameState.initial().copyWith(cash: 100000000);
      state = engine.reduce(
        state,
        const BuildOwnedDataCenter(
          cityId: 'moscow',
          size: FacilitySize.small,
          facilityQuality: FacilityQuality.standard,
          equipmentQuality: FacilityQuality.standard,
        ),
      );
      final siteId = state.ownedDataCenters.single.id;
      state = engine.reduce(
        state,
        InstallServer('ai_gpu_g2', dataCenterSiteId: siteId),
      );
      state = engine.reduce(
        state,
        InstallServer('ai_gpu_g2', dataCenterSiteId: siteId),
      );

      expect(state.usedRackUnitsAtDataCenter(siteId), 12);
      expect(state.usedRackUnitsAtDataCenter(''), 0);

      state = engine.reduce(state, const RentServerRoom('closet'));

      expect(state.selectedServerRoomId, 'closet');
    },
  );

  test(
    'global city balance keeps start free and creates material tradeoffs',
    () {
      final initial = GameState.initial();
      expect(initial.monthlyOfficeCost, 0);
      expect(initial.monthlyServerRoomCost, 0);

      final moscow = WorldEconomyCatalog.cityById('moscow');
      final dubai = WorldEconomyCatalog.cityById('dubai');
      final berlin = WorldEconomyCatalog.cityById('berlin');
      final sanFrancisco = WorldEconomyCatalog.cityById('san_francisco');
      final bangalore = WorldEconomyCatalog.cityById('bangalore');

      expect(
        sanFrancisco.salaryMultiplier,
        greaterThan(moscow.salaryMultiplier),
      );
      expect(bangalore.salaryMultiplier, lessThan(moscow.salaryMultiplier));
      expect(dubai.corporateTaxRate, lessThan(berlin.corporateTaxRate));
      expect(
        WorldEconomyCatalog.officeBuildCost(
          cityId: 'san_francisco',
          size: FacilitySize.medium,
          fitout: FacilityQuality.standard,
          equipment: FacilityQuality.standard,
        ),
        greaterThan(
          WorldEconomyCatalog.officeBuildCost(
            cityId: 'bangalore',
            size: FacilitySize.medium,
            fitout: FacilityQuality.standard,
            equipment: FacilityQuality.standard,
          ),
        ),
      );
    },
  );

  test('HQ rent and regulation create recurring city tradeoffs', () {
    GameState configured(String cityId) => engine.reduce(
      GameState.initial(),
      ConfigureCompany(
        companyName: 'Policy Labs',
        founderName: 'Alex',
        logoId: 'company_logo_01',
        startingBudget: 1200000,
        background: FounderBackground.operations,
        skills: _founderSkills,
        headquartersCityId: cityId,
      ),
    );

    final moscowOffice = configured(
      'moscow',
    ).copyWith(selectedOfficeId: 'garage');
    final sanFranciscoOffice = configured(
      'san_francisco',
    ).copyWith(selectedOfficeId: 'garage');
    expect(
      sanFranciscoOffice.monthlyOfficeCost,
      greaterThan(moscowOffice.monthlyOfficeCost),
    );

    var moscow = configured('moscow').copyWith(cash: 10000000);
    moscow = engine.reduce(
      moscow,
      const CreateConfiguredProduct(
        name: 'Compliance',
        blueprintId: 'team_saas',
        frameworkId: 'flutter_firebase',
        languageIds: <String>['dart'],
        technologyIds: <String>['postgresql'],
        featureIds: <String>['realtime_collaboration'],
      ),
    );
    final liveProduct = moscow.products.single.copyWith(
      stage: ProductStage.live,
      developmentProgress: 1,
    );
    moscow = moscow.copyWith(products: <Product>[liveProduct]);
    final singapore = configured(
      'singapore',
    ).copyWith(products: <Product>[liveProduct]);

    expect(moscow.monthlyRegulatoryComplianceCost, greaterThan(0));
    expect(
      singapore.monthlyRegulatoryComplianceCost,
      lessThan(moscow.monthlyRegulatoryComplianceCost),
    );
  });

  test('balance pressure escalates from bootstrap to global scale', () {
    final bootstrap = engine.reduce(
      GameState.initial(),
      ConfigureCompany(
        companyName: 'Bootstrap',
        founderName: 'Alex',
        logoId: 'company_logo_01',
        startingBudget: 450000,
        background: FounderBackground.operations,
        skills: _founderSkills,
        headquartersCityId: 'moscow',
      ),
    );
    expect(bootstrap.monthlyOfficeCost, 0);
    expect(bootstrap.monthlyServerRoomCost, 0);
    expect(bootstrap.monthlyRegulatoryComplianceCost, 0);

    final starterOffice = WorldEconomyCatalog.officeBuildCost(
      cityId: 'moscow',
      size: FacilitySize.small,
      fitout: FacilityQuality.basic,
      equipment: FacilityQuality.basic,
    );
    final starterDc = WorldEconomyCatalog.dataCenterBuildCost(
      cityId: 'moscow',
      size: FacilitySize.small,
      facility: FacilityQuality.basic,
      equipment: FacilityQuality.basic,
    );
    expect(starterOffice, greaterThan(bootstrap.cash));
    expect(starterDc, greaterThan(starterOffice));

    final warsawOffice = OwnedOfficeSite(
      id: 'office_warsaw_balance',
      cityId: 'warsaw',
      size: FacilitySize.medium,
      fitoutQuality: FacilityQuality.standard,
      equipmentQuality: FacilityQuality.standard,
      builtAtMinutes: 0,
    );
    final singaporeDc = OwnedDataCenterSite(
      id: 'dc_singapore_balance',
      cityId: 'singapore',
      size: FacilitySize.medium,
      facilityQuality: FacilityQuality.standard,
      equipmentQuality: FacilityQuality.standard,
      builtAtMinutes: 0,
    );
    final scaled = bootstrap.copyWith(
      cash: 100000000,
      ownedOffices: <OwnedOfficeSite>[warsawOffice],
      ownedDataCenters: <OwnedDataCenterSite>[singaporeDc],
    );
    expect(scaled.monthlyOfficeCost, greaterThan(0));
    expect(scaled.monthlyServerRoomCost, greaterThan(0));
    expect(
      scaled.monthlyOfficeCost + scaled.monthlyServerRoomCost,
      greaterThan(bootstrap.monthlyCosts),
    );
    expect(
      WorldEconomyCatalog.cityById('san_francisco').salaryMultiplier /
          WorldEconomyCatalog.cityById('bangalore').salaryMultiplier,
      greaterThan(3),
    );
  });

  test('premium owned office improves only on-site work in its city', () {
    final candidate = GameState.initial().candidates.firstWhere(
      (item) => !item.isHr,
    );
    final onSite = candidate.toEmployee().managedCopyWith(
      remote: false,
      locationCityId: 'warsaw',
    );
    final remote = candidate.toEmployee().managedCopyWith(
      remote: true,
      locationCityId: 'warsaw',
    );
    final office = OwnedOfficeSite(
      id: 'office_test',
      cityId: 'warsaw',
      size: FacilitySize.small,
      fitoutQuality: FacilityQuality.premium,
      equipmentQuality: FacilityQuality.premium,
      builtAtMinutes: 0,
    );
    final state = GameState.initial().copyWith(
      employees: <Employee>[onSite],
      ownedOffices: <OwnedOfficeSite>[office],
    );

    expect(state.officeProductivityMultiplier(onSite), greaterThan(1));
    expect(state.officeProductivityMultiplier(remote), 1);
  });

  test('annual taxes charge profit and payroll once per game year', () {
    var state = engine.reduce(
      GameState.initial(),
      ConfigureCompany(
        companyName: 'Tax Labs',
        founderName: 'Alex',
        logoId: 'company_logo_01',
        startingBudget: 1200000,
        background: FounderBackground.engineer,
        skills: _founderSkills,
        headquartersCityId: 'dubai',
      ),
    );
    state = state.copyWith(
      cash: 10000000,
      paused: false,
      simulationMinutes: 364 * 1440,
      taxYearRevenueAccrued: 5000000,
      taxYearExpensesAccrued: 2000000,
      taxYearPayrollAccrued: 1000000,
    );
    final cashBefore = state.cash;

    state = engine.reduce(state, const AdvanceTime(2 * 360));

    expect(state.taxRecords, hasLength(1));
    expect(state.taxRecords.single.corporateTax, greaterThan(0));
    expect(state.taxRecords.single.payrollTax, greaterThan(0));
    expect(state.cash, lessThan(cashBefore));
    expect(state.taxYearRevenueAccrued, 0);
  });

  test('all open product bugs can be queued as one technical batch', () {
    var state = engine.reduce(
      GameState.initial().copyWith(cash: 10000000),
      const CreateConfiguredProduct(
        name: 'Buggy',
        blueprintId: 'team_saas',
        frameworkId: 'flutter_firebase',
        languageIds: <String>['dart'],
        technologyIds: <String>['postgresql'],
        featureIds: <String>['realtime_collaboration'],
      ),
    );
    final product = state.products.single.copyWith(
      stage: ProductStage.live,
      developmentProgress: 1,
      openBugs: const <ProductBug>[
        ProductBug(
          id: 'v16_bug_1',
          title: 'Crash',
          severity: ProductBugSeverity.major,
          openedAtMinutes: 0,
        ),
        ProductBug(
          id: 'v16_bug_2',
          title: 'Broken flow',
          severity: ProductBugSeverity.minor,
          openedAtMinutes: 0,
        ),
      ],
    );
    state = state.copyWith(products: <Product>[product]);

    state = engine.reduce(state, FixAllProductBugs(product.id));

    expect(state.activeFeatureDevelopmentFor(product.id), isNotNull);
    expect(
      state.activeFeatureDevelopmentFor(product.id)!.featureId,
      '__bug_all__',
    );
    expect(
      state.activeFeatureDevelopmentFor(product.id)!.requiredHours,
      greaterThan(0),
    );
  });
}

const Map<FounderSkill, int> _founderSkills = <FounderSkill, int>{
  FounderSkill.engineering: 4,
  FounderSkill.design: 3,
  FounderSkill.product: 5,
  FounderSkill.growth: 3,
  FounderSkill.negotiation: 3,
  FounderSkill.operations: 4,
};
