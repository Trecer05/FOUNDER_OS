import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/operations_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';

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
          appBar: AppBar(title: const Text('Операции и проектные команды')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              SectionHeader(
                title: 'Проектные команды',
                subtitle:
                    '${state.employees.length - state.unassignedEmployees.length} назначено • ${state.unassignedEmployees.length} в резерве',
                hintTitle: 'Проектные команды',
                hintBody:
                    'Сотрудник может быть назначен только на один продукт. Capacity зависит от навыков, офиса, покрытия обязательных ролей и корпоративной AI.',
              ),
              const SizedBox(height: 12),
              if (state.products.isEmpty)
                const AppCard(
                  child: Text(
                    'Сначала создайте продукт. После этого сотрудников можно назначать в отдельные проектные команды.',
                  ),
                )
              else
                ...state.products.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ProductTeamCard(
                      controller: controller,
                      product: product,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              SectionHeader(
                title: 'Сотрудники',
                subtitle:
                    'Назначение влияет на скорость разработки и качество конкретного продукта. Свободные сотрудники не дают скрытый глобальный бонус.',
              ),
              const SizedBox(height: 10),
              if (state.employees.isEmpty)
                const AppCard(child: Text('Нанятых сотрудников пока нет.'))
              else
                ...state.employees.map(
                  (employee) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _EmployeeOperationsCard(
                      controller: controller,
                      employee: employee,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductTeamCard extends StatelessWidget {
  const _ProductTeamCard({required this.controller, required this.product});

  final GameController controller;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final team = state.employeesForProduct(product.id);
    final capacity = state.productDevelopmentCapacity(product.id);
    final roleCoverage = state.productRoleCoverage(product.id);
    final missingRoles = state.missingRoleRequirements(product.id);
    final remainingPercent = (1 - product.developmentProgress).clamp(0, 1);
    final etaHours = product.stage == ProductStage.development
        ? (remainingPercent * 4200 / (3.5 + capacity / 14)).clamp(0, 9999)
        : 0.0;

    return AppCard(
      hintTitle: 'Команда ${product.name}',
      hintBody:
          'Красные специальности отсутствуют или представлены в недостаточном количестве. Это снижает role coverage и итоговую скорость разработки.',
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
              FilledButton.tonalIcon(
                key: Key('manage-team-${product.id}'),
                onPressed: () => _showAssignmentSheet(context),
                icon: const Icon(Icons.manage_accounts_outlined),
                label: const Text('Состав'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip('Людей', '${team.length}'),
              _InfoChip('Capacity', capacity.toStringAsFixed(0)),
              _InfoChip('Roles', percent(roleCoverage)),
              if (product.stage == ProductStage.development)
                _InfoChip('ETA', '${etaHours.ceil()} ч'),
              _InfoChip(
                'Готовность',
                '${(product.developmentProgress * 100).toStringAsFixed(1)}%',
              ),
            ],
          ),
          if (missingRoles.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: missingRoles
                  .map(
                    (item) => Chip(
                      avatar: const Icon(
                        Icons.error_outline,
                        size: 17,
                        color: AppColors.red,
                      ),
                      label: Text(
                        '${roleName(item.role)} ${state.assignedRoleCount(product.id, item.role)}/${item.minimumCount}',
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: 10),
          if (team.isEmpty)
            const Text(
              'Работает только базовая мощность основателя. Назначьте команду, чтобы ускорить разработку.',
              style: TextStyle(color: AppColors.red),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: team
                  .map(
                    (employee) => Chip(
                      avatar: CircleAvatar(
                        child: Text(employee.name.substring(0, 1)),
                      ),
                      label: Text(
                        '${employee.name} • ${roleName(employee.role)}',
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  Future<void> _showAssignmentSheet(BuildContext context) async {
    final state = controller.state;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 16,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Команда ${product.name}',
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Один сотрудник может работать только над одним продуктом. Переназначение происходит сразу.',
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: state.employees.isEmpty
                      ? const Center(child: Text('Сотрудников пока нет.'))
                      : ListView.separated(
                          itemCount: state.employees.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final employee = state.employees[index];
                            final assignment = state.assignmentForEmployee(
                              employee.id,
                            );
                            final selected =
                                assignment?.productId == product.id;
                            final currentProduct = assignment == null
                                ? null
                                : state.productById(assignment.productId);
                            return CheckboxListTile(
                              key: Key(
                                'assign-${employee.id}-to-${product.id}',
                              ),
                              value: selected,
                              title: Text(employee.name),
                              subtitle: Text(
                                '${roleName(employee.role)} • ${currentProduct == null ? 'резерв' : currentProduct.name}',
                              ),
                              onChanged: (_) {
                                controller.dispatch(
                                  AssignEmployeeToProduct(
                                    employeeId: employee.id,
                                    productId: selected ? null : product.id,
                                  ),
                                );
                                Navigator.of(sheetContext).pop();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmployeeOperationsCard extends StatelessWidget {
  const _EmployeeOperationsCard({
    required this.controller,
    required this.employee,
  });

  final GameController controller;
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final assignment = state.assignmentForEmployee(employee.id);
    final product = assignment == null
        ? null
        : state.productById(assignment.productId);
    return AppCard(
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
                      employee.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${roleName(employee.role)} • ${money(employee.salary)}/мес.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                key: Key('employee-actions-${employee.id}'),
                onSelected: (value) => _handleAction(context, value),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'raise', child: Text('Повысить на 10%')),
                  PopupMenuItem(value: 'train', child: Text('Обучить')),
                  PopupMenuItem(
                    value: 'bench',
                    child: Text('Перевести в резерв'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(value: 'fire', child: Text('Уволить')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip('Проект', product?.name ?? 'Резерв'),
              _InfoChip('Skill', '${employee.skill}'),
              _InfoChip('Speed', '${employee.speed}'),
              _InfoChip('Quality', '${employee.quality}'),
              _InfoChip('Morale', '${employee.morale}'),
              _InfoChip('Load', '${employee.workload}%'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, String value) async {
    switch (value) {
      case 'raise':
        controller.dispatch(
          GiveEmployeeRaise(employeeId: employee.id, percent: 10),
        );
        return;
      case 'bench':
        controller.dispatch(AssignEmployeeToProduct(employeeId: employee.id));
        return;
      case 'train':
        await _showTraining(context);
        return;
      case 'fire':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Уволить ${employee.name}?'),
            content: Text(
              'Компенсация составит ${money(employee.salary * 0.5)}.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Уволить'),
              ),
            ],
          ),
        );
        if (confirmed ?? false) {
          controller.dispatch(FireEmployee(employee.id));
        }
        return;
    }
  }

  Future<void> _showTraining(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          children: [
            Text(
              'Обучение: ${employee.name}',
              style: Theme.of(sheetContext).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            ...OperationsCatalog.trainingPrograms.map(
              (program) => ListTile(
                key: Key('train-${employee.id}-${program.id}'),
                title: Text(program.name),
                subtitle: Text(
                  '${program.description}\n${money(program.cost)}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.school_outlined),
                onTap: () {
                  controller.dispatch(
                    TrainEmployee(
                      employeeId: employee.id,
                      programId: program.id,
                    ),
                  );
                  Navigator.of(sheetContext).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text('$label: $value'),
    );
  }
}
