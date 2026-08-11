// UAT_FIXPACK_R1
import 'models.dart';

enum ProductScope { starter, standard, advanced, moonshot }

enum DevelopmentPhase {
  discovery,
  architecture,
  core,
  features,
  stabilization,
  release,
}

enum AdvertisingBillingModel { cpm, cpc, hybrid }

enum AdvertisingCampaignStatus { active, completed, stopped }

class ProductStrategyProfile {
  const ProductStrategyProfile({
    required this.blueprintId,
    required this.scope,
    required this.shortDescription,
    required this.baseHours,
    required this.setupCost,
    required this.minimumTeamSize,
    required this.optimalTeamSize,
    required this.maximumEfficientTeamSize,
    required this.requiredInvestorCount,
    required this.maximumLanguageCount,
    required this.maximumTechnologyCount,
    required this.allowedFrameworkIds,
    required this.recommendedLanguageIds,
    required this.allowedMonetizationModels,
    required this.contractsUnlock,
    required this.initialTrust,
  });

  final String blueprintId;
  final ProductScope scope;
  final String shortDescription;
  final double baseHours;
  final double setupCost;
  final int minimumTeamSize;
  final int optimalTeamSize;
  final int maximumEfficientTeamSize;
  final int requiredInvestorCount;
  final int maximumLanguageCount;
  final int maximumTechnologyCount;
  final List<String> allowedFrameworkIds;
  final List<String> recommendedLanguageIds;
  final List<MonetizationModel> allowedMonetizationModels;
  final bool contractsUnlock;
  final double initialTrust;
}

class LanguageStrategyProfile {
  const LanguageStrategyProfile({
    required this.languageId,
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.bestForBlueprintIds,
    required this.complexityMultiplier,
  });

  final String languageId;
  final String summary;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> bestForBlueprintIds;
  final double complexityMultiplier;
}

class FrameworkStrategyProfile {
  const FrameworkStrategyProfile({
    required this.frameworkId,
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.requiredLanguageIds,
    required this.complexityMultiplier,
  });

  final String frameworkId;
  final String summary;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> requiredLanguageIds;
  final double complexityMultiplier;
}

class DevelopmentPhaseDefinition {
  const DevelopmentPhaseDefinition({
    required this.phase,
    required this.name,
    required this.start,
    required this.end,
    required this.description,
    required this.criticalRoles,
  });

  final DevelopmentPhase phase;
  final String name;
  final double start;
  final double end;
  final String description;
  final List<EmployeeRole> criticalRoles;
}

class DevelopmentStaffingSnapshot {
  const DevelopmentStaffingSnapshot({
    required this.teamSize,
    required this.minimumTeamSize,
    required this.optimalTeamSize,
    required this.maximumEfficientTeamSize,
    required this.languageCoverage,
    required this.roleCoverage,
    required this.efficiency,
    required this.status,
    required this.criticalEmployeeIds,
    required this.movableEmployeeIds,
  });

  final int teamSize;
  final int minimumTeamSize;
  final int optimalTeamSize;
  final int maximumEfficientTeamSize;
  final double languageCoverage;
  final double roleCoverage;
  final double efficiency;
  final String status;
  final List<String> criticalEmployeeIds;
  final List<String> movableEmployeeIds;
}

class AdvertisingAgency {
  const AdvertisingAgency({
    required this.id,
    required this.name,
    required this.description,
    required this.quality,
    required this.minimumBudget,
    required this.feePercent,
    required this.forecastAccuracy,
  });

  final String id;
  final String name;
  final String description;
  final double quality;
  final double minimumBudget;
  final double feePercent;
  final double forecastAccuracy;
}

class AdvertisingChannel {
  const AdvertisingChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.billingModel,
    required this.baseCpm,
    required this.baseCpc,
    required this.trustWeight,
    required this.brandWeight,
    required this.bestForCategories,
  });

  final String id;
  final String name;
  final String description;
  final AdvertisingBillingModel billingModel;
  final double baseCpm;
  final double baseCpc;
  final double trustWeight;
  final double brandWeight;
  final List<ProductCategory> bestForCategories;
}

class AdvertisingCampaign {
  const AdvertisingCampaign({
    required this.id,
    required this.productId,
    required this.agencyId,
    required this.channelId,
    required this.budget,
    required this.startedAtMinutes,
    required this.endsAtMinutes,
    required this.status,
    required this.projectedImpressions,
    required this.projectedClicks,
    required this.projectedUsersLow,
    required this.projectedUsersExpected,
    required this.projectedUsersHigh,
    required this.deliveredUsers,
  });

