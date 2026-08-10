import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/v12_game_state_extensions.dart';
import '../infrastructure/infrastructure_screen.dart';
import '../more/more_screen.dart';
import '../overview/overview_screen.dart';
import '../products/products_screen.dart';
import '../products/project_challenge_dialog.dart';
import '../team/team_screen.dart';
import '../tutorial/founder_tutorial_dialog.dart';
import '../onboarding/company_setup_dialog.dart';
import '../menu/save_slots_dialog.dart';
import '../../../application/localization/app_localizer.dart';
import '../../../application/localization/app_text.dart';
import '../../shared/widgets/scoped_listenable_builder.dart';
import '../../shared/widgets/company_logo.dart';

class FounderDashboard extends StatefulWidget {
  const FounderDashboard({
    required this.controller,
    this.onExitToMainMenu,
    super.key,
  });

  final GameController controller;
  final VoidCallback? onExitToMainMenu;

  @override
  State<FounderDashboard> createState() => _FounderDashboardState();
}

class _FounderDashboardState extends State<FounderDashboard> {
  int _tab = 0;
  CriticalEventType _shownEvent = CriticalEventType.none;
  bool _tutorialShowing = false;
  bool _projectChallengeShowing = false;
  bool _legacyWinShowing = false;
  bool _legacyWinShown = false;
  late final List<Widget Function()> _screenBuilders;

  @override
  void initState() {
    super.initState();
    _screenBuilders = <Widget Function()>[
      () => OverviewScreen(controller: widget.controller),
      () => ProductsScreen(controller: widget.controller),
      () => TeamScreen(controller: widget.controller),
      () => InfrastructureScreen(controller: widget.controller),
      () => MoreScreen(controller: widget.controller),
    ];
    widget.controller.addListener(_handleControllerUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _maybeShowTutorial();
      if (mounted) {
        await _maybeShowProjectChallenge();
      }
      if (mounted) {
        await _maybeShowLegacyWin();
      }
    });
  }

  Future<void> _maybeShowTutorial() async {
    if (!mounted || _tutorialShowing) {
      return;
    }

    var state = widget.controller.state;
    if (state.companyProfile.configured && state.onboardingCompleted) {
      return;
    }

    _tutorialShowing = true;
    try {
      if (!state.companyProfile.configured) {
        await showCompanySetup(context, widget.controller);
        if (!mounted) return;
        state = widget.controller.state;
      }

      if (state.onboardingCompleted) {
        return;
      }

      final genuinelyNewGame =
          state.day == 1 &&
          state.products.isEmpty &&
          state.employees.isEmpty &&
          state.clientContracts.isEmpty;
      if (!genuinelyNewGame) {
        widget.controller.dispatch(
          const CompleteOnboarding(),
          playSound: false,
        );
        return;
      }

      await showFounderTutorial(context, widget.controller);
    } finally {
      _tutorialShowing = false;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerUpdate);
    super.dispose();
  }

  void _handleControllerUpdate() {
    if (!mounted) {
      return;
    }
    final state = widget.controller.state;
    if (!state.companyProfile.configured) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _maybeShowTutorial();
        }
      });
    } else if (!_tutorialShowing && !_projectChallengeShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _maybeShowProjectChallenge();
          _maybeShowLegacyWin();
        }
      });
    }

    final event = state.criticalEvent;
    if (event == CriticalEventType.none) {
      _shownEvent = CriticalEventType.none;
      return;
    }
    if (event == _shownEvent) {
      return;
    }
    _shownEvent = event;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showCriticalEvent();
      }
    });
  }

  Future<void> _maybeShowProjectChallenge() async {
    if (!mounted ||
        _tutorialShowing ||
        _projectChallengeShowing ||
        widget.controller.state.criticalEvent != CriticalEventType.none) {
      return;
    }
    final product = widget.controller.state.pendingProjectChallengeProduct;
    if (product == null) {
      return;
    }
    _projectChallengeShowing = true;
    try {
      await showProjectDevelopmentChallenge(
        context,
        widget.controller,
        product,
      );
    } finally {
      _projectChallengeShowing = false;
    }
  }

  Future<void> _maybeShowLegacyWin() async {
    if (!mounted ||
        _legacyWinShowing ||
        _legacyWinShown ||
        _tutorialShowing ||
        _projectChallengeShowing ||
        widget.controller.state.criticalEvent != CriticalEventType.none ||
        !widget.controller.state.founderLegacyCompleted) {
      return;
    }
    _legacyWinShowing = true;
    _legacyWinShown = true;
    final state = widget.controller.state;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.emoji_events_outlined,
            color: AppColors.yellow,
            size: 46,
          ),
          title: const AppText('Founder Legacy завершён'),
          content: AppText(
            'Вы самостоятельно выпустили ${state.releasedBlueprintCount} направлений и поглотили всех ${state.acquiredRivalCount} крупных конкурентов. Это полноценный финал кампании — компанию можно продолжить развивать в свободном режиме.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const AppText('Продолжить компанию'),
            ),
          ],
        ),
      );
    } finally {
      _legacyWinShowing = false;
    }
  }

  void _selectTab(int value) {
    if (!mounted) return;
    setState(() => _tab = value);
  }

  Future<void> _showCriticalEvent() async {
    final state = widget.controller.state;
    final event = state.criticalEvent;
    if (!mounted || event == CriticalEventType.none) {
      return;
    }
    final product = state.criticalProductId == null
        ? null
        : state.productById(state.criticalProductId!);
    final content = _eventContent(event, product?.name);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(content.icon, color: AppColors.red, size: 40),
        title: AppText(content.title),
        content: AppText(content.body),
        actions: [
          if (event == CriticalEventType.insolvency)
            OutlinedButton.icon(
              key: const Key('restore-week-before-bankruptcy'),
              onPressed: () async {
                final restored = await widget.controller
                    .restoreWeekBeforeBankruptcy();
                if (!mounted) return;
                if (!dialogContext.mounted) return;
                if (restored) {
                  Navigator.of(dialogContext).pop();
                  if (mounted) setState(() => _tab = 0);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: AppText(
                        'Недельная контрольная точка ещё не успела создаться.',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.restore_rounded),
              label: const AppText('Откатить на неделю'),
            ),
          if (event == CriticalEventType.lostControl ||
              event == CriticalEventType.insolvency)
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await widget.controller.reset();
                if (mounted) {
                  setState(() => _tab = 0);
                }
              },
              child: const AppText('Начать новую компанию'),
            )
          else
            FilledButton(
              onPressed: () {
                widget.controller.dispatch(const ResolveCriticalEvent());
                Navigator.of(dialogContext).pop();
                final target = event == CriticalEventType.serverOverload
                    ? 3
                    : 1;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _selectTab(target);
                });
              },
              child: AppText(content.action),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: ScopedListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final state = widget.controller.state;
            return Row(
              children: <Widget>[
                CompanyLogo(
                  logoId: state.companyProfile.logoId,
                  size: 26,
                  borderRadius: 7,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    state.companyProfile.companyName,
                    translate: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            );
          },
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            tooltip: trContext(context, 'Меню компании'),
            onSelected: (value) async {
              if (value == 'save') {
                await showSaveSlotsDialog(
                  context,
                  widget.controller,
                  mode: SaveSlotDialogMode.save,
                );
                return;
              }
              if (value == 'main_menu') {
                if (!widget.controller.state.paused) {
                  widget.controller.dispatch(
                    const TogglePause(),
                    playSound: false,
                  );
                }
                await widget.controller.saveNow();
                if (mounted) widget.onExitToMainMenu?.call();
                return;
              }
              if (value != 'reset') return;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const AppText('Начать заново?'),
                  content: const AppText(
                    'Текущий автосейв будет заменён. Ручные слоты останутся доступными.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const AppText('Отмена'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const AppText('Сбросить'),
                    ),
                  ],
                ),
              );
              if ((confirmed ?? false) && mounted) {
                await widget.controller.reset();
                if (mounted) {
                  setState(() => _tab = 0);
                }
              }
            },
            itemBuilder: (_) => <PopupMenuEntry<String>>[
              if (widget.controller.supportsManualSaves)
                const PopupMenuItem<String>(
                  value: 'save',
                  child: AppText('Сохранить игру'),
                ),
              if (widget.onExitToMainMenu != null)
                const PopupMenuItem<String>(
                  value: 'main_menu',
                  child: AppText('В главное меню'),
                ),
              const PopupMenuItem<String>(
                value: 'reset',
                child: AppText('Новая компания'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: KeyedSubtree(
          key: ValueKey<int>(_tab),
          child: ActiveTabScope(
            active: true,
            child: ScopedListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) => _screenBuilders[_tab](),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.space_dashboard_outlined),
            selectedIcon: const Icon(Icons.space_dashboard),
            label: trContext(context, 'Обзор'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.apps_outlined),
            selectedIcon: const Icon(Icons.apps),
            label: trContext(context, 'Продукты'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_2_outlined),
            selectedIcon: const Icon(Icons.groups_2),
            label: trContext(context, 'Команда'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.dns_outlined),
            selectedIcon: const Icon(Icons.dns),
            label: trContext(context, 'Инфра'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            selectedIcon: const Icon(Icons.grid_view),
            label: trContext(context, 'Ещё'),
          ),
        ],
      ),
    );
  }
}

