import 'dart:convert';
import 'dart:math' as math;

import '../catalog/contract_catalog.dart';
import '../catalog/candidate_market_catalog.dart';
import '../catalog/game_catalog.dart';
import '../catalog/operations_catalog.dart';
import '../catalog/product_evolution_catalog.dart';
import '../catalog/product_strategy_catalog.dart';
import '../catalog/v9_content_catalog.dart';
import '../catalog/world_economy_catalog.dart';
import '../catalog/v17_endgame_catalog.dart';
import 'business_models.dart';
import 'management_models.dart';
import 'models.dart';
import 'operations_models.dart';
import 'product_evolution_models.dart';
import 'product_strategy_models.dart';
import 'v9_models.dart';
import 'v10_models.dart';
import 'v12_models.dart';
import 'v16_models.dart';
import 'v17_models.dart';

part 'game_state_index.dart';

const int currentSnapshotVersion = 16;

enum GameSpeed {
  x1(1),
  x2(2),
  x4(4);

  const GameSpeed(this.multiplier);
  final int multiplier;
}

class GameState {
  const GameState({
    required this.snapshotVersion,
    required this.simulationMinutes,
    required this.speed,
    required this.paused,
    required this.cash,
    this.companyProfile = const FounderCompanyProfile.unconfigured(),
    this.headquartersCityId = 'moscow',
    this.ownedOffices = const <OwnedOfficeSite>[],
    this.ownedDataCenters = const <OwnedDataCenterSite>[],
    this.employeeTrainings = const <EmployeeTrainingAssignment>[],
    this.employeeGradeUpgrades = const <EmployeeGradeUpgrade>[],
    this.employeeRelocations = const <EmployeeRelocationAssignment>[],
    this.productServiceRoutes = const <ProductServiceRoute>[],
    this.activeResearchProjects = const <CompanyResearchProject>[],
    this.completedResearchKeys = const <String>[],
    this.enabledCompanyPerkIds = const <String>[],
    this.legendMarketOffers = const <LegendMarketOffer>[],
    this.hiredLegendBonuses = const <HiredLegendBonus>[],
    this.pendingEmployeeDepartures = const <PendingEmployeeDeparture>[],
    this.companyFans = 0,
    this.brandReputation = 10,
    this.industryEventOpportunities = const <IndustryEventOpportunity>[],
    this.bookedIndustryEvents = const <BookedIndustryEvent>[],
    this.companyNotifications = const <CompanyNotification>[],
    this.worldProjects = const <WorldProjectProgress>[],
    this.ecosystemDoctrine = EcosystemDoctrine.balanced,
    this.philanthropySpent = 0,
    this.postGamePath = PostGamePath.none,
    this.taxRecords = const <AnnualTaxRecord>[],
    this.taxYearRevenueAccrued = 0,
    this.taxYearExpensesAccrued = 0,
    this.taxYearPayrollAccrued = 0,
    required this.products,
    required this.candidates,
    required this.employees,
    required this.employeeAssignments,
    required this.securityControls,
    required this.securityAudits,
    required this.productAiDeployments,
    required this.productAiIntegrations,
    required this.productImprovements,
    required this.productUpdates,
    required this.clientContracts,
    required this.contractEmployeeAssignments,
    required this.monetizationChanges,
    required this.financeHistory,
    required this.financeTransactions,
    required this.advertisingCampaigns,
    required this.priceChanges,
    required this.productFeatureDevelopments,
    required this.productMetricHistory,
    this.productCrunchPeriods = const <ProductCrunchPeriod>[],
    required this.activeLoan,
    required this.negativeCashSinceMinutes,
    required this.creditOffered,
    required this.liquidityGraceUsed,
    required this.ecosystemLinks,
    required this.selectedOfficeId,
    required this.selectedServerRoomId,
    required this.selectedHostingPlanId,
    required this.installedServers,
    required this.investorOffers,
    required this.investorAgreements,
    required this.founderOwnershipPercent,
    required this.portfolioHoldings,
    required this.acquiredCompanyIds,
    this.fullyAcquiredCompanyIds = const <String>[],
    required this.news,
    required this.criticalEvent,
    required this.criticalProductId,
    required this.gameOver,
    required this.miniGamesEnabled,
    required this.onboardingCompleted,
    required this.rngSeed,
    required this.rngCounter,
    required this.feed,
  });

  factory GameState.initial({int seed = 20260804}) => GameState(
    snapshotVersion: currentSnapshotVersion,
    simulationMinutes: 8 * 60,
    speed: GameSpeed.x1,
    paused: true,
    cash: 450000,
    companyProfile: FounderCompanyProfile.unconfigured(),
    headquartersCityId: 'moscow',
    ownedOffices: const <OwnedOfficeSite>[],
    ownedDataCenters: const <OwnedDataCenterSite>[],
    employeeTrainings: const <EmployeeTrainingAssignment>[],
    employeeGradeUpgrades: const <EmployeeGradeUpgrade>[],
    employeeRelocations: const <EmployeeRelocationAssignment>[],
    productServiceRoutes: const <ProductServiceRoute>[],
    activeResearchProjects: const <CompanyResearchProject>[],
    completedResearchKeys: const <String>[],
    enabledCompanyPerkIds: const <String>[],
    legendMarketOffers: const <LegendMarketOffer>[],
    hiredLegendBonuses: const <HiredLegendBonus>[],
    pendingEmployeeDepartures: const <PendingEmployeeDeparture>[],
    companyFans: 0,
    brandReputation: 10,
    industryEventOpportunities: const <IndustryEventOpportunity>[],
    bookedIndustryEvents: const <BookedIndustryEvent>[],
    companyNotifications: const <CompanyNotification>[],
    worldProjects: const <WorldProjectProgress>[],
    ecosystemDoctrine: EcosystemDoctrine.balanced,
    philanthropySpent: 0,
    postGamePath: PostGamePath.none,
    taxRecords: const <AnnualTaxRecord>[],
    taxYearRevenueAccrued: 0,
    taxYearExpensesAccrued: 0,
    taxYearPayrollAccrued: 0,
    products: const <Product>[],
    candidates: List<Candidate>.unmodifiable(
      CandidateMarketCatalog.initialMarket(seed: seed),
    ),
    employees: const <Employee>[],
    employeeAssignments: const <EmployeeAssignment>[],
    securityControls: const <ProductSecurityControl>[],
    securityAudits: const <SecurityAuditRecord>[],
    productAiDeployments: const <ProductAiDeployment>[],
    productAiIntegrations: const <ProductAiIntegration>[],
    productImprovements: const <ProductImprovementRecord>[],
    productUpdates: const <ProductUpdateRecord>[],
    clientContracts: const <ClientContract>[],
    contractEmployeeAssignments: const <ContractEmployeeAssignment>[],
    monetizationChanges: const <ProductMonetizationChange>[],
    financeHistory: const <FinanceHistoryPoint>[],
    financeTransactions: const <FinanceTransaction>[],
    advertisingCampaigns: const <AdvertisingCampaign>[],
    priceChanges: const <ProductPriceChange>[],
    productFeatureDevelopments: const <ProductFeatureDevelopment>[],
    productMetricHistory: const <ProductMetricPoint>[],
    activeLoan: null,
    negativeCashSinceMinutes: null,
    creditOffered: false,
    liquidityGraceUsed: false,
    ecosystemLinks: const <EcosystemLink>[],
    selectedOfficeId: 'remote_first',
    selectedServerRoomId: 'no_server_room',
    selectedHostingPlanId: 'no_hosting',
    installedServers: const <InstalledServer>[],
    investorOffers: const <InvestorOffer>[],
    investorAgreements: const <InvestorAgreement>[],
    founderOwnershipPercent: 100,
    portfolioHoldings: const <PortfolioHolding>[],
    acquiredCompanyIds: const <String>[],
    fullyAcquiredCompanyIds: const <String>[],
    news: const <NewsItem>[],
    criticalEvent: CriticalEventType.none,
    criticalProductId: null,
    gameOver: false,
    miniGamesEnabled: true,
    onboardingCompleted: false,
    rngSeed: seed,
    rngCounter: 0,
    feed: const <String>[
      'Компания зарегистрирована. На счету 450 тыс. ₽.',
      'Первый безопасный шаг — сайт компании. Крупный продукт без выручки быстро сожжёт деньги.',
    ],
  );

  final int snapshotVersion;
  final int simulationMinutes;
  final GameSpeed speed;
  final bool paused;
  final double cash;
  final FounderCompanyProfile companyProfile;
  final String headquartersCityId;
  final List<OwnedOfficeSite> ownedOffices;
  final List<OwnedDataCenterSite> ownedDataCenters;
  final List<EmployeeTrainingAssignment> employeeTrainings;
  final List<EmployeeGradeUpgrade> employeeGradeUpgrades;
  final List<EmployeeRelocationAssignment> employeeRelocations;
  final List<ProductServiceRoute> productServiceRoutes;
  final List<CompanyResearchProject> activeResearchProjects;
  final List<String> completedResearchKeys;
  final List<String> enabledCompanyPerkIds;
  final List<LegendMarketOffer> legendMarketOffers;
  final List<HiredLegendBonus> hiredLegendBonuses;
  final List<PendingEmployeeDeparture> pendingEmployeeDepartures;
  final int companyFans;
  final double brandReputation;
  final List<IndustryEventOpportunity> industryEventOpportunities;
  final List<BookedIndustryEvent> bookedIndustryEvents;
  final List<CompanyNotification> companyNotifications;
  final List<WorldProjectProgress> worldProjects;
  final EcosystemDoctrine ecosystemDoctrine;
  final double philanthropySpent;
  final PostGamePath postGamePath;
  final List<AnnualTaxRecord> taxRecords;
  final double taxYearRevenueAccrued;
  final double taxYearExpensesAccrued;
  final double taxYearPayrollAccrued;
  final List<Product> products;
  final List<Candidate> candidates;
  final List<Employee> employees;
  final List<EmployeeAssignment> employeeAssignments;
  final List<ProductSecurityControl> securityControls;
  final List<SecurityAuditRecord> securityAudits;
  final List<ProductAiDeployment> productAiDeployments;
  final List<ProductAiIntegration> productAiIntegrations;
  final List<ProductImprovementRecord> productImprovements;
  final List<ProductUpdateRecord> productUpdates;
  final List<ClientContract> clientContracts;
  final List<ContractEmployeeAssignment> contractEmployeeAssignments;
  final List<ProductMonetizationChange> monetizationChanges;
  final List<FinanceHistoryPoint> financeHistory;
  final List<FinanceTransaction> financeTransactions;
  final List<AdvertisingCampaign> advertisingCampaigns;
  final List<ProductPriceChange> priceChanges;
  final List<ProductFeatureDevelopment> productFeatureDevelopments;
  final List<ProductMetricPoint> productMetricHistory;
  final List<ProductCrunchPeriod> productCrunchPeriods;
  final CompanyLoan? activeLoan;
  final int? negativeCashSinceMinutes;
  final bool creditOffered;
  final bool liquidityGraceUsed;
  final List<EcosystemLink> ecosystemLinks;
  final String selectedOfficeId;
  final String selectedServerRoomId;
  final String selectedHostingPlanId;
  final List<InstalledServer> installedServers;
  final List<InvestorOffer> investorOffers;
  final List<InvestorAgreement> investorAgreements;
  final double founderOwnershipPercent;
  final List<PortfolioHolding> portfolioHoldings;
  final List<String> acquiredCompanyIds;
  final List<String> fullyAcquiredCompanyIds;
  final List<NewsItem> news;
  final CriticalEventType criticalEvent;
  final String? criticalProductId;
  final bool gameOver;
  final bool miniGamesEnabled;
  final bool onboardingCompleted;
  final int rngSeed;
  final int rngCounter;
  final List<String> feed;

  static final DateTime simulationEpoch = DateTime.utc(2026, 1, 5);

  int get day => simulationMinutes ~/ (24 * 60) + 1;
  int get minuteOfDay => simulationMinutes % (24 * 60);
  int get hour => minuteOfDay ~/ 60;
  int get minute => minuteOfDay % 60;

  DateTime dateTimeAt(int minutes) =>
      simulationEpoch.add(Duration(minutes: minutes));

  DateTime get simulationDateTime => dateTimeAt(simulationMinutes);

  String formatDateAt(int minutes) {
    final value = dateTimeAt(minutes);
    return '${value.day.toString().padLeft(2, '0')}.'
        '${value.month.toString().padLeft(2, '0')}.'
        '${value.year}';
  }

  String get formattedDate => formatDateAt(simulationMinutes);
  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  String get formattedDateTime => '$formattedDate $formattedTime';
  String get weekdayName => const <String>[
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ][simulationDateTime.weekday - 1];
  String get shortWeekdayName => const <String>[
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
    'Вс',
  ][simulationDateTime.weekday - 1];

  WorldCityOption get headquartersCity =>
      WorldEconomyCatalog.cityById(headquartersCityId);

  List<String> get staffingCityIds => _index.staffingCityIds;

  String recruitmentCityIdFor(Candidate candidate) {
    if (candidate.locationCityId.isNotEmpty) {
      return candidate.locationCityId;
    }
    final cities = staffingCityIds;
    if (cities.length == 1) {
      return cities.first;
    }
    final hash = candidate.id.codeUnits.fold<int>(
      0,
      (sum, unit) => (sum * 31 + unit) & 0x7fffffff,
    );
    return cities[hash % cities.length];
  }

  String employeeCityId(Employee employee) => employee.locationCityId.isEmpty
      ? headquartersCityId
      : employee.locationCityId;

  int ownedOfficeCapacityIn(String cityId) =>
      _index.ownedOfficeCapacityByCity[cityId] ?? 0;

  int onSiteEmployeesIn(String cityId) =>
      _index.onSiteEmployeeCountByCity[cityId] ?? 0;

  int bestOwnedOfficeComfortIn(String cityId) =>
      _index.bestOwnedOfficeComfortByCity[cityId] ?? 0;

  int availableOwnedOfficeSeatsIn(String cityId) {
    final incoming = employeeRelocations
        .where((item) => item.destinationCityId == cityId)
        .length;
    return math
        .max(
          0,
          ownedOfficeCapacityIn(cityId) - onSiteEmployeesIn(cityId) - incoming,
        )
        .toInt();
  }

  double get ownedOfficeMonthlyCost => ownedOffices.fold<double>(
    0,
    (sum, site) => sum + WorldEconomyCatalog.officeMonthlyCost(site),
  );

  double get ownedDataCenterMonthlyCost => ownedDataCenters.fold<double>(
    0,
    (sum, site) => sum + WorldEconomyCatalog.dataCenterMonthlyCost(site),
  );

  double get effectiveCorporateTaxRate => headquartersCity.corporateTaxRate;
  double get effectivePayrollTaxRate => headquartersCity.payrollTaxRate;

  EmployeeTrainingAssignment? trainingForEmployee(String employeeId) =>
      _index.trainingByEmployee[employeeId];

  EmployeeGradeUpgrade? gradeUpgradeForEmployee(String employeeId) =>
      _index.gradeUpgradeByEmployee[employeeId];

  EmployeeRelocationAssignment? relocationForEmployee(String employeeId) =>
      _index.relocationByEmployee[employeeId];

  ProductServiceRoute? serviceRouteFor(
    String productId,
    InfrastructureService service,
  ) =>
      _index.serviceRouteByProductAndService[_GameStateIndex.pair(
        productId,
        service.name,
      )];

  String dataCenterRouteFor(String productId, InfrastructureService service) =>
      serviceRouteFor(productId, service)?.dataCenterSiteId ?? '';

  String ownedOfficeLabel(OwnedOfficeSite site) {
    final index = ownedOffices.indexWhere((item) => item.id == site.id);
    return 'Офис #${index < 0 ? 1 : index + 1}';
  }

  String ownedDataCenterLabel(OwnedDataCenterSite site) {
    final index = ownedDataCenters.indexWhere((item) => item.id == site.id);
    return 'ЦОД #${index < 0 ? 1 : index + 1}';
  }

  double employeeRelocationCost(Employee employee, OwnedOfficeSite office) {
    final destination = WorldEconomyCatalog.cityById(office.cityId);
    final origin = WorldEconomyCatalog.cityById(employeeCityId(employee));
    final marketGap = (destination.salaryMultiplier - origin.salaryMultiplier)
        .abs();
    return 65000 + employee.salary * 0.55 + marketGap * 85000;
  }

  int employeeRelocationDurationDays(
    Employee employee,
    OwnedOfficeSite office,
  ) => office.cityId == employeeCityId(employee) ? 2 : 5;

  OfficeOption get office => GameCatalog.officeById(selectedOfficeId);
  ServerRoomOption get serverRoom =>
      GameCatalog.serverRoomById(selectedServerRoomId);
  HostingPlan get hostingPlan =>
      V9ContentCatalog.hostingById(selectedHostingPlanId);
  bool get usingOwnedInfrastructure => hostingPlan.kind == HostingKind.owned;

  Product? productById(String id) => _index.productsById[id];

