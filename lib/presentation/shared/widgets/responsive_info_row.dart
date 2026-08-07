import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/localization/app_text.dart';

class ResponsiveInfoRow extends StatelessWidget {
  const ResponsiveInfoRow(
    this.label,
    this.value, {
    this.last = false,
    super.key,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 360 || label.length + value.length > 42;
        final content = stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(label),
                  const SizedBox(height: 5),
                  AppText(
                    value,
                    style: Theme.of(context).textTheme.titleMedium,
                    softWrap: true,
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: AppText(label)),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: AppText(
                      value,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.titleMedium,
                      softWrap: true,
                    ),
                  ),
                ],
              );
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: content,
            ),
            if (!last) const Divider(color: AppColors.border),
          ],
        );
      },
    );
  }
}
