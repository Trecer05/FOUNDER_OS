import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/hosting_plans_panel.dart';
import '../../shared/widgets/responsive_info_row.dart';
import '../../shared/widgets/section_header.dart';
import '../../../application/localization/app_text.dart';

enum _InfraTab { hosting, offices, rooms, hardware, allocation }

class InfrastructureScreen extends StatefulWidget {
  const InfrastructureScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<InfrastructureScreen> createState() => _InfrastructureScreenState();
}

class _InfrastructureScreenState extends State<InfrastructureScreen> {
  _InfraTab _tab = _InfraTab.hosting;
  final Map<String, double> _allocationDrafts = <String, double>{};

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        SectionHeader(
          title: 'Инфраструктура',
          subtitle:
              'Активно ${state.totalComputeUnits.toStringAsFixed(0)} CU • подготовлено ${state.preparedComputeUnits.toStringAsFixed(0)} CU • офис ${money(state.monthlyOfficeCost)}/мес.',
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<_InfraTab>(
            segments: const [
              ButtonSegment(
                value: _InfraTab.hosting,
                label: AppText('Hosting'),
                icon: Icon(Icons.cloud_outlined),
              ),
              ButtonSegment(
                value: _InfraTab.offices,
                label: AppText('Офисы'),
                icon: Icon(Icons.business_outlined),
              ),
              ButtonSegment(
                value: _InfraTab.rooms,
                label: AppText('Серверные'),
                icon: Icon(Icons.meeting_room_outlined),
              ),
              ButtonSegment(
                value: _InfraTab.hardware,
                label: AppText('Серверы'),
                icon: Icon(Icons.dns_outlined),
              ),
              ButtonSegment(
                value: _InfraTab.allocation,
                label: AppText('Мощности'),
                icon: Icon(Icons.pie_chart_outline),
              ),
            ],
            selected: <_InfraTab>{_tab},
            onSelectionChanged: (value) => setState(() => _tab = value.first),
          ),
        ),
        const SizedBox(height: 14),
        switch (_tab) {
          _InfraTab.hosting => HostingPlansPanel(controller: widget.controller),
          _InfraTab.offices => _OfficesList(controller: widget.controller),
          _InfraTab.rooms => _ServerRoomsList(controller: widget.controller),
          _InfraTab.hardware => _HardwareList(controller: widget.controller),
          _InfraTab.allocation => _AllocationList(
            controller: widget.controller,
            drafts: _allocationDrafts,
            onDraftChanged: (id, value) =>
                setState(() => _allocationDrafts[id] = value),
          ),
        },
        if (_tab != _InfraTab.allocation) ...[
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Текущая конфигурация',
            subtitle: 'Физические ограничения считаются в U, kW, Gbps и CU.',
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                ResponsiveInfoRow(
                  'Офис',
                  '${state.office.name} • аренда ${money(state.office.monthlyRent)}/мес. • списание ${money(state.monthlyOfficeCost)}/мес.',
                ),
                ResponsiveInfoRow(
                  'Сотрудники',
                  '${state.onSiteEmployeeCount}/${state.office.capacity} в офисе • ${state.remoteEmployeeCount} remote',
                ),
                ResponsiveInfoRow('Hosting', state.hostingPlan.name),
                ResponsiveInfoRow(
                  'Серверная',
                  '${state.serverRoom.name} • аренда ${money(state.serverRoom.monthlyRent)}/мес. • ${state.usingOwnedInfrastructure ? 'активна' : 'подготовка к миграции'}',
                ),
                ResponsiveInfoRow(
                  'Rack',
                  '${state.usedRackUnits.toStringAsFixed(0)} / ${state.serverRoom.rackUnits} U',
                ),
                ResponsiveInfoRow(
                  'Power',
                  '${state.usedPowerKw.toStringAsFixed(1)} / ${state.serverRoom.powerKw.toStringAsFixed(1)} kW',
                ),
                ResponsiveInfoRow(
                  'Cooling',
                  '${state.usedCoolingKw.toStringAsFixed(1)} / ${state.serverRoom.coolingKw.toStringAsFixed(1)} kW',
                ),
                ResponsiveInfoRow(
                  'Network',
                  '${state.totalNetworkGbps.toStringAsFixed(1)} Gbps',
                ),
                ResponsiveInfoRow(
                  'Активный Compute',
                  '${state.totalComputeUnits.round()} CU',
                ),
                ResponsiveInfoRow(
                  'Серверы в резерве',
                  '${state.preparedComputeUnits.round()} CU • ${state.usingOwnedInfrastructure ? 'активны' : 'не учитываются до миграции'}',
                ),
                ResponsiveInfoRow(
                  'Общая загрузка',
                  percent(state.serverLoad, fractionDigits: 1),
                  last: true,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _OfficesList extends StatelessWidget {
  const _OfficesList({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Аренда офиса',
          subtitle: state.selectedOfficeId == 'remote_first'
              ? 'Remote-first: аренды нет, on-site места появятся после выбора офиса.'
              : 'Аренда офиса списывается независимо от заполнения; комфорт и вместимость влияют на команду.',
        ),
        const SizedBox(height: 10),
        ...GameCatalog.offices.map((office) {
          final current = office.id == state.selectedOfficeId;
          final canRent =
              office.capacity >= state.onSiteEmployeeCount &&
              state.cash >= office.deposit;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
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
                              office.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            AppText(
                              '${office.group} • аренда ${money(office.monthlyRent)}/мес.',
                            ),
                            if (office.id == 'remote_first')
                              AppText(
                                '0 ₽/мес. • on-site мест нет • remote-сотрудники доступны.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      if (current)
                        const _CurrentChip()
                      else
                        FilledButton(
                          onPressed: canRent
                              ? () => controller.dispatch(RentOffice(office.id))
                              : null,
                          child: const AppText('Арендовать'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppText(office.description),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _ValueChip('${office.capacity} мест'),
                      _ValueChip('Комфорт ${office.comfortScore}/100'),
                      _ValueChip(
                        'Коммуникация ×${office.communicationEfficiency.toStringAsFixed(2)}',
                      ),
                      _ValueChip(
                        'Бонус к найму +${(office.hiringBoostPercent * 100).round()}%',
                      ),
                      _ValueChip('Престиж ${office.prestigeScore}/100'),
                      _ValueChip('Депозит ${money(office.deposit)}'),
                    ],
                  ),
                  if (!current && !canRent)
                    const Padding(
                      padding: EdgeInsets.only(top: 9),
                      child: AppText(
                        'Блокировка: не хватает денег или мест для текущей команды.',
                        style: TextStyle(color: AppColors.red),
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
}

class _ServerRoomsList extends StatelessWidget {
  const _ServerRoomsList({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Аренда серверной',
          subtitle:
              'Вместимость, охлаждение и электропитание ограничивают устанавливаемое железо.',
        ),
        const SizedBox(height: 10),
        ...GameCatalog.serverRooms.map((room) {
          final current = room.id == state.selectedServerRoomId;
          final canRent =
              state.usedRackUnits <= room.rackUnits &&
              state.usedCoolingKw <= room.coolingKw &&
              state.usedPowerKw <= room.powerKw &&
              state.cash >= room.deposit;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
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
                              room.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            AppText(
                              '${room.group} • ${money(room.monthlyRent)}/мес.',
                            ),
                          ],
                        ),
                      ),
                      if (current)
                        const _CurrentChip()
                      else
                        FilledButton(
                          onPressed: canRent
                              ? () =>
                                    controller.dispatch(RentServerRoom(room.id))
                              : null,
                          child: const AppText('Арендовать'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppText(room.description),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _ValueChip('${room.rackUnits} U'),
                      _ValueChip('Cooling ${room.coolingKw} kW'),
                      _ValueChip('Power ${room.powerKw} kW'),
                      _ValueChip('${room.networkGbps} Gbps'),
                      _ValueChip('Security ${room.physicalSecurityScore}/100'),
                      _ValueChip('Депозит ${money(room.deposit)}'),
                    ],
                  ),
                  if (!current && !canRent)
                    const Padding(
                      padding: EdgeInsets.only(top: 9),
                      child: AppText(
                        'Блокировка: текущее железо не помещается или не хватает депозита.',
                        style: TextStyle(color: AppColors.red),
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
}

class _HardwareList extends StatelessWidget {
  const _HardwareList({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Серверное железо',
          subtitle:
              'Каждый сервер занимает rack, потребляет питание и выделяет тепло.',
        ),
        const SizedBox(height: 10),
        ...GameCatalog.serverHardware.map((hardware) {
          final count = state.installedCount(hardware.id);
          final canInstall =
              state.cash >= hardware.purchaseCost &&
              state.usedRackUnits + hardware.rackUnits <=
                  state.serverRoom.rackUnits &&
              state.usedCoolingKw + hardware.heatKw <=
                  state.serverRoom.coolingKw &&
              state.usedPowerKw + hardware.powerKw <= state.serverRoom.powerKw;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
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
                              hardware.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            AppText('${hardware.group} • установлено $count'),
                          ],
                        ),
                      ),
                      IconButton.outlined(
                        onPressed: count > 0
                            ? () =>
                                  controller.dispatch(RemoveServer(hardware.id))
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 6),
                      IconButton.filled(
                        onPressed: canInstall
                            ? () => controller.dispatch(
                                InstallServer(hardware.id),
                              )
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppText(hardware.description),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _ValueChip('${hardware.computeUnits.round()} CU'),
                      _ValueChip('${hardware.rackUnits} U'),
                      _ValueChip('Power ${hardware.powerKw} kW'),
                      _ValueChip('Heat ${hardware.heatKw} kW'),
                      _ValueChip('${hardware.networkGbps} Gbps'),
                      _ValueChip(
                        'SLA ${percent(hardware.hardwareReliability, fractionDigits: 2)}',
                      ),
                      _ValueChip(money(hardware.purchaseCost)),
                      _ValueChip('${money(hardware.monthlyCost)}/мес.'),
                    ],
                  ),
                  if (!canInstall)
                    const Padding(
                      padding: EdgeInsets.only(top: 9),
                      child: AppText(
                        'Установка заблокирована: проверьте деньги, U, power и cooling.',
                        style: TextStyle(color: AppColors.red),
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
}

class _AllocationList extends StatelessWidget {
  const _AllocationList({
    required this.controller,
    required this.drafts,
    required this.onDraftChanged,
  });

  final GameController controller;
  final Map<String, double> drafts;
  final void Function(String id, double value) onDraftChanged;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    if (state.products.isEmpty) {
      return const AppCard(
        child: AppText('Создайте продукт, чтобы распределять мощности.'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Распределение compute',
          subtitle:
              'Выделено ${directPercent(state.totalAllocatedPercent)} из 100%. Каждый продукт использует только свой процент.',
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (state.totalAllocatedPercent / 100)
                    .clamp(0, 1)
                    .toDouble(),
                color: state.totalAllocatedPercent <= 100
                    ? AppColors.primary
                    : AppColors.red,
              ),
              const SizedBox(height: 8),
              ResponsiveInfoRow(
                'Всего Compute',
                '${state.totalComputeUnits.round()} CU',
              ),
              ResponsiveInfoRow(
                'Свободно',
                directPercent(100 - state.totalAllocatedPercent),
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...state.products.map((product) {
          final value = drafts[product.id] ?? product.allocatedCapacityPercent;
          final load = state.productServerLoad(product);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
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
                              product.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            AppText(
                              '${categoryName(product.category)} • load ${percent(load, fractionDigits: 1)}',
                            ),
                          ],
                        ),
                      ),
                      AppText(
                        '${value.round()}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Slider(
                    value: value.clamp(0, 100).toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${value.round()}%',
                    onChanged: (next) => onDraftChanged(product.id, next),
                    onChangeEnd: (next) {
                      controller.dispatch(
                        SetProductAllocation(
                          productId: product.id,
                          percent: next,
                        ),
                      );
                      final applied = controller.state
                          .productById(product.id)!
                          .allocatedCapacityPercent;
                      onDraftChanged(product.id, applied);
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          'Доступно: ${state.allocatedComputeFor(product.id).round()} CU',
                        ),
                      ),
                      AppText(
                        'Нужно: ${state.productComputeDemand(product).round()} CU',
                      ),
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
}

class _CurrentChip extends StatelessWidget {
  const _CurrentChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.green.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const AppText(
        'Текущий',
        style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: AppText(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
