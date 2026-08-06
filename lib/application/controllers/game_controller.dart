import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../domain/commands/game_action.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/simulation/engine/game_engine.dart';
import '../../persistence/storage/snapshot_store.dart';

class GameController extends ChangeNotifier with WidgetsBindingObserver {
  GameController({
    required SnapshotStore snapshotStore,
    GameEngine engine = const GameEngine(),
    bool startClock = true,
  }) : this._(snapshotStore, engine, startClock);

  GameController._(this._snapshotStore, this._engine, this._startClock);

  final SnapshotStore _snapshotStore;
  final GameEngine _engine;
  final bool _startClock;

  GameState _state = GameState.initial();
  Timer? _timer;
  int _lastAutosavedFourHourBlock = -1;
  String? _storageError;
  bool _initialized = false;
  bool _disposed = false;
  Future<void> _saveChain = Future<void>.value();

  GameState get state => _state;
  String? get storageError => _storageError;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_startClock) {
      WidgetsBinding.instance.addObserver(this);
    }
    try {
      _state = await _snapshotStore.load() ?? GameState.initial();
      _storageError = null;
    } on Object catch (error) {
      _state = GameState.initial();
      _storageError = 'Сохранение повреждено: $error';
    }

    _initialized = true;
    _lastAutosavedFourHourBlock = _state.simulationMinutes ~/ (4 * 60);

    if (_startClock) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        dispatch(const AdvanceTime(1), playSound: false, save: false);
        final block = _state.simulationMinutes ~/ (4 * 60);
        if (block != _lastAutosavedFourHourBlock) {
          _lastAutosavedFourHourBlock = block;
          unawaited(saveNow());
        }
      });
    }
  }

  void dispatch(GameAction action, {bool playSound = true, bool save = true}) {
    if (_disposed) {
      return;
    }
    final previousCash = _state.cash;
    final next = _engine.reduce(_state, action);
    if (identical(_state, next)) {
      return;
    }

    _state = next;
    if (_startClock && playSound) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
    notifyListeners();

    final crossedIntoNegative = previousCash >= 0 && next.cash < 0;
    if (save || crossedIntoNegative) {
      unawaited(saveNow());
    }
  }

  Future<void> saveNow() {
    final snapshot = _state;
    _saveChain = _saveChain.then((_) async {
      try {
        await _snapshotStore.save(snapshot);
        if (_storageError != null) {
          _storageError = null;
          if (!_disposed) {
            notifyListeners();
          }
        }
      } on Object catch (error) {
        _storageError = 'Не удалось сохранить: $error';
        if (!_disposed) {
          notifyListeners();
        }
      }
    });
    return _saveChain;
  }

  Future<void> reset() async {
    await _saveChain;
    await _snapshotStore.clear();
    dispatch(const ResetGame(), save: false);
    await saveNow();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(saveNow());
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (_startClock) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _timer?.cancel();
    unawaited(saveNow());
    super.dispose();
  }
}
