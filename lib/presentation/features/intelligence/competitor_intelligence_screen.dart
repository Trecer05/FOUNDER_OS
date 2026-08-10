import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/entities/models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';
import '../../../application/localization/app_text.dart';

class CompetitorIntelligenceScreen extends StatefulWidget {
  const CompetitorIntelligenceScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<CompetitorIntelligenceScreen> createState() =>
      _CompetitorIntelligenceScreenState();
}

class _CompetitorIntelligenceScreenState
    extends State<CompetitorIntelligenceScreen> {
  ProductCategory? _category;

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final categories = ProductCategory.values;
    final selected = _category ?? categories.first;
    final competitors = state.competitorsForCategory(selected);
    final segments = GameCatalog.marketSegments
        .where((item) => item.category == selected)
        .toList(growable: false);
    final own =
        state.products
            .where((item) => item.category == selected)
            .toList(growable: false)
          ..sort((a, b) => b.qualityScore.compareTo(a.qualityScore));
    final ownBest = own.isEmpty ? null : own.first;

    return Scaffold(
      appBar: AppBar(title: const AppText('Конкурентная разведка')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const SectionHeader(
            title: 'Рынок по категориям',
            subtitle:
                'Показываются конкретные показатели лидеров и веса пользовательских сегментов. Это объясняет, почему аудитория переходит или остаётся у конкурента.',
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: AppText(categoryName(category)),
                        selected: category == selected,
                        onSelected: (_) => setState(() => _category = category),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Рейтинг: ${categoryName(selected)}',
            subtitle: ownBest == null
                ? '20 сгенерированных компаний. Один лидер держит эталон 100, остальные имеют разные функции и показатели.'
                : 'Ваш лучший продукт участвует в общей таблице и может обойти лидера за счёт функций, скорости, свежести, доверия и аудитории.',
          ),
          const SizedBox(height: 10),
          _MarketRankingTable(
            competitors: competitors,
            own: ownBest,
            ownFreshness: ownBest == null
                ? 0
                : state.productFreshnessScore(ownBest),
          ),
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Пользовательские сегменты',
            subtitle:
                'Каждый сегмент имеет собственные приоритеты. Преимущество по одной сильной метрике работает только там, где эта метрика действительно важна.',
          ),
          const SizedBox(height: 10),
          ...segments.map(
            (segment) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SegmentCard(segment: segment),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketRankingTable extends StatelessWidget {
  const _MarketRankingTable({
    required this.competitors,
    required this.own,
    required this.ownFreshness,
  });

  final List<CompetitorBenchmark> competitors;
  final Product? own;
  final double ownFreshness;

  @override
  Widget build(BuildContext context) {
    final rows = <_RankingRow>[
      for (final competitor in competitors)
        _RankingRow(
          name: competitor.productName,
          company: competitor.companyName,
          score: competitor.marketScore,
          features: competitor.featureIds.length,
          latency: competitor.speedMs,
          users: competitor.users,
          own: false,
        ),
      if (own != null)
        _RankingRow(
          name: own!.name,
          company: 'Ваша компания',
          score: GameCatalog.productMarketScore(own!, ownFreshness),
          features: own!.featureIds.length,
          latency: own!.speedMs,
          users: own!.users,
          own: true,
        ),
    ]..sort((left, right) => right.score.compareTo(left.score));
    return AppCard(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 18,
          horizontalMargin: 8,
          columns: const <DataColumn>[
            DataColumn(label: AppText('#')),
            DataColumn(label: AppText('Продукт')),
            DataColumn(label: AppText('Score')),
            DataColumn(label: AppText('Функции')),
            DataColumn(label: AppText('Latency')),
            DataColumn(label: AppText('Пользователи')),
          ],
          rows: rows.indexed
              .map((entry) {
                final rank = entry.$1 + 1;
                final row = entry.$2;
                final style = TextStyle(
                  color: row.own ? AppColors.primary : AppColors.text,
                  fontWeight: row.own ? FontWeight.w900 : FontWeight.w600,
                );
                return DataRow(
                  cells: <DataCell>[
                    DataCell(AppText('$rank', style: style)),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(row.name, maxLines: 1, style: style),
                            AppText(
                              row.company,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      AppText(row.score.toStringAsFixed(1), style: style),
                    ),
                    DataCell(AppText('${row.features}', style: style)),
                    DataCell(
                      AppText('${row.latency.round()} ms', style: style),
                    ),
                    DataCell(AppText(compactNumber(row.users), style: style)),
                  ],
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _RankingRow {
  const _RankingRow({
    required this.name,
    required this.company,
    required this.score,
    required this.features,
    required this.latency,
    required this.users,
    required this.own,
  });

  final String name;
  final String company;
  final double score;
  final int features;
  final double latency;
  final int users;
  final bool own;
}

class _SegmentCard extends StatelessWidget {
  const _SegmentCard({required this.segment});

  final MarketSegment segment;

  @override
  Widget build(BuildContext context) {
    final weights = <MapEntry<String, double>>[
      MapEntry('Скорость', segment.speedWeight),
      MapEntry('Дизайн', segment.designWeight),
      MapEntry('Безопасность', segment.securityWeight),
      MapEntry('Функции', segment.featureWeight),
      MapEntry('Цена', segment.priceWeight),
    ]..sort((a, b) => b.value.compareTo(a.value));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(segment.name, style: Theme.of(context).textTheme.titleMedium),
          AppText(
            'Доступный рынок: ${compactNumber(segment.addressableUsers)} пользователей',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          ...weights.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(child: AppText(item.key)),
                  SizedBox(
                    width: 140,
                    child: LinearProgressIndicator(value: item.value),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 42,
                    child: AppText(
                      percent(item.value),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
