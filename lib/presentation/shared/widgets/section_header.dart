import 'package:flutter/material.dart';

import 'info_hint_button.dart';
import '../../../application/localization/app_text.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    this.hintTitle,
    this.hintBody,
    this.hintBullets = const <String>[],
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? hintTitle;
  final String? hintBody;
  final List<String> hintBullets;

  @override
  Widget build(BuildContext context) {
    final hint = hintTitle != null && hintBody != null
        ? InfoHintButton(
            title: hintTitle!,
            body: hintBody!,
            bullets: hintBullets,
          )
        : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                AppText(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        ?hint,
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}
