#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== v12 static audit =="
python3 tools/audit_v12_founder_expansion.py

if test -f tools/audit_v10_localization_native.py; then
  echo "== existing localization/native audit =="
  python3 tools/audit_v10_localization_native.py
fi

echo "== flutter pub get =="
flutter pub get --offline

echo "== dart format =="
dart format lib test

echo "== flutter analyze =="
flutter analyze

echo "== focused v12 domain tests =="
flutter test test/domain/v12_founder_expansion_test.dart

echo "== focused v12 widget tests =="
flutter test test/presentation/v12_founder_expansion_widget_test.dart

echo "== snapshot/migration regressions =="
flutter test \
  test/domain/game_state_snapshot_test.dart \
  test/domain/v11_stabilization_test.dart

echo "== all domain tests =="
flutter test test/domain

echo "== all application and presentation tests =="
flutter test test/application test/presentation

echo "== full flutter test =="
flutter test

echo "== git diff check =="
git diff --check

echo "== iOS simulator debug build =="
flutter build ios --simulator --debug

echo "== Android debug build =="
flutter build apk --debug

echo "✅ FOUNDER.OS v12 Founder Expansion verification passed"
