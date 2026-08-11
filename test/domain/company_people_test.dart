import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/v17_endgame_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/domain/entities/v16_models.dart';
import 'package:founder_os/domain/entities/v17_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

import '../support/fixtures.dart';

void main() {
  const engine = GameEngine();

  test(
    'valid company configuration persists founder city budget and skills',
    () {
      final state = configuredCompany(
        engine,
        cityId: 'dubai',
        budget: 1200000,
        background: FounderBackground.operations,
      );
      expect(state.companyProfile.configured, isTrue);
      expect(state.companyProfile.companyName, 'Current Labs');
      expect(state.headquartersCityId, 'dubai');
      expect(state.cash, 1200000);
      expect(state.companyProfile.hasValidSkillBudget, isTrue);
      expect(state.selectedOfficeId, 'remote_first');
    },
  );

  test('invalid founder skill budget is rejected without mutating company', () {
    final invalid = <FounderSkill, int>{...founderSkills};
    invalid[FounderSkill.product] = 4;
    final next = engine.reduce(
      GameState.initial(),
      ConfigureCompany(
        companyName: 'Broken',
        founderName: 'CEO',
        logoId: 'company_logo_01',
        startingBudget: 450000,
        background: FounderBackground.product,
        skills: invalid,
        headquartersCityId: 'moscow',
      ),
    );
    expect(next.companyProfile.configured, isFalse);
    expect(next.feed.first, contains('22 очка'));
  });

  test('founder background and skills change real operating multipliers', () {
    final profile = const FounderCompanyProfile(
      configured: true,
      companyName: 'Profile',
      founderName: 'CEO',
      logoId: 'company_logo_01',
      startingBudget: 450000,
      background: FounderBackground.operations,
      skills: founderSkills,
    );
    expect(profile.employeeSalaryMultiplier, lessThan(1));
    expect(profile.officeRentMultiplier, lessThan(1));
    expect(profile.productSetupCostMultiplier, lessThan(1));
    expect(profile.improvementHoursMultiplier, lessThan(1));
    expect(profile.growthEfficiencyMultiplier, greaterThan(1));
  });

  test('on-site hiring respects numeric office capacity', () {
    var state = fundedInitial().copyWith(selectedOfficeId: 'garage');
    final onSite = state.candidates
        .where((item) => !item.remote)
        .take(4)
        .toList();
    expect(onSite, hasLength(4));
    for (final candidate in onSite.take(3)) {
      state = engine.reduce(state, HireCandidate(candidate.id));
    }
    final blocked = engine.reduce(state, HireCandidate(onSite.last.id));
    expect(state.onSiteEmployeeCount, 3);
    expect(blocked.onSiteEmployeeCount, 3);
    expect(blocked.candidateById(onSite.last.id), isNotNull);
  });

  test('employee course actions are disabled in favor of grades', () {
    final employee = employeeFixture(
      id: 'trainee',
      skill: 40,
      grade: EmployeeGrade.intern,
    );
    final state = fundedInitial().copyWith(
      paused: false,
      employees: <Employee>[employee],
    );
    final next = engine.reduce(
      state,
      TrainEmployee(employeeId: employee.id, programId: 'quality'),
    );
    expect(next.trainingForEmployee(employee.id), isNull);
    expect(next.employeeById(employee.id)!.skill, 40);
    expect(next.cash, state.cash);
  });

  test('bulk course actions are disabled in favor of grade upgrades', () {
    final first = employeeFixture(
      id: 'first',
      skill: 50,
      grade: EmployeeGrade.junior,
    );
    final second = employeeFixture(
      id: 'second',
      skill: 65,
      grade: EmployeeGrade.middle,
    );
    final state = fundedInitial().copyWith(
      employees: <Employee>[first, second],
    );
    final next = engine.reduce(
      state,
      TrainEmployees(
        employeeIds: <String>[first.id, second.id],
        programId: 'security',
      ),
    );
    expect(next.employeeTrainings, isEmpty);
    expect(next.cash, state.cash);
  });

  test('grade upgrade is a paid timed plan rather than instant mutation', () {
    final employee = employeeFixture(
      id: 'upgrade',
      skill: 40,
      grade: EmployeeGrade.intern,
      salary: 100000,
    );
    var state = fundedInitial().copyWith(
      paused: false,
      employees: <Employee>[employee],
    );
    state = engine.reduce(
      state,
      UpgradeEmployeesToGrade(
        employeeIds: <String>[employee.id],
        targetGrade: EmployeeGrade.senior,
      ),
    );
    expect(state.gradeUpgradeForEmployee(employee.id), isNotNull);
    expect(state.employeeById(employee.id)!.grade, isNot(EmployeeGrade.senior));
    state = engine.reduce(state, const AdvanceTime(13 * 360));
    expect(state.gradeUpgradeForEmployee(employee.id), isNull);
    expect(state.employeeById(employee.id)!.grade, EmployeeGrade.senior);
  });

  test('remote relocation costs money reserves time and ends on-site', () {
    final employee = employeeFixture(id: 'relocate', remote: true);
    var state = fundedInitial().copyWith(
      paused: false,
      employees: <Employee>[employee],
    );
    state = engine.reduce(
      state,
      const BuildOwnedOffice(
        cityId: 'warsaw',
        size: FacilitySize.small,
        fitoutQuality: FacilityQuality.standard,
        equipmentQuality: FacilityQuality.standard,
      ),
    );
    final office = state.ownedOffices.single;
    final cost = state.employeeRelocationCost(employee, office);
    final cashBefore = state.cash;
    state = engine.reduce(
      state,
      RelocateEmployeeToOffice(
        employeeId: employee.id,
        officeSiteId: office.id,
      ),
    );
    expect(state.relocationForEmployee(employee.id), isNotNull);
    expect(state.employeeById(employee.id)!.remote, isTrue);
    expect(state.cash, closeTo(cashBefore - cost, 0.01));
    state = engine.reduce(state, const AdvanceTime(5 * 360));
    expect(state.relocationForEmployee(employee.id), isNull);
    expect(state.employeeById(employee.id)!.remote, isFalse);
    expect(state.employeeById(employee.id)!.locationCityId, 'warsaw');
  });

  test('enabled perk recurring cost follows current employee headcount', () {
    final employees = <Employee>[
      employeeFixture(id: 'perk_a'),
      employeeFixture(id: 'perk_b'),
    ];
    var state = fundedInitial().copyWith(
      employees: <Employee>[employees.first],
    );
    final perk = V17EndgameCatalog.perkById('health_insurance');
    state = engine.reduce(state, const ToggleCompanyPerk('health_insurance'));
    expect(state.monthlyCompanyPerkCost, perk.monthlyCost);
    state = state.copyWith(employees: employees);
    expect(state.monthlyCompanyPerkCost, perk.monthlyCost * 2);
    state = state.copyWith(employees: <Employee>[employees.last]);
    expect(state.monthlyCompanyPerkCost, perk.monthlyCost);
  });

  test('counter-offer keeps resigning employee and applies required raise', () {
    final employee = employeeFixture(id: 'resign', salary: 200000, loyalty: 20);
    var state = fundedInitial().copyWith(
      employees: <Employee>[employee],
      pendingEmployeeDepartures: <PendingEmployeeDeparture>[
        PendingEmployeeDeparture(
          employeeId: employee.id,
          createdAtMinutes: 0,
          deadlineMinutes: 3 * 1440,
          requiredRaisePercent: 20,
        ),
      ],
    );
    state = engine.reduce(state, CounterOfferEmployee(employee.id));
    expect(state.pendingDepartureFor(employee.id), isNull);
    expect(state.employeeById(employee.id)!.salary, closeTo(240000, 0.01));
    expect(state.employeeById(employee.id)!.loyalty, greaterThan(20));
  });

  test(
    'expired resignation removes employee and creates employee notification',
    () {
      final employee = employeeFixture(id: 'expire', loyalty: 10);
      var state = fundedInitial().copyWith(
        paused: false,
        employees: <Employee>[employee],
        pendingEmployeeDepartures: <PendingEmployeeDeparture>[
          PendingEmployeeDeparture(
            employeeId: employee.id,
            createdAtMinutes: 0,
            deadlineMinutes: 1,
            requiredRaisePercent: 25,
          ),
        ],
      );
      state = engine.reduce(state, const AdvanceTime(360));
      expect(state.employeeById(employee.id), isNull);
      expect(
        state.companyNotifications.any(
          (item) => item.kind == CompanyNotificationKind.employee,
        ),
        isTrue,
      );
    },
  );
}
