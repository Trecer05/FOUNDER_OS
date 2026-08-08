import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../application/settings/display_preferences.dart';
import '../../../domain/catalog/development_content_catalog.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/v12_game_state_extensions.dart';
import '../../../domain/entities/v12_models.dart';

class ProductDevelopmentExperience extends StatelessWidget {
  const ProductDevelopmentExperience({
    required this.controller,
    required this.product,
    super.key,
  });

  final GameController controller;
  final Product product;

  String _t(String ru, String en) => DisplayPreferences.instance.text(ru, en);

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final stage = state.founderStageFor(product);
    final stageProgress = state.founderStageProgress(product);
    final languageId = DevelopmentContentCatalog.primaryLanguageId(product);
    final languageName = GameCatalog.languageById(languageId).name;

    return Card(
      key: const Key('v12-development-experience'),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('Что сейчас делает команда', 'What the team is doing now'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              _t(
                'Этапы отражают реальную работу: проектирование → дизайн → разработка → отладка.',
                'Stages represent actual work: planning → design → development → debugging.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            _StageRail(active: stage),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    DisplayPreferences.instance.isEnglish
                        ? state.founderStageNameEn(stage)
                        : state.founderStageNameRu(stage),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${(stageProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: stageProgress),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: switch (stage) {
                FounderDevelopmentStage.planning => _PlanningPane(
                  key: ValueKey('planning-${state.day}'),
                  product: product,
                  seed: state.rngSeed,
                  day: state.day,
                ),
                FounderDevelopmentStage.design => _DesignPane(
                  key: ValueKey('design-${state.day}'),
                  product: product,
                  seed: state.rngSeed,
                  day: state.day,
                  progress: stageProgress,
                ),
                FounderDevelopmentStage.implementation => _CodePane(
                  key: ValueKey('code-${state.day}'),
                  product: product,
                  seed: state.rngSeed,
                  day: state.day,
                  languageName: languageName,
                ),
                FounderDevelopmentStage.debugging => _DebugPane(
                  key: ValueKey('debug-${state.day}'),
                  product: product,
                  seed: state.rngSeed,
                  day: state.day,
                  languageName: languageName,
                ),
              },
            ),
            const SizedBox(height: 12),
            _FounderContribution(state: state, product: product, stage: stage),
          ],
        ),
      ),
    );
  }
}

class _StageRail extends StatelessWidget {
  const _StageRail({required this.active});

  final FounderDevelopmentStage active;

