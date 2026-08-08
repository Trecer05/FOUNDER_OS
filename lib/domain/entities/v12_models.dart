enum FounderBackground {
  engineer,
  designer,
  product,
  growth,
  sales,
  operations,
}

enum FounderSkill {
  engineering,
  design,
  product,
  growth,
  negotiation,
  operations,
}

enum FounderDevelopmentStage { planning, design, implementation, debugging }

class FounderCompanyProfile {
  const FounderCompanyProfile({
    required this.configured,
    required this.companyName,
    required this.founderName,
    required this.logoId,
    required this.startingBudget,
    required this.background,
    required this.skills,
  });

  const FounderCompanyProfile.unconfigured()
    : configured = false,
      companyName = 'FOUNDER.OS',
      founderName = 'CEO',
      logoId = 'company_logo_01',
      startingBudget = 450000,
      background = FounderBackground.product,
      skills = const <FounderSkill, int>{
        FounderSkill.engineering: 4,
        FounderSkill.design: 3,
        FounderSkill.product: 5,
        FounderSkill.growth: 3,
        FounderSkill.negotiation: 3,
        FounderSkill.operations: 4,
      };

  const FounderCompanyProfile.legacy()
    : configured = true,
      companyName = 'FOUNDER.OS',
      founderName = 'CEO',
      logoId = 'company_logo_01',
      startingBudget = 450000,
      background = FounderBackground.product,
      skills = const <FounderSkill, int>{
        FounderSkill.engineering: 4,
        FounderSkill.design: 3,
        FounderSkill.product: 5,
        FounderSkill.growth: 3,
        FounderSkill.negotiation: 3,
        FounderSkill.operations: 4,
      };

  static const int distributableSkillPoints = 22;
  static const int maximumSkill = 7;

  final bool configured;
  final String companyName;
  final String founderName;
  final String logoId;
  final double startingBudget;
  final FounderBackground background;
  final Map<FounderSkill, int> skills;

  int skill(FounderSkill skill) => skills[skill] ?? 0;

  int backgroundBonus(FounderSkill skill) => switch (background) {
    FounderBackground.engineer =>
      skill == FounderSkill.engineering || skill == FounderSkill.operations
          ? 2
          : 0,
    FounderBackground.designer =>
      skill == FounderSkill.design || skill == FounderSkill.product ? 2 : 0,
    FounderBackground.product =>
      skill == FounderSkill.product || skill == FounderSkill.negotiation
          ? 2
          : 0,
    FounderBackground.growth =>
      skill == FounderSkill.growth || skill == FounderSkill.product ? 2 : 0,
    FounderBackground.sales =>
      skill == FounderSkill.negotiation || skill == FounderSkill.growth ? 2 : 0,
    FounderBackground.operations =>
      skill == FounderSkill.operations || skill == FounderSkill.engineering
          ? 2
          : 0,
  };

  int effectiveSkill(FounderSkill skill) =>
      (this.skill(skill) + backgroundBonus(skill)).clamp(0, 7).toInt();

  double get employeeSalaryMultiplier {
    if (!configured) return 1;
    final operations = effectiveSkill(FounderSkill.operations);
    final negotiation = effectiveSkill(FounderSkill.negotiation);
    return (1 - operations * 0.008 - negotiation * 0.006)
        .clamp(0.88, 1.0)
        .toDouble();
  }

  double get officeRentMultiplier {
    if (!configured) return 1;
    final operations = effectiveSkill(FounderSkill.operations);
    final negotiation = effectiveSkill(FounderSkill.negotiation);
    return (1 - operations * 0.012 - negotiation * 0.007)
        .clamp(0.84, 1.0)
        .toDouble();
  }

  double get productSetupCostMultiplier {
    if (!configured) return 1;
    final product = effectiveSkill(FounderSkill.product);
    final engineering = effectiveSkill(FounderSkill.engineering);
    return (1 - product * 0.008 - engineering * 0.006)
        .clamp(0.88, 1.0)
        .toDouble();
  }

