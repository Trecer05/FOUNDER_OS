import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/entities/models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/section_header.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  NewsKind? _kind;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        final news = state.news
            .where((item) => _kind == null || item.kind == _kind)
            .toList(growable: false);

        return Scaffold(
          appBar: AppBar(title: const Text('Новости рынка')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const SectionHeader(
                title: 'Сигналы, влияющие на решения',
                subtitle:
                    'Без шума: релизы конкурентов, атаки, инвестиции, сделки, инфраструктурные и рыночные изменения.',
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Все'),
                      selected: _kind == null,
                      onSelected: (_) => setState(() => _kind = null),
                    ),
                    const SizedBox(width: 7),
                    ...NewsKind.values.map(
                      (kind) => Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: ChoiceChip(
                          label: Text(_kindName(kind)),
                          selected: _kind == kind,
                          onSelected: (_) => setState(() => _kind = kind),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (news.isEmpty)
                const AppCard(child: Text('По выбранному фильтру событий нет.'))
              else
                ...news.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: _kindColor(
                              item.kind,
                            ).withAlpha(22),
                            foregroundColor: _kindColor(item.kind),
                            child: Icon(_kindIcon(item.kind)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ),
                                    if (item.critical)
                                      const Icon(
                                        Icons.priority_high_rounded,
                                        color: AppColors.red,
                                        size: 20,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(item.body),
                                const SizedBox(height: 8),
                                Text(
                                  'День ${item.simulationMinutes ~/ 1440 + 1} • ${_time(item.simulationMinutes)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

String _time(int simulationMinutes) {
  final minuteOfDay = simulationMinutes % 1440;
  final hour = minuteOfDay ~/ 60;
  final minute = minuteOfDay % 60;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

String _kindName(NewsKind kind) => switch (kind) {
  NewsKind.competitor => 'Конкуренты',
  NewsKind.security => 'Атаки',
  NewsKind.funding => 'Инвестиции',
  NewsKind.acquisition => 'Сделки',
  NewsKind.market => 'Рынок',
  NewsKind.product => 'Продукты',
  NewsKind.infrastructure => 'Инфра',
  NewsKind.finance => 'Финансы',
};

IconData _kindIcon(NewsKind kind) => switch (kind) {
  NewsKind.competitor => Icons.radar_outlined,
  NewsKind.security => Icons.gpp_bad_outlined,
  NewsKind.funding => Icons.account_balance_outlined,
  NewsKind.acquisition => Icons.handshake_outlined,
  NewsKind.market => Icons.query_stats_outlined,
  NewsKind.product => Icons.rocket_launch_outlined,
  NewsKind.infrastructure => Icons.dns_outlined,
  NewsKind.finance => Icons.account_balance_wallet_outlined,
};

Color _kindColor(NewsKind kind) => switch (kind) {
  NewsKind.competitor => AppColors.violet,
  NewsKind.security => AppColors.red,
  NewsKind.funding => AppColors.green,
  NewsKind.acquisition => AppColors.primary,
  NewsKind.market => AppColors.yellow,
  NewsKind.product => AppColors.cyan,
  NewsKind.infrastructure => AppColors.textMuted,
  NewsKind.finance => AppColors.red,
};
