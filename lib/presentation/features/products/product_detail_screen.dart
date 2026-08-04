import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    required this.controller,
    required this.productId,
    super.key,
  });

  final GameController controller;
  final String productId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final product = state.productById(productId);
        if (product == null) {
          return const Scaffold(body: Center(child: Text('Продукт не найден')));
        }
        final competitor = GameCatalog.competitorFor(product.category);
        final framework = GameCatalog.frameworkById(product.frameworkId);
        final load = state.productServerLoad(product);
        final availableFeatures = GameCatalog.features
            .where(
              (feature) =>
                  feature.supportedCategories.contains(product.category) &&
                  !product.featureIds.contains(feature.id),
            )
            .toList(growable: false);

        return Scaffold(
          appBar: AppBar(title: Text(product.name)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              SectionHeader(
                title: product.name,
                subtitle:
                    '${categoryName(product.category)} • ${stageName(product.stage)} • ${framework.name}',
              ),
              const SizedBox(height: 12),
              if (product.stage == ProductStage.development) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Разработка ${(product.developmentProgress * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: product.developmentProgress,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Команда и выбранный стек определяют скорость. После 100% продукт можно выпустить.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key('launch-product'),
                          onPressed:
                              product.developmentProgress >= 1 &&
                                  product.allocatedCapacityPercent > 0
                              ? () => controller.dispatch(
                                  LaunchProduct(product.id),
                                )
                              : null,
                          icon: const Icon(Icons.rocket_launch_outlined),
                          label: const Text('Выпустить продукт'),
                        ),
                      ),
                      if (product.allocatedCapacityPercent <= 0)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Заблокировано: выделите серверную мощность.',
                            style: TextStyle(color: AppColors.red),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: [
                  MetricCard(
                    label: 'Users',
                    value: compactNumber(product.users),
                  ),
                  MetricCard(
                    label: 'DAU / MAU',
                    value:
                        '${compactNumber(product.dau)} / ${compactNumber(product.mau)}',
                  ),
                  MetricCard(
                    label: 'Activation',
                    value: percent(product.activationRate, fractionDigits: 1),
                  ),
                  MetricCard(
                    label: 'Retention 30d',
                    value: percent(product.retention30d, fractionDigits: 1),
                  ),
                  MetricCard(
                    label: 'Churn',
                    value: percent(product.churnRate, fractionDigits: 1),
                    positive: product.churnRate <= 0.08,
                  ),
                  MetricCard(
                    label: 'Rating',
                    value: product.rating.toStringAsFixed(2),
                    positive: product.rating >= 4,
                  ),
                  MetricCard(
                    label: 'MRR',
                    value: money(product.monthlyRevenue),
                  ),
                  MetricCard(
                    label: 'Расходы',
                    value: money(product.monthlyCost),
                    positive: false,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Продукт против лидера рынка',
                subtitle:
                    'Система считает сегменты отдельно: сильное преимущество по одной метрике может переманить часть аудитории.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    _ComparisonHeader(
                      own: product.name,
                      competitor: competitor.productName,
                    ),
                    const Divider(),
                    _ComparisonRow(
                      label: 'Latency',
                      own: '${product.speedMs.round()} ms',
                      competitor: '${competitor.speedMs.round()} ms',
                      ownBetter: product.speedMs < competitor.speedMs,
                    ),
                    _ComparisonRow(
                      label: 'Design',
                      own: '${product.designScore.round()}',
                      competitor: '${competitor.designScore.round()}',
                      ownBetter: product.designScore > competitor.designScore,
                    ),
                    _ComparisonRow(
                      label: 'Security',
                      own: '${product.securityScore.round()}',
                      competitor: '${competitor.securityScore.round()}',
                      ownBetter:
                          product.securityScore > competitor.securityScore,
                    ),
                    _ComparisonRow(
                      label: 'Reliability',
                      own: percent(product.reliability, fractionDigits: 2),
                      competitor: percent(
                        competitor.reliability,
                        fractionDigits: 2,
                      ),
                      ownBetter: product.reliability > competitor.reliability,
                    ),
                    _ComparisonRow(
                      label: 'Функции',
                      own: percent(product.featureCoverage),
                      competitor: '100%',
                      ownBetter: product.featureCoverage >= 1,
                      last: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Стек и функции',
                subtitle: 'Конкретная конфигурация, а не абстрактный уровень.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabelValue('Framework', framework.name),
                    _LabelValue(
                      'Языки',
                      product.languageIds
                          .map((id) => GameCatalog.languageById(id).name)
                          .join(', '),
                    ),
                    _LabelValue(
                      'Технологии',
                      product.technologyIds.isEmpty
                          ? 'Нет'
                          : product.technologyIds
                                .map(
                                  (id) => GameCatalog.technologyById(id).name,
                                )
                                .join(', '),
                    ),
                    _LabelValue(
                      'Функции',
                      product.featureIds
                          .map((id) => GameCatalog.featureById(id).name)
                          .join(', '),
                      last: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SectionHeader(
                title: 'Roadmap продукта',
                subtitle: availableFeatures.isEmpty
                    ? 'Все доступные функции этой категории уже реализованы.'
                    : 'Добавляйте ожидаемые рынком функции. После релиза внедрение стоит на 25% дороже.',
              ),
              const SizedBox(height: 10),
              if (availableFeatures.isEmpty)
                const AppCard(
                  child: Text(
                    'Функциональное покрытие максимально для выбранной категории.',
                  ),
                )
              else
                ...availableFeatures.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FeatureUpgradeCard(
                      feature: feature,
                      liveProduct: product.stage == ProductStage.live,
                      cash: state.cash,
                      onAdd: () => controller.dispatch(
                        AddProductFeature(
                          productId: product.id,
                          featureId: feature.id,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              const SectionHeader(
                title: 'Монетизация и маркетинг',
                subtitle:
                    'Реклама приводит тестовый трафик, но слабое качество ограничивает активацию и retention.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<MonetizationModel>(
                      initialValue: product.monetization,
                      decoration: const InputDecoration(
                        labelText: 'Модель монетизации',
                      ),
                      items: MonetizationModel.values
                          .map(
                            (model) => DropdownMenuItem(
                              value: model,
                              child: Text(monetizationName(model)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (model) {
                        if (model != null) {
                          controller.dispatch(
                            SetProductMonetization(
                              productId: product.id,
                              model: model,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Рекламный бюджет / мес.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <double>[0, 100000, 300000, 800000]
                          .map(
                            (budget) => ChoiceChip(
                              label: Text(money(budget)),
                              selected: product.marketingBudget == budget,
                              onSelected: (_) => controller.dispatch(
                                SetProductMarketingBudget(
                                  productId: product.id,
                                  monthlyBudget: budget,
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Инфраструктура и экосистема',
                subtitle:
                    'Каждый продукт имеет собственную нагрузку и отдельную выручку.',
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    _LabelValue(
                      'Выделено мощности',
                      directPercent(product.allocatedCapacityPercent),
                    ),
                    _LabelValue(
                      'Доступно compute',
                      '${state.allocatedComputeFor(product.id).round()} units',
                    ),
                    _LabelValue(
                      'Требуется compute',
                      '${state.productComputeDemand(product).round()} units',
                    ),
                    _LabelValue(
                      'Загрузка выделения',
                      percent(load, fractionDigits: 1),
                    ),
                    _LabelValue(
                      'Экосистемных связей',
                      '${state.connectedProductIds(product.id).length}',
                    ),
                    _LabelValue(
                      'Экосистемный буст',
                      '+${percent(state.ecosystemBoostFor(product.id), fractionDigits: 1)}',
                      last: true,
                    ),
                  ],
                ),
              ),
              if (product.stage == ProductStage.live) ...[
                const SizedBox(height: 18),
                const SectionHeader(
                  title: 'Безопасность',
                  subtitle:
                      'Security score влияет на вероятность атаки. Для кошелька успешный взлом может уничтожить продукт.',
                ),
                const SizedBox(height: 10),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LabelValue(
                        'Security score',
                        '${product.securityScore.round()} / 100',
                        last: true,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => controller.dispatch(
                            TriggerSecurityIncident(product.id),
                          ),
                          icon: const Icon(Icons.security_outlined),
                          label: const Text('Запустить red-team сценарий'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FeatureUpgradeCard extends StatelessWidget {
  const _FeatureUpgradeCard({
    required this.feature,
    required this.liveProduct,
    required this.cash,
    required this.onAdd,
  });

  final FeatureOption feature;
  final bool liveProduct;
  final double cash;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cost = feature.developmentCost * (liveProduct ? 1.25 : 1.0);
    final canAfford = cash >= cost;
    final effects = <String>[
      if (feature.designDelta != 0) 'Design ${_signed(feature.designDelta)}',
      if (feature.performanceDelta != 0)
        'Speed ${_signed(feature.performanceDelta)}',
      if (feature.securityDelta != 0)
        'Security ${_signed(feature.securityDelta)}',
      if (feature.retentionDelta != 0)
        'Retention ${_signed(feature.retentionDelta * 100)} п.п.',
      'Compute ×${feature.computeMultiplier.toStringAsFixed(2)}',
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(money(cost), style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: effects
                .map(
                  (effect) => Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(effect),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              key: Key('add-feature-${feature.id}'),
              onPressed: canAfford ? onAdd : null,
              icon: const Icon(Icons.add_task_outlined),
              label: Text(
                canAfford ? 'Добавить в продукт' : 'Недостаточно денег',
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _signed(double value) {
    final rounded = value.toStringAsFixed(
      value == value.roundToDouble() ? 0 : 1,
    );
    return value > 0 ? '+$rounded' : rounded;
  }
}

class _ComparisonHeader extends StatelessWidget {
  const _ComparisonHeader({required this.own, required this.competitor});
  final String own;
  final String competitor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Text('Метрика')),
        Expanded(
          child: Text(
            own,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: Text(
            competitor,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.own,
    required this.competitor,
    required this.ownBetter,
    this.last = false,
  });

  final String label;
  final String own;
  final String competitor;
  final bool ownBetter;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              Expanded(
                child: Text(
                  own,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ownBetter ? AppColors.green : AppColors.red,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(child: Text(competitor, textAlign: TextAlign.end)),
            ],
          ),
        ),
        if (!last) const Divider(),
      ],
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue(this.label, this.value, {this.last = false});
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
              Expanded(child: Text(label)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
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
