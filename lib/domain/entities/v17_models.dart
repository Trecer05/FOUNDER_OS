enum InfrastructureService {
  /// Only for V16-and-older installed hardware. New purchases are always
  /// dedicated to a concrete service pool.
  sharedLegacy,
  appApi,
  dataStorage,
  aiCompute,
}

class ProductServiceRoute {
  const ProductServiceRoute({
    required this.productId,
    required this.service,
    required this.dataCenterSiteId,
  });

  final String productId;
  final InfrastructureService service;

  /// Empty string means the currently rented server room. Owned data centers
  /// use [OwnedDataCenterSite.id].
  final String dataCenterSiteId;

  Map<String, Object?> toJson() => <String, Object?>{
    'productId': productId,
    'service': service.name,
    'dataCenterSiteId': dataCenterSiteId,
  };

  factory ProductServiceRoute.fromJson(Map<String, Object?> json) =>
      ProductServiceRoute(
        productId: json['productId']! as String,
        service: InfrastructureService.values.byName(
          json['service']! as String,
        ),
        dataCenterSiteId: json['dataCenterSiteId'] as String? ?? '',
      );
}

class EmployeeRelocationAssignment {
  const EmployeeRelocationAssignment({
    required this.id,
    required this.employeeId,
    required this.officeSiteId,
    required this.destinationCityId,
    required this.startedAtMinutes,
    required this.completesAtMinutes,
    required this.cost,
  });

  final String id;
  final String employeeId;
  final String officeSiteId;
  final String destinationCityId;
  final int startedAtMinutes;
  final int completesAtMinutes;
  final double cost;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'employeeId': employeeId,
    'officeSiteId': officeSiteId,
    'destinationCityId': destinationCityId,
    'startedAtMinutes': startedAtMinutes,
    'completesAtMinutes': completesAtMinutes,
    'cost': cost,
  };

  factory EmployeeRelocationAssignment.fromJson(Map<String, Object?> json) =>
      EmployeeRelocationAssignment(
        id: json['id']! as String,
        employeeId: json['employeeId']! as String,
        officeSiteId: json['officeSiteId']! as String,
        destinationCityId: json['destinationCityId']! as String,
        startedAtMinutes: (json['startedAtMinutes']! as num).toInt(),
        completesAtMinutes: (json['completesAtMinutes']! as num).toInt(),
        cost: (json['cost']! as num).toDouble(),
      );
}

class MonetizationExperienceImpact {
  const MonetizationExperienceImpact({
    required this.activationDelta,
    required this.retentionDelta,
    required this.churnDelta,
    required this.trustDelta,
  });

  final double activationDelta;
  final double retentionDelta;
  final double churnDelta;
  final double trustDelta;
}

enum ResearchTargetKind { feature, technology }

class CompanyResearchProject {
  const CompanyResearchProject({
    required this.key,
    required this.kind,
    required this.targetId,
    required this.startedAtMinutes,
    required this.completesAtMinutes,
    required this.cost,
  });

  final String key;
  final ResearchTargetKind kind;
  final String targetId;
  final int startedAtMinutes;
  final int completesAtMinutes;
  final double cost;

  Map<String, Object?> toJson() => <String, Object?>{
    'key': key,
    'kind': kind.name,
    'targetId': targetId,
    'startedAtMinutes': startedAtMinutes,
    'completesAtMinutes': completesAtMinutes,
    'cost': cost,
  };

  factory CompanyResearchProject.fromJson(Map<String, Object?> json) =>
      CompanyResearchProject(
        key: json['key']! as String,
        kind: ResearchTargetKind.values.byName(json['kind']! as String),
        targetId: json['targetId']! as String,
        startedAtMinutes: (json['startedAtMinutes']! as num).toInt(),
        completesAtMinutes: (json['completesAtMinutes']! as num).toInt(),
        cost: (json['cost']! as num).toDouble(),
      );
}

enum LegendProductBonusKind {
  performance,
  reliability,
  aiQuality,
  retention,
  activation,
  growth,
  brand,
  security,
}

class LegendMarketOffer {
  const LegendMarketOffer({
    required this.legendId,
    required this.productId,
    required this.bonusKind,
    required this.availableUntilMinutes,
  });

