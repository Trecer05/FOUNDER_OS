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

  @override
  void initState() {
    super.initState();
    _inGame = !widget.startAtMainMenu;
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
                  child: GlobalTimeControlBar(controller: widget.controller),
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
