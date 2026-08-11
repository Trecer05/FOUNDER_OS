#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$HOME/Developer/founder_os}"
cd "$ROOT"

if [[ ! -f pubspec.yaml ]]; then
  echo "ERROR: pubspec.yaml not found in $ROOT"
  exit 1
fi

echo "== CURRENT RELEASE STRUCTURAL AUDIT =="
python3 tools/audit_current_release.py .

echo
echo "== FORMAT CANONICAL TEST SUITE =="
dart format test

echo
echo "== FLUTTER ANALYZE =="
flutter analyze .

if [[ -f tools/audit_v13_full_english_locale.py ]]; then
  echo
  echo "== FULL ENGLISH LOCALE AUDIT =="
  python3 tools/audit_v13_full_english_locale.py .
fi

echo
echo "== FULL CANONICAL FLUTTER SUITE: 1 WORKER =="
flutter test --concurrency=1 --reporter compact

echo
echo "== CURRENT RELEASE AUDIT AFTER FORMAT/TEST =="
python3 tools/audit_current_release.py .

echo
echo "== DIFF CHECK =="
git diff --check

if [[ "$(uname -s)" == "Darwin" ]] && command -v xcrun >/dev/null 2>&1; then
  echo
  echo "== IOS SIMULATOR DEBUG BUILD =="
  flutter build ios --simulator --debug --no-codesign
fi

if command -v adb >/dev/null 2>&1 || [[ -n "${ANDROID_HOME:-}" ]] || [[ -n "${ANDROID_SDK_ROOT:-}" ]]; then
  echo
  echo "== ANDROID DEBUG APK =="
  flutter build apk --debug
else
  echo
  echo "== ANDROID BUILD SKIPPED: Android SDK not detected =="
fi

echo
echo "== FINAL STATUS =="
git status -sb

echo
echo "✅ CURRENT MASTER SPEC + CANONICAL TEST SUITE VERIFIED"
echo "Manual Simulator UAT is still required before release/commit is marked fully checked."
