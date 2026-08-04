import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/commands/game_action.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';
import '../contracts/contracts_screen.dart';
import '../ecosystem/ecosystem_screen.dart';
import '../security/security_center_screen.dart';
import '../tutorial/founder_tutorial_dialog.dart';
import '../operations/operations_screen.dart';
import '../intelligence/competitor_intelligence_screen.dart';
import '../finance/finance_screen.dart';
import '../investors/investors_screen.dart';
import '../market/market_screen.dart';
import '../news/news_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        const SectionHeader(
          title: 'Стратегия',
          subtitle:
              'Экосистема, капитал, внешний портфель, сделки и новости вынесены в отдельные разделы.',
        ),
        const SizedBox(height: 12),
        _MenuCard(
          icon: Icons.school_outlined,
          title: 'Обучение и подсказки',
          subtitle: 'Коротко пройти основной цикл и механику продукта',
          onTap: () => showFounderTutorial(context, controller),
        ),
        const SizedBox(height: 10),
        _MenuCard(
          icon: Icons.account_tree_outlined,
          title: 'Операции и проектные команды',
          subtitle:
              '${state.employees.length - state.unassignedEmployees.length} назначено • ${state.unassignedEmployees.length} в резерве',
          onTap: () => _open(context, OperationsScreen(controller: controller)),
        ),
        const SizedBox(height: 10),
        _MenuCard(
          icon: Icons.shield_outlined,
          title: 'Центр безопасности',
          subtitle:
              '${state.securityControls.length} контролей • ${money(state.monthlySecurityCost)}/мес.',
          warning: state.products.any(
            (product) => state.productSecurityRisk(product) >= 0.25,
          ),
          onTap: () =>
              _open(context, SecurityCenterScreen(controller: controller)),
        ),
        const SizedBox(height: 10),
        _MenuCard(
          icon: Icons.radar_outlined,
          title: 'Конкурентная разведка',
          subtitle: 'Лидеры рынка, точные метрики и пользовательские сегменты',
          onTap: () => _open(
            context,
            CompetitorIntelligenceScreen(controller: controller),
          ),
        ),
        const SizedBox(height: 10),
        _MenuCard(
          icon: Icons.handshake_outlined,
          title: 'Клиентские контракты',
          subtitle:
              '${state.activeContracts.length} активных • ${state.unassignedEmployees.length} сотрудников в резерве',
          warning: state.activeContracts.any(
            (contract) =>
                contract.deadlineAtMinutes - state.simulationMinutes < 2 * 1440,
          ),
          onTap: () => _open(context, ContractsScreen(controller: controller)),
        ),
        const SizedBox(height: 10),
        _MenuCard(
          icon: Icons.receipt_long_outlined,
          title: 'Финансы и P&L',
          subtitle:
              '${money(state.monthlyProfit)}/мес. • runway ${state.runwayMonths >= 99 ? '∞' : state.runwayMonths.toStringAsFixed(1)}',
          warning: state.monthlyProfit < 0 && state.runwayMonths < 6,
          onTap: () => _open(context, FinanceScreen(controller: controller)),
        ),
        const SizedBox(height: 10),
        _MenuCard(
          icon: Icons.hub_outlined,
          title: 'Экосистема продуктов',
          subtitle:
              '${state.ecosystemLinks.length} связей • продукты продолжают работать отдельно',
          onTap: () => _open(context, EcosystemScreen(controller: controller)),
        ),
        const SizedBox(height: 10),
        _MenuCard(
          icon: Icons.account_balance_outlined,
          title: 'Инвесторы и cap table',
          subtitle:
              '${directPercent(state.founderOwnershipPercent, fractionDigits: 1)} у основателя • ${state.investorAgreements.length} инвесторов',
          warning: state.founderOwnershipPercent < 60,
          onTap: () => _open(context, InvestorsScreen(controller: controller)),
        ),
        const SizedBox(height: 10),
        _MenuCard(
          icon: Icons.business_center_outlined,
          title: 'Рынок и M&A',
          subtitle:
              '${state.portfolioHoldings.length} внешних долей • ${state.acquiredCompanyIds.length} приобретений',
          onTap: () => _open(context, MarketScreen(controller: controller)),
        ),
        const SizedBox(height: 10),
        _MenuCard(
          icon: Icons.newspaper_outlined,
          title: 'Новости',
          subtitle:
              '${state.news.length} важных событий • атаки, конкуренты, сделки и релизы',
          warning: state.news.any((item) => item.critical),
          onTap: () => _open(context, NewsScreen(controller: controller)),
        ),
        const SizedBox(height: 18),
        const SectionHeader(
          title: 'Настройки симуляции',
          subtitle: 'Технические мини-игры не обязательны для результата.',
        ),
        const SizedBox(height: 10),
        Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: SwitchListTile(
            value: state.miniGamesEnabled,
            title: const Text('Технические мини-игры'),
            subtitle: const Text(
              'При отключении результат рассчитывается по навыкам команды.',
            ),
            onChanged: (_) => controller.dispatch(const ToggleMiniGames()),
          ),
        ),
        if (controller.storageError != null) ...[
          const SizedBox(height: 10),
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: AppColors.red),
                const SizedBox(width: 10),
                Expanded(child: Text(controller.storageError!)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => page));
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.warning = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      hintTitle: title,
      hintBody: subtitle,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (warning ? AppColors.red : AppColors.primary)
                .withAlpha(22),
            foregroundColor: warning ? AppColors.red : AppColors.primary,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
