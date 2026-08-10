import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/catalog/v9_content_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/v9_models.dart';
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
            subtitle:
                'Нагрузка упирается в самый дефицитный ресурс: CU, RAM или storage. Железо также ограничено U, power, cooling и сетью.',
          ),
          const SizedBox(height: 10),
          AppCard(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 10) / 2;
                final items = <_InfrastructureStat>[
                  _InfrastructureStat(
                    'Офис',
                    state.office.name,
                    '${money(state.monthlyOfficeCost)}/мес.',
                  ),
                  _InfrastructureStat(
                    'Сотрудники',
                    '${state.onSiteEmployeeCount}/${state.office.capacity} office',
                    '${state.remoteEmployeeCount} remote',
                  ),
                  _InfrastructureStat(
                    'Hosting',
                    state.hostingPlan.name,
                    state.hostingPlan.kind == HostingKind.vps &&
                            !state.hasDevOps
                        ? '82% мощности без DevOps'
                        : 'операционка закрыта',
                  ),
                  _InfrastructureStat(
                    'Серверная',
                    state.serverRoom.name,
                    '${money(state.monthlyServerRoomCost)}/мес.',
                  ),
                  _InfrastructureStat(
                    'Compute',
                    '${state.totalComputeDemand.round()} / ${state.totalComputeUnits.round()} CU',
                    'нагрузка ${percent(state.serverLoad)}',
                  ),
                  _InfrastructureStat(
                    'Memory',
                    '${state.totalMemoryGb.round()} GB',
                    state.usingOwnedInfrastructure
                        ? 'собственная RAM'
                        : 'RAM активного hosting',
                  ),
                  _InfrastructureStat(
                    'Storage',
                    '${state.totalStorageGb.round()} GB',
                    'доступно продуктам',
                  ),
                  _InfrastructureStat(
                    'Rack / Power',
                    '${state.usedRackUnits.round()}/${state.serverRoom.rackUnits} U',
                    '${state.usedPowerKw.toStringAsFixed(1)}/${state.serverRoom.powerKw.toStringAsFixed(1)} kW',
                  ),
                  _InfrastructureStat(
                    'Cooling',
                    '${state.usedCoolingKw.toStringAsFixed(1)}/${state.serverRoom.coolingKw.toStringAsFixed(1)} kW',
                    'тепловой лимит',
                  ),
                  _InfrastructureStat(
                    'Network',
                    '${state.totalNetworkGbps.toStringAsFixed(1)} Gbps',
                    'активный канал',
                  ),
                ];
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: items
                      .map((item) => SizedBox(width: width, child: item))
                      .toList(growable: false),
                );
              },
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
          final productivityBoost = office.id == 'remote_first'
              ? 0
              : (((1.02 +
                                    office.comfortScore / 1000 +
                                    (office.communicationEfficiency - 0.90) *
                                        0.25)
                                .clamp(1.0, 1.20) -
                            1) *
                        100)
                    .round();
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
                      _ValueChip(
                        office.id == 'remote_first'
                            ? 'On-site performance недоступен'
                            : 'On-site performance +$productivityBoost%',
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
                      _ValueChip('${hardware.memoryGb.round()} GB RAM'),
                      _ValueChip('${hardware.storageGb.round()} GB storage'),
                      _ValueChip('${hardware.rackUnits} U'),
                      _ValueChip('Power ${hardware.powerKw} kW'),
                      _ValueChip('Heat ${hardware.heatKw} kW'),
                      _ValueChip('${hardware.networkGbps} Gbps'),
                      _ValueChip(
                        'SLA ${percent(hardware.hardwareReliability, fractionDigits: 2)}',
                      ),
                      _ValueChip(money(hardware.purchaseCost)),
                      _ValueChip(
                        '${money(hardware.purchaseCost / hardware.computeUnits)} за CU',
                      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Распределение compute',
          subtitle:
              'Выделено ${directPercent(state.totalAllocatedPercent)} из 100%. Каждый продукт использует только свой процент.',
        ),
        const SizedBox(height: 10),
        _OwnedMigrationCard(controller: controller),
        const SizedBox(height: 12),
        if (state.products.isEmpty)
          const AppCard(
            child: AppText('Создайте продукт, чтобы распределять мощности.'),
          )
        else ...[
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
            final value =
                drafts[product.id] ?? product.allocatedCapacityPercent;
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _ValueChip(
                          'CU ${state.productComputeDemand(product).round()} / ${state.allocatedComputeFor(product.id).round()}',
                        ),
                        _ValueChip(
                          'RAM ${state.productMemoryDemand(product).round()} / ${state.allocatedMemoryFor(product.id).round()} GB',
                        ),
                        _ValueChip(
                          'Storage ${state.productStorageDemand(product).round()} / ${state.allocatedStorageFor(product.id).round()} GB',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _OwnedMigrationCard extends StatelessWidget {
  const _OwnedMigrationCard({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final ownedPlan = V9ContentCatalog.hostingPlans.firstWhere(
      (plan) => plan.kind == HostingKind.owned,
    );
    final roles = state.employees.map((employee) => employee.role.name).toSet();
    final reasons = <String>[
      if (state.installedServers.isEmpty) 'Купите хотя бы один сервер.',
      if (!state.infrastructureFitsRoom)
        'Серверная не выдерживает rack, power или cooling.',
      if (!roles.contains('devOps')) 'Наймите DevOps-инженера.',
      if (!roles.contains('security')) 'Наймите Security Engineer.',
      if (state.cash < ownedPlan.setupCost)
        'Нужно ещё ${money(ownedPlan.setupCost - state.cash)} на миграцию.',
    ];
    final ready = reasons.isEmpty;
    return AppCard(
      key: const Key('owned-migration-capacity-card'),
      hintTitle: 'Переход на свои серверы',
      hintBody:
          'Сначала арендуйте серверную и установите железо. После миграции арендованный hosting отключается, а продуктам становится доступна подготовленная физическая мощность.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: AppText(
                  'Миграция на собственные серверы',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (state.usingOwnedInfrastructure)
                const Chip(label: AppText('Активно')),
            ],
          ),
          const SizedBox(height: 6),
          AppText(
            'Подготовлено ${state.preparedComputeUnits.round()} CU • стоимость перехода ${money(ownedPlan.setupCost)}.',
          ),
          if (!state.usingOwnedInfrastructure && reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: AppText(
                  '• $reason',
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
            ),
          ],
          if (!state.usingOwnedInfrastructure) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('migrate-to-owned-from-capacity'),
                onPressed: ready
                    ? () => controller.dispatch(
                        const MigrateToOwnedInfrastructure(),
                      )
                    : null,
                icon: const Icon(Icons.swap_horiz),
                label: AppText(
                  ready
                      ? 'Мигрировать на свои серверы'
                      : 'Миграция пока недоступна',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfrastructureStat extends StatelessWidget {
  const _InfrastructureStat(this.label, this.value, this.note);

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          AppText(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          AppText(
            note,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
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
