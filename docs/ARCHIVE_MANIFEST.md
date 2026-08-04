# ARCHIVE_MANIFEST

Этот пакет является overlay для существующего Flutter-проекта `founder_os`.

## Перезаписывается

- `lib/`
- `test/`
- `docs/`
- `pubspec.yaml`
- `README.md`

## Не затрагивается

- `ios/`
- `android/`
- Bundle ID / applicationId;
- signing / Team;
- deployment target / SDK settings;
- Xcode schemes;
- git history и remote.

## Локальные gates после установки

1. `flutter pub get`
2. `dart format lib test`
3. `flutter analyze`
4. `flutter test --reporter expanded`
5. `git diff --check`
6. `flutter build ios --simulator --debug`
7. `flutter build apk --debug`
8. ручной smoke test в Simulator
