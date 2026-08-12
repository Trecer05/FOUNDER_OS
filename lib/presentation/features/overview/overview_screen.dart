import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/entities/business_models.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/r2_gameplay_extensions.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';
import '../contracts/contract_detail_screen.dart';
import '../products/product_detail_screen.dart';
import '../../../application/localization/app_text.dart';

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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.45,
          children: [
            MetricCard(label: 'Cash', value: money(state.cash)),
            _ProfitMetricCard(monthlyProfit: state.monthlyProfit),
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
        const SizedBox(height: 12),
        Builder(
          builder: (context) {
            final reputation = state.reputationBreakdown;
            final delta = reputation.projectedDailyDelta;
            return AppCard(
              key: const Key('reputation-breakdown'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: AppText(
                          'Почему меняется репутация',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      AppText(
                        '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(3)}/день',
                        translate: false,
                        style: TextStyle(
                          color: delta >= 0 ? AppColors.green : AppColors.red,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...reputation.drivers.map(
                    (driver) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  driver.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                AppText(
                                  driver.explanation,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          AppText(
                            '${driver.deltaPerDay >= 0 ? '+' : ''}${driver.deltaPerDay.toStringAsFixed(3)}',
                            translate: false,
                            style: TextStyle(
                              color: driver.deltaPerDay >= 0
                                  ? AppColors.green
                                  : AppColors.red,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
                label: 'Compute',
                value: '${state.totalComputeUnits.round()} CU',
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
          title: 'Активная работа',
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
            child: AppText('Создайте первый продукт во вкладке «Продукты».'),
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
        if (state.activeContracts.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...state.activeContracts.map(
            (contract) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ContractSummaryCard(
                state: state,
                contract: contract,
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => ContractDetailScreen(
                      controller: controller,
                      contractId: contract.id,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
                            AppText(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            AppText(item.body),
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
                        Expanded(child: AppText(message)),
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

class _ProfitMetricCard extends StatefulWidget {
  const _ProfitMetricCard({required this.monthlyProfit});

  final double monthlyProfit;

  @override
  State<_ProfitMetricCard> createState() => _ProfitMetricCardState();
}

class _ProfitMetricCardState extends State<_ProfitMetricCard> {
  bool _daily = false;

  @override
  Widget build(BuildContext context) {
    final value = _daily ? widget.monthlyProfit / 30 : widget.monthlyProfit;
    return MetricCard(
      key: const Key('overview-profit-period-toggle'),
      label: _daily ? 'Прибыль / день' : 'Прибыль / мес.',
      value: money(value),
      positive: value >= 0,
      onTap: () => setState(() => _daily = !_daily),
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
    final staffing = state.developmentStaffingFor(product.id);
    final phase = state.developmentPhaseFor(product);
    final featureWork = state.activeFeatureDevelopmentFor(product.id);
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
                    AppText(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppText(
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
            AppText(
              '${phase.name} • ${(product.developmentProgress * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 4),
            AppText(
              staffing.status,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: AppText('Команда $teamCount')),
              Chip(label: AppText('Роли ${(coverage * 100).round()}%')),
              if (!live)
                Chip(
                  label: AppText(
                    'Эфф. ${(staffing.efficiency * 100).round()}%',
                  ),
                ),
              if (featureWork != null)
                Chip(
                  label: AppText(
                    'Update ${(featureWork.progress * 100).toStringAsFixed(0)}%',
                  ),
                ),
              if (live)
                Chip(label: AppText('Users ${compactNumber(product.users)}')),
              if (live)
                Chip(
                  label: AppText(
                    'Свежесть ${state.productFreshnessScore(product).round()}',
                  ),
                ),
              if (live)
                Chip(
                  label: AppText('${net >= 0 ? '+' : ''}${money(net)}/мес.'),
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

class _ContractSummaryCard extends StatelessWidget {
  const _ContractSummaryCard({
    required this.state,
    required this.contract,
    required this.onTap,
  });

  final GameState state;
  final ClientContract contract;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final template = state.contractTemplate(contract.templateId);
    final team = state.employeesForContract(contract.id);
    final daysLeft =
        ((contract.deadlineAtMinutes - state.simulationMinutes) / 1440)
            .clamp(0, 999)
            .toDouble();
    return AppCard(
      key: Key('overview-contract-${contract.id}'),
      onTap: onTap,
      hintTitle: 'Контракт ${template.name}',
      hintBody:
          'Откройте карточку, чтобы назначить команду и увидеть подробный ETA.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppText(template.client),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: contract.progress),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: AppText(
                  '${(contract.progress * 100).toStringAsFixed(1)}%',
                ),
              ),
              Chip(label: AppText('Команда ${team.length}')),
              Chip(label: AppText('${daysLeft.toStringAsFixed(1)} дн.')),
            ],
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: AppText(label)),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: AppText(
                  value,
                  textAlign: TextAlign.end,
                  softWrap: true,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        if (!last) const Divider(),
      ],
    );
  }
}