  final String id;
  final String productId;
  final String agencyId;
  final String channelId;
  final double budget;
  final int startedAtMinutes;
  final int endsAtMinutes;
  final AdvertisingCampaignStatus status;
  final int projectedImpressions;
  final int projectedClicks;
  final int projectedUsersLow;
  final int projectedUsersExpected;
  final int projectedUsersHigh;
  final int deliveredUsers;

  AdvertisingCampaign copyWith({
    AdvertisingCampaignStatus? status,
    int? deliveredUsers,
  }) => AdvertisingCampaign(
    id: id,
    productId: productId,
    agencyId: agencyId,
    channelId: channelId,
    budget: budget,
    startedAtMinutes: startedAtMinutes,
    endsAtMinutes: endsAtMinutes,
    status: status ?? this.status,
    projectedImpressions: projectedImpressions,
    projectedClicks: projectedClicks,
    projectedUsersLow: projectedUsersLow,
    projectedUsersExpected: projectedUsersExpected,
    projectedUsersHigh: projectedUsersHigh,
    deliveredUsers: deliveredUsers ?? this.deliveredUsers,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'productId': productId,
    'agencyId': agencyId,
    'channelId': channelId,
    'budget': budget,
    'startedAtMinutes': startedAtMinutes,
    'endsAtMinutes': endsAtMinutes,
    'status': status.name,
    'projectedImpressions': projectedImpressions,
    'projectedClicks': projectedClicks,
    'projectedUsersLow': projectedUsersLow,
    'projectedUsersExpected': projectedUsersExpected,
    'projectedUsersHigh': projectedUsersHigh,
    'deliveredUsers': deliveredUsers,
  };

  factory AdvertisingCampaign.fromJson(
    Map<String, Object?> json,
  ) => AdvertisingCampaign(
    id: json['id']! as String,
    productId: json['productId']! as String,
    agencyId: json['agencyId']! as String,
    channelId: json['channelId']! as String,
    budget: (json['budget']! as num).toDouble(),
    startedAtMinutes: (json['startedAtMinutes']! as num).toInt(),
    endsAtMinutes: (json['endsAtMinutes']! as num).toInt(),
    status: AdvertisingCampaignStatus.values.byName(json['status']! as String),
    projectedImpressions: (json['projectedImpressions']! as num).toInt(),
    projectedClicks: (json['projectedClicks']! as num).toInt(),
    projectedUsersLow: (json['projectedUsersLow']! as num).toInt(),
    projectedUsersExpected: (json['projectedUsersExpected']! as num).toInt(),
    projectedUsersHigh: (json['projectedUsersHigh']! as num).toInt(),
    deliveredUsers: (json['deliveredUsers']! as num).toInt(),
  );
}

class ProductFeatureDevelopment {
  const ProductFeatureDevelopment({
    required this.productId,
    required this.featureId,
    required this.startedAtMinutes,
    required this.requiredHours,
    required this.progress,
  });

  final String productId;
  final String featureId;
  final int startedAtMinutes;
  final double requiredHours;
  final double progress;

  ProductFeatureDevelopment copyWith({double? progress}) =>
      ProductFeatureDevelopment(
        productId: productId,
        featureId: featureId,
        startedAtMinutes: startedAtMinutes,
        requiredHours: requiredHours,
        progress: progress ?? this.progress,
      );

  Map<String, Object?> toJson() => <String, Object?>{
    'productId': productId,
    'featureId': featureId,
    'startedAtMinutes': startedAtMinutes,
    'requiredHours': requiredHours,
    'progress': progress,
  };

  factory ProductFeatureDevelopment.fromJson(Map<String, Object?> json) =>
      ProductFeatureDevelopment(
        productId: json['productId']! as String,
        featureId: json['featureId']! as String,
        startedAtMinutes: (json['startedAtMinutes']! as num).toInt(),
        requiredHours: (json['requiredHours']! as num).toDouble(),
        progress: (json['progress']! as num).toDouble(),
      );
}

class CompanyLoan {
  const CompanyLoan({
    required this.principal,
    required this.remaining,
    required this.issuedAtMinutes,
    required this.weeklyPayment,
    required this.interestRate,
  });

  final double principal;
  final double remaining;
  final int issuedAtMinutes;
  final double weeklyPayment;
  final double interestRate;

