// UAT_FIXPACK_R1
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../application/controllers/game_controller.dart';
import '../../../application/localization/app_text.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/v17_models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/scoped_listenable_builder.dart';
import '../../shared/widgets/section_header.dart';

class ResearchScreen extends StatelessWidget {
  const ResearchScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText('Исследования R&D')),
      body: ScopedListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final state = controller.state;
          final technologies = GameCatalog.technologies.toList(growable: false)
            ..sort((left, right) {
              final byDepth = state
                  .researchDepth(ResearchTargetKind.technology, left.id)
                  .compareTo(
                    state.researchDepth(
                      ResearchTargetKind.technology,
                      right.id,
                    ),
                  );
              return byDepth != 0 ? byDepth : left.id.compareTo(right.id);
            });
          final features = GameCatalog.features.toList(growable: false)
            ..sort((left, right) {
              final byDepth = state
                  .researchDepth(ResearchTargetKind.feature, left.id)
                  .compareTo(
                    state.researchDepth(ResearchTargetKind.feature, right.id),
                  );
              if (byDepth != 0) return byDepth;
              final byCost = left.developmentCost.compareTo(
                right.developmentCost,
              );
              return byCost != 0 ? byCost : left.id.compareTo(right.id);
            });

          return ListView(
            key: const Key('research-screen-list'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const SectionHeader(
                title: 'Дерево корпоративных исследований',
                subtitle:
                    'Технологии и функции развиваются отдельно. Узел показывает цену, срок и реальную зависимость до запуска.',
                hintTitle: 'Как устроено дерево R&D',
                hintBody:
                    'Базовые узлы доступны сразу. Более глубокие технологии и функции требуют предыдущие исследования. После завершения функция становится доступна для подходящих продуктов и roadmap.',
              ),
              const SizedBox(height: 12),
              _ResearchGroup(
                title: 'Технологии',
                subtitle: 'Стек, инфраструктура и безопасность.',
                child: Column(
                  children: technologies
                      .map(
                        (technology) => _ResearchRow(
                          state: state,
                          controller: controller,
                          kind: ResearchTargetKind.technology,
                          targetId: technology.id,
                          title: technology.name,
                          description: technology.description,
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              const SizedBox(height: 12),
              _ResearchGroup(
                title: 'Функции продукта',
                subtitle:
                    'Исследованные функции можно добавлять в новые и выпущенные продукты.',
                child: Column(
                  children: features
                      .map(
                        (feature) => _ResearchRow(
                          state: state,
                          controller: controller,
                          kind: ResearchTargetKind.feature,
                          targetId: feature.id,
                          title: feature.name,
                          description: feature.description,
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResearchGroup extends StatelessWidget {
  const _ResearchGroup({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => AppCard(
    child: ExpansionTile(
      initiallyExpanded: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: AppText(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: AppText(subtitle),
      children: [child],
    ),
  );
}

class _ResearchRow extends StatelessWidget {
  const _ResearchRow({
    required this.state,
    required this.controller,
    required this.kind,
    required this.targetId,
    required this.title,
    required this.description,
  });

  final GameState state;
  final GameController controller;
  final ResearchTargetKind kind;
  final String targetId;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final key = state.researchKey(kind, targetId);
    final active = state.activeResearchFor(key);
    final completed = state.researchCompleted(kind, targetId);
    final baselineTechnology =
        kind == ResearchTargetKind.technology &&
        const <String>{'postgresql', 'observability_stack'}.contains(targetId);
    final cost = state.researchCost(kind, targetId);
    final days = state.researchDays(kind, targetId);
    final depth = state.researchDepth(kind, targetId);
    final prerequisiteNames = state.researchPrerequisiteNames(kind, targetId);
    final unlocked = state.researchPrerequisitesMet(kind, targetId);
    final progress = active == null
        ? 0.0
        : ((state.simulationMinutes - active.startedAtMinutes) /
                  math.max(
                    1,
                    active.completesAtMinutes - active.startedAtMinutes,
                  ))
              .clamp(0, 1)
              .toDouble();
    final remainingDays = active == null
        ? 0
        : math.max(
            0,
            ((active.completesAtMinutes - state.simulationMinutes) / 1440)
                .ceil(),
          );

    final indent = math.min(28.0, depth * 9.0);
    return Padding(
      padding: EdgeInsets.only(left: indent, bottom: 10),
      child: Container(
        key: Key('research-screen-${kind.name}-$targetId'),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppText(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(label: AppText('Уровень ${depth + 1}')),
              ],
            ),
            const SizedBox(height: 7),
            AppText(description),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                if (baselineTechnology)
                  const Chip(label: AppText('Базовая'))
                else if (completed)
                  const Chip(label: AppText('Исследовано'))
                else ...[
                  Chip(label: AppText(money(cost))),
                  Chip(label: AppText('$days дн.')),
                ],
                if (!unlocked && !completed)
                  const Chip(label: AppText('Зависимость')),
              ],
            ),
            if (prerequisiteNames.isNotEmpty) ...[
              const SizedBox(height: 8),
              AppText(
                'Нужно сначала: ${prerequisiteNames.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (active != null) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 5),
              AppText(
                'Готово ${(progress * 100).round()}% • осталось $remainingDays дн.',
              ),
            ],
            if (!completed && active == null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  key: Key('start-research-${kind.name}-$targetId'),
                  onPressed: !unlocked || state.cash < cost
                      ? null
                      : () => controller.dispatch(
                          StartCompanyResearch(kind: kind, targetId: targetId),
                        ),
                  child: AppText(
                    !unlocked
                        ? 'Сначала предыдущий уровень'
                        : state.cash < cost
                        ? 'Недостаточно денег'
                        : 'Исследовать',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
