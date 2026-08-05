import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/business_models.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';
import '../contracts/contract_detail_screen.dart';
import '../contracts/contracts_screen.dart';
import '../products/product_detail_screen.dart';
import '../products/products_screen.dart';

class OperationsScreen extends StatelessWidget {
  const OperationsScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        return Scaffold(
          appBar: AppBar(title: const Text('Центр проектов')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              SectionHeader(
                title: 'Вся активная работа',
                subtitle:
                    '${state.products.length} продуктов • ${state.activeContracts.length} контрактов • ${state.unassignedEmployees.length} свободных сотрудников',
                hintTitle: 'Единый центр проектов',
                hintBody:
                    'Здесь собраны собственные продукты и клиентские контракты. Каждая карточка открывает детали, прогресс, требования и управление командой.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _open(
                        context,
                        ProductsScreen(controller: controller),
                      ),
                      icon: const Icon(Icons.apps_outlined),
                      label: const Text('Каталог продуктов'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _open(
                        context,
                        ContractsScreen(controller: controller),
                      ),
                      icon: const Icon(Icons.handshake_outlined),
                      label: const Text('Новые контракты'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Собственные продукты',
                subtitle:
                    'Разработка, релизы и работающие продукты с отдельными командами.',
              ),
              const SizedBox(height: 10),
              if (state.products.isEmpty)
                const AppCard(
                  child: Text('Продуктов пока нет. Откройте каталог выше.'),
                )
              else
                ...state.products.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ProductWorkCard(
                      controller: controller,
                      product: product,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Клиентские контракты',
                subtitle:
                    'Каждый заказ имеет отдельную команду, прогресс и дедлайн.',
              ),
              const SizedBox(height: 10),
              if (state.activeContracts.isEmpty)
                const AppCard(child: Text('Активных контрактов пока нет.'))
              else
                ...state.activeContracts.map(
                  (contract) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ContractWorkCard(
                      controller: controller,
                      contract: contract,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              const SectionHeader(
                title: 'Распределение сотрудников',
                subtitle:
                    'Один сотрудник может работать только над одним активным проектом.',
              ),
              const SizedBox(height: 10),
              if (state.employees.isEmpty)
                const AppCard(child: Text('Сотрудников пока нет.'))
              else
                AppCard(
                  child: Column(
                    children: state.employees
                        .map((employee) {
                          final productAssignment = state.assignmentForEmployee(
                            employee.id,
                          );
                          final contractAssignment = state
                              .contractAssignmentForEmployee(employee.id);
                          final work = productAssignment != null
                              ? state
                                    .productById(productAssignment.productId)
                                    ?.name
                              : contractAssignment != null
                              ? state
                                    .contractById(contractAssignment.contractId)
                                    ?.letName(state)
                              : 'Свободен';
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(employee.name),
                            subtitle: Text(roleName(employee.role)),
                            trailing: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: Text(
                                work ?? 'Свободен',
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => page));
  }
}

class _ProductWorkCard extends StatelessWidget {
  const _ProductWorkCard({required this.controller, required this.product});

  final GameController controller;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final team = state.employeesForProduct(product.id);
    final coverage = state.productRoleCoverage(product.id);
    final capacity = state.productDevelopmentCapacity(product.id);
    final staffing = state.developmentStaffingFor(product.id);
    final phase = state.developmentPhaseFor(product);
    final featureWork = state.activeFeatureDevelopmentFor(product.id);
    return AppCard(
      key: Key('work-product-${product.id}'),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            controller: controller,
            productId: product.id,
          ),
        ),
      ),
      hintTitle: 'Работа над ${product.name}',
      hintBody:
          'Нажмите карточку для подробностей. Кнопка команды применяет изменения одним атомарным действием, поэтому промежуточные checkbox не меняют состояние.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              IconButton.filledTonal(
                key: Key('manage-team-${product.id}'),
                tooltip: 'Управлять командой',
                onPressed: () => _showProductTeamSheet(context, state),
                icon: const Icon(Icons.manage_accounts_outlined),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          if (product.stage == ProductStage.development) ...[
            LinearProgressIndicator(value: product.developmentProgress),
            const SizedBox(height: 7),
            Text('${phase.name} • ${staffing.status}'),
            const SizedBox(height: 7),
          ] else if (featureWork != null) ...[
            LinearProgressIndicator(value: featureWork.progress),
            const SizedBox(height: 7),
            Text(
              'Обновление: ${state.featureDevelopmentRemainingHours(product.id).round()} ч. осталось',
            ),
            const SizedBox(height: 7),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Команда ${team.length}')),
              Chip(label: Text('Роли ${(coverage * 100).round()}%')),
              Chip(label: Text('Capacity ${capacity.toStringAsFixed(2)} FTE')),
              Chip(label: Text('Эфф. ${(staffing.efficiency * 100).round()}%')),
              if (product.stage == ProductStage.development)
                Chip(
                  label: Text(
                    'Готовность ${(product.developmentProgress * 100).toStringAsFixed(1)}%',
                  ),
                ),
              if (product.stage == ProductStage.live)
                Chip(label: Text('${money(product.monthlyRevenue)}/мес.')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showProductTeamSheet(
    BuildContext context,
    GameState state,
  ) async {
    final selected = state
        .employeesForProduct(product.id)
        .map((item) => item.id)
        .toSet();
    await _showAssignmentSheet(
      context: context,
      title: 'Команда ${product.name}',
      state: state,
      selected: selected,
      keyPrefix: 'product-${product.id}',
      onSave: (ids) => controller.dispatch(
        SetProductTeam(productId: product.id, employeeIds: ids),
      ),
    );
  }
}

class _ContractWorkCard extends StatelessWidget {
  const _ContractWorkCard({required this.controller, required this.contract});

  final GameController controller;
  final ClientContract contract;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final template = state.contractTemplate(contract.templateId);
    final team = state.employeesForContract(contract.id);
    final coverage = state.contractRoleCoverageFor(contract.id);
    final daysLeft =
        ((contract.deadlineAtMinutes - state.simulationMinutes) / 1440)
            .clamp(0, 999)
            .toDouble();
    return AppCard(
      key: Key('work-contract-${contract.id}'),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ContractDetailScreen(
            controller: controller,
            contractId: contract.id,
          ),
        ),
      ),
      hintTitle: 'Контракт ${template.name}',
      hintBody:
          'Контракт больше не использует весь резерв автоматически. Назначьте конкретных сотрудников — они станут недоступны для других проектов.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(template.client),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Управлять командой',
                onPressed: () => _showContractTeamSheet(context, state),
                icon: const Icon(Icons.manage_accounts_outlined),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: contract.progress),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Команда ${team.length}')),
              Chip(label: Text('Роли ${(coverage * 100).round()}%')),
              Chip(label: Text('${daysLeft.toStringAsFixed(1)} дн.')),
              Chip(
                label: Text('${(contract.progress * 100).toStringAsFixed(1)}%'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showContractTeamSheet(
    BuildContext context,
    GameState state,
  ) async {
    final selected = state
        .employeesForContract(contract.id)
        .map((item) => item.id)
        .toSet();
    await _showAssignmentSheet(
      context: context,
      title: 'Команда контракта',
      state: state,
      selected: selected,
      keyPrefix: 'contract-${contract.id}',
      onSave: (ids) => controller.dispatch(
        SetContractTeam(contractId: contract.id, employeeIds: ids),
      ),
    );
  }
}

Future<void> _showAssignmentSheet({
  required BuildContext context,
  required String title,
  required GameState state,
  required Set<String> selected,
  required String keyPrefix,
  required ValueChanged<List<String>> onSave,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Выбрано ${selected.length}. Checkbox не закрывает панель; всё применяется только кнопкой сохранения.',
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.employees.length,
                    itemBuilder: (_, index) {
                      final employee = state.employees[index];
                      final productAssignment = state.assignmentForEmployee(
                        employee.id,
                      );
                      final contractAssignment = state
                          .contractAssignmentForEmployee(employee.id);
                      final busy = productAssignment != null
                          ? state.productById(productAssignment.productId)?.name
                          : contractAssignment != null
                          ? state
                                .contractById(contractAssignment.contractId)
                                ?.letName(state)
                          : 'Свободен';
                      final productMode = keyPrefix.startsWith('product-');
                      final targetId = productMode
                          ? keyPrefix.substring('product-'.length)
                          : keyPrefix;
                      return CheckboxListTile(
                        key: Key(
                          productMode
                              ? 'assign-${employee.id}-to-$targetId'
                              : '$keyPrefix-${employee.id}',
                        ),
                        value: selected.contains(employee.id),
                        title: Text(employee.name),
                        subtitle: Text(
                          '${roleName(employee.role)} • ${busy ?? 'Свободен'}',
                        ),
                        onChanged: (value) => setSheetState(() {
                          if (value ?? false) {
                            selected.add(employee.id);
                          } else {
                            selected.remove(employee.id);
                          }
                        }),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        key: Key(
                          keyPrefix.startsWith('product-')
                              ? 'save-team-${keyPrefix.substring('product-'.length)}'
                              : 'save-$keyPrefix',
                        ),
                        onPressed: () {
                          onSave(selected.toList(growable: false));
                          Navigator.of(sheetContext).pop();
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Сохранить команду'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

extension on ClientContract {
  String letName(GameState state) => state.contractTemplate(templateId).name;
}
