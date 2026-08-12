import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../background/background_simulation_service.dart';
import '../performance/native_performance_bridge.dart';
import '../settings/display_preferences.dart';
import '../../domain/commands/game_action.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/models.dart';
import '../../domain/simulation/engine/game_engine.dart';
import '../../persistence/storage/snapshot_store.dart';

class GameController extends ChangeNotifier with WidgetsBindingObserver {
  GameController({
    required SnapshotStore snapshotStore,
    GameEngine engine = const GameEngine(),
    bool startClock = true,
    bool enableBackgroundLifecycle = true,
    Duration tickInterval = const Duration(seconds: 1),
  }) : this._(
         snapshotStore,
         engine,
         startClock,
         enableBackgroundLifecycle,
         tickInterval,
       );

  GameController._(
    this._snapshotStore,
    this._engine,
    this._startClock,
    this._backgroundLifecycleEnabled,
    this._tickInterval,
  );

  static const _backgroundTimestampKey =
      'founder_os.background_started_at_epoch_ms';

  final SnapshotStore _snapshotStore;
  final GameEngine _engine;
  final bool _startClock;
  final bool _backgroundLifecycleEnabled;
  final Duration _tickInterval;
  SharedPreferencesAsync? _lifecyclePreferences;
  SharedPreferencesAsync get _backgroundPreferences =>
      _lifecyclePreferences ??= SharedPreferencesAsync();
  final NativePerformanceBridge _nativeBridge =
      NativePerformanceBridge.instance;

  GameState _state = GameState.initial();
  Timer? _timer;
  final Stopwatch _activeClock = Stopwatch();
  int _consumedClockSeconds = 0;
  int _lastAutosavedFourHourBlock = -1;
  int _lastRecoveryWeek = -1;
  String? _storageError;
  bool _initialized = false;
  bool _disposed = false;
  bool _lifecycleWorkRunning = false;
  int _backgroundGeneration = 0;

  GameState? _pendingSnapshot;
  bool _saveRunning = false;
  Completer<void>? _saveCompleter;

  GameState get state => _state;
  String? get storageError => _storageError;
  bool get initialized => _initialized;
  bool get supportsManualSaves => _snapshotStore is SaveSlotStore;

  Future<void> initialize() async {
    if (_startClock && _backgroundLifecycleEnabled) {
      WidgetsBinding.instance.addObserver(this);
    }
    try {
      _state = await _snapshotStore.load() ?? _freshInitialState();
      _storageError = null;
    } on Object catch (error) {
      _state = _freshInitialState();
      _storageError = 'Сохранение повреждено: $error';
    }

    if (_startClock && _backgroundLifecycleEnabled) {
      await _nativeBridge.cancelCriticalNotification();
      await _applyBackgroundCatchUp();
    }

    _initialized = true;
    if (_startClock && _backgroundLifecycleEnabled) {
      unawaited(_nativeBridge.requestNotificationPermission());
    }
    _lastAutosavedFourHourBlock = _state.simulationMinutes ~/ (4 * 60);
    _lastRecoveryWeek = _state.simulationMinutes ~/ (7 * 1440);
    if (_snapshotStore is BankruptcyRecoveryStore) {
      unawaited(
        (_snapshotStore as BankruptcyRecoveryStore).saveRecoveryCheckpoint(
          _state,
        ),
      );
    }
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
    if (_disposed || !_initialized) return;

    final elapsedSeconds = _activeClock.elapsedMilliseconds ~/ 1000;
    final pendingSeconds = elapsedSeconds - _consumedClockSeconds;
    if (pendingSeconds <= 0) return;
    _consumedClockSeconds = elapsedSeconds;

    var remaining = pendingSeconds;
    while (remaining > 0) {
      final batch = remaining > 15 ? 15 : remaining;
      dispatch(AdvanceTime(batch), playSound: false, save: false);
      remaining -= batch;
      if (_state.criticalEvent != CriticalEventType.none || _state.gameOver) {
        break;
      }
    }

    final block = _state.simulationMinutes ~/ (4 * 60);
    if (block != _lastAutosavedFourHourBlock) {
      _lastAutosavedFourHourBlock = block;
      unawaited(saveNow());
    }
  }

