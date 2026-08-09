#!/usr/bin/env bash
set -uo pipefail

ROOT="${1:-$(pwd)}"
cd "$ROOT"

SUMMARY="${V13_VERIFY_SUMMARY:-$ROOT/v13_verification_summary.txt}"
failures=()
: >"$SUMMARY"

run_stage() {
  local label="$1"
  shift

  echo
  echo "== $label =="
  if "$@"; then
    printf '✅ %s\n' "$label" | tee -a "$SUMMARY"
  else
    local status=$?
    printf '❌ %s (код %s)\n' "$label" "$status" | tee -a "$SUMMARY"
    failures+=("$label")
  fi
}

echo "FOUNDER.OS v13 — полный release-отчёт"
echo "Итог будет сохранён в: $SUMMARY"

run_stage "Статический аудит v13" \
  python3 tools/audit_v13_release_candidate.py
run_stage "Зависимости" flutter pub get
run_stage "Flutter analyzer" flutter analyze
run_stage "Доменные тесты v13" \
  flutter test test/domain/v13_release_candidate_test.dart --reporter expanded
run_stage "Главное меню" \
  flutter test test/presentation/v13_main_menu_widget_test.dart --reporter expanded
run_stage "Сохранения и ручные слоты" \
  flutter test test/application/game_snapshot_store_optimization_test.dart --reporter expanded
run_stage "Полный Flutter test" flutter test --reporter expanded
run_stage "Проверка diff" git diff --check
run_stage "iOS Simulator debug build" flutter build ios --simulator --debug
run_stage "Android release APK" flutter build apk --release

echo
echo "== КОРОТКИЙ ИТОГ =="
cat "$SUMMARY"

if ((${#failures[@]} > 0)); then
  echo
  echo "❌ Не пройдено этапов: ${#failures[@]}"
  printf ' - %s\n' "${failures[@]}"
  echo "Полный список также лежит в: $SUMMARY"
  exit 1
fi

echo
echo "✅ FOUNDER.OS v13 release-candidate verification passed"
