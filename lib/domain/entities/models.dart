enum EmployeeRole {
  productManager,
  frontend,
  backend,
  mobile,
  aiMl,
  designer,
  qa,
  devOps,
  security,
  growth,
  sales,
  support,
}

/// Seniority is part of the labour market, not a fixed candidate template.
/// It defines realistic compensation and skill bands while the actual values
/// inside those bands are generated for every market refresh.
enum EmployeeGrade { intern, junior, middle, senior }

enum ProductCategory {
  aiAssistant,
  cloud,
  saas,
  browser,
  cryptoWallet,
  developerTool,
}

enum ProductStage { development, beta, live, failed }

enum ProductBugSeverity { minor, major, critical }

enum MonetizationModel {
  free,
  subscription,
  usageBased,
  advertising,
  transactionFee,
}

enum CriticalEventType {
  none,
  serverOverload,
  securityBreach,
  lostControl,
  insolvency,
}

enum NewsKind {
  competitor,
  security,
  funding,
  acquisition,
  market,
  product,
  infrastructure,
  finance,
}

enum AcquisitionMode { maintainSeparate, migrateUsers }

class Candidate {
  const Candidate({
    required this.id,
    required this.name,
    required this.role,
    required this.skill,
    required this.speed,
    required this.quality,
    required this.autonomy,
    required this.communication,
    required this.reliability,
    required this.salary,
    required this.loyalty,
    required this.remote,
    this.languageIds = const <String>[],
    this.isHr = false,
    this.grade = EmployeeGrade.middle,
  });

  final String id;
  final String name;
  final EmployeeRole role;
  final int skill;
  final int speed;
  final int quality;
  final int autonomy;
  final int communication;
  final int reliability;
  final double salary;
  final int loyalty;
  final bool remote;
  final List<String> languageIds;
  final bool isHr;
  final EmployeeGrade grade;

  Employee toEmployee({int hiredAtMinutes = 0, double salaryMultiplier = 1}) =>
      Employee(
        id: id,
        name: name,
        role: role,
        skill: skill,
        speed: speed,
        quality: quality,
        autonomy: autonomy,
        communication: communication,
        reliability: reliability,
        salary: salary * salaryMultiplier,
        loyalty: loyalty,
        morale: 78,
        workload: 35,
        remote: remote,
        languageIds: languageIds,
        hiredAtMinutes: hiredAtMinutes,
        isHr: isHr,
        grade: grade,
      );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'role': role.name,
    'skill': skill,
    'speed': speed,
    'quality': quality,
    'autonomy': autonomy,
    'communication': communication,
    'reliability': reliability,
    'salary': salary,
    'loyalty': loyalty,
    'remote': remote,
    'languageIds': languageIds,
    'isHr': isHr,
    'grade': grade.name,
  };

  factory Candidate.fromJson(Map<String, Object?> json) => Candidate(
    id: json['id']! as String,
    name: json['name']! as String,
    role: EmployeeRole.values.byName(json['role']! as String),
    skill: (json['skill']! as num).toInt(),
    speed: (json['speed']! as num).toInt(),
    quality: (json['quality']! as num).toInt(),
    autonomy: (json['autonomy']! as num).toInt(),
    communication: (json['communication']! as num).toInt(),
    reliability: (json['reliability']! as num).toInt(),
    salary: (json['salary']! as num).toDouble(),
    loyalty: (json['loyalty']! as num).toInt(),
    remote: json['remote']! as bool,
    languageIds:
        (json['languageIds'] as List?)?.cast<String>() ?? const <String>[],
    isHr: json['isHr'] as bool? ?? false,
    grade: _employeeGradeFromJson(json),
  );
}

