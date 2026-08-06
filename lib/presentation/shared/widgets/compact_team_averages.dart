import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/game_state.dart';

class CompactTeamAverages extends StatelessWidget {
  const CompactTeamAverages({required this.state, super.key});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final values = <(String, double)>[
      ('Skill', state.averageEmployeeSkill),
      ('Speed', state.averageEmployeeSpeed),
      ('Quality', state.averageEmployeeQuality),
      ('Reliability', state.averageEmployeeReliability),
      ('Morale', state.averageEmployeeMorale),
      ('Loyalty', state.averageEmployeeLoyalty),
    ];
    return ConstrainedBox(
      key: const Key('compact-team-averages'),
      constraints: const BoxConstraints(maxHeight: 148),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 16) / 3;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values
                .map(
                  (item) => SizedBox(
                    width: width,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 7,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              item.$2.toStringAsFixed(0),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}
