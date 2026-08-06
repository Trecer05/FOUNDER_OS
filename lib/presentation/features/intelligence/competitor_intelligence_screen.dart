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
    final competitors = GameCatalog.competitors
        .where((item) => item.category == selected)
        .toList(growable: false);
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
            title: 'Лидеры: ${categoryName(selected)}',
            subtitle: ownBest == null
                ? 'Своего продукта в этой категории пока нет.'
                : 'Ваш лучший продукт: ${ownBest.name}, quality ${ownBest.qualityScore.round()}/100.',
          ),
          const SizedBox(height: 10),
          ...competitors.map(
            (competitor) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CompetitorCard(competitor: competitor, own: ownBest),
            ),
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

class _CompetitorCard extends StatelessWidget {
  const _CompetitorCard({required this.competitor, required this.own});

  final CompetitorBenchmark competitor;
  final Product? own;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            competitor.productName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          AppText(
            '${competitor.companyName} • ${compactNumber(competitor.users)} пользователей • ${money(competitor.monthlyPrice)}/мес.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _Comparison(
            label: 'Latency',
            competitorValue: '${competitor.speedMs.round()} ms',
            ownValue: own == null ? '—' : '${own!.speedMs.round()} ms',
            ownBetter: own != null && own!.speedMs < competitor.speedMs,
          ),
          _Comparison(
            label: 'Design',
            competitorValue: '${competitor.designScore.round()}/100',
            ownValue: own == null ? '—' : '${own!.designScore.round()}/100',
            ownBetter: own != null && own!.designScore > competitor.designScore,
          ),
          _Comparison(
            label: 'Security',
            competitorValue: '${competitor.securityScore.round()}/100',
            ownValue: own == null ? '—' : '${own!.securityScore.round()}/100',
            ownBetter:
                own != null && own!.securityScore > competitor.securityScore,
          ),
          _Comparison(
            label: 'Reliability',
            competitorValue: percent(competitor.reliability, fractionDigits: 2),
            ownValue: own == null
                ? '—'
                : percent(own!.reliability, fractionDigits: 2),
            ownBetter: own != null && own!.reliability > competitor.reliability,
          ),
        ],
      ),
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({
    required this.label,
    required this.competitorValue,
    required this.ownValue,
    required this.ownBetter,
  });

  final String label;
  final String competitorValue;
  final String ownValue;
  final bool ownBetter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: AppText(label)),
          AppText(
            ownValue,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: ownBetter ? AppColors.green : AppColors.text,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: AppText('vs', style: TextStyle(color: AppColors.textMuted)),
          ),
          SizedBox(
            width: 86,
            child: AppText(
              competitorValue,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
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
