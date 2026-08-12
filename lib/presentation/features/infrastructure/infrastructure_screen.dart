import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/catalog/v9_content_catalog.dart';
import '../../../domain/catalog/world_economy_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/v9_models.dart';
import '../../../domain/entities/v16_models.dart';
import '../../../domain/entities/v17_models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/hosting_plans_panel.dart';
import '../../shared/widgets/responsive_info_row.dart';
import '../../shared/widgets/section_header.dart';
import '../../../application/localization/app_text.dart';
import '../../../application/localization/app_localizer.dart';
import '../products/product_workspace_screen.dart';

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

  static const _tabs = <(_InfraTab, IconData, String)>[
    (_InfraTab.hosting, Icons.cloud_outlined, 'Hosting'),
    (_InfraTab.offices, Icons.business_outlined, 'Офисы'),
    (_InfraTab.rooms, Icons.meeting_room_outlined, 'Серверные'),
    (_InfraTab.hardware, Icons.dns_outlined, 'Серверы'),
    (_InfraTab.allocation, Icons.pie_chart_outline, 'Мощности'),
  ];

  Widget _tabSelector() => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 620) {
        return Material(
          type: MaterialType.transparency,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in _tabs)
                ChoiceChip(
                  key: Key('infra-tab-${item.$1.name}'),
                  avatar: Icon(item.$2, size: 18),
                  label: AppText(item.$3),
                  selected: _tab == item.$1,
                  onSelected: (_) => setState(() => _tab = item.$1),
                ),
            ],
          ),
        );
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<_InfraTab>(
          segments: [
            for (final item in _tabs)
              ButtonSegment<_InfraTab>(
                value: item.$1,
                label: AppText(item.$3),
                icon: Icon(item.$2),
              ),
          ],
          selected: <_InfraTab>{_tab},
          onSelectionChanged: (value) => setState(() => _tab = value.first),
        ),
      );
    },
  );

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
        _tabSelector(),
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
                    '${state.onSiteEmployeeCount}/${state.totalOfficeCapacity} office',
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
                    '${state.usedRackUnits.round()}/${state.effectiveRackUnits.round()} U',
                    '${state.usedPowerKw.toStringAsFixed(1)}/${state.effectivePowerKw.toStringAsFixed(1)} kW',
                  ),
                  _InfrastructureStat(
                    'Cooling',
                    '${state.usedCoolingKw.toStringAsFixed(1)}/${state.effectiveCoolingKw.toStringAsFixed(1)} kW',
                    '${state.ownedDataCenters.length} собственных ЦОД',
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
          title: 'Собственные офисы',
          subtitle:
              'Стройте несколько офисов в разных городах. География меняет зарплаты, налоги, коммунальные расходы, доступ к талантам, инвесторам и рынку.',
        ),
        const SizedBox(height: 10),
        if (state.ownedOffices.isEmpty)
          const AppCard(
            child: AppText(
              'Собственных офисов пока нет. Аренда остаётся быстрым стартом, строительство — долгосрочная инвестиция.',
            ),
          )
        else
          ...state.ownedOffices.map((site) {
            final city = WorldEconomyCatalog.cityById(site.cityId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '${state.ownedOfficeLabel(site)} · ${city.cityRu}, ${city.countryRu}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ResponsiveInfoRow(
                      'Размер и места',
                      '${_facilitySizeName(site.size)} · ${WorldEconomyCatalog.officeCapacity(site.size)} мест',
                    ),
                    ResponsiveInfoRow(
                      'Ремонт / оснащение',
                      '${_facilityQualityName(site.fitoutQuality)} / ${_facilityQualityName(site.equipmentQuality)}',
                    ),
                    ResponsiveInfoRow(
                      'Таланты / инвесторы / рынок',
                      '${city.talentScore} / ${city.investorScore} / ${city.marketAccessScore}',
                    ),
                    ResponsiveInfoRow(
                      'Содержание',
                      '${money(WorldEconomyCatalog.officeMonthlyCost(site))}/мес.',
                      last: true,
                    ),
                  ],
                ),
              ),
            );
          }),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('build-owned-office'),
            onPressed: () => _showBuildOfficeDialog(context, controller),
            icon: const Icon(Icons.add_business_outlined),
            label: const AppText('Построить собственный офис'),
          ),
        ),
        const SizedBox(height: 22),
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
          final headquartersCapacity =
              office.capacity +
              state.ownedOfficeCapacityIn(state.headquartersCityId);
          final canRent =
              headquartersCapacity >=
                  state.onSiteEmployeesIn(state.headquartersCityId) &&
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
        SectionHeader(
          title: 'Собственные дата-центры',
          subtitle:
              'Можно строить несколько ЦОД в разных городах. Размер определяет физический потолок, качество — эксплуатационные характеристики, а город — энергию, сеть и стоимость содержания.',
        ),
        const SizedBox(height: 10),
        if (state.ownedDataCenters.isEmpty)
          const AppCard(
            child: AppText(
              'Собственных ЦОД пока нет. Серверная в аренде подходит для первого железа, свои площадки нужны для масштабирования.',
            ),
          )
        else
          ...state.ownedDataCenters.map((site) {
            final city = WorldEconomyCatalog.cityById(site.cityId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '${state.ownedDataCenterLabel(site)} · ${city.cityRu}, ${city.countryRu}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ResponsiveInfoRow(
                      'Размер / стойки',
                      '${_facilitySizeName(site.size)} · ${WorldEconomyCatalog.dataCenterRackUnits(site.size)} U',
                    ),
                    ResponsiveInfoRow(
                      'Сеть',
                      '${WorldEconomyCatalog.dataCenterNetworkGbps(site).toStringAsFixed(1)} Gbps',
                    ),
                    ResponsiveInfoRow(
                      'Power / Cooling',
                      '${WorldEconomyCatalog.dataCenterPowerKw(site).toStringAsFixed(1)} / ${WorldEconomyCatalog.dataCenterCoolingKw(site).toStringAsFixed(1)} kW',
                    ),
                    ResponsiveInfoRow(
                      'Помещение / оборудование',
                      '${_facilityQualityName(site.facilityQuality)} / ${_facilityQualityName(site.equipmentQuality)}',
                    ),
                    ResponsiveInfoRow(
                      'Содержание',
                      '${money(WorldEconomyCatalog.dataCenterMonthlyCost(site))}/мес.',
                      last: true,
                    ),
                  ],
                ),
              ),
            );
          }),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('build-owned-datacenter'),
            onPressed: () => _showBuildDataCenterDialog(context, controller),
            icon: const Icon(Icons.domain_add_outlined),
            label: const AppText('Построить дата-центр'),
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeader(
          title: 'Аренда серверной',
          subtitle:
              'Вместимость, охлаждение и электропитание ограничивают устанавливаемое железо.',
        ),
        const SizedBox(height: 10),
        ...GameCatalog.serverRooms.map((room) {
          final current = room.id == state.selectedServerRoomId;
          final canRent =
              state.usedRackUnitsAtDataCenter('') <= room.rackUnits &&
              state.usedCoolingKwAtDataCenter('') <= room.coolingKw &&
              state.usedPowerKwAtDataCenter('') <= room.powerKw &&
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

    String serviceName(InfrastructureService service) => switch (service) {
      InfrastructureService.appApi => 'API / приложение',
      InfrastructureService.dataStorage => 'Data / storage',
      InfrastructureService.aiCompute => 'AI / compute',
      InfrastructureService.sharedLegacy => 'Legacy shared',
    };

    const installServices = <InfrastructureService>[
      InfrastructureService.appApi,
      InfrastructureService.dataStorage,
      InfrastructureService.aiCompute,
    ];

    bool canInstallAt(ServerHardwareOption hardware, String siteId) {
      if (state.cash < hardware.purchaseCost) {
        return false;
      }
      if (siteId.isEmpty) {
        return state.usedRackUnitsAtDataCenter('') + hardware.rackUnits <=
                state.serverRoom.rackUnits &&
            state.usedCoolingKwAtDataCenter('') + hardware.heatKw <=
                state.serverRoom.coolingKw &&
            state.usedPowerKwAtDataCenter('') + hardware.powerKw <=
                state.serverRoom.powerKw;
      }
      final site = state.ownedDataCenters.firstWhere(
        (item) => item.id == siteId,
      );
      return state.usedRackUnitsAtDataCenter(site.id) + hardware.rackUnits <=
              WorldEconomyCatalog.dataCenterRackUnits(site.size) &&
          state.usedCoolingKwAtDataCenter(site.id) + hardware.heatKw <=
              WorldEconomyCatalog.dataCenterCoolingKw(site) &&
          state.usedPowerKwAtDataCenter(site.id) + hardware.powerKw <=
              WorldEconomyCatalog.dataCenterPowerKw(site);
    }

    List<MapEntry<String, String>> locationsFor(ServerHardwareOption hardware) {
      final result = <MapEntry<String, String>>[
        MapEntry('', 'Арендная серверная • ${state.serverRoom.name}'),
      ];
      for (final site in state.ownedDataCenters) {
        final city = WorldEconomyCatalog.cityById(site.cityId);
        result.add(
          MapEntry(
            site.id,
            '${state.ownedDataCenterLabel(site)} • ${city.cityRu}',
          ),
        );
      }
      return result.where((item) => canInstallAt(hardware, item.key)).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Серверное железо',
          subtitle:
              'При покупке выберите площадку и назначение сервера. API, storage и AI/compute получают только свой выделенный пул; legacy-серверы старого сейва остаются shared до замены.',
        ),
        const SizedBox(height: 10),
        ...GameCatalog.serverHardware.map((hardware) {
          final count = state.installedCount(hardware.id);
          final installLocations = locationsFor(hardware);
          final installedLocations = state.installedServers
              .where((item) => item.hardwareId == hardware.id && item.count > 0)
              .toList(growable: false);
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
                      PopupMenuButton<String>(
                        enabled: installedLocations.isNotEmpty,
                        tooltip: trContext(context, 'Снять сервер с площадки'),
                        onSelected: (value) {
                          final parts = value.split('::');
                          final siteId = parts.first;
                          final service = InfrastructureService.values.byName(
                            parts.last,
                          );
                          controller.dispatch(
                            RemoveServer(
                              hardware.id,
                              dataCenterSiteId: siteId.isEmpty ? null : siteId,
                              service: service,
                            ),
                          );
                        },
                        itemBuilder: (_) => installedLocations
                            .map((item) {
                              final siteLabel = item.dataCenterSiteId.isEmpty
                                  ? 'Арендная серверная'
                                  : '${state.ownedDataCenterLabel(state.ownedDataCenters.firstWhere((site) => site.id == item.dataCenterSiteId))} · ${WorldEconomyCatalog.cityById(state.ownedDataCenters.firstWhere((site) => site.id == item.dataCenterSiteId).cityId).cityRu}';
                              final label =
                                  '$siteLabel • ${serviceName(item.service)} • ${item.count} шт.';
                              return PopupMenuItem(
                                value:
                                    '${item.dataCenterSiteId}::${item.service.name}',
                                child: AppText(label),
                              );
                            })
                            .toList(growable: false),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.remove),
                        ),
                      ),
                      const SizedBox(width: 6),
                      PopupMenuButton<String>(
                        enabled: installLocations.isNotEmpty,
                        tooltip: trContext(
                          context,
                          'Выбрать площадку и сервис',
                        ),
                        onSelected: (value) {
                          final parts = value.split('::');
                          final siteId = parts.first;
                          final service = InfrastructureService.values.byName(
                            parts.last,
                          );
                          controller.dispatch(
                            InstallServer(
                              hardware.id,
                              dataCenterSiteId: siteId.isEmpty ? null : siteId,
                              service: service,
                            ),
                          );
                        },
                        itemBuilder: (_) => <PopupMenuEntry<String>>[
                          for (final item in installLocations)
                            for (final service in installServices)
                              PopupMenuItem<String>(
                                value: '${item.key}::${service.name}',
                                child: AppText(
                                  '${item.value} • ${serviceName(service)}',
                                ),
                              ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: installLocations.isEmpty
                                ? AppColors.surfaceMuted
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add,
                            color: installLocations.isEmpty
                                ? AppColors.textMuted
                                : Colors.white,
                          ),
                        ),
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
                  if (installLocations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 9),
                      child: AppText(
                        'Нет площадки с достаточным U, power и cooling или не хватает денег.',
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
        const SectionHeader(
          title: 'Мощности по сервисам',
          subtitle:
              'API, storage и compute назначаются отдельно. Один продукт может использовать hosting, другой — свой ЦОД, а внутри одного продукта сервисы тоже можно развести.',
        ),
        const SizedBox(height: 10),
        _OwnedMigrationCard(controller: controller),
        const SizedBox(height: 12),
        if (state.products.isEmpty)
          const AppCard(
            child: AppText('Создайте продукт, чтобы распределять мощности.'),
          )
        else ...[
          ...const <InfrastructureService>[
            InfrastructureService.appApi,
            InfrastructureService.dataStorage,
            InfrastructureService.aiCompute,
          ].map((service) {
            final title = switch (service) {
              InfrastructureService.sharedLegacy => 'Legacy',
              InfrastructureService.appApi => 'API / приложение',
              InfrastructureService.dataStorage => 'Storage / данные',
              InfrastructureService.aiCompute => 'Compute / AI / backend jobs',
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                key: Key('infra-service-group-${service.name}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      service == InfrastructureService.appApi
                          ? 'Отвечает за API, application RAM и сеть.'
                          : service == InfrastructureService.dataStorage
                          ? 'Файлы, базы, логи и резервные данные.'
                          : 'CPU/GPU/AI inference и тяжёлые backend-задачи.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    ...state.products.map((product) {
                      final rawRoute = state.dataCenterRouteFor(
                        product.id,
                        service,
                      );
                      final hosting = state.routedHostingFor(
                        product.id,
                        service,
                      );
                      final ownedMatches = state.ownedDataCenters
                          .where((item) => item.id == rawRoute)
                          .toList(growable: false);
                      final routeName = hosting != null
                          ? hosting.name
                          : rawRoute.isEmpty
                          ? state.selectedServerRoomId == 'no_server_room'
                                ? 'Не назначено'
                                : state.serverRoom.name
                          : ownedMatches.isNotEmpty
                          ? state.ownedDataCenterLabel(ownedMatches.first)
                          : 'Не назначено';
                      final routeCost = hosting?.monthlyCost;
                      final demand = switch (service) {
                        InfrastructureService.sharedLegacy => 0.0,
                        InfrastructureService.appApi =>
                          state.productMemoryDemand(product),
                        InfrastructureService.dataStorage =>
                          state.productStorageDemand(product),
                        InfrastructureService.aiCompute =>
                          state.productComputeDemand(product),
                      };
                      final allocated = switch (service) {
                        InfrastructureService.sharedLegacy => 0.0,
                        InfrastructureService.appApi =>
                          state.allocatedMemoryFor(product.id),
                        InfrastructureService.dataStorage =>
                          state.allocatedStorageFor(product.id),
                        InfrastructureService.aiCompute =>
                          state.allocatedComputeFor(product.id),
                      };
                      final unit = switch (service) {
                        InfrastructureService.appApi => 'GB RAM',
                        InfrastructureService.dataStorage => 'GB',
                        InfrastructureService.aiCompute => 'CU',
                        InfrastructureService.sharedLegacy => '',
                      };
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Material(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppText(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    AppText(
                                      '${demand.toStringAsFixed(0)} / ${allocated.toStringAsFixed(0)} $unit',
                                      translate: false,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(child: AppText(routeName)),
                                    if (routeCost != null)
                                      AppText('${money(routeCost)}/мес.'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                TextButton.icon(
                                  onPressed: () =>
                                      Navigator.of(context).push<void>(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ProductWorkspaceScreen(
                                                controller: controller,
                                                productId: product.id,
                                              ),
                                        ),
                                      ),
                                  icon: const Icon(Icons.route_outlined),
                                  label: const AppText('Изменить маршрут'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          const SectionHeader(
            title: 'Распределение доли compute',
            subtitle:
                'Процент определяет долю общего пула там, где несколько продуктов используют одну и ту же площадку.',
          ),
          const SizedBox(height: 10),
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
                          child: AppText(
                            product.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        AppText('${value.round()}%'),
                      ],
                    ),
                    AppText(
                      'load ${percent(load, fractionDigits: 1)} • API ${state.allocatedMemoryFor(product.id).round()} GB • storage ${state.allocatedStorageFor(product.id).round()} GB • compute ${state.allocatedComputeFor(product.id).round()} CU',
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

String _facilitySizeName(FacilitySize size) => switch (size) {
  FacilitySize.small => 'Небольшой',
  FacilitySize.medium => 'Средний',
  FacilitySize.large => 'Большой',
  FacilitySize.campus => 'Кампус',
};

String _facilityQualityName(FacilityQuality quality) => switch (quality) {
  FacilityQuality.basic => 'Базовый',
  FacilityQuality.standard => 'Стандарт',
  FacilityQuality.premium => 'Премиум',
};

Future<void> _showBuildOfficeDialog(
  BuildContext context,
  GameController controller,
) async {
  var cityId = controller.state.headquartersCityId;
  var size = FacilitySize.small;
  var fitout = FacilityQuality.standard;
  var equipment = FacilityQuality.standard;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        final city = WorldEconomyCatalog.cityById(cityId);
        final draft = OwnedOfficeSite(
          id: 'preview',
          cityId: cityId,
          size: size,
          fitoutQuality: fitout,
          equipmentQuality: equipment,
          builtAtMinutes: controller.state.simulationMinutes,
        );
        final buildCost = WorldEconomyCatalog.officeBuildCost(
          cityId: cityId,
          size: size,
          fitout: fitout,
          equipment: equipment,
        );
        final monthly = WorldEconomyCatalog.officeMonthlyCost(draft);
        return AlertDialog(
          title: const AppText('Построить собственный офис'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: cityId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: trContext(context, 'Город'),
                    ),
                    items: WorldEconomyCatalog.cities
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: AppText('${item.cityRu}, ${item.countryRu}'),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => cityId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<FacilitySize>(
                    initialValue: size,
                    decoration: InputDecoration(
                      labelText: trContext(context, 'Размер'),
                    ),
                    items: FacilitySize.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: AppText(_facilitySizeName(item)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => size = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<FacilityQuality>(
                    initialValue: fitout,
                    decoration: InputDecoration(
                      labelText: trContext(context, 'Качество ремонта'),
                    ),
                    items: FacilityQuality.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: AppText(_facilityQualityName(item)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => fitout = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<FacilityQuality>(
                    initialValue: equipment,
                    decoration: InputDecoration(
                      labelText: trContext(context, 'Качество оснащения'),
                    ),
                    items: FacilityQuality.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: AppText(_facilityQualityName(item)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => equipment = value);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    child: Column(
                      children: [
                        ResponsiveInfoRow('Строительство', money(buildCost)),
                        ResponsiveInfoRow(
                          'Содержание',
                          '${money(monthly)}/мес.',
                        ),
                        ResponsiveInfoRow(
                          'Места',
                          '${WorldEconomyCatalog.officeCapacity(size)}',
                        ),
                        ResponsiveInfoRow(
                          'Налог на прибыль',
                          '${(city.corporateTaxRate * 100).toStringAsFixed(1)}%',
                        ),
                        ResponsiveInfoRow(
                          'Payroll tax',
                          '${(city.payrollTaxRate * 100).toStringAsFixed(1)}%',
                        ),
                        ResponsiveInfoRow(
                          'Зарплаты',
                          '×${city.salaryMultiplier.toStringAsFixed(2)}',
                        ),
                        ResponsiveInfoRow('Таланты', '${city.talentScore}/100'),
                        ResponsiveInfoRow(
                          'Инвесторы',
                          '${city.investorScore}/100',
                        ),
                        ResponsiveInfoRow(
                          'Доступ к рынку',
                          '${city.marketAccessScore}/100',
                          last: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const AppText('Отмена'),
            ),
            FilledButton(
              onPressed: controller.state.cash >= buildCost
                  ? () {
                      controller.dispatch(
                        BuildOwnedOffice(
                          cityId: cityId,
                          size: size,
                          fitoutQuality: fitout,
                          equipmentQuality: equipment,
                        ),
                      );
                      Navigator.pop(dialogContext);
                    }
                  : null,
              child: const AppText('Строить'),
            ),
          ],
        );
      },
    ),
  );
}

Future<void> _showBuildDataCenterDialog(
  BuildContext context,
  GameController controller,
) async {
  var cityId = controller.state.headquartersCityId;
  var size = FacilitySize.small;
  var facility = FacilityQuality.standard;
  var equipment = FacilityQuality.standard;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        final city = WorldEconomyCatalog.cityById(cityId);
        final draft = OwnedDataCenterSite(
          id: 'preview',
          cityId: cityId,
          size: size,
          facilityQuality: facility,
          equipmentQuality: equipment,
          builtAtMinutes: controller.state.simulationMinutes,
        );
        final buildCost = WorldEconomyCatalog.dataCenterBuildCost(
          cityId: cityId,
          size: size,
          facility: facility,
          equipment: equipment,
        );
        final monthly = WorldEconomyCatalog.dataCenterMonthlyCost(draft);
        return AlertDialog(
          title: const AppText('Построить дата-центр'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: cityId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: trContext(context, 'Город'),
                    ),
                    items: WorldEconomyCatalog.cities
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: AppText('${item.cityRu}, ${item.countryRu}'),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => cityId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<FacilitySize>(
                    initialValue: size,
                    decoration: InputDecoration(
                      labelText: trContext(context, 'Размер площадки'),
                    ),
                    items: FacilitySize.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: AppText(_facilitySizeName(item)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => size = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<FacilityQuality>(
                    initialValue: facility,
                    decoration: InputDecoration(
                      labelText: trContext(context, 'Качество помещения'),
                    ),
                    items: FacilityQuality.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: AppText(_facilityQualityName(item)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => facility = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<FacilityQuality>(
                    initialValue: equipment,
                    decoration: InputDecoration(
                      labelText: trContext(context, 'Инженерное оборудование'),
                    ),
                    items: FacilityQuality.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: AppText(_facilityQualityName(item)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => equipment = value);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    child: Column(
                      children: [
                        ResponsiveInfoRow('Строительство', money(buildCost)),
                        ResponsiveInfoRow(
                          'Содержание',
                          '${money(monthly)}/мес.',
                        ),
                        ResponsiveInfoRow(
                          'Rack',
                          '${WorldEconomyCatalog.dataCenterRackUnits(size)} U',
                        ),
                        ResponsiveInfoRow(
                          'Power',
                          '${WorldEconomyCatalog.dataCenterPowerKw(draft).toStringAsFixed(1)} kW',
                        ),
                        ResponsiveInfoRow(
                          'Cooling',
                          '${WorldEconomyCatalog.dataCenterCoolingKw(draft).toStringAsFixed(1)} kW',
                        ),
                        ResponsiveInfoRow(
                          'Network',
                          '${WorldEconomyCatalog.dataCenterNetworkGbps(draft).toStringAsFixed(1)} Gbps',
                        ),
                        ResponsiveInfoRow(
                          'Коммунальные',
                          '×${city.utilityMultiplier.toStringAsFixed(2)}',
                          last: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const AppText('Отмена'),
            ),
            FilledButton(
              onPressed: controller.state.cash >= buildCost
                  ? () {
                      controller.dispatch(
                        BuildOwnedDataCenter(
                          cityId: cityId,
                          size: size,
                          facilityQuality: facility,
                          equipmentQuality: equipment,
                        ),
                      );
                      Navigator.pop(dialogContext);
                    }
                  : null,
              child: const AppText('Строить'),
            ),
          ],
        );
      },
    ),
  );
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
