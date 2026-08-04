import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import 'info_hint_button.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.hintTitle,
    this.hintBody,
    this.hintBullets = const <String>[],
    this.showHint = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? hintTitle;
  final String? hintBody;
  final List<String> hintBullets;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final hint = showHint
        ? Align(
            alignment: Alignment.centerRight,
            child: InfoHintButton(
              title: hintTitle ?? 'Как читать эту карточку',
              body:
                  hintBody ??
                  'Здесь собраны показатели и действия конкретной сущности. Перед подтверждением сравнивайте стоимость, требования, нагрузку и ожидаемый эффект.',
              bullets: hintBullets,
            ),
          )
        : null;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: hint == null
              ? child
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 28, child: hint),
                    child,
                  ],
                ),
        ),
      ),
    );
  }
}