class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.skill,
    required this.speed,
    required this.quality,
    required this.autonomy,
    required this.communication,
    required this.reliability,
    required this.salary,
    required this.loyalty,
    required this.morale,
    required this.workload,
    required this.remote,
    this.languageIds = const <String>[],
    this.hiredAtMinutes = 0,
    this.isHr = false,
    this.grade = EmployeeGrade.middle,
  });

  final String id;
  final String name;
  final EmployeeRole role;
  final int skill;
  final int speed;
  final int quality;
  final int autonomy;
  final int communication;
  final int reliability;
  final double salary;
  final int loyalty;
  final int morale;
  final int workload;
  final bool remote;
  final List<String> languageIds;
  final int hiredAtMinutes;
  final bool isHr;
  final EmployeeGrade grade;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'role': role.name,
    'skill': skill,
    'speed': speed,
    'quality': quality,
    'autonomy': autonomy,
    'communication': communication,
    'reliability': reliability,
    'salary': salary,
    'loyalty': loyalty,
    'morale': morale,
    'workload': workload,
    'remote': remote,
    'languageIds': languageIds,
    'hiredAtMinutes': hiredAtMinutes,
    'isHr': isHr,
    'grade': grade.name,
  };

  factory Employee.fromJson(Map<String, Object?> json) => Employee(
    id: json['id']! as String,
    name: json['name']! as String,
    role: EmployeeRole.values.byName(json['role']! as String),
    skill: (json['skill']! as num).toInt(),
    speed: (json['speed']! as num).toInt(),
    quality: (json['quality']! as num).toInt(),
    autonomy: (json['autonomy']! as num).toInt(),
    communication: (json['communication']! as num).toInt(),
    reliability: (json['reliability']! as num).toInt(),
    salary: (json['salary']! as num).toDouble(),
    loyalty: (json['loyalty']! as num).toInt(),
    morale: (json['morale']! as num).toInt(),
    workload: (json['workload']! as num).toInt(),
    remote: json['remote']! as bool,
    languageIds:
        (json['languageIds'] as List?)?.cast<String>() ?? const <String>[],
    hiredAtMinutes: (json['hiredAtMinutes'] as num?)?.toInt() ?? 0,
    isHr: json['isHr'] as bool? ?? false,
    grade: _employeeGradeFromJson(json),
  );
}

EmployeeGrade _employeeGradeFromJson(Map<String, Object?> json) {
  final raw = json['grade'] as String?;
  for (final grade in EmployeeGrade.values) {
    if (grade.name == raw) return grade;
  }

  // v12 and older snapshots did not persist a grade. Infer it from the
  // strongest stable signal so old saves migrate without changing employees.
  final skill = (json['skill'] as num?)?.toInt() ?? 70;
  return switch (skill) {
    < 45 => EmployeeGrade.intern,
    < 63 => EmployeeGrade.junior,
    < 79 => EmployeeGrade.middle,
    _ => EmployeeGrade.senior,
  };
}

class ProductBlueprint {
  const ProductBlueprint({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.baseDevelopmentCost,
    required this.baseDevelopmentHours,
    required this.basePrice,
    required this.baseLatencyMs,
    required this.baseDesignScore,
    required this.baseSecurityScore,
    required this.baseReliability,
    required this.computePerThousandUsers,
    required this.expectedFeatureIds,
  });

  final String id;
  final String name;
  final ProductCategory category;
  final String description;
  final double baseDevelopmentCost;
  final double baseDevelopmentHours;
  final double basePrice;
  final double baseLatencyMs;
  final double baseDesignScore;
  final double baseSecurityScore;
  final double baseReliability;
  final double computePerThousandUsers;
  final List<String> expectedFeatureIds;
}

class FrameworkOption {
  const FrameworkOption({
    required this.id,
    required this.name,
    required this.supportedCategories,
    required this.description,
    required this.performanceDelta,
    required this.designDelta,
    required this.securityDelta,
    required this.developmentSpeedDelta,
    required this.monthlyCost,
  });

  final String id;
  final String name;
  final List<ProductCategory> supportedCategories;
  final String description;
  final double performanceDelta;
  final double designDelta;
  final double securityDelta;
  final double developmentSpeedDelta;
  final double monthlyCost;
}

