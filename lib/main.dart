import 'dart:ui';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'application/controllers/game_controller.dart';
import 'application/settings/display_preferences.dart';
import 'persistence/storage/game_snapshot_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _FounderOsBootstrap());
}

class _FounderOsBootstrap extends StatefulWidget {
  const _FounderOsBootstrap();

  @override
  State<_FounderOsBootstrap> createState() => _FounderOsBootstrapState();
}

class _FounderOsBootstrapState extends State<_FounderOsBootstrap> {
  static const _tipsRu = <String>[
    'Совет: один недостающий специалист больше не должен останавливать весь проект.',
    'Совет: R&D открывает функции — хороший fit ускоряет приток и удержание.',
    'Совет: держите API, storage и AI compute на подходящей инфраструктуре.',
    'Совет: HR снижает риск ухода и помогает удерживать сильных сотрудников.',
    'Совет: реклама создаёт интерес, а продукт должен конвертировать его в пользователей.',
    'Совет: если приложение закрыто, компания продолжает жить до критической ситуации.',
  ];
  static const _tipsEn = <String>[
    'Tip: one missing specialist should create a bottleneck, not stop the whole project.',
    'Tip: R&D unlocks features — strong product fit improves acquisition and retention.',
    'Tip: route API, storage, and AI compute to infrastructure that fits each workload.',
    'Tip: HR reduces departure risk and helps retain strong employees.',
    'Tip: ads create interest; your product still has to convert it into users.',
    'Tip: while the app is closed, the company keeps running until a critical event.',
  ];

  bool get _english => PlatformDispatcher.instance.locale.languageCode == 'en';
  List<String> get _tips => _english ? _tipsEn : _tipsRu;
  String _copy(String ru, String en) => _english ? en : ru;

  GameController? _controller;
  Object? _error;
  double _progress = 0.06;
  String _stage = '';
  late int _tipIndex;

  @override
  void initState() {
    super.initState();
    _stage = _copy('Запускаем компанию…', 'Starting the company…');
    _tipIndex = DateTime.now().millisecondsSinceEpoch % _tips.length;
    Future<void>.microtask(_boot);
  }

  Future<void> _boot() async {
    try {
      setState(() {
        _progress = 0.18;
        _stage = _copy('Настраиваем интерфейс…', 'Preparing the interface…');
      });
      final controller = GameController(snapshotStore: GameSnapshotStore());
      setState(() {
        _progress = 0.42;
        _stage = _copy(
          'Читаем сохранение и настройки…',
          'Loading save and settings…',
        );
      });
      await Future.wait<void>([
        DisplayPreferences.instance.initialize(),
        controller.initialize(),
      ]);
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _progress = 1;
        _stage = _copy('Готово', 'Ready');
        _controller = controller;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller != null) {
      return FounderOsApp(controller: controller, startAtMainMenu: true);
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
            child: Column(
              children: [
                const Spacer(flex: 3),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: const Color(0xFF171B24),
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        size: 54,
                        color: Colors.white,
                      ),
                      Positioned(
                        right: 15,
                        bottom: 14,
                        child: Icon(
                          Icons.trending_up_rounded,
                          size: 28,
                          color: Color(0xFF7BD7FF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'FOUNDER.OS',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Build. Ship. Survive.',
                  style: TextStyle(
                    color: Color(0xFF737B8C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(flex: 2),
                if (_error == null) ...[
                  LinearProgressIndicator(
                    key: const Key('cold-start-progress'),
                    value: _progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _stage,
                    key: const Key('cold-start-stage'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ] else ...[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 34,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _copy(
                      'Не удалось загрузить игру',
                      'Could not load the game',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text('$_error', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _progress = 0.06;
                        _stage = _copy(
                          'Запускаем компанию…',
                          'Starting the company…',
                        );
                        _tipIndex = (_tipIndex + 1) % _tips.length;
                      });
                      Future<void>.microtask(_boot);
                    },
                    child: Text(_copy('Повторить', 'Retry')),
                  ),
                ],
                const Spacer(flex: 3),
                Text(
                  _tips[_tipIndex],
                  key: ValueKey(_tipIndex),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF737B8C),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
