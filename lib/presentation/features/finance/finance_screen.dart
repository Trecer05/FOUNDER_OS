import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/management_models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../../application/localization/app_text.dart';
import '../../shared/widgets/scoped_listenable_builder.dart';
import '../../../application/localization/app_localizer.dart';

enum _FinanceSeries { cash, income, expenses, profit }

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  _FinanceSeries _series = _FinanceSeries.cash;
  bool _dailyProfit = false;
  int? _selectedHistoryIndex;
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedListenableBuilder(
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
        final history = state.financeHistory.isEmpty
            ? <FinanceHistoryPoint>[
                FinanceHistoryPoint(
                  simulationMinutes: state.simulationMinutes,
                  cash: state.cash,
                  incomeRunRate:
                      state.monthlyProductRevenue +
                      state.monthlyWorldProjectRevenue +
                      state.portfolioIncome,
                  expenseRunRate: state.monthlyCosts,
                  profitRunRate: state.monthlyProfit,
                ),
              ]
            : state.financeHistory;

        return Scaffold(
          appBar: AppBar(title: const AppText('Финансы компании')),
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
                      state.monthlyProductRevenue +
                          state.monthlyWorldProjectRevenue +
                          state.portfolioIncome,
                    ),
                  ),
                  MetricCard(
                    label: 'Расход / мес.',
                    value: money(state.monthlyCosts),
                    positive: false,
                  ),
                  MetricCard(
                    key: const Key('finance-profit-period-toggle'),
                    label: _dailyProfit ? 'Прибыль / день' : 'Прибыль / мес.',
                    value: money(
                      _dailyProfit
                          ? state.monthlyProfit / 30
                          : state.monthlyProfit,
                    ),
                    positive: state.monthlyProfit >= 0,
                    onTap: () => setState(() => _dailyProfit = !_dailyProfit),
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
              SectionHeader(
                title: 'Налоги и годовой резерв',
                subtitle:
                    'Налоговое обязательство накапливается весь игровой год и списывается отдельной транзакцией.',
                hintTitle: 'Как работают налоги',
                hintBody:
                    'Налог на прибыль считается с положительной накопленной прибыли года. Payroll tax считается с фонда оплаты труда. Ставки задаются городом HQ.',
              ),
              const SizedBox(height: 10),
              Builder(
                builder: (context) {
                  final taxableProfit = math.max(
                    0,
                    state.taxYearRevenueAccrued - state.taxYearExpensesAccrued,
                  );
                  final corporateReserve =
                      taxableProfit * state.effectiveCorporateTaxRate;
                  final payrollReserve =
                      state.taxYearPayrollAccrued *
                      state.effectivePayrollTaxRate;
                  final dayInTaxYear = (state.simulationMinutes ~/ 1440) % 365;
                  final daysUntilTax = 365 - dayInTaxYear;
                  return AppCard(
                    key: const Key('annual-tax-summary'),
                    child: Column(
                      children: [
                        _FinanceStatusRow(
                          label: 'Налог на прибыль',
                          value:
                              '${(state.effectiveCorporateTaxRate * 100).toStringAsFixed(1)}% • резерв ${money(corporateReserve)}',
                        ),
                        _FinanceStatusRow(
                          label: 'Payroll tax',
                          value:
                              '${(state.effectivePayrollTaxRate * 100).toStringAsFixed(1)}% • резерв ${money(payrollReserve)}',
                        ),
                        _FinanceStatusRow(
                          label: 'Ожидаемое списание',
                          value: money(corporateReserve + payrollReserve),
                        ),
                        _FinanceStatusRow(
                          label: 'Регуляторный OPEX / мес.',
                          value: money(state.monthlyRegulatoryComplianceCost),
                        ),
                        _FinanceStatusRow(
                          label: 'До конца налогового года',
                          value: '$daysUntilTax дн.',
                          last: true,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              SectionHeader(
                title: 'Ликвидность и кредит',
                subtitle: state.cash >= 0
                    ? 'Баланс положительный. Кредитный кризис не активен.'
                    : 'Отрицательный баланс требует исправления в течение ограниченного срока.',
              ),
              const SizedBox(height: 10),
              AppCard(
                hintTitle: 'Правила отрицательного баланса',
                hintBody:
                    'Первая неделя в минусе — время исправить экономику. После недели банк может предложить кредит. Повторный минус при погашении менее 70% приводит к банкротству; после 70% доступна последняя неделя.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.negativeCashSinceMinutes != null)
                      _FinanceStatusRow(
                        label: 'В минусе',
                        value:
                            '${((state.simulationMinutes - state.negativeCashSinceMinutes!) / 1440).clamp(0, 999).toStringAsFixed(1)} дн.',
                      ),
                    _FinanceStatusRow(
                      label: 'Экстренное предложение',
                      value: state.creditOffered ? 'Доступно' : 'Не активно',
                    ),
                    if (state.activeLoan != null) ...[
                      _FinanceStatusRow(
                        label: 'Остаток кредита',
                        value: money(state.activeLoan!.remaining),
                      ),
                      _FinanceStatusRow(
                        label: 'Погашено',
                        value: percent(state.activeLoan!.repaidFraction),
                      ),
                      _FinanceStatusRow(
                        label: 'Платёж / неделю',
                        value: money(state.activeLoan!.weeklyPayment),
                        last: true,
                      ),
                    ] else
                      _FinanceStatusRow(
                        label: 'Активный кредит',
                        value: 'Нет',
                        last: true,
                      ),
                    if (state.activeLoan == null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key('request-business-loan'),
                          onPressed: () => _showBusinessLoanRequest(context),
                          icon: const Icon(Icons.request_quote_outlined),
                          label: const AppText(
                            'Подать заявку на бизнес-кредит',
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        'Кредит виден всегда. Банк оценивает продукты, контракты, burn и security-риск.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (state.creditOffered && state.activeLoan == null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key('accept-emergency-loan'),
                          onPressed: () => _dispatchCreditWithFeedback(
                            context,
                            const AcceptEmergencyLoan(),
                          ),
                          icon: const Icon(Icons.account_balance_outlined),
                          label: const AppText('Запросить экстренный кредит'),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppText(
                        'Банк может отказать: учитываются выпущенные продукты, контракты, burn и security-риск.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Тестовые промокоды',
                subtitle:
                    'Инструмент только для проверки экономики и кризисных сценариев.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      key: const Key('debug-promo-field'),
                      controller: _promoController,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: trContext(context, 'Промокод'),
                        hintText: 'FOUNDER-RICH',
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        key: const Key('redeem-debug-promo'),
                        onPressed: () {
                          widget.controller.dispatch(
                            RedeemDebugPromo(_promoController.text),
                          );
                          _promoController.clear();
                        },
                        icon: const Icon(Icons.science_outlined),
                        label: const AppText('Применить'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      children: [
                        AppText('FOUNDER-RICH', translate: false),
                        AppText(' — добавить 5 млн ₽.'),
                      ],
                    ),
                    const Wrap(
                      children: [
                        AppText('FOUNDER-BROKE', translate: false),
                        AppText(' — установить баланс −500 тыс. ₽.'),
                      ],
                    ),
                  ],
                ),
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
                          label: AppText('Cash'),
                        ),
                        ButtonSegment(
                          value: _FinanceSeries.income,
                          label: AppText('Доход'),
                        ),
                        ButtonSegment(
                          value: _FinanceSeries.expenses,
                          label: AppText('Расход'),
                        ),
                        ButtonSegment(
                          value: _FinanceSeries.profit,
                          label: AppText('Profit'),
                        ),
                      ],
                      selected: <_FinanceSeries>{_series},
                      onSelectionChanged: (value) {
                        setState(() => _series = value.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        void selectAt(double dx) {
                          if (history.isEmpty || constraints.maxWidth <= 0) {
                            return;
                          }
                          final fraction = (dx / constraints.maxWidth)
                              .clamp(0.0, 1.0)
                              .toDouble();
                          final index =
                              (fraction * math.max(0, history.length - 1))
                                  .round()
                                  .clamp(0, history.length - 1)
                                  .toInt();
                          if (_selectedHistoryIndex != index) {
                            setState(() => _selectedHistoryIndex = index);
                          }
                        }

                        return GestureDetector(
                          key: const Key('finance-history-chart'),
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (details) =>
                              selectAt(details.localPosition.dx),
                          onHorizontalDragStart: (details) =>
                              selectAt(details.localPosition.dx),
                          onHorizontalDragUpdate: (details) =>
                              selectAt(details.localPosition.dx),
                          child: SizedBox(
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
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final index =
                            (_selectedHistoryIndex ?? history.length - 1)
                                .clamp(0, history.length - 1)
                                .toInt();
                        final point = history[index];
                        final value = switch (_series) {
                          _FinanceSeries.cash => point.cash,
                          _FinanceSeries.income => point.incomeRunRate,
                          _FinanceSeries.expenses => point.expenseRunRate,
                          _FinanceSeries.profit => point.profitRunRate,
                        };
                        final label = switch (_series) {
                          _FinanceSeries.cash => 'Cash',
                          _FinanceSeries.income => 'Доход / мес.',
                          _FinanceSeries.expenses => 'Расход / мес.',
                          _FinanceSeries.profit => 'Profit / мес.',
                        };
                        return Container(
                          key: const Key('finance-history-selection'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AppText(
                            '${state.formatDateAt(point.simulationMinutes)} • $label ${money(value)} • проведите пальцем по графику',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    AppText(
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
                      label: 'Зарплаты',
                      value: state.monthlyPayroll,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Офис',
                      value: state.monthlyOfficeCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Хостинг и серверы',
                      value:
                          state.monthlyServerRoomCost +
                          state.monthlyHardwareCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Продуктовые сервисы',
                      value: productTech,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Улучшения (только рабочее время)',
                      value: improvements,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Корпоративная AI',
                      value: state.monthlyCorporateAiCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Безопасность',
                      value: state.monthlySecurityCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Реклама',
                      value: state.monthlyAdvertisingSpend,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Масштабирование продуктов',
                      value: state.monthlyScaleOperationsCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Регуляторные расходы',
                      value: state.monthlyRegulatoryComplianceCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Плюшки команды',
                      value: state.monthlyCompanyPerkCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Мировые проекты',
                      value: state.monthlyWorldProjectOperatingCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Выплаты инвесторам',
                      value: state.investorPayouts,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Кредит',
                      value: state.monthlyLoanPayment,
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
                    'Разовые покупки и ежедневные списания. Для крупных расходов здесь видна категория и причина.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: state.financeTransactions.isEmpty
                    ? const AppText('Разовых финансовых операций пока нет.')
                    : Column(
                        children: state.financeTransactions
                            .take(60)
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
                      const AppText('Внешних инвесторов пока нет.')
                    else
                      ...state.investorAgreements.map((agreement) {
                        final investor = GameCatalog.investorById(
                          agreement.investorId,
                        );
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: AppText(investor.name),
                          subtitle: AppText(
                            'Revenue share ${directPercent(agreement.revenueSharePercent, fractionDigits: 1)}',
                          ),
                          trailing: AppText(
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

  Future<void> _showBusinessLoanRequest(BuildContext context) async {
    final state = widget.controller.state;
    var draft = math
        .max(50000, math.min(1000000, state.valuation * 0.08))
        .round()
        .toString();
    final requestedAmount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final amount =
              double.tryParse(draft.replaceAll(' ', '').replaceAll(',', '.')) ??
              0;
          final chance = state.businessLoanApprovalChance(amount);
          final ratio = state.businessLoanRequestRatio(math.max(0, amount));
          final interest = state.businessLoanInterestRate(
            math.max(50000, amount),
          );
          return AlertDialog(
            title: const AppText('Запрос бизнес-кредита'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Вы сами задаёте сумму. Чем больше кредит относительно оценки компании, тем ниже шанс одобрения и выше ставка.',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: draft,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: trContext(context, 'Сумма кредита'),
                      suffixText: '₽',
                    ),
                    onChanged: (value) => setDialogState(() => draft = value),
                  ),
                  const SizedBox(height: 12),
                  _FinanceStatusRow(
                    label: 'Оценка компании',
                    value: money(state.valuation),
                  ),
                  _FinanceStatusRow(
                    label: 'Доля от оценки',
                    value: '${(ratio * 100).toStringAsFixed(1)}%',
                  ),
                  _FinanceStatusRow(
                    label: 'Шанс одобрения',
                    value: '${(chance * 100).round()}%',
                  ),
                  _FinanceStatusRow(
                    label: 'Ориентировочная ставка',
                    value: '${(interest * 100).toStringAsFixed(1)}%',
                  ),
                  _FinanceStatusRow(
                    label: 'К возврату при одобрении',
                    value: money(amount * (1 + interest)),
                  ),
                  _FinanceStatusRow(
                    label: 'Платёж в неделю',
                    value: money(amount * (1 + interest) / 16),
                  ),
                  if (amount < 50000) ...[
                    const SizedBox(height: 8),
                    const AppText('Введите сумму от 50 000 ₽.'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const AppText('Отмена'),
              ),
              FilledButton(
                onPressed: amount < 50000
                    ? null
                    : () => Navigator.of(dialogContext).pop(amount),
                child: const AppText('Отправить заявку'),
              ),
            ],
          );
        },
      ),
    );
    if (requestedAmount == null || !context.mounted) {
      return;
    }
    _dispatchCreditWithFeedback(
      context,
      RequestBusinessLoan(amount: requestedAmount),
    );
  }

  void _dispatchCreditWithFeedback(BuildContext context, GameAction action) {
    final before = widget.controller.state;
    widget.controller.dispatch(action);
    final after = widget.controller.state;
    final message =
        after.feed.isNotEmpty &&
            (before.feed.isEmpty || after.feed.first != before.feed.first)
        ? after.feed.first
        : after.activeLoan != null && before.activeLoan == null
        ? 'Кредит оформлен, деньги зачислены на баланс.'
        : 'Условия кредита не изменились.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const Key('credit-result-message'),
          content: AppText(message),
        ),
      );
  }
}

class _FinanceStatusRow extends StatelessWidget {
  const _FinanceStatusRow({
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
              Expanded(child: AppText(label)),
              const SizedBox(width: 10),
              Flexible(
                child: AppText(
                  value,
                  textAlign: TextAlign.end,
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
              Expanded(child: AppText(label)),
              AppText(
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
      title: AppText(transaction.description),
      subtitle: AppText(
        'День ${transaction.simulationMinutes ~/ 1440 + 1} • ${transaction.category.name}',
      ),
      trailing: AppText(
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
            const Expanded(child: AppText('Основатель')),
            AppText(
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
