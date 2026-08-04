import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/simulation/product_estimator.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _nameController = TextEditingController();
  String _blueprintId = GameCatalog.productBlueprints.first.id;
  String _frameworkId = GameCatalog.frameworks.first.id;
  final Set<String> _languageIds = <String>{'typescript'};
  final Set<String> _technologyIds = <String>{'postgresql'};
  final Set<String> _featureIds = <String>{};

  ProductBlueprint get _blueprint => GameCatalog.blueprintById(_blueprintId);

  List<FrameworkOption> get _frameworks => GameCatalog.frameworks
      .where((item) => item.supportedCategories.contains(_blueprint.category))
      .toList(growable: false);

  List<FeatureOption> get _features => GameCatalog.features
      .where((item) => item.supportedCategories.contains(_blueprint.category))
      .toList(growable: false);

  ProductProjection get _projection => ProductEstimator.estimate(
    blueprintId: _blueprintId,
    frameworkId: _frameworkId,
    languageIds: _languageIds.toList(growable: false),
    technologyIds: _technologyIds.toList(growable: false),
    featureIds: _featureIds.toList(growable: false),
  );

  @override
  void initState() {
    super.initState();
    _frameworkId = _frameworks.first.id;
    _featureIds.addAll(_blueprint.expectedFeatureIds.take(2));
    _nameController.text = 'Nova One';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectBlueprint(String id) {
    setState(() {
      _blueprintId = id;
      _frameworkId = _frameworks.first.id;
      _featureIds
        ..clear()
        ..addAll(_blueprint.expectedFeatureIds.take(2));
      _nameController.text = _defaultName(_blueprint.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final projection = _projection;
    final canCreate =
        _nameController.text.trim().isNotEmpty &&
        _languageIds.isNotEmpty &&
        _featureIds.isNotEmpty &&
        widget.controller.state.cash >= projection.developmentCost;

    return Scaffold(
      appBar: AppBar(title: const Text('Новый продукт')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          const SectionHeader(
            title: 'Тип продукта',
            subtitle:
                'Категория определяет рынок, нагрузку и ожидания пользователей.',
          ),
          const SizedBox(height: 10),
          ...GameCatalog.productBlueprints.map(
            (blueprint) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: AppCard(
                onTap: () => _selectBlueprint(blueprint.id),
                child: Row(
                  children: [
                    Icon(
                      blueprint.id == _blueprintId
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: blueprint.id == _blueprintId
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blueprint.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 3),
                          Text(blueprint.description),
                          const SizedBox(height: 5),
                          Text(
                            'База: ${money(blueprint.baseDevelopmentCost)} • ${blueprint.baseDevelopmentHours.round()} ч.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const SectionHeader(
            title: 'Название и framework',
            subtitle:
                'Framework влияет на скорость, качество и стоимость разработки.',
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Название продукта',
              prefixIcon: Icon(Icons.drive_file_rename_outline),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          ..._frameworks.map(
            (framework) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: AppCard(
                onTap: () => setState(() => _frameworkId = framework.id),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      framework.id == _frameworkId
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: framework.id == _frameworkId
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            framework.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 3),
                          Text(framework.description),
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _SmallChip(
                                'Perf ${_signed(framework.performanceDelta)}',
                              ),
                              _SmallChip(
                                'Design ${_signed(framework.designDelta)}',
                              ),
                              _SmallChip(
                                'Security ${_signed(framework.securityDelta)}',
                              ),
                              _SmallChip(
                                'Dev speed ${_signed(framework.developmentSpeedDelta)}',
                              ),
                              _SmallChip(
                                '${money(framework.monthlyCost)}/мес.',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const SectionHeader(
            title: 'Языки',
            subtitle:
                'Выберите минимум один. Дополнительные языки усложняют разработку.',
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GameCatalog.languages
                .map((language) {
                  final selected = _languageIds.contains(language.id);
                  return FilterChip(
                    selected: selected,
                    label: Text(language.name),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _languageIds.add(language.id);
                        } else if (_languageIds.length > 1) {
                          _languageIds.remove(language.id);
                        }
                      });
                    },
                  );
                })
                .toList(growable: false),
          ),
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Технологии',
            subtitle:
                'У технологий есть точная стоимость, нагрузка и технический эффект.',
          ),
          const SizedBox(height: 10),
          ...GameCatalog.technologies.map(
            (technology) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: CheckboxListTile(
                  value: _technologyIds.contains(technology.id),
                  title: Text(technology.name),
                  subtitle: Text(
                    '${technology.description}\n${money(technology.developmentCost)} • ${money(technology.monthlyCost)}/мес. • compute ×${technology.computeMultiplier.toStringAsFixed(2)}',
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        _technologyIds.add(technology.id);
                      } else {
                        _technologyIds.remove(technology.id);
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader(
            title: 'Функции',
            subtitle:
                'Конкурент ожидает: ${_blueprint.expectedFeatureIds.map((id) => GameCatalog.featureById(id).name).join(', ')}.',
          ),
          const SizedBox(height: 10),
          ..._features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: CheckboxListTile(
                  value: _featureIds.contains(feature.id),
                  title: Text(feature.name),
                  subtitle: Text(
                    '${feature.description}\n${money(feature.developmentCost)} • retention +${(feature.retentionDelta * 100).toStringAsFixed(1)} п.п. • compute ×${feature.computeMultiplier.toStringAsFixed(2)}',
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        _featureIds.add(feature.id);
                      } else {
                        _featureIds.remove(feature.id);
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Прогноз до запуска',
            subtitle: 'Это реальные расчётные значения выбранной конфигурации.',
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                _ProjectionRow(
                  'Стоимость разработки',
                  money(projection.developmentCost),
                ),
                _ProjectionRow(
                  'Объём разработки',
                  '${projection.developmentHours.round()} ч.',
                ),
                _ProjectionRow('Latency', '${projection.speedMs.round()} ms'),
                _ProjectionRow(
                  'Design',
                  '${projection.designScore.round()} / 100',
                ),
                _ProjectionRow(
                  'Security',
                  '${projection.securityScore.round()} / 100',
                ),
                _ProjectionRow(
                  'Reliability',
                  percent(projection.reliability, fractionDigits: 2),
                ),
                _ProjectionRow(
                  'Ожидаемые функции',
                  percent(projection.featureCoverage),
                ),
                _ProjectionRow(
                  'Quality',
                  '${projection.qualityScore.round()} / 100',
                ),
                _ProjectionRow(
                  'Compute multiplier',
                  '×${projection.computeMultiplier.toStringAsFixed(2)}',
                  last: true,
                ),
              ],
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
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      money(projection.developmentCost),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      canCreate
                          ? 'Списывается после подтверждения'
                          : 'Нужны название, язык, функция и деньги',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton(
                key: const Key('create-configured-product'),
                onPressed: canCreate
                    ? () {
                        widget.controller.dispatch(
                          CreateConfiguredProduct(
                            name: _nameController.text,
                            blueprintId: _blueprintId,
                            frameworkId: _frameworkId,
                            languageIds: _languageIds.toList(growable: false),
                            technologyIds: _technologyIds.toList(
                              growable: false,
                            ),
                            featureIds: _featureIds.toList(growable: false),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    : null,
                child: const Text('Создать'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _ProjectionRow extends StatelessWidget {
  const _ProjectionRow(this.label, this.value, {this.last = false});
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
              Expanded(child: Text(label)),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        if (!last) const Divider(),
      ],
    );
  }
}

String _signed(double value) =>
    value >= 0 ? '+${value.round()}' : '${value.round()}';

String _defaultName(ProductCategory category) => switch (category) {
  ProductCategory.aiAssistant => 'Nova One',
  ProductCategory.cloud => 'Orbit Cloud',
  ProductCategory.saas => 'Flowspace',
  ProductCategory.browser => 'Luma Browser',
  ProductCategory.cryptoWallet => 'Vaultline',
  ProductCategory.developerTool => 'Forge SDK',
};
