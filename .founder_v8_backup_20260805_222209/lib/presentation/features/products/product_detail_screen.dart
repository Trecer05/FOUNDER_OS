import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/catalog/product_evolution_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/product_evolution_models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';
import '../security/security_center_screen.dart';
import '../operations/operations_screen.dart';

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
        final monetizationCooldownDays = state
            .monetizationCooldownRemainingDays(product.id);
        final revenueForecast = state.revenueForecastFor(product);
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
                  hintTitle: 'Разработка продукта',
                  hintBody:
                      'Новый продукт начинается с 0%. Прогресс растёт только вместе с игровым временем и зависит от назначенной команды, покрытия ролей, выбранного стека и корпоративной AI.',
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
                        'Назначенная проектная команда и выбранный стек определяют скорость. Сотрудники в резерве не дают скрытый бонус.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      _LabelValue(
                        'Назначено сотрудников',
                        '${state.employeesForProduct(product.id).length}',
                      ),
                      _LabelValue(
                        'Development capacity',
                        state
                            .productDevelopmentCapacity(product.id)
                            .toStringAsFixed(0),
                        last: true,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (_) =>
                                  OperationsScreen(controller: controller),
                            ),
                          ),
                          icon: const Icon(Icons.account_tree_outlined),
                          label: const Text('Управлять проектной командой'),
                        ),
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
              SectionHeader(
                title: 'Специалисты для разработки',
                subtitle:
                    'Для каждого типа продукта нужны конкретные роли. Нехватка специальностей замедляет разработку и снижает качество исполнения.',
                hintTitle: 'Почему важны специальности',
                hintBody:
                    'Development capacity учитывает не только средние навыки, но и покрытие обязательных ролей. Один сильный backend-разработчик не заменяет security, design или QA.',
              ),
              const SizedBox(height: 10),
              _ProductTeamRequirementsCard(state: state, product: product),
              const SizedBox(height: 18),
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
              SectionHeader(
                title: 'Свежесть продукта',
                subtitle:
                    'Без обновлений органический рост, retention и рейтинг постепенно снижаются.',
                hintTitle: 'Как работает устаревание',
                hintBody:
                    'Первые 21 игровой день после обновления продукт считается свежим. Затем штраф растёт постепенно. Любая крупная функция или техническое улучшение обновляет дату свежести.',
              ),
              const SizedBox(height: 10),
              _FreshnessCard(state: state, product: product),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Продукт против лидера рынка',
                subtitle:
                    'Система считает сегменты отдельно: сильное преимущество по одной метрике может переманить часть аудитории.',
              ),
              const SizedBox(height: 10),
              AppCard(
                hintTitle: 'Сравнение с лидером',
                hintBody:
                    'Рынок сравнивает скорость, дизайн, безопасность, надёжность, функции и цену. Зелёная строка означает преимущество вашего продукта.',
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
                hintTitle: 'Технологический стек',
                hintBody:
                    'Framework, языки, технологии и функции задают стоимость разработки, скорость, качество, надёжность и серверную нагрузку.',
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
                title: 'Собственная AI',
                subtitle: product.category == ProductCategory.aiAssistant
                    ? 'Выберите: публичный рынок или внутренняя корпоративная AI.'
                    : 'Корпоративная AI ускоряет разработку и немного повышает качество, но требует compute и OPEX.',
                hintTitle: 'Публичная и корпоративная AI',
                hintBody:
                    'Публичная AI конкурирует за пользователей и приносит выручку. Корпоративная AI не продаётся на рынке: её можно подключать к другим продуктам для +18% development capacity и +4 quality.',
                hintBullets: const [
                  'Одна корпоративная AI может обслуживать несколько продуктов.',
                  'Каждое подключение стоит 45 000 ₽ в месяц.',
                  'Нагрузка растёт на AI-продукте и зависит от масштаба подключённых продуктов.',
                ],
              ),
              const SizedBox(height: 10),
              _AiUsageCard(
                state: state,
                product: product,
                controller: controller,
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Постоянные технические улучшения',
                subtitle:
                    'После релиза доступны всегда, даже когда все крупные функции roadmap уже реализованы.',
                hintTitle: 'Бесконечное развитие продукта',
                hintBody:
                    'Улучшения можно повторять. Каждый следующий уровень дороже, но снова делает продукт свежим и даёт конкретный технический эффект.',
              ),
              const SizedBox(height: 10),
              ...ProductEvolutionCatalog.improvements.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ContinuousImprovementCard(
                    state: state,
                    product: product,
                    option: option,
                    onApply: () => controller.dispatch(
                      ApplyProductImprovement(
                        productId: product.id,
                        type: option.type,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SectionHeader(
                title: 'Roadmap продукта',
                subtitle: availableFeatures.isEmpty
                    ? 'Все крупные функции реализованы. Продукт продолжает развиваться через постоянные технические улучшения выше.'
                    : 'Добавляйте ожидаемые рынком функции. После релиза внедрение стоит на 25% дороже.',
              ),
              const SizedBox(height: 10),
              if (availableFeatures.isEmpty)
                const AppCard(
                  child: Text(
                    'Крупные функции завершены. Следите за свежестью и продолжайте улучшать скорость, алгоритмы, дизайн, security и reliability.',
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
                hintTitle: 'Цена, модель и реклама',
                hintBody:
                    'Цена влияет одновременно на выручку и привлекательность продукта для чувствительных к стоимости сегментов. Реклама увеличивает тестовый трафик, но не исправляет слабые retention и quality.',
                subtitle:
                    'Реклама приводит тестовый трафик, но слабое качество ограничивает активацию и retention.',
              ),
              const SizedBox(height: 10),
              AppCard(
                hintTitle: 'Настройки монетизации',
                hintBody:
                    'Модель определяет формулу выручки. Подписка использует регулируемую цену; реклама зависит от MAU; usage-based и transaction fee зависят от цены и активности. Маркетинговый бюджет списывается каждый месяц.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<MonetizationModel>(
                      key: ValueKey(product.monetization),
                      initialValue: product.monetization,
                      decoration: InputDecoration(
                        labelText: 'Модель монетизации',
                        helperText:
                            product.stage == ProductStage.live &&
                                monetizationCooldownDays > 0
                            ? 'Следующая смена через $monetizationCooldownDays дн.'
                            : 'После релиза модель можно менять раз в 30 игровых дней.',
                      ),
                      items: MonetizationModel.values
                          .map(
                            (model) => DropdownMenuItem(
                              value: model,
                              child: Text(monetizationName(model)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged:
                          product.stage == ProductStage.live &&
                              monetizationCooldownDays > 0
                          ? null
                          : (model) {
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Прогноз дохода / мес.',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                label: Text(
                                  'Low ${money(revenueForecast.low)}',
                                ),
                              ),
                              Chip(
                                label: Text(
                                  'Base ${money(revenueForecast.expected)}',
                                ),
                              ),
                              Chip(
                                label: Text(
                                  'High ${money(revenueForecast.high)}',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${revenueForecast.note} Фактический MRR сейчас: ${money(product.monthlyRevenue)}.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (product.stage == ProductStage.live &&
                        product.monetization ==
                            MonetizationModel.subscription) ...[
                      const SizedBox(height: 14),
                      _SubscriptionPriceControl(
                        product: product,
                        onChanged: (price) => controller.dispatch(
                          SetProductPrice(productId: product.id, price: price),
                        ),
                      ),
                    ],
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
                hintTitle: 'Нагрузка продукта',
                hintBody:
                    'Выделение — доля общей серверной мощности. Загрузка выше 100% означает дефицит; длительная перегрузка ухудшает скорость, uptime и удержание пользователей.',
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
                  hintTitle: 'Риск безопасности',
                  hintBody:
                      'Расчётный риск учитывает security score, масштаб, загрузку серверов, физическую защиту и установленные security controls. Красный team-сценарий запускает тестовый инцидент.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LabelValue(
                        'Security score',
                        '${product.securityScore.round()} / 100',
                      ),
                      _LabelValue(
                        'Расчётный риск',
                        percent(
                          state.productSecurityRisk(product),
                          fractionDigits: 1,
                        ),
                      ),
                      _LabelValue(
                        'Контролей внедрено',
                        '${state.securityControlIdsFor(product.id).length}',
                      ),
                      _LabelValue(
                        'Security OPEX',
                        '${money(state.productSecurityMonthlyCost(product.id))}/мес.',
                        last: true,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: () => Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => SecurityCenterScreen(
                                    controller: controller,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.shield_outlined),
                              label: const Text('Центр безопасности'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.outlined(
                            tooltip: 'Red-team сценарий',
                            onPressed: () => controller.dispatch(
                              TriggerSecurityIncident(product.id),
                            ),
                            icon: const Icon(Icons.bug_report_outlined),
                          ),
                        ],
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

class _ProductTeamRequirementsCard extends StatelessWidget {
  const _ProductTeamRequirementsCard({
    required this.state,
    required this.product,
  });

  final GameState state;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final requirements = state.roleRequirementsFor(product);
    final coverage = state.productRoleCoverage(product.id);
    return AppCard(
      hintTitle: 'Покрытие ролей',
      hintBody:
          'Зелёная строка означает, что минимум по роли выполнен. Красная — роли не хватает. Покрытие напрямую входит в расчёт development capacity.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Покрытие ${(coverage * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${state.employeesForProduct(product.id).length} в проекте',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: coverage),
          const SizedBox(height: 12),
          ...requirements.map((requirement) {
            final actual = state.assignedRoleCount(
              product.id,
              requirement.role,
            );
            final ready = actual >= requirement.minimumCount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    ready ? Icons.check_circle_outline : Icons.error_outline,
                    color: ready ? AppColors.green : AppColors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${roleName(requirement.role)}: $actual/${requirement.minimumCount}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          requirement.reason,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FreshnessCard extends StatelessWidget {
  const _FreshnessCard({required this.state, required this.product});

  final GameState state;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final score = state.productFreshnessScore(product);
    final days = state.productAgeSinceUpdateDays(product);
    final latest = state.latestProductUpdate(product);
    final danger = score < 65;
    return AppCard(
      hintTitle: 'Свежесть',
      hintBody:
          'Устаревание не убивает продукт мгновенно. Оно уменьшает органический приток, activation, retention и quality, а churn растёт.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${score.toStringAsFixed(0)} / 100',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: danger ? AppColors.red : AppColors.green,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text('${days.toStringAsFixed(1)} дн. без обновления'),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: score / 100),
          const SizedBox(height: 10),
          Text(
            'Последнее обновление: ${latest?.reason ?? 'создание продукта'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AiUsageCard extends StatelessWidget {
  const _AiUsageCard({
    required this.state,
    required this.product,
    required this.controller,
  });

  final GameState state;
  final Product product;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    if (product.category == ProductCategory.aiAssistant) {
      final mode = state.aiDeploymentModeFor(product.id);
      final targets = state.productAiIntegrations
          .where((item) => item.aiProductId == product.id)
          .map((item) => state.productById(item.targetProductId)?.name)
          .whereType<String>()
          .toList(growable: false);
      return AppCard(
        hintTitle: 'Режим AI-продукта',
        hintBody:
            'Режим можно менять. При возврате на публичный рынок внутренние подключения этой AI отключаются.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<AiDeploymentMode>(
              segments: const [
                ButtonSegment(
                  value: AiDeploymentMode.publicMarket,
                  label: Text('Рынок'),
                  icon: Icon(Icons.public_outlined),
                ),
                ButtonSegment(
                  value: AiDeploymentMode.corporate,
                  label: Text('Корпоративная'),
                  icon: Icon(Icons.business_outlined),
                ),
              ],
              selected: <AiDeploymentMode>{mode},
              onSelectionChanged: (selection) => controller.dispatch(
                SetAiDeploymentMode(
                  productId: product.id,
                  mode: selection.first,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _LabelValue('Внутренних подключений', '${targets.length}'),
            _LabelValue(
              'Дополнительный compute',
              state.corporateAiComputeDemandFor(product.id).toStringAsFixed(1),
              last: true,
            ),
            if (targets.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Используют: ${targets.join(', ')}'),
            ],
          ],
        ),
      );
    }

    final current = state.corporateAiForTarget(product.id);
    final available = state.corporateAiProducts;
    return AppCard(
      hintTitle: 'AI в продукте',
      hintBody:
          'К продукту можно подключить одну корпоративную AI. Она ускоряет разработку, повышает quality и добавляет постоянную нагрузку на серверы.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: current?.id ?? '__none__',
            decoration: const InputDecoration(labelText: 'Корпоративная AI'),
            items: [
              const DropdownMenuItem(
                value: '__none__',
                child: Text('Не использовать'),
              ),
              ...available.map(
                (ai) => DropdownMenuItem(value: ai.id, child: Text(ai.name)),
              ),
            ],
            onChanged: (value) {
              if (value == null || value == '__none__') {
                controller.dispatch(DisconnectCorporateAi(product.id));
              } else {
                controller.dispatch(
                  ConnectCorporateAi(
                    aiProductId: value,
                    targetProductId: product.id,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 10),
          if (available.isEmpty)
            Text(
              'Сначала выпустите AI-продукт и переведите его в корпоративный режим.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            const Text(
              '+18% development capacity • +4 quality • 45 000 ₽/мес.',
            ),
        ],
      ),
    );
  }
}

class _SubscriptionPriceControl extends StatefulWidget {
  const _SubscriptionPriceControl({
    required this.product,
    required this.onChanged,
  });

  final Product product;
  final ValueChanged<double> onChanged;

  @override
  State<_SubscriptionPriceControl> createState() =>
      _SubscriptionPriceControlState();
}

class _SubscriptionPriceControlState extends State<_SubscriptionPriceControl> {
  double? _draftPrice;

  @override
  void didUpdateWidget(covariant _SubscriptionPriceControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.price != widget.product.price) {
      _draftPrice = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueprint = GameCatalog.blueprintById(widget.product.blueprintId);
    final minimum = math.max(49, blueprint.basePrice * 0.25).toDouble();
    final maximum = math.max(minimum, blueprint.basePrice * 4).toDouble();
    final value = (_draftPrice ?? widget.product.price)
        .clamp(minimum, maximum)
        .toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Цена подписки',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '${value.round()} ₽/мес.',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        Slider(
          key: const Key('subscription-price-slider'),
          value: value,
          min: minimum,
          max: maximum,
          divisions: 15,
          label: '${value.round()} ₽',
          onChanged: (next) => setState(() => _draftPrice = next),
          onChangeEnd: (next) {
            widget.onChanged(next);
            setState(() => _draftPrice = null);
          },
        ),
        Text(
          'Базовая цена категории: ${blueprint.basePrice.round()} ₽. Более высокая цена увеличивает доход с платящего пользователя, но ухудшает ценовую конкурентоспособность.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ContinuousImprovementCard extends StatelessWidget {
  const _ContinuousImprovementCard({
    required this.state,
    required this.product,
    required this.option,
    required this.onApply,
  });

  final GameState state;
  final Product product;
  final ProductImprovementOption option;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final level = state.improvementLevel(product.id, option.type);
    final cost = state.improvementCost(product.id, option.type);
    final released = product.stage == ProductStage.live;
    final canAfford = released && state.cash >= cost;
    return AppCard(
      hintTitle: option.name,
      hintBody: option.description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  option.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text('L$level → L${level + 1}'),
            ],
          ),
          const SizedBox(height: 5),
          Text(option.description),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              Chip(label: Text(money(cost))),
              Chip(label: Text('+${money(option.monthlyCostDelta)}/мес.')),
              if (option.speedMultiplier != 1)
                Chip(
                  label: Text(
                    'Speed ×${option.speedMultiplier.toStringAsFixed(3)}',
                  ),
                ),
              if (option.designDelta != 0)
                Chip(label: Text('Design +${option.designDelta}')),
              if (option.securityDelta != 0)
                Chip(label: Text('Security +${option.securityDelta}')),
              if (option.qualityDelta != 0)
                Chip(label: Text('Quality +${option.qualityDelta}')),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: canAfford ? onApply : null,
              icon: const Icon(Icons.upgrade_outlined),
              label: Text(
                !released
                    ? 'Доступно после релиза'
                    : canAfford
                    ? 'Выпустить улучшение'
                    : 'Недостаточно денег',
              ),
            ),
          ),
        ],
      ),
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
