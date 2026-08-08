import 'package:flutter/material.dart';

import '../../../application/settings/display_preferences.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/v12_models.dart';
import 'company_logo.dart';

class FounderProfilePanel extends StatelessWidget {
  const FounderProfilePanel({required this.state, super.key});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.companyProfile;
    final english = DisplayPreferences.instance.isEnglish;
    return Card(
      key: const Key('founder-profile-panel'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CompanyLogo(logoId: profile.logoId, size: 54),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.companyName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        profile.founderName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        english
                            ? founderBackgroundNameEn(profile.background)
                            : founderBackgroundNameRu(profile.background),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              english ? 'Founder skills' : 'Навыки CEO',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final skill in FounderSkill.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        english
                            ? founderSkillNameEn(skill)
                            : founderSkillNameRu(skill),
                      ),
                    ),
                    Text(
                      '${profile.effectiveSkill(skill)}/7',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 110,
                      child: LinearProgressIndicator(
                        value: profile.effectiveSkill(skill) / 7,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Text(
              english
                  ? 'Bonuses: salary −${((1 - profile.employeeSalaryMultiplier) * 100).toStringAsFixed(1)}% · '
                        'infrastructure −${((1 - profile.officeRentMultiplier) * 100).toStringAsFixed(1)}% · '
                        'setup −${((1 - profile.productSetupCostMultiplier) * 100).toStringAsFixed(1)}% · '
                        'growth +${((profile.growthEfficiencyMultiplier - 1) * 100).toStringAsFixed(1)}%'
                  : 'Бонусы: сотрудники −${((1 - profile.employeeSalaryMultiplier) * 100).toStringAsFixed(1)}% · '
                        'инфраструктура −${((1 - profile.officeRentMultiplier) * 100).toStringAsFixed(1)}% · '
                        'старт продукта −${((1 - profile.productSetupCostMultiplier) * 100).toStringAsFixed(1)}% · '
                        'рост +${((profile.growthEfficiencyMultiplier - 1) * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
