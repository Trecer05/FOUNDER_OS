import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../shared/widgets/formatters.dart';
import '../infrastructure/infrastructure_screen.dart';
import '../more/more_screen.dart';
import '../overview/overview_screen.dart';
import '../products/products_screen.dart';
import '../team/team_screen.dart';

class FounderDashboard extends StatefulWidget {
  const FounderDashboard({required this.controller, super.key});

  final GameController controller;

  @override
  State<FounderDashboard> createState() => _FounderDashboardState();
}

class _FounderDashboardState extends State<FounderDashboard> {
  int _tab = 0;
  CriticalEventType _shownEvent = CriticalEventType.none;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerUpdate);
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
    final event = widget.controller.state.criticalEvent;
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
        title: Text(content.title),
        content: Text(content.body),
        actions: [
          if (event == CriticalEventType.lostControl)
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await widget.controller.reset();
                if (mounted) {
                  setState(() => _tab = 0);
                }
              },
              child: const Text('Начать новую компанию'),
            )
          else
            FilledButton(
              onPressed: () {
                widget.controller.dispatch(const ResolveCriticalEvent());
                Navigator.of(dialogContext).pop();
                setState(() {
                  _tab = event == CriticalEventType.serverOverload ? 3 : 1;
                });
              },
              child: Text(content.action),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        final screens = <Widget>[
          OverviewScreen(controller: widget.controller),
          ProductsScreen(controller: widget.controller),
          TeamScreen(controller: widget.controller),
          InfrastructureScreen(controller: widget.controller),
          MoreScreen(controller: widget.controller),
        ];

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FOUNDER.OS',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  'День ${state.day} • ${state.formattedTime}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              _HeaderMetric(label: 'Cash', value: money(state.cash)),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                tooltip: 'Меню компании',
                onSelected: (value) async {
                  if (value != 'reset') {
                    return;
                  }
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Начать заново?'),
                      content: const Text(
                        'Текущее локальное сохранение будет удалено.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('Отмена'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text('Сбросить'),
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
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'reset', child: Text('Новая компания')),
                ],
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: IndexedStack(index: _tab, children: screens),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) => setState(() => _tab = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard),
                label: 'Обзор',
              ),
              NavigationDestination(
                icon: Icon(Icons.apps_outlined),
                selectedIcon: Icon(Icons.apps),
                label: 'Продукты',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_2_outlined),
                selectedIcon: Icon(Icons.groups_2),
                label: 'Команда',
              ),
              NavigationDestination(
                icon: Icon(Icons.dns_outlined),
                selectedIcon: Icon(Icons.dns),
                label: 'Инфра',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_rounded),
                selectedIcon: Icon(Icons.grid_view),
                label: 'Ещё',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              fontSize: 9,
              height: 1,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: const TextStyle(
              fontSize: 11,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
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
