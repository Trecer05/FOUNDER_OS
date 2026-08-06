import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/v9_models.dart';
import '../../../domain/explainability/product_configuration_resolver.dart';
import 'formatters.dart';
import 'section_header.dart';
import '../../../application/localization/app_text.dart';

class TechnologySelectorPanel extends StatelessWidget {
  const TechnologySelectorPanel({
    required this.state,
    required this.blueprintId,
    required this.frameworkId,
    required this.languageIds,
    required this.featureIds,
    required this.selectedTechnologyIds,
    required this.onChanged,
    super.key,
  });

  final GameState state;
  final String blueprintId;
  final String frameworkId;
  final Set<String> languageIds;
  final Set<String> featureIds;
  final Set<String> selectedTechnologyIds;
  final void Function(String technologyId, bool selected) onChanged;

  TechnologyLimitExplanation get explanation =>
      ProductConfigurationResolver.technologyLimit(
        state: state,
        blueprintId: blueprintId,
        frameworkId: frameworkId,
        featureIds: featureIds,
        selectedTechnologyIds: selectedTechnologyIds,
      );

  @override
  Widget build(BuildContext context) {
    final limit = explanation;
    return ListView(
      key: const Key('technology-multi-select'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        SectionHeader(
          title: 'Технологии и инфраструктура',
          subtitle:
              'Выбрано ${limit.selected}. Разрешено ${limit.allowed}. Большой стек повышает часы, tech debt, OPEX и сложность найма.',
          hintTitle: 'Почему лимит динамический',
          hintBody:
              'Лимит зависит от масштаба продукта, framework, roadmap, сложности сопровождения и возможностей инженерной команды.',
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('technology-limit-explanation'),
          onPressed: () => _showLimit(context, limit),
          icon: const Icon(Icons.info_outline),
          label: AppText('Почему доступно ${limit.allowed}'),
        ),
        const SizedBox(height: 10),
        ...GameCatalog.technologies.map((technology) {
          final selected = selectedTechnologyIds.contains(technology.id);
          final availability = ProductConfigurationResolver.availability(
            frameworkId: frameworkId,
            languageIds: languageIds,
            selectedTechnologyIds: selectedTechnologyIds,
            technology: technology,
          );
          final impact = ProductConfigurationResolver.impact(technology);
          final atLimit = !selected && limit.reached;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: availability.mandatory
                    ? null
                    : () {
                        if (atLimit) {
                          _showLimit(context, limit);
                        } else if (availability.enabled) {
                          onChanged(technology.id, !selected);
                        } else {
                          _showBlocked(context, technology.name, availability);
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: selected,
                            onChanged: availability.mandatory
                                ? null
                                : (_) {
                                    if (atLimit) {
                                      _showLimit(context, limit);
                                    } else if (availability.enabled) {
                                      onChanged(technology.id, !selected);
                                    } else {
                                      _showBlocked(
                                        context,
                                        technology.name,
                                        availability,
                                      );
                                    }
                                  },
                          ),
                          Expanded(
                            child: AppText(
                              technology.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (availability.mandatory)
                            const Chip(label: AppText('Обязательна')),
                        ],
                      ),
                      AppText(technology.description),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _ImpactChip(
                            'Часы +${impact.developmentHoursDelta.round()}',
                          ),
                          _ImpactChip(
                            'Tech debt +${(impact.technicalDebtDelta * 100).round()}',
                            warning: true,
                          ),
                          _ImpactChip(
                            'Infra ${money(impact.infrastructureCostDelta)}/мес.',
                            warning: impact.infrastructureCostDelta > 20000,
                          ),
                          _ImpactChip(
                            'Найм +${(impact.hiringDifficultyDelta * 100).round()}%',
                            warning: impact.hiringDifficultyDelta >= 0.2,
                          ),
                          _ImpactChip(
                            'Support +${(impact.supportDifficultyDelta * 100).round()}%',
                            warning: true,
                          ),
                          _ImpactChip(
                            'Stability ${impact.stabilityDelta >= 0 ? '+' : ''}${(impact.stabilityDelta * 100).toStringAsFixed(1)} п.п.',
                          ),
                        ],
                      ),
                      if (!availability.enabled) ...[
                        const SizedBox(height: 8),
                        AppText(
                          '${availability.reason} ${availability.nextStep}',
                          style: const TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ] else if (atLimit) ...[
                        const SizedBox(height: 8),
                        AppText(
                          'Лимит достигнут: выбрано ${limit.selected} из ${limit.allowed}. Нажмите, чтобы увидеть расчёт.',
                          style: const TextStyle(color: AppColors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showLimit(BuildContext context, TechnologyLimitExplanation value) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Выбрано ${value.selected} • разрешено ${value.allowed}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              ...value.reasons.map(
                (reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AppText('• $reason'),
                ),
              ),
              const SizedBox(height: 8),
              const AppText(
                'Чтобы увеличить реальную способность сопровождать стек: упростите framework/roadmap или наймите сильную инженерную команду. Выбор сверх лимита запрещён движком.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlocked(
    BuildContext context,
    String name,
    TechnologyAvailability availability,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText('$name недоступна'),
        content: AppText(
          '${availability.reason}\n\nСледующий шаг: ${availability.nextStep}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const AppText('Понятно'),
          ),
        ],
      ),
    );
  }
}

class _ImpactChip extends StatelessWidget {
  const _ImpactChip(this.label, {this.warning = false});
  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: (warning ? AppColors.red : AppColors.primary).withAlpha(16),
      borderRadius: BorderRadius.circular(12),
    ),
    child: AppText(label, style: Theme.of(context).textTheme.bodySmall),
  );
}
