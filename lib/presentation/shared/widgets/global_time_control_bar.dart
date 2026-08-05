import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/models.dart';

class GlobalTimeControlBar extends StatelessWidget {
  const GlobalTimeControlBar({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      return const SizedBox.shrink();
    }
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final blocked =
            state.criticalEvent != CriticalEventType.none || state.gameOver;
        return Material(
          color: AppColors.surface,
          elevation: 8,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    key: const Key('global-time-toggle'),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(42, 42),
                      maximumSize: const Size(42, 42),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: blocked
                        ? null
                        : () => controller.dispatch(const TogglePause()),
                    icon: Icon(
                      state.paused ? Icons.play_arrow : Icons.pause,
                      semanticLabel: state.paused ? 'Продолжить' : 'Пауза',
                    ),
                  ),
                  const SizedBox(width: 7),
                  _SpeedButton(
                    key: const Key('global-speed-x1'),
                    label: '1x',
                    selected: state.speed == GameSpeed.x1,
                    enabled: !blocked,
                    onTap: () =>
                        controller.dispatch(const SetGameSpeed(GameSpeed.x1)),
                  ),
                  const SizedBox(width: 4),
                  _SpeedButton(
                    key: const Key('global-speed-x2'),
                    label: '2x',
                    selected: state.speed == GameSpeed.x2,
                    enabled: !blocked,
                    onTap: () =>
                        controller.dispatch(const SetGameSpeed(GameSpeed.x2)),
                  ),
                  const SizedBox(width: 4),
                  _SpeedButton(
                    key: const Key('global-speed-x4'),
                    label: '4x',
                    selected: state.speed == GameSpeed.x4,
                    enabled: !blocked,
                    onTap: () =>
                        controller.dispatch(const SetGameSpeed(GameSpeed.x4)),
                  ),
                  const Spacer(),
                  Text(
                    'Д${state.day}\n${state.formattedTime}',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    key: const Key('global-skip-night'),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(42, 42),
                      maximumSize: const Size(42, 42),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: blocked
                        ? null
                        : () => controller.dispatch(const SkipNight()),
                    icon: const Icon(
                      Icons.nightlight_outlined,
                      semanticLabel: 'Пропустить до 08:00',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({
    required super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = !enabled
        ? AppColors.textMuted.withAlpha(100)
        : selected
        ? AppColors.primary
        : AppColors.textMuted;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: 'Скорость $label',
      child: Material(
        color: selected ? AppColors.primary.withAlpha(24) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 36,
            height: 38,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
