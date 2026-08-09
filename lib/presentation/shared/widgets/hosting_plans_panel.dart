import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/v9_content_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/v9_models.dart';
import 'app_card.dart';
import 'formatters.dart';
import 'section_header.dart';
import '../../../application/localization/app_text.dart';

class HostingPlansPanel extends StatelessWidget {
  const HostingPlansPanel({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Column(
      key: const Key('hosting-plans-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Арендуемая инфраструктура',
          subtitle:
              'Компания начинает без хостинга и расходов. Инфраструктуру подключайте только когда она действительно нужна.',
          hintTitle: 'Hosting plan',
          hintBody:
              'Plan задаёт compute, storage, bandwidth, SLA, допустимую нагрузку и ежемесячный burn. Физическое железо можно подготовить заранее, но оно не обслуживает продукты до миграции.',
        ),
        const SizedBox(height: 10),
        ...V9ContentCatalog.hostingPlans.map((plan) {
          final current = plan.id == state.selectedHostingPlanId;
          final reasons = _blockingReasons(plan);
          final owned = plan.kind == HostingKind.owned;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
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
                              plan.name,
                              translate: false,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Flexible(
                                  child: AppText(
                                    plan.provider,
                                    translate: false,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                                AppText(
                                  ' • ${owned ? 'CAPEX' : '${money(plan.monthlyCost)}/мес.'}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (current)
                        const Chip(label: AppText('Текущий'))
                      else if (owned)
                        const Chip(
                          avatar: Icon(Icons.pie_chart_outline, size: 18),
                          label: AppText('Миграция в «Мощностях»'),
                        )
                      else
                        FilledButton(
                          key: Key('select-hosting-${plan.id}'),
                          onPressed: reasons.isEmpty
                              ? () => controller.dispatch(
                                  RentHostingPlan(plan.id),
                                )
                              : null,
                          child: const AppText('Арендовать'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppText(plan.description),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _Chip('${plan.computeUnits.round()} CU'),
                      _Chip('${plan.storageGb.round()} GB storage'),
                      _Chip(
                        '${plan.bandwidthTb.toStringAsFixed(1)} TB bandwidth',
                      ),
                      _Chip('SLA ${percent(plan.sla, fractionDigits: 2)}'),
                      _Chip(
                        'Ориентир: до ${compactNumber(plan.approximateUsers)} активных пользователей',
                      ),
                      _Chip('Scale ${(plan.scalability * 100).round()}/100'),
                      if (plan.setupCost > 0)
                        _Chip('Setup ${money(plan.setupCost)}'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _List(title: 'Плюсы', items: plan.strengths, positive: true),
                  _List(title: 'Минусы', items: plan.weaknesses),
                  _List(title: 'Риски', items: plan.risks),
                  if (plan.requiredRoles.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: AppText(
                        'Требуются: ${plan.requiredRoles.map(_roleLabel).join(', ')}.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  if (reasons.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    ...reasons.map(
                      (reason) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: AppText(
                          'Блокировка: $reason',
                          style: const TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (owned && !current) ...[
                    const SizedBox(height: 7),
                    const AppText(
                      'Кнопка миграции находится во вкладке «Мощности» рядом с распределением compute.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  List<String> _blockingReasons(HostingPlan plan) {
    final state = controller.state;
    if (plan.id == state.selectedHostingPlanId) return const <String>[];
    final reasons = <String>[];
    if (state.cash < plan.setupCost) {
      reasons.add('не хватает ${money(plan.setupCost - state.cash)} на setup.');
    }
    final employeeRoles = state.employees.map((item) => item.role.name).toSet();
    for (final role in plan.requiredRoles.toList()..sort()) {
      if (!employeeRoles.contains(role)) {
        reasons.add('требуется ${_roleLabel(role)}.');
      }
    }
    if (plan.kind == HostingKind.owned) {
      if (state.installedServers.isEmpty) {
        reasons.add('сначала купите хотя бы один сервер.');
      }
      if (!state.infrastructureFitsRoom) {
        reasons.add('серверная не выдерживает rack, power или cooling.');
      }
    }
    reasons.sort();
    return reasons;
  }

  static String _roleLabel(String id) => switch (id) {
    'devOps' => 'DevOps-инженер',
    'security' => 'Security Engineer',
    'backend' => 'Backend-разработчик',
    _ => id,
  };
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: AppText(label, style: Theme.of(context).textTheme.bodySmall),
  );
}

class _List extends StatelessWidget {
  const _List({
    required this.title,
    required this.items,
    this.positive = false,
  });
  final String title;
  final List<String> items;
  final bool positive;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: AppText(
      '$title: ${items.join(' • ')}',
      style: TextStyle(color: positive ? AppColors.green : AppColors.textMuted),
    ),
  );
}