  double get repaidFraction =>
      principal <= 0 ? 1 : (1 - remaining / principal).clamp(0, 1).toDouble();

  int get scheduledWeeks {
    if (weeklyPayment <= 0) return 1;
    return (principal / weeklyPayment).ceil().clamp(1, 520).toInt();
  }

  double earlyPayoffAmountAt(int simulationMinutes) {
    if (remaining <= 0) return 0;
    if (interestRate <= 0 || principal <= 0) return remaining;

    final originalCashPrincipal = principal / (1 + interestRate);
    final totalScheduledInterest = principal - originalCashPrincipal;
    final elapsedWeeks = ((simulationMinutes - issuedAtMinutes) / (7 * 1440))
        .clamp(0, scheduledWeeks)
        .toDouble();
    final timeRemainingFraction =
        ((scheduledWeeks - elapsedWeeks) / scheduledWeeks)
            .clamp(0.0, 1.0)
            .toDouble();
    final balanceRemainingFraction = (remaining / principal)
        .clamp(0.0, 1.0)
        .toDouble();
    final interestFraction = timeRemainingFraction < balanceRemainingFraction
        ? timeRemainingFraction
        : balanceRemainingFraction;
    final unearnedInterest = totalScheduledInterest * interestFraction;
    return (remaining - unearnedInterest).clamp(0.0, remaining).toDouble();
  }

  double earlyPayoffSavingsAt(int simulationMinutes) =>
      (remaining - earlyPayoffAmountAt(simulationMinutes))
          .clamp(0.0, remaining)
          .toDouble();

  CompanyLoan copyWith({double? remaining}) => CompanyLoan(
    principal: principal,
    remaining: remaining ?? this.remaining,
    issuedAtMinutes: issuedAtMinutes,
    weeklyPayment: weeklyPayment,
    interestRate: interestRate,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'principal': principal,
    'remaining': remaining,
    'issuedAtMinutes': issuedAtMinutes,
    'weeklyPayment': weeklyPayment,
    'interestRate': interestRate,
  };

  factory CompanyLoan.fromJson(Map<String, Object?> json) => CompanyLoan(
    principal: (json['principal']! as num).toDouble(),
    remaining: (json['remaining']! as num).toDouble(),
    issuedAtMinutes: (json['issuedAtMinutes']! as num).toInt(),
    weeklyPayment: (json['weeklyPayment']! as num).toDouble(),
    interestRate: (json['interestRate']! as num).toDouble(),
  );
}

class ProductPriceChange {
  const ProductPriceChange({
    required this.productId,
    required this.previousPrice,
    required this.newPrice,
    required this.changedAtMinutes,
    required this.initialSentimentShock,
  });

  final String productId;
  final double previousPrice;
  final double newPrice;
  final int changedAtMinutes;
  final double initialSentimentShock;

  Map<String, Object?> toJson() => <String, Object?>{
    'productId': productId,
    'previousPrice': previousPrice,
    'newPrice': newPrice,
    'changedAtMinutes': changedAtMinutes,
    'initialSentimentShock': initialSentimentShock,
  };

  factory ProductPriceChange.fromJson(Map<String, Object?> json) =>
      ProductPriceChange(
        productId: json['productId']! as String,
        previousPrice: (json['previousPrice']! as num).toDouble(),
        newPrice: (json['newPrice']! as num).toDouble(),
        changedAtMinutes: (json['changedAtMinutes']! as num).toInt(),
        initialSentimentShock: (json['initialSentimentShock']! as num)
            .toDouble(),
      );
}

class PriceImpactForecast {
  const PriceImpactForecast({
    required this.currentPrice,
    required this.proposedPrice,
    required this.expectedRevenueBefore,
    required this.expectedRevenueAfter,
    required this.expectedUserChangePercent,
    required this.expectedChurnDelta,
    required this.sentimentShock,
    required this.note,
  });

  final double currentPrice;
  final double proposedPrice;
  final double expectedRevenueBefore;
  final double expectedRevenueAfter;
  final double expectedUserChangePercent;
  final double expectedChurnDelta;
  final double sentimentShock;
  final String note;
}

class AdvertisingForecast {
  const AdvertisingForecast({
    required this.impressions,
    required this.clicks,
    required this.usersLow,
    required this.usersExpected,
    required this.usersHigh,
    required this.effectiveBudget,
    required this.note,
  });

  final int impressions;
  final int clicks;
  final int usersLow;
  final int usersExpected;
  final int usersHigh;
  final double effectiveBudget;
  final String note;
}
