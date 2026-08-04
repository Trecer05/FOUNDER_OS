import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import 'app_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.positive,
    this.accent,
    super.key,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData? icon;
  final bool? positive;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final resolvedAccent =
        accent ??
        (positive == null
            ? AppColors.primary
            : positive!
            ? AppColors.green
            : AppColors.red);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: resolvedAccent),
                const SizedBox(width: 7),
              ],
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Text(
              caption!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: resolvedAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
