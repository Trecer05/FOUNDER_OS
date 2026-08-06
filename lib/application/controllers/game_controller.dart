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
    Duration tickInterval = const Duration(seconds: 1),
  }) : this._(snapshotStore, engine, startClock, tickInterval);

  GameController._(
    this._snapshotStore,
    this._engine,
    this._startClock,
    this._tickInterval,
  );

  final SnapshotStore _snapshotStore;
  final GameEngine _engine;
  final bool _startClock;
  final Duration _tickInterval;

  GameState _state = GameState.initial();
  Timer? _timer;
  final Stopwatch _activeClock = Stopwatch();
  int _consumedClockSeconds = 0;
  int _lastAutosavedFourHourBlock = -1;
  String? _storageError;
  bool _initialized = false;
  bool _disposed = false;

  GameState? _pendingSnapshot;
  bool _saveRunning = false;
  Completer<void>? _saveCompleter;

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
      _startTicker();
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _activeClock
      ..reset()
      ..start();
    _consumedClockSeconds = 0;
    _timer = Timer.periodic(_tickInterval, (_) => _consumeElapsedTime());
  }

  void _stopTicker() {
    _timer?.cancel();
    _timer = null;
    _activeClock.stop();
  }

  void _consumeElapsedTime() {
    if (_disposed || !_initialized) {
      return;
    }
    final elapsedSeconds = _activeClock.elapsedMilliseconds ~/ 1000;
    final pendingSeconds = elapsedSeconds - _consumedClockSeconds;
    if (pendingSeconds <= 0) {
      return;
    }
    _consumedClockSeconds = elapsedSeconds;

    // Batch timer drift into one deterministic reducer call. A bounded batch
    // avoids a large foreground spike after a debugger pause while preserving
    // normal active-session time.
    var remaining = pendingSeconds;
    while (remaining > 0) {
      final batch = remaining > 15 ? 15 : remaining;
      dispatch(AdvanceTime(batch), playSound: false, save: false);
      remaining -= batch;
    }

    final block = _state.simulationMinutes ~/ (4 * 60);
    if (block != _lastAutosavedFourHourBlock) {
      _lastAutosavedFourHourBlock = block;
      unawaited(saveNow());
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

  /// Coalesces bursts of save requests and always persists the newest snapshot.
  /// Intermediate snapshots are never written after a newer one is queued.
  Future<void> saveNow() {
    _pendingSnapshot = _state;
    _saveCompleter ??= Completer<void>();
    if (!_saveRunning) {
      unawaited(_drainSaveQueue());
    }
    return _saveCompleter!.future;
  }

  Future<void> _drainSaveQueue() async {
    _saveRunning = true;
    try {
      while (_pendingSnapshot != null) {
        final snapshot = _pendingSnapshot!;
        _pendingSnapshot = null;
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
      }
    } finally {
      _saveRunning = false;
      final completer = _saveCompleter;
      _saveCompleter = null;
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
      if (_pendingSnapshot != null && !_disposed) {
        unawaited(saveNow());
      }
    }
  }

  Future<void> reset() async {
    await saveNow();
    await _snapshotStore.clear();
    dispatch(const ResetGame(), save: false);
    await saveNow();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_startClock && !_disposed) {
          _startTicker();
        }
        return;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (_startClock) {
          _stopTicker();
        }
        unawaited(saveNow());
        return;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (_startClock) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _stopTicker();
    unawaited(saveNow());
    super.dispose();
  }
}
