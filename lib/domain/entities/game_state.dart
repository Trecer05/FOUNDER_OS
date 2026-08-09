import 'dart:convert';
import 'dart:math' as math;

import '../catalog/contract_catalog.dart';
import '../catalog/candidate_market_catalog.dart';
import '../catalog/game_catalog.dart';
import '../catalog/operations_catalog.dart';
import '../catalog/product_evolution_catalog.dart';
import '../catalog/product_strategy_catalog.dart';
import '../catalog/v9_content_catalog.dart';
import 'business_models.dart';
import 'management_models.dart';
import 'models.dart';
import 'operations_models.dart';
import 'product_evolution_models.dart';
import 'product_strategy_models.dart';
import 'v9_models.dart';
import 'v10_models.dart';
import 'v12_models.dart';

part 'game_state_index.dart';

const int currentSnapshotVersion = 12;

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

  OfficeOption get office => GameCatalog.officeById(selectedOfficeId);
  ServerRoomOption get serverRoom =>
      GameCatalog.serverRoomById(selectedServerRoomId);
  HostingPlan get hostingPlan =>
      V9ContentCatalog.hostingById(selectedHostingPlanId);
  bool get usingOwnedInfrastructure => hostingPlan.kind == HostingKind.owned;

  Product? productById(String id) => _index.productsById[id];

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

  double employeeProductivityPercent(Employee employee) =>
      (employeeCoreProductivityPercent(employee) *
              parallelEfficiencyForEmployee(employee.id))
          .clamp(0, 109)
          .toDouble();

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

  int get availableOfficeSeats =>
      math.max(0, office.capacity - onSiteEmployeeCount).toInt();

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
    final scaleRisk = math.min(0.18, product.users / 5000000);
    final raw =
        (100 - product.securityScore) / 100 * 0.58 +
        categoryRisk +
        scaleRisk +
        math.max(0, productServerLoad(product) - 0.85) * 0.20;
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
    final phase = ProductStrategyCatalog.phaseFor(product.developmentProgress);
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
    final sizeEfficiency = teamSize == 0
        ? 0.10
        : teamSize < strategy.minimumTeamSize
        ? (0.30 + 0.70 * teamSize / math.max(1, strategy.minimumTeamSize))
              .clamp(0.18, 1.0)
              .toDouble()
        : teamSize <= strategy.maximumEfficientTeamSize
        ? 1.0
        : (1 - (teamSize - strategy.maximumEfficientTeamSize) * 0.07)
              .clamp(0.52, 1.0)
              .toDouble();
    final efficiency =
        (sizeEfficiency *
                (0.38 + languageCoverage * 0.62) *
                (0.52 + roleCoverage * 0.48))
            .clamp(0.05, 1.0)
            .toDouble();

    final criticalIds = <String>[];
    final movableIds = <String>[];
    for (final employee in team) {
      final phaseCritical = phase.criticalRoles.contains(employee.role);
      final uniqueLanguage = employee.languageIds.any((language) {
        if (!selectedLanguages.contains(language)) {
          return false;
        }
        return team
            .where((other) => other.id != employee.id)
            .where((other) => other.languageIds.contains(language))
            .isEmpty;
      });
      if (phaseCritical ||
          uniqueLanguage ||
          teamSize <= strategy.minimumTeamSize) {
        criticalIds.add(employee.id);
      } else {
        movableIds.add(employee.id);
      }
    }

    final status = teamSize == 0
        ? 'Проект почти стоит: работает только основатель'
        : teamSize < strategy.minimumTeamSize
        ? 'Недокомплект'
        : teamSize > strategy.maximumEfficientTeamSize
        ? 'Перегруз команды: коммуникации съедают скорость'
        : teamSize < strategy.optimalTeamSize
        ? 'Рабочая команда, но до оптимума не хватает людей'
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
    if (product == null) {
      return 0;
    }
    final team = employeesForProduct(productId);
    final staffing = developmentStaffingFor(productId);
    final phase = developmentPhaseFor(product);
    final aiMultiplier = 1 + productAiDevelopmentBoost(productId);
    final productManagerMultiplier =
        team.any((employee) => employee.role == EmployeeRole.productManager)
        ? 1.15
        : 1.0;
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
    final selectedLanguages = product.languageIds.toSet();
    var effectiveFte = 0.0;
    for (final employee in team) {
      final productivity = employeeCoreProductivityPercent(employee) / 100;
      final phaseWeight = phase.criticalRoles.contains(employee.role)
          ? 1.0
          : engineeringRoles.contains(employee.role)
          ? 0.58
          : 0.30;
      final languageMatch = languageIndependentRoles.contains(employee.role)
          ? 0.90
          : employee.languageIds.any(selectedLanguages.contains)
          ? 1.0
          : 0.28;
      final allocation =
          employeeAllocationForProduct(employee.id, productId) / 100;
      effectiveFte += productivity * phaseWeight * languageMatch * allocation;
    }

    final usesOffice = team.any((employee) => !employee.remote);
    final comfortMultiplier = usesOffice
        ? 0.90 + office.comfortScore / 1000
        : 1.0;
    final communicationMultiplier = usesOffice
        ? office.communicationEfficiency
        : 1.0;
    return effectiveFte *
        staffing.efficiency *
        communicationMultiplier *
        comfortMultiplier *
        aiMultiplier *
        productManagerMultiplier;
  }

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

  double productFreshnessScore(Product product) {
    final days = productAgeSinceUpdateDays(product);
    if (days <= 21) {
      return 100;
    }
    return (100 - (days - 21) * 1.35).clamp(35, 100).toDouble();
  }

  double productStalenessPenalty(Product product) =>
      (100 - productFreshnessScore(product)) / 100;

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

  double get preparedComputeUnits =>
      installedServers.fold<double>(0, (sum, item) {
        final hardware = GameCatalog.serverHardwareById(item.hardwareId);
        return sum + hardware.computeUnits * item.count;
      });

  double get totalComputeUnits => usingOwnedInfrastructure
      ? preparedComputeUnits
      : hostingPlan.computeUnits;

  double get totalNetworkGbps {
    if (hostingPlan.kind == HostingKind.none) {
      return 0;
    }
    if (!usingOwnedInfrastructure) {
      return math.max(0.1, hostingPlan.bandwidthTb * 0.60).toDouble();
    }
    return math
        .min(
          serverRoom.networkGbps,
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
      (usedRackUnits <= serverRoom.rackUnits &&
          usedCoolingKw <= serverRoom.coolingKw &&
          usedPowerKw <= serverRoom.powerKw);

  double get totalAllocatedPercent => products.fold<double>(
    0,
    (sum, item) => sum + item.allocatedCapacityPercent,
  );

  double allocatedComputeFor(String productId) {
    final product = productById(productId);
    if (product == null) {
      return 0;
    }
    return totalComputeUnits * product.allocatedCapacityPercent / 100;
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
            productImprovementComputeMultiplier(product.id)) +
        aiProviderDemand;
  }

  double productServerLoad(Product product) {
    final allocated = allocatedComputeFor(product.id);
    if (allocated <= 0) {
      return product.stage == ProductStage.live ? 9.99 : 0;
    }
    return productComputeDemand(product) / allocated;
  }

  double get totalComputeDemand =>
      products.fold<double>(0, (sum, item) => sum + productComputeDemand(item));

  double get serverLoad =>
      totalComputeUnits <= 0 ? 0 : totalComputeDemand / totalComputeUnits;

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
                product.retention30d * 0.10 +
                product.reliability * 0.13)
            .clamp(0.48, 1.0)
            .toDouble();
    final founderGrowthMultiplier = companyProfile.growthEfficiencyMultiplier;
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
        founderGrowthMultiplier;
    final expected = (clicks * conversion).round();
    final spread = (1 - agency.forecastAccuracy) * 0.75 + 0.18;
    return AdvertisingForecast(
      impressions: math.max(0, impressions),
      clicks: math.max(0, clicks),
      usersLow: math.max(0, (expected * (1 - spread)).round()),
      usersExpected: math.max(0, expected),
      usersHigh: math.max(0, (expected * (1 + spread)).round()),
      effectiveBudget: effectiveBudget,
      note: product.brandAwareness < 0.08
          ? 'Новый бренд конвертирует слабее зрелого, но закупленный трафик всё равно даёт измеримый объём. Дальше результат решают activation и retention.'
          : 'Диапазон зависит от доверия, качества продукта, соответствия канала и точности агентства.',
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
    return base * companyProfile.officeRentMultiplier;
  }

  double get monthlyServerRoomCost => usingOwnedInfrastructure
      ? serverRoom.monthlyRent * companyProfile.officeRentMultiplier
      : 0;

  double get monthlyOfficeCost =>
      office.monthlyRent * companyProfile.officeRentMultiplier;

  double get monthlyProductRevenue =>
      products.fold<double>(0, (sum, item) => sum + item.monthlyRevenue);

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

  double get monthlyCosts =>
      monthlyPayroll +
      monthlyOfficeCost +
      monthlyServerRoomCost +
      monthlyHardwareCost +
      monthlySecurityCost +
      monthlyCorporateAiCost +
      products.fold<double>(
        0,
        (sum, item) =>
            sum + item.monthlyCost + productImprovementMonthlyCost(item.id),
      ) +
      investorPayouts +
      monthlyLoanPayment;

  double get monthlyProfit =>
      monthlyProductRevenue + portfolioIncome - monthlyCosts;

  double get runwayMonths {
    if (monthlyProfit >= 0) {
      return 99;
    }
    return cash / monthlyProfit.abs();
  }

  double get valuation {
    final recurring = monthlyProductRevenue * 24;
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
    return math
        .max(
          500000,
          recurring + usersValue + technology + ecosystem + profitPremium,
        )
        .toDouble();
  }

  double get founderPortfolioValue => valuation * founderOwnershipPercent / 100;

  int get requiredReleasedBlueprintsForLegacy =>
      (GameCatalog.productBlueprints.length * 0.70).ceil();

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

  double get legacyProductProgress =>
      (releasedBlueprintCount /
              math.max(1, requiredReleasedBlueprintsForLegacy))
          .clamp(0, 1)
          .toDouble();

  bool get legacyProductRequirementMet =>
      releasedBlueprintCount >= requiredReleasedBlueprintsForLegacy;

  bool marketCompanyFullyAcquired(String companyId) =>
      fullyAcquiredCompanyIds.contains(companyId);

  int get acquiredRivalCount => GameCatalog.marketCompanies
      .where((company) => marketCompanyFullyAcquired(company.id))
      .length;

  int get remainingRivalCount => math
      .max(0, GameCatalog.marketCompanies.length - acquiredRivalCount)
      .toInt();

  bool get founderLegacyCompleted =>
      !gameOver && legacyProductRequirementMet && remainingRivalCount == 0;

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
    final base = switch (selectedModel) {
      MonetizationModel.free => 0.0,
      MonetizationModel.subscription => assumedMau * product.price * 0.092,
      MonetizationModel.usageBased => assumedMau * product.price * 0.061,
      MonetizationModel.advertising => assumedMau * 34.0,
      MonetizationModel.transactionFee => assumedMau * product.price * 0.18,
    };
    final expected =
        base * product.reliability * (1 + ecosystemBoostFor(product.id) * 0.55);
    return RevenueForecast(
      low: expected * 0.68,
      expected: expected,
      high: expected * 1.32,
      assumedMau: assumedMau,
      note:
          'Диапазон использует текущие MAU, цену, reliability и экосистему. Реальный доход меняется из-за churn, рынка, свежести и рекламы.',
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
    if (source == null) return 0;
    var boost = 0.0;
    for (final link in ecosystemLinks) {
      if (!link.contains(productId) ||
          simulationMinutes < link.activeAtMinutes) {
        continue;
      }
      final other = productById(link.other(productId));
      if (other == null) continue;
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
    if (stored is List) return stored.cast<String>();

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
