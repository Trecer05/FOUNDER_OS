import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/performance/native_performance_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('founder_os/native_performance.test');

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('native bridge uses one compatible contract for snapshot I/O', () async {
    String? stored;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'diagnostics':
              return <String, Object?>{
                'available': true,
                'backend': 'test_atomic_file',
              };
            case 'saveSnapshot':
              stored = (call.arguments! as Map)['snapshot']! as String;
              return true;
            case 'loadSnapshot':
              return stored;
            case 'clearSnapshot':
              stored = null;
              return true;
            case 'monotonicMicros':
              return 123456789;
          }
          return null;
        });

    final bridge = NativePerformanceBridge(
      channel: channel,
      platformAvailable: true,
    );
    expect(await bridge.isAvailable(), isTrue);
    expect(await bridge.saveSnapshot('{"snapshotVersion":10}'), isTrue);
    expect(await bridge.loadSnapshot(), '{"snapshotVersion":10}');
    expect(await bridge.monotonicMicros(), 123456789);
    expect(await bridge.clearSnapshot(), isTrue);
    expect(await bridge.loadSnapshot(), isNull);
  });
}
