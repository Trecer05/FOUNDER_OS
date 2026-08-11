// UAT_FIXPACK_R1
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
import 'contract_detail_screen.dart';
import '../../../application/localization/app_text.dart';
import '../../shared/widgets/scoped_listenable_builder.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ScopedListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final contractWeek = state.simulationMinutes ~/ (7 * 1440);
        final weeklyOffers = ContractCatalog.weeklyOffers(
          seed: state.rngSeed,
          week: contractWeek,
          completedCount: state.completedContracts.length,
        );
        final refreshInDays =
            ((((contractWeek + 1) * 7 * 1440) - state.simulationMinutes) / 1440)
                .ceil()
                .clamp(1, 7);
        return Scaffold(
          appBar: AppBar(title: const AppText('Клиентские контракты')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const SectionHeader(
                title: 'Контракты',
                subtitle:
                    'Каждый заказ теперь ведётся как отдельный проект со своей командой, сроком и карточкой.',
                hintTitle: 'Как работают контракты',
                hintBody:
                    'После принятия игра автоматически подбирает людей по ролям. Сотрудник может участвовать максимум в 4 работах, но эффективность снижается.',
                hintBullets: [
                  'Одновременно можно вести до трёх контрактов.',
                  'Аванс приходит сразу, остаток — после сдачи.',
                  'Срыв срока приводит к штрафу 10%.',
                ],
              ),
              const SizedBox(height: 12),
              if (!state.contractsUnlocked) ...[
                const AppCard(
                  hintTitle: 'Как открыть контракты',
                  hintBody:
                      'Контракты становятся доступны после публичного релиза сайта компании. Это первый дешёвый продукт и подтверждение, что компания способна завершать работу.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: AppColors.textMuted,
                        size: 34,
                      ),
                      SizedBox(height: 10),
                      AppText(
                        'Контракты пока закрыты',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 5),
                      AppText(
                        'Создайте и выпустите «Сайт компании». После релиза заказы появятся здесь и внутри карточки сайта.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 128,
                children: [
                  MetricCard(
                    label: 'Активные',
                    value: '${state.activeContracts.length} / 3',
                  ),
                  MetricCard(
                    label: 'Можно подключить',
                    value:
                        '${state.employees.where((item) => state.canAssignEmployeeToMoreWork(item.id)).length}',
                  ),
                  MetricCard(
                    label: 'Завершено',
                    value: '${state.completedContracts.length}',
                  ),
                  MetricCard(
                    label: 'Сорвано',
                    value: '${state.failedContracts.length}',
                    positive: state.failedContracts.isEmpty,
                  ),
                ],
              ),
              if (state.activeContracts.isNotEmpty) ...[
                const SizedBox(height: 18),
                const SectionHeader(
                  title: 'В работе',
                  subtitle:
                      'Нажмите на карточку, чтобы назначить команду и увидеть ETA.',
                ),
                const SizedBox(height: 10),
                ...state.activeContracts.map(
                  (contract) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ActiveContractCard(
                      state: state,
                      contract: contract,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => ContractDetailScreen(
                            controller: controller,
                            contractId: contract.id,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (state.contractsUnlocked) ...[
                const SizedBox(height: 18),
                SectionHeader(
                  title: 'Доступные заказы • неделя ${contractWeek + 1}',
                  subtitle:
                      'Рынок обновляется каждую неделю. Обновление рынка через $refreshInDays дн. • завершено контрактов: ${state.completedContracts.length}. После успешных заказов появляются более дорогие и сложные.',
                ),
                const SizedBox(height: 10),
                ...weeklyOffers.map(
                  (template) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ContractOfferCard(
                      state: state,
                      template: template,
                      onAccept: () => controller.dispatch(
                        AcceptClientContract(template.id),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ActiveContractCard extends StatelessWidget {
  const _ActiveContractCard({
    required this.state,
    required this.contract,
    required this.onTap,
  });

  final GameState state;
  final ClientContract contract;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final template = state.contractTemplate(contract.templateId);
    final daysLeft =
        ((contract.deadlineAtMinutes - state.simulationMinutes) / 1440)
            .clamp(0, 999)
            .toDouble();
    final team = state.employeesForContract(contract.id);
    final coverage = state.contractRoleCoverageFor(contract.id);
    return AppCard(
      key: Key('active-contract-${contract.id}'),
      onTap: onTap,
      hintTitle: 'Активный контракт',
      hintBody:
          'Откройте карточку, назначьте команду и следите за ETA. Без назначенных людей работает только минимальная мощность основателя.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppText(
                      template.client,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: contract.progress),
          const SizedBox(height: 8),
          AppText(
            '${(contract.progress * 100).toStringAsFixed(1)}% • ${daysLeft.toStringAsFixed(1)} дн.',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: AppText('Команда ${team.length}')),
              Chip(label: AppText('Роли ${(coverage * 100).round()}%')),
              Chip(
                label: AppText(
                  coverage >= 1 ? 'Команды хватает' : 'Не хватает команды',
                ),
              ),
              Chip(label: AppText(money(contract.reward))),
            ],
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
    final availableCoverage = state.contractOfferRoleCoverage(template);
    return AppCard(
      hintTitle: template.name,
      hintBody:
          'До принятия видно, хватает ли текущей команды. После принятия игра автоматически назначит наименее загруженных подходящих сотрудников.',
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
                    AppText(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppText(template.client),
                  ],
                ),
              ),
              AppText(
                money(template.reward),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText(template.description),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              Chip(label: AppText('${template.deadlineDays} дней')),
              Chip(label: AppText('${template.developmentHours.round()} ч.')),
              Chip(
                label: AppText(
                  'Доступные роли ${(availableCoverage * 100).round()}%',
                ),
              ),
              Chip(
                label: AppText(
                  availableCoverage >= 1
                      ? 'Команды хватает'
                      : 'Не хватает команды',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText(
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
              label: AppText(
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
