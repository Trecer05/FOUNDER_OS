import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/business_models.dart';
import '../../../domain/entities/game_state.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';
import '../../../application/localization/app_text.dart';
import '../../shared/widgets/scoped_listenable_builder.dart';

class ContractDetailScreen extends StatelessWidget {
  const ContractDetailScreen({
    required this.controller,
    required this.contractId,
    super.key,
  });

  final GameController controller;
  final String contractId;

  @override
  Widget build(BuildContext context) {
    return ScopedListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final contract = state.contractById(contractId);
        if (contract == null) {
          return const Scaffold(
            body: Center(child: AppText('Контракт не найден')),
          );
        }
        final template = state.contractTemplate(contract.templateId);
        final team = state.employeesForContract(contract.id);
        final coverage = state.contractRoleCoverageFor(contract.id);
        final capacity = state.contractDevelopmentCapacityFor(contract.id);
        final minutesLeft =
            contract.deadlineAtMinutes - state.simulationMinutes;
        final daysLeft = (minutesLeft / 1440).clamp(0, 999).toDouble();
        final remainingHours =
            (1 - contract.progress).clamp(0, 1) * template.developmentHours;
        final etaDays = capacity <= 0
            ? double.infinity
            : remainingHours / (0.30 + capacity / 80) / 24;

        return Scaffold(
          appBar: AppBar(title: AppText(template.name)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              SectionHeader(
                title: template.name,
                subtitle:
                    '${template.client} • ${_statusName(contract.status)}',
                hintTitle: 'Контракт как отдельный проект',
                hintBody:
                    'У контракта собственная команда, прогресс и дедлайн. Один сотрудник не может одновременно работать над продуктом и контрактом.',
              ),
              const SizedBox(height: 12),
              AppCard(
                hintTitle: 'Прогресс и срок',
                hintBody:
                    'Прогресс растёт только у назначенной команды. Покрытие ролей и навыки влияют на скорость, а дедлайн не останавливается.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '${(contract.progress * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: contract.progress),
                    const SizedBox(height: 12),
                    _ValueRow(
                      'До дедлайна',
                      '${daysLeft.toStringAsFixed(1)} дн.',
                    ),
                    _ValueRow('Награда', money(contract.reward)),
                    _ValueRow('Команда', '${team.length}'),
                    _ValueRow('Покрытие ролей', '${(coverage * 100).round()}%'),
                    _ValueRow('Capacity', capacity.toStringAsFixed(0)),
                    _ValueRow(
                      'Прогноз завершения',
                      etaDays.isInfinite
                          ? 'Нет рабочей мощности'
                          : '~${etaDays.toStringAsFixed(1)} дн.',
                      last: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SectionHeader(
                title: 'Команда контракта',
                subtitle: team.isEmpty
                    ? 'Никто не назначен — контракт почти не движется.'
                    : team.map((item) => item.name).join(', '),
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...template.requiredRoles.map((role) {
                      final actual = team
                          .where((item) => item.role == role)
                          .length;
                      final ready = actual > 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              ready
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: ready ? AppColors.green : AppColors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: AppText(roleName(role))),
                            AppText('$actual/1'),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: Key('manage-contract-team-${contract.id}'),
                        onPressed: contract.status == ContractStatus.active
                            ? () => _showTeamSheet(context, state, contract)
                            : null,
                        icon: const Icon(Icons.groups_2_outlined),
                        label: const AppText('Изменить команду'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppCard(
                hintTitle: 'Оплата контракта',
                hintBody:
                    'Аванс уже получен при принятии. Остаток приходит после завершения. При срыве срока списывается штраф 10% полной суммы.',
                child: Column(
                  children: [
                    _ValueRow(
                      'Аванс',
                      money(contract.reward * template.upfrontPercent),
                    ),
                    _ValueRow(
                      'После сдачи',
                      money(contract.reward * (1 - template.upfrontPercent)),
                      last: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showTeamSheet(
    BuildContext context,
    GameState state,
    ClientContract contract,
  ) async {
    final selected = state
        .employeesForContract(contract.id)
        .map((item) => item.id)
        .toSet();
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
                  AppText(
                    'Команда контракта',
                    style: Theme.of(sheetContext).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    'Выбрано: ${selected.length}. Изменения применятся только после сохранения.',
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: state.employees.isEmpty
                        ? const Center(child: AppText('Сотрудников пока нет.'))
                        : ListView.builder(
                            itemCount: state.employees.length,
                            itemBuilder: (_, index) {
                              final employee = state.employees[index];
                              final productAssignment = state
                                  .assignmentForEmployee(employee.id);
                              final contractAssignment = state
                                  .contractAssignmentForEmployee(employee.id);
                              final busyLabel = productAssignment != null
                                  ? state
                                        .productById(
                                          productAssignment.productId,
                                        )
                                        ?.name
                                  : contractAssignment != null
                                  ? state
                                        .contractById(
                                          contractAssignment.contractId,
                                        )
                                        ?.letName(state)
                                  : null;
                              return CheckboxListTile(
                                key: Key(
                                  'contract-${contract.id}-employee-${employee.id}',
                                ),
                                value: selected.contains(employee.id),
                                title: AppText(employee.name),
                                subtitle: AppText(
                                  '${roleName(employee.role)} • ${busyLabel ?? 'свободен'}',
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
                          child: const AppText('Отмена'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          key: Key('save-contract-team-${contract.id}'),
                          onPressed: () {
                            controller.dispatch(
                              SetContractTeam(
                                contractId: contract.id,
                                employeeIds: selected.toList(growable: false),
                              ),
                            );
                            Navigator.of(sheetContext).pop();
                          },
                          icon: const Icon(Icons.save_outlined),
                          label: const AppText('Сохранить команду'),
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
}

extension on ClientContract {
  String letName(GameState state) => state.contractTemplate(templateId).name;
}

String _statusName(ContractStatus status) => switch (status) {
  ContractStatus.active => 'В работе',
  ContractStatus.completed => 'Завершён',
  ContractStatus.failed => 'Сорван',
};

class _ValueRow extends StatelessWidget {
  const _ValueRow(this.label, this.value, {this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Expanded(child: AppText(label)),
              AppText(
                value,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        if (!last) const Divider(height: 1),
      ],
    );
  }
}
