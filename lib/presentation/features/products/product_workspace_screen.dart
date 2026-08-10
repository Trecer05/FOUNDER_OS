import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../application/settings/display_preferences.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/catalog/product_evolution_catalog.dart';
import '../../../domain/catalog/product_strategy_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/v12_game_state_extensions.dart';
import '../../../domain/entities/product_evolution_models.dart';
import '../../../domain/entities/v17_models.dart';
import '../../../domain/explainability/staffing_deficit_resolver.dart';
import '../../../domain/explainability/product_configuration_resolver.dart';
import '../../../domain/simulation/product_projection_cache.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/development_stage_progress_rail.dart';
import '../../shared/widgets/interactive_metric_chart_card.dart';
import 'product_development_experience.dart';
import '../../../application/localization/app_text.dart';
import '../../shared/widgets/scoped_listenable_builder.dart';
import '../../../application/localization/app_localizer.dart';

enum _WorkspaceSection {
  overview,
  development,
  team,
  marketing,
  monetization,
  metrics,
  infrastructure,
}

enum _MetricRange {
  days7(7, '7д'),
  days30(30, '30д'),
  days90(90, '90д'),
  all(100000, 'Всё');

  const _MetricRange(this.days, this.label);
  final int days;
  final String label;
}

class ProductWorkspaceScreen extends StatefulWidget {
  const ProductWorkspaceScreen({
    required this.controller,
    required this.productId,
    super.key,
  });

  final GameController controller;
  final String productId;

  @override
  State<ProductWorkspaceScreen> createState() => _ProductWorkspaceScreenState();
}

class _ProductWorkspaceScreenState extends State<ProductWorkspaceScreen> {
  _WorkspaceSection _section = _WorkspaceSection.overview;
  _MetricRange _range = _MetricRange.days30;
  String? _agencyId;
  String? _channelId;
  double _campaignBudget = 80000;
  double? _priceDraft;
  double? _intensityDraft;
  double? _freeTierDraft;

  Product? get _product =>
      widget.controller.state.productById(widget.productId);