  final String legendId;
  final String productId;
  final LegendProductBonusKind bonusKind;
  final int availableUntilMinutes;

  Map<String, Object?> toJson() => <String, Object?>{
    'legendId': legendId,
    'productId': productId,
    'bonusKind': bonusKind.name,
    'availableUntilMinutes': availableUntilMinutes,
  };

  factory LegendMarketOffer.fromJson(Map<String, Object?> json) =>
      LegendMarketOffer(
        legendId: json['legendId']! as String,
        productId: json['productId']! as String,
        bonusKind: LegendProductBonusKind.values.byName(
          json['bonusKind']! as String,
        ),
        availableUntilMinutes: (json['availableUntilMinutes']! as num).toInt(),
      );
}

class HiredLegendBonus {
  const HiredLegendBonus({
    required this.legendId,
    required this.employeeId,
    required this.productId,
    required this.bonusKind,
  });

  final String legendId;
  final String employeeId;
  final String productId;
  final LegendProductBonusKind bonusKind;

  Map<String, Object?> toJson() => <String, Object?>{
    'legendId': legendId,
    'employeeId': employeeId,
    'productId': productId,
    'bonusKind': bonusKind.name,
  };

  factory HiredLegendBonus.fromJson(Map<String, Object?> json) =>
      HiredLegendBonus(
        legendId: json['legendId']! as String,
        employeeId: json['employeeId']! as String,
        productId: json['productId']! as String,
        bonusKind: LegendProductBonusKind.values.byName(
          json['bonusKind']! as String,
        ),
      );
}

class PendingEmployeeDeparture {
  const PendingEmployeeDeparture({
    required this.employeeId,
    required this.createdAtMinutes,
    required this.deadlineMinutes,
    required this.requiredRaisePercent,
  });

  final String employeeId;
  final int createdAtMinutes;
  final int deadlineMinutes;
  final double requiredRaisePercent;

  Map<String, Object?> toJson() => <String, Object?>{
    'employeeId': employeeId,
    'createdAtMinutes': createdAtMinutes,
    'deadlineMinutes': deadlineMinutes,
    'requiredRaisePercent': requiredRaisePercent,
  };

  factory PendingEmployeeDeparture.fromJson(Map<String, Object?> json) =>
      PendingEmployeeDeparture(
        employeeId: json['employeeId']! as String,
        createdAtMinutes: (json['createdAtMinutes']! as num).toInt(),
        deadlineMinutes: (json['deadlineMinutes']! as num).toInt(),
        requiredRaisePercent: (json['requiredRaisePercent']! as num).toDouble(),
      );
}

class IndustryEventOpportunity {
  const IndustryEventOpportunity({
    required this.id,
    required this.templateId,
    required this.availableUntilMinutes,
    required this.eventAtMinutes,
  });

  final String id;
  final String templateId;
  final int availableUntilMinutes;
  final int eventAtMinutes;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'templateId': templateId,
    'availableUntilMinutes': availableUntilMinutes,
    'eventAtMinutes': eventAtMinutes,
  };

  factory IndustryEventOpportunity.fromJson(Map<String, Object?> json) =>
      IndustryEventOpportunity(
        id: json['id']! as String,
        templateId: json['templateId']! as String,
        availableUntilMinutes: (json['availableUntilMinutes']! as num).toInt(),
        eventAtMinutes: (json['eventAtMinutes']! as num).toInt(),
      );
}

class BookedIndustryEvent {
  const BookedIndustryEvent({
    required this.opportunityId,
    required this.templateId,
    required this.productIds,
    required this.eventAtMinutes,
    required this.totalCost,
  });

  final String opportunityId;
  final String templateId;
  final List<String> productIds;
  final int eventAtMinutes;
  final double totalCost;

  Map<String, Object?> toJson() => <String, Object?>{
    'opportunityId': opportunityId,
    'templateId': templateId,
    'productIds': productIds,
    'eventAtMinutes': eventAtMinutes,
    'totalCost': totalCost,
  };