  List<CompetitorBenchmark> competitorsForCategory(ProductCategory category) =>
      _index.competitorsForCategory(category);

  List<CompetitorBenchmark> _buildCompetitorsForCategory(
    ProductCategory category,
  ) {
    return GameCatalog.competitorsFor(category, rngSeed)
        .map((competitor) {
          final incidents = news
              .where(
                (item) =>
                    item.kind == NewsKind.security &&
                    item.title.startsWith('${competitor.productName}:'),
              )
              .length;
          if (incidents == 0) {
            return competitor;
          }
          return competitor.copyWith(
            users: (competitor.users * math.pow(0.97, incidents)).round(),
            marketScore: math
                .max(25, competitor.marketScore - incidents * 1.8)
                .toDouble(),
          );
        })
        .toList(growable: false)
      ..sort((left, right) => right.marketScore.compareTo(left.marketScore));
  }

  Candidate? candidateById(String id) => _index.candidatesById[id];

  Employee? employeeById(String id) => _index.employeesById[id];

  List<EmployeeAssignment> assignmentsForEmployee(String employeeId) =>
      _index.assignmentsByEmployee[employeeId] ?? const <EmployeeAssignment>[];

  EmployeeAssignment? assignmentForEmployee(String employeeId) {
    final matches = assignmentsForEmployee(employeeId);
    return matches.isEmpty ? null : matches.first;
  }

  EmployeeAssignment? assignmentForEmployeeOnProduct(
    String employeeId,
    String productId,
  ) =>
      _index.assignmentByEmployeeProduct[_GameStateIndex.pair(
        employeeId,
        productId,
      )];

  int activeAssignmentCountForEmployee(String employeeId) {
    final productCount = assignmentsForEmployee(
      employeeId,
    ).where((item) => productHasActiveWork(item.productId)).length;
    final contractCount =
        (_index.contractAssignmentsByEmployee[employeeId] ??
                const <ContractEmployeeAssignment>[])
            .where(
              (item) =>
                  _index.contractsById[item.contractId]?.status ==
                  ContractStatus.active,
            )
            .length;
    return productCount + contractCount;
  }

  bool productHasActiveWork(String productId) {
    final product = productById(productId);
    if (product == null || product.stage == ProductStage.failed) {
      return false;
    }
    if (product.stage == ProductStage.development ||
        product.stage == ProductStage.beta) {
      return true;
    }
    return activeFeatureDevelopmentFor(productId) != null;
  }

  double parallelEfficiencyForEmployee(String employeeId) =>
      switch (activeAssignmentCountForEmployee(employeeId)) {
        <= 1 => 1.0,
        2 => 0.70,
        3 => 0.55,
        _ => 0.40,
      };

  bool canAssignEmployeeToMoreWork(String employeeId) =>
      activeAssignmentCountForEmployee(employeeId) < 4;

  double employeeAllocationForProduct(String employeeId, String productId) {
    if (assignmentForEmployeeOnProduct(employeeId, productId) == null) {
      return 0;
    }
    return parallelEfficiencyForEmployee(employeeId) * 100;
  }

  double employeeBaseProductivityPercent(Employee employee) =>
      (employee.skill * 0.40 +
              employee.speed * 0.34 +
              employee.quality * 0.18 +
              employee.autonomy * 0.08)
          .clamp(0, 100)
          .toDouble();

  double employeeMoraleProductivityMultiplier(Employee employee) =>
      (0.90 + (employee.morale - 70) * 0.003).clamp(0.75, 1.09).toDouble();

  double employeeWorkloadProductivityMultiplier(Employee employee) {
    if (employee.workload <= 82) {
      return 1;
    }
    return (1 - (employee.workload - 82) * 0.012).clamp(0.72, 1.0).toDouble();
  }

  double employeeCoreProductivityPercent(Employee employee) =>
      (employeeBaseProductivityPercent(employee) *
              employeeMoraleProductivityMultiplier(employee) *
              employeeWorkloadProductivityMultiplier(employee))
          .clamp(0, 109)
          .toDouble();

  double get companyPerkProductivityMultiplier =>
      (1 +
              enabledCompanyPerkIds.fold<double>(
                0,
                (sum, id) =>
                    sum + V17EndgameCatalog.perkById(id).productivityBonus,
              ))
          .clamp(1.0, 1.18)
          .toDouble();

  double employeeProductivityPercent(Employee employee) =>
      (employeeCoreProductivityPercent(employee) *
              parallelEfficiencyForEmployee(employee.id) *
              officeProductivityMultiplier(employee) *
              companyPerkProductivityMultiplier)
          .clamp(0, 118)
          .toDouble();

  double officeProductivityMultiplier(Employee employee) {
    if (employee.remote) {
      return 1;
    }
    final cityId = employeeCityId(employee);
    final comfort = bestOwnedOfficeComfortIn(cityId);
    if (comfort > 0) {
      return (1.02 + comfort / 850).clamp(1.0, 1.20).toDouble();
    }
    if (cityId != headquartersCityId || office.id == 'remote_first') {
      return 1;
    }
    final comfortBonus = office.comfortScore / 1000;
    final communicationBonus = (office.communicationEfficiency - 0.90) * 0.25;
    return (1.02 + comfortBonus + communicationBonus)
        .clamp(1.0, 1.20)
        .toDouble();
  }

  List<String> employeeProductivityFactors(Employee employee) {
    final factors = <String>[
      'Навыки и грейд: база ${employeeBaseProductivityPercent(employee).round()}%',
    ];
    if (employee.morale >= 85) {
      factors.add('Высокая мораль повышает продуктивность');
    } else if (employee.morale < 65) {
      factors.add('Низкая мораль снижает продуктивность');
    } else {
      factors.add('Мораль в норме');
    }
    if (employee.workload > 82) {
      factors.add('Перегрузка ${employee.workload}% снижает продуктивность');
    } else {
      factors.add('Нагрузка без штрафа');
    }
    final activeWorks = activeAssignmentCountForEmployee(employee.id);
    if (activeWorks > 1) {
      factors.add(
        '$activeWorks активные работы делят вклад до ${(parallelEfficiencyForEmployee(employee.id) * 100).round()}%',
      );
    } else if (activeWorks == 1) {
      factors.add('Одна активная работа: штрафа за параллельность нет');
    } else {
      factors.add('Нет активной работы: сотрудник не создаёт вклад');
    }
    if (!employee.remote && officeProductivityMultiplier(employee) > 1) {
      final city = WorldEconomyCatalog.cityById(employeeCityId(employee));
      factors.add(
        'Офис в ${city.cityRu}: ×${officeProductivityMultiplier(employee).toStringAsFixed(2)} только для on-site',
      );
    } else if (employee.remote) {
      factors.add('Remote: офисный бонус не применяется');
    }
    return List<String>.unmodifiable(factors);
  }

  List<Employee> employeesForProduct(String productId) =>
      _index.employeesByProduct[productId] ?? const <Employee>[];

  List<Employee> get unassignedEmployees => employees
      .where(
        (employee) =>
            assignmentsForEmployee(employee.id).isEmpty &&
            contractAssignmentForEmployee(employee.id) == null,
      )
      .toList(growable: false);

  int get onSiteEmployeeCount =>
      employees.where((employee) => !employee.remote).length;

  int get remoteEmployeeCount =>
      employees.where((employee) => employee.remote).length;

  int get totalOfficeCapacity =>
      office.capacity +
      ownedOffices.fold<int>(
        0,
        (sum, site) => sum + WorldEconomyCatalog.officeCapacity(site.size),
      );

  int get availableOfficeSeats =>
      math.max(0, totalOfficeCapacity - onSiteEmployeeCount).toInt();

  List<ClientContract> get activeContracts => clientContracts
      .where((contract) => contract.status == ContractStatus.active)
      .toList(growable: false);

  List<ClientContract> get completedContracts => clientContracts
      .where((contract) => contract.status == ContractStatus.completed)
      .toList(growable: false);

  List<ClientContract> get failedContracts => clientContracts
      .where((contract) => contract.status == ContractStatus.failed)
      .toList(growable: false);

  ClientContract? contractById(String id) => _index.contractsById[id];

  ContractEmployeeAssignment? contractAssignmentForEmployee(String employeeId) {
    for (final assignment
        in _index.contractAssignmentsByEmployee[employeeId] ??
            const <ContractEmployeeAssignment>[]) {
      if (_index.contractsById[assignment.contractId]?.status ==
          ContractStatus.active) {
        return assignment;
      }
    }
    return null;
  }

  List<Employee> employeesForContract(String contractId) =>
      _index.employeesByContract[contractId] ?? const <Employee>[];

  ContractTemplate contractTemplate(String templateId) =>
      ContractCatalog.byId(templateId);

  bool hasActiveContractTemplate(String templateId) =>
      activeContracts.any((contract) => contract.templateId == templateId);

  double contractOfferRoleCoverage(ContractTemplate template) {
    if (template.requiredRoles.isEmpty) {
      return 1;
    }
    final available = employees
        .where((employee) => canAssignEmployeeToMoreWork(employee.id))
        .toList(growable: true);
    var covered = 0;
    for (final role in template.requiredRoles) {
      final index = available.indexWhere((employee) => employee.role == role);
      if (index >= 0) {
        covered += 1;
        available.removeAt(index);
      }
    }
    return covered / template.requiredRoles.length;
  }

  double contractRoleCoverage(ContractTemplate template) =>
      contractOfferRoleCoverage(template);

  double contractRoleCoverageFor(String contractId) {
    final contract = contractById(contractId);
    if (contract == null) {
      return 0;
    }
    final template = contractTemplate(contract.templateId);
    if (template.requiredRoles.isEmpty) {
      return 1;
    }
    final roles = employeesForContract(
      contractId,
    ).map((employee) => employee.role).toList(growable: false);
    final covered = template.requiredRoles
        .where((role) => roles.contains(role))
        .length;
    return covered / template.requiredRoles.length;
  }

  double contractDevelopmentCapacityFor(String contractId) {
    final team = employeesForContract(contractId);
    final founderBase = 8 / math.max(1, activeContracts.length);
    if (team.isEmpty) {
      return founderBase;
    }
    return founderBase +
        team.fold<double>(0, (sum, employee) {
          final efficiency = parallelEfficiencyForEmployee(employee.id);
          return sum +
              (employee.skill * 0.28 +
                      employee.speed * 0.24 +
                      employee.quality * 0.14) *
                  efficiency;
        });
  }

  double get contractDevelopmentCapacity =>
      8 +
      employees
          .where((employee) => canAssignEmployeeToMoreWork(employee.id))
          .fold<double>(0, (sum, employee) {
            final efficiency = parallelEfficiencyForEmployee(employee.id);
            return sum +
                (employee.skill * 0.28 +
                        employee.speed * 0.24 +
                        employee.quality * 0.14) *
                    efficiency;
          });

  List<String> securityControlIdsFor(String productId) =>
      (_index.securityByProduct[productId] ?? const <ProductSecurityControl>[])
          .map((item) => item.controlId)
          .toList(growable: false);

  bool hasSecurityControl(String productId, String controlId) =>
      (_index.securityByProduct[productId] ?? const <ProductSecurityControl>[])
          .any((item) => item.controlId == controlId);

  double productSecurityBonus(String productId) => securityControls
      .where((item) => item.productId == productId)
      .fold<double>(
        0,
        (sum, item) =>
            sum +
            OperationsCatalog.securityControlById(item.controlId).securityDelta,
      );

  double productSecurityReliabilityBonus(String productId) => securityControls
      .where((item) => item.productId == productId)
      .fold<double>(
        0,
        (sum, item) =>
            sum +
            OperationsCatalog.securityControlById(
              item.controlId,
            ).reliabilityDelta,
      );

  double productIncidentMultiplier(String productId) => securityControls
      .where((item) => item.productId == productId)
      .fold<double>(
        1,
        (value, item) =>
            value *
            OperationsCatalog.securityControlById(
              item.controlId,
            ).incidentMultiplier,
      )
      .clamp(0.12, 1)
      .toDouble();

  double productSecurityMonthlyCost(String productId) => securityControls
      .where((item) => item.productId == productId)
      .fold<double>(
        0,
        (sum, item) =>
            sum +
            OperationsCatalog.securityControlById(item.controlId).monthlyCost,
      );

  double productSecurityRisk(Product product) {
    final categoryRisk = product.category == ProductCategory.cryptoWallet
        ? 0.20
        : 0.05;
    final servesTraffic = product.stage == ProductStage.live;
    final scaleRisk = servesTraffic
        ? math.min(0.18, product.users / 5000000)
        : 0.0;
    final infrastructureRisk = servesTraffic
        ? math.max(0, productServerLoad(product) - 0.85) * 0.20
        : 0.0;
    final raw =
        (100 - product.securityScore) / 100 * 0.58 +
        categoryRisk +
        scaleRisk +
        infrastructureRisk;
    return (raw * productIncidentMultiplier(product.id))
        .clamp(0.01, 0.95)
        .toDouble();
  }

  DevelopmentStaffingSnapshot developmentStaffingFor(String productId) {
    final product = productById(productId);
    if (product == null) {
      return const DevelopmentStaffingSnapshot(
        teamSize: 0,
        minimumTeamSize: 0,
        optimalTeamSize: 0,
        maximumEfficientTeamSize: 0,
        languageCoverage: 0,
        roleCoverage: 0,
        efficiency: 0,
        status: 'Продукт не найден',
        criticalEmployeeIds: <String>[],
        movableEmployeeIds: <String>[],
      );
    }
    final strategy = ProductStrategyCatalog.strategyFor(product.blueprintId);
    final team = employeesForProduct(productId);
    final selectedLanguages = product.languageIds.toSet();
    final coveredLanguages = <String>{};
    for (final employee in team) {
      coveredLanguages.addAll(
        employee.languageIds.where(selectedLanguages.contains),
      );
    }
    final languageCoverage = selectedLanguages.isEmpty
        ? 1.0
        : coveredLanguages.length / selectedLanguages.length;
    final roleCoverage = productRoleCoverage(productId);
    final teamSize = team.length;

    // R2: missing one person is a bottleneck, not a death sentence.
    final sizeEfficiency = teamSize == 0
        ? 0.10
        : teamSize < strategy.minimumTeamSize
        ? (0.62 + 0.38 * teamSize / math.max(1, strategy.minimumTeamSize))
              .clamp(0.55, 1.0)
              .toDouble()
        : teamSize <= strategy.maximumEfficientTeamSize
        ? 1.0
        : (1 - (teamSize - strategy.maximumEfficientTeamSize) * 0.045)
              .clamp(0.64, 1.0)
              .toDouble();
    final roleFactor = (0.72 + roleCoverage * 0.28).clamp(0.72, 1.0);
    final languageFactor = (0.82 + languageCoverage * 0.18).clamp(0.82, 1.0);
    final efficiency = teamSize == 0
        ? 0.10
        : (sizeEfficiency * roleFactor * languageFactor)
              .clamp(0.42, 1.0)
              .toDouble();

    final progress = product.developmentProgress;
    final requiresDevOps = roleRequirementsFor(
      product,
    ).any((item) => item.role == EmployeeRole.devOps && item.minimumCount > 0);
    final phaseCriticalRoles = <EmployeeRole>{
      if (progress < 0.08) ...[
        EmployeeRole.productManager,
        EmployeeRole.designer,
      ] else if (progress < 0.18) ...[
        EmployeeRole.backend,
        EmployeeRole.security,
      ] else if (progress < 0.38) ...[
        EmployeeRole.frontend,
        EmployeeRole.mobile,
        EmployeeRole.designer,
      ] else if (progress < 0.62) ...[
        EmployeeRole.backend,
        EmployeeRole.aiMl,
      ] else if (progress < 0.72 && requiresDevOps) ...[
        EmployeeRole.devOps,
        EmployeeRole.security,
      ] else if (progress < 0.84) ...[
        EmployeeRole.frontend,
        EmployeeRole.backend,
        EmployeeRole.mobile,
        EmployeeRole.aiMl,
      ] else if (progress < 0.96) ...[
        EmployeeRole.qa,
        EmployeeRole.security,
        EmployeeRole.devOps,
      ] else ...[
        EmployeeRole.productManager,
        EmployeeRole.qa,
        EmployeeRole.devOps,
      ],
    };

    final criticalIds = <String>[];
    final movableIds = <String>[];
    for (final employee in team) {
      final phaseCritical = phaseCriticalRoles.contains(employee.role);
      final uniqueLanguage = employee.languageIds.any((language) {
        if (!selectedLanguages.contains(language)) return false;
        return team
            .where((other) => other.id != employee.id)
            .where((other) => other.languageIds.contains(language))
            .isEmpty;
      });
      if (phaseCritical || uniqueLanguage) {
        criticalIds.add(employee.id);
      } else {
        movableIds.add(employee.id);
      }
    }

    final missing = missingRoleRequirements(productId);
    final status = teamSize == 0
        ? 'Нет назначенной команды'
        : missing.isNotEmpty
        ? 'Есть bottleneck: ${missing.map((item) => item.role.name).join(', ')}'
        : teamSize > strategy.maximumEfficientTeamSize
        ? 'Слишком большая команда: коммуникационный overhead'
        : teamSize < strategy.optimalTeamSize
        ? 'Рабочая команда, можно ускорить точечным наймом'
        : 'Сбалансированная команда';

    return DevelopmentStaffingSnapshot(
      teamSize: teamSize,
      minimumTeamSize: strategy.minimumTeamSize,
      optimalTeamSize: strategy.optimalTeamSize,
      maximumEfficientTeamSize: strategy.maximumEfficientTeamSize,
      languageCoverage: languageCoverage,
      roleCoverage: roleCoverage,
      efficiency: efficiency,
      status: status,
      criticalEmployeeIds: List<String>.unmodifiable(criticalIds),
      movableEmployeeIds: List<String>.unmodifiable(movableIds),
    );
  }

