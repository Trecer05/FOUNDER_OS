import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/settings/display_preferences.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/v12_game_state_extensions.dart';
import '../../../domain/entities/v12_models.dart';

class DevelopmentStageProgressRail extends StatelessWidget {
  const DevelopmentStageProgressRail({
    required this.state,
    required this.product,
    this.compact = false,
    super.key,
  });

  final GameState state;
  final Product product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final english = DisplayPreferences.instance.isEnglish;
    if (product.stage == ProductStage.live) {
      return Container(
        key: Key('development-stage-progress-${product.id}'),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.green.withAlpha(14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.green.withAlpha(70)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                english ? 'Development complete' : 'Разработка завершена',
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
            ),
            Text(
              '4/4',
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w900,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      );
    }

    final active = state.founderStageFor(product);
    final activeIndex = FounderDevelopmentStage.values.indexOf(active);
    final overallProgress = product.developmentProgress.clamp(0, 1).toDouble();
    final stageName = english
        ? state.founderStageNameEn(active)
        : state.founderStageNameRu(active);

    return Column(
      key: Key('development-stage-progress-${product.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (
              var index = 0;
              index < FounderDevelopmentStage.values.length;
              index += 1
            ) ...[
              Expanded(
                child: _StageSegment(
                  label: _label(index, english),
                  active: index == activeIndex,
                  completed: index < activeIndex,
                  compact: compact,
                ),
              ),
              if (index < FounderDevelopmentStage.values.length - 1)
                SizedBox(width: compact ? 4 : 6),
            ],
          ],
        ),
        SizedBox(height: compact ? 7 : 9),
        Row(
          children: [
            Expanded(
              child: Text(
                english ? 'Now: $stageName' : 'Сейчас: $stageName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(overallProgress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 5 : 6),
        LinearProgressIndicator(
          value: overallProgress,
          minHeight: compact ? 5 : 7,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  static String _label(int index, bool english) {
    if (english) {
      return switch (index) {
        0 => 'Planning',
        1 => 'Design',
        2 => 'Development',
        _ => 'Debugging',
      };
    }
    return switch (index) {
      0 => 'Проектирование',
      1 => 'Дизайн',
      2 => 'Разработка',
      _ => 'Отладка',
    };
  }
}

class _StageSegment extends StatelessWidget {
  const _StageSegment({
    required this.label,
    required this.active,
    required this.completed,
    required this.compact,
  });

  final String label;
  final bool active;
  final bool completed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? AppColors.green
        : active
        ? AppColors.primary
        : AppColors.textMuted;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 3 : 5,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(active || completed ? 20 : 7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withAlpha(active || completed ? 105 : 42),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            completed ? Icons.check_rounded : Icons.circle_outlined,
            size: compact ? 12 : 14,
            color: color,
          ),
          SizedBox(width: compact ? 3 : 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 9 : 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
