import 'package:flutter/material.dart';

import '../../../application/controllers/game_controller.dart';
import '../../../application/settings/display_preferences.dart';
import '../../../domain/catalog/development_content_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/v12_game_state_extensions.dart';

Future<void> showProjectDevelopmentChallenge(
  BuildContext context,
  GameController controller,
  Product product,
) async {
  final resumeAfter = !controller.state.paused;
  if (resumeAfter) {
    controller.dispatch(const TogglePause(), playSound: false, save: false);
  }
  try {
    await _showProjectDevelopmentChallengeBody(context, controller, product);
  } finally {
    if (resumeAfter && controller.state.paused) {
      controller.dispatch(const TogglePause(), playSound: false, save: false);
    }
  }
}

Future<void> _showProjectDevelopmentChallengeBody(
  BuildContext context,
  GameController controller,
  Product product,
) async {
  final state = controller.state;
  if (!state.projectChallengeEligible(product)) {
    return;
  }

  final english = DisplayPreferences.instance.isEnglish;
  final proceed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.bolt_rounded, size: 38),
      title: Text(english ? 'Project challenge' : 'Технический вызов проекта'),
      content: Text(
        english
            ? 'This appears once per project. Solve it to boost the current stage by 30%. You can skip it and continue normally.'
            : 'Такой вызов появляется один раз за проект. Реши задачу — текущий этап ускорится на 30%. Можно пропустить и продолжить без штрафа.',
      ),
      actions: [
        TextButton(
          key: const Key('skip-project-challenge'),
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(english ? 'Skip' : 'Пропустить'),
        ),
        FilledButton.icon(
          key: const Key('start-project-challenge'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(english ? 'Take challenge' : 'Пройти задачу'),
        ),
      ],
    ),
  );

  if (!context.mounted || proceed == null) {
    return;
  }

  final latest = controller.state.productById(product.id);
  if (latest == null || !controller.state.projectChallengeEligible(latest)) {
    return;
  }
  final stage = controller.state.founderStageFor(latest);

  if (!proceed) {
    controller.dispatch(
      CompleteDevelopmentChallenge(
        productId: latest.id,
        stage: stage,
        correct: false,
      ),
    );
    return;
  }

  final challenge = DevelopmentContentCatalog.challenge(
    product: latest,
    stage: stage,
    seed: controller.state.rngSeed,
    day: controller.state.day,
  );
  final prompt = english ? challenge.promptEn : challenge.promptRu;
  final selected = await showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        english ? 'Choose the safe solution' : 'Выбери правильное решение',
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(prompt),
              const SizedBox(height: 14),
              for (var index = 0; index < challenge.options.length; index += 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      key: Key('project-challenge-option-$index'),
                      onPressed: () => Navigator.of(dialogContext).pop(index),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            challenge.options[index],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(-1),
                child: Text(english ? 'Skip challenge' : 'Пропустить задачу'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (!context.mounted || selected == null) {
    return;
  }
  final correct = selected == challenge.correctIndex;
  controller.dispatch(
    CompleteDevelopmentChallenge(
      productId: latest.id,
      stage: stage,
      correct: correct,
    ),
  );

  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        correct
            ? (english
                  ? 'Correct: +30% of the current stage.'
                  : 'Верно: +30% прогресса текущего этапа.')
            : (english
                  ? 'Challenge closed. Development continues without a penalty.'
                  : 'Вызов закрыт. Разработка продолжается без штрафа.'),
      ),
    ),
  );
}