  double productDevelopmentCapacity(String productId) {
    final product = productById(productId);
    if (product == null) return 0;

    final team = employeesForProduct(productId);
    final staffing = developmentStaffingFor(productId);
    final aiMultiplier = 1 + productAiDevelopmentBoost(productId);
    final productManagerMultiplier =
        1 + productManagerBonusPercentFor(productId);
    if (team.isEmpty) {
      return companyProfile.configured
          ? 0
          : 0.12 * staffing.efficiency * aiMultiplier;
    }

    const engineeringRoles = <EmployeeRole>{
      EmployeeRole.frontend,
      EmployeeRole.backend,
      EmployeeRole.mobile,
      EmployeeRole.aiMl,
      EmployeeRole.devOps,
      EmployeeRole.security,
      EmployeeRole.qa,
    };
    const languageIndependentRoles = <EmployeeRole>{
      EmployeeRole.productManager,
      EmployeeRole.designer,
      EmployeeRole.growth,
      EmployeeRole.sales,
      EmployeeRole.support,
    };

    final progress = product.developmentProgress;
    final requiresDevOps = roleRequirementsFor(
      product,
    ).any((item) => item.role == EmployeeRole.devOps && item.minimumCount > 0);
    final phaseCriticalRoles = <EmployeeRole>{
      if (progress < 0.08) ...[
        EmployeeRole.productManager,
        EmployeeRole.designer,
      ] else if (progress < 0.18) ...[
        EmployeeRole.backend,
        EmployeeRole.security,
      ] else if (progress < 0.38) ...[
        EmployeeRole.frontend,
        EmployeeRole.mobile,
        EmployeeRole.designer,
      ] else if (progress < 0.62) ...[
        EmployeeRole.backend,
        EmployeeRole.aiMl,
      ] else if (progress < 0.72 && requiresDevOps) ...[
        EmployeeRole.devOps,
        EmployeeRole.security,
      ] else if (progress < 0.84) ...[
        EmployeeRole.frontend,
        EmployeeRole.backend,
        EmployeeRole.mobile,
        EmployeeRole.aiMl,
      ] else if (progress < 0.96) ...[
        EmployeeRole.qa,
        EmployeeRole.security,
        EmployeeRole.devOps,
      ] else ...[
        EmployeeRole.productManager,
        EmployeeRole.qa,
        EmployeeRole.devOps,
      ],
    };

    final selectedLanguages = product.languageIds.toSet();
    var effectiveFte = 0.0;
    for (final employee in team) {
      if (trainingForEmployee(employee.id) != null ||
          gradeUpgradeForEmployee(employee.id) != null) {
        continue;
      }
      final productivity =
          employeeCoreProductivityPercent(employee) /
          100 *
          officeProductivityMultiplier(employee) *
          companyPerkProductivityMultiplier *
          productCrunchMultiplier(productId);
      final phaseWeight = phaseCriticalRoles.contains(employee.role)
          ? 1.0
          : engineeringRoles.contains(employee.role)
          ? 0.68
          : 0.38;
      final languageMatch = languageIndependentRoles.contains(employee.role)
          ? 0.95
          : employee.languageIds.any(selectedLanguages.contains)
          ? 1.0
          : 0.50;
      final allocation =
          employeeAllocationForProduct(employee.id, productId) / 100;
      effectiveFte += productivity * phaseWeight * languageMatch * allocation;
    }

    return effectiveFte *
        staffing.efficiency *
        aiMultiplier *
        productManagerMultiplier;
  }

  double productManagerBonusPercentFor(String productId) {
    final productManagers = employeesForProduct(
      productId,
    ).where((employee) => employee.role == EmployeeRole.productManager);
    if (productManagers.isEmpty) {
      return 0;
    }
    final bestGrade = productManagers
        .map((employee) => employee.grade)
        .reduce((left, right) => left.index >= right.index ? left : right);
    return switch (bestGrade) {
      EmployeeGrade.intern => 0.04,
      EmployeeGrade.junior => 0.08,
      EmployeeGrade.middle => 0.15,
      EmployeeGrade.senior => 0.24,
    };
  }

  ProductCrunchPeriod? crunchFor(String productId) {
    ProductCrunchPeriod? latest;
    for (final period in productCrunchPeriods) {
      if (period.productId == productId &&
          (latest == null ||
              period.startedAtMinutes > latest.startedAtMinutes)) {
        latest = period;
      }
    }
    return latest;
  }

  double productCrunchMultiplier(String productId) {
    final period = crunchFor(productId);
    if (period == null || simulationMinutes >= period.recoveryEndsAtMinutes) {
      return 1;
    }
    return simulationMinutes < period.boostEndsAtMinutes ? 1.28 : 0.78;
  }

  String productCrunchStatus(String productId) {
    final period = crunchFor(productId);
    if (period == null || simulationMinutes >= period.recoveryEndsAtMinutes) {
      return 'Доступен';
    }
    final boosting = simulationMinutes < period.boostEndsAtMinutes;
    final remaining =
        ((boosting ? period.boostEndsAtMinutes : period.recoveryEndsAtMinutes) -
            simulationMinutes) /
        1440;
    return boosting
        ? 'Форсаж: +28% ещё ${remaining.ceil()} дн.'
        : 'Восстановление: −22% ещё ${remaining.ceil()} дн.';
  }

  bool canStartProductCrunch(String productId) =>
      productCrunchMultiplier(productId) == 1;

  double get averageEmployeeSkill => _employeeAverage((item) => item.skill);
  double get averageEmployeeSpeed => _employeeAverage((item) => item.speed);
  double get averageEmployeeQuality => _employeeAverage((item) => item.quality);
  double get averageEmployeeReliability =>
      _employeeAverage((item) => item.reliability);
  double get averageEmployeeMorale => _employeeAverage((item) => item.morale);
  double get averageEmployeeLoyalty => _employeeAverage((item) => item.loyalty);

  double _employeeAverage(int Function(Employee employee) metric) {
    if (employees.isEmpty) {
      return 0;
    }
    return employees.map(metric).reduce((a, b) => a + b) / employees.length;
  }

  List<ProductRoleRequirement> roleRequirementsFor(Product product) =>
      ProductEvolutionCatalog.roleRequirements(product.category);

  int assignedRoleCount(String productId, EmployeeRole role) =>
      employeesForProduct(productId).where((item) => item.role == role).length;

  double productRoleCoverage(String productId) {
    final product = productById(productId);
    if (product == null) {
      return 0;
    }
    final requirements = roleRequirementsFor(product);
    final total = requirements.fold<int>(
      0,
      (sum, item) => sum + item.minimumCount,
    );
    if (total == 0) {
      return 1;
    }
    final filled = requirements.fold<int>(0, (sum, requirement) {
      final count = assignedRoleCount(productId, requirement.role);
      return sum + math.min(count, requirement.minimumCount).toInt();
    });
    return filled / total;
  }

  List<ProductRoleRequirement> missingRoleRequirements(String productId) {
    final product = productById(productId);
    if (product == null) {
      return const <ProductRoleRequirement>[];
    }
    return roleRequirementsFor(product)
        .where(
          (requirement) =>
              assignedRoleCount(productId, requirement.role) <
              requirement.minimumCount,
        )
        .toList(growable: false);
  }

  AiDeploymentMode aiDeploymentModeFor(String productId) {
    for (final deployment in productAiDeployments) {
      if (deployment.productId == productId) {
        return deployment.mode;
      }
    }
    return AiDeploymentMode.publicMarket;
  }

  Product? corporateAiForTarget(String targetProductId) {
    for (final integration in productAiIntegrations) {
      if (integration.targetProductId == targetProductId) {
        final product = productById(integration.aiProductId);
        if (product != null &&
            product.stage == ProductStage.live &&
            aiDeploymentModeFor(product.id) == AiDeploymentMode.corporate) {
          return product;
        }
      }
    }
    return null;
  }

  List<Product> get corporateAiProducts => products
      .where(
        (product) =>
            product.category == ProductCategory.aiAssistant &&
            product.stage == ProductStage.live &&
            aiDeploymentModeFor(product.id) == AiDeploymentMode.corporate,
      )
      .toList(growable: false);

  double productAiDevelopmentBoost(String productId) =>
      corporateAiForTarget(productId) == null
      ? 0
      : ProductEvolutionCatalog.corporateAiDevelopmentBoost;

  double productAiQualityBoost(String productId) =>
      corporateAiForTarget(productId) == null
      ? 0
      : ProductEvolutionCatalog.corporateAiQualityBoost;

  double corporateAiComputeDemandFor(String aiProductId) {
    return productAiIntegrations
        .where((item) => item.aiProductId == aiProductId)
        .fold<double>(0, (sum, item) {
          final target = productById(item.targetProductId);
          final scaleDemand = target == null ? 0 : target.users / 50000 * 2;
          return sum +
              ProductEvolutionCatalog.corporateAiBaseComputeDemand +
              scaleDemand;
        });
  }

  double get monthlyCorporateAiCost =>
      productAiIntegrations.length *
      ProductEvolutionCatalog.corporateAiMonthlyCostPerIntegration;

  int improvementLevel(String productId, ProductImprovementType type) =>
      _index.improvementLevelByProductType[_GameStateIndex.pair(
        productId,
        type.name,
      )] ??
      0;

  double improvementCost(String productId, ProductImprovementType type) {
    final option = ProductEvolutionCatalog.improvementByType(type);
    final level = improvementLevel(productId, type);
    return option.baseCost * (1 + level * 0.38);
  }

  double improvementRequiredHours(
    String productId,
    ProductImprovementType type,
  ) {
    final option = ProductEvolutionCatalog.improvementByType(type);
    final nextLevel = improvementLevel(productId, type) + 1;
    return (math.max(
              14,
              option.baseCost / 1600 * (1 + (nextLevel - 1) * 0.18),
            ) *
            companyProfile.improvementHoursMultiplier)
        .toDouble();
  }

  double productImprovementMonthlyCost(String productId) => 0;

  double productImprovementComputeMultiplier(String productId) =>
      ProductImprovementType.values.fold<double>(1, (value, type) {
        final option = ProductEvolutionCatalog.improvementByType(type);
        return value *
            math
                .pow(
                  option.computeMultiplier,
                  improvementLevel(productId, type),
                )
                .toDouble();
      });

  int productLastUpdateMinutes(Product product) {
    var last = product.createdAtMinutes;
    for (final update in productUpdates) {
      if (update.productId == product.id && update.updatedAtMinutes > last) {
        last = update.updatedAtMinutes;
      }
    }
    return last;
  }

  ProductUpdateRecord? latestProductUpdate(Product product) {
    ProductUpdateRecord? latest;
    for (final update in productUpdates) {
      if (update.productId == product.id &&
          (latest == null ||
              update.updatedAtMinutes > latest.updatedAtMinutes)) {
        latest = update;
      }
    }
    return latest;
  }

  double productAgeSinceUpdateDays(Product product) =>
      (math.max(0, simulationMinutes - productLastUpdateMinutes(product)) /
              1440)
          .toDouble();

  double productAgeDays(Product product) {
    final origin = product.releasedAtMinutes >= 0
        ? product.releasedAtMinutes
        : product.createdAtMinutes;
    return (math.max(0, simulationMinutes - origin) / 1440).toDouble();
  }

  double productFreshnessCeiling(Product product) {
    final age = productAgeDays(product);
    final addedFeatures = math.max(0, product.featureIds.length - 1);
    final addedStack = product.technologyIds.length;
    final improvementLevels = ProductImprovementType.values.fold<int>(
      0,
      (sum, type) => sum + improvementLevel(product.id, type),
    );
    final supportedLifetimeDays =
        (180 +
                math.min(180, addedFeatures * 18) +
                math.min(140, addedStack * 14) +
                math.min(180, improvementLevels * 20))
            .toDouble();
    if (age <= supportedLifetimeDays) {
      return 100;
    }
    return (100 - (age - supportedLifetimeDays) * 0.18)
        .clamp(0, 100)
        .toDouble();
  }

  double productSupportedLifetimeDays(Product product) {
    final addedFeatures = math.max(0, product.featureIds.length - 1);
    final addedStack = product.technologyIds.length;
    final improvementLevels = ProductImprovementType.values.fold<int>(
      0,
      (sum, type) => sum + improvementLevel(product.id, type),
    );
    return (180 +
            math.min(180, addedFeatures * 18) +
            math.min(140, addedStack * 14) +
            math.min(180, improvementLevels * 20))
        .toDouble();
  }

  double productFreshnessScore(Product product) {
    final days = productAgeSinceUpdateDays(product);
    final recency = days <= 21
        ? 100.0
        : (100 - (days - 21) * 1.35).clamp(0, 100).toDouble();
    return math.min(recency, productFreshnessCeiling(product)).toDouble();
  }

  double productStalenessPenalty(Product product) =>
      (100 - productFreshnessScore(product)) / 100;

  int productBugWeight(Product product) =>
      product.openBugs.fold<int>(0, (sum, bug) => sum + bug.weight);

  double productBugPenalty(Product product) =>
      (productBugWeight(product) / 24).clamp(0, 0.75).toDouble();

  SecurityAuditRecord? latestAuditFor(String productId) {
    final records =
        securityAudits
            .where((item) => item.productId == productId)
            .toList(growable: false)
          ..sort((a, b) => b.simulationMinutes.compareTo(a.simulationMinutes));
    return records.isEmpty ? null : records.first;
  }

  InvestorOffer? offerById(String id) => _index.offersById[id];

  InvestorAgreement? agreementById(String id) => _index.agreementsById[id];

  PortfolioHolding? holdingByCompanyId(String id) =>
      _index.holdingsByCompanyId[id];

  int installedCount(String hardwareId) =>
      _index.installedCountByHardwareId[hardwareId] ?? 0;

  double usedRackUnitsAtDataCenter(String siteId) =>
      (_index.serversByDataCenter[siteId] ?? const <InstalledServer>[])
          .fold<double>(0, (sum, item) {
            final hardware = GameCatalog.serverHardwareById(item.hardwareId);
            return sum + hardware.rackUnits * item.count;
          });

  double usedPowerKwAtDataCenter(String siteId) =>
      (_index.serversByDataCenter[siteId] ?? const <InstalledServer>[])
          .fold<double>(0, (sum, item) {
            final hardware = GameCatalog.serverHardwareById(item.hardwareId);
            return sum + hardware.powerKw * item.count;
          });

  double usedCoolingKwAtDataCenter(String siteId) =>
      (_index.serversByDataCenter[siteId] ?? const <InstalledServer>[])
          .fold<double>(0, (sum, item) {
            final hardware = GameCatalog.serverHardwareById(item.hardwareId);
            return sum + hardware.heatKw * item.count;
          });

  double get ownedDataCenterRackUnits => ownedDataCenters.fold<double>(
    0,
    (sum, site) => sum + WorldEconomyCatalog.dataCenterRackUnits(site.size),
  );

  double get ownedDataCenterPowerKw => ownedDataCenters.fold<double>(
    0,
    (sum, site) => sum + WorldEconomyCatalog.dataCenterPowerKw(site),
  );

  double get ownedDataCenterCoolingKw => ownedDataCenters.fold<double>(
    0,
    (sum, site) => sum + WorldEconomyCatalog.dataCenterCoolingKw(site),
  );

  double get ownedDataCenterNetworkGbps => ownedDataCenters.fold<double>(
    0,
    (sum, site) => sum + WorldEconomyCatalog.dataCenterNetworkGbps(site),
  );

  double get effectiveRackUnits =>
      serverRoom.rackUnits + ownedDataCenterRackUnits;
  double get effectivePowerKw => serverRoom.powerKw + ownedDataCenterPowerKw;
  double get effectiveCoolingKw =>
      serverRoom.coolingKw + ownedDataCenterCoolingKw;

  double get usedRackUnits => installedServers.fold<double>(0, (sum, item) {
    final hardware = GameCatalog.serverHardwareById(item.hardwareId);
    return sum + hardware.rackUnits * item.count;
  });

  double get usedCoolingKw => installedServers.fold<double>(0, (sum, item) {
    final hardware = GameCatalog.serverHardwareById(item.hardwareId);
    return sum + hardware.heatKw * item.count;
  });

