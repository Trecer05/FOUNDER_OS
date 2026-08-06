import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/v9_models.dart';
import 'app_card.dart';
import '../../../application/localization/app_text.dart';

class SpecialistDeficitCard extends StatelessWidget {
  const SpecialistDeficitCard({required this.deficits, super.key});

  final List<SpecialistDeficit> deficits;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hintTitle: 'Конкретный дефицит специалистов',
      hintBody:
          'Список строится детерминированно: сначала критичность навыка, затем роль и язык. Он не зависит от порядка Set, Map или JSON.',
      child: deficits.isEmpty
          ? const Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.green),
                SizedBox(width: 10),
                Expanded(
                  child: AppText('Критичных дефицитов для текущей стадии нет.'),
                ),
              ],
            )
          : Column(
              key: const Key('specialist-deficit-list'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Что тормозит проект',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...deficits.map(
                  (deficit) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.red.withAlpha(12),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.red.withAlpha(45)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            deficit.message,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            '${deficit.effect} Стадия: ${deficit.stageName}.',
                          ),
                          const SizedBox(height: 5),
                          AppText(
                            'Решения: ${deficit.solutions.join(' • ')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
