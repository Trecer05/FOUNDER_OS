import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/contract_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/business_models.dart';
import '../../../domain/entities/game_state.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Клиентские контракты')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const SectionHeader(
            title: 'Контракты',
            subtitle:
                'Разовые заказы дают денежную подушку, пока собственные продукты убыточны.',
            hintTitle: 'Как работают контракты',
            hintBody:
                'Контракт выполняют сотрудники в резерве. Назначенные на продукты люди не ускоряют заказ. Клиент платит аванс сразу, остаток — после выполнения. Срыв срока приводит к штрафу.',
            hintBullets: [
              'Одновременно можно вести до трёх контрактов.',
              'Покрытие требуемых ролей заметно ускоряет работу.',
              'Контрактная выручка разовая и не входит в MRR.',
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              MetricCard(
                label: 'Активные контракты',
                value: '${state.activeContracts.length} / 3',
                hint:
                    'Количество заказов, которые прямо сейчас используют свободную контрактную мощность.',
              ),
              MetricCard(
                label: 'Резерв команды',
                value: '${state.unassignedEmployees.length}',
                hint:
                    'Только сотрудники без назначения на продукт работают над контрактами.',
              ),
              MetricCard(
                label: 'Contract capacity',
                value: state.contractDevelopmentCapacity.toStringAsFixed(0),
                hint:
                    'Скорость контрактной разработки из навыков сотрудников в резерве и базовой мощности основателя.',
              ),
              MetricCard(
                label: 'Завершено',
                value: '${state.completedContracts.length}',
                hint: 'Количество успешно закрытых клиентских заказов.',
              ),
            ],
          ),
          if (state.activeContracts.isNotEmpty) ...[
            const SizedBox(height: 18),
            const SectionHeader(
              title: 'В работе',
              subtitle: 'Следите за прогрессом, сроком и покрытием ролей.',
            ),
            const SizedBox(height: 10),
            ...state.activeContracts.map(
              (contract) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ActiveContractCard(state: state, contract: contract),
              ),
            ),
          ],
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Доступные заказы',
            subtitle: 'Новые контракты можно брать повторно после завершения.',
          ),
          const SizedBox(height: 10),
          ...ContractCatalog.templates.map(
            (template) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ContractOfferCard(
                state: state,
                template: template,
                onAccept: () =>
                    controller.dispatch(AcceptClientContract(template.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveContractCard extends StatelessWidget {
  const _ActiveContractCard({required this.state, required this.contract});

  final GameState state;
  final ClientContract contract;

  @override
  Widget build(BuildContext context) {
    final template = state.contractTemplate(contract.templateId);
    final minutesLeft = contract.deadlineAtMinutes - state.simulationMinutes;
    final daysLeft = minutesLeft / 1440;
    return AppCard(
      hintTitle: 'Активный контракт',
      hintBody:
          'Прогресс растёт вместе с игровым временем. Если роли не покрыты, контракт всё равно движется, но значительно медленнее.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(template.name, style: Theme.of(context).textTheme.titleMedium),
          Text(template.client, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: contract.progress),
          const SizedBox(height: 8),
          Text(
            '${(contract.progress * 100).toStringAsFixed(1)}% • ${daysLeft.clamp(0, 999).toStringAsFixed(1)} дн. до срока',
          ),
          const SizedBox(height: 8),
          Text(
            'Покрытие ролей ${(state.contractRoleCoverage(template) * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: state.contractRoleCoverage(template) >= 1
                  ? AppColors.green
                  : AppColors.red,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractOfferCard extends StatelessWidget {
  const _ContractOfferCard({
    required this.state,
    required this.template,
    required this.onAccept,
  });

  final GameState state;
  final ContractTemplate template;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final active = state.hasActiveContractTemplate(template.id);
    final limitReached = state.activeContracts.length >= 3;
    final coverage = state.contractRoleCoverage(template);
    return AppCard(
      hintTitle: template.name,
      hintBody:
          'Награда выплачивается частями: ${(template.upfrontPercent * 100).round()}% авансом, остальное после сдачи. При просрочке штраф 10% полной суммы.',
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
                    Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      template.client,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                money(template.reward),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(template.description),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              Chip(label: Text('${template.deadlineDays} дней')),
              Chip(label: Text('${template.developmentHours.round()} ч.')),
              Chip(label: Text('Роли ${(coverage * 100).round()}%')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Нужны: ${template.requiredRoles.map(roleName).join(', ')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: Key('accept-contract-${template.id}'),
              onPressed: active || limitReached ? null : onAccept,
              icon: const Icon(Icons.handshake_outlined),
              label: Text(
                active
                    ? 'Уже выполняется'
                    : limitReached
                    ? 'Лимит активных контрактов'
                    : 'Принять • аванс ${money(template.reward * template.upfrontPercent)}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