  double get improvementHoursMultiplier {
    if (!configured) return 1;
    final operations = effectiveSkill(FounderSkill.operations);
    final engineering = effectiveSkill(FounderSkill.engineering);
    return (1 - operations * 0.012 - engineering * 0.008)
        .clamp(0.82, 1.0)
        .toDouble();
  }

  double get growthEfficiencyMultiplier {
    if (!configured) return 1;
    final growth = effectiveSkill(FounderSkill.growth);
    final product = effectiveSkill(FounderSkill.product);
    return (1 + growth * 0.025 + product * 0.008).clamp(1.0, 1.25).toDouble();
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'configured': configured,
    'companyName': companyName,
    'founderName': founderName,
    'logoId': logoId,
    'startingBudget': startingBudget,
    'background': background.name,
    'skills': <String, int>{
      for (final entry in skills.entries) entry.key.name: entry.value,
    },
  };

  factory FounderCompanyProfile.fromJson(Map<String, Object?> json) {
    final rawSkills =
        (json['skills'] as Map?)?.cast<String, Object?>() ??
        const <String, Object?>{};
    return FounderCompanyProfile(
      configured: json['configured'] as bool? ?? true,
      companyName: (json['companyName'] as String?)?.trim().isNotEmpty == true
          ? (json['companyName']! as String).trim()
          : 'FOUNDER.OS',
      founderName: (json['founderName'] as String?)?.trim().isNotEmpty == true
          ? (json['founderName']! as String).trim()
          : 'CEO',
      logoId: json['logoId'] as String? ?? 'company_logo_01',
      startingBudget: (json['startingBudget'] as num?)?.toDouble() ?? 450000,
      background: FounderBackground.values.firstWhere(
        (item) => item.name == (json['background'] as String?),
        orElse: () => FounderBackground.product,
      ),
      skills: Map<FounderSkill, int>.unmodifiable(<FounderSkill, int>{
        for (final skill in FounderSkill.values)
          skill:
              ((rawSkills[skill.name] as num?)?.toInt() ??
                      switch (skill) {
                        FounderSkill.engineering => 4,
                        FounderSkill.design => 3,
                        FounderSkill.product => 5,
                        FounderSkill.growth => 3,
                        FounderSkill.negotiation => 3,
                        FounderSkill.operations => 4,
                      })
                  .clamp(0, maximumSkill)
                  .toInt(),
      }),
    );
  }

  bool get hasValidSkillBudget =>
      skills.values.fold<int>(0, (sum, value) => sum + value) ==
          distributableSkillPoints &&
      skills.values.every((value) => value >= 0 && value <= maximumSkill);
}

String founderBackgroundNameRu(FounderBackground value) => switch (value) {
  FounderBackground.engineer => 'Разработчик',
  FounderBackground.designer => 'Дизайнер',
  FounderBackground.product => 'Продакт',
  FounderBackground.growth => 'Growth / маркетолог',
  FounderBackground.sales => 'Продажи / BizDev',
  FounderBackground.operations => 'Операционный менеджер',
};

String founderBackgroundNameEn(FounderBackground value) => switch (value) {
  FounderBackground.engineer => 'Engineer',
  FounderBackground.designer => 'Designer',
  FounderBackground.product => 'Product manager',
  FounderBackground.growth => 'Growth marketer',
  FounderBackground.sales => 'Sales / BizDev',
  FounderBackground.operations => 'Operations manager',
};

String founderSkillNameRu(FounderSkill value) => switch (value) {
  FounderSkill.engineering => 'Разработка',
  FounderSkill.design => 'Дизайн',
  FounderSkill.product => 'Продукт',
  FounderSkill.growth => 'Рост',
  FounderSkill.negotiation => 'Переговоры',
  FounderSkill.operations => 'Операционка',
};

String founderSkillNameEn(FounderSkill value) => switch (value) {
  FounderSkill.engineering => 'Engineering',
  FounderSkill.design => 'Design',
  FounderSkill.product => 'Product',
  FounderSkill.growth => 'Growth',
  FounderSkill.negotiation => 'Negotiation',
  FounderSkill.operations => 'Operations',
};
