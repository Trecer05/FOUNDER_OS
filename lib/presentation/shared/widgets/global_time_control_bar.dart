import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../application/localization/app_localizer.dart';
import '../../../application/localization/app_text.dart';
import '../../../application/settings/display_preferences.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/models.dart';
import 'formatters.dart';
import './scoped_listenable_builder.dart';

class GlobalTimeControlBar extends StatelessWidget {
  const GlobalTimeControlBar({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ScopedListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        controller,
        DisplayPreferences.instance,
      ]),
      builder: (context, _) {
        final state = controller.state;
        final blocked =
            state.criticalEvent != CriticalEventType.none || state.gameOver;
        return RepaintBoundary(
          child: Semantics(
            key: const Key('global-time-floating'),
            container: true,
            label: tr('Глобальное управление временем и деньгами'),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620, minHeight: 48),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface.withAlpha(238),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withAlpha(170)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _GlassIconButton(
                        key: const Key('global-time-toggle'),
                        enabled: !blocked,
                        selected: !state.paused,
                        semanticLabel: tr(
                          state.paused ? 'Продолжить' : 'Пауза',
                        ),
                        icon: state.paused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        onPressed: () =>
                            controller.dispatch(const TogglePause()),
                      ),
                      const SizedBox(width: 4),
                      _SpeedButton(
                        key: const Key('global-speed-x1'),
                        label: '1×',
                        selected: state.speed == GameSpeed.x1,
                        enabled: !blocked,
                        onTap: () => controller.dispatch(
                          const SetGameSpeed(GameSpeed.x1),
                        ),
                      ),
                      const SizedBox(width: 3),
                      _SpeedButton(
                        key: const Key('global-speed-x2'),
                        label: '2×',
                        selected: state.speed == GameSpeed.x2,
                        enabled: !blocked,
                        onTap: () => controller.dispatch(
                          const SetGameSpeed(GameSpeed.x2),
                        ),
                      ),
                      const SizedBox(width: 3),
                      _SpeedButton(
                        key: const Key('global-speed-x4'),
                        label: '4×',
                        selected: state.speed == GameSpeed.x4,
                        enabled: !blocked,
                        onTap: () => controller.dispatch(
                          const SetGameSpeed(GameSpeed.x4),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: _StatusPill(
                          key: const Key('global-current-time'),
                          semanticLabel: tr(
                            'Дата и время ${state.formattedDateTime}',
                          ),
                          text: state.formattedDateTime,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: _StatusPill(
                          key: const Key('global-current-cash'),
                          semanticLabel: tr(
                            'Деньги компании ${money(state.cash)}',
                          ),
                          text: money(state.cash),
                          warning: state.cash < 0,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _GlassIconButton(
                        key: const Key('global-skip-night'),
                        enabled: !blocked,
                        selected: false,
                        semanticLabel: tr('Пропустить ночь до 08:00'),
                        icon: Icons.nightlight_round,
                        onPressed: () => controller.dispatch(const SkipNight()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required super.key,
    required this.semanticLabel,
    required this.text,
    this.warning = false,
    this.fontSize = 12,
  });

  final String semanticLabel;
  final String text;
  final bool warning;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        constraints: const BoxConstraints(minWidth: 58, maxWidth: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: warning
              ? AppColors.red.withAlpha(20)
              : Colors.white.withAlpha(115),
          borderRadius: BorderRadius.circular(14),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: AppText(
            text,
            maxLines: 1,
            style: TextStyle(
              color: warning ? AppColors.red : AppColors.text,
              decoration: TextDecoration.none,
              decorationColor: Colors.transparent,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required super.key,
    required this.enabled,
    required this.selected,
    required this.semanticLabel,
    required this.icon,
    required this.onPressed,
  });

  final bool enabled;
  final bool selected;
  final String semanticLabel;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: semanticLabel,
      child: IconButton(
        constraints: const BoxConstraints.tightFor(width: 36, height: 38),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: selected
              ? AppColors.primary.withAlpha(28)
              : Colors.white.withAlpha(92),
          foregroundColor: selected ? AppColors.primary : AppColors.textMuted,
          disabledForegroundColor: AppColors.textMuted.withAlpha(90),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 20),
      ),
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
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: tr('Скорость $label'),
      child: Material(
        color: selected
            ? AppColors.primary.withAlpha(28)
            : Colors.white.withAlpha(92),
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 32,
            height: 38,
            child: Center(
              child: AppText(
                label,
                style: TextStyle(
                  color: !enabled
                      ? AppColors.textMuted.withAlpha(90)
                      : selected
                      ? AppColors.primary
                      : AppColors.textMuted,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