class LanguageOption {
  const LanguageOption({
    required this.id,
    required this.name,
    required this.performanceDelta,
    required this.reliabilityDelta,
    required this.talentAvailability,
    required this.monthlyCost,
  });

  final String id;
  final String name;
  final double performanceDelta;
  final double reliabilityDelta;
  final int talentAvailability;
  final double monthlyCost;
}

class TechnologyOption {
  const TechnologyOption({
    required this.id,
    required this.name,
    required this.description,
    required this.performanceDelta,
    required this.securityDelta,
    required this.reliabilityDelta,
    required this.computeMultiplier,
    required this.developmentCost,
    required this.monthlyCost,
  });

  final String id;
  final String name;
  final String description;
  final double performanceDelta;
  final double securityDelta;
  final double reliabilityDelta;
  final double computeMultiplier;
  final double developmentCost;
  final double monthlyCost;
}

class FeatureOption {
  const FeatureOption({
    required this.id,
    required this.name,
    required this.supportedCategories,
    required this.description,
    required this.designDelta,
    required this.performanceDelta,
    required this.securityDelta,
    required this.retentionDelta,
    required this.computeMultiplier,
    required this.developmentCost,
  });

  final String id;
  final String name;
  final List<ProductCategory> supportedCategories;
  final String description;
  final double designDelta;
  final double performanceDelta;
  final double securityDelta;
  final double retentionDelta;
  final double computeMultiplier;
  final double developmentCost;
}

class Product {
  const Product({
    required this.id,
    required this.blueprintId,
    required this.name,
    required this.category,
    required this.stage,
    required this.frameworkId,
    required this.languageIds,
    required this.technologyIds,
    required this.featureIds,
    required this.developmentProgress,
    required this.users,
    required this.dau,
    required this.mau,
    required this.activationRate,
    required this.retention30d,
    required this.churnRate,
    required this.rating,
    required this.speedMs,
    required this.designScore,
    required this.securityScore,
    required this.reliability,
    required this.featureCoverage,
    required this.qualityScore,
    required this.monthlyRevenue,
    required this.monthlyCost,
    required this.monthlyGrowth,
    required this.price,
    required this.monetization,
    required this.marketingBudget,
    required this.allocatedCapacityPercent,
    required this.computeMultiplier,
    required this.createdAtMinutes,
    required this.acquired,
    this.brandAwareness = 0,
    this.brandTrust = 0.08,
    this.priceSentiment = 0,
    this.openBugs = const <ProductBug>[],
    this.fixedBugCount = 0,
    this.releasedAtMinutes = -1,
    this.monetizationIntensity = 0.5,
    this.freeTierPercent = 0.25,
  });

  final String id;
  final String blueprintId;
  final String name;
  final ProductCategory category;
  final ProductStage stage;
  final String frameworkId;
  final List<String> languageIds;
  final List<String> technologyIds;
  final List<String> featureIds;
  final double developmentProgress;
  final int users;
  final int dau;
  final int mau;
  final double activationRate;
  final double retention30d;
  final double churnRate;
  final double rating;
  final double speedMs;
  final double designScore;
  final double securityScore;
  final double reliability;
  final double featureCoverage;
  final double qualityScore;
  final double monthlyRevenue;
  final double monthlyCost;
  final double monthlyGrowth;
  final double price;
  final MonetizationModel monetization;
  final double marketingBudget;
  final double allocatedCapacityPercent;
  final double computeMultiplier;
  final int createdAtMinutes;
  final bool acquired;
  final double brandAwareness;
  final double brandTrust;
  final double priceSentiment;
  final List<ProductBug> openBugs;
  final int fixedBugCount;
  final int releasedAtMinutes;
  final double monetizationIntensity;
  final double freeTierPercent;