  @override
  Widget build(BuildContext context) {
    final product = _product;
    if (product == null) {
      return const Scaffold(body: Center(child: AppText('Продукт не найден')));
    }
    return Scaffold(
      appBar: AppBar(
        title: AppText(product.name),
        actions: [
          IconButton(
            key: const Key('rename-product'),
            tooltip: trContext(context, 'Изменить название'),
            onPressed: () => _showRenameProduct(product),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _SectionRail(
            selected: _section,
            onSelected: (value) => setState(() => _section = value),
          ),
          const Divider(height: 1),
          Expanded(
            child: ScopedAnimatedBuilder(
              animation: Listenable.merge(<Listenable>[
                widget.controller,
                DisplayPreferences.instance,
              ]),
              builder: (context, _) {
                final current = _product;
                if (current == null) {
                  return const SizedBox.shrink();
                }
                return _buildSection(current);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(Product product) => switch (_section) {
    _WorkspaceSection.overview => _overview(product),
    _WorkspaceSection.development => _development(product),
    _WorkspaceSection.team => _team(product),
    _WorkspaceSection.marketing => _marketing(product),
    _WorkspaceSection.monetization => _monetization(product),
    _WorkspaceSection.metrics => _metrics(product),
    _WorkspaceSection.infrastructure => _infrastructure(product),
  };

  Widget _list(List<Widget> children) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
    children: children,
  );

  Widget _overview(Product product) {
    final state = widget.controller.state;
    final blueprint = GameCatalog.blueprintById(product.blueprintId);
    final projection = ProductProjectionCache.estimate(
      blueprintId: product.blueprintId,
      frameworkId: product.frameworkId,
      languageIds: product.languageIds,
      technologyIds: product.technologyIds,
      featureIds: product.featureIds,
    );
    return _list([
      SectionHeader(
        title: blueprint.name,
        subtitle: '${stageName(product.stage)} • ${product.name}',
        hintTitle: 'Рабочее пространство продукта',
        hintBody:
            'Шесть разделов отделяют разработку, команду, рекламу, метрики и инфраструктуру. Управление людьми полностью находится в разделе «Команда».',
      ),
      const SizedBox(height: 12),
      AppCard(
        hintTitle: 'Совместимость стека',
        hintBody:
            'Совместимость — это согласованность фреймворка, языков, технологий и функций. 100% означает естественный стек; низкое значение добавляет часы, стоимость поддержки и риск дефектов.',
        hintBullets: const [
          '70–100%: стек понятный и поддерживаемый.',
          '45–69%: есть спорные сочетания и лишняя сложность.',
          'Ниже 45%: лучше сменить фреймворк или убрать часть стека.',
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MetricStrip(
              items: [
                _Pair('Пользователи', compactNumber(product.users)),
                _Pair('Выручка/мес.', money(product.monthlyRevenue)),
                _Pair('Рейтинг', product.rating.toStringAsFixed(1)),
                _Pair(
                  'Совместимость',
                  '${(projection.stackCoherence * 100).round()}%',
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: projection.stackCoherence.clamp(0, 1).toDouble(),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            AppText(
              'Совместимость ${(projection.stackCoherence * 100).round()}%: ${_coherenceMeaning(projection.stackCoherence)}',
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Быстрые действия',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (product.stage == ProductStage.development)
                  FilledButton.icon(
                    onPressed: product.developmentProgress >= 1
                        ? () => widget.controller.dispatch(
                            LaunchProduct(product.id),
                          )
                        : null,
                    icon: const Icon(Icons.rocket_launch),
                    label: AppText(
                      product.developmentProgress >= 1
                          ? 'Выпустить'
                          : 'Релиз ${(product.developmentProgress * 100).round()}%',
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _section = _WorkspaceSection.team),
                  icon: const Icon(Icons.group_add),
                  label: const AppText('Нанять под проект'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _section = _WorkspaceSection.metrics),
                  icon: const Icon(Icons.show_chart),
                  label: const AppText('Графики'),
                ),
                if (product.stage == ProductStage.live)
                  OutlinedButton.icon(
                    key: const Key('sell-product'),
                    onPressed: () => _confirmProductSale(product),
                    icon: const Icon(Icons.sell_outlined),
                    label: const AppText('Продать продукт'),
                  ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Экономика сейчас',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _row('Доход', money(product.monthlyRevenue)),
            _row('Технологии', money(product.monthlyCost)),
            _row(
              'Доля общей мощности',
              '${product.allocatedCapacityPercent.round()}%',
            ),
            _row(
              'Нагрузка продукта',
              '${(state.productServerLoad(product) * 100).round()}%',
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _development(Product product) {
    final state = widget.controller.state;
    final phase = state.developmentPhaseFor(product);
    final capacity = state.totalDevelopmentCapacityFor(product);
    final activeWork = state.activeFeatureDevelopmentFor(product.id);
    final competitor = state.competitorsForCategory(product.category).first;
    final availableFeatures = GameCatalog.features
        .where(
          (feature) =>
              feature.supportedCategories.contains(product.category) &&
              !product.featureIds.contains(feature.id),
        )
        .toList(growable: false);
    final availableTechnologies = GameCatalog.technologies
        .where((technology) => !product.technologyIds.contains(technology.id))
        .where(
          (technology) => ProductConfigurationResolver.availability(
            frameworkId: product.frameworkId,
            languageIds: product.languageIds,
            selectedTechnologyIds: product.technologyIds,
            technology: technology,
          ).enabled,
        )
        .toList(growable: false);
    return _list([
      SectionHeader(
        title: 'Разработка',
        subtitle:
            '${phase.name} • ${(product.developmentProgress * 100).round()}%',
        hintTitle: 'Мощность разработки',
        hintBody:
            'Мощность разработки — эффективная скорость команды в FTE. 1,0 FTE примерно равен одному подходящему специалисту на полной занятости. Значение учитывает навыки, роль, языки, долю времени, мораль и AI-помощь.',
      ),
      const SizedBox(height: 12),
      if (product.stage == ProductStage.development)
        AppCard(
          child: DevelopmentStageProgressRail(state: state, product: product),
        )
      else
        const AppCard(
          child: AppText(
            'Основная разработка завершена. Дальше продукт развивается через функции и технические улучшения.',
          ),
        ),
      if (product.stage == ProductStage.development) ...[
        const SizedBox(height: 12),
        ProductDevelopmentExperience(
          controller: widget.controller,
          product: product,
        ),
        if (product.developmentProgress >= 1) ...[
          const SizedBox(height: 12),
          AppCard(
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('release-from-development'),
                onPressed: () =>
                    widget.controller.dispatch(LaunchProduct(product.id)),
                icon: const Icon(Icons.rocket_launch),
                label: const AppText(
                  'Разработка завершена — выпустить продукт',
                ),
              ),
            ),
          ),
        ],
      ],
      const SizedBox(height: 12),
      AppCard(
        hintTitle: 'Почему меняется мощность разработки',
        hintBody:
            'Мощность разработки не является отдельным ресурсом или серверной мощностью. Это производительность людей. При работе сотрудника над несколькими проектами его вклад делится между ними, а перегрузка снижает мораль.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Эффективная скорость: ${capacity.toStringAsFixed(2)} FTE',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            AppText(_capacityMeaning(capacity)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: math.min(1, capacity / 5),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 12),
            _row('Текущая стадия', phase.name),
            _row('Прогресс', '${(product.developmentProgress * 100).round()}%'),
            _row(
              'Активная работа',
              activeWork == null
                  ? 'Нет очереди — команда свободна для новой задачи'
                  : '${_workName(activeWork.featureId)} ${(activeWork.progress * 100).round()}%',
            ),
            const SizedBox(height: 8),
            AppText(
              '«Активная работа» — это выбранная доработка, функция, исправление бага или расширение стека. Это не скрытый режим ускорения.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppText(
                    state.productCrunchStatus(product.id),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                FilledButton.icon(
                  key: const Key('start-product-crunch'),
                  onPressed:
                      state.canStartProductCrunch(product.id) &&
                          state.employeesForProduct(product.id).isNotEmpty
                      ? () => widget.controller.dispatch(
                          StartProductCrunch(product.id),
                        )
                      : null,
                  icon: const Icon(Icons.bolt),
                  label: const AppText('Форсаж на неделю'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AppText(
              'Форсаж даёт +28% на 7 дней, затем команда 7 дней работает на −22%. Повторно включить его во время восстановления нельзя.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (product.stage == ProductStage.live)
        AppCard(
          hintTitle: 'Постоянные улучшения',
          hintBody:
              'Улучшение больше не покупается мгновенно. Оно занимает рабочие часы. Пока команда работает, компания платит обычные зарплаты и инфраструктуру.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Поставить техническую работу',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...ProductImprovementType.values.map((type) {
                final option = ProductEvolutionCatalog.improvementByType(type);
                final level = state.improvementLevel(product.id, type);
                final ownWork =
                    activeWork != null &&
                    activeWork.featureId.startsWith(
                      '__improvement_${type.name}_',
                    );
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: AppText('${option.name} • уровень ${level + 1}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Только время команды; отдельного списания денег нет.',
                      ),
                      if (ownWork) ...[
                        const SizedBox(height: 7),
                        LinearProgressIndicator(
                          value: activeWork.progress.clamp(0, 1).toDouble(),
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          'В работе ${(activeWork.progress * 100).toStringAsFixed(0)}% • осталось ${state.featureDevelopmentRemainingHours(product.id).round()} командо-часов',
                        ),
                      ],
                    ],
                  ),
                  trailing: FilledButton(
                    onPressed: activeWork == null
                        ? () => widget.controller.dispatch(
                            ApplyProductImprovement(
                              productId: product.id,
                              type: type,
                            ),
                          )
                        : null,
                    child: AppText(
                      ownWork
                          ? '${(activeWork.progress * 100).round()}%'
                          : activeWork == null
                          ? 'Начать'
                          : 'Занято',
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      if (product.stage == ProductStage.live) ...[
        const SizedBox(height: 12),
        AppCard(
          key: const Key('post-release-roadmap'),
          hintTitle: 'Функции после релиза',
          hintBody:
              'Новая функция проходит два этапа: сначала платный R&D компании, затем внедрение рабочими часами команды. Исследование выполняется один раз и после этого доступно всем продуктам.',
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: AppText(
              'Функции • установлено ${product.featureIds.length}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: AppText(
              availableFeatures.isEmpty
                  ? 'Все доступные функции уже выпущены.'
                  : 'Доступно к разработке: ${availableFeatures.length}',
            ),
            children: availableFeatures
                .take(20)
                .map((feature) {
                  final ownWork = activeWork?.featureId == feature.id;
                  final researchKey = state.researchKey(
                    ResearchTargetKind.feature,
                    feature.id,
                  );
                  final research = state.activeResearchFor(researchKey);
                  final researched = state.researchCompleted(
                    ResearchTargetKind.feature,
                    feature.id,
                  );
                  final researchCost = state.researchCost(
                    ResearchTargetKind.feature,
                    feature.id,
                  );
                  final researchDays = state.researchDays(
                    ResearchTargetKind.feature,
                    feature.id,
                  );
                  final researchProgress = research == null
                      ? 0.0
                      : ((state.simulationMinutes - research.startedAtMinutes) /
                                math.max(
                                  1,
                                  research.completesAtMinutes -
                                      research.startedAtMinutes,
                                ))
                            .clamp(0, 1)
                            .toDouble();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: AppText(feature.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(feature.description),
                        const SizedBox(height: 5),
                        if (!researched && research == null)
                          AppText(
                            'R&D: ${money(researchCost)} • $researchDays дн. До исследования внедрение недоступно.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (research != null) ...[
                          const SizedBox(height: 6),
                          LinearProgressIndicator(value: researchProgress),
                          const SizedBox(height: 4),
                          AppText(
                            'Исследование ${(researchProgress * 100).round()}% • осталось ${math.max(0, ((research.completesAtMinutes - state.simulationMinutes) / 1440).ceil())} дн.',
                          ),
                        ],
                        if (researched && !ownWork)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: AppText('R&D готово • можно внедрять'),
                          ),
                        if (ownWork) ...[
                          const SizedBox(height: 7),
                          LinearProgressIndicator(
                            value: activeWork!.progress.clamp(0, 1).toDouble(),
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            'В работе ${(activeWork.progress * 100).round()}% • осталось ${state.featureDevelopmentRemainingHours(product.id).round()} командо-часов',
                          ),
                        ],
                      ],
                    ),
                    trailing: researched
                        ? FilledButton(
                            onPressed: activeWork == null
                                ? () => widget.controller.dispatch(
                                    AddProductFeature(
                                      productId: product.id,
                                      featureId: feature.id,
                                    ),
                                  )
                                : null,
                            child: AppText(
                              ownWork
                                  ? '${(activeWork!.progress * 100).round()}%'
                                  : 'Внедрить',
                            ),
                          )
                        : FilledButton.tonal(
                            key: Key('research-feature-${feature.id}'),
                            onPressed:
                                research == null && state.cash >= researchCost
                                ? () => widget.controller.dispatch(
                                    StartCompanyResearch(
                                      kind: ResearchTargetKind.feature,
                                      targetId: feature.id,
                                    ),
                                  )
                                : null,
                            child: AppText(
                              research == null
                                  ? 'Исследовать'
                                  : '${(researchProgress * 100).round()}%',
                            ),
                          ),
                  );
                })
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          key: const Key('post-release-stack-expansion'),
          hintTitle: 'Расширение стека после релиза',
          hintBody:
              'Дополнительная технология может снизить latency, повысить стабильность или безопасность, но увеличивает стоимость сопровождения и compute.',
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: AppText(
              'Стек • ${product.technologyIds.length} технологий',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: AppText(
              'Latency сейчас ${product.speedMs.round()} ms • доступно ${availableTechnologies.length}',
            ),
            children: availableTechnologies
                .take(16)
                .map((technology) {
                  final ownWork =
                      activeWork?.featureId == '__technology_${technology.id}';
                  final researchKey = state.researchKey(
                    ResearchTargetKind.technology,
                    technology.id,
                  );
                  final research = state.activeResearchFor(researchKey);
                  final researched = state.researchCompleted(
                    ResearchTargetKind.technology,
                    technology.id,
                  );
                  final researchCost = state.researchCost(
                    ResearchTargetKind.technology,
                    technology.id,
                  );
                  final researchDays = state.researchDays(
                    ResearchTargetKind.technology,
                    technology.id,
                  );
                  final researchProgress = research == null
                      ? 0.0
                      : ((state.simulationMinutes - research.startedAtMinutes) /
                                math.max(
                                  1,
                                  research.completesAtMinutes -
                                      research.startedAtMinutes,
                                ))
                            .clamp(0, 1)
                            .toDouble();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: AppText(technology.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          '${technology.description} • performance +${technology.performanceDelta.toStringAsFixed(0)} • ${money(technology.monthlyCost)}/мес.',
                        ),
                        const SizedBox(height: 5),
                        if (!researched && research == null)
                          AppText(
                            'R&D: ${money(researchCost)} • $researchDays дн. Исследование открывает технологию для всех продуктов.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (research != null) ...[
                          const SizedBox(height: 6),
                          LinearProgressIndicator(value: researchProgress),
                          const SizedBox(height: 4),
                          AppText(
                            'Исследование ${(researchProgress * 100).round()}% • осталось ${math.max(0, ((research.completesAtMinutes - state.simulationMinutes) / 1440).ceil())} дн.',
                          ),
                        ],
                        if (researched && !ownWork)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: AppText('R&D готово • можно интегрировать'),
                          ),
                        if (ownWork) ...[
                          const SizedBox(height: 7),
                          LinearProgressIndicator(
                            value: activeWork!.progress.clamp(0, 1).toDouble(),
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            'Интеграция ${(activeWork.progress * 100).round()}% • осталось ${state.featureDevelopmentRemainingHours(product.id).round()} командо-часов',
                          ),
                        ],
                      ],
                    ),
                    trailing: researched
                        ? FilledButton(
                            onPressed: activeWork == null
                                ? () => widget.controller.dispatch(
                                    AddProductTechnology(
                                      productId: product.id,
                                      technologyId: technology.id,
                                    ),
                                  )
                                : null,
                            child: AppText(
                              ownWork
                                  ? '${(activeWork!.progress * 100).round()}%'
                                  : 'Интегрировать',
                            ),
                          )
                        : FilledButton.tonal(
                            key: Key('research-technology-${technology.id}'),
                            onPressed:
                                research == null && state.cash >= researchCost
                                ? () => widget.controller.dispatch(
                                    StartCompanyResearch(
                                      kind: ResearchTargetKind.technology,
                                      targetId: technology.id,
                                    ),
                                  )
                                : null,
                            child: AppText(
                              research == null
                                  ? 'Исследовать'
                                  : '${(researchProgress * 100).round()}%',
                            ),
                          ),
                  );
                })
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          key: const Key('product-bug-backlog'),
          hintTitle: 'Баги продукта',
          hintBody:
              'Вес 1 — minor, 3 — major, 7 — critical. Общий вес ухудшает latency, reliability, качество, churn и выручку. Исправление занимает время команды.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Открыто ${product.openBugs.length} • вес ${state.productBugWeight(product)} • исправлено ${product.fixedBugCount}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              if (product.openBugs.isEmpty) ...[
                const SizedBox(height: 8),
                const AppText('Открытых дефектов нет.'),
              ] else ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: Key('fix-all-bugs-${product.id}'),
                    onPressed: activeWork == null
                        ? () => widget.controller.dispatch(
                            FixAllProductBugs(product.id),
                          )
                        : null,
                    icon: const Icon(Icons.auto_fix_high_outlined),
                    label: AppText(
                      'Исправить все баги разом • ${product.openBugs.length} шт.',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (activeWork?.featureId == '__bug_all__') ...[
                  LinearProgressIndicator(
                    key: Key('fix-all-bugs-progress-${product.id}'),
                    value: activeWork!.progress.clamp(0, 1).toDouble(),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    'Пакетное исправление ${(activeWork.progress * 100).round()}% • осталось ${state.featureDevelopmentRemainingHours(product.id).round()} командо-часов',
                  ),
                  const SizedBox(height: 6),
                ],
                ...product.openBugs.map((bug) {
                  final ownWork = activeWork?.featureId == '__bug_${bug.id}';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: AppText('${bug.weight}')),
                    title: AppText(bug.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          '${bug.severity.name} • найден ${state.formatDateAt(bug.openedAtMinutes)}',
                        ),
                        if (ownWork) ...[
                          const SizedBox(height: 7),
                          LinearProgressIndicator(
                            value: activeWork!.progress.clamp(0, 1).toDouble(),
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            'Исправление ${(activeWork.progress * 100).round()}%',
                          ),
                        ],
                      ],
                    ),
                    trailing: FilledButton(
                      onPressed: activeWork == null
                          ? () => widget.controller.dispatch(
                              FixProductBug(
                                productId: product.id,
                                bugId: bug.id,
                              ),
                            )
                          : null,
                      child: AppText(
                        ownWork
                            ? '${(activeWork!.progress * 100).round()}%'
                            : 'Исправить',
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Техническое устаревание',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              _row(
                'Свежесть сейчас',
                '${state.productFreshnessScore(product).round()}/100',
              ),
              _row(
                'Максимум для возраста продукта',
                '${state.productFreshnessCeiling(product).round()}/100',
              ),
              _row(
                'Поддерживаемый возраст',
                '${state.productSupportedLifetimeDays(product).round()} дн.',
              ),
              AppText(
                'Функции, новый стек и технические улучшения продлевают поддерживаемый срок жизни продукта. После этого потолок свежести постепенно снижается; просто смена даты обновления не обнуляет возраст.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          hintTitle: 'Сравнение с рынком',
          hintBody:
              'Это ближайший ориентир в категории. Улучшения продукта должны сокращать разрыв по скорости, дизайну, безопасности, надёжности и полноте функций.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Относительно ${competitor.productName}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              _row(
                'Задержка',
                '${product.speedMs.round()} ms / ${competitor.speedMs.round()} ms',
              ),
              _row(
                'Дизайн',
                '${product.designScore.round()} / ${competitor.designScore.round()}',
              ),
              _row(
                'Безопасность',
                '${product.securityScore.round()} / ${competitor.securityScore.round()}',
              ),
              _row(
                'Надёжность',
                '${percent(product.reliability, fractionDigits: 2)} / ${percent(competitor.reliability, fractionDigits: 2)}',
              ),
              _row(
                'Функции',
                '${product.featureIds.length} / ${competitor.featureIds.length}',
              ),
              _row(
                'Рыночный score',
                '${GameCatalog.productMarketScore(product, state.productFreshnessScore(product)).toStringAsFixed(1)} / ${competitor.marketScore.toStringAsFixed(0)}',
              ),
            ],
          ),
        ),
      ],
    ]);
  }

  Widget _team(Product product) {
    final state = widget.controller.state;
    final team = state.employeesForProduct(product.id);
    final deficits = StaffingDeficitResolver.forProduct(state, product);
    final hasHr = state.employees.any((employee) => employee.isHr);
    final requiredRoles = deficits.map((item) => item.roleId).toSet();
    final teamIds = team.map((item) => item.id).toSet();
    final availableEmployees =
        state.employees
            .where(
              (employee) =>
                  !employee.isHr &&
                  !teamIds.contains(employee.id) &&
                  requiredRoles.contains(employee.role.name) &&
                  state.canAssignEmployeeToMoreWork(employee.id),
            )
            .toList(growable: false)
          ..sort((left, right) {
            final load = state
                .activeAssignmentCountForEmployee(left.id)
                .compareTo(state.activeAssignmentCountForEmployee(right.id));
            if (load != 0) {
              return load;
            }
            return right.skill.compareTo(left.skill);
          });
    final candidates =
        state.candidates
            .where(
              (candidate) =>
                  !candidate.isHr &&
                  requiredRoles.contains(candidate.role.name),
            )
            .toList(growable: false)
          ..sort((left, right) {
            final leftLanguages = left.languageIds
                .where(product.languageIds.contains)
                .length;
            final rightLanguages = right.languageIds
                .where(product.languageIds.contains)
                .length;
            if (leftLanguages != rightLanguages) {
              return rightLanguages.compareTo(leftLanguages);
            }
            return right.skill.compareTo(left.skill);
          });
    final productManagerBonus = state.productManagerBonusPercentFor(product.id);
    final founderCapacity = state.founderDevelopmentCapacityFor(product);

    return _list([
      SectionHeader(
        title: 'Команда',
        subtitle: '${team.length} сотрудников • дефицитов ${deficits.length}',
        hintTitle: 'Команда продукта',
        hintBody:
            'Все назначения продукта находятся здесь. CEO участвует автоматически. Один сотрудник может вести до четырёх активных работ с падающей эффективностью.',
      ),
      const SizedBox(height: 12),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('CEO', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: AppText(
                state.companyProfile.founderName,
                translate: false,
              ),
              subtitle: AppText(
                'Автоматический участник • ${founderCapacity.toStringAsFixed(2)} FTE',
              ),
              trailing: const Chip(label: AppText('CEO')),
            ),
            if (productManagerBonus > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: AppText(
                  'Product Manager: +${(productManagerBonus * 100).round()}% к производительности по грейду.',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: AppText(
                    'Автоподбор',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Chip(
                  avatar: Icon(
                    hasHr ? Icons.check_circle : Icons.lock,
                    size: 18,
                  ),
                  label: AppText(hasHr ? 'HR есть' : 'Нужен HR'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const AppText(
              'Автоподбор закрывает только минимальные дефициты ролей. Лишние должности и запасной headcount не создаются.',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('auto-hire-project-team'),
                onPressed: hasHr && deficits.isNotEmpty
                    ? () => widget.controller.dispatch(
                        AutoHireProjectTeam(product.id),
                      )
                    : null,
                icon: const Icon(Icons.auto_awesome),
                label: AppText(
                  deficits.isEmpty
                      ? 'Минимальный состав закрыт'
                      : hasHr
                      ? 'Добрать только недостающих'
                      : 'Сначала наймите HR',
                ),
              ),
            ),
          ],
        ),
      ),
      if (deficits.isNotEmpty) ...[
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Кого не хватает',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              ...deficits
                  .take(8)
                  .map(
                    (deficit) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_search),
                      title: AppText(
                        '${deficit.roleName} ×${deficit.missingCount}',
                      ),
                      subtitle: AppText(deficit.effect),
                    ),
                  ),
            ],
          ),
        ),
      ],
      if (availableEmployees.isNotEmpty) ...[
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Подходящие сотрудники уже в штате',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              ...availableEmployees
                  .take(8)
                  .map(
                    (employee) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: AppText(employee.name),
                      subtitle: AppText(
                        '${employeeRoleName(employee)} • workload ${employee.workload}/100',
                      ),
                      trailing: FilledButton(
                        onPressed: () => widget.controller.dispatch(
                          AssignEmployeeToProduct(
                            employeeId: employee.id,
                            productId: product.id,
                          ),
                        ),
                        child: const AppText('Назначить'),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 12),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Рынок кандидатов',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            if (deficits.isEmpty)
              const AppText(
                'Минимальный состав закрыт. Лишние должности под этот продукт не предлагаются.',
              )
            else if (candidates.isEmpty)
              const AppText('Под нужные роли кандидатов сейчас нет.')
            else
              ...candidates.take(10).map((candidate) {
                final languageMatch = candidate.languageIds
                    .where(product.languageIds.contains)
                    .map((id) => GameCatalog.languageById(id).name)
                    .toList(growable: false);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: AppText(candidate.name.substring(0, 1)),
                  ),
                  title: AppText(candidate.name),
                  subtitle: AppText(
                    '${candidateRoleName(candidate)} • ${gradeName(candidate.grade)} • skill ${candidate.skill} • ${money(candidate.salary)}/мес.'
                    '${languageMatch.isEmpty ? '' : ' • ${languageMatch.join(', ')}'}',
                  ),
                  trailing: FilledButton(
                    onPressed: () => widget.controller.dispatch(
                      HireCandidateForProduct(
                        candidateId: candidate.id,
                        productId: product.id,
                      ),
                    ),
                    child: const AppText('Нанять'),
                  ),
                );
              }),
          ],
        ),
      ),
      if (team.isNotEmpty) ...[
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Назначенные сотрудники',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              ...team.map((employee) {
                final allocation = state.employeeAllocationForProduct(
                  employee.id,
                  product.id,
                );
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: AppText(employee.name),
                  subtitle: AppText(
                    '${employeeRoleName(employee)} • ${allocation.round()}% • workload ${employee.workload}/100 • morale ${employee.morale}/100',
                  ),
                  trailing: IconButton(
                    tooltip: trContext(context, 'Снять с продукта'),
                    icon: const Icon(Icons.person_remove_outlined),
                    onPressed: () => widget.controller.dispatch(
                      SetProductTeam(
                        productId: product.id,
                        employeeIds: team
                            .where((item) => item.id != employee.id)
                            .map((item) => item.id)
                            .toList(growable: false),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    ]);
  }

  Widget _monetization(Product product) {
    final state = widget.controller.state;
    final strategy = ProductStrategyCatalog.strategyFor(product.blueprintId);
    // A migrated/legacy save can keep a model that is no longer allowed by the
    // current strategy. Keep that current value renderable, while GameEngine
    // remains the source of truth for which new models may be selected.
    final monetizationOptions = <MonetizationModel>{
      product.monetization,
      ...strategy.allowedMonetizationModels,
    }.toList(growable: false);
    final cooldown = state.monetizationCooldownRemainingDays(product.id);
    final forecast = state.revenueForecastFor(product);
    final blueprint = GameCatalog.blueprintById(product.blueprintId);
    final (minimum, maximum, divisions) = switch (product.monetization) {
      MonetizationModel.subscription => (
        math.max(49, blueprint.basePrice * 0.25).toDouble(),
        math.max(49, blueprint.basePrice * 4).toDouble(),
        20,
      ),
      MonetizationModel.usageBased => (5.0, 500.0, 33),
      MonetizationModel.advertising => (0.5, 4.0, 35),
      MonetizationModel.transactionFee => (0.5, 10.0, 38),
      MonetizationModel.free => (0.0, 1.0, 1),
    };
    final value = (_priceDraft ?? product.price)
        .clamp(minimum, maximum)
        .toDouble();
    final intensity = (_intensityDraft ?? product.monetizationIntensity)
        .clamp(0.1, 1.0)
        .toDouble();
    final freeTier = (_freeTierDraft ?? product.freeTierPercent)
        .clamp(0, 0.9)
        .toDouble();
    final experienceImpact = state.monetizationExperienceImpact(product);
    final intensityLabel = switch (product.monetization) {
      MonetizationModel.free => 'Монетизация отключена',
      MonetizationModel.subscription => 'Жёсткость paywall',
      MonetizationModel.usageBased => 'Доля платного использования',
      MonetizationModel.advertising => 'Рекламная агрессивность',
      MonetizationModel.transactionFee => 'Агрессивность комиссии',
    };
    final settingLabel = switch (product.monetization) {
      MonetizationModel.free => 'Настроек оплаты нет',
      MonetizationModel.subscription => 'Цена подписки',
      MonetizationModel.usageBased => 'Цена за 1 000 операций',
      MonetizationModel.advertising => 'Рекламная нагрузка',
      MonetizationModel.transactionFee => 'Комиссия с транзакции',
    };
    String formatSetting(double setting) => switch (product.monetization) {
      MonetizationModel.subscription ||
      MonetizationModel.usageBased => money(setting),
      MonetizationModel.advertising => '×${setting.toStringAsFixed(1)}',
      MonetizationModel.transactionFee => '${setting.toStringAsFixed(1)}%',
      MonetizationModel.free => '—',
    };
    return _list([
      SectionHeader(
        title: 'Монетизация',
        subtitle: monetizationName(product.monetization),
        hintTitle: 'Настройка коммерческой модели',
        hintBody:
            'Каждая модель имеет собственный параметр: цену подписки, цену использования, рекламную нагрузку или комиссию. Более агрессивная настройка увеличивает доход, но рынок учитывает цену и доверие.',
      ),
      const SizedBox(height: 12),
      AppCard(
        key: const Key('workspace-monetization-guide'),
        hintTitle: 'Как выбрать монетизацию',
        hintBody:
            'Справочник свернут по умолчанию. Разверните его, когда нужно сравнить модели и их риски.',
        child: ExpansionTile(
          key: const Key('workspace-monetization-guide-expansion'),
          initiallyExpanded: false,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: const AppText(
            'Справочник по моделям монетизации',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: const AppText(
            'Свернуто по умолчанию • нажмите, чтобы открыть подробности',
          ),
          children: const [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    '• Free — быстрый набор аудитории без прямой выручки. KPI: activation, retention, MAU. Риск: инфраструктура растёт быстрее дохода.',
                  ),
                  SizedBox(height: 7),
                  AppText(
                    '• Subscription — повторяющаяся выручка. KPI: платящие, MRR, retention, churn. Риск: высокий прайс и жёсткий paywall выталкивают пользователей.',
                  ),
                  SizedBox(height: 7),
                  AppText(
                    '• Usage based — оплата за реальное использование. KPI: ARPU, активность, маржа после compute. Риск: себестоимость растёт быстрее выручки.',
                  ),
                  SizedBox(height: 7),
                  AppText(
                    '• Advertising — бесплатный вход, доход от аудитории. KPI: MAU, DAU, вовлечённость. Риск: рекламный перегруз повышает churn и снижает доверие.',
                  ),
                  SizedBox(height: 7),
                  AppText(
                    '• Transaction fee — комиссия с операций. KPI: объём операций, activation, доверие. Риск: высокая комиссия уменьшает число операций.',
                  ),
                  Divider(height: 22),
                  AppText(
                    'Правило: максимизируйте не доход с пользователя, а устойчивую связку revenue + activation + retention + churn + trust.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      AppCard(
        key: const Key('workspace-monetization-controls'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<MonetizationModel>(
              key: ValueKey(
                'workspace-monetization-${product.id}-${product.monetization.name}',
              ),
              initialValue: product.monetization,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: trContext(context, 'Модель монетизации'),
                helperText: cooldown > 0
                    ? trContext(context, 'Следующая смена через $cooldown дн.')
                    : trContext(context, 'Изменение доступно сейчас.'),
              ),
              items: monetizationOptions
                  .map(
                    (model) => DropdownMenuItem(
                      value: model,
                      child: AppText(monetizationName(model)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: product.stage == ProductStage.live && cooldown > 0
                  ? null
                  : (model) {
                      if (model == null) {
                        return;
                      }
                      setState(() => _priceDraft = null);
                      widget.controller.dispatch(
                        SetProductMonetization(
                          productId: product.id,
                          model: model,
                        ),
                      );
                    },
            ),
            const SizedBox(height: 12),
            _row(
              'Прогноз дохода',
              '${money(forecast.low)} – ${money(forecast.high)} / мес.',
            ),
            _row(
              'Влияние на пользователей',
              'activation ${experienceImpact.activationDelta >= 0 ? '+' : ''}${(experienceImpact.activationDelta * 100).toStringAsFixed(1)} п.п. • retention ${experienceImpact.retentionDelta >= 0 ? '+' : ''}${(experienceImpact.retentionDelta * 100).toStringAsFixed(1)} п.п.',
            ),
            _row(
              'Отток и доверие',
              'churn ${experienceImpact.churnDelta >= 0 ? '+' : ''}${(experienceImpact.churnDelta * 100).toStringAsFixed(1)} п.п. • trust ${experienceImpact.trustDelta >= 0 ? '+' : ''}${(experienceImpact.trustDelta * 100).toStringAsFixed(1)} п.п.',
            ),
            if (product.monetization != MonetizationModel.free) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: AppText(settingLabel)),
                  AppText(
                    formatSetting(value),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Slider(
                key: Key('workspace-monetization-setting-${product.id}'),
                value: value,
                min: minimum,
                max: maximum,
                divisions: divisions,
                label: formatSetting(value),
                onChanged: (next) => setState(() => _priceDraft = next),
                onChangeEnd: (next) {
                  widget.controller.dispatch(
                    SetProductPrice(productId: product.id, price: next),
                  );
                  setState(() => _priceDraft = null);
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: AppText(intensityLabel)),
                  AppText(
                    percent(intensity),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Slider(
                key: Key('workspace-monetization-intensity-${product.id}'),
                value: intensity,
                min: 0.1,
                max: 1,
                divisions: 18,
                label: percent(intensity),
                onChanged: (next) => setState(() => _intensityDraft = next),
                onChangeEnd: (next) {
                  widget.controller.dispatch(
                    SetProductMonetizationSettings(
                      productId: product.id,
                      intensity: next,
                      freeTierPercent: freeTier,
                    ),
                  );
                  setState(() => _intensityDraft = null);
                },
              ),
              if (product.monetization == MonetizationModel.subscription ||
                  product.monetization == MonetizationModel.usageBased) ...[
                Row(
                  children: [
                    const Expanded(child: AppText('Бесплатный тариф / квота')),
                    AppText(
                      percent(freeTier),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Slider(
                  key: Key('workspace-free-tier-${product.id}'),
                  value: freeTier,
                  min: 0,
                  max: 0.9,
                  divisions: 18,
                  label: percent(freeTier),
                  onChanged: (next) => setState(() => _freeTierDraft = next),
                  onChangeEnd: (next) {
                    widget.controller.dispatch(
                      SetProductMonetizationSettings(
                        productId: product.id,
                        intensity: intensity,
                        freeTierPercent: next,
                      ),
                    );
                    setState(() => _freeTierDraft = null);
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    ]);
  }

  Widget _marketing(Product product) {
    final state = widget.controller.state;
    final agencies = ProductStrategyCatalog.agencies;
    final channels = ProductStrategyCatalog.channels;
    _agencyId ??= agencies.first.id;
    _channelId ??= channels.first.id;
    final selectedAgency = ProductStrategyCatalog.agencyById(_agencyId!);
    final effectiveBudget = math
        .max(_campaignBudget, selectedAgency.minimumBudget)
        .toDouble();
    final campaigns = state.activeCampaignsFor(product.id);
    return _list([
      SectionHeader(
        title: 'Реклама и рост',
        subtitle: 'Активных каналов: ${campaigns.length}/3',
        hintTitle: 'Отдельный рекламный раздел',
        hintBody:
            'Канал работает постоянно, пока вы его не остановите. Бюджет задаётся на месяц, списание идёт ежедневно, а пользователи приходят постепенно.',
      ),
      const SizedBox(height: 12),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _agencyId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: trContext(context, 'Агентство'),
              ),
              items: agencies
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
                if (value == null) {
                  return;
                }
                final minimum = ProductStrategyCatalog.agencyById(
                  value,
                ).minimumBudget;
                setState(() {
                  _agencyId = value;
                  _campaignBudget = math
                      .max(_campaignBudget, minimum)
                      .toDouble();
                });
              },
            ),
            const SizedBox(height: 12),
            AppText('Бюджет / мес.: ${money(effectiveBudget)}'),
            Slider(
              value: effectiveBudget,
              min: selectedAgency.minimumBudget,
              max: math.max(selectedAgency.minimumBudget, 3000000).toDouble(),
              divisions: 30,
              label: money(effectiveBudget),
              onChanged: (value) => setState(() => _campaignBudget = value),
            ),
            const SizedBox(height: 8),
            const AppText(
              'Прогноз по всем каналам',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            ...channels.map((channel) {
              final forecast = state.advertisingForecast(
                product: product,
                agencyId: selectedAgency.id,
                channelId: channel.id,
                budget: effectiveBudget,
              );
              final selected = channel.id == _channelId;
              final fit = channel.bestForCategories.contains(product.category);
              return Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Material(
                  color: selected
                      ? AppColors.primary.withAlpha(18)
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _channelId = channel.id),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textMuted,
                            size: 19,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  channel.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                AppText(
                                  '${compactNumber(forecast.impressions)} показов • ${compactNumber(forecast.clicks)} переходов • ${forecast.usersLow}–${forecast.usersHigh} пользователей',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                AppText(
                                  fit
                                      ? 'Хорошее попадание в категорию'
                                      : 'Аудитория подходит хуже — прогноз уже учитывает штраф',
                                  style: TextStyle(
                                    color: fit
                                        ? AppColors.green
                                        : AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    product.stage == ProductStage.live &&
                        campaigns.length < 3 &&
                        state.cash >= effectiveBudget / 6
                    ? () => widget.controller.dispatch(
                        StartAdvertisingCampaign(
                          productId: product.id,
                          agencyId: _agencyId!,
                          channelId: _channelId!,
                          budget: effectiveBudget,
                        ),
                      )
                    : null,
                icon: const Icon(Icons.campaign),
                label: const AppText('Включить рекламный канал'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ...campaigns.map(
        (campaign) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  ProductStrategyCatalog.channelById(campaign.channelId).name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                AppText(
                  'Постоянный канал • ${money(campaign.budget)}/мес. • списание ${(campaign.budget / 30).round()} ₽/день',
                ),
                const SizedBox(height: 4),
                AppText(
                  'Прогноз ${campaign.projectedUsersLow}–${campaign.projectedUsersHigh} пользователей/мес. • уже приведено ${campaign.deliveredUsers}',
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => widget.controller.dispatch(
                      StopAdvertisingCampaign(campaign.id),
                    ),
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const AppText('Остановить канал'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _metrics(Product product) {
    final state = widget.controller.state;
    final cutoff = state.simulationMinutes - _range.days * 1440;
    final history = state
        .metricHistoryFor(product.id)
        .where((item) => item.simulationMinutes >= cutoff)
        .toList(growable: false);

    List<InteractiveMetricPoint> points(double Function(dynamic item) value) =>
        history
            .map(
              (item) => InteractiveMetricPoint(
                simulationMinutes: item.simulationMinutes,
                value: value(item),
              ),
            )
            .toList(growable: false);

    return _list([
      SectionHeader(
        title: 'Метрики',
        subtitle: 'Период: ${_range.label}',
        hintTitle: 'Интерактивные графики',
        hintBody:
            'Проведите пальцем по графику: карточка покажет точную дату и значение выбранного игрового дня.',
      ),
      const SizedBox(height: 10),
      SegmentedButton<_MetricRange>(
        segments: _MetricRange.values
            .map(
              (item) => ButtonSegment(value: item, label: AppText(item.label)),
            )
            .toList(growable: false),
        selected: {_range},
        onSelectionChanged: (value) => setState(() => _range = value.first),
      ),
      const SizedBox(height: 12),
      InteractiveMetricChartCard(
        title: 'Пользователи',
        current: compactNumber(product.users),
        points: points((item) => item.users.toDouble()),
        dateFormatter: state.formatDateAt,
        valueFormatter: (value) => compactNumber(value.round()),
      ),
      const SizedBox(height: 12),
      InteractiveMetricChartCard(
        title: 'DAU',
        current: compactNumber(product.dau),
        points: points((item) => item.dau.toDouble()),
        dateFormatter: state.formatDateAt,
        valueFormatter: (value) => compactNumber(value.round()),
      ),
      const SizedBox(height: 12),
      InteractiveMetricChartCard(
        title: 'MAU',
        current: compactNumber(product.mau),
        points: points((item) => item.mau.toDouble()),
        dateFormatter: state.formatDateAt,
        valueFormatter: (value) => compactNumber(value.round()),
      ),
      const SizedBox(height: 12),
      InteractiveMetricChartCard(
        title: 'Выручка в месяц',
        current: money(product.monthlyRevenue),
        points: points((item) => item.revenue),
        dateFormatter: state.formatDateAt,
        valueFormatter: money,
      ),
      const SizedBox(height: 12),
      InteractiveMetricChartCard(
        title: 'Рейтинг',
        current: product.rating.toStringAsFixed(2),
        points: points((item) => item.rating),
        dateFormatter: state.formatDateAt,
        valueFormatter: (value) => value.toStringAsFixed(2),
      ),
      const SizedBox(height: 12),
      InteractiveMetricChartCard(
        title: 'Retention 30d',
        current: percent(product.retention30d),
        points: points((item) => item.retention30d),
        dateFormatter: state.formatDateAt,
        valueFormatter: percent,
      ),
      const SizedBox(height: 12),
      InteractiveMetricChartCard(
        title: 'Churn',
        current: percent(product.churnRate),
        points: points((item) => item.churnRate),
        dateFormatter: state.formatDateAt,
        valueFormatter: percent,
      ),
      const SizedBox(height: 12),
      InteractiveMetricChartCard(
        title: 'Требуемая мощность',
        current: state.productComputeDemand(product).toStringAsFixed(1),
        points: points((item) => item.requiredCompute),
        dateFormatter: state.formatDateAt,
        valueFormatter: (value) => '${value.toStringAsFixed(1)} CU',
      ),
      if (history.isEmpty) ...[
        const SizedBox(height: 12),
        const AppCard(
          child: AppText('История появится после смены игрового дня.'),
        ),
      ],
    ]);
  }

  Widget _infrastructure(Product product) {
    final state = widget.controller.state;
    final blueprint = GameCatalog.blueprintById(product.blueprintId);
    final required = state.productComputeDemand(product);
    final allocated = state.allocatedComputeFor(product.id);
    final prepared = state.preparedComputeUnits;
    return _list([
      SectionHeader(
        title: 'Инфраструктура',
        subtitle: blueprint.name,
        hintTitle: 'Почему сайт не SaaS',
        hintBody:
            'Здесь показывается реальный blueprint продукта, а не техническая enum-категория. Сайт компании остаётся сайтом, даже если внутри экономики использует web/SaaS-механику.',
      ),
      const SizedBox(height: 12),
      if (state.usingOwnedInfrastructure)
        AppCard(
          key: const Key('workspace-service-routing'),
          hintTitle: 'Раздельная инфраструктура по сервисам',
          hintBody:
              'API/приложение, данные и AI/compute можно направить на разные ЦОД. Мощность делится только между продуктами, использующими ту же площадку и тот же тип сервиса.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Маршрутизация сервисов',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              ...const <InfrastructureService>[
                InfrastructureService.appApi,
                InfrastructureService.dataStorage,
                InfrastructureService.aiCompute,
              ].map((service) {
                final route = state.dataCenterRouteFor(product.id, service);
                final serviceLabel = switch (service) {
                  InfrastructureService.sharedLegacy => 'Legacy shared',
                  InfrastructureService.appApi =>
                    'API / приложение / RAM / сеть',
                  InfrastructureService.dataStorage => 'Данные / storage',
                  InfrastructureService.aiCompute =>
                    'Compute / AI / backend jobs',
                };
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField<String>(
                    key: Key('service-route-${product.id}-${service.name}'),
                    initialValue: route,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: serviceLabel),
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: '',
                        child: AppText(
                          'Арендная серверная • ${state.serverRoom.name}',
                        ),
                      ),
                      ...state.ownedDataCenters.map(
                        (site) => DropdownMenuItem<String>(
                          value: site.id,
                          child: AppText(state.ownedDataCenterLabel(site)),
                        ),
                      ),
                    ],
                    onChanged: (siteId) {
                      if (siteId == null) {
                        return;
                      }
                      widget.controller.dispatch(
                        AssignProductInfrastructureService(
                          productId: product.id,
                          service: service,
                          dataCenterSiteId: siteId,
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      if (state.usingOwnedInfrastructure) const SizedBox(height: 12),
      AppCard(
        hintTitle: 'Активная и подготовленная мощность',
        hintBody:
            'На арендном hosting работают мощности тарифа. Купленные серверы находятся в резерве и начнут учитываться только после явной миграции на собственную инфраструктуру.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Тип продукта', blueprint.name),
            _row('Активный hosting', state.hostingPlan.name),
            _row(
              'Активная мощность',
              '${state.totalComputeUnits.toStringAsFixed(0)} CU',
            ),
            _row('Подготовлено серверов', prepared.toStringAsFixed(0)),
            _row('Выделено compute', '${allocated.toStringAsFixed(1)} CU'),
            _row('Требуется compute', '${required.toStringAsFixed(1)} CU'),
            _row(
              'RAM продукта',
              '${state.productMemoryDemand(product).round()} / ${state.allocatedMemoryFor(product.id).round()} GB',
            ),
            _row(
              'Storage продукта',
              '${state.productStorageDemand(product).round()} / ${state.allocatedStorageFor(product.id).round()} GB',
            ),
            const SizedBox(height: 8),
            AppText(
              'Формула спроса: базовая нагрузка + пользователи / 1000 × ${blueprint.computePerThousandUsers.toStringAsFixed(1)} × сложность стека. Поэтому требование растёт вместе с аудиторией.',
            ),
            const SizedBox(height: 12),
            AppText(
              'Доля общей мощности: ${product.allocatedCapacityPercent.round()}%',
            ),
            Slider(
              value: product.allocatedCapacityPercent.clamp(0, 100).toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (value) => widget.controller.dispatch(
                SetProductAllocation(productId: product.id, percent: value),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (!state.usingOwnedInfrastructure && prepared > 0)
        AppCard(
          child: Row(
            children: [
              const Icon(Icons.inventory_2, color: AppColors.yellow),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  '${prepared.toStringAsFixed(0)} CU куплено, но пока не участвует в расчёте: активен арендный hosting.',
                ),
              ),
            ],
          ),
        ),
    ]);
  }

  Future<void> _showRenameProduct(Product product) async {
    final controller = TextEditingController(text: product.name);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText('Изменить название продукта'),
        content: TextField(
          key: const Key('rename-product-field'),
          controller: controller,
          autofocus: true,
          maxLength: 32,
          decoration: InputDecoration(
            labelText: trContext(dialogContext, 'Название'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const AppText('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const AppText('Сохранить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && mounted) {
      widget.controller.dispatch(
        RenameProduct(productId: product.id, name: name),
      );
    }
  }

  Future<void> _confirmProductSale(Product product) async {
    final state = widget.controller.state;
    final buyer = state.productBuyerFor(product);
    final value = state.productSaleValue(product);
    final fresh =
        product.users <= 100 &&
        product.mau <= 50 &&
        product.monthlyRevenue <= 0 &&
        state.releasedUpdateCount(product) <= 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText('Продать продукт?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('${buyer.companyName} готова купить ${product.name}.'),
            const SizedBox(height: 10),
            AppText(
              'Цена сделки: ${money(value)}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            AppText(
              fresh
                  ? 'Продукт без заметной аудитории оценивается от 30% базовой стоимости разработки.'
                  : 'Цена учитывает пользователей, выручку, выпущенные обновления и показатели относительно конкурентов.',
            ),
            const SizedBox(height: 8),
            const AppText(
              'После сделки продукт уйдёт из портфеля, а его команда освободится.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const AppText('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const AppText('Продать'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && mounted) {
      widget.controller.dispatch(SellProduct(product.id));
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  String _coherenceMeaning(double value) {
    if (value >= 0.70) {
      return 'стек хорошо сочетается';
    }
    if (value >= 0.45) {
      return 'есть спорные сочетания и лишняя поддержка';
    }
    return 'стек конфликтный, разработка будет заметно медленнее';
  }

  String _capacityMeaning(double value) {
    if (value < 0.5) {
      return 'Проект почти стоит: нужна подходящая команда.';
    }
    if (value < 1.5) {
      return 'Скорость небольшой команды или одного сильного специалиста.';
    }
    if (value < 3.5) {
      return 'Рабочая продуктовая команда.';
    }
    return 'Высокая скорость; проверьте, не растёт ли workload.';
  }

  String _workName(String featureId) {
    if (featureId.startsWith('__bug_')) {
      return 'Исправление бага';
    }
    if (featureId.startsWith('__technology_')) {
      final id = featureId.substring('__technology_'.length);
      final matches = GameCatalog.technologies.where((item) => item.id == id);
      return matches.isEmpty ? 'Расширение стека' : matches.first.name;
    }
    if (featureId.startsWith('__improvement_')) {
      return 'Техническое улучшение';
    }
    return GameCatalog.featureById(featureId).name;
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: AppText(label)),
        const SizedBox(width: 12),
        Flexible(
          child: AppText(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

class _SectionRail extends StatelessWidget {
  const _SectionRail({required this.selected, required this.onSelected});

  final _WorkspaceSection selected;
  final ValueChanged<_WorkspaceSection> onSelected;

  @override
  Widget build(BuildContext context) {
    const data = <(_WorkspaceSection, IconData, String)>[
      (_WorkspaceSection.overview, Icons.dashboard_outlined, 'Обзор'),
      (_WorkspaceSection.development, Icons.code, 'Разработка'),
      (_WorkspaceSection.team, Icons.groups_outlined, 'Команда'),
      (_WorkspaceSection.marketing, Icons.campaign_outlined, 'Реклама'),
      (_WorkspaceSection.monetization, Icons.payments_outlined, 'Монетизация'),
      (_WorkspaceSection.metrics, Icons.show_chart, 'Метрики'),
      (_WorkspaceSection.infrastructure, Icons.dns_outlined, 'Инфра'),
    ];
    return SizedBox(
      height: 66,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < data.length; index += 1) ...[
              if (index > 0) const SizedBox(width: 7),
              Builder(
                builder: (context) {
                  final item = data[index];
                  final active = item.$1 == selected;
                  return Material(
                    color: active
                        ? AppColors.primary.withAlpha(24)
                        : AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                      side: BorderSide(
                        color: active ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: InkWell(
                      key: Key('workspace-section-${item.$1.name}'),
                      borderRadius: BorderRadius.circular(13),
                      onTap: () => onSelected(item.$1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.$2, size: 18),
                            const SizedBox(height: 2),
                            AppText(
                              item.$3,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pair {
  const _Pair(this.label, this.value);
  final String label;
  final String value;
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.items});
  final List<_Pair> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              width: 142,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 3),
                  AppText(
                    item.value,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
