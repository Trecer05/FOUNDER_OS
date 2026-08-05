import 'package:flutter/material.dart';

import '../application/controllers/game_controller.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FOUNDER.OS',
      theme: AppTheme.light(),
      builder: (context, child) => Column(
        children: [
          Expanded(child: child ?? const SizedBox.shrink()),
          if (showGlobalTimeControls)
            GlobalTimeControlBar(controller: controller),
        ],
      ),
      home: FounderDashboard(controller: controller),
    );
  }
}
