#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []

localizer = (ROOT / 'lib/application/localization/app_localizer.dart').read_text(encoding='utf-8')
for forbidden in (
    '_cyrillizeUnknownEnglish',
    '_latinToCyrillic',
    "'Backend': 'Серверная разработка'",
    "'Frontend': 'Интерфейсная разработка'",
    "'Compute': 'Вычислительная мощность'",
):
    if forbidden in localizer:
        errors.append(f'unsafe RU localization remains: {forbidden}')

for required in (
    "'frontend',",
    "'backend',",
    "'product manager',",
    "'people partner',",
    "'payroll': 'зарплаты'",
):
    if required not in localizer:
        errors.append(f'safe RU terminology marker missing: {required}')

state = (ROOT / 'lib/domain/entities/game_state.dart').read_text(encoding='utf-8')
for required in (
    'currentSnapshotVersion = 11',
    'hasLegacyStarterHardware',
    'installedServers: const <InstalledServer>[]',
):
    if required not in state:
        errors.append(f'v11 state marker missing: {required}')

checks = {
    'lib/presentation/shared/widgets/responsive_info_row.dart': 'class ResponsiveInfoRow',
    'lib/presentation/features/team/team_screen.dart': "Key('team-hr-status')",
    'lib/presentation/features/products/product_workspace_screen.dart': 'isExpanded: true',
    'lib/presentation/features/overview/overview_screen.dart': "Key('overview-profit-period-toggle')",
    'lib/presentation/features/finance/finance_screen.dart': "label: 'Зарплаты'",
    'lib/application/localization/app_text.dart': 'final bool translate;',
}
for relative, marker in checks.items():
    content = (ROOT / relative).read_text(encoding='utf-8')
    if marker not in content:
        errors.append(f'{relative}: missing {marker}')

for native in (
    'ios/Runner/AppDelegate.swift',
    'android/app/src/main/kotlin/com/example/founder_os/MainActivity.kt',
):
    if 'founder_os/native_performance' not in (ROOT / native).read_text(encoding='utf-8'):
        errors.append(f'{native}: native snapshot channel missing')

if errors:
    print('v11 stabilization audit failed:')
    for error in errors:
        print(f'- {error}')
    raise SystemExit(1)

print('v11 stabilization audit: ok')
