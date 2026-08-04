#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=== FORMAT ==="
dart format lib test

echo "=== ANALYZE ==="
flutter analyze

echo "=== EVOLUTION TESTS ==="
flutter test test/domain/game_engine_test.dart --reporter expanded
flutter test test/domain/game_state_snapshot_test.dart --reporter expanded
flutter test test/widget_test.dart --reporter expanded

echo "=== ALL TESTS ==="
flutter test --reporter expanded

echo "=== DIFF CHECK ==="
git diff --check

echo "=== IOS SIMULATOR BUILD ==="
flutter build ios --simulator --debug

echo "=== ANDROID DEBUG BUILD ==="
flutter build apk --debug

echo "✅ GUIDANCE_AI_EVOLUTION_V5_VERIFIED"
