import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/entities/models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';
import '../../../application/localization/app_text.dart';

class MarketCompanyDetailScreen extends StatelessWidget {
  const MarketCompanyDetailScreen({
    required this.controller,
    required this.company,
    super.key,
  });

  final GameController controller;
  final MarketCompany company;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final portfolio = _productsFor(company);
    final soldToCompany = state.news
        .where((item) => item.id.startsWith('product_sale_${company.id}_'))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: AppText(company.companyName, translate: false)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        children: [
          SectionHeader(
            title: company.companyName,
            subtitle: categoryName(company.category),
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                _row('Оценка компании', money(company.valuation)),
                _row('MRR', money(company.monthlyRevenue)),
                _row('Прибыль / мес.', money(company.monthlyProfit)),
                _row('Пользователи', compactNumber(company.users)),
                _row(
                  'Рост',
                  '${(company.growthRate * 100).toStringAsFixed(1)}%',
                ),
                _row('Security', company.securityScore.toStringAsFixed(0)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Продукты компании',
            subtitle: 'Портфель и относительный масштаб продуктов.',
          ),
          const SizedBox(height: 10),
          ...portfolio.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      product.name,
                      translate: false,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    AppText(product.description),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _chip('${compactNumber(product.users)} users'),
                        _chip('MRR ${money(product.mrr)}'),
                        _chip('Rating ${product.rating.toStringAsFixed(1)}'),
                        _chip('Security ${product.security.round()}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (soldToCompany.isNotEmpty) ...[
            const SizedBox(height: 8),
            const SectionHeader(
              title: 'Сделки с вашей компанией',
              subtitle: 'Продукты, которые этот покупатель уже приобрёл.',
            ),
            const SizedBox(height: 10),
            ...soldToCompany.map(
              (news) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.handshake_outlined,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              news.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            AppText(news.body),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static List<_MarketProductView> _productsFor(MarketCompany company) {
    final secondary = switch (company.category) {
      ProductCategory.aiAssistant => const [
        ('Model Studio', 'Инструменты моделей и командной настройки.'),
        ('Knowledge API', 'Корпоративная база знаний и API.'),
      ],
      ProductCategory.cloud => const [
        ('Edge Compute', 'Региональный compute и edge workloads.'),
        ('Managed Data', 'Базы данных, backup и storage.'),
      ],
      ProductCategory.saas => const [
        ('Flow Docs', 'Документы и совместная работа.'),
        ('Flow Automations', 'Автоматизация процессов и интеграции.'),
      ],
      ProductCategory.browser => const [
        ('Private Search', 'Поиск с упором на приватность.'),
        ('Secure Sync', 'Синхронизация профилей и устройств.'),
      ],
      ProductCategory.cryptoWallet => const [
        ('Pay', 'Платежи и merchant-инструменты.'),
        ('Vault', 'Хранение, recovery и security.'),
      ],
      ProductCategory.developerTool => const [
        ('Build Cloud', 'CI jobs, artifacts и release pipelines.'),
        ('Observability', 'Logs, metrics и traces.'),
      ],
    };
    return [
      _MarketProductView(
        name: company.productName,
        description: company.description,
        users: company.users,
        mrr: company.monthlyRevenue,
        rating: (3.9 + company.designScore / 1000).clamp(3.5, 4.9).toDouble(),
        security: company.securityScore,
      ),
      for (var index = 0; index < secondary.length; index += 1)
        _MarketProductView(
          name: '${company.companyName} ${secondary[index].$1}',
          description: secondary[index].$2,
          users: (company.users * (index == 0 ? 0.44 : 0.23)).round(),
          mrr: company.monthlyRevenue * (index == 0 ? 0.31 : 0.17),
          rating: (4.0 + index * 0.18).clamp(1, 5).toDouble(),
          security: (company.securityScore + 2 - index)
              .clamp(1, 100)
              .toDouble(),
        ),
    ];
  }

  static Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: AppText(label)),
        const SizedBox(width: 12),
        AppText(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );

  static Widget _chip(String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: AppText(value),
  );
}

class _MarketProductView {
  const _MarketProductView({
    required this.name,
    required this.description,
    required this.users,
    required this.mrr,
    required this.rating,
    required this.security,
  });

  final String name;
  final String description;
  final int users;
  final double mrr;
  final double rating;
  final double security;
}
