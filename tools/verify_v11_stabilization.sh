#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export GIT_PAGER=cat
export PAGER=cat

echo "== v11 static audit =="
python3 tools/audit_v11_stabilization.py

echo "== existing localization/native audit =="
python3 tools/audit_localization_v10_optimization.py

echo "== dart format =="
dart format lib test

echo "== flutter analyze =="
flutter analyze

echo "== focused v11 tests =="
flutter test test/domain/v11_stabilization_test.dart
flutter test test/application/localization_v10_optimization_test.dart
flutter test test/presentation/v11_stabilization_widget_test.dart
flutter test test/presentation/v10_optimization_widget_test.dart

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

echo "✅ FOUNDER.OS v11 stabilization verification passed"