  Product copyWith({
    String? name,
    ProductStage? stage,
    List<String>? technologyIds,
    List<String>? featureIds,
    double? developmentProgress,
    int? users,
    int? dau,
    int? mau,
    double? activationRate,
    double? retention30d,
    double? churnRate,
    double? rating,
    double? speedMs,
    double? designScore,
    double? securityScore,
    double? reliability,
    double? featureCoverage,
    double? qualityScore,
    double? monthlyRevenue,
    double? monthlyCost,
    double? monthlyGrowth,
    double? price,
    MonetizationModel? monetization,
    double? marketingBudget,
    double? allocatedCapacityPercent,
    double? computeMultiplier,
    bool? acquired,
    double? brandAwareness,
    double? brandTrust,
    double? priceSentiment,
    List<ProductBug>? openBugs,
    int? fixedBugCount,
    int? releasedAtMinutes,
    double? monetizationIntensity,
    double? freeTierPercent,
  }) {
    return Product(
      id: id,
      blueprintId: blueprintId,
      name: name ?? this.name,
      category: category,
      stage: stage ?? this.stage,
      frameworkId: frameworkId,
      languageIds: languageIds,
      technologyIds: List<String>.unmodifiable(
        technologyIds ?? this.technologyIds,
      ),
      featureIds: List<String>.unmodifiable(featureIds ?? this.featureIds),
      developmentProgress: developmentProgress ?? this.developmentProgress,
      users: users ?? this.users,
      dau: dau ?? this.dau,
      mau: mau ?? this.mau,
      activationRate: activationRate ?? this.activationRate,
      retention30d: retention30d ?? this.retention30d,
      churnRate: churnRate ?? this.churnRate,
      rating: rating ?? this.rating,
      speedMs: speedMs ?? this.speedMs,
      designScore: designScore ?? this.designScore,
      securityScore: securityScore ?? this.securityScore,
      reliability: reliability ?? this.reliability,
      featureCoverage: featureCoverage ?? this.featureCoverage,
      qualityScore: qualityScore ?? this.qualityScore,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      monthlyCost: monthlyCost ?? this.monthlyCost,
      monthlyGrowth: monthlyGrowth ?? this.monthlyGrowth,
      price: price ?? this.price,
      monetization: monetization ?? this.monetization,
      marketingBudget: marketingBudget ?? this.marketingBudget,
      allocatedCapacityPercent:
          allocatedCapacityPercent ?? this.allocatedCapacityPercent,
      computeMultiplier: computeMultiplier ?? this.computeMultiplier,
      createdAtMinutes: createdAtMinutes,
      acquired: acquired ?? this.acquired,
      brandAwareness: brandAwareness ?? this.brandAwareness,
      brandTrust: brandTrust ?? this.brandTrust,
      priceSentiment: priceSentiment ?? this.priceSentiment,
      openBugs: List<ProductBug>.unmodifiable(openBugs ?? this.openBugs),
      fixedBugCount: fixedBugCount ?? this.fixedBugCount,
      releasedAtMinutes: releasedAtMinutes ?? this.releasedAtMinutes,
      monetizationIntensity:
          monetizationIntensity ?? this.monetizationIntensity,
      freeTierPercent: freeTierPercent ?? this.freeTierPercent,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'blueprintId': blueprintId,
    'name': name,
    'category': category.name,
    'stage': stage.name,
    'frameworkId': frameworkId,
    'languageIds': languageIds,
    'technologyIds': technologyIds,
    'featureIds': featureIds,
    'developmentProgress': developmentProgress,
    'users': users,
    'dau': dau,
    'mau': mau,
    'activationRate': activationRate,
    'retention30d': retention30d,
    'churnRate': churnRate,
    'rating': rating,
    'speedMs': speedMs,
    'designScore': designScore,
    'securityScore': securityScore,
    'reliability': reliability,
    'featureCoverage': featureCoverage,
    'qualityScore': qualityScore,
    'monthlyRevenue': monthlyRevenue,
    'monthlyCost': monthlyCost,
    'monthlyGrowth': monthlyGrowth,
    'price': price,
    'monetization': monetization.name,
    'marketingBudget': marketingBudget,
    'allocatedCapacityPercent': allocatedCapacityPercent,
    'computeMultiplier': computeMultiplier,
    'createdAtMinutes': createdAtMinutes,
    'acquired': acquired,
    'brandAwareness': brandAwareness,
    'brandTrust': brandTrust,
    'priceSentiment': priceSentiment,
    'openBugs': openBugs.map((item) => item.toJson()).toList(),
    'fixedBugCount': fixedBugCount,
    'releasedAtMinutes': releasedAtMinutes,
    'monetizationIntensity': monetizationIntensity,
    'freeTierPercent': freeTierPercent,
  };

  factory Product.fromJson(Map<String, Object?> json) => Product(
    id: json['id']! as String,
    blueprintId: json['blueprintId']! as String,
    name: json['name']! as String,
    category: ProductCategory.values.byName(json['category']! as String),
    stage: ProductStage.values.byName(json['stage']! as String),
    frameworkId: json['frameworkId']! as String,
    languageIds: (json['languageIds']! as List).cast<String>(),
    technologyIds: (json['technologyIds']! as List).cast<String>(),
    featureIds: (json['featureIds']! as List).cast<String>(),
    developmentProgress: (json['developmentProgress']! as num).toDouble(),
    users: (json['users']! as num).toInt(),
    dau: (json['dau']! as num).toInt(),
    mau: (json['mau']! as num).toInt(),
    activationRate: (json['activationRate']! as num).toDouble(),
    retention30d: (json['retention30d']! as num).toDouble(),
    churnRate: (json['churnRate']! as num).toDouble(),
    rating: (json['rating']! as num).toDouble(),
    speedMs: (json['speedMs']! as num).toDouble(),
    designScore: (json['designScore']! as num).toDouble(),
    securityScore: (json['securityScore']! as num).toDouble(),
    reliability: (json['reliability']! as num).toDouble(),
    featureCoverage: (json['featureCoverage']! as num).toDouble(),
    qualityScore: (json['qualityScore']! as num).toDouble(),
    monthlyRevenue: (json['monthlyRevenue']! as num).toDouble(),
    monthlyCost: (json['monthlyCost']! as num).toDouble(),
    monthlyGrowth: (json['monthlyGrowth']! as num).toDouble(),
    price: (json['price']! as num).toDouble(),
    monetization: MonetizationModel.values.byName(
      json['monetization']! as String,
    ),
    marketingBudget: (json['marketingBudget']! as num).toDouble(),
    allocatedCapacityPercent: (json['allocatedCapacityPercent']! as num)
        .toDouble(),
    computeMultiplier: (json['computeMultiplier']! as num).toDouble(),
    createdAtMinutes: (json['createdAtMinutes']! as num).toInt(),
    acquired: json['acquired']! as bool,
    brandAwareness: (json['brandAwareness'] as num?)?.toDouble() ?? 0,
    brandTrust: (json['brandTrust'] as num?)?.toDouble() ?? 0.08,
    priceSentiment: (json['priceSentiment'] as num?)?.toDouble() ?? 0,
    openBugs:
        (json['openBugs'] as List?)
            ?.whereType<Map>()
            .map((item) => ProductBug.fromJson(item.cast<String, Object?>()))
            .toList(growable: false) ??
        const <ProductBug>[],
    fixedBugCount: (json['fixedBugCount'] as num?)?.toInt() ?? 0,
    releasedAtMinutes: (json['releasedAtMinutes'] as num?)?.toInt() ?? -1,
    monetizationIntensity:
        (json['monetizationIntensity'] as num?)?.toDouble() ?? 0.5,
    freeTierPercent: (json['freeTierPercent'] as num?)?.toDouble() ?? 0.25,
  );
}

class ProductBug {
  const ProductBug({
    required this.id,
    required this.title,
    required this.severity,
    required this.openedAtMinutes,
  });

