import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/commands/game_action.dart';
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
    final products = state.products;

    if (products.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: const [
          SectionHeader(
            title: 'Экосистема',
            subtitle: 'Сначала создайте минимум два продукта.',
          ),
          SizedBox(height: 12),
          AppCard(
            child: Text(
              'Каждый продукт останется самостоятельным. Связи только добавляют небольшой взаимный буст.',
            ),
          ),
        ],
      );
    }

    final selectedId = products.any((item) => item.id == _selectedProductId)
        ? _selectedProductId!
        : products.first.id;
    final selected = state.productById(selectedId)!;
    final others = products.where((item) => item.id != selectedId).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        const SectionHeader(
          title: 'Экосистема продуктов',
          subtitle:
              'Один продукт можно связать с любым количеством других. Самосвязи и повторяющиеся пары запрещены.',
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedId,
                decoration: const InputDecoration(
                  labelText: 'Настраиваемый продукт',
                ),
                items: products
                    .map(
                      (product) => DropdownMenuItem(
                        value: product.id,
                        child: Text(product.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedProductId = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _Summary(
                      label: 'Связи',
                      value: '${state.connectedProductIds(selectedId).length}',
                    ),
                  ),
                  Expanded(
                    child: _Summary(
                      label: 'Буст',
                      value:
                          '+${percent(state.ecosystemBoostFor(selectedId), fractionDigits: 1)}',
                    ),
                  ),
                  Expanded(
                    child: _Summary(
                      label: 'Свой MRR',
                      value: money(selected.monthlyRevenue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionHeader(
          title: 'Подключения для ${selected.name}',
          subtitle:
              'Каждая связь стоит 85 000 ₽. Рост и выручка продуктов продолжают считаться отдельно.',
        ),
        const SizedBox(height: 10),
        if (others.isEmpty)
          const AppCard(child: Text('Нужен ещё один продукт.'))
        else
          ...others.map((other) {
            final linked = state.hasLink(selectedId, other.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: SwitchListTile(
                  key: Key('ecosystem-$selectedId-${other.id}'),
                  value: linked,
                  secondary: CircleAvatar(
                    backgroundColor: AppColors.violet.withAlpha(22),
                    foregroundColor: AppColors.violet,
                    child: const Icon(Icons.hub_outlined),
                  ),
                  title: Text(other.name),
                  subtitle: Text(
                    '${categoryName(other.category)} • ${compactNumber(other.users)} users • ${money(other.monthlyRevenue)}/мес.',
                  ),
                  onChanged: linked || state.cash >= 85000
                      ? (value) {
                          widget.controller.dispatch(
                            value
                                ? ConnectProducts(
                                    firstProductId: selectedId,
                                    secondProductId: other.id,
                                  )
                                : DisconnectProducts(
                                    firstProductId: selectedId,
                                    secondProductId: other.id,
                                  ),
                          );
                        }
                      : null,
                ),
              ),
            );
          }),
        const SizedBox(height: 18),
        const SectionHeader(
          title: 'Все уникальные связи',
          subtitle: 'Пара A ↔ B хранится один раз, независимо от направления.',
        ),
        const SizedBox(height: 10),
        AppCard(
          child: state.ecosystemLinks.isEmpty
              ? const Text('Связей пока нет.')
              : Column(
                  children: state.ecosystemLinks
                      .map((link) {
                        final left = state.productById(link.leftProductId)!;
                        final right = state.productById(link.rightProductId)!;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.link,
                            color: AppColors.violet,
                          ),
                          title: Text('${left.name} ↔ ${right.name}'),
                          subtitle: Text(
                            '${money(left.monthlyRevenue)} + ${money(right.monthlyRevenue)} считаются независимо',
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
