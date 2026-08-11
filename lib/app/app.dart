// UAT_FIXPACK_R1
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../application/controllers/game_controller.dart';
import '../application/settings/display_preferences.dart';
import '../domain/commands/game_action.dart';
import '../presentation/features/dashboard/founder_dashboard.dart';
import '../presentation/features/menu/main_menu_screen.dart';
import '../presentation/shared/widgets/global_time_control_bar.dart';
import 'theme/app_theme.dart';
import '../presentation/shared/widgets/scoped_listenable_builder.dart';

class FounderOsApp extends StatefulWidget {
  const FounderOsApp({
    required this.controller,
    this.showGlobalTimeControls = true,
    this.startAtMainMenu = false,
    super.key,
  });

  final GameController controller;
  final bool showGlobalTimeControls;
  final bool startAtMainMenu;

  @override
  State<FounderOsApp> createState() => _FounderOsAppState();
}

class _FounderOsAppState extends State<FounderOsApp> {
  late bool _inGame;
  late final _ModalRouteObserver _modalObserver;
  int _modalDepth = 0;

  @override
  void initState() {
    super.initState();
    _inGame = !widget.startAtMainMenu;
    _modalObserver = _ModalRouteObserver((depth) {
      if (!mounted || depth == _modalDepth) return;
      setState(() => _modalDepth = depth);
    });
    if (widget.startAtMainMenu && !widget.controller.state.paused) {
      widget.controller.dispatch(const TogglePause(), playSound: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedAnimatedBuilder(
      animation: DisplayPreferences.instance,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FOUNDER.OS',
        locale: Locale(
          DisplayPreferences.instance.language == AppLanguage.en ? 'en' : 'ru',
        ),
        supportedLocales: const <Locale>[Locale('ru'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        navigatorObservers: <NavigatorObserver>[_modalObserver],
        theme: AppTheme.light(),
        builder: (context, child) {
          final media = MediaQuery.of(context);
          final controlsVisible =
              widget.showGlobalTimeControls &&
              _inGame &&
              media.viewInsets.bottom == 0;
          const controlsHeight = 58.0;
          final content = MediaQuery(
            data: media.copyWith(
              padding: media.padding.copyWith(
                top: media.padding.top + (controlsVisible ? controlsHeight : 0),
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              content,
              if (controlsVisible)
                Positioned(
                  top: media.padding.top + 5,
                  left: 8,
                  right: 8,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: IgnorePointer(
                      // PopupRoute (dialogs, modal sheets, technical challenges)
                      // lives inside Navigator. The global time bar is outside
                      // Navigator and otherwise stays tappable above its barrier.
                      ignoring: _modalDepth > 0,
                      child: GlobalTimeControlBar(
                        controller: widget.controller,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        home: _inGame
            ? FounderDashboard(
                controller: widget.controller,
                onExitToMainMenu: widget.startAtMainMenu
                    ? () => setState(() => _inGame = false)
                    : null,
              )
            : MainMenuScreen(
                controller: widget.controller,
                onEnterGame: () => setState(() => _inGame = true),
              ),
      ),
    );
  }
}

class _ModalRouteObserver extends NavigatorObserver {
  _ModalRouteObserver(this.onDepthChanged);

  final ValueChanged<int> onDepthChanged;
  final Set<Route<dynamic>> _popupRoutes = <Route<dynamic>>{};

  void _sync() => onDepthChanged(_popupRoutes.length);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PopupRoute<dynamic>) {
      _popupRoutes.add(route);
      _sync();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_popupRoutes.remove(route)) {
      _sync();
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_popupRoutes.remove(route)) {
      _sync();
    }
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    var changed = false;
    if (oldRoute != null) {
      changed = _popupRoutes.remove(oldRoute) || changed;
    }
    if (newRoute is PopupRoute<dynamic>) {
      changed = _popupRoutes.add(newRoute) || changed;
    }
    if (changed) {
      _sync();
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
