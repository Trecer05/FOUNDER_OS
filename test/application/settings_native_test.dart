import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/performance/native_performance_bridge.dart';
import 'package:founder_os/application/settings/display_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('display currency converts fixed offline RUB rates', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = DisplayPreferences.instance;
    await preferences.initialize();
    await preferences.setLanguage(AppLanguage.en);
    await preferences.setCurrency(DisplayCurrency.usd);
    expect(
      preferences.formatMoney(DisplayPreferences.rubPerUsd),
      contains('1.00'),
    );
    expect(
      preferences.formatMoney(DisplayPreferences.rubPerUsd),
      contains(r'$'),
    );
    await preferences.setCurrency(DisplayCurrency.eur);
    expect(
      preferences.formatMoney(DisplayPreferences.rubPerEur),
      contains('1.00'),
    );
    expect(
      preferences.formatMoney(DisplayPreferences.rubPerEur),
      contains('€'),
    );
    await preferences.setCurrency(DisplayCurrency.rub);
    await preferences.setLanguage(AppLanguage.ru);
  });

  test('display preferences persist language and currency', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = DisplayPreferences.instance;
    await preferences.initialize();
    await preferences.setCurrency(DisplayCurrency.usd);
    await preferences.setLanguage(AppLanguage.en);
    final storage = await SharedPreferences.getInstance();
    expect(storage.getString('display_currency_v10'), 'usd');
    expect(storage.getString('app_language_v10'), 'en');
    await preferences.setCurrency(DisplayCurrency.rub);
    await preferences.setLanguage(AppLanguage.ru);
  });

  test('money formatting uses locale-specific compact suffixes', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = DisplayPreferences.instance;
    await preferences.initialize();
    await preferences.setLanguage(AppLanguage.ru);
    expect(preferences.formatMoney(1500000), contains('млн'));
    await preferences.setLanguage(AppLanguage.en);
    expect(preferences.formatMoney(1500000), contains('M'));
    await preferences.setLanguage(AppLanguage.ru);
  });

  test(
    'native bridge uses one contract for snapshot I/O and diagnostics',
    () async {
      const channel = MethodChannel(
        'founder_os/native_performance.current_test',
      );
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
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      final bridge = _ChannelNativeBridge(channel);
      expect(await bridge.isAvailable(), isTrue);
      expect(await bridge.saveSnapshot('{"snapshotVersion":16}'), isTrue);
      expect(await bridge.loadSnapshot(), '{"snapshotVersion":16}');
      expect(await bridge.monotonicMicros(), 123456789);
      expect(await bridge.clearSnapshot(), isTrue);
      expect(await bridge.loadSnapshot(), isNull);
    },
  );

  test(
    'native bridge degrades to null/false when platform is unavailable',
    () async {
      final bridge = _UnavailableNativeBridge();
      expect(await bridge.isAvailable(), isFalse);
      expect(await bridge.loadSnapshot(), isNull);
      expect(await bridge.saveSnapshot('{}'), isFalse);
      expect(await bridge.clearSnapshot(), isFalse);
      expect(await bridge.monotonicMicros(), isNull);
      expect((await bridge.diagnostics())['backend'], 'dart_fallback');
    },
  );
}

class _ChannelNativeBridge extends NativePerformanceBridge {
  _ChannelNativeBridge(MethodChannel channel) : super(channel: channel);

  @override
  bool get mayBeAvailable => true;
}

class _UnavailableNativeBridge extends NativePerformanceBridge {
  _UnavailableNativeBridge() : super();

  @override
  bool get mayBeAvailable => false;
}