  factory BookedIndustryEvent.fromJson(Map<String, Object?> json) =>
      BookedIndustryEvent(
        opportunityId: json['opportunityId']! as String,
        templateId: json['templateId']! as String,
        productIds: (json['productIds']! as List).cast<String>(),
        eventAtMinutes: (json['eventAtMinutes']! as num).toInt(),
        totalCost: (json['totalCost']! as num).toDouble(),
      );
}

enum CompanyNotificationKind {
  employee,
  legend,
  investor,
  tax,
  event,
  research,
  product,
  finance,
  legacy,
}

class CompanyNotification {
  const CompanyNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.simulationMinutes,
    required this.read,
  });

  final String id;
  final CompanyNotificationKind kind;
  final String title;
  final String body;
  final int simulationMinutes;
  final bool read;

  CompanyNotification copyWith({bool? read}) => CompanyNotification(
    id: id,
    kind: kind,
    title: title,
    body: body,
    simulationMinutes: simulationMinutes,
    read: read ?? this.read,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'kind': kind.name,
    'title': title,
    'body': body,
    'simulationMinutes': simulationMinutes,
    'read': read,
  };

  factory CompanyNotification.fromJson(Map<String, Object?> json) =>
      CompanyNotification(
        id: json['id']! as String,
        kind: CompanyNotificationKind.values.byName(json['kind']! as String),
        title: json['title']! as String,
        body: json['body']! as String,
        simulationMinutes: (json['simulationMinutes']! as num).toInt(),
        read: json['read'] as bool? ?? false,
      );
}

class WorldProjectProgress {
  const WorldProjectProgress({
    required this.projectId,
    required this.completedPhases,
    required this.activePhaseCompletesAtMinutes,
    required this.completedUpgradeIds,
    required this.activeUpgradeId,
    required this.activeUpgradeCompletesAtMinutes,
  });

  final String projectId;
  final int completedPhases;
  final int activePhaseCompletesAtMinutes;
  final List<String> completedUpgradeIds;
  final String activeUpgradeId;
  final int activeUpgradeCompletesAtMinutes;

  WorldProjectProgress copyWith({
    int? completedPhases,
    int? activePhaseCompletesAtMinutes,
    List<String>? completedUpgradeIds,
    String? activeUpgradeId,
    int? activeUpgradeCompletesAtMinutes,
  }) => WorldProjectProgress(
    projectId: projectId,
    completedPhases: completedPhases ?? this.completedPhases,
    activePhaseCompletesAtMinutes:
        activePhaseCompletesAtMinutes ?? this.activePhaseCompletesAtMinutes,
    completedUpgradeIds: completedUpgradeIds ?? this.completedUpgradeIds,
    activeUpgradeId: activeUpgradeId ?? this.activeUpgradeId,
    activeUpgradeCompletesAtMinutes:
        activeUpgradeCompletesAtMinutes ?? this.activeUpgradeCompletesAtMinutes,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'projectId': projectId,
    'completedPhases': completedPhases,
    'activePhaseCompletesAtMinutes': activePhaseCompletesAtMinutes,
    'completedUpgradeIds': completedUpgradeIds,
    'activeUpgradeId': activeUpgradeId,
    'activeUpgradeCompletesAtMinutes': activeUpgradeCompletesAtMinutes,
  };

  factory WorldProjectProgress.fromJson(Map<String, Object?> json) =>
      WorldProjectProgress(
        projectId: json['projectId']! as String,
        completedPhases: (json['completedPhases'] as num?)?.toInt() ?? 0,
        activePhaseCompletesAtMinutes:
            (json['activePhaseCompletesAtMinutes'] as num?)?.toInt() ?? -1,
        completedUpgradeIds:
            (json['completedUpgradeIds'] as List?)?.cast<String>() ??
            const <String>[],
        activeUpgradeId: json['activeUpgradeId'] as String? ?? '',
        activeUpgradeCompletesAtMinutes:
            (json['activeUpgradeCompletesAtMinutes'] as num?)?.toInt() ?? -1,
      );
}

enum EcosystemDoctrine { balanced, open, dominant }

enum PostGamePath {
  none,
  infiniteGrowth,
  sellAndExit,
  openFoundation,
  holdingCompany,
}
