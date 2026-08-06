#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$HOME/Developer/founder_os}"
cd "$ROOT"

printf '%s\n' '== v10 static gate =='
python3 <<'PY'
from pathlib import Path

required = {
    'lib/domain/entities/game_state.dart': [
        'const int currentSnapshotVersion = 10;',
        'productMetricHistory',
        'preparedComputeUnits',
        'monthlyOfficeCost',
    ],
    'lib/domain/simulation/engine/game_engine.dart': [
        'AutoHireProjectTeam()',
        '_advanceInvestorNegotiations',
        '_requestBusinessLoan',
        'Частичная выплата',
        '__improvement_',
    ],
    'lib/presentation/features/products/product_workspace_screen.dart': [
        "'Обзор'",
        "'Разработка'",
        "'Команда'",
        "'Реклама'",
        "'Метрики'",
        "'Инфра'",
        'RepaintBoundary',
    ],
    'lib/presentation/shared/widgets/global_time_control_bar.dart': [
        "Key('global-current-time')",
        "Key('global-current-cash')",
        'decoration: TextDecoration.none',
    ],
    'lib/application/settings/display_preferences.dart': [
        'rubPerUsd = 80.9293',
        'rubPerEur = 93.1901',
    ],
}
for path, needles in required.items():
    text = Path(path).read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            raise SystemExit(f'{path}: missing {needle!r}')
print('v10 static gate: ok')
PY

printf '%s\n' '== dart format =='
dart format lib test

printf '%s\n' '== flutter analyze =='
flutter analyze

printf '%s\n' '== focused v10 domain tests =='
flutter test test/domain/ux_economy_v10_test.dart

printf '%s\n' '== focused v10 application tests =='
flutter test test/application/emergency_save_v10_test.dart
flutter test test/application/display_preferences_v10_test.dart

printf '%s\n' '== focused v10 widget tests =='
flutter test test/presentation/ux_v10_widget_test.dart

printf '%s\n' '== all domain tests =='
flutter test test/domain

printf '%s\n' '== all application and presentation tests =='
flutter test test/application test/presentation

printf '%s\n' '== full flutter test =='
flutter test

printf '%s\n' '== git diff check =='
git diff --check

printf '%s\n' '== iOS simulator debug build =='
flutter build ios --simulator --debug

printf '%s\n' '✅ FOUNDER.OS v10 verification passed'
