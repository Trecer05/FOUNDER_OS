import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/entities/management_models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';

enum _FinanceSeries { cash, income, expenses, profit }

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  _FinanceSeries _series = _FinanceSeries.cash;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        final productTech = state.products.fold<double>(
          0,
          (sum, item) => sum + item.monthlyCost,
        );
        final improvements = state.products.fold<double>(
          0,
          (sum, item) => sum + state.productImprovementMonthlyCost(item.id),
        );
        final infra =
            state.office.monthlyRent +
            state.serverRoom.monthlyRent +
            state.monthlyHardwareCost;
        final history = state.financeHistory.isEmpty
            ? <FinanceHistoryPoint>[
                FinanceHistoryPoint(
                  simulationMinutes: state.simulationMinutes,
                  cash: state.cash,
                  incomeRunRate:
                      state.monthlyProductRevenue + state.portfolioIncome,
                  expenseRunRate: state.monthlyCosts,
                  profitRunRate: state.monthlyProfit,
                ),
              ]
            : state.financeHistory;

        return Scaffold(
          appBar: AppBar(title: const Text('Финансы компании')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const SectionHeader(
                title: 'P&L, история и денежные потоки',
                subtitle:
                    'График хранится в сохранении и показывает изменение cash и месячного run rate по игровым дням.',
                hintTitle: 'Как читать финансы',
                hintBody:
                    'Фактический cash меняется непрерывно. Доходы и расходы на графике — месячный темп на конкретный игровой день, а не обещанная сумма за будущий месяц.',
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 126,
                children: [
                  MetricCard(label: 'Cash', value: money(state.cash)),
                  MetricCard(
                    label: 'Доход / мес.',
                    value: money(
                      state.monthlyProductRevenue + state.portfolioIncome,
                    ),
                  ),
                  MetricCard(
                    label: 'Расход / мес.',
                    value: money(state.monthlyCosts),
                    positive: false,
                  ),
                  MetricCard(
                    label: 'Прибыль / мес.',
                    value: money(state.monthlyProfit),
                    positive: state.monthlyProfit >= 0,
                  ),
                  MetricCard(
                    label: 'Runway',
                    value: state.runwayMonths >= 99
                        ? '∞'
                        : '${state.runwayMonths.toStringAsFixed(1)} мес.',
                    positive: state.runwayMonths >= 12,
                  ),
                  MetricCard(label: 'Valuation', value: money(state.valuation)),
                ],
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Динамика',
                subtitle: 'Последние 120 ежедневных точек.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    SegmentedButton<_FinanceSeries>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: _FinanceSeries.cash,
                          label: Text('Cash'),
                        ),
                        ButtonSegment(
                          value: _FinanceSeries.income,
                          label: Text('Доход'),
                        ),
                        ButtonSegment(
                          value: _FinanceSeries.expenses,
                          label: Text('Расход'),
                        ),
                        ButtonSegment(
                          value: _FinanceSeries.profit,
                          label: Text('Profit'),
                        ),
                      ],
                      selected: <_FinanceSeries>{_series},
                      onSelectionChanged: (value) {
                        setState(() => _series = value.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      key: const Key('finance-history-chart'),
                      height: 210,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _FinanceChartPainter(
                          points: history,
                          series: _series,
                          lineColor: _series == _FinanceSeries.expenses
                              ? AppColors.red
                              : _series == _FinanceSeries.profit &&
                                    state.monthlyProfit < 0
                              ? AppColors.red
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Точек: ${history.length} • от дня ${history.first.simulationMinutes ~/ 1440 + 1} до дня ${history.last.simulationMinutes ~/ 1440 + 1}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Структура расходов',
                subtitle: 'Текущий месячный run rate по категориям.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    _BreakdownBar(
                      label: 'Payroll',
                      value: state.monthlyPayroll,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Офис и инфраструктура',
                      value: infra,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Продукты и маркетинг',
                      value: productTech,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Постоянные улучшения',
                      value: improvements,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Корпоративная AI',
                      value: state.monthlyCorporateAiCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Security',
                      value: state.monthlySecurityCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Инвесторы',
                      value: state.investorPayouts,
                      total: state.monthlyCosts,
                      last: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Последние операции',
                subtitle:
                    'Разовые покупки, авансы, инвестиции и другие изменения cash.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: state.financeTransactions.isEmpty
                    ? const Text('Разовых финансовых операций пока нет.')
                    : Column(
                        children: state.financeTransactions
                            .take(30)
                            .map((item) => _TransactionTile(transaction: item))
                            .toList(growable: false),
                      ),
              ),
              const SizedBox(height: 18),
              SectionHeader(
                title: 'Cap table',
                subtitle:
                    'Доля основателя ${directPercent(state.founderOwnershipPercent, fractionDigits: 1)}. Ниже 50% управление теряется.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    _OwnershipBar(
                      founderPercent: state.founderOwnershipPercent,
                    ),
                    const SizedBox(height: 12),
                    if (state.investorAgreements.isEmpty)
                      const Text('Внешних инвесторов пока нет.')
                    else
                      ...state.investorAgreements.map((agreement) {
                        final investor = GameCatalog.investorById(
                          agreement.investorId,
                        );
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(investor.name),
                          subtitle: Text(
                            'Revenue share ${directPercent(agreement.revenueSharePercent, fractionDigits: 1)}',
                          ),
                          trailing: Text(
                            directPercent(
                              agreement.equityPercent,
                              fractionDigits: 1,
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FinanceChartPainter extends CustomPainter {
  const _FinanceChartPainter({
    required this.points,
    required this.series,
    required this.lineColor,
  });

  final List<FinanceHistoryPoint> points;
  final _FinanceSeries series;
  final Color lineColor;

  double _value(FinanceHistoryPoint point) => switch (series) {
    _FinanceSeries.cash => point.cash,
    _FinanceSeries.income => point.incomeRunRate,
    _FinanceSeries.expenses => point.expenseRunRate,
    _FinanceSeries.profit => point.profitRunRate,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i += 1) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final values = points.map(_value).toList(growable: false);
    if (values.isEmpty) {
      return;
    }
    var minimum = values.reduce(math.min);
    var maximum = values.reduce(math.max);
    if ((maximum - minimum).abs() < 1) {
      minimum -= 1;
      maximum += 1;
    }
    final path = Path();
    for (var index = 0; index < values.length; index += 1) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * index / (values.length - 1);
      final normalized = (values[index] - minimum) / (maximum - minimum);
      final y = size.height - normalized * (size.height - 12) - 6;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _FinanceChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.series != series ||
      oldDelegate.lineColor != lineColor;
}

class _BreakdownBar extends StatelessWidget {
  const _BreakdownBar({
    required this.label,
    required this.value,
    required this.total,
    this.last = false,
  });

  final String label;
  final double value;
  final double total;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final share = total <= 0 ? 0.0 : (value / total).clamp(0, 1).toDouble();
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(
                money(value),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: share),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final FinanceTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: (transaction.income ? AppColors.green : AppColors.red)
            .withAlpha(20),
        foregroundColor: transaction.income ? AppColors.green : AppColors.red,
        child: Icon(
          transaction.income ? Icons.south_west : Icons.north_east,
          size: 18,
        ),
      ),
      title: Text(transaction.description),
      subtitle: Text(
        'День ${transaction.simulationMinutes ~/ 1440 + 1} • ${transaction.category.name}',
      ),
      trailing: Text(
        '${transaction.income ? '+' : ''}${money(transaction.amount)}',
        style: TextStyle(
          color: transaction.income ? AppColors.green : AppColors.red,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _OwnershipBar extends StatelessWidget {
  const _OwnershipBar({required this.founderPercent});

  final double founderPercent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Text('Основатель')),
            Text(
              directPercent(founderPercent, fractionDigits: 1),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: founderPercent / 100, minHeight: 12),
      ],
    );
  }
}