  void dispatch(GameAction action, {bool playSound = true, bool save = true}) {
    if (_disposed) return;

    final previousCash = _state.cash;
    final next = _engine.reduce(_state, action);
    if (identical(_state, next)) return;

    _state = next;
    final recoveryWeek = next.simulationMinutes ~/ (7 * 1440);
    if (recoveryWeek != _lastRecoveryWeek &&
        _snapshotStore is BankruptcyRecoveryStore) {
      _lastRecoveryWeek = recoveryWeek;
      unawaited(
        (_snapshotStore as BankruptcyRecoveryStore).saveRecoveryCheckpoint(
          next,
        ),
      );
    }
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
            if (!_disposed) notifyListeners();
          }
        } on Object catch (error) {
          _storageError = 'Не удалось сохранить: $error';
          if (!_disposed) notifyListeners();
        }
      }
    } finally {
      _saveRunning = false;
      final completer = _saveCompleter;
      _saveCompleter = null;
      if (completer != null && !completer.isCompleted) completer.complete();
      if (_pendingSnapshot != null && !_disposed) {
        unawaited(saveNow());
      }
    }
  }

  Future<int?> _readBackgroundStartedAt() async {
    if (!_startClock || !_backgroundLifecycleEnabled) return null;
    return _backgroundPreferences.getInt(_backgroundTimestampKey);
  }

  Future<void> _writeBackgroundStartedAt(int value) async {
    if (!_startClock || !_backgroundLifecycleEnabled) return;
    await _backgroundPreferences.setInt(_backgroundTimestampKey, value);
  }

  Future<void> _clearBackgroundStartedAt() async {
    if (!_startClock || !_backgroundLifecycleEnabled) return;
    await _backgroundPreferences.remove(_backgroundTimestampKey);
  }

  Future<void> reset() async {
    if (_disposed) return;
    if (_startClock) _stopTicker();

    await saveNow();
    _pendingSnapshot = null;
    await _snapshotStore.clear();
    await _clearBackgroundStartedAt();
    if (_startClock && _backgroundLifecycleEnabled) {
      await _nativeBridge.cancelCriticalNotification();
    }

    _state = _freshInitialState();
    _storageError = null;
    _lastAutosavedFourHourBlock = _state.simulationMinutes ~/ (4 * 60);
    _lastRecoveryWeek = _state.simulationMinutes ~/ (7 * 1440);
    _activeClock.reset();
    _consumedClockSeconds = 0;
    notifyListeners();

    try {
      await _snapshotStore.save(_state);
      if (_snapshotStore is BankruptcyRecoveryStore) {
        await (_snapshotStore as BankruptcyRecoveryStore)
            .saveRecoveryCheckpoint(_state);
      }
    } on Object catch (error) {
      _storageError = 'Не удалось сохранить новую компанию: $error';
      notifyListeners();
    }

    if (_startClock && !_disposed) _startTicker();
  }

  GameState _freshInitialState() => GameState.initial(
    seed: DateTime.now().microsecondsSinceEpoch & 0x7fffffff,
  );

  Future<List<SaveSlotSummary>> listSaveSlots() async {
    if (_snapshotStore is! SaveSlotStore) {
      return const <SaveSlotSummary>[];
    }
    return (_snapshotStore as SaveSlotStore).listSlots();
  }

  Future<void> saveToSlot(String slotId) async {
    if (_snapshotStore is! SaveSlotStore || _disposed) return;
    final store = _snapshotStore as SaveSlotStore;
    await saveNow();
    await store.saveSlot(slotId, _state);
  }

  Future<bool> loadFromSlot(String slotId) async {
    if (_snapshotStore is! SaveSlotStore || _disposed) return false;
    final store = _snapshotStore as SaveSlotStore;
    if (_startClock) _stopTicker();
    try {
      await saveNow();
      final loaded = await store.loadSlot(slotId);
      if (loaded == null) return false;
      _pendingSnapshot = null;
      _state = loaded;
      _storageError = null;
      _lastAutosavedFourHourBlock = _state.simulationMinutes ~/ (4 * 60);
      _lastRecoveryWeek = _state.simulationMinutes ~/ (7 * 1440);
      _activeClock.reset();
      _consumedClockSeconds = 0;
      notifyListeners();
      await _snapshotStore.save(_state);
      return true;
    } finally {
      if (_startClock && !_disposed) _startTicker();
    }
  }

  Future<void> deleteSaveSlot(String slotId) async {
    if (_snapshotStore is SaveSlotStore) {
      await (_snapshotStore as SaveSlotStore).deleteSlot(slotId);
    }
  }

  Future<bool> restoreWeekBeforeBankruptcy() async {
    if (_snapshotStore is! BankruptcyRecoveryStore ||
        _disposed ||
        _state.criticalEvent != CriticalEventType.insolvency) {
      return false;
    }
    if (_startClock) _stopTicker();
    await saveNow();
    final currentMinutes = _state.simulationMinutes;
    final loaded = await (_snapshotStore as BankruptcyRecoveryStore)
        .loadRecoveryCheckpoint(beforeMinutes: currentMinutes - 7 * 1440);
    if (loaded == null) {
      if (_startClock && !_disposed) _startTicker();
      return false;
    }
    _pendingSnapshot = null;
    _state = loaded.copyWith(
      paused: true,
      criticalEvent: CriticalEventType.none,
      clearCriticalProductId: true,
      gameOver: false,
    );
    _storageError = null;
    _lastAutosavedFourHourBlock = _state.simulationMinutes ~/ (4 * 60);
    _lastRecoveryWeek = _state.simulationMinutes ~/ (7 * 1440);
    _activeClock.reset();
    _consumedClockSeconds = 0;
    notifyListeners();
    await _snapshotStore.save(_state);
    if (_startClock && !_disposed) _startTicker();
    return true;
  }

  Future<void> _enterBackground() async {
    if (!_backgroundLifecycleEnabled ||
        _disposed ||
        !_initialized ||
        _lifecycleWorkRunning) {
      return;
    }
    _lifecycleWorkRunning = true;
    final generation = ++_backgroundGeneration;
    try {
      _stopTicker();
      if (!_state.paused &&
          !_state.gameOver &&
          _state.criticalEvent == CriticalEventType.none) {
        await _writeBackgroundStartedAt(DateTime.now().millisecondsSinceEpoch);
        final prediction = await BackgroundSimulationService.predictCritical(
          _state,
          english: DisplayPreferences.instance.language == AppLanguage.en,
        );
        if (!_disposed &&
            generation == _backgroundGeneration &&
            prediction != null) {
          await _nativeBridge.scheduleCriticalNotification(
            title: prediction.title,
            body: prediction.body,
            delaySeconds: prediction.delaySeconds,
          );
        }
      } else {
        await _clearBackgroundStartedAt();
      }
      await saveNow();
    } finally {
      _lifecycleWorkRunning = false;
    }
  }

  Future<void> _resumeFromBackground() async {
    if (!_backgroundLifecycleEnabled ||
        _disposed ||
        !_initialized ||
        _lifecycleWorkRunning) {
      return;
    }
    _lifecycleWorkRunning = true;
    ++_backgroundGeneration;
    try {
      await _nativeBridge.cancelCriticalNotification();
      await _applyBackgroundCatchUp();
      if (!_disposed) {
        notifyListeners();
        await saveNow();
      }
    } finally {
      _lifecycleWorkRunning = false;
      if (_startClock && !_disposed) _startTicker();
    }
  }

  Future<void> _applyBackgroundCatchUp() async {
    final startedAt = await _readBackgroundStartedAt();
    if (startedAt == null) return;
    await _clearBackgroundStartedAt();

    final elapsedSeconds =
        (DateTime.now().millisecondsSinceEpoch - startedAt) ~/ 1000;
    if (elapsedSeconds <= 0 ||
        _state.paused ||
        _state.gameOver ||
        _state.criticalEvent != CriticalEventType.none) {
      return;
    }

    final previousMinutes = _state.simulationMinutes;
    _state = BackgroundSimulationService.catchUp(_state, elapsedSeconds);
    _lastAutosavedFourHourBlock = _state.simulationMinutes ~/ (4 * 60);
    _lastRecoveryWeek = _state.simulationMinutes ~/ (7 * 1440);
    final advancedMinutes = _state.simulationMinutes - previousMinutes;
    if (advancedMinutes > 0) {
      _state = _state.copyWith(
        feed: <String>[
          'Фоновая симуляция: прошло ${advancedMinutes ~/ 60} игровых ч. Компания продолжала работу.',
          ..._state.feed,
        ].take(80).toList(growable: false),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_startClock && _backgroundLifecycleEnabled && !_disposed) {
          unawaited(_resumeFromBackground());
        }
        return;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (_startClock && _backgroundLifecycleEnabled) {
          unawaited(_enterBackground());
        }
        return;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ++_backgroundGeneration;
    if (_startClock && _backgroundLifecycleEnabled) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _stopTicker();
    unawaited(saveNow());
    super.dispose();
  }
}
