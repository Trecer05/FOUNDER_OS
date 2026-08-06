import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Thin, optional bridge for platform work that is safer and cheaper outside
/// the Dart heap: atomic snapshot I/O and monotonic-clock diagnostics.
///
/// The simulation itself deliberately remains in Dart so seeded RNG and reducer
/// behavior cannot diverge between iOS, Android, tests, and future platforms.
class NativePerformanceBridge {
  NativePerformanceBridge({MethodChannel? channel, this._platformAvailable})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName = 'founder_os/native_performance';
  static final NativePerformanceBridge instance = NativePerformanceBridge();

  final MethodChannel _channel;
  final bool? _platformAvailable;
  bool? _available;

  bool get mayBeAvailable =>
      _platformAvailable ??
      (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android));

  Future<bool> isAvailable() async {
    if (!mayBeAvailable) {
      return false;
    }
    final cached = _available;
    if (cached != null) {
      return cached;
    }
    try {
      final diagnostics = await _channel.invokeMapMethod<String, Object?>(
        'diagnostics',
      );
      final available = diagnostics?['available'] == true;
      _available = available;
      return available;
    } on MissingPluginException {
      _available = false;
      return false;
    } on PlatformException {
      _available = false;
      return false;
    }
  }

  Future<String?> loadSnapshot() async {
    if (!await isAvailable()) {
      return null;
    }
    try {
      return await _channel.invokeMethod<String>('loadSnapshot');
    } on MissingPluginException {
      _available = false;
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<bool> saveSnapshot(String snapshot) async {
    if (!await isAvailable()) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>(
            'saveSnapshot',
            <String, Object?>{'snapshot': snapshot},
          ) ??
          false;
    } on MissingPluginException {
      _available = false;
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> clearSnapshot() async {
    if (!await isAvailable()) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('clearSnapshot') ?? false;
    } on MissingPluginException {
      _available = false;
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<int?> monotonicMicros() async {
    if (!await isAvailable()) {
      return null;
    }
    try {
      return await _channel.invokeMethod<int>('monotonicMicros');
    } on MissingPluginException {
      _available = false;
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<Map<String, Object?>> diagnostics() async {
    if (!mayBeAvailable) {
      return const <String, Object?>{
        'available': false,
        'backend': 'dart_fallback',
      };
    }
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'diagnostics',
      );
      _available = result?['available'] == true;
      return result ??
          const <String, Object?>{
            'available': false,
            'backend': 'dart_fallback',
          };
    } on MissingPluginException {
      _available = false;
      return const <String, Object?>{
        'available': false,
        'backend': 'dart_fallback',
      };
    } on PlatformException catch (error) {
      return <String, Object?>{
        'available': false,
        'backend': 'dart_fallback',
        'error': error.code,
      };
    }
  }
}
