import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../application/controllers/game_controller.dart';
import '../application/settings/display_preferences.dart';
import '../presentation/features/dashboard/founder_dashboard.dart';
import '../presentation/shared/widgets/global_time_control_bar.dart';
import 'theme/app_theme.dart';

class FounderOsApp extends StatelessWidget {
  const FounderOsApp({
    required this.controller,
    this.showGlobalTimeControls = true,
    super.key,
  });

  final GameController controller;
  final bool showGlobalTimeControls;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
              showGlobalTimeControls && media.viewInsets.bottom == 0;
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
                    child: GlobalTimeControlBar(controller: controller),
                  ),
                ),
            ],
          );
        },
        home: FounderDashboard(controller: controller),
      ),
    );
  }
}
