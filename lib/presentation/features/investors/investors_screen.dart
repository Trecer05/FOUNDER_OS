import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';
import '../../../application/localization/app_text.dart';
import '../../shared/widgets/scoped_listenable_builder.dart';
import '../../../application/localization/app_localizer.dart';

class InvestorsScreen extends StatelessWidget {
  const InvestorsScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ScopedListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        return Scaffold(
          appBar: AppBar(title: const AppText('Инвесторы и доли')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const SectionHeader(
                title: 'Cap table',
                subtitle:
                    'Доля ниже 50% означает потерю контроля. Выкуп долей возвращает контроль и убирает revenue share.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    _InfoRow(
                      'Доля основателя',
                      directPercent(
                        state.founderOwnershipPercent,
                        fractionDigits: 1,
                      ),
                      danger: state.founderOwnershipPercent < 60,
                    ),
                    _InfoRow(
                      'Стоимость доли основателя',
                      money(state.founderPortfolioValue),
                    ),
                    _InfoRow(
                      'Инвесторов',
                      '${state.investorAgreements.length}',
                    ),
                    _InfoRow(
                      'Выплаты инвесторам / мес.',
                      money(state.investorPayouts),
                      last: true,
                    ),
                  ],
                ),
              ),
              if (state.founderOwnershipPercent < 60) ...[
                const SizedBox(height: 10),
                const AppCard(
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: AppText(
                          'Опасная зона: ещё одна крупная сделка может опустить долю ниже 50%.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Предложения',
                subtitle:
                    'После запроса начинается переговорный процесс. Явный ответ приходит за 1–14 игровых дней.',
              ),
              const SizedBox(height: 10),
              if (state.investorOffers.isEmpty)
                const AppCard(child: AppText('Активных предложений нет.'))
              else
                ...state.investorOffers.map(
                  (offer) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OfferCard(controller: controller, offer: offer),
                  ),
                ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Действующие инвесторы',
                subtitle:
                    'После запуска профинансированного продукта инвестор получает долю выручки.',
              ),
              const SizedBox(height: 10),
              if (state.investorAgreements.isEmpty)
                const AppCard(child: AppText('Инвесторов в капитале пока нет.'))
              else
                ...state.investorAgreements.map(
                  (agreement) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AgreementCard(
                      controller: controller,
                      agreement: agreement,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Рынок инвесторов',
                subtitle:
                    'Каждый инвестор имеет свой фокус, лимит и готовность к риску.',
              ),
              const SizedBox(height: 10),
              ...GameCatalog.investors.map(
                (investor) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFECE8FF),
                              foregroundColor: AppColors.violet,
                              child: Icon(Icons.account_balance_outlined),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    investor.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  AppText(
                                    'Доступно до ${money(investor.availableCapital)}',
                                  ),
                                ],
                              ),
                            ),
                            FilledButton(
                              onPressed: state.products.isNotEmpty
                                  ? () => _showFundingRequest(
                                      context,
                                      controller,
                                      investor,
                                    )
                                  : null,
                              child: const AppText('Запросить'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AppText(investor.thesis),
                        const SizedBox(height: 9),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            ...investor.preferredCategories.map(
                              (category) => _Chip(categoryName(category)),
                            ),
                            _Chip(
                              'Готовность ≥ ${(investor.minimumReadiness * 100).round()}%',
                            ),
                            _Chip(
                              'Макс. доля ${investor.maximumEquityPercent.round()}%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showFundingRequest(
    BuildContext context,
    GameController controller,
    InvestorProfile investor,
  ) async {
    var selectedProductId = controller.state.products.first.id;
    var amount = 500000.0;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              18,
              16,
              18 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Запрос в ${investor.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                AppText(
                  'Если сумма выше лимита, инвестор предложит доступный максимум. При несоответствии фокусу или готовности он откажет.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedProductId,
                  decoration: InputDecoration(
                    labelText: trContext(context, 'Продукт'),
                  ),
                  items: controller.state.products
                      .map(
                        (product) => DropdownMenuItem(
                          value: product.id,
                          child: AppText(product.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() => selectedProductId = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                AppText(
                  'Запрашиваемая сумма',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <double>[250000, 500000, 1000000, 2000000, 5000000]
                      .map(
                        (value) => ChoiceChip(
                          label: AppText(money(value)),
                          selected: amount == value,
                          onSelected: (_) =>
                              setModalState(() => amount = value),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      controller.dispatch(
                        RequestInvestorFunding(
                          investorId: investor.id,
                          productId: selectedProductId,
                          requestedAmount: amount,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    child: const AppText('Отправить запрос'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.controller, required this.offer});
  final GameController controller;
  final InvestorOffer offer;

  @override
  Widget build(BuildContext context) {
    final investor = GameCatalog.investorById(offer.investorId);
    final product = controller.state.productById(offer.productId);
    final pending = offer.offeredAmount < 0;
    final decisionDays = int.tryParse(offer.id.split('_').last) ?? 7;
    final decisionAt = offer.createdAtMinutes + decisionDays * 1440;
    final progress =
        ((controller.state.simulationMinutes - offer.createdAtMinutes) /
                math.max(1, decisionAt - offer.createdAtMinutes))
            .clamp(0, 1)
            .toDouble();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            investor.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          AppText('На продукт ${product?.name ?? 'закрытый продукт'}'),
          const SizedBox(height: 10),
          _InfoRow('Запрошено', money(offer.requestedAmount)),
          if (pending) ...[
            _InfoRow(
              'Статус',
              'Переговоры • ответ до Д${decisionAt ~/ 1440 + 1}',
              last: true,
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 6),
            AppText(
              'Инвестор проверяет команду, готовность, риск и рынок. Максимальный срок — 14 дней.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ] else ...[
            _InfoRow('Предложено', money(offer.offeredAmount)),
            _InfoRow(
              'Доля компании',
              directPercent(offer.equityPercent, fractionDigits: 1),
            ),
            _InfoRow(
              'Revenue share продукта',
              directPercent(offer.revenueSharePercent, fractionDigits: 1),
              last: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        controller.dispatch(RejectInvestorOffer(offer.id)),
                    child: const AppText('Отказать'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        controller.dispatch(AcceptInvestorOffer(offer.id)),
                    child: const AppText('Принять'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AgreementCard extends StatelessWidget {
  const _AgreementCard({required this.controller, required this.agreement});
  final GameController controller;
  final InvestorAgreement agreement;

  @override
  Widget build(BuildContext context) {
    final investor = GameCatalog.investorById(agreement.investorId);
    final product = controller.state.productById(agreement.productId);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            investor.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          AppText(product?.name ?? 'Продукт продан/закрыт'),
          const SizedBox(height: 10),
          _InfoRow('Инвестировано', money(agreement.investedAmount)),
          _InfoRow(
            'Доля',
            directPercent(agreement.equityPercent, fractionDigits: 1),
          ),
          _InfoRow(
            'Revenue share',
            directPercent(agreement.revenueSharePercent, fractionDigits: 1),
          ),
          _InfoRow('Выкуп', money(agreement.buybackPrice), last: true),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: controller.state.cash >= agreement.buybackPrice
                  ? () => controller.dispatch(BuyBackInvestor(agreement.id))
                  : null,
              child: const AppText('Выкупить долю обратно'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
    this.label,
    this.value, {
    this.last = false,
    this.danger = false,
  });
  final String label;
  final String value;
  final bool last;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: AppText(label)),
              AppText(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: danger ? AppColors.red : null,
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

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: AppText(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