  double get usedPowerKw => installedServers.fold<double>(0, (sum, item) {
    final hardware = GameCatalog.serverHardwareById(item.hardwareId);
    return sum + hardware.powerKw * item.count;
  });

  double preparedComputeUnitsAtDataCenter(String siteId) =>
      (_index.serversByDataCenter[siteId] ?? const <InstalledServer>[])
          .fold<double>(0, (sum, item) {
            final hardware = GameCatalog.serverHardwareById(item.hardwareId);
            return sum + hardware.computeUnits * item.count;
          });

  Iterable<InstalledServer> _serversAtForService(
    String siteId,
    InfrastructureService service,
  ) => (_index.serversByDataCenter[siteId] ?? const <InstalledServer>[]).where(
    (item) =>
        item.service == InfrastructureService.sharedLegacy ||
        item.service == service,
  );

  double preparedComputeUnitsAtDataCenterForService(
    String siteId,
    InfrastructureService service,
  ) => _serversAtForService(siteId, service).fold<double>(0, (sum, item) {
    final hardware = GameCatalog.serverHardwareById(item.hardwareId);
    return sum + hardware.computeUnits * item.count;
  });

  double preparedMemoryGbAtDataCenterForService(
    String siteId,
    InfrastructureService service,
  ) => _serversAtForService(siteId, service).fold<double>(0, (sum, item) {
    final hardware = GameCatalog.serverHardwareById(item.hardwareId);
    return sum + hardware.memoryGb * item.count;
  });

  double preparedStorageGbAtDataCenterForService(
    String siteId,
    InfrastructureService service,
  ) => _serversAtForService(siteId, service).fold<double>(0, (sum, item) {
    final hardware = GameCatalog.serverHardwareById(item.hardwareId);
    return sum + hardware.storageGb * item.count;
  });

  double preparedNetworkGbpsAtDataCenterForService(
    String siteId,
    InfrastructureService service,
  ) => _serversAtForService(siteId, service).fold<double>(0, (sum, item) {
    final hardware = GameCatalog.serverHardwareById(item.hardwareId);
    return sum + hardware.networkGbps * item.count;
  });

  double preparedMemoryGbAtDataCenter(String siteId) =>
      (_index.serversByDataCenter[siteId] ?? const <InstalledServer>[])
          .fold<double>(0, (sum, item) {
            final hardware = GameCatalog.serverHardwareById(item.hardwareId);
            return sum + hardware.memoryGb * item.count;
          });

  double preparedStorageGbAtDataCenter(String siteId) =>
      (_index.serversByDataCenter[siteId] ?? const <InstalledServer>[])
          .fold<double>(0, (sum, item) {
            final hardware = GameCatalog.serverHardwareById(item.hardwareId);
            return sum + hardware.storageGb * item.count;
          });

  double preparedNetworkGbpsAtDataCenter(String siteId) =>
      (_index.serversByDataCenter[siteId] ?? const <InstalledServer>[])
          .fold<double>(0, (sum, item) {
            final hardware = GameCatalog.serverHardwareById(item.hardwareId);
            return sum + hardware.networkGbps * item.count;
          });

  double get preparedComputeUnits =>
      installedServers.fold<double>(0, (sum, item) {
        final hardware = GameCatalog.serverHardwareById(item.hardwareId);
        return sum + hardware.computeUnits * item.count;
      });

  double get preparedMemoryGb => installedServers.fold<double>(0, (sum, item) {
    final hardware = GameCatalog.serverHardwareById(item.hardwareId);
    return sum + hardware.memoryGb * item.count;
  });

  double get preparedStorageGb => installedServers.fold<double>(0, (sum, item) {
    final hardware = GameCatalog.serverHardwareById(item.hardwareId);
    return sum + hardware.storageGb * item.count;
  });

  double get totalComputeUnits =>
      (usingOwnedInfrastructure
          ? preparedComputeUnits
          : hostingPlan.computeUnits) *
      hostingOperationsEfficiency;

  bool get hasDevOps =>
      employees.any((employee) => employee.role == EmployeeRole.devOps);

  double get hostingOperationsEfficiency =>
      hostingPlan.kind == HostingKind.vps && !hasDevOps ? 0.82 : 1.0;

  double get totalMemoryGb => usingOwnedInfrastructure
      ? preparedMemoryGb
      : switch (hostingPlan.id) {
          'no_hosting' => 0.0,
          'shared_launch' => 2.0,
          'vps_core' => 4.0,
          'managed_scale' => 16.0,
          'cloud_flex' => 64.0,
          'cloud_pro' => 192.0,
          'serverless_burst' => 32.0,
          'managed_db' => 64.0,
          'object_storage' => 8.0,
          'cdn_edge' => 8.0,
          _ => math.max(2, hostingPlan.computeUnits / 8).toDouble(),
        };

  double get totalStorageGb =>
      usingOwnedInfrastructure ? preparedStorageGb : hostingPlan.storageGb;

  double get totalNetworkGbps {
    if (hostingPlan.kind == HostingKind.none) {
      return 0;
    }
    if (!usingOwnedInfrastructure) {
      return math.max(0.1, hostingPlan.bandwidthTb * 0.60).toDouble();
    }
    return math
        .min(
          serverRoom.networkGbps + ownedDataCenterNetworkGbps,
          installedServers.fold<double>(0, (sum, item) {
            final hardware = GameCatalog.serverHardwareById(item.hardwareId);
            return sum + hardware.networkGbps * item.count;
          }),
        )
        .toDouble();
  }

  double get hardwareReliability {
    if (!usingOwnedInfrastructure) {
      return hostingPlan.reliability;
    }
    if (installedServers.isEmpty) {
      return 0;
    }
    var weighted = 0.0;
    var count = 0;
    for (final installed in installedServers) {
      final hardware = GameCatalog.serverHardwareById(installed.hardwareId);
      weighted += hardware.hardwareReliability * installed.count;
      count += installed.count;
    }
    return count == 0 ? 0 : weighted / count;
  }

  bool get infrastructureFitsRoom =>
      !usingOwnedInfrastructure ||
      (usedRackUnits <= effectiveRackUnits &&
          usedCoolingKw <= effectiveCoolingKw &&
          usedPowerKw <= effectivePowerKw);

  double get totalAllocatedPercent => products.fold<double>(
    0,
    (sum, item) => sum + item.allocatedCapacityPercent,
  );

  HostingPlan? routedHostingFor(
    String productId,
    InfrastructureService service,
  ) {
    final route = dataCenterRouteFor(productId, service);
    if (!route.startsWith('hosting:')) return null;
    final parts = route.split(':');
    if (parts.length < 2) return null;
    final planId = parts[1];
    try {
      return V9ContentCatalog.hostingById(planId);
    } on Object {
      return null;
    }
  }

  double _hostingMemoryGb(HostingPlan plan) => switch (plan.id) {
    'no_hosting' => 0.0,
    'shared_launch' => 2.0,
    'vps_core' => 4.0,
    'managed_scale' => 16.0,
    'cloud_flex' => 64.0,
    'cloud_pro' => 192.0,
    'serverless_burst' => 32.0,
    'managed_db' => 64.0,
    'object_storage' => 8.0,
    'cdn_edge' => 8.0,
    _ => math.max(2, plan.computeUnits / 8).toDouble(),
  };

  double _hostingNetworkGbps(HostingPlan plan) =>
      math.max(0.1, plan.bandwidthTb * 0.60).toDouble();

  double _allocationShareForRoute(
    String productId,
    InfrastructureService service,
  ) {
    final product = productById(productId);
    if (product == null) return 0;

    final route = dataCenterRouteFor(productId, service);
    if (route.startsWith('hosting:')) {
      final routedProducts = products
          .where((item) => dataCenterRouteFor(item.id, service) == route)
          .toList(growable: false);
      if (routedProducts.length <= 1) return 1;
      final totalAtRoute = routedProducts.fold<double>(
        0,
        (sum, item) => sum + item.allocatedCapacityPercent,
      );
      return totalAtRoute <= 0
          ? 1 / routedProducts.length
          : (product.allocatedCapacityPercent / totalAtRoute)
                .clamp(0, 1)
                .toDouble();
    }

    if (!usingOwnedInfrastructure) {
      final total = products.fold<double>(
        0,
        (sum, item) => sum + item.allocatedCapacityPercent,
      );
      final denominator = math.max(100, total).toDouble();
      return (product.allocatedCapacityPercent / denominator)
          .clamp(0, 1)
          .toDouble();
    }

    final totalAtRoute = products.fold<double>(0, (sum, item) {
      return dataCenterRouteFor(item.id, service) == route
          ? sum + item.allocatedCapacityPercent
          : sum;
    });
    final denominator = math.max(100, totalAtRoute).toDouble();
    return (product.allocatedCapacityPercent / denominator)
        .clamp(0, 1)
        .toDouble();
  }

  double allocatedComputeFor(String productId) {
    final product = productById(productId);
    if (product == null) return 0;
    final routed = routedHostingFor(productId, InfrastructureService.aiCompute);
    final capacity = routed != null
        ? routed.computeUnits * hostingOperationsEfficiency
        : usingOwnedInfrastructure
        ? preparedComputeUnitsAtDataCenterForService(
            dataCenterRouteFor(productId, InfrastructureService.aiCompute),
            InfrastructureService.aiCompute,
          )
        : totalComputeUnits;
    return capacity *
        _allocationShareForRoute(productId, InfrastructureService.aiCompute);
  }

  double allocatedMemoryFor(String productId) {
    final product = productById(productId);
    if (product == null) return 0;
    final routed = routedHostingFor(productId, InfrastructureService.appApi);
    final capacity = routed != null
        ? _hostingMemoryGb(routed)
        : usingOwnedInfrastructure
        ? preparedMemoryGbAtDataCenterForService(
            dataCenterRouteFor(productId, InfrastructureService.appApi),
            InfrastructureService.appApi,
          )
        : totalMemoryGb;
    return capacity *
        _allocationShareForRoute(productId, InfrastructureService.appApi);
  }

  double allocatedStorageFor(String productId) {
    final product = productById(productId);
    if (product == null) return 0;
    final routed = routedHostingFor(
      productId,
      InfrastructureService.dataStorage,
    );
    final capacity = routed != null
        ? routed.storageGb
        : usingOwnedInfrastructure
        ? preparedStorageGbAtDataCenterForService(
            dataCenterRouteFor(productId, InfrastructureService.dataStorage),
            InfrastructureService.dataStorage,
          )
        : totalStorageGb;
    return capacity *
        _allocationShareForRoute(productId, InfrastructureService.dataStorage);
  }

  double allocatedNetworkFor(String productId) {
    final product = productById(productId);
    if (product == null) return 0;
    final routed = routedHostingFor(productId, InfrastructureService.appApi);
    final capacity = routed != null
        ? _hostingNetworkGbps(routed)
        : usingOwnedInfrastructure
        ? preparedNetworkGbpsAtDataCenterForService(
            dataCenterRouteFor(productId, InfrastructureService.appApi),
            InfrastructureService.appApi,
          )
        : totalNetworkGbps;
    return capacity *
        _allocationShareForRoute(productId, InfrastructureService.appApi);
  }

  double productComputeDemand(Product product) {
    if (product.stage == ProductStage.failed) {
      return 0;
    }
    final blueprint = GameCatalog.blueprintById(product.blueprintId);
    final userDemand = product.users / 1000 * blueprint.computePerThousandUsers;
    final baseline = product.stage == ProductStage.development ? 28 : 18;
    final aiProviderDemand = product.category == ProductCategory.aiAssistant
        ? corporateAiComputeDemandFor(product.id)
        : 0;
    return ((baseline + userDemand) *
            product.computeMultiplier *
            productImprovementComputeMultiplier(product.id) *
            _resourceOptimizationMultiplier(product)) +
        aiProviderDemand;
  }

  double _resourceOptimizationMultiplier(Product product) {
    final performance = improvementLevel(
      product.id,
      ProductImprovementType.performance,
    );
    final algorithms = improvementLevel(
      product.id,
      ProductImprovementType.algorithms,
    );
    return (math.pow(0.93, performance) * math.pow(0.90, algorithms))
        .clamp(0.42, 1.0)
        .toDouble();
  }

  double productMemoryDemand(Product product) {
    if (product.stage == ProductStage.failed) {
      return 0;
    }
    final baselineMemoryGb = product.blueprintId == 'company_website'
        ? 0.75
        : 3.0;
    final categoryMultiplier = switch (product.category) {
      ProductCategory.aiAssistant => 4.8,
      ProductCategory.cloud => 2.5,
      ProductCategory.saas => 1.8,
      ProductCategory.browser => 1.1,
      ProductCategory.cryptoWallet => 1.5,
      ProductCategory.developerTool => 2.0,
    };
    return (baselineMemoryGb +
            product.users / 1000 * 0.055 * categoryMultiplier) *
        _resourceOptimizationMultiplier(product);
  }

  double productStorageDemand(Product product) {
    if (product.stage == ProductStage.failed) {
      return 0;
    }
    final perThousand = switch (product.category) {
      ProductCategory.aiAssistant => 3.8,
      ProductCategory.cloud => 18.0,
      ProductCategory.saas => 4.2,
      ProductCategory.browser => 1.1,
      ProductCategory.cryptoWallet => 1.4,
      ProductCategory.developerTool => 6.2,
    };
    final baselineStorageGb = product.blueprintId == 'company_website'
        ? 8.0
        : 18.0;
    return (baselineStorageGb + product.users / 1000 * perThousand) *
        _resourceOptimizationMultiplier(product);
  }

  double productResourceLoad(Product product) {
    final allocation = product.allocatedCapacityPercent / 100;
    if (allocation <= 0) {
      return product.stage == ProductStage.live ? 9.99 : 0;
    }
    final compute =
        productComputeDemand(product) /
        math.max(0.001, allocatedComputeFor(product.id));
    final memory =
        productMemoryDemand(product) /
        math.max(0.001, allocatedMemoryFor(product.id));
    final storage =
        productStorageDemand(product) /
        math.max(0.001, allocatedStorageFor(product.id));
    final networkDemand = math.max(0.02, product.users / 120000).toDouble();
    final network =
        networkDemand / math.max(0.001, allocatedNetworkFor(product.id));
    return math
        .max(compute, math.max(memory, math.max(storage, network)))
        .toDouble();
  }

  double productServerLoad(Product product) {
    return productResourceLoad(product);
  }

  double get totalComputeDemand =>
      products.fold<double>(0, (sum, item) => sum + productComputeDemand(item));

  double get serverLoad => products.isEmpty
      ? 0
      : products
            .map(productResourceLoad)
            .fold<double>(0, (left, right) => math.max(left, right).toDouble());

  bool get contractsUnlocked => products.any((product) {
    if (product.stage != ProductStage.live) {
      return false;
    }
    return ProductStrategyCatalog.strategyFor(
      product.blueprintId,
    ).contractsUnlock;
  });

  DevelopmentPhaseDefinition developmentPhaseFor(Product product) =>
      ProductStrategyCatalog.phaseFor(product.developmentProgress);

  ProductFeatureDevelopment? activeFeatureDevelopmentFor(String productId) {
    for (final work
        in _index.featureWorkByProduct[productId] ??
            const <ProductFeatureDevelopment>[]) {
      if (work.progress < 1) {
        return work;
      }
    }
    return null;
  }

  double featureDevelopmentRemainingHours(String productId) {
    final work = activeFeatureDevelopmentFor(productId);
    if (work == null) {
      return 0;
    }
    return math.max(0, work.requiredHours * (1 - work.progress)).toDouble();
  }

  List<AdvertisingCampaign> activeCampaignsFor(String productId) =>
      (_index.campaignsByProduct[productId] ?? const <AdvertisingCampaign>[])
          .where((item) => item.status == AdvertisingCampaignStatus.active)
          .toList(growable: false);

  ProductPriceChange? latestPriceChangeFor(String productId) {
    ProductPriceChange? latest;
    for (final change in priceChanges) {
      if (change.productId == productId &&
          (latest == null ||
              change.changedAtMinutes > latest.changedAtMinutes)) {
        latest = change;
      }
    }
    return latest;
  }

