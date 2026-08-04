import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final productTech = state.products.fold<double>(
          0,
          (sum, item) => sum + item.monthlyCost,
        );
        final continuousImprovementOpex = state.products.fold<double>(
          0,
          (sum, item) => sum + state.productImprovementMonthlyCost(item.id),
        );
        final revenueShare = state.investorPayouts;
        final infra =
            state.office.monthlyRent +
            state.serverRoom.monthlyRent +
            state.monthlyHardwareCost;
        return Scaffold(
          appBar: AppBar(title: const Text('Финансы компании')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const SectionHeader(
                title: 'P&L и контроль капитала',
                subtitle:
                    'Все строки рассчитаны из текущих зарплат, аренды, железа, продуктов, AI, security-контролей и инвесторских соглашений.',
                hintTitle: 'Как читать P&L',
                hintBody:
                    'P&L показывает месячную экономику. Cash — запас денег, profit — текущий поток, runway — сколько компания проживёт при убытке.',
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
                  MetricCard(
                    label: 'Выручка / мес.',
                    value: money(
                      state.monthlyProductRevenue + state.portfolioIncome,
                    ),
                  ),
                  MetricCard(
                    label: 'Расходы / мес.',
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
                title: 'Структура расходов',
                subtitle: 'Текущий месячный run rate без абстрактных уровней.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    _PnlRow('Payroll', state.monthlyPayroll),
                    _PnlRow('Офис + серверная + железо', infra),
                    _PnlRow('Продукты и маркетинг', productTech),
                    _PnlRow('Постоянные улучшения', continuousImprovementOpex),
                    _PnlRow('Корпоративная AI', state.monthlyCorporateAiCost),
                    _PnlRow('Security operations', state.monthlySecurityCost),
                    _PnlRow('Revenue share инвесторам', revenueShare),
                    const Divider(),
                    _PnlRow('Итого расходов', state.monthlyCosts, strong: true),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SectionHeader(
                title: 'Cap table',
                subtitle:
                    'Доля основателя ${directPercent(state.founderOwnershipPercent, fractionDigits: 1)}. Ниже 50% управление компанией теряется.',
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
                        final product = state.productById(agreement.productId);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(investor.name),
                          subtitle: Text(
                            '${product?.name ?? 'Продукт'} • revenue share ${directPercent(agreement.revenueSharePercent, fractionDigits: 1)}',
                          ),
                          trailing: Text(
                            directPercent(
                              agreement.equityPercent,
                              fractionDigits: 1,
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Внешний портфель',
                subtitle:
                    'Доли в других компаниях дают отдельный денежный поток и не смешиваются с продуктовой выручкой.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: state.portfolioHoldings.isEmpty
                    ? const Text('Внешних долей пока нет.')
                    : Column(
                        children: state.portfolioHoldings
                            .map((holding) {
                              final company = GameCatalog.marketCompanyById(
                                holding.companyId,
                              );
                              final income =
                                  company.monthlyProfit *
                                  holding.ownershipPercent /
                                  100;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(company.companyName),
                                subtitle: Text(
                                  '${directPercent(holding.ownershipPercent, fractionDigits: 1)} • вложено ${money(holding.amountPaid)}',
                                ),
                                trailing: Text(
                                  '+${money(income)}/мес.',
                                  style: const TextStyle(
                                    color: AppColors.green,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PnlRow extends StatelessWidget {
  const _PnlRow(this.label, this.value, {this.strong = false});

  final String label;
  final double value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: strong
                  ? const TextStyle(fontWeight: FontWeight.w900)
                  : null,
            ),
          ),
          Text(
            money(value),
            style: TextStyle(
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            minHeight: 12,
            value: founderPercent / 100,
            backgroundColor: AppColors.red.withAlpha(28),
          ),
        ),
      ],
    );
  }
}