  final String id;
  final String title;
  final ProductBugSeverity severity;
  final int openedAtMinutes;

  int get weight => switch (severity) {
    ProductBugSeverity.minor => 1,
    ProductBugSeverity.major => 3,
    ProductBugSeverity.critical => 7,
  };

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'severity': severity.name,
    'openedAtMinutes': openedAtMinutes,
  };

  factory ProductBug.fromJson(Map<String, Object?> json) => ProductBug(
    id: json['id']! as String,
    title: json['title']! as String,
    severity: ProductBugSeverity.values.byName(json['severity']! as String),
    openedAtMinutes: (json['openedAtMinutes']! as num).toInt(),
  );
}

class EcosystemLink {
  const EcosystemLink._({
    required this.leftProductId,
    required this.rightProductId,
    required this.connectedAtMinutes,
    required this.activeAtMinutes,
  });

  factory EcosystemLink(
    String firstProductId,
    String secondProductId, {
    int connectedAtMinutes = 0,
    int activeAtMinutes = 0,
  }) {
    if (firstProductId == secondProductId) {
      throw ArgumentError('A product cannot be linked to itself.');
    }
    final ordered = <String>[firstProductId, secondProductId]..sort();
    return EcosystemLink._(
      leftProductId: ordered.first,
      rightProductId: ordered.last,
      connectedAtMinutes: connectedAtMinutes,
      activeAtMinutes: activeAtMinutes,
    );
  }

