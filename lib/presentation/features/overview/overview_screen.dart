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
import '../products/product_detail_screen.dart';

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
                label: 'Команда',
                value:
                    '${state.onSiteEmployeeCount}/${state.office.capacity} в офисе • ${state.remoteEmployeeCount} remote',
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
                label: 'Активные контракты',
                value: '${state.activeContracts.length}',
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
          title: 'Проекты',
          subtitle: state.products.isEmpty
              ? 'Собственных продуктов пока нет.'
              : 'Короткая сводка по разработке, команде, деньгам и состоянию каждого продукта.',
          hintTitle: 'Сводка по проектам',
          hintBody:
              'Здесь нет полной продуктовой аналитики. Карточка помогает быстро заметить остановившуюся разработку, нехватку ролей, убыток, устаревание или перегрузку. Нажмите на неё для подробностей.',
        ),
        const SizedBox(height: 10),
        if (state.products.isEmpty)
          const AppCard(
            hintTitle: 'Первый продукт',
            hintBody:
                'Откройте вкладку «Продукты», выберите категорию, стек и функции. Новый проект начнётся с 0% разработки.',
            child: Text('Создайте первый продукт во вкладке «Продукты».'),
          )
        else
          ...state.products.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ProjectSummaryCard(
                state: state,
                product: product,
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      controller: controller,
                      productId: product.id,
                    ),
                  ),
                ),
              ),
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

class _ProjectSummaryCard extends StatelessWidget {
  const _ProjectSummaryCard({
    required this.state,
    required this.product,
    required this.onTap,
  });

  final GameState state;
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final teamCount = state.employeesForProduct(product.id).length;
    final coverage = state.productRoleCoverage(product.id);
    final live = product.stage == ProductStage.live;
    final net =
        product.monthlyRevenue -
        product.monthlyCost -
        state.productSecurityMonthlyCost(product.id) -
        state.productImprovementMonthlyCost(product.id);
    return AppCard(
      key: Key('overview-project-${product.id}'),
      onTap: onTap,
      hintTitle: 'Сводка ${product.name}',
      hintBody: live
          ? 'Показывает стадию, размер команды, покрытие обязательных ролей, свежесть, пользователей и приблизительный прямой результат продукта без общих расходов компании.'
          : 'Показывает прогресс разработки, назначенную команду и покрытие обязательных ролей. При нулевой скорости назначьте сотрудников в разделе «Операции».',
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
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${categoryName(product.category)} • ${stageName(product.stage)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          if (!live) ...[
            LinearProgressIndicator(value: product.developmentProgress),
            const SizedBox(height: 7),
            Text(
              'Разработка ${(product.developmentProgress * 100).toStringAsFixed(1)}%',
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Команда $teamCount')),
              Chip(label: Text('Роли ${(coverage * 100).round()}%')),
              if (live)
                Chip(label: Text('Users ${compactNumber(product.users)}')),
              if (live)
                Chip(
                  label: Text(
                    'Свежесть ${state.productFreshnessScore(product).round()}',
                  ),
                ),
              if (live)
                Chip(
                  label: Text('${net >= 0 ? '+' : ''}${money(net)}/мес.'),
                  backgroundColor: (net >= 0 ? AppColors.green : AppColors.red)
                      .withAlpha(18),
                ),
            ],
          ),
        ],
      ),
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
