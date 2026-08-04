import 'dart:convert';
import 'dart:math' as math;

import '../catalog/game_catalog.dart';
import 'models.dart';

const int currentSnapshotVersion = 3;

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
    return (baseline + userDemand) * product.computeMultiplier;
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

  double get monthlyCosts =>
      monthlyPayroll +
      office.monthlyRent +
      serverRoom.monthlyRent +
      monthlyHardwareCost +
      products.fold<double>(0, (sum, item) => sum + item.monthlyCost) +
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
    if (version < currentSnapshotVersion) {
      return _migrateLegacy(json, version);
    }
    if (version != currentSnapshotVersion) {
      throw FormatException('Unsupported snapshot version: $version.');
    }

    return GameState(
      snapshotVersion: currentSnapshotVersion,
      simulationMinutes: (json['simulationMinutes']! as num).toInt(),
      speed: GameSpeed.values.byName(json['speed']! as String),
      paused: json['paused']! as bool,
      cash: (json['cash']! as num).toDouble(),
      products: _decodeList(json['products'], Product.fromJson),
      candidates: _decodeList(json['candidates'], Candidate.fromJson),
      employees: _decodeList(json['employees'], Employee.fromJson),
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
      rngSeed: (json['rngSeed']! as num).toInt(),
      rngCounter: (json['rngCounter']! as num).toInt(),
      feed: (json['feed']! as List).cast<String>(),
    );
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