  final String leftProductId;
  final String rightProductId;
  final int connectedAtMinutes;
  final int activeAtMinutes;

  String get key => '$leftProductId::$rightProductId';

  bool contains(String productId) =>
      leftProductId == productId || rightProductId == productId;

  String other(String productId) {
    if (leftProductId == productId) {
      return rightProductId;
    }
    if (rightProductId == productId) {
      return leftProductId;
    }
    throw ArgumentError('Product is not part of this link.');
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'leftProductId': leftProductId,
    'rightProductId': rightProductId,
    'connectedAtMinutes': connectedAtMinutes,
    'activeAtMinutes': activeAtMinutes,
  };

  factory EcosystemLink.fromJson(Map<String, Object?> json) => EcosystemLink(
    json['leftProductId']! as String,
    json['rightProductId']! as String,
    connectedAtMinutes: (json['connectedAtMinutes'] as num?)?.toInt() ?? 0,
    activeAtMinutes: (json['activeAtMinutes'] as num?)?.toInt() ?? 0,
  );
}

class OfficeOption {
  const OfficeOption({
    required this.id,
    required this.name,
    required this.group,
    required this.description,
    required this.monthlyRent,
    required this.deposit,
    required this.capacity,
    required this.comfortScore,
    required this.communicationEfficiency,
    required this.hiringBoostPercent,
    required this.prestigeScore,
  });

  final String id;
  final String name;
  final String group;
  final String description;
  final double monthlyRent;
  final double deposit;
  final int capacity;
  final int comfortScore;
  final double communicationEfficiency;
  final double hiringBoostPercent;
  final int prestigeScore;
}

class ServerRoomOption {
  const ServerRoomOption({
    required this.id,
    required this.name,
    required this.group,
    required this.description,
    required this.monthlyRent,
    required this.deposit,
    required this.rackUnits,
    required this.coolingKw,
    required this.powerKw,
    required this.networkGbps,
    required this.physicalSecurityScore,
  });

  final String id;
  final String name;
  final String group;
  final String description;
  final double monthlyRent;
  final double deposit;
  final int rackUnits;
  final double coolingKw;
  final double powerKw;
  final double networkGbps;
  final int physicalSecurityScore;
}

class ServerHardwareOption {
  const ServerHardwareOption({
    required this.id,
    required this.name,
    required this.group,
    required this.description,
    required this.purchaseCost,
    required this.monthlyCost,
    required this.rackUnits,
    required this.computeUnits,
    required this.memoryGb,
    required this.storageGb,
    required this.powerKw,
    required this.heatKw,
    required this.networkGbps,
    required this.hardwareReliability,
  });

