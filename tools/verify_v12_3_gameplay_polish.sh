#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-$(pwd)}"
cd "$ROOT"

echo "== v12.3 static audit =="
python3 tools/audit_v12_3_gameplay_polish.py

echo
echo "== dependency resolution =="
flutter pub get

echo
echo "== flutter analyze =="
flutter analyze

echo
echo "== v12.3 focused domain tests =="
flutter test test/domain/v12_3_gameplay_polish_test.dart --reporter expanded

echo
echo "== v12.2 domain regression =="
flutter test test/domain/v12_2_pre_testflight_test.dart --reporter expanded

echo
echo "== v12.2 widget regression =="
flutter test test/presentation/v12_2_pre_testflight_widget_test.dart --reporter expanded

echo
echo "== market regression after zero-infra start =="
flutter test test/domain/game_engine_test.dart \
  --plain-name "market rewards product advantage even when weaker rival spends on ads" \
  --reporter expanded

echo
echo "== liquidity grace regression after zero-infra start =="
flutter test test/domain/product_economy_v8_test.dart \
  --plain-name "mostly repaid loan grants one final week instead of instant game over" \
  --reporter expanded

echo
echo "== full Flutter suite =="
flutter test --reporter expanded

echo
echo "== git diff check =="
git diff --check

echo
echo "== iOS simulator debug build =="
flutter build ios --simulator --debug

echo
echo "== Android debug build =="
flutter build apk --debug

echo
echo "✅ FOUNDER.OS v12.3 gameplay polish verification passed"
