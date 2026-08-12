import 'package:flutter/material.dart';

import '../../../application/controllers/game_controller.dart';
import '../../../application/localization/app_text.dart';
import '../../../application/localization/app_localizer.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/catalog/v17_endgame_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/v17_models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';

enum _CompanyHubSection { notifications, opportunities, legacy }

class CompanyHubScreen extends StatefulWidget {
  const CompanyHubScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<CompanyHubScreen> createState() => _CompanyHubScreenState();
}

class _CompanyHubScreenState extends State<CompanyHubScreen> {
  _CompanyHubSection _section = _CompanyHubSection.notifications;
  final Map<String, Set<String>> _eventSelections = <String, Set<String>>{};

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    return ListView(
      key: const Key('company-hub-list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        SectionHeader(
          title: 'События компании',
          subtitle: 'Непрочитанных: ${state.unreadCompanyNotificationCount}',
          hintTitle: 'Зачем нужна эта вкладка',
          hintBody:
              'Здесь собраны события, которые нельзя терять из виду: уходы сотрудников, легенды рынка, инвесторы, налоги, мероприятия, R&D и мировые проекты.',
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<_CompanyHubSection>(
            key: const Key('company-hub-sections'),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: _CompanyHubSection.notifications,
                icon: Icon(Icons.notifications_outlined),
                label: AppText('Уведомления'),
              ),
              ButtonSegment(
                value: _CompanyHubSection.opportunities,
                icon: Icon(Icons.event_available_outlined),
                label: AppText('Возможности'),
              ),
              ButtonSegment(
                value: _CompanyHubSection.legacy,
                icon: Icon(Icons.public_outlined),
                label: AppText('Наследие'),
              ),
            ],
            selected: <_CompanyHubSection>{_section},
            onSelectionChanged: (value) =>
                setState(() => _section = value.first),
          ),
        ),
        const SizedBox(height: 14),
        switch (_section) {
          _CompanyHubSection.notifications => _notifications(state),
          _CompanyHubSection.opportunities => _opportunities(state),
          _CompanyHubSection.legacy => _legacy(state),
        },
      ],
    );
  }

  Widget _notifications(GameState state) {
    final items = state.companyNotifications.take(80).toList(growable: false);
    return Column(
      key: const Key('company-notifications'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText(
                'Важные события',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton.icon(
              key: const Key('mark-company-notifications-read'),
              onPressed: state.unreadCompanyNotificationCount == 0
                  ? null
                  : () => widget.controller.dispatch(
                      const MarkAllCompanyNotificationsRead(),
                    ),
              icon: const Icon(Icons.done_all_outlined),
              label: const AppText('Прочитать все'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const AppCard(
            child: AppText(
              'Пока тихо. Здесь появятся налоги, предложения, легенды, R&D и кадровые риски.',
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_notificationIcon(item.kind)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.read
                                  ? FontWeight.w700
                                  : FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          AppText(item.body),
                          const SizedBox(height: 4),
                          AppText(
                            'День ${item.simulationMinutes ~/ 1440 + 1}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (!item.read)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.circle, size: 9),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _opportunities(GameState state) {
    final liveProducts = state.products
        .where((item) => item.stage == ProductStage.live)
        .toList(growable: false);
    return Column(
      key: const Key('company-opportunities'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Мероприятия',
          subtitle:
              'Возможности появляются не постоянно. Вход платный, и каждое из максимум трёх мест для продукта оплачивается отдельно.',
        ),
        const SizedBox(height: 10),
        if (state.industryEventOpportunities.isEmpty)
          const AppCard(
            child: AppText(
              'Сейчас подходящих мероприятий нет. Новые окна появляются со временем — следите за уведомлениями.',
            ),
          )
        else
          ...state.industryEventOpportunities.map((opportunity) {
            final definition = V17EndgameCatalog.eventById(
              opportunity.templateId,
            );
            final selected = _eventSelections.putIfAbsent(
              opportunity.id,
              () => <String>{},
            );
            final totalCost =
                definition.entryCost +
                definition.productSlotCost * selected.length;
            final availableUntil = state.formatDateAt(
              opportunity.availableUntilMinutes,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                key: Key('industry-event-${opportunity.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      definition.name,
                      translate: false,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    AppText(definition.description),
                    const SizedBox(height: 6),
                    AppText(
                      'Вход ${money(definition.entryCost)} • место продукта ${money(definition.productSlotCost)} • доступно до $availableUntil.',
                    ),
                    const SizedBox(height: 10),
                    if (liveProducts.isEmpty)
                      const AppText('Нужен хотя бы один выпущенный продукт.')
                    else
                      ...liveProducts.map((product) {
                        final checked = selected.contains(product.id);
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: checked,
                          onChanged: (value) {
                            setState(() {
                              if (value == true && selected.length < 3) {
                                selected.add(product.id);
                              } else if (value != true) {
                                selected.remove(product.id);
                              }
                            });
                          },
                          title: AppText(product.name, translate: false),
                          subtitle: AppText(
                            'MAU ${product.mau} • качество ${product.qualityScore.toStringAsFixed(0)}',
                          ),
                        );
                      }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: selected.isEmpty || state.cash < totalCost
                            ? null
                            : () => widget.controller.dispatch(
                                JoinIndustryEvent(
                                  opportunityId: opportunity.id,
                                  productIds: selected.toList(growable: false),
                                ),
                              ),
                        icon: const Icon(Icons.confirmation_num_outlined),
                        label: AppText(
                          'Забронировать ${selected.length}/3 • ${money(totalCost)}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        if (state.bookedIndustryEvents.isNotEmpty) ...[
          const SizedBox(height: 14),
          const SectionHeader(
            title: 'Забронировано',
            subtitle:
                'После проведения события пользователи и фанаты начислятся автоматически.',
          ),
          const SizedBox(height: 8),
          ...state.bookedIndustryEvents.map((booking) {
            final definition = V17EndgameCatalog.eventById(booking.templateId);
            final eventDate = state.formatDateAt(booking.eventAtMinutes);
            return ListTile(
              title: AppText(definition.name, translate: false),
              subtitle: AppText(
                '${booking.productIds.length} продукта • $eventDate • ${money(booking.totalCost)}',
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _legacy(GameState state) {
    final marketLeader = GameCatalog.marketCompanies.reduce(
      (left, right) => left.valuation >= right.valuation ? left : right,
    );
    final valuationGap = state.valuation - marketLeader.valuation;
    return Column(
      key: const Key('company-legacy'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          key: const Key('company-legacy-score'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Фанаты ${state.companyFans} • бренд ${state.brandReputation.toStringAsFixed(1)}/100',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 5),
              AppText(
                'Legacy score ${state.companyLegacyScore.toStringAsFixed(0)} • мировые проекты ${(state.worldProjectCompletionProgress * 100).round()}%',
              ),
              const SizedBox(height: 5),
              AppText(
                valuationGap >= 0
                    ? 'Вы опережаете лидера рынка ${marketLeader.companyName} на ${money(valuationGap)}.'
                    : 'Лидер рынка ${marketLeader.companyName} впереди на ${money(valuationGap.abs())}.',
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: state.worldProjectCompletionProgress,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const SectionHeader(
          title: 'Власть или открытая экосистема',
          subtitle:
              'После 3 млрд ₽ valuation можно выбрать философию компании. Open быстрее растит фанатов и спрос, Dominant делает ставку на контроль и коммерциализацию.',
        ),
        const SizedBox(height: 8),
        SegmentedButton<EcosystemDoctrine>(
          key: const Key('ecosystem-doctrine-selector'),
          segments: const [
            ButtonSegment(
              value: EcosystemDoctrine.balanced,
              label: AppText('Баланс'),
            ),
            ButtonSegment(
              value: EcosystemDoctrine.open,
              label: AppText('Open'),
            ),
            ButtonSegment(
              value: EcosystemDoctrine.dominant,
              label: AppText('Контроль'),
            ),
          ],
          selected: <EcosystemDoctrine>{state.ecosystemDoctrine},
          onSelectionChanged: state.valuation < 3000000000
              ? null
              : (value) => widget.controller.dispatch(
                  SetEcosystemDoctrine(value.first),
                ),
        ),
        const SizedBox(height: 12),
        const SectionHeader(
          title: 'Мировые проекты',
          subtitle:
              'Именно эти три проекта завершают кампанию. Количество обычных продуктов больше не является условием победы.',
        ),
        const SizedBox(height: 8),
        ...V17EndgameCatalog.worldProjects.map(
          (definition) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _worldProjectCard(state, definition),
          ),
        ),
        const SectionHeader(
          title: 'Общественное влияние',
          subtitle:
              'Филантропия не обязана окупаться напрямую: она превращает деньги в фанатов, репутацию и наследие.',
        ),
        const SizedBox(height: 8),
        AppCard(
          key: const Key('philanthropy-controls'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText('Уже направлено: ${money(state.philanthropySpent)}'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <double>[100000000, 1000000000, 10000000000]
                    .map(
                      (amount) => OutlinedButton(
                        onPressed: state.cash >= amount
                            ? () => widget.controller.dispatch(
                                FundPhilanthropy(amount),
                              )
                            : null,
                        child: AppText(money(amount), translate: false),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
        if (state.founderLegacyCompleted) ...[
          const SizedBox(height: 12),
          const SectionHeader(
            title: 'Что дальше',
            subtitle:
                'Кампания пройдена. Теперь выберите философский финал — это не закрывает свободную игру.',
          ),
          const SizedBox(height: 8),
          AppCard(
            key: const Key('post-game-paths'),
            child: Column(
              children: PostGamePath.values
                  .where((path) => path != PostGamePath.none)
                  .map(
                    (path) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      selected: state.postGamePath == path,
                      leading: Icon(
                        state.postGamePath == path
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                      onTap: () =>
                          widget.controller.dispatch(ChoosePostGamePath(path)),
                      title: AppText(_postGamePathName(path)),
                      subtitle: AppText(_postGamePathDescription(path)),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ],
    );
  }

  Widget _worldProjectCard(GameState state, WorldProjectDefinition definition) {
    final progress = state.worldProjectProgressFor(definition.id);
    final displayName = state.worldProjectDisplayName(definition.id);
    final completedPhases = progress?.completedPhases ?? 0;
    final activePhaseAt = progress?.activePhaseCompletesAtMinutes ?? -1;
    final baseDone = state.worldProjectBaseCompleted(definition.id);
    final fullyDone = state.worldProjectCompleted(definition.id);
    final requirementsMet =
        state.valuation >= definition.minimumValuation &&
        state.companyFans >= definition.minimumFans &&
        state.completedResearchKeys.length >=
            definition.requiredCompletedResearch;
    final phaseCost = completedPhases < definition.phaseCosts.length
        ? definition.phaseCosts[completedPhases]
        : 0.0;
    final active = activePhaseAt > state.simulationMinutes;
    final upgrades = V17EndgameCatalog.worldProjectUpgrades
        .where((item) => item.projectId == definition.id)
        .toList(growable: false);

    return AppCard(
      key: Key('world-project-${definition.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  displayName,
                  translate: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                key: Key('rename-world-project-${definition.id}'),
                tooltip: trContext(context, 'Изменить название'),
                onPressed: () =>
                    _showRenameWorldProject(definition.id, displayName),
                icon: const Icon(Icons.edit_outlined),
              ),
              if (fullyDone) const Icon(Icons.verified_outlined),
            ],
          ),
          const SizedBox(height: 4),
          AppText(definition.description),
          const SizedBox(height: 8),
          AppText(
            'Требования: valuation ${money(definition.minimumValuation)} • фанаты ${definition.minimumFans} • R&D ${definition.requiredCompletedResearch}',
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (completedPhases / definition.phaseCosts.length)
                .clamp(0, 1)
                .toDouble(),
          ),
          const SizedBox(height: 5),
          AppText(
            'База: $completedPhases/${definition.phaseCosts.length} • OPEX после запуска ${money(definition.monthlyOperatingCost)}/мес.',
          ),
          AppText(
            definition.monthlyRevenue > 0
                ? 'Доход после запуска: ${money(definition.monthlyRevenue)}/мес.'
                : 'Прямой доход после запуска: нет.',
          ),
          if (!baseDone) ...[
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: !requirementsMet || active || state.cash < phaseCost
                  ? null
                  : () => widget.controller.dispatch(
                      FundWorldProjectPhase(definition.id),
                    ),
              icon: const Icon(Icons.rocket_launch_outlined),
              label: AppText(
                active
                    ? 'Этап в работе'
                    : 'Финансировать этап ${completedPhases + 1} • ${money(phaseCost)}',
              ),
            ),
          ] else ...[
            const Divider(height: 24),
            AppText(
              'Уникальные возможности • ${progress?.completedUpgradeIds.length ?? 0}/${definition.requiredUpgradeCount} нужно для мирового статуса',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            ...upgrades.map((upgrade) {
              final complete =
                  progress?.completedUpgradeIds.contains(upgrade.id) ?? false;
              final activeUpgrade = progress?.activeUpgradeId == upgrade.id;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: AppText(upgrade.name, translate: false),
                subtitle: AppText(
                  '${upgrade.description} • ${money(upgrade.cost)} • ${upgrade.days} дн.',
                ),
                trailing: complete
                    ? const Icon(Icons.check_circle_outline)
                    : FilledButton.tonal(
                        onPressed:
                            (progress?.activeUpgradeId.isNotEmpty ?? false) ||
                                state.cash < upgrade.cost
                            ? null
                            : () => widget.controller.dispatch(
                                StartWorldProjectUpgrade(
                                  projectId: definition.id,
                                  upgradeId: upgrade.id,
                                ),
                              ),
                        child: AppText(
                          activeUpgrade ? 'В работе' : 'Запустить',
                        ),
                      ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Future<void> _showRenameWorldProject(
    String projectId,
    String currentName,
  ) async {
    var draftName = currentName;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText('Изменить название мирового проекта'),
        content: TextFormField(
          key: Key('rename-world-project-field-$projectId'),
          initialValue: currentName,
          autofocus: true,
          maxLength: 36,
          onChanged: (value) => draftName = value,
          decoration: InputDecoration(
            labelText: trContext(dialogContext, 'Название'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const AppText('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(draftName.trim()),
            child: const AppText('Сохранить'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && mounted) {
      widget.controller.dispatch(
        RenameWorldProject(projectId: projectId, name: name),
      );
    }
  }

  IconData _notificationIcon(CompanyNotificationKind kind) => switch (kind) {
    CompanyNotificationKind.employee => Icons.person_off_outlined,
    CompanyNotificationKind.legend => Icons.workspace_premium_outlined,
    CompanyNotificationKind.investor => Icons.account_balance_outlined,
    CompanyNotificationKind.tax => Icons.receipt_long_outlined,
    CompanyNotificationKind.event => Icons.event_outlined,
    CompanyNotificationKind.research => Icons.science_outlined,
    CompanyNotificationKind.product => Icons.apps_outlined,
    CompanyNotificationKind.contract => Icons.handshake_outlined,
    CompanyNotificationKind.development => Icons.build_circle_outlined,
    CompanyNotificationKind.finance => Icons.payments_outlined,
    CompanyNotificationKind.legacy => Icons.public_outlined,
  };

  String _postGamePathName(PostGamePath path) => switch (path) {
    PostGamePath.none => 'Не выбрано',
    PostGamePath.infiniteGrowth => 'Бесконечный рост',
    PostGamePath.sellAndExit => 'Продать империю',
    PostGamePath.openFoundation => 'Открытый фонд',
    PostGamePath.holdingCompany => 'Глобальный холдинг',
  };

  String _postGamePathDescription(PostGamePath path) => switch (path) {
    PostGamePath.none => '',
    PostGamePath.infiniteGrowth =>
      'Продолжить масштабировать продукты, рынки и инфраструктуру.',
    PostGamePath.sellAndExit =>
      'Зафиксировать созданную стоимость и оставить компанию следующему поколению.',
    PostGamePath.openFoundation =>
      'Сделать технологии и капитал инструментом образования и open source.',
    PostGamePath.holdingCompany =>
      'Передать операционку менеджменту и строить портфель компаний.',
  };
}
