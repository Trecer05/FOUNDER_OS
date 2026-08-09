import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/catalog/product_evolution_catalog.dart';
import '../../../domain/catalog/product_strategy_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/product_evolution_models.dart';
import '../../../domain/entities/v12_game_state_extensions.dart';
import '../../../domain/explainability/staffing_deficit_resolver.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/development_stage_progress_rail.dart';
import '../../shared/widgets/specialist_deficit_card.dart';
import '../security/security_center_screen.dart';
import '../contracts/contracts_screen.dart';
import 'product_development_experience.dart';
import '../../../domain/simulation/product_projection_cache.dart';
import '../../../application/localization/app_text.dart';
import '../../shared/widgets/scoped_listenable_builder.dart';
import '../../../application/localization/app_localizer.dart';

String _safeActiveWorkTitle(String featureId) {
  if (featureId.startsWith('__improvement_')) {
    final payload = featureId.substring('__improvement_'.length);
    final separator = payload.lastIndexOf('_');
    if (separator > 0) {
      final typeName = payload.substring(0, separator);
      final level = int.tryParse(payload.substring(separator + 1));
      for (final option in ProductEvolutionCatalog.improvements) {
        if (option.type.name == typeName) {
          return level == null ? option.name : '${option.name} · L$level';
        }
      }
    }
    return 'Техническое улучшение';
  }
  final matches = GameCatalog.features.where((item) => item.id == featureId);
  return matches.isEmpty ? 'Устаревшая функция' : matches.first.name;
}

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
    return ScopedListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final product = state.productById(productId);
        if (product == null) {
          return const Scaffold(
            body: Center(child: AppText('Продукт не найден')),
          );
        }
        final competitor = GameCatalog.competitorFor(product.category);
        final framework = GameCatalog.frameworkById(product.frameworkId);
        final load = state.productServerLoad(product);
        final strategy = ProductStrategyCatalog.strategyFor(
          product.blueprintId,
        );
        final phase = state.developmentPhaseFor(product);
        final staffing = state.developmentStaffingFor(product.id);
        final projection = ProductProjectionCache.estimate(
          blueprintId: product.blueprintId,
          frameworkId: product.frameworkId,
          languageIds: product.languageIds,
          technologyIds: product.technologyIds,
          featureIds: product.featureIds,
        );
        final monetizationCooldownDays = state
            .monetizationCooldownRemainingDays(product.id);
        final revenueForecast = state.revenueForecastFor(product);
        final availableFeatures = GameCatalog.features
            .where(
              (feature) =>
                  feature.supportedCategories.contains(product.category) &&
                  !product.featureIds.contains(feature.id) &&
                  (product.blueprintId != 'company_website' ||
                      GameCatalog.blueprintById(
                        product.blueprintId,
                      ).expectedFeatureIds.contains(feature.id)),
            )
            .toList(growable: false);
        final activeFeatureWork = state.activeFeatureDevelopmentFor(product.id);
        final activeFeatureWorkTitle = activeFeatureWork == null
            ? null
            : _safeActiveWorkTitle(activeFeatureWork.featureId);

        return Scaffold(
          appBar: AppBar(title: AppText(product.name)),
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
                  child: DevelopmentStageProgressRail(
                    state: state,
                    product: product,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (product.stage == ProductStage.development) ...[
                AppCard(
                  hintTitle: 'Разработка продукта',
                  hintBody:
                      'Новый продукт начинается с 0%. Прогресс растёт только вместе с игровым временем и зависит от назначенной команды, покрытия ролей, выбранного стека и корпоративной AI.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Разработка ${(product.developmentProgress * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: product.developmentProgress,
                      ),
                      const SizedBox(height: 12),
                      AppText(
                        phase.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      AppText(phase.description),
                      const SizedBox(height: 10),
                      AppText(
                        staffing.status,
                        style: TextStyle(
                          color: staffing.efficiency >= 0.80
                              ? AppColors.green
                              : AppColors.red,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _LabelValue(
                        'Рабочий объём',
                        '${projection.developmentHours.round()} ч.',
                      ),
                      _LabelValue(
                        'Осталось',
                        '${(projection.developmentHours * (1 - product.developmentProgress)).round()} ч.',
                      ),
                      _LabelValue(
                        'Штраф состава',
                        '${((1 - staffing.efficiency) * 100).round()}%',
                      ),
                      _LabelValue(
                        'Оптимальная команда',
                        '${staffing.optimalTeamSize} человек',
                      ),
                      _LabelValue(
                        'Языки покрыты',
                        percent(staffing.languageCoverage),
                      ),
                      _LabelValue(
                        'Роли покрыты',
                        percent(staffing.roleCoverage),
                      ),
                      _LabelValue(
                        'Эффективность состава',
                        percent(staffing.efficiency),
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        'Сейчас критичны: ${phase.criticalRoles.map(roleName).join(', ')}.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (staffing.movableEmployeeIds.isNotEmpty)
                        AppText(
                          'Можно временно выдернуть: ${staffing.movableEmployeeIds.map((id) => state.employeeById(id)?.name ?? id).join(', ')}.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      const SizedBox(height: 10),
                      _LabelValue(
                        'Назначено сотрудников',
                        '${state.employeesForProduct(product.id).length}',
                      ),
                      _LabelValue(
                        'Мощность разработки',
                        '${state.totalDevelopmentCapacityFor(product).toStringAsFixed(2)} FTE',
                        last: true,
                      ),
                      const SizedBox(height: 10),
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
                          label: const AppText('Выпустить продукт'),
                        ),
                      ),
                      if (product.allocatedCapacityPercent <= 0)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: AppText(
                            'Заблокировано: выделите серверную мощность.',
                            style: TextStyle(color: AppColors.red),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ProductDevelopmentExperience(
                  controller: controller,
                  product: product,
                ),
                const SizedBox(height: 18),
              ],
              SectionHeader(
                title: 'Специалисты для разработки',
                subtitle:
                    'Для каждого типа продукта нужны конкретные роли. Нехватка специальностей замедляет разработку и снижает качество исполнения.',
                hintTitle: 'Почему важны специальности',
                hintBody:
                    'Мощность разработки учитывает не только средние навыки, но и покрытие обязательных ролей. Один сильный Backend-разработчик не заменяет безопасность, дизайн или QA.',
              ),
              const SizedBox(height: 10),
              _ProductTeamRequirementsCard(state: state, product: product),
              const SizedBox(height: 10),
              SpecialistDeficitCard(
                deficits: StaffingDeficitResolver.forProduct(state, product),
              ),
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
                    label: 'Пользователи',
                    value: compactNumber(product.users),
                  ),
                  MetricCard(
                    label: 'DAU / MAU',
                    value:
                        '${compactNumber(product.dau)} / ${compactNumber(product.mau)}',
                  ),
                  MetricCard(
                    label: 'Активация',
                    value: percent(product.activationRate, fractionDigits: 1),
                  ),
                  MetricCard(
                    label: 'Удержание 30 дн.',
                    value: percent(product.retention30d, fractionDigits: 1),
                  ),
                  MetricCard(
                    label: 'Отток',
                    value: percent(product.churnRate, fractionDigits: 1),
                    positive: product.churnRate <= 0.08,
                  ),
                  MetricCard(
                    label: 'Рейтинг',
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
                    'Без обновлений органический рост, удержание и рейтинг постепенно снижаются.',
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
                      label: 'Задержка',
                      own: '${product.speedMs.round()} ms',
                      competitor: '${competitor.speedMs.round()} ms',
                      ownBetter: product.speedMs < competitor.speedMs,
                    ),
                    _ComparisonRow(
                      label: 'Дизайн',
                      own: '${product.designScore.round()}',
                      competitor: '${competitor.designScore.round()}',
                      ownBetter: product.designScore > competitor.designScore,
                    ),
                    _ComparisonRow(
                      label: 'Безопасность',
                      own: '${product.securityScore.round()}',
                      competitor: '${competitor.securityScore.round()}',
                      ownBetter:
                          product.securityScore > competitor.securityScore,
                    ),
                    _ComparisonRow(
                      label: 'Надёжность',
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
                    _LabelValue('Фреймворк', framework.name),
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
                    : 'Корпоративная AI ускоряет разработку и немного повышает качество, но требует вычислительной мощности и операционных расходов.',
                hintTitle: 'Публичная и корпоративная AI',
                hintBody:
                    'Публичная AI конкурирует за пользователей и приносит выручку. Корпоративная AI не продаётся на рынке: её можно подключать к другим продуктам для +18% к мощности разработки и +4 quality.',
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
              if (activeFeatureWork != null) ...[
                AppCard(
                  hintTitle: 'Активное обновление',
                  hintBody:
                      'Функция не покупается мгновенно. Назначенная команда выполняет рабочие часы, а компания оплачивает зарплаты и инфраструктуру.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        activeFeatureWorkTitle ?? 'Техническое улучшение',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: activeFeatureWork.progress,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        '${(activeFeatureWork.progress * 100).toStringAsFixed(1)}% • осталось ${state.featureDevelopmentRemainingHours(product.id).round()} командо-часов',
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        'Скорость: ${(state.productDevelopmentCapacity(product.id) + state.founderFeatureWorkCapacityFor(product)).toStringAsFixed(2)} FTE с учётом CEO.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SectionHeader(
                title: 'Roadmap продукта',
                subtitle: availableFeatures.isEmpty
                    ? 'Все крупные функции реализованы. Продукт продолжает развиваться через постоянные технические улучшения выше.'
                    : 'Добавляйте функции в очередь разработки. Они требуют рабочих часов, но не отдельной покупки.',
              ),
              const SizedBox(height: 10),
              if (availableFeatures.isEmpty)
                const AppCard(
                  child: AppText(
                    'Крупные функции завершены. Следите за свежестью и продолжайте улучшать скорость, алгоритмы, дизайн, security и reliability.',
                  ),
                )
              else
                AppCard(
                  child: ExpansionTile(
                    key: const Key('product-roadmap-expansion'),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(top: 8),
                    title: AppText(
                      'Доступно функций: ${availableFeatures.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: const AppText(
                      'Разверните список, чтобы выбрать следующее обновление.',
                    ),
                    children: availableFeatures
                        .map(
                          (feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _FeatureUpgradeCard(
                              feature: feature,
                              enabled:
                                  product.stage == ProductStage.live &&
                                  activeFeatureWork == null,
                              onAdd: () => controller.dispatch(
                                AddProductFeature(
                                  productId: product.id,
                                  featureId: feature.id,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
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
                      isExpanded: true,
                      initialValue: product.monetization,
                      decoration: InputDecoration(
                        labelText: trContext(context, 'Модель монетизации'),
                        helperText:
                            product.stage == ProductStage.live &&
                                monetizationCooldownDays > 0
                            ? 'Следующая смена через $monetizationCooldownDays дн.'
                            : 'После релиза модель можно менять раз в 30 игровых дней.',
                      ),
                      items: strategy.allowedMonetizationModels
                          .map(
                            (model) => DropdownMenuItem(
                              value: model,
                              child: AppText(monetizationName(model)),
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
                          AppText(
                            'Прогноз дохода / мес.',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                label: AppText(
                                  'Low ${money(revenueForecast.low)}',
                                ),
                              ),
                              Chip(
                                label: AppText(
                                  'Base ${money(revenueForecast.expected)}',
                                ),
                              ),
                              Chip(
                                label: AppText(
                                  'High ${money(revenueForecast.high)}',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          AppText(
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
                        state: state,
                        product: product,
                        onChanged: (price) => controller.dispatch(
                          SetProductPrice(productId: product.id, price: price),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _AdvertisingCampaignCard(
                      state: state,
                      product: product,
                      controller: controller,
                    ),
                  ],
                ),
              ),
              if (product.blueprintId == 'company_website' &&
                  product.stage == ProductStage.live) ...[
                const SizedBox(height: 18),
                SectionHeader(
                  title: 'Клиентские контракты',
                  subtitle:
                      '${state.activeContracts.length} активных • открыты после релиза сайта',
                ),
                const SizedBox(height: 10),
                AppCard(
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) =>
                              ContractsScreen(controller: controller),
                        ),
                      ),
                      icon: const Icon(Icons.handshake_outlined),
                      label: const AppText('Открыть контракты сайта'),
                    ),
                  ),
                ),
              ],
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
                      '${state.allocatedComputeFor(product.id).round()} CU',
                    ),
                    _LabelValue(
                      'Требуется compute',
                      '${state.productComputeDemand(product).round()} CU',
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
                              label: const AppText('Центр безопасности'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.outlined(
                            tooltip: trContext(context, 'Red-team сценарий'),
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
                child: AppText(
                  'Покрытие ${(coverage * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              AppText(
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
                        AppText(
                          '${roleName(requirement.role)}: $actual/${requirement.minimumCount}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        AppText(
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
                child: AppText(
                  '${score.toStringAsFixed(0)} / 100',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: danger ? AppColors.red : AppColors.green,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              AppText('${days.toStringAsFixed(1)} дн. без обновления'),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: score / 100),
          const SizedBox(height: 10),
          AppText(
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
                  label: AppText('Рынок'),
                  icon: Icon(Icons.public_outlined),
                ),
                ButtonSegment(
                  value: AiDeploymentMode.corporate,
                  label: AppText('Корпоративная'),
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
              AppText('Используют: ${targets.join(', ')}'),
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
            decoration: InputDecoration(
              labelText: trContext(context, 'Корпоративная AI'),
            ),
            items: [
              const DropdownMenuItem(
                value: '__none__',
                child: AppText('Не использовать'),
              ),
              ...available.map(
                (ai) => DropdownMenuItem(value: ai.id, child: AppText(ai.name)),
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
            AppText(
              'Сначала выпустите AI-продукт и переведите его в корпоративный режим.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            const AppText(
              '+18% к мощности разработки • +4 quality • 45 000 ₽/мес.',
            ),
        ],
      ),
    );
  }
}

class _SubscriptionPriceControl extends StatefulWidget {
  const _SubscriptionPriceControl({
    required this.state,
    required this.product,
    required this.onChanged,
  });

  final GameState state;
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
    final forecast = widget.state.priceImpactForecast(widget.product, value);
    final revenueDelta =
        forecast.expectedRevenueAfter - forecast.expectedRevenueBefore;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText(
                'Цена подписки',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            AppText(
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
          divisions: 30,
          label: '${value.round()} ₽',
          onChanged: (next) => setState(() => _draftPrice = next),
          onChangeEnd: (next) {
            widget.onChanged(next);
            setState(() => _draftPrice = null);
          },
        ),
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
              AppText(
                'Вероятный эффект изменения',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  Chip(
                    label: AppText(
                      'MAU ${directPercent(forecast.expectedUserChangePercent * 100, fractionDigits: 1)}',
                    ),
                  ),
                  Chip(
                    label: AppText(
                      'Churn ${forecast.expectedChurnDelta >= 0 ? '+' : ''}${directPercent(forecast.expectedChurnDelta * 100, fractionDigits: 1)}',
                    ),
                  ),
                  Chip(
                    label: AppText(
                      'MRR ${revenueDelta >= 0 ? '+' : ''}${money(revenueDelta)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              AppText(
                'Ценовой шок ${(forecast.sentimentShock * 100).toStringAsFixed(1)}%. ${forecast.note}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        AppText(
          'Текущее отношение аудитории к последнему изменению цены: ${(widget.state.currentPriceSentiment(widget.product) * 100).toStringAsFixed(1)}%.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AdvertisingCampaignCard extends StatefulWidget {
  const _AdvertisingCampaignCard({
    required this.state,
    required this.product,
    required this.controller,
  });

  final GameState state;
  final Product product;
  final GameController controller;

  @override
  State<_AdvertisingCampaignCard> createState() =>
      _AdvertisingCampaignCardState();
}

class _AdvertisingCampaignCardState extends State<_AdvertisingCampaignCard> {
  String _agencyId = ProductStrategyCatalog.agencies.first.id;
  String _channelId = ProductStrategyCatalog.channels.first.id;
  double _budget = ProductStrategyCatalog.agencies.first.minimumBudget;

  @override
  Widget build(BuildContext context) {
    final agency = ProductStrategyCatalog.agencyById(_agencyId);
    final channel = ProductStrategyCatalog.channelById(_channelId);
    final normalizedBudget = math.max(_budget, agency.minimumBudget).toDouble();
    final forecast = widget.state.advertisingForecast(
      product: widget.product,
      agencyId: agency.id,
      channelId: channel.id,
      budget: normalizedBudget,
    );
    final active = widget.state.activeCampaignsFor(widget.product.id);
    final canStart =
        widget.product.stage == ProductStage.live &&
        widget.state.cash >= normalizedBudget &&
        active.length < 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Рекламные кампании',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        AppText(
          'Вы выбираете агентство, канал и закупаемый объём. Результат ограничен качеством продукта, доверием и узнаваемостью.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (active.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...active.map((campaign) {
            final remainingDays = math.max(
              0,
              (campaign.endsAtMinutes - widget.state.simulationMinutes) / 1440,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  '${ProductStrategyCatalog.channelById(campaign.channelId).name} • ${money(campaign.budget)} • ${remainingDays.toStringAsFixed(1)} дн. • прогноз ${campaign.projectedUsersLow}–${campaign.projectedUsersHigh} users',
                ),
              ),
            );
          }),
        ],
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: ValueKey('advertising-agency-$_agencyId'),
          initialValue: _agencyId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: trContext(context, 'Рекламное агентство'),
          ),
          items: ProductStrategyCatalog.agencies
              .map(
                (item) => DropdownMenuItem(
                  value: item.id,
                  child: AppText(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _agencyId = value;
              _budget = math
                  .max(
                    _budget,
                    ProductStrategyCatalog.agencyById(value).minimumBudget,
                  )
                  .toDouble();
            });
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: ValueKey('advertising-channel-$_channelId'),
          initialValue: _channelId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: trContext(context, 'Канал закупки'),
          ),
          items: ProductStrategyCatalog.channels
              .map(
                (item) => DropdownMenuItem(
                  value: item.id,
                  child: AppText(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) setState(() => _channelId = value);
          },
        ),
        const SizedBox(height: 8),
        AppText('${agency.description} ${channel.description}'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            Chip(
              label: AppText(
                'Качество агентства ${(agency.quality * 100).round()}%',
              ),
            ),
            Chip(
              label: AppText(
                'Точность прогноза ${(agency.forecastAccuracy * 100).round()}%',
              ),
            ),
            Chip(
              label: AppText('Комиссия ${(agency.feePercent * 100).round()}%'),
            ),
            if (channel.baseCpm > 0)
              Chip(label: AppText('CPM ${money(channel.baseCpm)}')),
            if (channel.baseCpc > 0)
              Chip(label: AppText('CPC ${money(channel.baseCpc)}')),
            Chip(
              label: AppText(
                channel.bestForCategories.contains(widget.product.category)
                    ? 'Канал подходит продукту'
                    : 'Слабое попадание в аудиторию',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: AppText('Бюджет на 7 дней')),
            AppText(
              money(normalizedBudget),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        Slider(
          key: const Key('advertising-budget-slider'),
          min: agency.minimumBudget,
          max: math.max(agency.minimumBudget, 1500000).toDouble(),
          divisions: 24,
          value: normalizedBudget
              .clamp(agency.minimumBudget, 1500000)
              .toDouble(),
          onChanged: (value) => setState(() => _budget = value),
        ),
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
              AppText(
                'Что будет закуплено',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  Chip(
                    label: AppText(
                      '${compactNumber(forecast.impressions)} показов',
                    ),
                  ),
                  Chip(
                    label: AppText(
                      '${compactNumber(forecast.clicks)} переходов',
                    ),
                  ),
                  Chip(
                    label: AppText(
                      '${forecast.usersLow}–${forecast.usersHigh} пользователей',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              AppText(
                forecast.note,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('start-advertising-campaign'),
            onPressed: canStart
                ? () => widget.controller.dispatch(
                    StartAdvertisingCampaign(
                      productId: widget.product.id,
                      agencyId: agency.id,
                      channelId: channel.id,
                      budget: normalizedBudget,
                    ),
                  )
                : null,
            icon: const Icon(Icons.campaign_outlined),
            label: AppText(
              active.length >= 2
                  ? 'Уже две активные кампании'
                  : widget.state.cash < normalizedBudget
                  ? 'Недостаточно денег'
                  : 'Запустить кампанию',
            ),
          ),
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
    final released = product.stage == ProductStage.live;
    final activeWork = state.activeFeatureDevelopmentFor(product.id);
    final ownWork =
        activeWork != null &&
        activeWork.featureId.startsWith('__improvement_${option.type.name}_');
    final canStart = released && activeWork == null;
    final requiredHours = state.improvementRequiredHours(
      product.id,
      option.type,
    );
    return AppCard(
      hintTitle: option.name,
      hintBody: option.description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  option.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              AppText('L$level → L${level + 1}'),
            ],
          ),
          const SizedBox(height: 5),
          AppText(option.description),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              Chip(label: AppText('≈ ${requiredHours.round()} командо-часов')),
              if (option.speedMultiplier != 1)
                Chip(
                  label: AppText(
                    'Speed ×${option.speedMultiplier.toStringAsFixed(3)}',
                  ),
                ),
              if (option.designDelta != 0)
                Chip(label: AppText('Design +${option.designDelta}')),
              if (option.securityDelta != 0)
                Chip(label: AppText('Security +${option.securityDelta}')),
              if (option.qualityDelta != 0)
                Chip(label: AppText('Quality +${option.qualityDelta}')),
            ],
          ),
          if (ownWork) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: activeWork.progress.clamp(0, 1).toDouble(),
            ),
            const SizedBox(height: 6),
            AppText(
              'В работе ${(activeWork.progress * 100).toStringAsFixed(0)}% • осталось ${state.featureDevelopmentRemainingHours(product.id).round()} командо-часов',
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: canStart ? onApply : null,
              icon: const Icon(Icons.upgrade_outlined),
              label: AppText(
                !released
                    ? 'Доступно после релиза'
                    : ownWork
                    ? 'Улучшение в работе'
                    : activeWork != null
                    ? 'Сначала завершите текущую работу'
                    : 'Начать улучшение',
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
    required this.enabled,
    required this.onAdd,
  });

  final FeatureOption feature;
  final bool enabled;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final hours = math.max(24, feature.developmentCost / 450 * 1.25).round();
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
                    AppText(
                      feature.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      feature.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppText(
                '$hours ч.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
                    label: AppText(effect),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 8),
          AppText(
            'Прямой цены нет. Пока команда выполняет $hours рабочих часов, продолжают списываться зарплаты и инфраструктура.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              key: Key('add-feature-${feature.id}'),
              onPressed: enabled ? onAdd : null,
              icon: const Icon(Icons.add_task_outlined),
              label: AppText(
                enabled
                    ? 'Начать разработку функции'
                    : 'Сначала завершите текущее обновление',
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
        const Expanded(child: AppText('Метрика')),
        Expanded(
          child: AppText(
            own,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: AppText(
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
              Expanded(child: AppText(label)),
              Expanded(
                child: AppText(
                  own,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ownBetter ? AppColors.green : AppColors.red,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(child: AppText(competitor, textAlign: TextAlign.end)),
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
              Expanded(child: AppText(label)),
              const SizedBox(width: 12),
              Expanded(
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
