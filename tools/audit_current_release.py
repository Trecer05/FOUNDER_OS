#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]

required_files = [
    'docs/MASTER_GAME_SPEC.md',
    'docs/TEST_STRATEGY.md',
    'test/support/fixtures.dart',
    'test/support/fakes.dart',
    'test/support/widget_harness.dart',
    'test/domain/simulation_contract_test.dart',
    'test/domain/company_people_test.dart',
    'test/domain/product_lifecycle_test.dart',
    'test/domain/product_market_test.dart',
    'test/domain/infrastructure_security_test.dart',
    'test/domain/finance_ownership_test.dart',
    'test/domain/contracts_ecosystem_test.dart',
    'test/domain/research_endgame_test.dart',
    'test/domain/geography_content_test.dart',
    'test/domain/persistence_schema_test.dart',
    'test/application/controller_persistence_test.dart',
    'test/application/snapshot_storage_test.dart',
    'test/application/settings_native_test.dart',
    'test/presentation/app_shell_test.dart',
    'test/presentation/product_team_flow_test.dart',
    'test/presentation/business_surfaces_test.dart',
    'test/presentation/responsive_localization_test.dart',
]

source_checks = [
    ('lib/domain/entities/game_state.dart', 'const int currentSnapshotVersion = 16;', 'snapshot schema 16'),
    ('lib/domain/entities/game_state.dart', "selectedOfficeId: 'remote_first'", 'remote-first bootstrap'),
    ('lib/domain/entities/game_state.dart', "selectedHostingPlanId: 'no_hosting'", 'no-host bootstrap'),
    ('lib/domain/entities/game_state.dart', 'double productUserSatisfaction(', 'causal satisfaction'),
    ('lib/domain/entities/game_state.dart', 'double productPaidConversionRate(', 'paid conversion'),
    ('lib/domain/entities/game_state.dart', 'double productCac(', 'CAC metric'),
    ('lib/domain/entities/game_state.dart', 'double productArpu(', 'ARPU metric'),
    ('lib/domain/entities/game_state.dart', 'List<String> researchPrerequisiteKeys(', 'R&D dependency resolver'),
    ('lib/domain/entities/game_state.dart', 'double businessLoanApprovalChance(double requestedAmount)', 'loan risk model'),
    ('lib/domain/simulation/engine/game_engine.dart', 'RequestBusinessLoan() => _requestBusinessLoan(state, action.amount)', 'requested loan amount routed'),
    ('lib/domain/simulation/engine/game_engine.dart', 'RenameWorldProject() => _renameWorldProject(', 'world project rename'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _appendRunwayWarning', 'runway warning'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _advanceChurnShocks', 'causal churn shocks'),
    ('lib/application/controllers/game_controller.dart', '_state.simulationMinutes ~/ (4 * 60)', 'four-hour autosave'),
    ('lib/persistence/storage/game_snapshot_store.dart', "static const manualSlotIds = <String>['slot_1', 'slot_2', 'slot_3'];", 'three manual save slots'),
    ('lib/persistence/storage/game_snapshot_store.dart', 'static const _recoverySlotCount = 3;', 'three bankruptcy recovery slots'),
    ('lib/presentation/features/dashboard/founder_dashboard.dart', 'NavigationDestinationLabelBehavior.alwaysShow', 'always-visible navigation labels'),
    ('lib/presentation/features/dashboard/founder_dashboard.dart', 'unreadCompanyNotificationCount', 'notification badge'),
    ('lib/presentation/features/more/more_screen.dart', "'Исследования R&D'", 'R&D navigation'),
    ('lib/presentation/features/more/more_screen.dart', "'Финансы и P&L'", 'finance navigation'),
    ('lib/presentation/features/research/research_screen.dart', "Key('research-screen-${kind.name}-$targetId')", 'dedicated R&D tree UI'),
    ('lib/presentation/features/products/product_workspace_screen.dart', "Key('product-business-funnel')", 'business funnel UI'),
    ('lib/presentation/features/finance/finance_screen.dart', "Key('request-business-loan')", 'loan UI'),
]

failures: list[str] = []

for rel in required_files:
    if not (ROOT / rel).is_file():
        failures.append(f'missing canonical file: {rel}')

for rel, needle, label in source_checks:
    path = ROOT / rel
    if not path.is_file():
        failures.append(f'{label}: missing source file {rel}')
        continue
    text = path.read_text(encoding='utf-8')
    if needle not in text:
        failures.append(f'{label}: missing {needle!r} in {rel}')

master = ROOT / 'docs/MASTER_GAME_SPEC.md'
if master.is_file():
    text = master.read_text(encoding='utf-8')
    for marker in (
        'FOUNDER.OS — MASTER GAME SPECIFICATION',
        'Causal product-market model',
        'Business loan',
        'World projects',
        'Persistence',
        'Каноническая тестовая стратегия',
    ):
        if marker not in text:
            failures.append(f'master spec missing section marker: {marker}')

test_root = ROOT / 'test'
legacy_name = re.compile(
    r'(?:^|_)(?:v\d+|hotfix|stabilization|optimization|release_candidate)(?:_|\.|$)',
    re.IGNORECASE,
)
dart_tests = sorted(test_root.rglob('*_test.dart')) if test_root.is_dir() else []
for path in dart_tests:
    if legacy_name.search(path.name):
        failures.append(f'legacy version-named test remains: {path.relative_to(ROOT)}')

if (ROOT / 'test/widget_test.dart').exists():
    failures.append('legacy root test/widget_test.dart remains; use presentation/app_shell_test.dart')

test_count = 0
for path in dart_tests:
    text = path.read_text(encoding='utf-8')
    test_count += len(re.findall(r'\btest(?:Widgets)?\s*\(', text))

if test_count < 125:
    failures.append(f'canonical suite too small: {test_count} tests, expected at least 125')

domain_count = sum(
    len(re.findall(r'\btest(?:Widgets)?\s*\(', path.read_text(encoding='utf-8')))
    for path in (test_root / 'domain').glob('*_test.dart')
)
application_count = sum(
    len(re.findall(r'\btest(?:Widgets)?\s*\(', path.read_text(encoding='utf-8')))
    for path in (test_root / 'application').glob('*_test.dart')
)
presentation_count = sum(
    len(re.findall(r'\btest(?:Widgets)?\s*\(', path.read_text(encoding='utf-8')))
    for path in (test_root / 'presentation').glob('*_test.dart')
)

if domain_count < 90:
    failures.append(f'domain coverage floor not met: {domain_count} < 90')
if application_count < 15:
    failures.append(f'application coverage floor not met: {application_count} < 15')
if presentation_count < 10:
    failures.append(f'presentation coverage floor not met: {presentation_count} < 10')

if failures:
    print('CURRENT RELEASE AUDIT: FAIL', file=sys.stderr)
    for failure in failures:
        print(f'- {failure}', file=sys.stderr)
    raise SystemExit(1)

print('CURRENT RELEASE AUDIT: PASS')
print(f'Canonical tests: {test_count} total ({domain_count} domain, {application_count} application, {presentation_count} presentation)')
print(f'Canonical files: {len(required_files)}')
print(f'Production invariants: {len(source_checks)}')