  double productUserSatisfaction(Product product) {
    final competitor = GameCatalog.competitorsFor(
      product.category,
      rngSeed,
    ).first;
    final speedScore = (competitor.speedMs / math.max(1, product.speedMs))
        .clamp(0.12, 1.0)
        .toDouble();
    final qualityScore = (product.qualityScore / 100).clamp(0, 1).toDouble();
    final reliabilityScore = product.reliability.clamp(0, 1).toDouble();
    final featureScore = product.featureCoverage.clamp(0, 1).toDouble();
    final securityScore = (product.securityScore / 100).clamp(0, 1).toDouble();
    final blueprint = GameCatalog.blueprintById(product.blueprintId);
    final basePrice = math.max(1.0, blueprint.basePrice).toDouble();
    final pricePressure =
        product.monetization == MonetizationModel.free ||
            product.monetization == MonetizationModel.advertising
        ? 0.0
        : product.monetization == MonetizationModel.transactionFee
        ? math.max(0, product.price - 1.5) / 8
        : math.max(
            currentPriceSentiment(product),
            math.max(0, product.price / basePrice - 1) * 0.55,
          );
    final priceFairness = (1 - pricePressure).clamp(0.05, 1).toDouble();
    final intensity = product.monetizationIntensity.clamp(0.1, 1.0).toDouble();
    final freeTier = product.freeTierPercent.clamp(0, 0.9).toDouble();
    final monetizationComfort = switch (product.monetization) {
      MonetizationModel.free => 1.0,
      MonetizationModel.subscription =>
        (1 - intensity * 0.18 - pricePressure * 0.45 + freeTier * 0.20).clamp(
          0.05,
          1,
        ),
      MonetizationModel.usageBased =>
        (1 - intensity * 0.14 - pricePressure * 0.30 + freeTier * 0.14).clamp(
          0.05,
          1,
        ),
      MonetizationModel.advertising => (1 - intensity * 0.62).clamp(0.05, 1),
      MonetizationModel.transactionFee =>
        (1 - intensity * 0.24 - pricePressure * 0.30).clamp(0.05, 1),
    }.toDouble();
    final stalenessPenalty = productStalenessPenalty(product);
    final bugPenalty = productBugPenalty(product);
    return ((qualityScore * 0.28 +
                reliabilityScore * 0.18 +
                speedScore * 0.12 +
                featureScore * 0.12 +
                securityScore * 0.10 +
                priceFairness * 0.10 +
                monetizationComfort * 0.10 -
                stalenessPenalty * 0.12 -
                bugPenalty * 0.10) *
            100)
        .clamp(0, 100)
        .toDouble();
  }

  double productPaidConversionRate(Product product) {
    final satisfaction = productUserSatisfaction(product) / 100;
    final trust = product.brandTrust.clamp(0, 1).toDouble();
    final intensity = product.monetizationIntensity.clamp(0.1, 1.0).toDouble();
    final blueprint = GameCatalog.blueprintById(product.blueprintId);
    final basePrice = math.max(1.0, blueprint.basePrice).toDouble();
    final pricePressure =
        product.monetization == MonetizationModel.transactionFee
        ? (math.max(0, product.price - 1.5) / 8).clamp(0, 1).toDouble()
        : math
              .max(
                currentPriceSentiment(product),
                math.max(0, product.price / basePrice - 1) * 0.60,
              )
              .clamp(0, 1)
              .toDouble();
    final freeTier = product.freeTierPercent.clamp(0, 0.9).toDouble();
    return switch (product.monetization) {
      MonetizationModel.free => 0.0,
      MonetizationModel.subscription =>
        (0.018 +
                satisfaction * 0.065 +
                trust * 0.035 +
                intensity * 0.055 -
                freeTier * 0.045 -
                pricePressure * 0.085)
            .clamp(0.003, 0.24)
            .toDouble(),
      MonetizationModel.usageBased =>
        (0.030 +
                satisfaction * 0.080 +
                trust * 0.030 +
                intensity * 0.050 -
                freeTier * 0.035 -
                pricePressure * 0.060)
            .clamp(0.006, 0.30)
            .toDouble(),
      MonetizationModel.advertising => 0.0,
      MonetizationModel.transactionFee =>
        (0.14 +
                satisfaction * 0.20 +
                trust * 0.16 +
                intensity * 0.040 -
                pricePressure * 0.15)
            .clamp(0.03, 0.62)
            .toDouble(),
    };
  }

  int productPayingUsers(Product product) =>
      (product.mau * productPaidConversionRate(product)).round();

  double productMonetizationRevenueEstimate(
    Product product, {
    int? mauOverride,
  }) {
    final mau = math.max(0, mauOverride ?? product.mau).toInt();
    if (mau <= 0) {
      return 0;
    }
    final satisfaction = productUserSatisfaction(product) / 100;
    final intensity = product.monetizationIntensity.clamp(0.1, 1.0).toDouble();
    final payingUsers = (mau * productPaidConversionRate(product)).round();
    final base = switch (product.monetization) {
      MonetizationModel.free => 0.0,
      MonetizationModel.subscription => payingUsers * product.price,
      MonetizationModel.usageBased =>
        payingUsers * product.price * (0.75 + intensity * 1.45),
      MonetizationModel.advertising =>
        mau *
            (7 + satisfaction * 12) *
            (0.4 + intensity * 3.6) *
            (55 + product.price * 35) /
            1000,
      MonetizationModel.transactionFee =>
        payingUsers * (3.0 + satisfaction * 5.0) * math.max(0.1, product.price),
    };
    return base *
        product.reliability.clamp(0.5, 1).toDouble() *
        (1 + ecosystemBoostFor(product.id) * 0.55);
  }

  double productArpu(Product product) =>
      product.mau <= 0 ? 0 : product.monthlyRevenue / product.mau;

  double productPaidAcquisitionInterest(Product product) {
    return activeCampaignsFor(product.id).fold<double>(0, (sum, campaign) {
      final forecast = advertisingForecast(
        product: product,
        agencyId: campaign.agencyId,
        channelId: campaign.channelId,
        budget: campaign.budget,
      );
      return sum + forecast.usersExpected;
    });
  }

  double productEstimatedMonthlyStartedUsers(Product product) => math
      .max(0, product.monthlyGrowth + product.users * product.churnRate)
      .toDouble();

  double productEstimatedMonthlyInterest(Product product) {
    final started = productEstimatedMonthlyStartedUsers(product);
    return started / math.max(0.05, product.activationRate);
  }

  double productOrganicAcquisitionShare(Product product) {
    final total = productEstimatedMonthlyInterest(product);
    if (total <= 0) {
      return 1;
    }
    return (1 - productPaidAcquisitionInterest(product) / total)
        .clamp(0, 1)
        .toDouble();
  }

  double productCac(Product product) {
    final monthlySpend = activeCampaignsFor(
      product.id,
    ).fold<double>(0, (sum, campaign) => sum + campaign.budget);
    if (monthlySpend <= 0) {
      return 0;
    }
    final totalInterest = productEstimatedMonthlyInterest(product);
    final paidInterest = productPaidAcquisitionInterest(product);
    if (totalInterest <= 0 || paidInterest <= 0) {
      return 0;
    }
    final paidStarted =
        productEstimatedMonthlyStartedUsers(product) *
        (paidInterest / totalInterest).clamp(0, 1);
    return paidStarted <= 0 ? 0 : monthlySpend / paidStarted;
  }

  double businessLoanRequestRatio(double requestedAmount) =>
      requestedAmount / math.max(500000.0, valuation);

  double businessLoanApprovalChance(double requestedAmount) {
    if (requestedAmount < 50000 || activeLoan != null) {
      return 0;
    }
    final hasProof =
        products.isNotEmpty ||
        activeContracts.isNotEmpty ||
        completedContracts.isNotEmpty;
    if (!hasProof) {
      return 0;
    }
    final ratio = businessLoanRequestRatio(requestedAmount);
    final recurringRevenue =
        monthlyProductRevenue + monthlyWorldProjectRevenue + portfolioIncome;
    final burnRatio =
        monthlyCosts / math.max(250000.0, recurringRevenue + 250000);
    final riskyProducts = products
        .where((product) => productSecurityRisk(product) > 0.72)
        .length;
    final economicBonus = math
        .min(0.08, recurringRevenue / math.max(500000.0, valuation) * 1.5)
        .toDouble();
    return (0.94 +
            economicBonus -
            ratio * 1.35 -
            math.max(0, burnRatio - 1) * 0.08 -
            riskyProducts * 0.07)
        .clamp(0.02, 0.97)
        .toDouble();
  }

  double businessLoanInterestRate(double requestedAmount) {
    final ratio = businessLoanRequestRatio(requestedAmount);
    final riskyProducts = products
        .where((product) => productSecurityRisk(product) > 0.72)
        .length;
    final recurringRevenue =
        monthlyProductRevenue + monthlyWorldProjectRevenue + portfolioIncome;
    final burnRatio =
        monthlyCosts / math.max(250000.0, recurringRevenue + 250000);
    return (0.08 +
            ratio * 0.14 +
            riskyProducts * 0.015 +
            math.max(0, burnRatio - 1) * 0.012)
        .clamp(0.08, 0.28)
        .toDouble();
  }

  MonetizationExperienceImpact monetizationExperienceImpact(Product product) {
    final intensity = product.monetizationIntensity.clamp(0.1, 1.0).toDouble();
    final blueprint = GameCatalog.blueprintById(product.blueprintId);
    final basePrice = math.max(1.0, blueprint.basePrice).toDouble();
    final absolutePricePressure =
        math.max(0, product.price / basePrice - 1) * 0.22;
    final pricePressure = math
        .max(currentPriceSentiment(product), absolutePricePressure)
        .clamp(-0.25, 0.85)
        .toDouble();
    final freeTier = product.freeTierPercent.clamp(0, 0.9).toDouble();
    final activationDelta = switch (product.monetization) {
      MonetizationModel.free => 0.025,
      MonetizationModel.subscription =>
        -(0.025 + intensity * 0.055 + pricePressure * 0.16 - freeTier * 0.035),
      MonetizationModel.usageBased =>
        -(0.012 + intensity * 0.038 + pricePressure * 0.11 - freeTier * 0.025),
      MonetizationModel.advertising => -(intensity * 0.030),
      MonetizationModel.transactionFee =>
        -(0.010 + intensity * 0.045 + pricePressure * 0.10),
    };
    final retentionDelta = switch (product.monetization) {
      MonetizationModel.free => 0.012,
      MonetizationModel.subscription =>
        -(intensity * 0.045 + pricePressure * 0.10) + freeTier * 0.028,
      MonetizationModel.usageBased =>
        -(intensity * 0.025 + pricePressure * 0.06) + freeTier * 0.020,
      MonetizationModel.advertising => -(intensity * 0.090),
      MonetizationModel.transactionFee =>
        -(intensity * 0.035 + pricePressure * 0.05),
    };
    final churnDelta = switch (product.monetization) {
      MonetizationModel.free => -0.006,
      MonetizationModel.subscription =>
        intensity * 0.038 + pricePressure * 0.10 - freeTier * 0.020,
      MonetizationModel.usageBased =>
        intensity * 0.023 + pricePressure * 0.065 - freeTier * 0.014,
      MonetizationModel.advertising => intensity * 0.070,
      MonetizationModel.transactionFee =>
        intensity * 0.032 + pricePressure * 0.055,
    };
    final trustDelta = switch (product.monetization) {
      MonetizationModel.free => 0.004,
      MonetizationModel.subscription =>
        -(intensity * 0.012 + pricePressure * 0.025),
      MonetizationModel.usageBased =>
        -(intensity * 0.008 + pricePressure * 0.018),
      MonetizationModel.advertising => -(intensity * 0.020),
      MonetizationModel.transactionFee =>
        -(intensity * 0.012 + pricePressure * 0.018),
    };
    return MonetizationExperienceImpact(
      activationDelta: activationDelta.clamp(-0.25, 0.08).toDouble(),
      retentionDelta: retentionDelta.clamp(-0.20, 0.05).toDouble(),
      churnDelta: churnDelta.clamp(-0.03, 0.22).toDouble(),
      trustDelta: trustDelta.clamp(-0.06, 0.02).toDouble(),
    );
  }

  double currentPriceSentiment(Product product) {
    final latest = latestPriceChangeFor(product.id);
    if (latest == null) {
      return product.priceSentiment;
    }
    final elapsedDays =
        math.max(0, simulationMinutes - latest.changedAtMinutes) / 1440;
    final decay = (1 - elapsedDays / 45).clamp(0, 1).toDouble();
    return latest.initialSentimentShock * decay;
  }

  PriceImpactForecast priceImpactForecast(Product product, double newPrice) {
    final currentPrice = math.max(1, product.price).toDouble();
    final normalized = math.max(1, newPrice).toDouble();
    final changeRatio = normalized / currentPrice - 1;
    final trustProtection = (0.35 + product.brandTrust * 0.65)
        .clamp(0.25, 1.0)
        .toDouble();
    final userChange = changeRatio >= 0
        ? -changeRatio * (0.42 / trustProtection)
        : -changeRatio * (0.20 + product.brandAwareness * 0.18);
    final churnDelta = changeRatio >= 0
        ? changeRatio * (0.11 / trustProtection)
        : changeRatio * 0.035;
    final expectedUsers = math.max(
      0,
      product.mau * (1 + userChange.clamp(-0.72, 0.35)),
    );
    final before = product.mau * currentPrice * 0.092;
    final after = expectedUsers * normalized * 0.092;
    final shock = changeRatio >= 0
        ? (changeRatio * (1.15 - product.brandTrust)).clamp(0, 0.85)
        : (changeRatio * 0.25).clamp(-0.25, 0);
    return PriceImpactForecast(
      currentPrice: currentPrice,
      proposedPrice: normalized,
      expectedRevenueBefore: before,
      expectedRevenueAfter: after,
      expectedUserChangePercent: userChange.clamp(-0.72, 0.35).toDouble(),
      expectedChurnDelta: churnDelta.clamp(-0.05, 0.18).toDouble(),
      sentimentShock: shock.toDouble(),
      note:
          'Это прогноз, а не гарантия. Через 45 игровых дней ценовой шок постепенно сходит на нет.',
    );
  }

  AdvertisingForecast advertisingForecast({
    required Product product,
    required String agencyId,
    required String channelId,
    required double budget,
  }) {
    final agency = ProductStrategyCatalog.agencyById(agencyId);
    final channel = ProductStrategyCatalog.channelById(channelId);
    final effectiveBudget = budget / (1 + agency.feePercent);
    final categoryFit = channel.bestForCategories.contains(product.category)
        ? 1.0
        : 0.72;
    final impressions = channel.billingModel == AdvertisingBillingModel.cpc
        ? (effectiveBudget / math.max(1, channel.baseCpc) * 18).round()
        : (effectiveBudget / math.max(1, channel.baseCpm) * 1000).round();
    final clicks = channel.billingModel == AdvertisingBillingModel.cpm
        ? (impressions * (0.006 + agency.quality * 0.008)).round()
        : (effectiveBudget / math.max(1, channel.baseCpc)).round();
    final maturity =
        (0.55 + product.brandAwareness * 0.28 + product.brandTrust * 0.17)
            .clamp(0.50, 1.0)
            .toDouble();
    final qualityFactor =
        (0.45 +
                product.qualityScore / 100 * 0.32 +
                productUserSatisfaction(product) / 100 * 0.10 +
                product.reliability * 0.13)
            .clamp(0.48, 1.0)
            .toDouble();
    final founderGrowthMultiplier = companyProfile.growthEfficiencyMultiplier;
    final marketAccessMultiplier = (headquartersCity.marketAccessScore / 76)
        .clamp(0.82, 1.22)
        .toDouble();
    final channelConversion = switch (channel.id) {
      'search_ads' => 0.38,
      'social_feed' => 0.12,
      'creator_reviews' => 0.22,
      'b2b_outreach' => 0.09,
      'short_video' => 0.10,
      'newsletters' => 0.19,
      'developer_communities' => 0.24,
      'affiliate_partners' => 0.16,
      _ => 0.14,
    };
    final agencyMultiplier = (0.60 + agency.quality * 0.65)
        .clamp(0.75, 1.35)
        .toDouble();
    final conversion =
        channelConversion *
        agencyMultiplier *
        maturity *
        qualityFactor *
        categoryFit *
        founderGrowthMultiplier *
        marketAccessMultiplier;
    // Forecast is qualified top-of-funnel interest. The market simulation
    // decides how many people actually start using the product and remain.
    final expected = (clicks * conversion * 2.4).round();
    final spread = (1 - agency.forecastAccuracy) * 0.75 + 0.18;
    return AdvertisingForecast(
      impressions: math.max(0, impressions),
      clicks: math.max(0, clicks),
      usersLow: math.max(0, (expected * (1 - spread)).round()),
      usersExpected: math.max(0, expected),
      usersHigh: math.max(0, (expected * (1 + spread)).round()),
      effectiveBudget: effectiveBudget,
      note:
          'Прогноз показывает заинтересованных людей, а не готовых пользователей. Финальный результат зависит от того, сколько из них реально начнут пользоваться продуктом и останутся.',
    );
  }

  double get monthlyLoanPayment =>
      activeLoan == null ? 0 : activeLoan!.weeklyPayment * (43200 / (7 * 1440));

  double get monthlyPayroll =>
      employees.fold<double>(0, (sum, item) => sum + item.salary);

  double get monthlyHardwareCost {
    final base = usingOwnedInfrastructure
        ? installedServers.fold<double>(0, (sum, item) {
            final hardware = GameCatalog.serverHardwareById(item.hardwareId);
            return sum + hardware.monthlyCost * item.count;
          })
        : hostingPlan.monthlyCost;

    final dedicatedHostingRoutes = productServiceRoutes
        .where((item) => item.dataCenterSiteId.startsWith('hosting:'))
        .map((item) => item.dataCenterSiteId)
        .toSet();
    final dedicatedHostingCost = dedicatedHostingRoutes.fold<double>(0, (
      sum,
      route,
    ) {
      final parts = route.split(':');
      if (parts.length < 2) return sum;
      try {
        return sum + V9ContentCatalog.hostingById(parts[1]).monthlyCost;
      } on Object {
        return sum;
      }
    });
    return (base + dedicatedHostingCost) * companyProfile.officeRentMultiplier;
  }

