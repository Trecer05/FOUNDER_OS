import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../domain/catalog/v9_content_catalog.dart';
import '../../../domain/entities/v9_models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/section_header.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({this.initialTermId, super.key});
  final String? initialTermId;

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final entries =
        V9ContentCatalog.glossary
            .where((entry) {
              if (query.isEmpty) return true;
              return entry.term.toLowerCase().contains(query) ||
                  entry.shortExplanation.toLowerCase().contains(query) ||
                  entry.detailedExplanation.toLowerCase().contains(query);
            })
            .toList(growable: false)
          ..sort((a, b) {
            if (a.id == widget.initialTermId) return -1;
            if (b.id == widget.initialTermId) return 1;
            return a.term.compareTo(b.term);
          });
    return Scaffold(
      appBar: AppBar(title: const Text('Метрики и терминология')),
      body: ListView(
        key: const Key('glossary-screen'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const SectionHeader(
            title: 'Справочник основателя',
            subtitle:
                'Короткое объяснение, игровой пример и причина, почему метрика важна.',
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('glossary-search'),
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Найти MRR, churn, compute…',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const AppCard(child: Text('Термин не найден.'))
          else
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GlossaryCard(entry: entry),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlossaryCard extends StatelessWidget {
  const _GlossaryCard({required this.entry});
  final GlossaryEntry entry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ExpansionTile(
        key: Key('glossary-${entry.id}'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 4),
        title: Text(entry.term, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(entry.shortExplanation),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.detailedExplanation),
                const SizedBox(height: 10),
                _Label('Пример из игры', entry.gameExample),
                _Label('Где применяется', entry.usedIn.join(', ')),
                _Label('Почему важно', entry.whyImportant, last: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.label, this.value, {this.last = false});
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 8),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
