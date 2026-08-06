enum HostingKind {
  shared,
  vps,
  managed,
  cloudCompute,
  managedDatabase,
  objectStorage,
  cdn,
  serverless,
  owned,
}

class HostingPlan {
  const HostingPlan({
    required this.id,
    required this.provider,
    required this.name,
    required this.kind,
    required this.description,
    required this.computeUnits,
    required this.storageGb,
    required this.bandwidthTb,
    required this.sla,
    required this.approximateUsers,
    required this.monthlyCost,
    required this.setupCost,
    required this.reliability,
    required this.scalability,
    required this.strengths,
    required this.weaknesses,
    required this.risks,
    required this.requiredRoles,
  });

  final String id;
  final String provider;
  final String name;
  final HostingKind kind;
  final String description;
  final double computeUnits;
  final double storageGb;
  final double bandwidthTb;
  final double sla;
  final int approximateUsers;
  final double monthlyCost;
  final double setupCost;
  final double reliability;
  final double scalability;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> risks;
  final List<String> requiredRoles;
}

class GlossaryEntry {
  const GlossaryEntry({
    required this.id,
    required this.term,
    required this.shortExplanation,
    required this.detailedExplanation,
    required this.gameExample,
    required this.usedIn,
    required this.whyImportant,
  });

  final String id;
  final String term;
  final String shortExplanation;
  final String detailedExplanation;
  final String gameExample;
  final List<String> usedIn;
  final String whyImportant;
}

class TechnologyLimitExplanation {
  const TechnologyLimitExplanation({
    required this.allowed,
    required this.selected,
    required this.baseLimit,
    required this.scopeAdjustment,
    required this.frameworkAdjustment,
    required this.featureAdjustment,
    required this.teamAdjustment,
    required this.maintenancePenalty,
    required this.reasons,
  });

  final int allowed;
  final int selected;
  final int baseLimit;
  final int scopeAdjustment;
  final int frameworkAdjustment;
  final int featureAdjustment;
  final int teamAdjustment;
  final int maintenancePenalty;
  final List<String> reasons;

  bool get reached => selected >= allowed;
  bool get exceeded => selected > allowed;
}

class TechnologyImpact {
  const TechnologyImpact({
    required this.developmentHoursDelta,
    required this.technicalDebtDelta,
    required this.infrastructureCostDelta,
    required this.hiringDifficultyDelta,
    required this.developmentSpeedDelta,
    required this.supportDifficultyDelta,
    required this.stabilityDelta,
  });

  final double developmentHoursDelta;
  final double technicalDebtDelta;
  final double infrastructureCostDelta;
  final double hiringDifficultyDelta;
  final double developmentSpeedDelta;
  final double supportDifficultyDelta;
  final double stabilityDelta;
}

class TechnologyAvailability {
  const TechnologyAvailability({
    required this.enabled,
    required this.mandatory,
    required this.reason,
    required this.nextStep,
  });

  final bool enabled;
  final bool mandatory;
  final String? reason;
  final String? nextStep;
}

class SpecialistDeficit {
  const SpecialistDeficit({
    required this.roleId,
    required this.roleName,
    required this.languageId,
    required this.languageName,
    required this.technologyId,
    required this.technologyName,
    required this.minimumSkill,
    required this.missingCount,
    required this.stageName,
    required this.effect,
    required this.solutions,
  });

  final String roleId;
  final String roleName;
  final String? languageId;
  final String? languageName;
  final String? technologyId;
  final String? technologyName;
  final int minimumSkill;
  final int missingCount;
  final String stageName;
  final String effect;
  final List<String> solutions;

  String get message {
    final count = missingCount == 1
        ? '1 специалиста'
        : '$missingCount специалистов';
    final stack = <String>[?languageName, ?technologyName].join(' / ');
    return 'Не хватает $count: $roleName${stack.isEmpty ? '' : ' со знанием $stack'}, навык $minimumSkill+.';
  }
}

class EcosystemIntegrationProfile {
  const EcosystemIntegrationProfile({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.integrationDays,
    required this.growthBoost,
    required this.retentionBoost,
    required this.computeMultiplier,
    required this.risk,
    required this.requirements,
  });

  final String id;
  final String title;
  final String description;
  final double cost;
  final int integrationDays;
  final double growthBoost;
  final double retentionBoost;
  final double computeMultiplier;
  final double risk;
  final List<String> requirements;
}

class ContentValidationIssue {
  const ContentValidationIssue({required this.code, required this.message});
  final String code;
  final String message;
}