  double get monthlyServerRoomCost {
    final headquartersFacilityMultiplier =
        (headquartersCity.rentMultiplier + headquartersCity.utilityMultiplier) /
        2;
    final rented = usingOwnedInfrastructure
        ? serverRoom.monthlyRent * headquartersFacilityMultiplier
        : 0.0;
    return (rented + ownedDataCenterMonthlyCost) *
        companyProfile.officeRentMultiplier;
  }

  double get monthlyOfficeCost =>
      (office.monthlyRent * headquartersCity.rentMultiplier +
          ownedOfficeMonthlyCost) *
      companyProfile.officeRentMultiplier;

  double get regulatoryComplianceMultiplier =>
      (1 + (58 - headquartersCity.regulationScore) / 250)
          .clamp(0.82, 1.12)
          .toDouble();

  double get monthlyRegulatoryComplianceCost {
    if (!companyProfile.configured) {
      return 0;
    }
    final regulatedProducts = products
        .where((item) => item.stage == ProductStage.live)
        .length;
    return regulatedProducts * 18000 * regulatoryComplianceMultiplier;
  }

  double get monthlyProductRevenue {
    final base = products.fold<double>(
      0,
      (sum, item) => sum + item.monthlyRevenue,
    );
    final doctrineMultiplier = switch (ecosystemDoctrine) {
      EcosystemDoctrine.balanced => 1.0,
      EcosystemDoctrine.open => 0.96,
      EcosystemDoctrine.dominant => 1.08,
    };
    return base * doctrineMultiplier;
  }

  double get investorPayouts => investorAgreements.fold<double>(0, (sum, item) {
    final product = productById(item.productId);
    if (product == null || product.stage != ProductStage.live) {
      return sum;
    }
    return sum + product.monthlyRevenue * item.revenueSharePercent / 100;
  });

  double get portfolioIncome => portfolioHoldings.fold<double>(0, (sum, item) {
    final company = GameCatalog.marketCompanyById(item.companyId);
    return sum + company.monthlyProfit * item.ownershipPercent / 100;
  });

  double get monthlySecurityCost => securityControls.fold<double>(
    0,
    (sum, item) =>
        sum + OperationsCatalog.securityControlById(item.controlId).monthlyCost,
  );

  double get monthlyAdvertisingSpend => advertisingCampaigns
      .where((item) => item.status == AdvertisingCampaignStatus.active)
      .fold<double>(0, (sum, item) => sum + item.budget);

  /// Variable support, observability, third-party API and operations pressure.
  /// A hit product is valuable, but it is not free to operate at scale.
  double get monthlyScaleOperationsCost {
    final raw = products
        .where((item) => item.stage == ProductStage.live)
        .fold<double>(0, (sum, product) {
          final perMau = switch (product.category) {
            ProductCategory.aiAssistant => 16.0,
            ProductCategory.cloud => 8.5,
            ProductCategory.saas => 3.6,
            ProductCategory.browser => 0.75,
            ProductCategory.cryptoWallet => 2.8,
            ProductCategory.developerTool => 4.4,
          };
          final maturityPressure =
              (1 + math.max(0, product.mau - 500000) / 5000000)
                  .clamp(1.0, 1.35)
                  .toDouble();
          return sum + product.mau * perMau * maturityPressure;
        });
    return raw * (worldProjectCompleted('planet_compute') ? 0.78 : 1.0);
  }

  double companyPerkActivationCost(String perkId) =>
      V17EndgameCatalog.perkById(perkId).upfrontCost * employees.length;

  double companyPerkMonthlyCost(String perkId) =>
      V17EndgameCatalog.perkById(perkId).monthlyCost * employees.length;

  double get monthlyCompanyPerkCost => enabledCompanyPerkIds.fold<double>(
    0,
    (sum, id) => sum + companyPerkMonthlyCost(id),
  );

  int get companyPerkLoyaltyBonus => enabledCompanyPerkIds.fold<int>(
    0,
    (sum, id) => sum + V17EndgameCatalog.perkById(id).loyaltyBonus,
  );

  int get companyPerkMoraleBonus => enabledCompanyPerkIds.fold<int>(
    0,
    (sum, id) => sum + V17EndgameCatalog.perkById(id).moraleBonus,
  );

  double get monthlyWorldProjectOperatingCost => worldProjects.fold<double>(
    0,
    (sum, progress) => worldProjectBaseCompleted(progress.projectId)
        ? sum +
              V17EndgameCatalog.worldProjectById(
                progress.projectId,
              ).monthlyOperatingCost
        : sum,
  );

  double get monthlyWorldProjectRevenue => worldProjects.fold<double>(
    0,
    (sum, progress) => worldProjectBaseCompleted(progress.projectId)
        ? sum +
              V17EndgameCatalog.worldProjectById(
                progress.projectId,
              ).monthlyRevenue
        : sum,
  );

  double get brandDemandMultiplier {
    final doctrine = switch (ecosystemDoctrine) {
      EcosystemDoctrine.balanced => 0.0,
      EcosystemDoctrine.open => 0.07,
      EcosystemDoctrine.dominant => -0.035,
    };
    final worldBonus =
        (worldProjectCompleted('world_os') ? 0.06 : 0.0) +
        (worldProjectCompleted('free_ai') ? 0.08 : 0.0);
    return (0.86 +
            brandReputation.clamp(0, 100) / 250 +
            math.min(0.12, math.log(companyFans + 1) / 120) +
            doctrine +
            worldBonus)
        .clamp(0.82, 1.48)
        .toDouble();
  }

  double get monthlyCosts =>
      monthlyPayroll +
      monthlyCompanyPerkCost +
      monthlyWorldProjectOperatingCost +
      monthlyOfficeCost +
      monthlyServerRoomCost +
      monthlyHardwareCost +
      monthlySecurityCost +
      monthlyRegulatoryComplianceCost +
      monthlyCorporateAiCost +
      monthlyAdvertisingSpend +
      monthlyScaleOperationsCost +
      products.fold<double>(
        0,
        (sum, item) =>
            sum + item.monthlyCost + productImprovementMonthlyCost(item.id),
      ) +
      investorPayouts +
      monthlyLoanPayment;

  double get monthlyProfit =>
      monthlyProductRevenue +
      monthlyWorldProjectRevenue +
      portfolioIncome -
      monthlyCosts;

  double get runwayMonths {
    if (monthlyProfit >= 0) {
      return 99;
    }
    return cash / monthlyProfit.abs();
  }

  double get valuation {
    final recurring = (monthlyProductRevenue + monthlyWorldProjectRevenue) * 24;
    final usersValue = products.fold<double>(
      0,
      (sum, item) => sum + item.mau * 38,
    );
    final technology = products.fold<double>(
      0,
      (sum, item) => sum + item.qualityScore * 11000,
    );
    final ecosystem = ecosystemLinks.length * 180000;
    final profitPremium = math.max(0, monthlyProfit) * 18;
    final brandValue = companyFans * 24 + brandReputation * 2500000;
    final researchValue = completedResearchKeys.length * 1800000;
    return math
        .max(
          500000,
          recurring +
              usersValue +
              technology +
              ecosystem +
              profitPremium +
              brandValue +
              researchValue,
        )
        .toDouble();
  }

  double get founderPortfolioValue => valuation * founderOwnershipPercent / 100;

  int get requiredReleasedBlueprintsForLegacy => 0;

  int get releasedBlueprintCount {
    final catalogIds = GameCatalog.productBlueprints
        .map((item) => item.id)
        .toSet();
    return products
        .where(
          (product) =>
              product.stage == ProductStage.live &&
              !product.acquired &&
              catalogIds.contains(product.blueprintId),
        )
        .map((product) => product.blueprintId)
        .toSet()
        .length;
  }

  double get legacyProductProgress => worldProjectCompletionProgress;
  bool get legacyProductRequirementMet => founderLegacyCompleted;

  bool marketCompanyFullyAcquired(String companyId) =>
      fullyAcquiredCompanyIds.contains(companyId);

  int get acquiredRivalCount => GameCatalog.marketCompanies
      .where((company) => marketCompanyFullyAcquired(company.id))
      .length;

  int get remainingRivalCount => math
      .max(0, GameCatalog.marketCompanies.length - acquiredRivalCount)
      .toInt();

  WorldProjectProgress? worldProjectProgressFor(String projectId) {
    for (final item in worldProjects) {
      if (item.projectId == projectId) {
        return item;
      }
    }
    return null;
  }

  String worldProjectDisplayName(String projectId) {
    final customName =
        worldProjectProgressFor(projectId)?.customName.trim() ?? '';
    return customName.isEmpty
        ? V17EndgameCatalog.worldProjectById(projectId).name
        : customName;
  }

  bool worldProjectBaseCompleted(String projectId) {
    final progress = worldProjectProgressFor(projectId);
    final definition = V17EndgameCatalog.worldProjectById(projectId);
    return progress != null &&
        progress.completedPhases >= definition.phaseCosts.length;
  }

  bool worldProjectCompleted(String projectId) {
    final progress = worldProjectProgressFor(projectId);
    final definition = V17EndgameCatalog.worldProjectById(projectId);
    return worldProjectBaseCompleted(projectId) &&
        progress != null &&
        progress.completedUpgradeIds.length >= definition.requiredUpgradeCount;
  }

  double get worldProjectCompletionProgress {
    var sum = 0.0;
    for (final definition in V17EndgameCatalog.worldProjects) {
      final progress = worldProjectProgressFor(definition.id);
      if (progress == null) {
        continue;
      }
      final phaseProgress =
          progress.completedPhases / math.max(1, definition.phaseCosts.length);
      final upgradeProgress =
          progress.completedUpgradeIds.length /
          math.max(1, definition.requiredUpgradeCount);
      sum += (phaseProgress * 0.72 + math.min(1, upgradeProgress) * 0.28).clamp(
        0,
        1,
      );
    }
    return (sum / V17EndgameCatalog.worldProjects.length)
        .clamp(0, 1)
        .toDouble();
  }

  bool get founderLegacyCompleted =>
      !gameOver &&
      V17EndgameCatalog.worldProjects.every(
        (item) => worldProjectCompleted(item.id),
      );

  int get unreadCompanyNotificationCount =>
      companyNotifications.where((item) => !item.read).length;

  CompanyResearchProject? activeResearchFor(String key) {
    for (final item in activeResearchProjects) {
      if (item.key == key) {
        return item;
      }
    }
    return null;
  }

  String researchKey(ResearchTargetKind kind, String targetId) =>
      '${kind.name}:$targetId';

  bool researchCompleted(ResearchTargetKind kind, String targetId) {
    if (kind == ResearchTargetKind.technology &&
        const <String>{
          'postgresql',
          'observability_stack',
        }.contains(targetId)) {
      return true;
    }
    return completedResearchKeys.contains(researchKey(kind, targetId));
  }

  int featureResearchTier(String targetId) {
    final cost = GameCatalog.featureById(targetId).developmentCost;
    if (cost <= 50000) {
      return 0;
    }
    if (cost <= 90000) {
      return 1;
    }
    if (cost <= 140000) {
      return 2;
    }
    if (cost <= 220000) {
      return 3;
    }
    return 4;
  }

  List<String> researchPrerequisiteKeys(
    ResearchTargetKind kind,
    String targetId,
  ) {
    if (kind == ResearchTargetKind.technology) {
      final parent = switch (targetId) {
        'redis' => 'postgresql',
        'cdn' || 'vector_db' => 'redis',
        'kubernetes' => 'observability_stack',
        'e2ee' => 'observability_stack',
        'hsm' => 'e2ee',
        _ => '',
      };
      return parent.isEmpty
          ? const <String>[]
          : <String>[researchKey(ResearchTargetKind.technology, parent)];
    }
    final target = GameCatalog.featureById(targetId);
    final tier = featureResearchTier(targetId);
    if (tier <= 0) {
      return const <String>[];
    }
    final categories = target.supportedCategories.toSet();
    final candidates =
        GameCatalog.features
            .where(
              (item) =>
                  item.id != targetId &&
                  item.supportedCategories.any(categories.contains) &&
                  featureResearchTier(item.id) == tier - 1,
            )
            .toList(growable: true)
          ..sort((a, b) {
            final byCost = a.developmentCost.compareTo(b.developmentCost);
            return byCost != 0 ? byCost : a.id.compareTo(b.id);
          });
    if (candidates.isNotEmpty) {
      return <String>[
        researchKey(ResearchTargetKind.feature, candidates.last.id),
      ];
    }
    final fallback =
        GameCatalog.features
            .where(
              (item) =>
                  item.id != targetId &&
                  item.supportedCategories.any(categories.contains) &&
                  featureResearchTier(item.id) < tier,
            )
            .toList(growable: true)
          ..sort((a, b) {
            final byTier = featureResearchTier(
              a.id,
            ).compareTo(featureResearchTier(b.id));
            if (byTier != 0) {
              return byTier;
            }
            final byCost = a.developmentCost.compareTo(b.developmentCost);
            return byCost != 0 ? byCost : a.id.compareTo(b.id);
          });
    return fallback.isEmpty
        ? const <String>[]
        : <String>[researchKey(ResearchTargetKind.feature, fallback.last.id)];
  }

  int researchDepth(ResearchTargetKind kind, String targetId) {
    if (kind == ResearchTargetKind.feature) {
      return featureResearchTier(targetId);
    }
    return switch (targetId) {
      'postgresql' || 'observability_stack' => 0,
      'redis' || 'kubernetes' || 'e2ee' => 1,
      'cdn' || 'vector_db' || 'hsm' => 2,
      _ => 1,
    };
  }

  bool researchPrerequisitesMet(ResearchTargetKind kind, String targetId) =>
      researchPrerequisiteKeys(kind, targetId).every(
        (key) =>
            completedResearchKeys.contains(key) ||
            key == 'technology:postgresql' ||
            key == 'technology:observability_stack',
      );

  List<String> researchPrerequisiteNames(
    ResearchTargetKind kind,
    String targetId,
  ) {
    return researchPrerequisiteKeys(kind, targetId)
        .map((key) {
          final separator = key.indexOf(':');
          final id = separator < 0 ? key : key.substring(separator + 1);
          return key.startsWith('technology:')
              ? GameCatalog.technologyById(id).name
              : GameCatalog.featureById(id).name;
        })
        .toList(growable: false);
  }

  double researchCost(ResearchTargetKind kind, String targetId) {
    if (researchCompleted(kind, targetId)) {
      return 0;
    }
    final depth = researchDepth(kind, targetId);
    if (kind == ResearchTargetKind.technology) {
      final developmentCost = GameCatalog.technologyById(
        targetId,
      ).developmentCost;
      final base = switch (depth) {
        0 => 180000.0,
        1 => 450000.0,
        2 => 1200000.0,
        _ => 2800000.0,
      };
      final multiplier = 3.5 + depth * 2.0;
      return (base + developmentCost * multiplier).toDouble();
    }
    final developmentCost = GameCatalog.featureById(targetId).developmentCost;
    final base = switch (depth) {
      0 => 80000.0,
      1 => 220000.0,
      2 => 500000.0,
      3 => 1100000.0,
      _ => 2500000.0,
    };
    final multiplier = 3.5 + depth * 1.5;
    return (base + developmentCost * multiplier).toDouble();
  }

  int researchDays(ResearchTargetKind kind, String targetId) {
    if (researchCompleted(kind, targetId)) {
      return 0;
    }
    final depth = researchDepth(kind, targetId);
    final cost = researchCost(kind, targetId);
    final costScale = (math.log(cost / 150000 + 1) / math.ln2).round();
    final base = kind == ResearchTargetKind.feature
        ? 4 + depth * 5
        : 6 + depth * 7;
    return (base + costScale).clamp(4, 45).toInt();
  }

  PendingEmployeeDeparture? pendingDepartureFor(String employeeId) {
    for (final item in pendingEmployeeDepartures) {
      if (item.employeeId == employeeId) {
        return item;
      }
    }
    return null;
  }

  LegendMarketOffer? legendOfferFor(String legendId) {
    for (final item in legendMarketOffers) {
      if (item.legendId == legendId) {
        return item;
      }
    }
    return null;
  }

  HiredLegendBonus? legendBonusForProduct(String productId) {
    for (final item in hiredLegendBonuses) {
      if (item.productId == productId &&
          employeeById(item.employeeId) != null) {
        return item;
      }
    }
    return null;
  }

  double legendProductMetricBonus(
    String productId,
    LegendProductBonusKind kind,
  ) {
    return hiredLegendBonuses
        .where(
          (item) =>
              item.productId == productId &&
              item.bonusKind == kind &&
              employeeById(item.employeeId) != null,
        )
        .fold<double>(0, (sum, _) => sum + 1);
  }

