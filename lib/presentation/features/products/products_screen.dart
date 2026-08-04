import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/entities/models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';
import 'create_product_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  ProductCategory? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final query = _searchController.text.trim().toLowerCase();
    final products = state.products
        .where((product) {
          final matchesQuery =
              query.isEmpty ||
              product.name.toLowerCase().contains(query) ||
              categoryName(product.category).toLowerCase().contains(query);
          final matchesCategory =
              _category == null || product.category == _category;
          return matchesQuery && matchesCategory;
        })
        .toList(growable: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          SectionHeader(
            title: 'Продукты',
            subtitle:
                '${state.products.length} продуктов. Все продуктовые метрики находятся здесь, а не на главном экране.',
            trailing: FilledButton.icon(
              key: const Key('open-product-builder'),
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) =>
                        CreateProductScreen(controller: widget.controller),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Создать'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Поиск по названию или категории',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Все'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                const SizedBox(width: 7),
                ...ProductCategory.values.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(categoryName(category)),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (products.isEmpty)
            AppCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.apps_outlined,
                    size: 38,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.products.isEmpty
                        ? 'Продуктов пока нет. Соберите первый стек и набор функций.'
                        : 'По фильтрам ничего не найдено.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...products.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ProductCard(
                  controller: widget.controller,
                  product: product,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.controller, required this.product});

  final GameController controller;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final load = state.productServerLoad(product);
    return AppCard(
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              controller: controller,
              productId: product.id,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _categoryColor(product.category).withAlpha(24),
                foregroundColor: _categoryColor(product.category),
                child: Icon(_categoryIcon(product.category)),
              ),
              const SizedBox(width: 11),
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
          if (product.stage == ProductStage.development) ...[
            const SizedBox(height: 13),
            LinearProgressIndicator(value: product.developmentProgress),
            const SizedBox(height: 6),
            Text(
              'Готовность ${(product.developmentProgress * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ] else ...[
            const SizedBox(height: 13),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricPill('Users', compactNumber(product.users)),
                _MetricPill('MRR', money(product.monthlyRevenue)),
                _MetricPill('Rating', product.rating.toStringAsFixed(1)),
                _MetricPill('Load', percent(load, fractionDigits: 0)),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '${GameCatalog.frameworkById(product.frameworkId).name} • ${product.featureIds.length} функций • ${directPercent(product.allocatedCapacityPercent)} мощности',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

IconData _categoryIcon(ProductCategory category) => switch (category) {
  ProductCategory.aiAssistant => Icons.auto_awesome_outlined,
  ProductCategory.cloud => Icons.cloud_outlined,
  ProductCategory.saas => Icons.dashboard_customize_outlined,
  ProductCategory.browser => Icons.public,
  ProductCategory.cryptoWallet => Icons.account_balance_wallet_outlined,
  ProductCategory.developerTool => Icons.code,
};

Color _categoryColor(ProductCategory category) => switch (category) {
  ProductCategory.aiAssistant => AppColors.violet,
  ProductCategory.cloud => AppColors.cyan,
  ProductCategory.saas => AppColors.primary,
  ProductCategory.browser => AppColors.green,
  ProductCategory.cryptoWallet => AppColors.yellow,
  ProductCategory.developerTool => AppColors.textMuted,
};
