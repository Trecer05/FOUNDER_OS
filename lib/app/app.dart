import 'package:flutter/material.dart';

import '../application/controllers/game_controller.dart';
import '../presentation/features/dashboard/founder_dashboard.dart';
import 'theme/app_theme.dart';

class FounderOsApp extends StatelessWidget {
  const FounderOsApp({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FOUNDER.OS',
      theme: AppTheme.light(),
      home: FounderDashboard(controller: controller),
    );
  }
}
