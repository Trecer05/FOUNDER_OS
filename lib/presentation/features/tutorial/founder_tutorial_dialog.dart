import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/commands/game_action.dart';
import '../../../application/localization/app_text.dart';

Future<void> showFounderTutorial(
  BuildContext context,
  GameController controller,
) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _FounderTutorialDialog(controller: controller),
  );
}

class _FounderTutorialDialog extends StatefulWidget {
  const _FounderTutorialDialog({required this.controller});

  final GameController controller;

  @override
  State<_FounderTutorialDialog> createState() => _FounderTutorialDialogState();
}

class _FounderTutorialDialogState extends State<_FounderTutorialDialog> {
  int _page = 0;

  static const _pages = <_TutorialPage>[
    _TutorialPage(
      icon: Icons.person_outline,
      title: '0. CEO — тоже часть команды',
      body:
          'CEO умеет проектировать, рисовать, писать код и отлаживать продукт. Background и 12 распределённых очков определяют скорость этой работы и экономические бонусы.',
      tip:
          'В одиночку можно довести продукт до релиза, но профильные сотрудники ускоряют работу в разы.',
    ),
    _TutorialPage(
      icon: Icons.rocket_launch_outlined,
      title: '1. Создайте первый продукт',
      body:
          'Во вкладке «Продукты» выберите категорию, framework, языки, технологии и функции. После создания работа проходит через проектирование, дизайн, разработку и отладку.',
      tip:
          'Не выбирайте всё сразу: лишние технологии повышают стоимость и compute.',
    ),
    _TutorialPage(
      icon: Icons.groups_2_outlined,
      title: '2. Соберите подходящую команду',
      body:
          'Каждому типу продукта нужны конкретные специальности. Нанятый сотрудник работает только на том продукте, куда назначен в «Операциях».',
      tip:
          'Красные требования означают, что нужной роли в проектной команде пока не хватает.',
    ),
    _TutorialPage(
      icon: Icons.dns_outlined,
      title: '3. Подготовьте инфраструктуру',
      body:
          'Серверная ограничивает стойки, питание и охлаждение. Затем распределите общую compute-мощность между продуктами в процентах.',
      tip:
          'Высокая загрузка ухудшает latency, uptime и удержание пользователей.',
    ),
    _TutorialPage(
      icon: Icons.psychology_alt_outlined,
      title: '4. Используйте собственную AI',
      body:
          'AI-продукт можно вывести на рынок либо перевести во внутренний корпоративный режим и подключать к другим продуктам.',
      tip:
          'Корпоративная AI ускоряет разработку и повышает качество, но требует дополнительных серверов и ежемесячных расходов.',
    ),
    _TutorialPage(
      icon: Icons.update_outlined,
      title: '5. Не дайте продукту устареть',
      body:
          'После долгого периода без обновлений падают свежесть, органический рост и retention. Даже после завершения roadmap всегда доступны технические улучшения.',
      tip:
          'Следите за показателем «Свежесть» в карточке продукта и обновляйте скорость, алгоритмы, дизайн, security или reliability.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final page = _pages[_page];
    final last = _page == _pages.length - 1;
    return AlertDialog(
      icon: Icon(page.icon, size: 42, color: AppColors.primary),
      title: AppText(page.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(page.body),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withAlpha(55)),
              ),
              child: AppText('Подсказка: ${page.tip}'),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: (_page + 1) / _pages.length),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('tutorial-skip'),
          onPressed: _complete,
          child: const AppText('Пропустить'),
        ),
        if (_page > 0)
          TextButton(
            onPressed: () => setState(() => _page -= 1),
            child: const AppText('Назад'),
          ),
        FilledButton(
          key: Key(last ? 'tutorial-complete' : 'tutorial-next'),
          onPressed: last ? _complete : () => setState(() => _page += 1),
          child: AppText(last ? 'Начать' : 'Далее'),
        ),
      ],
    );
  }

  void _complete() {
    widget.controller.dispatch(const CompleteOnboarding());
    Navigator.of(context).pop();
  }
}

class _TutorialPage {
  const _TutorialPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.tip,
  });

  final IconData icon;
  final String title;
  final String body;
  final String tip;
}
