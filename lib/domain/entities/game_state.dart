import 'dart:convert';
import 'dart:math' as math;

import '../catalog/contract_catalog.dart';
import '../catalog/game_catalog.dart';
import '../catalog/operations_catalog.dart';
import '../catalog/product_evolution_catalog.dart';
import 'business_models.dart';
import 'models.dart';
import 'operations_models.dart';
import 'product_evolution_models.dart';

const int currentSnapshotVersion = 6;

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
    required this.ecosystemLinks,
    required this.selectedOfficeId,
    required this.selectedServerRoomId,
    required this.installedServers,
    required this.investorOffers,
    required this.investorAgreements,
    required this.founderOwnershipPercent,
    required this.portfolioHoldings,
    required this.acquiredCompanyIds,
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

  factory GameState.initial() => GameState(
    snapshotVersion: currentSnapshotVersion,
    simulationMinutes: 8 * 60,
    speed: GameSpeed.x1,
    paused: true,
    cash: 2600000,
    products: const <Product>[],
    candidates: List<Candidate>.unmodifiable(GameCatalog.initialCandidates),
    employees: const <Employee>[],
    employeeAssignments: const <EmployeeAssignment>[],
    securityControls: const <ProductSecurityControl>[],
    securityAudits: const <SecurityAuditRecord>[],
    productAiDeployments: const <ProductAiDeployment>[],
    productAiIntegrations: const <ProductAiIntegration>[],
    productImprovements: const <ProductImprovementRecord>[],
    productUpdates: const <ProductUpdateRecord>[],
    clientContracts: const <ClientContract>[],
    ecosystemLinks: const <EcosystemLink>[],
    selectedOfficeId: 'garage',
    selectedServerRoomId: 'closet',
    installedServers: const <InstalledServer>[
      InstalledServer(hardwareId: 'edge_s1', count: 2),
    ],
    investorOffers: const <InvestorOffer>[],
    investorAgreements: const <InvestorAgreement>[],
    founderOwnershipPercent: 100,
    portfolioHoldings: const <PortfolioHolding>[],
    acquiredCompanyIds: const <String>[],
    news: const <NewsItem>[
      NewsItem(
        id: 'news_start_competitor',
        kind: NewsKind.competitor,
        title: 'Astra AI обновила модель',
        body: 'Конкурент сократил среднюю задержку ответа до 1,45 сек.',
        simulationMinutes: 8 * 60,
        critical: false,
      ),
      NewsItem(
        id: 'news_start_market',
        kind: NewsKind.market,
        title: 'Рынок ждёт узкие продукты',
        body:
            'Пользователи готовы переходить ради заметного преимущества по одной важной метрике.',
        simulationMinutes: 8 * 60,
        critical: false,
      ),
    ],
    criticalEvent: CriticalEventType.none,
    criticalProductId: null,
    gameOver: false,
    miniGamesEnabled: true,
    onboardingCompleted: false,
    rngSeed: 20260804,
    rngCounter: 0,
    feed: const <String>[
      'Компания зарегистрирована. На счету 2,6 млн ₽.',
      'Сначала выберите продукт, стек и ожидаемые пользователями функции.',
    ],
  );

  final int snapshotVersion;
  final int simulationMinutes;
  final GameSpeed speed;
  final bool paused;
  final double cash;
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
  final List<EcosystemLink> ecosystemLinks;
  final String selectedOfficeId;
  final String selectedServerRoomId;
  final List<InstalledServer> installedServers;
  final List<InvestorOffer> investorOffers;
  final List<InvestorAgreement> investorAgreements;
  final double founderOwnershipPercent;
  final List<PortfolioHolding> portfolioHoldings;
  final List<String> acquiredCompanyIds;
  final List<NewsItem> news;
  final CriticalEventType criticalEvent;
  final String? criticalProductId;
  final bool gameOver;
  final bool miniGamesEnabled;
  final bool onboardingCompleted;
  final int rngSeed;
  final int rngCounter;
  final List<String> feed;

  int get day => simulationMinutes ~/ (24 * 60) + 1;
  int get minuteOfDay => simulationMinutes % (24 * 60);
  int get hour => minuteOfDay ~/ 60;
  int get minute => minuteOfDay % 60;
  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  OfficeOption get office => GameCatalog.officeById(selectedOfficeId);
  ServerRoomOption get serverRoom =>
      GameCatalog.serverRoomById(selectedServerRoomId);

  Product? productById(String id) {
    for (final product in products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  Candidate? candidateById(String id) {
    for (final candidate in candidates) {
      if (candidate.id == id) {
        return candidate;
      }
    }
    return null;
  }

  Employee? employeeById(String id) {
    for (final employee in employees) {
      if (employee.id == id) {
        return employee;
      }
    }
    return null;
  }

  EmployeeAssignment? assignmentForEmployee(String employeeId) {
    for (final assignment in employeeAssignments) {
      if (assignment.employeeId == employeeId) {
        return assignment;
      }
    }
    return null;
  }

  List<Employee> employeesForProduct(String productId) => employeeAssignments
      .where((item) => item.productId == productId)
      .map((item) => employeeById(item.employeeId))
      .whereType<Employee>()
      .toList(growable: false);

  List<Employee> get unassignedEmployees => employees
      .where((employee) => assignmentForEmployee(employee.id) == null)
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

  ContractTemplate contractTemplate(String templateId) =>
      ContractCatalog.byId(templateId);

  bool hasActiveContractTemplate(String templateId) =>
      activeContracts.any((contract) => contract.templateId == templateId);

  double contractRoleCoverage(ContractTemplate template) {
    if (template.requiredRoles.isEmpty) {
      return 1;
    }
    final reserveRoles = unassignedEmployees
        .map((employee) => employee.role)
        .toList(growable: false);
    final covered = template.requiredRoles
        .where((role) => reserveRoles.contains(role))
        .length;
    return covered / template.requiredRoles.length;
  }

  double get contractDevelopmentCapacity {
    final reserve = unassignedEmployees;
    if (reserve.isEmpty) {
      return 18;
    }
    return 18 +
        reserve.fold<double>(
          0,
          (sum, employee) =>
              sum +
              employee.skill * 0.28 +
              employee.speed * 0.24 +
              employee.quality * 0.14,
        );
  }

  List<String> securityControlIdsFor(String productId) => securityControls
      .where((item) => item.productId == productId)
      .map((item) => item.controlId)
      .toList(growable: false);

  bool hasSecurityControl(String productId, String controlId) =>
      securityControls.any(
        (item) => item.productId == productId && item.controlId == controlId,
      );

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

  double productDevelopmentCapacity(String productId) {
    final team = employeesForProduct(productId);
    final product = productById(productId);
    if (product == null) {
      return 0;
    }
    final roleCoverage = productRoleCoverage(productId);
    final aiMultiplier = 1 + productAiDevelopmentBoost(productId);
    if (team.isEmpty) {
      return 22 * (0.75 + roleCoverage * 0.25) * aiMultiplier;
    }
    final base = team.fold<double>(
      0,
      (sum, employee) =>
          sum +
          employee.skill * 0.42 +
          employee.speed * 0.34 +
          employee.quality * 0.24,
    );
    final comfortMultiplier = 0.86 + office.comfortScore / 500;
    final roleMultiplier = 0.55 + roleCoverage * 0.45;
    return base *
        office.communicationEfficiency *
        comfortMultiplier *
        roleMultiplier *
        aiMultiplier;
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

  int improvementLevel(String productId, ProductImprovementType type) {
    var level = 0;
    for (final record in productImprovements) {
      if (record.productId == productId &&
          record.type == type &&
          record.level > level) {
        level = record.level;
      }
    }
    return level;
  }

  double improvementCost(String productId, ProductImprovementType type) {
    final option = ProductEvolutionCatalog.improvementByType(type);
    final level = improvementLevel(productId, type);
    return option.baseCost * (1 + level * 0.38);
  }

  double productImprovementMonthlyCost(String productId) =>
      ProductImprovementType.values.fold<double>(0, (sum, type) {
        final option = ProductEvolutionCatalog.improvementByType(type);
        return sum +
            option.monthlyCostDelta * improvementLevel(productId, type);
      });

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

  InvestorOffer? offerById(String id) {
    for (final offer in investorOffers) {
      if (offer.id == id) {
        return offer;
      }
    }
    return null;
  }

  InvestorAgreement? agreementById(String id) {
    for (final agreement in investorAgreements) {
      if (agreement.id == id) {
        return agreement;
      }
    }
    return null;
  }

  PortfolioHolding? holdingByCompanyId(String id) {
    for (final holding in portfolioHoldings) {
      if (holding.companyId == id) {
        return holding;
      }
    }
    return null;
  }

  int installedCount(String hardwareId) {
    for (final installed in installedServers) {
      if (installed.hardwareId == hardwareId) {
        return installed.count;
      }
    }
    return 0;
  }

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

  double get totalComputeUnits => installedServers.fold<double>(0, (sum, item) {
    final hardware = GameCatalog.serverHardwareById(item.hardwareId);
    return sum + hardware.computeUnits * item.count;
  });

  double get totalNetworkGbps => math
      .min(
        serverRoom.networkGbps,
        installedServers.fold<double>(0, (sum, item) {
          final hardware = GameCatalog.serverHardwareById(item.hardwareId);
          return sum + hardware.networkGbps * item.count;
        }),
      )
      .toDouble();

  double get hardwareReliability {
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
      usedRackUnits <= serverRoom.rackUnits &&
      usedCoolingKw <= serverRoom.coolingKw &&
      usedPowerKw <= serverRoom.powerKw;

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

  double get monthlyPayroll =>
      employees.fold<double>(0, (sum, item) => sum + item.salary);

  double get monthlyHardwareCost =>
      installedServers.fold<double>(0, (sum, item) {
        final hardware = GameCatalog.serverHardwareById(item.hardwareId);
        return sum + hardware.monthlyCost * item.count;
      });

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
      office.monthlyRent +
      serverRoom.monthlyRent +
      monthlyHardwareCost +
      monthlySecurityCost +
      monthlyCorporateAiCost +
      products.fold<double>(
        0,
        (sum, item) =>
            sum + item.monthlyCost + productImprovementMonthlyCost(item.id),
      ) +
      investorPayouts;

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
    final connectionCount = connectedProductIds(productId).length;
    return math.min(0.15, connectionCount * 0.025).toDouble();
  }

  GameState copyWith({
    int? snapshotVersion,
    int? simulationMinutes,
    GameSpeed? speed,
    bool? paused,
    double? cash,
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
    List<EcosystemLink>? ecosystemLinks,
    String? selectedOfficeId,
    String? selectedServerRoomId,
    List<InstalledServer>? installedServers,
    List<InvestorOffer>? investorOffers,
    List<InvestorAgreement>? investorAgreements,
    double? founderOwnershipPercent,
    List<PortfolioHolding>? portfolioHoldings,
    List<String>? acquiredCompanyIds,
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
      ecosystemLinks: List<EcosystemLink>.unmodifiable(
        ecosystemLinks ?? this.ecosystemLinks,
      ),
      selectedOfficeId: selectedOfficeId ?? this.selectedOfficeId,
      selectedServerRoomId: selectedServerRoomId ?? this.selectedServerRoomId,
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
    'ecosystemLinks': ecosystemLinks.map((item) => item.toJson()).toList(),
    'selectedOfficeId': selectedOfficeId,
    'selectedServerRoomId': selectedServerRoomId,
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
      ecosystemLinks: _decodeList(
        json['ecosystemLinks'],
        EcosystemLink.fromJson,
      ),
      selectedOfficeId: json['selectedOfficeId']! as String,
      selectedServerRoomId: json['selectedServerRoomId']! as String,
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
    if (version < currentSnapshotVersion && state.productUpdates.isEmpty) {
      return state.copyWith(
        productUpdates: state.products
            .map(
              (product) => ProductUpdateRecord(
                productId: product.id,
                updatedAtMinutes: state.simulationMinutes,
                reason: 'Миграция snapshot v$version',
              ),
            )
            .toList(growable: false),
      );
    }
    return state;
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
}
