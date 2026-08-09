#!/bin/bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== FULL ENGLISH LOCALE AUDIT =="
python3 tools/audit_v13_full_english_locale.py .

echo
echo "== V14 DOMAIN REGRESSIONS =="
flutter test test/domain/v14_publisher_uat_polish_test.dart --reporter expanded

echo
echo "== MANAGEMENT PARALLEL-WORK REGRESSION =="
flutter test test/domain/management_refactor_test.dart \
  --plain-name "product and contract teams allow parallel work and remain atomic" \
  --reporter expanded

echo
echo "== V14 LOCALIZATION REGRESSIONS =="
flutter test test/application/localization_v10_optimization_test.dart --reporter expanded

echo
echo "== V14 WIDGET REGRESSIONS =="
flutter test test/presentation/v14_publisher_uat_polish_widget_test.dart --reporter expanded

echo
echo "== FLUTTER ANALYZE =="
flutter analyze

echo
echo "== COMPLETE FLUTTER TEST SUITE =="
flutter test --reporter compact

echo
echo "== IOS SIMULATOR DEBUG BUILD =="
flutter build ios --simulator --debug

echo
echo "== ANDROID DEBUG BUILD =="
flutter build apk --debug

echo
echo "== DIFF CHECK =="
git diff --check

echo
echo "V14 PUBLISHER UAT POLISH: PASS"
