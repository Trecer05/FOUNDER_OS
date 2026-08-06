import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import 'app_card.dart';
import 'info_hint_button.dart';
import '../../../application/localization/app_text.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.positive,
    this.accent,
    this.hint,
    this.showHint = true,
    super.key,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData? icon;
  final bool? positive;
  final Color? accent;
  final String? hint;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final resolvedAccent =
        accent ??
        (positive == null
            ? AppColors.primary
            : positive!
            ? AppColors.green
            : AppColors.red);
    final resolvedHint = showHint ? (hint ?? _metricHint(label)) : null;
    return AppCard(
      showHint: false,
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
                child: AppText(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (resolvedHint != null)
                SizedBox(
                  width: 28,
                  height: 28,
                  child: InfoHintButton(title: label, body: resolvedHint),
                ),
            ],
          ),
          const SizedBox(height: 5),
          AppText(
            value,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            AppText(
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

String? _metricHint(String label) {
  final key = label.toLowerCase();
  if (key.contains('cash')) {
    return 'Деньги компании. Из них оплачиваются разработка, найм, аренда, серверы, безопасность и обновления.';
  }
  if (key.contains('выруч') || key.contains('mrr')) {
    return 'Ежемесячная выручка продукта или всей компании до вычета расходов.';
  }
  if (key.contains('расход')) {
    return 'Текущий месячный burn: зарплаты, инфраструктура, продуктовые расходы, AI, security и выплаты инвесторам.';
  }
  if (key.contains('прибыл')) {
    return 'Выручка минус все ежемесячные расходы.';
  }
  if (key.contains('runway')) {
    return 'На сколько месяцев хватит денег при текущем отрицательном денежном потоке.';
  }
  if (key.contains('valuation')) {
    return 'Оценка компании из выручки, пользователей, качества технологий, прибыли и экосистемы.';
  }
  if (key.contains('users')) {
    return 'Общее число пользователей продукта, включая неактивных.';
  }
  if (key.contains('dau')) {
    return 'DAU — активные за день, MAU — активные за месяц. Их соотношение показывает частоту использования.';
  }
  if (key.contains('activation')) {
    return 'Доля новых пользователей, которые дошли до первого полезного действия.';
  }
  if (key.contains('retention')) {
    return 'Доля пользователей, вернувшихся спустя 30 дней.';
  }
  if (key.contains('churn')) {
    return 'Доля пользователей, которые уходят за месяц. Чем ниже, тем лучше.';
  }
  if (key.contains('rating')) {
    return 'Публичная оценка продукта. Зависит от качества, свежести, стабильности и инцидентов.';
  }
  if (key.contains('skill')) {
    return 'Средний профессиональный уровень сотрудников.';
  }
  if (key.contains('speed')) {
    return 'Средняя скорость выполнения работы сотрудниками или latency продукта — зависит от контекста карточки.';
  }
  if (key.contains('quality')) {
    return 'Среднее качество работы команды или интегральное качество продукта.';
  }
  if (key.contains('reliability')) {
    return 'Надёжность: способность работать без ошибок, сбоев и аварий.';
  }
  if (key.contains('morale')) {
    return 'Мораль команды. Падает при перегрузке и влияет на устойчивость работы.';
  }
  if (key.contains('loyalty')) {
    return 'Лояльность сотрудников компании. Важна для удержания сильных специалистов.';
  }
  return null;
}
