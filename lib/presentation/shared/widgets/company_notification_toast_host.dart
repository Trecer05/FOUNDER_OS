import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../application/localization/app_text.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/v17_models.dart';
import '../../features/contracts/contracts_screen.dart';
import '../../features/investors/investors_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/company/company_hub_screen.dart';

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
  final List<CompanyNotification> _queue = <CompanyNotification>[];
  CompanyNotification? _current;
  Timer? _timer;
  bool _collapsing = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.controller.state.companyNotifications;
    _knownIds.addAll(initial.map((item) => item.id));
    _queue.addAll(
      initial.where((item) => !item.read).toList(growable: false)
        ..sort((a, b) => a.simulationMinutes.compareTo(b.simulationMinutes)),
    );
    widget.controller.addListener(_onStateChanged);
    if (_queue.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showNext());
    }
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
            .toList(growable: false)
          ..sort((a, b) => a.simulationMinutes.compareTo(b.simulationMinutes));
    if (fresh.isEmpty) return;
    _queue.addAll(fresh);
    if (_current == null) {
      _showNext();
    }
  }

  void _showNext() {
    _timer?.cancel();
    if (!mounted) return;
    if (_queue.isEmpty) {
      setState(() {
        _current = null;
        _collapsing = false;
      });
      return;
    }
    setState(() {
      _current = _queue.removeAt(0);
      _collapsing = false;
    });
    _timer = Timer(const Duration(seconds: 5), _collapseCurrent);
  }

  void _collapseCurrent() {
    if (!mounted || _current == null) return;
    setState(() => _collapsing = true);
    _timer = Timer(const Duration(milliseconds: 620), _showNext);
  }

  void _openCurrent() {
    final item = _current;
    if (item == null) return;
    _timer?.cancel();
    widget.controller.dispatch(
      MarkCompanyNotificationRead(item.id),
      playSound: false,
    );
    _navigate(item);
    setState(() {
      _current = null;
      _collapsing = false;
    });
    Future<void>.delayed(const Duration(milliseconds: 250), _showNext);
  }

  void _navigate(CompanyNotification item) {
    final page = switch (item.kind) {
      CompanyNotificationKind.contract => ContractsScreen(
        controller: widget.controller,
      ),
      CompanyNotificationKind.development || CompanyNotificationKind.product =>
        ProductsScreen(controller: widget.controller),
      CompanyNotificationKind.investor => InvestorsScreen(
        controller: widget.controller,
      ),
      _ => CompanyHubScreen(controller: widget.controller),
    };
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (current != null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 62,
            left: 10,
            right: 10,
            child: IgnorePointer(
              ignoring: _collapsing,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: _collapsing ? 1 : 0),
                duration: const Duration(milliseconds: 580),
                curve: Curves.easeInCubic,
                builder: (context, progress, child) {
                  return Transform.translate(
                    offset: Offset(progress * 130, -progress * 42),
                    child: Transform.scale(
                      alignment: Alignment.topRight,
                      scale: 1 - progress * 0.72,
                      child: Opacity(
                        opacity: 1 - progress * 0.95,
                        child: ClipPath(
                          clipper: _GenieClipper(progress),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: Material(
                  elevation: 9,
                  borderRadius: BorderRadius.circular(18),
                  color: AppColors.surface,
                  child: InkWell(
                    key: const Key('top-company-notification-toast'),
                    borderRadius: BorderRadius.circular(18),
                    onTap: _openCurrent,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
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
                          const Icon(Icons.chevron_right),
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

class _GenieClipper extends CustomClipper<Path> {
  const _GenieClipper(this.progress);

  final double progress;

  @override
  Path getClip(Size size) {
    final squeeze = size.height * 0.42 * progress;
    return Path()
      ..moveTo(size.width * progress * 0.58, squeeze)
      ..quadraticBezierTo(
        size.width * 0.56,
        -squeeze * 0.18,
        size.width,
        squeeze * 0.72,
      )
      ..lineTo(size.width, size.height - squeeze * 0.72)
      ..quadraticBezierTo(
        size.width * 0.56,
        size.height + squeeze * 0.18,
        size.width * progress * 0.58,
        size.height - squeeze,
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant _GenieClipper oldClipper) =>
      oldClipper.progress != progress;
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
