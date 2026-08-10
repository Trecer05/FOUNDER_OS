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
          'CEO умеет проектировать, рисовать, писать код и отлаживать продукт. Background и 22 распределённых очка определяют скорость этой работы и экономические бонусы.',
      tip:
          'В одиночку можно довести продукт до релиза, но профильные сотрудники ускоряют работу в разы.',
    ),
    _TutorialPage(
      icon: Icons.public_outlined,
      title: '1. Выберите географию компании',
      body:
          'Город HQ задаёт налог на прибыль, payroll tax, базовые зарплаты, аренду и коммунальные расходы. Одновременно он влияет на доступ к талантам, инвесторам, рынку, регулирование и качество сети.',
      tip:
          'Самая дешёвая юрисдикция не всегда лучшая: дорогой город может быстрее дать сильную команду, капитал или рынок.',
    ),
    _TutorialPage(
      icon: Icons.rocket_launch_outlined,
      title: '2. Создайте первый продукт',
      body:
          'Во вкладке «Продукты» выберите категорию, framework, языки, технологии и функции. После создания работа проходит через проектирование, дизайн, разработку и отладку.',
      tip:
          'Не выбирайте всё сразу: лишние технологии повышают стоимость и compute.',
    ),
    _TutorialPage(
      icon: Icons.payments_outlined,
      title: '3. Поймите монетизацию до релиза',
      body:
          'Free ускоряет набор аудитории, но не даёт прямой выручки. Subscription даёт повторяющийся доход и требует retention. Usage based растёт вместе с использованием и расходами compute. Advertising зависит от MAU и вовлечённости. Transaction fee требует объёма операций и доверия.',
      tip:
          'Цена, free tier, рекламная нагрузка и комиссия — рычаги. Смотрите одновременно на прогноз выручки, activation, retention, churn и доверие.',
    ),
    _TutorialPage(
      icon: Icons.groups_2_outlined,
      title: '4. Соберите и развивайте команду',
      body:
          'Каждому продукту нужны конкретные роли. Skill растёт от реальной разработки. Курсы занимают 2–3 игровых дня, на это время сотрудник выпадает из разработки. Грейд повышается вместе с навыком или через план повышения до выбранного целевого грейда.',
      tip:
          'Можно выбрать нескольких сотрудников или всех из фильтра и отправить их на один курс одновременно.',
    ),
    _TutorialPage(
      icon: Icons.apartment_outlined,
      title: '5. Масштабируйте офисы по миру',
      body:
          'Аренда подходит для старта. Позже можно строить несколько собственных офисов в разных городах, выбирая размер, качество ремонта и оснащения. Каждый город меняет стоимость команды и стратегические возможности.',
      tip:
          'Не стройте кампус раньше времени: CAPEX и содержание должны окупаться реальной потребностью в людях.',
    ),
    _TutorialPage(
      icon: Icons.dns_outlined,
      title: '6. Стройте дата-центры осознанно',
      body:
          'Собственные ЦОД можно размещать в разных городах. Размер задаёт rack-потолок, а качество помещения и оборудования влияет на power, cooling и network. Сервер при покупке устанавливается на конкретную площадку.',
      tip:
          'Дешёвое электричество не компенсирует плохую сеть или слишком маленький ЦОД, если продукт растёт глобально.',
    ),
    _TutorialPage(
      icon: Icons.receipt_long_outlined,
      title: '7. Планируйте годовые налоги',
      body:
          'Раз в игровой год компания платит налог с накопленной прибыли и payroll tax с фонда оплаты труда. Они не спрятаны в месячном burn: обязательство накапливается и списывается отдельной транзакцией.',
      tip:
          'Держите резерв к концу года. Высокая прибыль без кэша после CAPEX всё равно может создать кассовый разрыв.',
    ),
    _TutorialPage(
      icon: Icons.psychology_alt_outlined,
      title: '8. Используйте собственную AI',
      body:
          'AI-продукт можно вывести на рынок либо перевести во внутренний корпоративный режим и подключать к другим продуктам.',
      tip:
          'Корпоративная AI ускоряет разработку и повышает качество, но требует дополнительных серверов и ежемесячных расходов.',
    ),
    _TutorialPage(
      icon: Icons.update_outlined,
      title: '9. Не дайте продукту устареть',
      body:
          'После долгого периода без обновлений падают свежесть, органический рост и retention. Даже после завершения roadmap всегда доступны технические улучшения и массовое исправление накопившихся багов.',
      tip:
          'Рост — это цикл: продукт → команда → инфраструктура → рынок → налоги → следующая инвестиция. Не максимизируйте один показатель в отрыве от остальных.',
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