  bool hasLegendRequirement(String legendId) {
    final legend = V17EndgameCatalog.legendById(legendId);
    if (releasedBlueprintCount < legend.requiredReleasedProducts ||
        valuation < legend.requiredValuation) {
      return false;
    }
    if (legend.requiredOfficeQuality == null) {
      return true;
    }
    return ownedOffices.any((office) {
      if (legend.requiredOfficeCityId.isNotEmpty &&
          office.cityId != legend.requiredOfficeCityId) {
        return false;
      }
      return office.fitoutQuality.index >=
              legend.requiredOfficeQuality!.index &&
          office.equipmentQuality.index >= legend.requiredOfficeQuality!.index;
    });
  }

  double get companyLegacyScore =>
      brandReputation * 12 +
      math.log(companyFans + 1) * 90 +
      completedResearchKeys.length * 8 +
      philanthropySpent / 10000000 +
      worldProjectCompletionProgress * 2000;

  List<ProductMetricPoint> metricHistoryFor(String productId) =>
      _index.metricHistoryByProduct[productId] ?? const <ProductMetricPoint>[];

  ProductMonetizationChange? latestMonetizationChange(String productId) {
    ProductMonetizationChange? latest;
    for (final change in monetizationChanges) {
      if (change.productId == productId &&
          (latest == null ||
              change.changedAtMinutes > latest.changedAtMinutes)) {
        latest = change;
      }
    }
    return latest;
  }

  int monetizationCooldownRemainingDays(String productId) {
    final product = productById(productId);
    if (product == null || product.stage != ProductStage.live) {
      return 0;
    }
    final latest = latestMonetizationChange(productId);
    if (latest == null) {
      return 0;
    }
    final elapsed = simulationMinutes - latest.changedAtMinutes;
    final remaining = 30 * 1440 - elapsed;
    return remaining <= 0 ? 0 : (remaining / 1440).ceil();
  }

  bool canChangeMonetization(String productId) =>
      monetizationCooldownRemainingDays(productId) == 0;

  RevenueForecast revenueForecastFor(
    Product product, {
    MonetizationModel? model,
  }) {
    final selectedModel = model ?? product.monetization;
    final assumedMau = product.stage == ProductStage.live
        ? math.max(1, product.mau)
        : 2500;
    final preview = selectedModel == product.monetization
        ? product
        : product.copyWith(monetization: selectedModel);
    final expected = productMonetizationRevenueEstimate(
      preview,
      mauOverride: assumedMau,
    );
    return RevenueForecast(
      low: expected * 0.82,
      expected: expected,
      high: expected * 1.18,
      assumedMau: assumedMau,
      note:
          'Прогноз использует ту же модель, что и симуляция: MAU, удовлетворённость, доверие, цену, интенсивность монетизации, reliability и экосистему.',
    );
  }

  int get successfulProducts => products
      .where(
        (item) =>
            item.stage == ProductStage.live &&
            item.rating >= 4.0 &&
            item.users >= 10000,
      )
      .length;

  bool hasLink(String firstProductId, String secondProductId) {
    if (firstProductId == secondProductId) {
      return false;
    }
    final key = EcosystemLink(firstProductId, secondProductId).key;
    return ecosystemLinks.any((link) => link.key == key);
  }

  List<String> connectedProductIds(String productId) => ecosystemLinks
      .where((link) => link.contains(productId))
      .map((link) => link.other(productId))
      .toList(growable: false);

  double ecosystemBoostFor(String productId) {
    final source = productById(productId);
    if (source == null) {
      return 0;
    }
    var boost = 0.0;
    for (final link in ecosystemLinks) {
      if (!link.contains(productId) ||
          simulationMinutes < link.activeAtMinutes) {
        continue;
      }
      final other = productById(link.other(productId));
      if (other == null) {
        continue;
      }
      boost += V9ContentCatalog.integrationFor(
        source.category.name,
        other.category.name,
      ).growthBoost;
    }
    return math.min(0.24, boost).toDouble();
  }

  GameState copyWith({
    int? snapshotVersion,
    int? simulationMinutes,
    GameSpeed? speed,
    bool? paused,
    double? cash,
    FounderCompanyProfile? companyProfile,
    String? headquartersCityId,
    List<OwnedOfficeSite>? ownedOffices,
    List<OwnedDataCenterSite>? ownedDataCenters,
    List<EmployeeTrainingAssignment>? employeeTrainings,
    List<EmployeeGradeUpgrade>? employeeGradeUpgrades,
    List<EmployeeRelocationAssignment>? employeeRelocations,
    List<ProductServiceRoute>? productServiceRoutes,
    List<CompanyResearchProject>? activeResearchProjects,
    List<String>? completedResearchKeys,
    List<String>? enabledCompanyPerkIds,
    List<LegendMarketOffer>? legendMarketOffers,
    List<HiredLegendBonus>? hiredLegendBonuses,
    List<PendingEmployeeDeparture>? pendingEmployeeDepartures,
    int? companyFans,
    double? brandReputation,
    List<IndustryEventOpportunity>? industryEventOpportunities,
    List<BookedIndustryEvent>? bookedIndustryEvents,
    List<CompanyNotification>? companyNotifications,
    List<WorldProjectProgress>? worldProjects,
    EcosystemDoctrine? ecosystemDoctrine,
    double? philanthropySpent,
    PostGamePath? postGamePath,
    List<AnnualTaxRecord>? taxRecords,
    double? taxYearRevenueAccrued,
    double? taxYearExpensesAccrued,
    double? taxYearPayrollAccrued,
    List<Product>? products,
    List<Candidate>? candidates,
    List<Employee>? employees,
    List<EmployeeAssignment>? employeeAssignments,
    List<ProductSecurityControl>? securityControls,
    List<SecurityAuditRecord>? securityAudits,
    List<ProductAiDeployment>? productAiDeployments,
    List<ProductAiIntegration>? productAiIntegrations,
    List<ProductImprovementRecord>? productImprovements,
    List<ProductUpdateRecord>? productUpdates,
    List<ClientContract>? clientContracts,
    List<ContractEmployeeAssignment>? contractEmployeeAssignments,
    List<ProductMonetizationChange>? monetizationChanges,
    List<FinanceHistoryPoint>? financeHistory,
    List<FinanceTransaction>? financeTransactions,
    List<AdvertisingCampaign>? advertisingCampaigns,
    List<ProductPriceChange>? priceChanges,
    List<ProductFeatureDevelopment>? productFeatureDevelopments,
    List<ProductMetricPoint>? productMetricHistory,
    List<ProductCrunchPeriod>? productCrunchPeriods,
    CompanyLoan? activeLoan,
    bool clearActiveLoan = false,
    int? negativeCashSinceMinutes,
    bool clearNegativeCashSinceMinutes = false,
    bool? creditOffered,
    bool? liquidityGraceUsed,
    List<EcosystemLink>? ecosystemLinks,
    String? selectedOfficeId,
    String? selectedServerRoomId,
    String? selectedHostingPlanId,
    List<InstalledServer>? installedServers,
    List<InvestorOffer>? investorOffers,
    List<InvestorAgreement>? investorAgreements,
    double? founderOwnershipPercent,
    List<PortfolioHolding>? portfolioHoldings,
    List<String>? acquiredCompanyIds,
    List<String>? fullyAcquiredCompanyIds,
    List<NewsItem>? news,
    CriticalEventType? criticalEvent,
    String? criticalProductId,
    bool clearCriticalProductId = false,
    bool? gameOver,
    bool? miniGamesEnabled,
    bool? onboardingCompleted,
    int? rngSeed,
    int? rngCounter,
    List<String>? feed,
  }) {
    return GameState(
      snapshotVersion: snapshotVersion ?? this.snapshotVersion,
      simulationMinutes: simulationMinutes ?? this.simulationMinutes,
      speed: speed ?? this.speed,
      paused: paused ?? this.paused,
      cash: cash ?? this.cash,
      companyProfile: companyProfile ?? this.companyProfile,
      headquartersCityId: headquartersCityId ?? this.headquartersCityId,
      ownedOffices: List<OwnedOfficeSite>.unmodifiable(
        ownedOffices ?? this.ownedOffices,
      ),
      ownedDataCenters: List<OwnedDataCenterSite>.unmodifiable(
        ownedDataCenters ?? this.ownedDataCenters,
      ),
      employeeTrainings: List<EmployeeTrainingAssignment>.unmodifiable(
        employeeTrainings ?? this.employeeTrainings,
      ),
      employeeGradeUpgrades: List<EmployeeGradeUpgrade>.unmodifiable(
        employeeGradeUpgrades ?? this.employeeGradeUpgrades,
      ),
      employeeRelocations: List<EmployeeRelocationAssignment>.unmodifiable(
        employeeRelocations ?? this.employeeRelocations,
      ),
      productServiceRoutes: List<ProductServiceRoute>.unmodifiable(
        productServiceRoutes ?? this.productServiceRoutes,
      ),
      activeResearchProjects: List<CompanyResearchProject>.unmodifiable(
        activeResearchProjects ?? this.activeResearchProjects,
      ),
      completedResearchKeys: List<String>.unmodifiable(
        completedResearchKeys ?? this.completedResearchKeys,
      ),
      enabledCompanyPerkIds: List<String>.unmodifiable(
        enabledCompanyPerkIds ?? this.enabledCompanyPerkIds,
      ),
      legendMarketOffers: List<LegendMarketOffer>.unmodifiable(
        legendMarketOffers ?? this.legendMarketOffers,
      ),
      hiredLegendBonuses: List<HiredLegendBonus>.unmodifiable(
        hiredLegendBonuses ?? this.hiredLegendBonuses,
      ),
      pendingEmployeeDepartures: List<PendingEmployeeDeparture>.unmodifiable(
        pendingEmployeeDepartures ?? this.pendingEmployeeDepartures,
      ),
      companyFans: companyFans ?? this.companyFans,
      brandReputation: brandReputation ?? this.brandReputation,
      industryEventOpportunities: List<IndustryEventOpportunity>.unmodifiable(
        industryEventOpportunities ?? this.industryEventOpportunities,
      ),
      bookedIndustryEvents: List<BookedIndustryEvent>.unmodifiable(
        bookedIndustryEvents ?? this.bookedIndustryEvents,
      ),
      companyNotifications: List<CompanyNotification>.unmodifiable(
        companyNotifications ?? this.companyNotifications,
      ),
      worldProjects: List<WorldProjectProgress>.unmodifiable(
        worldProjects ?? this.worldProjects,
      ),
      ecosystemDoctrine: ecosystemDoctrine ?? this.ecosystemDoctrine,
      philanthropySpent: philanthropySpent ?? this.philanthropySpent,
      postGamePath: postGamePath ?? this.postGamePath,
      taxRecords: List<AnnualTaxRecord>.unmodifiable(
        taxRecords ?? this.taxRecords,
      ),
      taxYearRevenueAccrued:
          taxYearRevenueAccrued ?? this.taxYearRevenueAccrued,
      taxYearExpensesAccrued:
          taxYearExpensesAccrued ?? this.taxYearExpensesAccrued,
      taxYearPayrollAccrued:
          taxYearPayrollAccrued ?? this.taxYearPayrollAccrued,
      products: List<Product>.unmodifiable(products ?? this.products),
      candidates: List<Candidate>.unmodifiable(candidates ?? this.candidates),
      employees: List<Employee>.unmodifiable(employees ?? this.employees),
      employeeAssignments: List<EmployeeAssignment>.unmodifiable(
        employeeAssignments ?? this.employeeAssignments,
      ),
      securityControls: List<ProductSecurityControl>.unmodifiable(
        securityControls ?? this.securityControls,
      ),
      securityAudits: List<SecurityAuditRecord>.unmodifiable(
        securityAudits ?? this.securityAudits,
      ),
      productAiDeployments: List<ProductAiDeployment>.unmodifiable(
        productAiDeployments ?? this.productAiDeployments,
      ),
      productAiIntegrations: List<ProductAiIntegration>.unmodifiable(
        productAiIntegrations ?? this.productAiIntegrations,
      ),
      productImprovements: List<ProductImprovementRecord>.unmodifiable(
        productImprovements ?? this.productImprovements,
      ),
      productUpdates: List<ProductUpdateRecord>.unmodifiable(
        productUpdates ?? this.productUpdates,
      ),
      clientContracts: List<ClientContract>.unmodifiable(
        clientContracts ?? this.clientContracts,
      ),
      contractEmployeeAssignments:
          List<ContractEmployeeAssignment>.unmodifiable(
            contractEmployeeAssignments ?? this.contractEmployeeAssignments,
          ),
      monetizationChanges: List<ProductMonetizationChange>.unmodifiable(
        monetizationChanges ?? this.monetizationChanges,
      ),
      financeHistory: List<FinanceHistoryPoint>.unmodifiable(
        financeHistory ?? this.financeHistory,
      ),
      financeTransactions: List<FinanceTransaction>.unmodifiable(
        financeTransactions ?? this.financeTransactions,
      ),
      advertisingCampaigns: List<AdvertisingCampaign>.unmodifiable(
        advertisingCampaigns ?? this.advertisingCampaigns,
      ),
      priceChanges: List<ProductPriceChange>.unmodifiable(
        priceChanges ?? this.priceChanges,
      ),
      productFeatureDevelopments: List<ProductFeatureDevelopment>.unmodifiable(
        productFeatureDevelopments ?? this.productFeatureDevelopments,
      ),
      productMetricHistory: List<ProductMetricPoint>.unmodifiable(
        productMetricHistory ?? this.productMetricHistory,
      ),
      productCrunchPeriods: List<ProductCrunchPeriod>.unmodifiable(
        productCrunchPeriods ?? this.productCrunchPeriods,
      ),
      activeLoan: clearActiveLoan ? null : activeLoan ?? this.activeLoan,
      negativeCashSinceMinutes: clearNegativeCashSinceMinutes
          ? null
          : negativeCashSinceMinutes ?? this.negativeCashSinceMinutes,
      creditOffered: creditOffered ?? this.creditOffered,
      liquidityGraceUsed: liquidityGraceUsed ?? this.liquidityGraceUsed,
      ecosystemLinks: List<EcosystemLink>.unmodifiable(
        ecosystemLinks ?? this.ecosystemLinks,
      ),
      selectedOfficeId: selectedOfficeId ?? this.selectedOfficeId,
      selectedServerRoomId: selectedServerRoomId ?? this.selectedServerRoomId,
      selectedHostingPlanId:
          selectedHostingPlanId ?? this.selectedHostingPlanId,
      installedServers: List<InstalledServer>.unmodifiable(
        installedServers ?? this.installedServers,
      ),
      investorOffers: List<InvestorOffer>.unmodifiable(
        investorOffers ?? this.investorOffers,
      ),
      investorAgreements: List<InvestorAgreement>.unmodifiable(
        investorAgreements ?? this.investorAgreements,
      ),
      founderOwnershipPercent:
          founderOwnershipPercent ?? this.founderOwnershipPercent,
      portfolioHoldings: List<PortfolioHolding>.unmodifiable(
        portfolioHoldings ?? this.portfolioHoldings,
      ),
      acquiredCompanyIds: List<String>.unmodifiable(
        acquiredCompanyIds ?? this.acquiredCompanyIds,
      ),
      fullyAcquiredCompanyIds: List<String>.unmodifiable(
        fullyAcquiredCompanyIds ?? this.fullyAcquiredCompanyIds,
      ),
      news: List<NewsItem>.unmodifiable(news ?? this.news),
      criticalEvent: criticalEvent ?? this.criticalEvent,
      criticalProductId: clearCriticalProductId
          ? null
          : criticalProductId ?? this.criticalProductId,
      gameOver: gameOver ?? this.gameOver,
      miniGamesEnabled: miniGamesEnabled ?? this.miniGamesEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      rngSeed: rngSeed ?? this.rngSeed,
      rngCounter: rngCounter ?? this.rngCounter,
      feed: List<String>.unmodifiable(feed ?? this.feed),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'snapshotVersion': snapshotVersion,
    'simulationMinutes': simulationMinutes,
    'speed': speed.name,
    'paused': paused,
    'cash': cash,
    'companyProfile': companyProfile.toJson(),
    'headquartersCityId': headquartersCityId,
    'ownedOffices': ownedOffices.map((item) => item.toJson()).toList(),
    'ownedDataCenters': ownedDataCenters.map((item) => item.toJson()).toList(),
    'employeeTrainings': employeeTrainings
        .map((item) => item.toJson())
        .toList(),
    'employeeGradeUpgrades': employeeGradeUpgrades
        .map((item) => item.toJson())
        .toList(),
    'employeeRelocations': employeeRelocations
        .map((item) => item.toJson())
        .toList(),
    'productServiceRoutes': productServiceRoutes
        .map((item) => item.toJson())
        .toList(),
    'activeResearchProjects': activeResearchProjects
        .map((item) => item.toJson())
        .toList(),
    'completedResearchKeys': completedResearchKeys,
    'enabledCompanyPerkIds': enabledCompanyPerkIds,
    'legendMarketOffers': legendMarketOffers
        .map((item) => item.toJson())
        .toList(),
    'hiredLegendBonuses': hiredLegendBonuses
        .map((item) => item.toJson())
        .toList(),
    'pendingEmployeeDepartures': pendingEmployeeDepartures
        .map((item) => item.toJson())
        .toList(),
    'companyFans': companyFans,
    'brandReputation': brandReputation,
    'industryEventOpportunities': industryEventOpportunities
        .map((item) => item.toJson())
        .toList(),
    'bookedIndustryEvents': bookedIndustryEvents
        .map((item) => item.toJson())
        .toList(),
    'companyNotifications': companyNotifications
        .map((item) => item.toJson())
        .toList(),
    'worldProjects': worldProjects.map((item) => item.toJson()).toList(),
    'ecosystemDoctrine': ecosystemDoctrine.name,
    'philanthropySpent': philanthropySpent,
    'postGamePath': postGamePath.name,
    'taxRecords': taxRecords.map((item) => item.toJson()).toList(),
    'taxYearRevenueAccrued': taxYearRevenueAccrued,
    'taxYearExpensesAccrued': taxYearExpensesAccrued,
    'taxYearPayrollAccrued': taxYearPayrollAccrued,
    'products': products.map((item) => item.toJson()).toList(),
    'candidates': candidates.map((item) => item.toJson()).toList(),
    'employees': employees.map((item) => item.toJson()).toList(),
    'employeeAssignments': employeeAssignments
        .map((item) => item.toJson())
        .toList(),
    'securityControls': securityControls.map((item) => item.toJson()).toList(),
    'securityAudits': securityAudits.map((item) => item.toJson()).toList(),
    'productAiDeployments': productAiDeployments
        .map((item) => item.toJson())
        .toList(),
    'productAiIntegrations': productAiIntegrations
        .map((item) => item.toJson())
        .toList(),
    'productImprovements': productImprovements
        .map((item) => item.toJson())
        .toList(),
    'productUpdates': productUpdates.map((item) => item.toJson()).toList(),
    'clientContracts': clientContracts.map((item) => item.toJson()).toList(),
    'contractEmployeeAssignments': contractEmployeeAssignments
        .map((item) => item.toJson())
        .toList(),
    'monetizationChanges': monetizationChanges
        .map((item) => item.toJson())
        .toList(),
    'financeHistory': financeHistory.map((item) => item.toJson()).toList(),
    'financeTransactions': financeTransactions
        .map((item) => item.toJson())
        .toList(),
    'advertisingCampaigns': advertisingCampaigns
        .map((item) => item.toJson())
        .toList(),
    'priceChanges': priceChanges.map((item) => item.toJson()).toList(),
    'productFeatureDevelopments': productFeatureDevelopments
        .map((item) => item.toJson())
        .toList(),
    'productMetricHistory': productMetricHistory
        .map((item) => item.toJson())
        .toList(),
    'productCrunchPeriods': productCrunchPeriods
        .map((item) => item.toJson())
        .toList(),
    'activeLoan': activeLoan?.toJson(),
    'negativeCashSinceMinutes': negativeCashSinceMinutes,
    'creditOffered': creditOffered,
    'liquidityGraceUsed': liquidityGraceUsed,
    'ecosystemLinks': ecosystemLinks.map((item) => item.toJson()).toList(),
    'selectedOfficeId': selectedOfficeId,
    'selectedServerRoomId': selectedServerRoomId,
    'selectedHostingPlanId': selectedHostingPlanId,
    'installedServers': installedServers.map((item) => item.toJson()).toList(),
    'investorOffers': investorOffers.map((item) => item.toJson()).toList(),
    'investorAgreements': investorAgreements
        .map((item) => item.toJson())
        .toList(),
    'founderOwnershipPercent': founderOwnershipPercent,
    'portfolioHoldings': portfolioHoldings
        .map((item) => item.toJson())
        .toList(),
    'acquiredCompanyIds': acquiredCompanyIds,
    'fullyAcquiredCompanyIds': fullyAcquiredCompanyIds,
    'news': news.map((item) => item.toJson()).toList(),
    'criticalEvent': criticalEvent.name,
    'criticalProductId': criticalProductId,
    'gameOver': gameOver,
    'miniGamesEnabled': miniGamesEnabled,
    'onboardingCompleted': onboardingCompleted,
    'rngSeed': rngSeed,
    'rngCounter': rngCounter,
    'feed': feed,
  };

  String encode() => jsonEncode(toJson());

  factory GameState.decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Snapshot root must be a JSON object.');
    }
    final json = decoded.cast<String, Object?>();
    final version = (json['snapshotVersion'] as num?)?.toInt() ?? 1;
    if (version < 3) {
      return _migrateLegacy(json, version);
    }
    if (version > currentSnapshotVersion) {
      throw FormatException('Unsupported snapshot version: $version.');
    }