_EventContent _eventContent(
  CriticalEventType type,
  String? productName,
) => switch (type) {
  CriticalEventType.serverOverload => _EventContent(
    title: 'Перегрузка ${productName ?? 'продукта'}',
    body:
        'Выделенной мощности недостаточно. Скорость и uptime падают, а пользователи начинают уходить. Измените проценты распределения или расширьте серверную.',
    action: 'Перейти к инфраструктуре',
    icon: Icons.dns_outlined,
  ),
  CriticalEventType.securityBreach => _EventContent(
    title: 'Атака на ${productName ?? 'продукт'}',
    body:
        'Инцидент попал в новости и уже повлиял на доверие, рейтинг и пользователей. Локализуйте атаку и пересмотрите security score продукта.',
    action: 'Локализовать атаку',
    icon: Icons.gpp_bad_outlined,
  ),
  CriticalEventType.lostControl => const _EventContent(
    title: 'Компания потеряна',
    body:
        'Доля основателя упала ниже 50%. Инвесторы получили контроль над компанией. Эта сессия завершена.',
    action: 'Начать заново',
    icon: Icons.account_balance_outlined,
  ),
  CriticalEventType.insolvency => const _EventContent(
    title: 'Компания обанкротилась',
    body:
        'Отрицательный баланс не был восстановлен в срок. Кредитные условия нарушены, компания больше не может оплачивать работу.',
    action: 'Начать заново',
    icon: Icons.money_off_csred_outlined,
  ),
  CriticalEventType.none => const _EventContent(
    title: '',
    body: '',
    action: '',
    icon: Icons.info_outline,
  ),
};

class _EventContent {
  const _EventContent({
    required this.title,
    required this.body,
    required this.action,
    required this.icon,
  });

  final String title;
  final String body;
  final String action;
  final IconData icon;
}
