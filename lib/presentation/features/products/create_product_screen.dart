import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/catalog/product_strategy_catalog.dart';
import '../../../domain/catalog/product_evolution_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/product_strategy_models.dart';
import '../../../domain/entities/v9_models.dart';
import '../../../domain/entities/v17_models.dart';
import '../research/research_screen.dart';
import '../../../domain/explainability/language_limit_resolver.dart';
import '../../../domain/explainability/product_configuration_resolver.dart';
import '../../../domain/simulation/product_estimator.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/technology_selector_panel.dart';
import '../../../domain/simulation/product_projection_cache.dart';
import '../../../application/localization/app_text.dart';
import '../../../application/localization/app_localizer.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _nameController = TextEditingController();
  int _step = 0;
  String _blueprintId = GameCatalog.productBlueprints.first.id;
  late String _frameworkId;
  final Set<String> _languageIds = <String>{};
  final Set<String> _technologyIds = <String>{};
  final Set<String> _featureIds = <String>{};
  late MonetizationModel _monetization;

  static const _stepTitles = <String>[
    'Масштаб продукта',
    'Название и фреймворк',
    'Языки',
    'Технологии',
    'Функции',
    'Монетизация',
    'Проверка проекта',
  ];

  ProductBlueprint get _blueprint => GameCatalog.blueprintById(_blueprintId);
  ProductStrategyProfile get _strategy =>
      ProductStrategyCatalog.strategyFor(_blueprintId);

  LanguageLimitExplanation get _languageLimit => LanguageLimitResolver.resolve(
    blueprintId: _blueprintId,
    frameworkId: _frameworkId,
  );

  TechnologyLimitExplanation get _technologyLimit =>
      ProductConfigurationResolver.technologyLimit(
        state: widget.controller.state,
        blueprintId: _blueprintId,
        frameworkId: _frameworkId,
        featureIds: _featureIds,
        selectedTechnologyIds: _technologyIds,
      );

  List<FrameworkOption> get _frameworks => GameCatalog.frameworks
      .where((item) => _strategy.allowedFrameworkIds.contains(item.id))
      .toList(growable: false);

  List<FeatureOption> get _features {
    final all = GameCatalog.features
        .where((item) => item.supportedCategories.contains(_blueprint.category))
        .toList(growable: false);
    if (_blueprintId == 'company_website') {
      return all
          .where((item) => _blueprint.expectedFeatureIds.contains(item.id))
          .toList(growable: false);
    }
    return all;
  }

  ProductProjection get _projection => ProductProjectionCache.estimate(
    blueprintId: _blueprintId,
    frameworkId: _frameworkId,
    languageIds: _languageIds.toList(growable: false),
    technologyIds: _technologyIds.toList(growable: false),
    featureIds: _featureIds.toList(growable: false),
  );

  @override
  void initState() {
    super.initState();
    _configureBlueprint(_blueprintId, notify: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _configureBlueprint(String id, {bool notify = true}) {
    void apply() {
      _blueprintId = id;
      final strategy = ProductStrategyCatalog.strategyFor(id);
      final frameworks = GameCatalog.frameworks
          .where((item) => strategy.allowedFrameworkIds.contains(item.id))
          .toList(growable: false);
      _frameworkId = frameworks.first.id;
      final frameworkProfile = ProductStrategyCatalog.frameworkProfile(
        _frameworkId,
      );
      _languageIds
        ..clear()
        ..addAll(frameworkProfile.requiredLanguageIds)
        ..addAll(strategy.recommendedLanguageIds.take(1));
      final languageLimit = LanguageLimitResolver.resolve(
        blueprintId: id,
        frameworkId: _frameworkId,
      );
      while (_languageIds.length > languageLimit.allowed) {
        _languageIds.remove(_languageIds.last);
      }
      _technologyIds
        ..clear()
        ..addAll(
          _defaultTechnologies(id).where(
            (technologyId) => widget.controller.state.researchCompleted(
              ResearchTargetKind.technology,
              technologyId,
            ),
          ),
        );
      final mandatoryTechnology =
          ProductConfigurationResolver.mandatoryTechnologyId(_frameworkId);
      if (mandatoryTechnology != null &&
          widget.controller.state.researchCompleted(
            ResearchTargetKind.technology,
            mandatoryTechnology,
          )) {
        _technologyIds.add(mandatoryTechnology);
      }
      _featureIds
        ..clear()
        ..addAll(
          GameCatalog.blueprintById(
            id,
          ).expectedFeatureIds.take(id == 'company_website' ? 3 : 2),
        );
      _monetization = strategy.allowedMonetizationModels.first;
      _nameController.text = _defaultName(id);
    }

    if (notify) {
      setState(apply);
    } else {
      apply();
    }
  }

  void _selectFramework(String id) {
    setState(() {
      _frameworkId = id;
      final profile = ProductStrategyCatalog.frameworkProfile(id);
      _languageIds.addAll(profile.requiredLanguageIds);
      final mandatoryTechnology =
          ProductConfigurationResolver.mandatoryTechnologyId(id);
      if (mandatoryTechnology != null &&
          widget.controller.state.researchCompleted(
            ResearchTargetKind.technology,
            mandatoryTechnology,
          )) {
        _technologyIds.add(mandatoryTechnology);
      }
      _technologyIds.removeWhere((technologyId) {
        final technology = GameCatalog.technologyById(technologyId);
        final availability = ProductConfigurationResolver.availability(
          frameworkId: id,
          languageIds: _languageIds,
          selectedTechnologyIds: _technologyIds,
          technology: technology,
        );
        return !availability.enabled && !availability.mandatory;
      });
      while (_languageIds.length > _languageLimit.allowed) {
        final removable = _languageIds.firstWhere(
          (language) => !profile.requiredLanguageIds.contains(language),
          orElse: () => _languageIds.last,
        );
        _languageIds.remove(removable);
      }
    });
  }

  String? get _technologyStepBlockingReason {
    final requiredResearch = _requiredTechnologyResearchMessage;
    if (requiredResearch != null) {
      return requiredResearch;
    }
    if (_technologyIds.any(
      (id) => !widget.controller.state.researchCompleted(
        ResearchTargetKind.technology,
        id,
      ),
    )) {
      return 'В проект можно добавить только исследованные технологии.';
    }
    if (_technologyIds.length > _technologyLimit.allowed) {
      return 'Выбрано ${_technologyIds.length} технологий из допустимых ${_technologyLimit.allowed}. Уберите лишние технологии.';
    }
    return null;
  }

  String? get _requiredTechnologyResearchMessage {
    final mandatoryTechnology =
        ProductConfigurationResolver.mandatoryTechnologyId(_frameworkId);
    if (mandatoryTechnology == null ||
        widget.controller.state.researchCompleted(
          ResearchTargetKind.technology,
          mandatoryTechnology,
        )) {
      return null;
    }
    final name = GameCatalog.technologyById(mandatoryTechnology).name;
    return 'Сначала исследуйте обязательную технологию в R&D: $name.';
  }

  bool get _requirementsMet {
    final frameworkProfile = ProductStrategyCatalog.frameworkProfile(
      _frameworkId,
    );
    return _nameController.text.trim().isNotEmpty &&
        _strategy.allowedFrameworkIds.contains(_frameworkId) &&
        _languageIds.isNotEmpty &&
        _languageIds.length <= _languageLimit.allowed &&
        _technologyIds.length <= _technologyLimit.allowed &&
        _requiredTechnologyResearchMessage == null &&
        _technologyIds.every(
          (id) => widget.controller.state.researchCompleted(
            ResearchTargetKind.technology,
            id,
          ),
        ) &&
        frameworkProfile.requiredLanguageIds.every(_languageIds.contains) &&
        _featureIds.isNotEmpty &&
        widget.controller.state.investorAgreements.length >=
            _strategy.requiredInvestorCount &&
        widget.controller.state.cash >= _projection.developmentCost;
  }

  String? get _stepBlockingReason {
    final frameworkProfile = ProductStrategyCatalog.frameworkProfile(
      _frameworkId,
    );
    return switch (_step) {
      0 => null,
      1 =>
        _nameController.text.trim().isEmpty
            ? 'Введите название проекта.'
            : !_strategy.allowedFrameworkIds.contains(_frameworkId)
            ? 'Выберите фреймворк из списка этого проекта.'
            : null,
      2 =>
        _languageIds.isEmpty
            ? 'Выберите хотя бы один язык.'
            : _languageIds.length > _languageLimit.allowed
            ? 'Можно выбрать максимум ${_languageLimit.allowed}: лимит рассчитан из масштаба и фреймворка.'
            : frameworkProfile.requiredLanguageIds
                  .where((id) => !_languageIds.contains(id))
                  .isNotEmpty
            ? 'Добавьте обязательные языки выбранного фреймворка.'
            : null,
      3 => _technologyStepBlockingReason,
      4 =>
        _featureIds.isEmpty
            ? 'В первом релизе нужна хотя бы одна функция.'
            : null,
      5 =>
        !_strategy.allowedMonetizationModels.contains(_monetization)
            ? 'Выберите доступную модель монетизации.'
            : null,
      _ => _requirementsMet ? null : 'Исправьте блокирующие требования выше.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final projection = _projection;
    return Scaffold(
      appBar: AppBar(
        title: AppText('Новый проект • ${_step + 1}/${_stepTitles.length}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (_step + 1) / _stepTitles.length,
                ),
                const SizedBox(height: 8),
                AppText(
                  _stepTitles[_step],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_stepBlockingReason != null) ...[
                  const SizedBox(height: 5),
                  AppText(
                    _stepBlockingReason!,
                    style: const TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: KeyedSubtree(
                key: ValueKey<int>(_step),
                child: _buildStep(context, projection),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _step -= 1),
                    icon: const Icon(Icons.arrow_back),
                    label: const AppText('Назад'),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _step < _stepTitles.length - 1
                    ? FilledButton.icon(
                        key: const Key('product-wizard-next'),
                        onPressed: _stepBlockingReason == null
                            ? () => setState(() => _step += 1)
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const AppText('Далее'),
                      )
                    : FilledButton.icon(
                        key: const Key('create-configured-product'),
                        onPressed: _requirementsMet ? _create : null,
                        icon: const Icon(Icons.rocket_launch_outlined),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AppText('Запустить разработку'),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, ProductProjection projection) =>
      switch (_step) {
        0 => _scopeStep(context),
        1 => _frameworkStep(context),
        2 => _languagesStep(context),
        3 => _technologiesStep(context),
        4 => _featuresStep(context),
        5 => _monetizationStep(context),
        _ => _summaryStep(context, projection),
      };

  Widget _scopeStep(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        const SectionHeader(
          title: 'Что именно строим',
          subtitle:
              'Масштаб определяет часы, команду, риски и требования к инвесторам.',
        ),
        const SizedBox(height: 10),
        ...GameCatalog.productBlueprints.map((blueprint) {
          final strategy = ProductStrategyCatalog.strategyFor(blueprint.id);
          final selected = blueprint.id == _blueprintId;
          final investorsReady =
              widget.controller.state.investorAgreements.length >=
              strategy.requiredInvestorCount;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: () => _configureBlueprint(blueprint.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText(
                          blueprint.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _ScopeBadge(strategy.scope),
                    ],
                  ),
                  const SizedBox(height: 7),
                  AppText(strategy.shortDescription),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _InfoChip('${strategy.baseHours.round()} базовых часов'),
                      _InfoChip(
                        'Команда ${strategy.minimumTeamSize}–${strategy.maximumEfficientTeamSize}',
                      ),
                      _InfoChip(
                        'Разовая настройка ${money(strategy.setupCost)}',
                      ),
                      if (strategy.requiredInvestorCount > 0)
                        _InfoChip(
                          '${investorsReady ? '✓' : 'Нужно'} инвесторов: ${strategy.requiredInvestorCount}',
                          warning: !investorsReady,
                        ),
                      if (strategy.contractsUnlock)
                        const _InfoChip('Открывает контракты'),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _frameworkStep(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: trContext(context, 'Название проекта'),
            prefixIcon: Icon(Icons.drive_file_rename_outline),
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Фреймворк',
          subtitle:
              'Выбор меняет сроки, стоимость эксплуатации и набор обязательных языков.',
        ),
        const SizedBox(height: 10),
        ..._frameworks.map((framework) {
          final profile = ProductStrategyCatalog.frameworkProfile(framework.id);
          final selected = framework.id == _frameworkId;
          final languageLimit = LanguageLimitResolver.resolve(
            blueprintId: _blueprintId,
            frameworkId: framework.id,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: () => _selectFramework(framework.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText(
                          framework.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AppText(profile.summary),
                  const SizedBox(height: 9),
                  _ProsCons(
                    strengths: profile.strengths,
                    weaknesses: profile.weaknesses,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    'Языковые слоты: ${languageLimit.allowed} • база ${languageLimit.base} • влияние framework ${languageLimit.frameworkAdjustment >= 0 ? '+' : ''}${languageLimit.frameworkAdjustment}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  AppText(
                    'Обязательные языки: ${profile.requiredLanguageIds.isEmpty ? 'нет' : profile.requiredLanguageIds.map((id) => GameCatalog.languageById(id).name).join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  AppText(
                    'Dev speed ${_signed(framework.developmentSpeedDelta)} • OPEX ${money(framework.monthlyCost)}/мес.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  AppText(
                    'С текущим roadmap: ${_projectionForFramework(framework.id).developmentHours.round()} ч. • setup ${money(_projectionForFramework(framework.id).developmentCost)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _languagesStep(BuildContext context) {
    final required = ProductStrategyCatalog.frameworkProfile(
      _frameworkId,
    ).requiredLanguageIds;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        SectionHeader(
          title: 'Языки проекта',
          subtitle:
              'Можно выбрать ${_languageLimit.allowed}. База ${_languageLimit.base}, фреймворк ${_languageLimit.frameworkAdjustment >= 0 ? '+' : ''}${_languageLimit.frameworkAdjustment}, обязательных ${_languageLimit.requiredLanguages}.',
          hintTitle: 'Почему есть лимит языков',
          hintBody: _languageLimit.reasons.join(' '),
        ),
        const SizedBox(height: 10),
        ...GameCatalog.languages.map((language) {
          final profile = ProductStrategyCatalog.languageProfile(language.id);
          final selected = _languageIds.contains(language.id);
          final mandatory = required.contains(language.id);
          final candidates = widget.controller.state.candidates
              .where((item) => item.languageIds.contains(language.id))
              .length;
          final recommended = _strategy.recommendedLanguageIds.contains(
            language.id,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: () {
                setState(() {
                  if (selected && !mandatory) {
                    _languageIds.remove(language.id);
                  } else if (!selected &&
                      _languageIds.length < _languageLimit.allowed) {
                    _languageIds.add(language.id);
                  }
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: selected,
                        onChanged: mandatory
                            ? null
                            : (_) {
                                setState(() {
                                  if (selected) {
                                    _languageIds.remove(language.id);
                                  } else if (_languageIds.length <
                                      _languageLimit.allowed) {
                                    _languageIds.add(language.id);
                                  }
                                });
                              },
                      ),
                      Expanded(
                        child: AppText(
                          language.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (mandatory) const _InfoChip('Обязателен'),
                      if (!mandatory && recommended)
                        const _InfoChip('Рекомендуется'),
                    ],
                  ),
                  AppText(profile.summary),
                  const SizedBox(height: 8),
                  _ProsCons(
                    strengths: profile.strengths,
                    weaknesses: profile.weaknesses,
                  ),
                  const SizedBox(height: 7),
                  AppText(
                    'Кандидатов на рынке: $candidates • доступность ${language.talentAvailability}/100 • сложность ×${profile.complexityMultiplier.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _technologiesStep(BuildContext context) {
    return TechnologySelectorPanel(
      state: widget.controller.state,
      blueprintId: _blueprintId,
      frameworkId: _frameworkId,
      languageIds: _languageIds,
      featureIds: _featureIds,
      selectedTechnologyIds: _technologyIds,
      onOpenResearch: () => Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ResearchScreen(controller: widget.controller),
        ),
      ),
      onChanged: (technologyId, selected) {
        setState(() {
          if (selected) {
            _technologyIds.add(technologyId);
          } else {
            _technologyIds.remove(technologyId);
          }
        });
      },
    );
  }

  Widget _featuresStep(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        const SectionHeader(
          title: 'Что войдёт в первый релиз',
          subtitle:
              'Функции не покупаются. Они добавляют рабочие часы, которые оплачиваются через зарплаты команды.',
        ),
        const SizedBox(height: 10),
        ..._features.map((feature) {
          final selected = _featureIds.contains(feature.id);
          final hours = math.max(20, feature.developmentCost / 520).round();
          final expected = _blueprint.expectedFeatureIds.contains(feature.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: CheckboxListTile(
                value: selected,
                title: AppText(feature.name),
                secondary: expected
                    ? const Icon(Icons.star_outline, color: AppColors.primary)
                    : null,
                subtitle: AppText(
                  '${feature.description}\n≈ $hours рабочих часов • retention +${(feature.retentionDelta * 100).toStringAsFixed(1)} п.п. • compute ×${feature.computeMultiplier.toStringAsFixed(2)}',
                ),
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      _featureIds.add(feature.id);
                    } else if (_featureIds.length > 1) {
                      _featureIds.remove(feature.id);
                    }
                  });
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _monetizationStep(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        const SectionHeader(
          title: 'Монетизация первого релиза',
          subtitle:
              'Для каждого типа продукта доступны только реалистичные модели.',
        ),
        const SizedBox(height: 10),
        ..._strategy.allowedMonetizationModels.map((model) {
          final selected = model == _monetization;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: () => setState(() => _monetization = model),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? AppColors.primary : AppColors.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          monetizationName(model),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        AppText(_monetizationDescription(model)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  List<String> get _selectedLanguageNames => _languageIds
      .map((id) => GameCatalog.languageById(id).name)
      .toList(growable: false);

  List<String> get _selectedTechnologyNames => _technologyIds
      .map((id) => GameCatalog.technologyById(id).name)
      .toList(growable: false);

  int get _requiredHeadcount => ProductEvolutionCatalog.roleRequirements(
    _blueprint.category,
  ).fold<int>(0, (sum, item) => sum + item.minimumCount);

  String get _requiredTeamSummary {
    final requirements = ProductEvolutionCatalog.roleRequirements(
      _blueprint.category,
    );
    if (requirements.isEmpty) {
      return 'Без обязательных ролей';
    }
    return requirements
        .map((item) => '${item.minimumCount}× ${roleName(item.role)}')
        .join(' • ');
  }

  double _averageCandidateSalary(EmployeeRole role) {
    final roleSalaries = widget.controller.state.candidates
        .where((candidate) => candidate.role == role && !candidate.isHr)
        .map((candidate) => candidate.salary)
        .toList(growable: false);
    if (roleSalaries.isNotEmpty) {
      return roleSalaries.reduce((a, b) => a + b) / roleSalaries.length;
    }
    final allSalaries = widget.controller.state.candidates
        .where((candidate) => !candidate.isHr)
        .map((candidate) => candidate.salary)
        .toList(growable: false);
    if (allSalaries.isEmpty) {
      return 0;
    }
    return allSalaries.reduce((a, b) => a + b) / allSalaries.length;
  }

  double _estimatedDevelopmentMonths(ProductProjection projection) {
    final headcount = math.max(1, _requiredHeadcount);
    final months = projection.developmentHours / (headcount * 8 * 22);
    return math.max(0.25, months).toDouble();
  }

  double _estimatedDevelopmentPayroll(ProductProjection projection) {
    final requirements = ProductEvolutionCatalog.roleRequirements(
      _blueprint.category,
    );
    final monthlyPayroll = requirements.fold<double>(
      0,
      (sum, item) =>
          sum + _averageCandidateSalary(item.role) * item.minimumCount,
    );
    return monthlyPayroll * _estimatedDevelopmentMonths(projection);
  }

  double _estimatedDevelopmentCompute(ProductProjection projection) =>
      math.max(1, 28 * projection.computeMultiplier).toDouble();

  Widget _summaryStep(BuildContext context, ProductProjection projection) {
    final optimisticDays =
        projection.developmentHours /
        math.max(1, _strategy.optimalTeamSize) /
        8;
    final currentInvestors = widget.controller.state.investorAgreements.length;
    final frameworkProfile = ProductStrategyCatalog.frameworkProfile(
      _frameworkId,
    );
    final missingFrameworkLanguages = frameworkProfile.requiredLanguageIds
        .where((id) => !_languageIds.contains(id))
        .toList(growable: false);
    final languageNames = _selectedLanguageNames;
    final technologyNames = _selectedTechnologyNames;
    final estimatedMonths = _estimatedDevelopmentMonths(projection);
    final estimatedPayroll = _estimatedDevelopmentPayroll(projection);
    final estimatedCompute = _estimatedDevelopmentCompute(projection);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        SectionHeader(
          title: _nameController.text.trim().isEmpty
              ? _blueprint.name
              : _nameController.text.trim(),
          subtitle:
              '${_blueprint.name} • ${GameCatalog.frameworkById(_frameworkId).name}',
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            children: [
              _SummaryRow(
                'Разовая настройка',
                money(projection.developmentCost),
                supporting: 'Списывается один раз при запуске проекта.',
              ),
              _SummaryRow(
                'Ориентировочная стоимость разработки',
                '≈ ${money(estimatedPayroll)}',
                supporting:
                    'По средним зарплатам $_requiredHeadcount требуемых специалистов • ≈ ${estimatedMonths.toStringAsFixed(1)} мес.',
              ),
              _SummaryRow(
                'Мощность инфраструктуры',
                '≈ ${estimatedCompute.ceil()} CU на разработке',
                supporting:
                    'После релиза потребность растёт вместе с пользователями • множитель стека ×${projection.computeMultiplier.toStringAsFixed(2)}.',
              ),
              _SummaryRow(
                'Объём',
                '${projection.developmentHours.round()} рабочих часов',
              ),
              _SummaryRow(
                'Ориентир срока',
                '≈ ${optimisticDays.ceil()} рабочих дней',
                supporting:
                    'При эффективной команде из ${_strategy.optimalTeamSize} специалистов.',
              ),
              _SummaryRow(
                'Совместимость стека',
                '${(projection.stackCoherence * 100).round()}% — ${projection.stackCoherence >= 0.70
                    ? 'хорошо сочетается'
                    : projection.stackCoherence >= 0.45
                    ? 'есть спорные сочетания'
                    : 'конфликтный стек'}',
              ),
              _SummaryRow(
                'Языки',
                languageNames.isEmpty ? 'Не выбраны' : languageNames.join(', '),
                supporting:
                    'Выбрано ${_languageIds.length} из допустимых ${_languageLimit.allowed}.',
              ),
              _SummaryRow(
                'Технологии',
                technologyNames.isEmpty
                    ? 'Не выбраны'
                    : technologyNames.join(', '),
                supporting:
                    'Выбрано ${_technologyIds.length} из допустимых ${_technologyLimit.allowed}.',
              ),
              _SummaryRow('Нужные специалисты', _requiredTeamSummary),
              _SummaryRow(
                'Инвесторы',
                '$currentInvestors/${_strategy.requiredInvestorCount}',
              ),
              _SummaryRow(
                'Монетизация',
                monetizationName(_monetization),
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (projection.warnings.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Риски конфигурации',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...projection.warnings.map(
                  (warning) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: AppText('• $warning'),
                  ),
                ),
              ],
            ),
          ),
        if (missingFrameworkLanguages.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            child: AppText(
              'Нельзя создать: фреймворк требует ${missingFrameworkLanguages.map((id) => GameCatalog.languageById(id).name).join(', ')}.',
            ),
          ),
        ],
        if (widget.controller.state.cash < projection.developmentCost) ...[
          const SizedBox(height: 12),
          AppCard(
            child: AppText(
              'Недостаточно денег на разовую настройку: доступно ${money(widget.controller.state.cash)}.',
            ),
          ),
        ],
        if (currentInvestors < _strategy.requiredInvestorCount) ...[
          const SizedBox(height: 12),
          AppCard(
            child: AppText(
              'Проект заблокирован: нужно инвесторов ${_strategy.requiredInvestorCount}.',
            ),
          ),
        ],
      ],
    );
  }

  ProductProjection _projectionForFramework(String frameworkId) {
    final profile = ProductStrategyCatalog.frameworkProfile(frameworkId);
    final languages = <String>{..._languageIds, ...profile.requiredLanguageIds};
    while (languages.length > _strategy.maximumLanguageCount) {
      final removable = languages.firstWhere(
        (id) => !profile.requiredLanguageIds.contains(id),
        orElse: () => languages.last,
      );
      languages.remove(removable);
    }
    return ProductProjectionCache.estimate(
      blueprintId: _blueprintId,
      frameworkId: frameworkId,
      languageIds: languages.toList(growable: false),
      technologyIds: _technologyIds.toList(growable: false),
      featureIds: _featureIds.toList(growable: false),
    );
  }

  void _create() {
    widget.controller.dispatch(
      CreateConfiguredProduct(
        name: _nameController.text,
        blueprintId: _blueprintId,
        frameworkId: _frameworkId,
        languageIds: _languageIds.toList(growable: false),
        technologyIds: _technologyIds.toList(growable: false),
        featureIds: _featureIds.toList(growable: false),
        monetization: _monetization,
      ),
    );
    Navigator.of(context).pop();
  }
}

class _ScopeBadge extends StatelessWidget {
  const _ScopeBadge(this.scope);
  final ProductScope scope;

  @override
  Widget build(BuildContext context) {
    final label = switch (scope) {
      ProductScope.starter => 'Старт',
      ProductScope.standard => 'Средний',
      ProductScope.advanced => 'Сложный',
      ProductScope.moonshot => 'Moonshot',
    };
    return _InfoChip(label, warning: scope == ProductScope.moonshot);
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label, {this.warning = false});
  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: (warning ? AppColors.red : AppColors.primary).withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (warning ? AppColors.red : AppColors.primary).withAlpha(55),
        ),
      ),
      child: AppText(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _ProsCons extends StatelessWidget {
  const _ProsCons({required this.strengths, required this.weaknesses});
  final List<String> strengths;
  final List<String> weaknesses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...strengths.map(
          (item) => AppText(
            '+ $item',
            style: const TextStyle(color: AppColors.green),
          ),
        ),
        ...weaknesses.map(
          (item) =>
              AppText('− $item', style: const TextStyle(color: AppColors.red)),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
    this.label,
    this.value, {
    this.supporting,
    this.last = false,
  });

  final String label;
  final String value;
  final String? supporting;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: last ? 0 : 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          AppText(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          if (supporting != null) ...[
            const SizedBox(height: 5),
            AppText(supporting!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

String _signed(double value) =>
    value >= 0 ? '+${value.round()}' : '${value.round()}';

List<String> _defaultTechnologies(String blueprintId) => switch (blueprintId) {
  'company_website' => const <String>[],
  'ai_assistant' => const <String>['postgresql', 'vector_db'],
  'cloud_platform' => const <String>[
    'postgresql',
    'kubernetes',
    'observability_stack',
  ],
  'privacy_browser' => const <String>['cdn', 'observability_stack'],
  'crypto_wallet' => const <String>['postgresql', 'hsm', 'e2ee'],
  'developer_platform' => const <String>['postgresql', 'observability_stack'],
  'city_system' => const <String>[
    'postgresql',
    'kubernetes',
    'observability_stack',
  ],
  _ => const <String>['postgresql'],
};

String _defaultName(String blueprintId) => switch (blueprintId) {
  'company_website' => 'First Landing',
  'ai_assistant' => 'Nova One',
  'cloud_platform' => 'Orbit Cloud',
  'team_saas' => 'Flowspace',
  'privacy_browser' => 'Luma Browser',
  'crypto_wallet' => 'Vaultline',
  'developer_platform' => 'Forge SDK',
  'city_system' => 'City Grid',
  _ => 'New Product',
};

String _monetizationDescription(MonetizationModel model) => switch (model) {
  MonetizationModel.free =>
    'Нет прямой выручки. Используется для доверия и входа в другие системы.',
  MonetizationModel.subscription =>
    'Регулярный платёж. Цена влияет на выручку, churn и настроение аудитории.',
  MonetizationModel.usageBased => 'Оплата зависит от использования и нагрузки.',
  MonetizationModel.advertising =>
    'Выручка растёт с MAU, но нужна аудитория и доверие рекламодателей.',
  MonetizationModel.transactionFee =>
    'Комиссия с операций. Требует высокого доверия и безопасности.',
};
