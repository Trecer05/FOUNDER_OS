import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/v9_content_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/v9_models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';

class EcosystemScreen extends StatefulWidget {
  const EcosystemScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<EcosystemScreen> createState() => _EcosystemScreenState();
}

class _EcosystemScreenState extends State<EcosystemScreen> {
  String? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final products = state.products.toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(title: const Text('Экосистема')),
      body: products.length < 2
          ? _EmptyState(productCount: products.length)
          : ListView(
              key: const Key('ecosystem-screen-list'),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: _content(context, products),
            ),
    );
  }

  List<Widget> _content(BuildContext context, List<Product> products) {
    final state = widget.controller.state;
    final selectedId = products.any((item) => item.id == _selectedProductId)
        ? _selectedProductId!
        : products.first.id;
    final selected = state.productById(selectedId)!;
    final others = products.where((item) => item.id != selectedId).toList();
    return [
      const SectionHeader(
        title: 'Связи между самостоятельными продуктами',
        subtitle:
            'Каждая пара хранится один раз. Связь даёт конкретный эффект, стоимость, срок и риск.',
      ),
      const SizedBox(height: 12),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              key: const Key('ecosystem-product-picker'),
              initialValue: selectedId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Основной продукт'),
              items: products
                  .map(
                    (product) => DropdownMenuItem(
                      value: product.id,
                      child: Text(
                        product.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _selectedProductId = value),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  'Связи',
                  '${state.connectedProductIds(selectedId).length}',
                ),
                _MetricChip(
                  'Текущий boost',
                  '+${percent(state.ecosystemBoostFor(selectedId), fractionDigits: 1)}',
                ),
                _MetricChip('MRR продукта', money(selected.monthlyRevenue)),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      ...others.map((other) {
        final linked = state.hasLink(selected.id, other.id);
        final profile = V9ContentCatalog.integrationFor(
          selected.category.name,
          other.category.name,
        );
        final reasons = _blockingReasons(selected, other, profile, linked);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _IntegrationCard(
            selected: selected,
            other: other,
            profile: profile,
            linked: linked,
            blockingReasons: reasons,
            onChanged: (value) {
              widget.controller.dispatch(
                value
                    ? ConnectProducts(
                        firstProductId: selected.id,
                        secondProductId: other.id,
                      )
                    : DisconnectProducts(
                        firstProductId: selected.id,
                        secondProductId: other.id,
                      ),
              );
            },
          ),
        );
      }),
      const SizedBox(height: 8),
      const SectionHeader(
        title: 'Активные интеграции',
        subtitle: 'Дублирующие и самоссылочные пары запрещены движком.',
      ),
      const SizedBox(height: 10),
      if (state.ecosystemLinks.isEmpty)
        const AppCard(child: Text('Интеграций пока нет.'))
      else
        AppCard(
          child: Column(
            children: state.ecosystemLinks
                .map((link) {
                  final left = state.productById(link.leftProductId)!;
                  final right = state.productById(link.rightProductId)!;
                  final profile = V9ContentCatalog.integrationFor(
                    left.category.name,
                    right.category.name,
                  );
                  final remainingDays =
                      ((link.activeAtMinutes - state.simulationMinutes) / 1440)
                          .ceil();
                  final status = remainingDays > 0
                      ? 'интеграция ещё $remainingDays дн.'
                      : 'активна';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.link, color: AppColors.violet),
                    title: Text('${left.name} ↔ ${right.name}'),
                    subtitle: Text(
                      '${profile.title} • $status • рост +${percent(profile.growthBoost)} • compute ×${profile.computeMultiplier.toStringAsFixed(2)}',
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
    ];
  }

  List<String> _blockingReasons(
    Product selected,
    Product other,
    EcosystemIntegrationProfile profile,
    bool linked,
  ) {
    if (linked) return const <String>[];
    final state = widget.controller.state;
    final reasons = <String>[];
    if (selected.stage == ProductStage.failed ||
        other.stage == ProductStage.failed) {
      reasons.add('Нельзя интегрировать проваленный продукт.');
    }
    if (state.cash < profile.cost) {
      reasons.add('Не хватает ${money(profile.cost - state.cash)}.');
    }
    final freeBackend = state.unassignedEmployees.any(
      (employee) =>
          employee.role == EmployeeRole.backend ||
          employee.role == EmployeeRole.devOps,
    );
    if (!freeBackend) {
      reasons.add('Нет свободного Backend или DevOps для интеграции.');
    }
    reasons.sort();
    return reasons;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.productCount});
  final int productCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.hub_outlined,
                    size: 48,
                    color: AppColors.violet,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Нужно минимум два продукта',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productCount == 0
                        ? 'Создайте первый продукт, затем второй — после этого появятся варианты интеграции.'
                        : 'Создайте ещё один продукт. Существующий продолжит работать самостоятельно.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  const _IntegrationCard({
    required this.selected,
    required this.other,
    required this.profile,
    required this.linked,
    required this.blockingReasons,
    required this.onChanged,
  });

  final Product selected;
  final Product other;
  final EcosystemIntegrationProfile profile;
  final bool linked;
  final List<String> blockingReasons;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.violet.withAlpha(22),
                foregroundColor: AppColors.violet,
                child: const Icon(Icons.hub_outlined),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      other.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      profile.title,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                key: Key('ecosystem-${selected.id}-${other.id}'),
                value: linked,
                onChanged: linked || blockingReasons.isEmpty ? onChanged : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(profile.description),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _MetricChip('Стоимость', money(profile.cost)),
              _MetricChip('Интеграция', '${profile.integrationDays} дн.'),
              _MetricChip('Рост', '+${percent(profile.growthBoost)}'),
              _MetricChip('Retention', '+${percent(profile.retentionBoost)}'),
              _MetricChip(
                'Compute',
                '×${profile.computeMultiplier.toStringAsFixed(2)}',
              ),
              _MetricChip('Риск', percent(profile.risk)),
            ],
          ),
          if (blockingReasons.isNotEmpty && !linked) ...[
            const SizedBox(height: 10),
            ...blockingReasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '• $reason',
                  style: const TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
