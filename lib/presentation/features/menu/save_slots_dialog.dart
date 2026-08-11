// UAT_FIXPACK_R1
import 'package:flutter/material.dart';

import '../../../application/controllers/game_controller.dart';
import '../../../application/localization/app_localizer.dart';
import '../../../application/localization/app_text.dart';
import '../../../app/theme/app_theme.dart';
import '../../../persistence/storage/snapshot_store.dart';
import '../../shared/widgets/formatters.dart';

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
    final media = MediaQuery.of(context);
    final compact = media.size.width < 540;
    final maxDialogHeight = (media.size.height - 48)
        .clamp(320.0, 720.0)
        .toDouble();

    // Dialog is used intentionally instead of AlertDialog. AlertDialog wraps
    // its contents in intrinsic-width measurement, which is incompatible with
    // LayoutBuilder-style responsive descendants and caused the narrow-iPhone
    // save UI to fail during layout.
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxDialogHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      widget.mode == SaveSlotDialogMode.save
                          ? 'Сохранить игру'
                          : 'Загрузить игру',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    key: const Key('save-slots-close-icon'),
                    tooltip: trContext(context, 'Закрыть'),
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  key: const Key('save-slots-scroll'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < 3; index++) ...[
                        _slot(
                          context,
                          'slot_${index + 1}',
                          index + 1,
                          compact: compact,
                        ),
                        if (index < 2) const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('save-slots-close-button'),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const AppText('Закрыть'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slot(
    BuildContext context,
    String slotId,
    int number, {
    required bool compact,
  }) {
    final summary = _summaryFor(slotId);
    final busy = _busySlot == slotId;
    final canSelect = widget.mode == SaveSlotDialogMode.save || summary != null;

    Widget details() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          summary?.companyName ?? 'Пустой слот',
          translate: summary == null,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        if (summary != null)
          AppText(
            'День ${summary.simulationMinutes ~/ 1440 + 1} • ${money(summary.cash)}\n${_date(summary.savedAt)}',
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
    );

    Widget actionButton() => FilledButton.tonal(
      key: Key('save-slot-action-$slotId'),
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
    );

    final avatar = CircleAvatar(
      backgroundColor: AppColors.primary.withAlpha(22),
      foregroundColor: AppColors.primary,
      child: AppText('$number', translate: false),
    );

    return Material(
      color: AppColors.surfaceMuted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      avatar,
                      const SizedBox(width: 10),
                      Expanded(child: details()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (summary != null)
                        IconButton(
                          tooltip: trContext(context, 'Удалить слот'),
                          onPressed: busy ? null : () => _delete(slotId),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      if (summary != null) const SizedBox(width: 6),
                      Expanded(child: actionButton()),
                    ],
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  avatar,
                  const SizedBox(width: 12),
                  Expanded(child: details()),
                  if (summary != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: trContext(context, 'Удалить слот'),
                      onPressed: busy ? null : () => _delete(slotId),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                  const SizedBox(width: 8),
                  actionButton(),
                ],
              ),
      ),
    );
  }

  String _date(DateTime value) {
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