  final String id;
  final String name;
  final String group;
  final String description;
  final double purchaseCost;
  final double monthlyCost;
  final int rackUnits;
  final double computeUnits;
  final double memoryGb;
  final double storageGb;
  final double powerKw;
  final double heatKw;
  final double networkGbps;
  final double hardwareReliability;
}

class InstalledServer {
  const InstalledServer({required this.hardwareId, required this.count});

  final String hardwareId;
  final int count;

  InstalledServer copyWith({int? count}) =>
      InstalledServer(hardwareId: hardwareId, count: count ?? this.count);

  Map<String, Object?> toJson() => <String, Object?>{
    'hardwareId': hardwareId,
    'count': count,
  };

  factory InstalledServer.fromJson(Map<String, Object?> json) =>
      InstalledServer(
        hardwareId: json['hardwareId']! as String,
        count: (json['count']! as num).toInt(),
      );
}

class CompetitorBenchmark {
  const CompetitorBenchmark({
    required this.id,
    required this.companyName,
    required this.productName,
    required this.category,
    required this.speedMs,
    required this.designScore,
    required this.securityScore,
    required this.reliability,
    required this.featureIds,
    required this.users,
    required this.monthlyPrice,
    this.marketScore = 0,
  });

  final String id;
  final String companyName;
  final String productName;
  final ProductCategory category;
  final double speedMs;
  final double designScore;
  final double securityScore;
  final double reliability;
  final List<String> featureIds;
  final int users;
  final double monthlyPrice;
  final double marketScore;

  CompetitorBenchmark copyWith({int? users, double? marketScore}) =>
      CompetitorBenchmark(
        id: id,
        companyName: companyName,
        productName: productName,
        category: category,
        speedMs: speedMs,
        designScore: designScore,
        securityScore: securityScore,
        reliability: reliability,
        featureIds: featureIds,
        users: users ?? this.users,
        monthlyPrice: monthlyPrice,
        marketScore: marketScore ?? this.marketScore,
      );
}

class MarketSegment {
  const MarketSegment({
    required this.id,
    required this.name,
    required this.category,
    required this.addressableUsers,
    required this.speedWeight,
    required this.designWeight,
    required this.securityWeight,
    required this.featureWeight,
    required this.priceWeight,
  });

  final String id;
  final String name;
  final ProductCategory category;
  final int addressableUsers;
  final double speedWeight;
  final double designWeight;
  final double securityWeight;
  final double featureWeight;
  final double priceWeight;
}

class InvestorProfile {
  const InvestorProfile({
    required this.id,
    required this.name,
    required this.thesis,
    required this.preferredCategories,
    required this.availableCapital,
    required this.minimumReadiness,
    required this.riskTolerance,
    required this.maximumEquityPercent,
  });

  final String id;
  final String name;
  final String thesis;
  final List<ProductCategory> preferredCategories;
  final double availableCapital;
  final double minimumReadiness;
  final double riskTolerance;
  final double maximumEquityPercent;
}

class InvestorOffer {
  const InvestorOffer({
    required this.id,
    required this.investorId,
    required this.productId,
    required this.requestedAmount,
    required this.offeredAmount,
    required this.equityPercent,
    required this.revenueSharePercent,
    required this.createdAtMinutes,
  });

  final String id;
  final String investorId;
  final String productId;
  final double requestedAmount;
  final double offeredAmount;
  final double equityPercent;
  final double revenueSharePercent;
  final int createdAtMinutes;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'investorId': investorId,
    'productId': productId,
    'requestedAmount': requestedAmount,
    'offeredAmount': offeredAmount,
    'equityPercent': equityPercent,
    'revenueSharePercent': revenueSharePercent,
    'createdAtMinutes': createdAtMinutes,
  };

  factory InvestorOffer.fromJson(Map<String, Object?> json) => InvestorOffer(
    id: json['id']! as String,
    investorId: json['investorId']! as String,
    productId: json['productId']! as String,
    requestedAmount: (json['requestedAmount']! as num).toDouble(),
    offeredAmount: (json['offeredAmount']! as num).toDouble(),
    equityPercent: (json['equityPercent']! as num).toDouble(),
    revenueSharePercent: (json['revenueSharePercent']! as num).toDouble(),
    createdAtMinutes: (json['createdAtMinutes']! as num).toInt(),
  );
}

