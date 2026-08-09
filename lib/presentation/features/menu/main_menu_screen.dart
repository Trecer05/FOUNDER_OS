import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../application/settings/display_preferences.dart';
import '../../shared/widgets/company_logo.dart';
import '../../shared/widgets/formatters.dart';
import '../../../application/localization/app_text.dart';
import 'save_slots_dialog.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    required this.controller,
    required this.onEnterGame,
    super.key,
  });

  final GameController controller;
  final VoidCallback onEnterGame;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final hasCompany = state.companyProfile.configured;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFFF6F8FF), Color(0xFFEFF3FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(24),
                children: [
                  const Icon(Icons.rocket_launch_rounded, size: 48, color: AppColors.primary),
                  const SizedBox(height: 14),
                  const AppText(
                    'FOUNDER.OS',
                    translate: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 5),
                  const AppText(
                    'Постройте компанию, переживите рынок и соберите технологическую империю.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  if (hasCompany) ...[
                    _CompanyResume(controller: controller),
                    const SizedBox(height: 14),
                  ],
                  FilledButton.icon(
                    key: const Key('main-menu-continue'),
                    onPressed: hasCompany ? onEnterGame : null,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const AppText('Продолжить'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    key: const Key('main-menu-new-game'),
                    onPressed: () => _newGame(context),
                    icon: const Icon(Icons.add_business_outlined),
                    label: const AppText('Новая игра'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    key: const Key('main-menu-load'),
                    onPressed: controller.supportsManualSaves
                        ? () => _load(context)
                        : null,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const AppText('Загрузить игру'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const _SettingsDialog(),
                    ),
                    icon: const Icon(Icons.settings_outlined),
                    label: const AppText('Настройки'),
                  ),
                  const SizedBox(height: 18),
                  AppText(
                    'Автосохранение + 3 ручных слота',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _newGame(BuildContext context) async {
    if (controller.state.companyProfile.configured) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const AppText('Начать новую игру?'),
          content: const AppText(
            'Текущий автосейв будет заменён. Ручные слоты останутся доступными.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const AppText('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const AppText('Начать'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }
    await controller.reset();
    if (context.mounted) onEnterGame();
  }

  Future<void> _load(BuildContext context) async {
    final loaded = await showSaveSlotsDialog(
      context,
      controller,
      mode: SaveSlotDialogMode.load,
    );
    if (loaded && context.mounted) onEnterGame();
  }
}

class _CompanyResume extends StatelessWidget {
  const _CompanyResume({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CompanyLogo(logoId: state.companyProfile.logoId, size: 44, borderRadius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    state.companyProfile.companyName,
                    translate: false,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  AppText(
                    'День ${state.day} • ${money(state.cash)} • ${state.products.length} продуктов',
                    translate: false,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDialog extends StatelessWidget {
  const _SettingsDialog();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DisplayPreferences.instance,
      builder: (context, _) {
        final preferences = DisplayPreferences.instance;
        return AlertDialog(
          title: const AppText('Настройки'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<AppLanguage>(
                  initialValue: preferences.language,
                  decoration: const InputDecoration(labelText: 'Language / Язык'),
                  items: const [
                    DropdownMenuItem(value: AppLanguage.ru, child: Text('Русский')),
                    DropdownMenuItem(value: AppLanguage.en, child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value != null) preferences.setLanguage(value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DisplayCurrency>(
                  initialValue: preferences.currency,
                  decoration: const InputDecoration(labelText: 'Валюта / Currency'),
                  items: DisplayCurrency.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(switch (value) {
                            DisplayCurrency.rub => 'RUB · ₽',
                            DisplayCurrency.usd => 'USD · \$',
                            DisplayCurrency.eur => 'EUR · €',
                          }),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) preferences.setCurrency(value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const AppText('Готово'),
            ),
          ],
        );
      },
    );
  }
}
