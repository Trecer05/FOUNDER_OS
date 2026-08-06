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

class MarketScreen extends StatelessWidget {
  const MarketScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ScopedListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final spareCompute =
            (state.totalComputeUnits - state.totalComputeDemand).clamp(
              0,
              double.infinity,
            );
        return Scaffold(
          appBar: AppBar(title: const AppText('Рынок и M&A')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const SectionHeader(
                title: 'Внешний портфель',
                subtitle:
                    'Можно покупать доли, отдельные продукты или компании целиком.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    _InfoRow(
                      'Долей в портфеле',
                      '${state.portfolioHoldings.length}',
                    ),
                    _InfoRow('Дивиденды / мес.', money(state.portfolioIncome)),
                    _InfoRow(
                      'Свободный compute',
                      '${spareCompute.round()} units',
                      last: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Компании на рынке',
                subtitle:
                    'Миграция пользователей требует запаса инфраструктуры. Поддержка отдельного продукта требует собственного allocation.',
              ),
              const SizedBox(height: 10),
              ...GameCatalog.marketCompanies.map(
                (company) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CompanyCard(controller: controller, company: company),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.controller, required this.company});

  final GameController controller;
  final MarketCompany company;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final holding = state.holdingByCompanyId(company.id);
    final acquired = state.acquiredCompanyIds.contains(company.id);
    final sameCategoryProducts = state.products
        .where(
          (product) =>
              product.category == company.category &&
              product.stage == ProductStage.live,
        )
        .toList(growable: false);
    final spareCompute = (state.totalComputeUnits - state.totalComputeDemand)
        .clamp(0, double.infinity);
    final migrationReady =
        sameCategoryProducts.isNotEmpty &&
        spareCompute >= company.computeDemand * 1.2;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withAlpha(22),
                foregroundColor: AppColors.primary,
                child: const Icon(Icons.corporate_fare_outlined),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      company.companyName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppText(
                      '${company.productName} • ${categoryName(company.category)}',
                    ),
                  ],
                ),
              ),
              if (acquired) const _StatusChip(label: 'Куплено', positive: true),
            ],
          ),
          const SizedBox(height: 10),
          AppText(company.description),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _ValueChip('Valuation ${money(company.valuation)}'),
              _ValueChip('Продукт ${money(company.productPrice)}'),
              _ValueChip('${compactNumber(company.users)} users'),
              _ValueChip('MRR ${money(company.monthlyRevenue)}'),
              _ValueChip('Profit ${money(company.monthlyProfit)}'),
              _ValueChip(
                'Growth ${(company.growthRate * 100).toStringAsFixed(1)}%',
              ),
              _ValueChip('Security ${company.securityScore.round()}'),
              _ValueChip('${company.computeDemand.round()} compute'),
            ],
          ),
          const SizedBox(height: 12),
          if (holding != null)
            AppText(
              'В портфеле: ${holding.ownershipPercent.toStringAsFixed(1)}%, вложено ${money(holding.amountPaid)}',
              style: const TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      !acquired &&
                          state.cash >= company.valuation * 0.05 &&
                          (holding?.ownershipPercent ?? 0) + 5 <=
                              company.availableStakePercent
                      ? () => controller.dispatch(
                          InvestInMarketCompany(
                            companyId: company.id,
                            ownershipPercent: 5,
                          ),
                        )
                      : null,
                  child: const AppText('Купить 5%'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: !acquired && state.cash >= company.productPrice
                      ? () => _showProductAcquisition(
                          context,
                          controller,
                          company,
                          migrationReady,
                          sameCategoryProducts,
                        )
                      : null,
                  child: const AppText('Купить продукт'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: !acquired && state.cash >= company.valuation
                  ? () => controller.dispatch(AcquireMarketCompany(company.id))
                  : null,
              child: AppText('Купить компанию • ${money(company.valuation)}'),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Icon(
                migrationReady
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                size: 18,
                color: migrationReady ? AppColors.green : AppColors.red,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: AppText(
                  migrationReady
                      ? 'Миграция готова: есть аналог и ${(company.computeDemand * 1.2).round()}+ свободных compute units.'
                      : 'Миграция не готова: нужен свой аналог и ${(company.computeDemand * 1.2).round()} свободных compute units.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showProductAcquisition(
    BuildContext context,
    GameController controller,
    MarketCompany company,
    bool migrationReady,
    List<Product> sameCategoryProducts,
  ) async {
    var mode = AcquisitionMode.maintainSeparate;
    String? targetId = sameCategoryProducts.isEmpty
        ? null
        : sameCategoryProducts.first.id;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Купить ${company.productName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                AppCard(
                  onTap: () => setModalState(
                    () => mode = AcquisitionMode.maintainSeparate,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        mode == AcquisitionMode.maintainSeparate
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Поддерживать отдельно',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            AppText(
                              'Продукт, пользователи и выручка сохраняются. Нужно выделить ему compute.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                AppCard(
                  onTap: migrationReady
                      ? () => setModalState(
                          () => mode = AcquisitionMode.migrateUsers,
                        )
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        mode == AcquisitionMode.migrateUsers
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: migrationReady
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'Перевести пользователей',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            AppText(
                              migrationReady
                                  ? '82% пользователей перейдут в выбранный аналог без критической просадки.'
                                  : 'Заблокировано: недостаточно инфраструктуры или нет аналога.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (mode == AcquisitionMode.migrateUsers &&
                    sameCategoryProducts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: targetId,
                    decoration: InputDecoration(
                      labelText: trContext(context, 'Целевой продукт'),
                    ),
                    items: sameCategoryProducts
                        .map(
                          (product) => DropdownMenuItem(
                            value: product.id,
                            child: AppText(product.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) => setModalState(() => targetId = value),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        mode == AcquisitionMode.maintainSeparate ||
                            migrationReady
                        ? () {
                            controller.dispatch(
                              AcquireMarketProduct(
                                companyId: company.id,
                                mode: mode,
                                targetProductId: targetId,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: AppText(
                      'Подтвердить • ${money(company.productPrice)}',
                    ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.last = false});
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
              AppText(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        if (!last) const Divider(),
      ],
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip(this.label);
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.positive});
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: (positive ? AppColors.green : AppColors.red).withAlpha(20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppText(
        label,
        style: TextStyle(
          color: positive ? AppColors.green : AppColors.red,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
