import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        const SectionHeader(
          title: 'Компания',
          subtitle:
              'Только сводные показатели. Метрики каждого продукта находятся в его карточке.',
        ),
        const SizedBox(height: 12),
        _TimeControls(controller: controller),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.45,
          children: [
            MetricCard(label: 'Cash', value: money(state.cash)),
            MetricCard(
              label: 'Прибыль / мес.',
              value: money(state.monthlyProfit),
              positive: state.monthlyProfit >= 0,
            ),
            MetricCard(
              label: 'Доля основателя',
              value: directPercent(
                state.founderOwnershipPercent,
                fractionDigits: 1,
              ),
              positive: state.founderOwnershipPercent >= 60,
            ),
            MetricCard(label: 'Оценка', value: money(state.valuation)),
            MetricCard(
              label: 'Загрузка серверов',
              value: percent(state.serverLoad, fractionDigits: 1),
              positive: state.serverLoad <= 0.85,
            ),
            MetricCard(
              label: 'Runway',
              value: state.runwayMonths >= 99
                  ? 'Положительный'
                  : '${state.runwayMonths.toStringAsFixed(1)} мес.',
              positive: state.runwayMonths >= 6,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionHeader(
          title: 'Операционная сводка',
          subtitle: 'Числа компании без смешивания отдельных систем.',
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            children: [
              _SummaryRow(label: 'Продукты', value: '${state.products.length}'),
              _SummaryRow(
                label: 'Сотрудники / места',
                value: '${state.employees.length} / ${state.office.capacity}',
              ),
              _SummaryRow(
                label: 'Compute capacity',
                value: '${state.totalComputeUnits.round()} units',
              ),
              _SummaryRow(
                label: 'Выделено продуктам',
                value: directPercent(
                  state.totalAllocatedPercent,
                  fractionDigits: 0,
                ),
              ),
              _SummaryRow(
                label: 'Инвесторы',
                value: '${state.investorAgreements.length}',
              ),
              _SummaryRow(
                label: 'Портфель внешних долей',
                value: '${state.portfolioHoldings.length}',
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionHeader(
          title: 'Важные новости',
          subtitle: state.news.isEmpty
              ? 'Пока пусто.'
              : 'Только события рынка, атак, сделок и релизов.',
        ),
        const SizedBox(height: 10),
        ...state.news
            .take(3)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.critical
                            ? Icons.warning_amber_rounded
                            : Icons.newspaper_outlined,
                        color: item.critical
                            ? AppColors.red
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(item.body),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        const SizedBox(height: 8),
        const SectionHeader(
          title: 'Причины последних изменений',
          subtitle: 'Лента объясняет решения и ограничения.',
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: state.feed
                .take(8)
                .map(
                  (message) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: CircleAvatar(
                            radius: 3,
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(message)),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _TimeControls extends StatelessWidget {
  const _TimeControls({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'День ${state.day} • ${state.formattedTime}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      state.paused ? 'Симуляция на паузе' : 'Компания работает',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: state.criticalEvent == CriticalEventType.none
                    ? () => controller.dispatch(const TogglePause())
                    : null,
                icon: Icon(state.paused ? Icons.play_arrow : Icons.pause),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<GameSpeed>(
            segments: const [
              ButtonSegment(value: GameSpeed.x1, label: Text('1x')),
              ButtonSegment(value: GameSpeed.x2, label: Text('2x')),
              ButtonSegment(value: GameSpeed.x4, label: Text('4x')),
            ],
            selected: <GameSpeed>{state.speed},
            onSelectionChanged: (value) {
              controller.dispatch(SetGameSpeed(value.first));
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: state.criticalEvent == CriticalEventType.none
                  ? () => controller.dispatch(const SkipNight())
                  : null,
              icon: const Icon(Icons.nightlight_outlined),
              label: const Text('Пропустить до 08:00'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        if (!last) const Divider(),
      ],
    );
  }
}
