import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../application/localization/app_text.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/v17_models.dart';
import '../../features/company/company_notification_center_screen.dart';

class CompanyNotificationToastHost extends StatefulWidget {
  const CompanyNotificationToastHost({
    required this.controller,
    required this.child,
    super.key,
  });

  final GameController controller;
  final Widget child;

  @override
  State<CompanyNotificationToastHost> createState() =>
      _CompanyNotificationToastHostState();
}

class _CompanyNotificationToastHostState
    extends State<CompanyNotificationToastHost> {
  final Set<String> _knownIds = <String>{};
  CompanyNotification? _current;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _knownIds.addAll(
      widget.controller.state.companyNotifications.map((item) => item.id),
    );
    widget.controller.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.controller.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    final fresh =
        widget.controller.state.companyNotifications
            .where((item) => _knownIds.add(item.id))
            .where((item) => item.kind != CompanyNotificationKind.research)
            .toList(growable: false)
          ..sort((left, right) {
            final byTime = right.simulationMinutes.compareTo(
              left.simulationMinutes,
            );
            return byTime != 0 ? byTime : right.id.compareTo(left.id);
          });
    if (fresh.isEmpty) return;
    _present(fresh.first);
  }

  void _present(CompanyNotification item) {
    _timer?.cancel();
    if (!mounted) return;
    setState(() => _current = item);
    _timer = Timer(
      const Duration(seconds: 5),
      () => _hideCurrent(markRead: false),
    );
  }

  void _hideCurrent({required bool markRead}) {
    final item = _current;
    _timer?.cancel();
    if (item == null) return;
    if (markRead && !item.read) {
      widget.controller.dispatch(
        MarkCompanyNotificationRead(item.id),
        playSound: false,
      );
    }
    if (mounted) {
      setState(() => _current = null);
    }
  }

  void _openCurrent() {
    final item = _current;
    if (item == null) return;
    _hideCurrent(markRead: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) =>
              CompanyNotificationCenterScreen(controller: widget.controller),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          top: MediaQuery.paddingOf(context).top + 62,
          left: 10,
          right: 10,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            reverseDuration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.18),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
            child: current == null
                ? const SizedBox.shrink(
                    key: ValueKey<String>('no-company-notification-toast'),
                  )
                : Dismissible(
                    key: ValueKey<String>(
                      'top-company-notification-toast-${current.id}',
                    ),
                    direction: DismissDirection.up,
                    resizeDuration: null,
                    dismissThresholds: const <DismissDirection, double>{
                      DismissDirection.up: 0.22,
                    },
                    onDismissed: (_) => _hideCurrent(markRead: true),
                    child: Material(
                      key: const Key('top-company-notification-toast'),
                      elevation: 9,
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _openCurrent,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
                          child: Row(
                            children: [
                              Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _toastColor(current.kind),
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      current.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    AppText(
                                      current.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.keyboard_arrow_up_rounded,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

Color _toastColor(CompanyNotificationKind kind) => switch (kind) {
  CompanyNotificationKind.contract => const Color(0xFF3D8BFF),
  CompanyNotificationKind.development ||
  CompanyNotificationKind.product => AppColors.green,
  CompanyNotificationKind.finance ||
  CompanyNotificationKind.employee => AppColors.red,
  CompanyNotificationKind.investor => const Color(0xFF8E6CFF),
  CompanyNotificationKind.research => const Color(0xFF33BBD7),
  _ => const Color(0xFFE8B84A),
};
