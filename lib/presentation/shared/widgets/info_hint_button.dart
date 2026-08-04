import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

class InfoHintButton extends StatelessWidget {
  const InfoHintButton({
    required this.title,
    required this.body,
    this.bullets = const <String>[],
    super.key,
  });

  final String title;
  final String body;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        fixedSize: const Size(28, 28),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      tooltip: 'Подсказка: $title',
      onPressed: () => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
          ),
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(body),
                if (bullets.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...bullets.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Понятно'),
            ),
          ],
        ),
      ),
      icon: const Icon(Icons.info_outline_rounded, size: 20),
    );
  }
}
