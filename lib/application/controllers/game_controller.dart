import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/commands/game_action.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/simulation/engine/game_engine.dart';
import '../../persistence/storage/snapshot_store.dart';

class GameController extends ChangeNotifier {
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
  int _lastAutosavedHour = -1;
  String? _storageError;
  bool _initialized = false;

  GameState get state => _state;
  String? get storageError => _storageError;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    try {
      _state = await _snapshotStore.load() ?? GameState.initial();
      _storageError = null;
    } on Object catch (error) {
      _state = GameState.initial();
      _storageError = 'Сохранение повреждено: $error';
    }

    _initialized = true;
    _lastAutosavedHour = _state.simulationMinutes ~/ 60;

    if (_startClock) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        dispatch(const AdvanceTime(1), playSound: false, save: false);
        final hour = _state.simulationMinutes ~/ 60;
        if (hour != _lastAutosavedHour) {
          _lastAutosavedHour = hour;
          unawaited(saveNow());
        }
      });
    }
  }

  void dispatch(GameAction action, {bool playSound = true, bool save = true}) {
    final next = _engine.reduce(_state, action);
    if (identical(_state, next)) {
      return;
    }

    _state = next;
    if (playSound) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
    notifyListeners();

    if (save) {
      unawaited(saveNow());
    }
  }

  Future<void> saveNow() async {
    try {
      await _snapshotStore.save(_state);
      if (_storageError != null) {
        _storageError = null;
        notifyListeners();
      }
    } on Object catch (error) {
      _storageError = 'Не удалось сохранить: $error';
      notifyListeners();
    }
  }

  Future<void> reset() async {
    await _snapshotStore.clear();
    dispatch(const ResetGame(), save: false);
    await saveNow();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