class InvestorAgreement {
  const InvestorAgreement({
    required this.id,
    required this.investorId,
    required this.productId,
    required this.investedAmount,
    required this.equityPercent,
    required this.revenueSharePercent,
    required this.buybackPrice,
  });

  final String id;
  final String investorId;
  final String productId;
  final double investedAmount;
  final double equityPercent;
  final double revenueSharePercent;
  final double buybackPrice;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'investorId': investorId,
    'productId': productId,
    'investedAmount': investedAmount,
    'equityPercent': equityPercent,
    'revenueSharePercent': revenueSharePercent,
    'buybackPrice': buybackPrice,
  };

  factory InvestorAgreement.fromJson(Map<String, Object?> json) =>
      InvestorAgreement(
        id: json['id']! as String,
        investorId: json['investorId']! as String,
        productId: json['productId']! as String,
        investedAmount: (json['investedAmount']! as num).toDouble(),
        equityPercent: (json['equityPercent']! as num).toDouble(),
        revenueSharePercent: (json['revenueSharePercent']! as num).toDouble(),
        buybackPrice: (json['buybackPrice']! as num).toDouble(),
      );
}

class MarketCompany {
  const MarketCompany({
    required this.id,
    required this.companyName,
    required this.productName,
    required this.category,
    required this.description,
    required this.valuation,
    required this.productPrice,
    required this.users,
    required this.monthlyRevenue,
    required this.monthlyProfit,
    required this.growthRate,
    required this.securityScore,
    required this.speedMs,
    required this.designScore,
    required this.computeDemand,
    required this.availableStakePercent,
  });

  final String id;
  final String companyName;
  final String productName;
  final ProductCategory category;
  final String description;
  final double valuation;
  final double productPrice;
  final int users;
  final double monthlyRevenue;
  final double monthlyProfit;
  final double growthRate;
  final double securityScore;
  final double speedMs;
  final double designScore;
  final double computeDemand;
  final double availableStakePercent;
}

class PortfolioHolding {
  const PortfolioHolding({
    required this.companyId,
    required this.ownershipPercent,
    required this.amountPaid,
  });

  final String companyId;
  final double ownershipPercent;
  final double amountPaid;

  PortfolioHolding copyWith({double? ownershipPercent, double? amountPaid}) =>
      PortfolioHolding(
        companyId: companyId,
        ownershipPercent: ownershipPercent ?? this.ownershipPercent,
        amountPaid: amountPaid ?? this.amountPaid,
      );

  Map<String, Object?> toJson() => <String, Object?>{
    'companyId': companyId,
    'ownershipPercent': ownershipPercent,
    'amountPaid': amountPaid,
  };

  factory PortfolioHolding.fromJson(Map<String, Object?> json) =>
      PortfolioHolding(
        companyId: json['companyId']! as String,
        ownershipPercent: (json['ownershipPercent']! as num).toDouble(),
        amountPaid: (json['amountPaid']! as num).toDouble(),
      );
}

class NewsItem {
  const NewsItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.simulationMinutes,
    required this.critical,
  });

  final String id;
  final NewsKind kind;
  final String title;
  final String body;
  final int simulationMinutes;
  final bool critical;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'kind': kind.name,
    'title': title,
    'body': body,
    'simulationMinutes': simulationMinutes,
    'critical': critical,
  };

  factory NewsItem.fromJson(Map<String, Object?> json) => NewsItem(
    id: json['id']! as String,
    kind: NewsKind.values.byName(json['kind']! as String),
    title: json['title']! as String,
    body: json['body']! as String,
    simulationMinutes: (json['simulationMinutes']! as num).toInt(),
    critical: json['critical']! as bool,
  );
}