    final state = GameState(
      snapshotVersion: currentSnapshotVersion,
      simulationMinutes: (json['simulationMinutes']! as num).toInt(),
      speed: GameSpeed.values.byName(json['speed']! as String),
      paused: json['paused']! as bool,
      cash: (json['cash']! as num).toDouble(),
      companyProfile: json['companyProfile'] is Map
          ? FounderCompanyProfile.fromJson(
              (json['companyProfile']! as Map).cast<String, Object?>(),
            )
          : FounderCompanyProfile.legacy(),
      headquartersCityId: json['headquartersCityId'] as String? ?? 'moscow',
      ownedOffices: _decodeList(json['ownedOffices'], OwnedOfficeSite.fromJson),
      ownedDataCenters: _decodeList(
        json['ownedDataCenters'],
        OwnedDataCenterSite.fromJson,
      ),
      employeeTrainings: _decodeList(
        json['employeeTrainings'],
        EmployeeTrainingAssignment.fromJson,
      ),
      employeeGradeUpgrades: _decodeList(
        json['employeeGradeUpgrades'],
        EmployeeGradeUpgrade.fromJson,
      ),
      employeeRelocations: _decodeList(
        json['employeeRelocations'],
        EmployeeRelocationAssignment.fromJson,
      ),
      productServiceRoutes: _decodeList(
        json['productServiceRoutes'],
        ProductServiceRoute.fromJson,
      ),
      activeResearchProjects: _decodeList(
        json['activeResearchProjects'],
        CompanyResearchProject.fromJson,
      ),
      completedResearchKeys:
          (json['completedResearchKeys'] as List?)?.cast<String>() ??
          const <String>[],
      enabledCompanyPerkIds:
          (json['enabledCompanyPerkIds'] as List?)?.cast<String>() ??
          const <String>[],
      legendMarketOffers: _decodeList(
        json['legendMarketOffers'],
        LegendMarketOffer.fromJson,
      ),
      hiredLegendBonuses: _decodeList(
        json['hiredLegendBonuses'],
        HiredLegendBonus.fromJson,
      ),
      pendingEmployeeDepartures: _decodeList(
        json['pendingEmployeeDepartures'],
        PendingEmployeeDeparture.fromJson,
      ),
      companyFans: (json['companyFans'] as num?)?.toInt() ?? 0,
      brandReputation: (json['brandReputation'] as num?)?.toDouble() ?? 10,
      industryEventOpportunities: _decodeList(
        json['industryEventOpportunities'],
        IndustryEventOpportunity.fromJson,
      ),
      bookedIndustryEvents: _decodeList(
        json['bookedIndustryEvents'],
        BookedIndustryEvent.fromJson,
      ),
      companyNotifications: _decodeList(
        json['companyNotifications'],
        CompanyNotification.fromJson,
      ),
      worldProjects: _decodeList(
        json['worldProjects'],
        WorldProjectProgress.fromJson,
      ),
      ecosystemDoctrine: EcosystemDoctrine.values.firstWhere(
        (item) => item.name == json['ecosystemDoctrine'],
        orElse: () => EcosystemDoctrine.balanced,
      ),
      philanthropySpent: (json['philanthropySpent'] as num?)?.toDouble() ?? 0,
      postGamePath: PostGamePath.values.firstWhere(
        (item) => item.name == json['postGamePath'],
        orElse: () => PostGamePath.none,
      ),
      taxRecords: _decodeList(json['taxRecords'], AnnualTaxRecord.fromJson),
      taxYearRevenueAccrued:
          (json['taxYearRevenueAccrued'] as num?)?.toDouble() ?? 0,
      taxYearExpensesAccrued:
          (json['taxYearExpensesAccrued'] as num?)?.toDouble() ?? 0,
      taxYearPayrollAccrued:
          (json['taxYearPayrollAccrued'] as num?)?.toDouble() ?? 0,
      products: _decodeList(json['products'], Product.fromJson),
      candidates: _decodeList(json['candidates'], Candidate.fromJson),
      employees: _decodeList(json['employees'], Employee.fromJson),
      employeeAssignments: _decodeList(
        json['employeeAssignments'],
        EmployeeAssignment.fromJson,
      ),
      securityControls: _decodeList(
        json['securityControls'],
        ProductSecurityControl.fromJson,
      ),
      securityAudits: _decodeList(
        json['securityAudits'],
        SecurityAuditRecord.fromJson,
      ),
      productAiDeployments: _decodeList(
        json['productAiDeployments'],
        ProductAiDeployment.fromJson,
      ),
      productAiIntegrations: _decodeList(
        json['productAiIntegrations'],
        ProductAiIntegration.fromJson,
      ),
      productImprovements: _decodeList(
        json['productImprovements'],
        ProductImprovementRecord.fromJson,
      ),
      productUpdates: _decodeList(
        json['productUpdates'],
        ProductUpdateRecord.fromJson,
      ),
      clientContracts: _decodeList(
        json['clientContracts'],
        ClientContract.fromJson,
      ),
      contractEmployeeAssignments: _decodeList(
        json['contractEmployeeAssignments'],
        ContractEmployeeAssignment.fromJson,
      ),
      monetizationChanges: _decodeList(
        json['monetizationChanges'],
        ProductMonetizationChange.fromJson,
      ),
      financeHistory: _decodeList(
        json['financeHistory'],
        FinanceHistoryPoint.fromJson,
      ),
      financeTransactions: _decodeList(
        json['financeTransactions'],
        FinanceTransaction.fromJson,
      ),
      advertisingCampaigns: _decodeList(
        json['advertisingCampaigns'],
        AdvertisingCampaign.fromJson,
      ),
      priceChanges: _decodeList(
        json['priceChanges'],
        ProductPriceChange.fromJson,
      ),
      productFeatureDevelopments: _decodeList(
        json['productFeatureDevelopments'],
        ProductFeatureDevelopment.fromJson,
      ),
      productMetricHistory: _decodeList(
        json['productMetricHistory'],
        ProductMetricPoint.fromJson,
      ),
      productCrunchPeriods: _decodeList(
        json['productCrunchPeriods'],
        ProductCrunchPeriod.fromJson,
      ),
      activeLoan: json['activeLoan'] is Map
          ? CompanyLoan.fromJson(
              (json['activeLoan']! as Map).cast<String, Object?>(),
            )
          : null,
      negativeCashSinceMinutes: (json['negativeCashSinceMinutes'] as num?)
          ?.toInt(),
      creditOffered: json['creditOffered'] as bool? ?? false,
      liquidityGraceUsed: json['liquidityGraceUsed'] as bool? ?? false,
      ecosystemLinks: _decodeList(
        json['ecosystemLinks'],
        EcosystemLink.fromJson,
      ),
      selectedOfficeId: json['selectedOfficeId']! as String,
      selectedServerRoomId: json['selectedServerRoomId']! as String,
      selectedHostingPlanId:
          json['selectedHostingPlanId'] as String? ?? 'shared_launch',
      installedServers: _decodeList(
        json['installedServers'],
        InstalledServer.fromJson,
      ),
      investorOffers: _decodeList(
        json['investorOffers'],
        InvestorOffer.fromJson,
      ),
      investorAgreements: _decodeList(
        json['investorAgreements'],
        InvestorAgreement.fromJson,
      ),
      founderOwnershipPercent: (json['founderOwnershipPercent']! as num)
          .toDouble(),
      portfolioHoldings: _decodeList(
        json['portfolioHoldings'],
        PortfolioHolding.fromJson,
      ),
      acquiredCompanyIds: (json['acquiredCompanyIds']! as List).cast<String>(),
      fullyAcquiredCompanyIds: _decodeFullyAcquiredCompanyIds(json),
      news: _decodeList(json['news'], NewsItem.fromJson),
      criticalEvent: CriticalEventType.values.byName(
        json['criticalEvent']! as String,
      ),
      criticalProductId: json['criticalProductId'] as String?,
      gameOver: json['gameOver']! as bool,
      miniGamesEnabled: json['miniGamesEnabled']! as bool,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      rngSeed: (json['rngSeed']! as num).toInt(),
      rngCounter: (json['rngCounter']! as num).toInt(),
      feed: (json['feed']! as List).cast<String>(),
    );
    var migrated = state;
    final hasLegacyStarterHardware =
        version <= 10 &&
        migrated.selectedHostingPlanId != 'owned' &&
        migrated.installedCount('edge_s1') >= 2;
    if (hasLegacyStarterHardware) {
      migrated = migrated.copyWith(
        installedServers: migrated.installedServers
            .expand((server) {
              if (server.hardwareId != 'edge_s1') {
                return <InstalledServer>[server];
              }
              final paidCount = server.count - 2;
              return paidCount > 0
                  ? <InstalledServer>[
                      InstalledServer(
                        hardwareId: server.hardwareId,
                        count: paidCount,
                      ),
                    ]
                  : const <InstalledServer>[];
            })
            .toList(growable: false),
      );
    }
    if (version <= 11 &&
        migrated.selectedOfficeId == 'garage' &&
        migrated.onSiteEmployeeCount == 0) {
      migrated = migrated.copyWith(selectedOfficeId: 'remote_first');
    }
    if (version <= 10) {
      final hrIds = migrated.employees
          .where((employee) => employee.isHr)
          .map((employee) => employee.id)
          .toSet();
      if (hrIds.isNotEmpty) {
        migrated = migrated.copyWith(
          employeeAssignments: migrated.employeeAssignments
              .where((assignment) => !hrIds.contains(assignment.employeeId))
              .toList(growable: false),
        );
      }
    }
    if (version <= 14) {
      migrated = migrated.copyWith(
        advertisingCampaigns: migrated.advertisingCampaigns
            .map((campaign) {
              if (campaign.status == AdvertisingCampaignStatus.active &&
                  campaign.endsAtMinutes >= 0) {
                return campaign.copyWith(
                  status: AdvertisingCampaignStatus.stopped,
                );
              }
              return campaign;
            })
            .toList(growable: false),
      );
    }
    if (version < currentSnapshotVersion && migrated.productUpdates.isEmpty) {
      return migrated.copyWith(
        productUpdates: migrated.products
            .map(
              (product) => ProductUpdateRecord(
                productId: product.id,
                updatedAtMinutes: migrated.simulationMinutes,
                reason: 'Миграция snapshot v$version',
              ),
            )
            .toList(growable: false),
      );
    }
    return migrated;
  }

  static GameState _migrateLegacy(Map<String, Object?> json, int version) {
    final initial = GameState.initial();
    final speedName = json['speed'] as String?;
    final speed = GameSpeed.values.where((item) => item.name == speedName);
    return initial.copyWith(
      simulationMinutes:
          (json['simulationMinutes'] as num?)?.toInt() ??
          initial.simulationMinutes,
      speed: speed.isEmpty ? GameSpeed.x1 : speed.first,
      paused: json['paused'] as bool? ?? true,
      cash: (json['cash'] as num?)?.toDouble() ?? initial.cash,
      companyProfile: FounderCompanyProfile.legacy(),
      miniGamesEnabled: json['miniGamesEnabled'] as bool? ?? true,
      feed: <String>[
        'Сохранение версии $version перенесено в новую экономическую модель.',
        ...initial.feed,
      ],
    );
  }

  static List<T> _decodeList<T>(
    Object? source,
    T Function(Map<String, Object?> json) decoder,
  ) {
    final items = source as List? ?? const <Object?>[];
    return items
        .map((item) => decoder((item! as Map).cast<String, Object?>()))
        .toList(growable: false);
  }

  static List<String> _decodeFullyAcquiredCompanyIds(
    Map<String, Object?> json,
  ) {
    final stored = json['fullyAcquiredCompanyIds'];
    if (stored is List) {
      return stored.cast<String>();
    }

    // Older v12 saves represented a full company acquisition only by the
    // retained acquisition team. Promote that stable marker once on decode.
    final employeeIds = <String>{};
    for (final raw in json['employees'] as List? ?? const <Object?>[]) {
      if (raw is Map && raw['id'] is String) {
        employeeIds.add(raw['id']! as String);
      }
    }
    return GameCatalog.marketCompanies
        .where((company) => employeeIds.contains('acq_${company.id}_lead'))
        .map((company) => company.id)
        .toList(growable: false);
  }
}
