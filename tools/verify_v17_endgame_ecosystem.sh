#!/bin/bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== V17 R17 STATIC RELEASE AUDIT =="
python3 tools/audit_v17_endgame_ecosystem.py .

echo
echo "== V17 R1 PRODUCT PRESSURE AUDIT =="
python3 tools/audit_v17_product_pressure.py .

echo
echo "== FULL ENGLISH LOCALE AUDIT =="
python3 tools/audit_v13_full_english_locale.py .

echo
echo "== V17 R17 ENDGAME DOMAIN REGRESSIONS =="
flutter test test/domain/v17_endgame_ecosystem_test.dart --reporter expanded

echo
echo "== V17 R17 ENDGAME WIDGET REGRESSIONS =="
flutter test test/presentation/v17_endgame_ecosystem_widget_test.dart --reporter expanded

echo
echo "== V17 R1 PRODUCT PRESSURE DOMAIN =="
flutter test test/domain/v17_product_pressure_test.dart --reporter expanded

echo
echo "== V17 R1 PRODUCT PRESSURE WIDGET + RUNTIME =="
flutter test test/presentation/v17_product_pressure_widget_test.dart --reporter expanded

echo
echo "== V16 DOMAIN REGRESSIONS =="
flutter test test/domain/v16_global_company_test.dart --reporter expanded

echo
echo "== V16 WIDGET REGRESSIONS =="
flutter test test/presentation/v16_global_company_widget_test.dart --reporter expanded

echo
echo "== V15 DOMAIN + COMPATIBILITY REGRESSIONS =="
flutter test test/domain/v15_long_term_competition_test.dart test/application/v15_bankruptcy_recovery_test.dart test/application/v15_full_suite_compatibility_test.dart --reporter compact

echo
echo "== SNAPSHOT MIGRATION REGRESSIONS =="
flutter test test/domain/game_state_snapshot_test.dart test/domain/v11_stabilization_test.dart test/domain/v12_founder_expansion_test.dart --reporter compact

echo
echo "== V14 WORKSPACE REGRESSIONS =="
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
echo "V17 R17 ENDGAME ECOSYSTEM: PASS"
