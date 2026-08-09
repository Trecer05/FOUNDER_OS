import 'package:flutter/material.dart';

import '../../../application/controllers/game_controller.dart';
import '../../../app/theme/app_theme.dart';
import '../../../persistence/storage/snapshot_store.dart';
import '../../shared/widgets/formatters.dart';
import '../../../application/localization/app_text.dart';

enum SaveSlotDialogMode { save, load }

Future<bool> showSaveSlotsDialog(
  BuildContext context,
  GameController controller, {
  required SaveSlotDialogMode mode,
}) async {
  if (!controller.supportsManualSaves) return false;
  final summaries = await controller.listSaveSlots();
  if (!context.mounted) return false;
  return await showDialog<bool>(
        context: context,
        builder: (_) => _SaveSlotsDialog(
          controller: controller,
          mode: mode,
          initialSummaries: summaries,
        ),
      ) ??
      false;
}

class _SaveSlotsDialog extends StatefulWidget {
  const _SaveSlotsDialog({
    required this.controller,
    required this.mode,
    required this.initialSummaries,
  });

  final GameController controller;
  final SaveSlotDialogMode mode;
  final List<SaveSlotSummary> initialSummaries;

  @override
  State<_SaveSlotsDialog> createState() => _SaveSlotsDialogState();
}

class _SaveSlotsDialogState extends State<_SaveSlotsDialog> {
  late List<SaveSlotSummary> _summaries;
  String? _busySlot;

  @override
  void initState() {
    super.initState();
    _summaries = widget.initialSummaries;
  }

  SaveSlotSummary? _summaryFor(String slotId) {
    for (final summary in _summaries) {
      if (summary.slotId == slotId) return summary;
    }
    return null;
  }

  Future<void> _select(String slotId) async {
    if (_busySlot != null) return;
    setState(() => _busySlot = slotId);
    try {
      if (widget.mode == SaveSlotDialogMode.save) {
        await widget.controller.saveToSlot(slotId);
        if (mounted) Navigator.of(context).pop(true);
      } else {
        final loaded = await widget.controller.loadFromSlot(slotId);
        if (mounted && loaded) Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) setState(() => _busySlot = null);
    }
  }

  Future<void> _delete(String slotId) async {
    if (_busySlot != null) return;
    await widget.controller.deleteSaveSlot(slotId);
    final refreshed = await widget.controller.listSaveSlots();
    if (mounted) setState(() => _summaries = refreshed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppText(
        widget.mode == SaveSlotDialogMode.save
            ? 'Сохранить игру'
            : 'Загрузить игру',
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < 3; index++) ...[
              _slot(context, 'slot_${index + 1}', index + 1),
              if (index < 2) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const AppText('Закрыть'),
        ),
      ],
    );
  }

  Widget _slot(BuildContext context, String slotId, int number) {
    final summary = _summaryFor(slotId);
    final busy = _busySlot == slotId;
    final canSelect = widget.mode == SaveSlotDialogMode.save || summary != null;
    return Material(
      color: AppColors.surfaceMuted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withAlpha(22),
              foregroundColor: AppColors.primary,
              child: AppText('$number', translate: false),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    summary?.companyName ?? 'Пустой слот',
                    translate: summary == null,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  if (summary != null)
                    AppText(
                      'День ${summary.simulationMinutes ~/ 1440 + 1} • ${money(summary.cash)} • ${_date(summary.savedAt)}',
                      translate: false,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else
                    AppText(
                      widget.mode == SaveSlotDialogMode.save
                          ? 'Можно сохранить текущую компанию'
                          : 'Нет сохранения',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            if (summary != null)
              IconButton(
                tooltip: 'Удалить слот',
                onPressed: busy ? null : () => _delete(slotId),
                icon: const Icon(Icons.delete_outline),
              ),
            const SizedBox(width: 4),
            FilledButton.tonal(
              onPressed: canSelect && !busy ? () => _select(slotId) : null,
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : AppText(
                      widget.mode == SaveSlotDialogMode.save
                          ? summary == null
                                ? 'Сохранить'
                                : 'Перезаписать'
                          : 'Загрузить',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _date(DateTime value) {
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year} ${two(local.hour)}:${two(local.minute)}';
  }
}
