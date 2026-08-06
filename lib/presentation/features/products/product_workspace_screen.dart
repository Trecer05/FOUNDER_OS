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
import '../../../domain/entities/product_evolution_models.dart';
import '../../../domain/explainability/staffing_deficit_resolver.dart';
import '../../../domain/simulation/product_projection_cache.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';
import 'product_detail_screen.dart';
import '../../../application/localization/app_text.dart';
import '../../shared/widgets/scoped_listenable_builder.dart';
import '../../../application/localization/app_localizer.dart';

enum _WorkspaceSection {
  overview,
  development,
  team,
  marketing,
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
            tooltip: trContext(context, 'Все расширенные инструменты'),
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductDetailScreen(
                  controller: widget.controller,
                  productId: product.id,
                ),
              ),
            ),
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
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: KeyedSubtree(
                    key: ValueKey<_WorkspaceSection>(_section),
                    child: _buildSection(current),
                  ),
                );
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
            'Шесть разделов отделяют разработку, команду, рекламу, метрики и инфраструктуру. Шестерёнка сверху открывает редкие расширенные настройки.',
      ),
      const SizedBox(height: 12),
      AppCard(
        hintTitle: 'Совместимость стека',
        hintBody:
            'Coherence — это совместимость framework, языков, технологий и функций. 100% означает естественный стек; низкое значение добавляет часы, стоимость поддержки и риск дефектов.',
        hintBullets: const [
          '70–100%: стек понятный и поддерживаемый.',
          '45–69%: есть спорные сочетания и лишняя сложность.',
          'Ниже 45%: лучше сменить framework или убрать часть стека.',
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
    final capacity = state.productDevelopmentCapacity(product.id);
    final activeWork = state.activeFeatureDevelopmentFor(product.id);
    return _list([
      SectionHeader(
        title: 'Разработка',
        subtitle:
            '${phase.name} • ${(product.developmentProgress * 100).round()}%',
        hintTitle: 'Development capacity',
        hintBody:
            'Development capacity — эффективная скорость команды в FTE. 1,0 FTE примерно равен одному подходящему специалисту на полной занятости. Значение учитывает навыки, роль, языки, долю времени, мораль и AI-помощь.',
      ),
      const SizedBox(height: 12),
      AppCard(
        hintTitle: 'Почему capacity меняется',
        hintBody:
            'Capacity не является отдельным ресурсом или серверной мощностью. Это производительность людей. При работе сотрудника над несколькими проектами его вклад делится между ними, а перегрузка снижает мораль.',
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
                  ? 'Нет'
                  : '${_workName(activeWork.featureId)} ${(activeWork.progress * 100).round()}%',
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
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: AppText('${option.name} • уровень ${level + 1}'),
                  subtitle: AppText(
                    'Только время команды; отдельного списания денег нет.',
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
                    child: const AppText('Начать'),
                  ),
                );
              }),
            ],
          ),
        ),
    ]);
  }

  Widget _team(Product product) {
    final state = widget.controller.state;
    final team = state.employeesForProduct(product.id);
    final deficits = StaffingDeficitResolver.forProduct(state, product);
    final hasHr = state.employees.any((employee) => employee.isHr);
    final requiredRoles = deficits.map((item) => item.roleId).toSet();
    final candidates = state.candidates.toList(growable: false)
      ..sort((left, right) {
        final leftFit = requiredRoles.contains(left.role.name) ? 1 : 0;
        final rightFit = requiredRoles.contains(right.role.name) ? 1 : 0;
        if (leftFit != rightFit) return rightFit.compareTo(leftFit);
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
    return _list([
      SectionHeader(
        title: 'Команда проекта',
        subtitle: '${team.length} назначено • дефицитов ${deficits.length}',
        hintTitle: 'Несколько проектов',
        hintBody:
            'Один сотрудник может участвовать в нескольких проектах. Его рабочее время делится между назначениями. Чем больше параллельных проектов, тем выше workload и риск выгорания.',
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
                    'Автоподбор команды',
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
              'Игра сама подберёт доступных специалистов под дефициты проекта. За срочный подбор зарплата и signing bonus каждого нанятого сотрудника будут на 25% выше.',
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
                      ? 'Критических дефицитов нет'
                      : hasHr
                      ? 'Нанять команду под проект'
                      : 'Сначала наймите HR',
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (deficits.isNotEmpty)
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Кого не хватает',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              ...deficits
                  .take(5)
                  .map(
                    (deficit) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_search),
                      title: AppText(
                        '${deficit.roleName} ×${deficit.missingCount}',
                      ),
                      subtitle: AppText(
                        '${deficit.effect}${deficit.languageName == null ? '' : ' • ${deficit.languageName}'}',
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
            const AppText(
              'Подходящие кандидаты',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            if (candidates.isEmpty)
              const AppText('На рынке сейчас нет кандидатов.')
            else
              ...candidates.take(8).map((candidate) {
                final roleNeeded = requiredRoles.contains(candidate.role.name);
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
                    '${candidateRoleName(candidate)} • skill ${candidate.skill}${roleNeeded ? ' • нужная роль' : ''}${languageMatch.isEmpty ? '' : ' • ${languageMatch.join(', ')}'}',
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
      const SizedBox(height: 12),
      if (team.isNotEmpty)
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
                    '${employeeRoleName(employee)} • ${allocation.round()}% времени • workload ${employee.workload}/100 • morale ${employee.morale}/100',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'vacation') {
                        widget.controller.dispatch(
                          SendEmployeeOnVacation(employee.id),
                        );
                      } else if (value == 'bonus') {
                        widget.controller.dispatch(
                          GiveWellbeingBonus(employee.id),
                        );
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'vacation',
                        child: AppText('Отправить в отпуск'),
                      ),
                      PopupMenuItem(
                        value: 'bonus',
                        child: AppText('Корпоративный бонус'),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
    ]);
  }

  Widget _marketing(Product product) {
    final state = widget.controller.state;
    final agencies = ProductStrategyCatalog.agencies;
    final channels = ProductStrategyCatalog.channels
        .where((item) => item.bestForCategories.contains(product.category))
        .toList(growable: false);
    _agencyId ??= agencies.first.id;
    _channelId ??= channels.isEmpty
        ? ProductStrategyCatalog.channels.first.id
        : channels.first.id;
    final campaigns = state.activeCampaignsFor(product.id);
    return _list([
      SectionHeader(
        title: 'Реклама и рост',
        subtitle: 'Активных кампаний: ${campaigns.length}/2',
        hintTitle: 'Отдельный рекламный раздел',
        hintBody:
            'Кампании сгруппированы отдельно от разработки. Перед запуском видны агентство, канал, бюджет и прогноз пользователей.',
      ),
      const SizedBox(height: 12),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _agencyId,
              decoration: InputDecoration(
                labelText: trContext(context, 'Агентство'),
              ),
              items: agencies
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: AppText(item.name),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _agencyId = value),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _channelId,
              decoration: InputDecoration(
                labelText: trContext(context, 'Канал'),
              ),
              items:
                  (channels.isEmpty
                          ? ProductStrategyCatalog.channels
                          : channels)
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: AppText(item.name),
                        ),
                      )
                      .toList(growable: false),
              onChanged: (value) => setState(() => _channelId = value),
            ),
            const SizedBox(height: 12),
            AppText('Бюджет: ${money(_campaignBudget)}'),
            Slider(
              value: _campaignBudget,
              min: 25000,
              max: 1000000,
              divisions: 39,
              label: money(_campaignBudget),
              onChanged: (value) => setState(() => _campaignBudget = value),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    product.stage == ProductStage.live &&
                        campaigns.length < 2 &&
                        state.cash >= _campaignBudget
                    ? () => widget.controller.dispatch(
                        StartAdvertisingCampaign(
                          productId: product.id,
                          agencyId: _agencyId!,
                          channelId: _channelId!,
                          budget: _campaignBudget,
                        ),
                      )
                    : null,
                icon: const Icon(Icons.campaign),
                label: const AppText('Запустить кампанию на 7 дней'),
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
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value:
                      ((state.simulationMinutes - campaign.startedAtMinutes) /
                              math.max(
                                1,
                                campaign.endsAtMinutes -
                                    campaign.startedAtMinutes,
                              ))
                          .clamp(0, 1)
                          .toDouble(),
                ),
                const SizedBox(height: 8),
                AppText(
                  'Прогноз ${campaign.projectedUsersLow}–${campaign.projectedUsersHigh} пользователей • ${money(campaign.budget)}',
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
    return _list([
      SectionHeader(
        title: 'Метрики',
        subtitle: 'Период: ${_range.label}',
        hintTitle: 'Период графиков',
        hintBody:
            'Фильтр меняет только диапазон отображения. История сохраняется ежедневно: пользователи, DAU, MAU, выручка и требуемая compute-мощность.',
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
      _MetricChartCard(
        title: 'Пользователи',
        current: compactNumber(product.users),
        points: history.map((item) => item.users.toDouble()).toList(),
      ),
      const SizedBox(height: 12),
      _MetricChartCard(
        title: 'Выручка в месяц',
        current: money(product.monthlyRevenue),
        points: history.map((item) => item.revenue).toList(),
      ),
      const SizedBox(height: 12),
      _MetricChartCard(
        title: 'Требуемая мощность',
        current: state.productComputeDemand(product).toStringAsFixed(1),
        points: history.map((item) => item.requiredCompute).toList(),
      ),
      if (history.isEmpty) ...[
        const SizedBox(height: 12),
        const AppCard(
          child: AppText(
            'История появится после смены игрового дня. Текущие значения уже учитываются.',
          ),
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
              state.totalComputeUnits.toStringAsFixed(0),
            ),
            _row('Подготовлено серверов', prepared.toStringAsFixed(0)),
            _row('Выделено продукту', allocated.toStringAsFixed(1)),
            _row('Требуется сейчас', required.toStringAsFixed(1)),
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
                  '${prepared.toStringAsFixed(0)} compute units куплено, но пока не участвует в расчёте: активен арендный hosting.',
                ),
              ),
            ],
          ),
        ),
    ]);
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

class _MetricChartCard extends StatelessWidget {
  const _MetricChartCard({
    required this.title,
    required this.current,
    required this.points,
  });

  final String title;
  final String current;
  final List<double> points;

  @override
  Widget build(BuildContext context) {
    final usable = points.length >= 2 ? points : <double>[0, ...points];
    return RepaintBoundary(
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                AppText(current),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              width: double.infinity,
              child: CustomPaint(painter: _LinePainter(usable)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.points);
  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final minValue = points.reduce(math.min);
    final maxValue = points.reduce(math.max);
    final range = math.max(1, maxValue - minValue);
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var index = 1; index < 4; index += 1) {
      final y = size.height * index / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final path = Path();
    for (var index = 0; index < points.length; index += 1) {
      final x = points.length == 1
          ? 0.0
          : size.width * index / (points.length - 1);
      final normalized = (points[index] - minValue) / range;
      final y = size.height - normalized * size.height;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    if (identical(oldDelegate.points, points)) {
      return false;
    }
    if (oldDelegate.points.length != points.length) {
      return true;
    }
    for (var index = 0; index < points.length; index += 1) {
      if (oldDelegate.points[index] != points[index]) {
        return true;
      }
    }
    return false;
  }
}
