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
                    'Идите от базовых возможностей к сложным. Каждый следующий уровень дороже и дольше, а зависимые узлы открываются только после предыдущих исследований.',
                hintTitle: 'Как устроено дерево R&D',
                hintBody:
                    'У каждого узла есть уровень, цена, срок и зависимости. Базовые технологии доступны сразу. Сильные технологии и функции требуют предыдущие исследования.',
              ),
              const SizedBox(height: 12),
              _ResearchGroup(
                title: 'Технологии',
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
                title: 'Функции',
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
  const _ResearchGroup({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => AppCard(
    child: ExpansionTile(
      initiallyExpanded: title == 'Технологии',
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: AppText(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
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

    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: depth == 0
              ? null
              : Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 2,
                  ),
                ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: depth == 0 ? 0 : 10),
          child: ListTile(
            key: Key('research-screen-${kind.name}-$targetId'),
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(child: AppText(title)),
                const SizedBox(width: 8),
                Chip(label: AppText('Уровень ${depth + 1}')),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(description),
                const SizedBox(height: 4),
                if (baselineTechnology)
                  const AppText('Базовая технология')
                else if (completed)
                  const AppText('Исследование завершено')
                else
                  AppText('${money(cost)} • $days дн.'),
                if (prerequisiteNames.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppText(
                    'Нужно сначала: ${prerequisiteNames.join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (active != null) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 4),
                  AppText(
                    'Готово ${(progress * 100).round()}% • осталось $remainingDays дн.',
                  ),
                ],
              ],
            ),
            trailing: completed
                ? const Chip(label: AppText('Исследовано'))
                : active != null
                ? Chip(label: AppText('${(progress * 100).round()}%'))
                : FilledButton.tonal(
                    key: Key('start-research-${kind.name}-$targetId'),
                    onPressed: !unlocked || state.cash < cost
                        ? null
                        : () => controller.dispatch(
                            StartCompanyResearch(
                              kind: kind,
                              targetId: targetId,
                            ),
                          ),
                    child: AppText(
                      unlocked ? 'Исследовать' : 'Сначала предыдущий уровень',
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