  @override
  Widget build(BuildContext context) {
    final english = DisplayPreferences.instance.isEnglish;
    return Row(
      children: [
        for (
          var index = 0;
          index < FounderDevelopmentStage.values.length;
          index += 1
        ) ...[
          Expanded(
            child: _StageChip(
              label: english
                  ? switch (FounderDevelopmentStage.values[index]) {
                      FounderDevelopmentStage.planning => 'Planning',
                      FounderDevelopmentStage.design => 'Design',
                      FounderDevelopmentStage.implementation => 'Development',
                      FounderDevelopmentStage.debugging => 'Debugging',
                    }
                  : switch (FounderDevelopmentStage.values[index]) {
                      FounderDevelopmentStage.planning => 'Проектирование',
                      FounderDevelopmentStage.design => 'Дизайн',
                      FounderDevelopmentStage.implementation => 'Разработка',
                      FounderDevelopmentStage.debugging => 'Отладка',
                    },
              active: active == FounderDevelopmentStage.values[index],
              completed: FounderDevelopmentStage.values.indexOf(active) > index,
            ),
          ),
          if (index < FounderDevelopmentStage.values.length - 1)
            const SizedBox(width: 5),
        ],
      ],
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({
    required this.label,
    required this.active,
    required this.completed,
  });

  final String label;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? AppColors.green
        : active
        ? AppColors.primary
        : AppColors.textMuted;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(active || completed ? 20 : 8),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _PlanningPane extends StatelessWidget {
  const _PlanningPane({
    required this.product,
    required this.seed,
    required this.day,
    super.key,
  });

  final Product product;
  final int seed;
  final int day;

  @override
  Widget build(BuildContext context) {
    final document = DevelopmentContentCatalog.planningDocument(
      product: product,
      seed: seed,
      day: day,
    );
    final text = DisplayPreferences.instance.isEnglish
        ? document.en
        : document.ru;
    return _TerminalSurface(
      header: DisplayPreferences.instance.text(
        'product_spec.md · печать документа',
        'product_spec.md · writing document',
      ),
      child: _TypingText(text: text),
    );
  }
}

class _DesignPane extends StatelessWidget {
  const _DesignPane({
    required this.product,
    required this.seed,
    required this.day,
    required this.progress,
    super.key,
  });

  final Product product;
  final int seed;
  final int day;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final scene = DevelopmentContentCatalog.designScene(
      product: product,
      seed: seed,
      day: day,
    );
    final focus = DisplayPreferences.instance.isEnglish
        ? scene.focusEn
        : scene.focusRu;
    final normalized = progress.clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TerminalSurface(
          header: DisplayPreferences.instance.text(
            'Макет · $focus',
            'Mockup · $focus',
          ),
          child: SizedBox(
            height: 210,
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 650),
              tween: Tween(
                begin: (normalized - 0.10).clamp(0, 1).toDouble(),
                end: normalized,
              ),
              builder: (context, value, _) => CustomPaint(
                painter: _MockupPainter(seed: scene.seed, structure: value),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DisplayPreferences.instance.text(
            normalized < 0.35
                ? 'Черновик: блоки пока ищут своё место.'
                : normalized < 0.75
                ? 'Структура собирается: сетка и иерархия становятся понятнее.'
                : 'Финальный макет: элементы выровнены в цельную структуру.',
            normalized < 0.35
                ? 'Draft: blocks are still finding their place.'
                : normalized < 0.75
                ? 'Structure is settling into a clear grid and hierarchy.'
                : 'Final mockup: elements are aligned into a coherent layout.',
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _CodePane extends StatelessWidget {
  const _CodePane({
    required this.product,
    required this.seed,
    required this.day,
    required this.languageName,
    super.key,
  });

  final Product product;
  final int seed;
  final int day;
  final String languageName;

  @override
  Widget build(BuildContext context) {
    final code = DevelopmentContentCatalog.codeSample(
      product: product,
      seed: seed,
      day: day,
    );
    return _TerminalSurface(
      header:
          '$languageName · ${DisplayPreferences.instance.text('реализация', 'implementation')}',
      child: _TypingText(text: code, monospace: true),
    );
  }
}

class _DebugPane extends StatelessWidget {
  const _DebugPane({
    required this.product,
    required this.seed,
    required this.day,
    required this.languageName,
    super.key,
  });

  final Product product;
  final int seed;
  final int day;
  final String languageName;

  @override
  Widget build(BuildContext context) {
    final error = DevelopmentContentCatalog.debugSample(
      product: product,
      seed: seed,
      day: day,
    );
    final lines = <String>[
      r'$ run test --release',
      '[1/4] loading ${product.name}',
      '[2/4] $languageName checks',
      '[3/4] ${DisplayPreferences.instance.text('воспроизводим дефект', 'reproducing defect')}',
      'ERROR: $error',
      '[4/4] ${DisplayPreferences.instance.text('подбираем безопасный фикс…', 'searching for a safe fix…')}',
    ];
    return _TerminalSurface(
      header: DisplayPreferences.instance.text(
        'Терминал · отладка',
        'Terminal · debugging',
      ),
      child: _TypingText(text: lines.join('\n'), monospace: true),
    );
  }
}

class _TerminalSurface extends StatelessWidget {
  const _TerminalSurface({required this.header, required this.child});

  final String header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF11131A),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white.withAlpha(10),
            child: Text(
              header,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFAAB0C0),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: DefaultTextStyle.merge(
              style: const TextStyle(
                color: Color(0xFFE8EAF1),
                fontSize: 11.5,
                height: 1.45,
                decoration: TextDecoration.none,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingText extends StatelessWidget {
  const _TypingText({required this.text, this.monospace = true});

  final String text;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(
      milliseconds: math.min(3600, math.max(700, text.length * 7)).toInt(),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      builder: (context, value, _) {
        final count = (text.length * value)
            .round()
            .clamp(0, text.length)
            .toInt();
        return Text(
          text.substring(0, count),
          style: TextStyle(
            fontFamily: monospace ? 'monospace' : null,
            color: const Color(0xFFE8EAF1),
            fontSize: 11.5,
            height: 1.45,
            decoration: TextDecoration.none,
          ),
        );
      },
    );
  }
}

class _FounderContribution extends StatelessWidget {
  const _FounderContribution({
    required this.state,
    required this.product,
    required this.stage,
  });

  final GameState state;
  final Product product;
  final FounderDevelopmentStage stage;

  @override
  Widget build(BuildContext context) {
    final profile = state.companyProfile;
    final stageSkill = switch (stage) {
      FounderDevelopmentStage.planning => FounderSkill.product,
      FounderDevelopmentStage.design => FounderSkill.design,
      FounderDevelopmentStage.implementation => FounderSkill.engineering,
      FounderDevelopmentStage.debugging => FounderSkill.operations,
    };
    final capacity = state.founderDevelopmentCapacityFor(product);
    final skill = profile.effectiveSkill(stageSkill);
    final english = DisplayPreferences.instance.isEnglish;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(14),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_outline, color: AppColors.primary),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              english
                  ? 'Founder contribution: ${capacity.toStringAsFixed(2)} FTE. '
                        '${founderSkillNameEn(stageSkill)} skill: $skill/7. '
                        'The founder can move every stage alone, but a proper team is much faster.'
                  : 'Вклад CEO: ${capacity.toStringAsFixed(2)} FTE. '
                        'Навык «${founderSkillNameRu(stageSkill)}»: $skill/7. '
                        'CEO может тащить любой этап в одиночку, но полноценная команда заметно быстрее.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _MockupPainter extends CustomPainter {
  const _MockupPainter({required this.seed, required this.structure});

  final int seed;
  final double structure;

  double _unit(int index) {
    var value = (seed ^ (index * 1103515245)) & 0x7FFFFFFF;
    value = (value * 1103515245 + 12345) & 0x7FFFFFFF;
    return value / 0x7FFFFFFF;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeInOut.transform(structure.clamp(0, 1).toDouble());
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF6D7488);
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF232735);
    final accent = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF526DE8);
    final muted = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF343A4C);

    final shell = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      const Radius.circular(12),
    );
    canvas.drawRRect(shell, fill);
    canvas.drawRRect(shell, border);

    final targets = <Rect>[
      Rect.fromLTWH(14, 14, size.width - 28, 24),
      Rect.fromLTWH(14, 48, size.width * 0.28, size.height - 62),
      Rect.fromLTWH(size.width * 0.34, 48, size.width * 0.62, 42),
      Rect.fromLTWH(size.width * 0.34, 98, size.width * 0.29, 42),
      Rect.fromLTWH(size.width * 0.66, 98, size.width * 0.30, 42),
      Rect.fromLTWH(size.width * 0.34, 148, size.width * 0.62, 26),
      Rect.fromLTWH(size.width * 0.34, 180, size.width * 0.18, 16),
      Rect.fromLTWH(size.width * 0.55, 180, size.width * 0.18, 16),
      Rect.fromLTWH(size.width * 0.76, 180, size.width * 0.20, 16),
    ];

    for (var i = 0; i < targets.length; i += 1) {
      final target = targets[i];
      final randomWidth =
          38 + _unit(i * 5 + 2) * math.min(105, size.width * 0.32);
      final randomHeight = 14 + _unit(i * 5 + 3) * 34;
      final randomLeft =
          10 + _unit(i * 5) * math.max(10, size.width - randomWidth - 20);
      final randomTop =
          10 + _unit(i * 5 + 1) * math.max(10, size.height - randomHeight - 20);
      final start = Rect.fromLTWH(
        randomLeft,
        randomTop,
        randomWidth,
        randomHeight,
      );
      final rect = Rect.fromLTRB(
        _lerp(start.left, target.left, t),
        _lerp(start.top, target.top, t),
        _lerp(start.right, target.right, t),
        _lerp(start.bottom, target.bottom, t),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(7)),
        i == 0 || i == 5 ? accent : muted,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MockupPainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.structure != structure;
}
