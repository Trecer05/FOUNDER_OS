import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../application/localization/app_localizer.dart';
import '../../../application/localization/app_text.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/v17_models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/scoped_listenable_builder.dart';

class CompanyNotificationCenterScreen extends StatelessWidget {
  const CompanyNotificationCenterScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ScopedListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final items = state.companyNotifications
            .take(160)
            .toList(growable: false);
        return Scaffold(
          appBar: AppBar(
            title: const AppText('Уведомления'),
            actions: [
              if (items.isNotEmpty)
                IconButton(
                  key: const Key('clear-all-notifications'),
                  tooltip: trContext(context, 'Очистить все'),
                  onPressed: () =>
                      controller.dispatch(const ClearCompanyNotifications()),
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
            ],
          ),
          body: items.isEmpty
              ? const Center(child: AppText('Новых уведомлений пока нет.'))
              : ListView.builder(
                  key: const Key('notification-center-list'),
                  scrollCacheExtent: const ScrollCacheExtent.pixels(0),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _VisibleNotificationTile(
                      key: ValueKey(item.id),
                      controller: controller,
                      item: item,
                    );
                  },
                ),
        );
      },
    );
  }
}

class _VisibleNotificationTile extends StatefulWidget {
  const _VisibleNotificationTile({
    required this.controller,
    required this.item,
    super.key,
  });

  final GameController controller;
  final CompanyNotification item;

  @override
  State<_VisibleNotificationTile> createState() =>
      _VisibleNotificationTileState();
}

class _VisibleNotificationTileState extends State<_VisibleNotificationTile> {
  bool _markScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleVisibleRead();
  }

  @override
  void didUpdateWidget(covariant _VisibleNotificationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.read != widget.item.read ||
        oldWidget.item.id != widget.item.id) {
      _markScheduled = false;
      _scheduleVisibleRead();
    }
  }

  void _scheduleVisibleRead() {
    if (_markScheduled || widget.item.read) return;
    _markScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markScheduled = false;
      if (!mounted || widget.item.read) return;
      final render = context.findRenderObject();
      if (render is! RenderBox || !render.hasSize) return;
      final top = render.localToGlobal(Offset.zero).dy;
      final bottom = top + render.size.height;
      final viewport = MediaQuery.sizeOf(context).height;
      final visible = bottom > kToolbarHeight && top < viewport;
      if (visible) {
        widget.controller.dispatch(
          MarkCompanyNotificationRead(widget.item.id),
          playSound: false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleVisibleRead();
    final state = widget.controller.state;
    final item = widget.item;
    final date = state.dateTimeAt(item.simulationMinutes);
    final timestamp =
        '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: ValueKey('dismiss-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => widget.controller.dispatch(
        DeleteCompanyNotification(item.id),
        playSound: false,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                key: Key('notification-dot-${item.kind.name}'),
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kindColor(item.kind),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.read
                                  ? FontWeight.w700
                                  : FontWeight.w900,
                            ),
                          ),
                        ),
                        if (!item.read)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: AppText(
                              'NEW',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    AppText(item.body),
                    const SizedBox(height: 7),
                    AppText(
                      timestamp,
                      translate: false,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _kindColor(CompanyNotificationKind kind) => switch (kind) {
  CompanyNotificationKind.contract => const Color(0xFF3D8BFF),
  CompanyNotificationKind.development ||
  CompanyNotificationKind.product => AppColors.green,
  CompanyNotificationKind.finance ||
  CompanyNotificationKind.employee => AppColors.red,
  CompanyNotificationKind.investor => const Color(0xFF8E6CFF),
  CompanyNotificationKind.research => const Color(0xFF33BBD7),
  CompanyNotificationKind.event ||
  CompanyNotificationKind.legend ||
  CompanyNotificationKind.legacy => const Color(0xFFE8B84A),
  CompanyNotificationKind.tax => const Color(0xFF7F8A9E),
};
