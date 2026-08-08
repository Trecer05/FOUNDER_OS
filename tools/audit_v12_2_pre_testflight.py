#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()

CHECKS = {
    'atomic clean reset': (
        'lib/application/controllers/game_controller.dart',
        '_state = GameState.initial();',
    ),
    'reset clears save before new state': (
        'lib/application/controllers/game_controller.dart',
        'await _snapshotStore.clear();',
    ),
    'parallel assignment counter': (
        'lib/domain/entities/game_state.dart',
        'activeAssignmentCountForEmployee',
    ),
    'two work efficiency 70': (
        'lib/domain/entities/game_state.dart',
        '2 => 0.70',
    ),
    'three work efficiency 55': (
        'lib/domain/entities/game_state.dart',
        '3 => 0.55',
    ),
    'four work efficiency 40': (
        'lib/domain/entities/game_state.dart',
        '_ => 0.40',
    ),
    'assignment cap four': (
        'lib/domain/entities/game_state.dart',
        'activeAssignmentCountForEmployee(employeeId) < 4',
    ),
    'contract shared efficiency': (
        'lib/domain/entities/game_state.dart',
        'parallelEfficiencyForEmployee(employee.id)',
    ),
    'product assignment max four': (
        'lib/domain/simulation/engine/game_engine.dart',
        'Нельзя назначить сотрудника больше чем на 4 активные работы.',
    ),
    'contract auto assignment': (
        'lib/domain/simulation/engine/game_engine.dart',
        'Автоназначено ${selected.length}',
    ),
    'project challenge thirty percent': (
        'lib/domain/simulation/engine/game_engine.dart',
        'stageSpan * 0.30',
    ),
    'project challenge one key': (
        'lib/domain/entities/v12_game_state_extensions.dart',
        'v12_2_project_challenge:${product.id}',
    ),
    'project challenge overlay': (
        'lib/presentation/features/products/project_challenge_dialog.dart',
        "Key('start-project-challenge')",
    ),
    'dashboard global challenge trigger': (
        'lib/presentation/features/dashboard/founder_dashboard.dart',
        '_maybeShowProjectChallenge',
    ),
    'CEO total capacity': (
        'lib/domain/entities/v12_game_state_extensions.dart',
        'totalDevelopmentCapacityFor',
    ),
    'CEO pinned in assignment sheet': (
        'lib/presentation/features/operations/operations_screen.dart',
        'CEO участвует автоматически',
    ),
    'workspace uses total CEO capacity': (
        'lib/presentation/features/products/product_workspace_screen.dart',
        'state.totalDevelopmentCapacityFor(product)',
    ),
    'operations uses total CEO capacity': (
        'lib/presentation/features/operations/operations_screen.dart',
        'state.totalDevelopmentCapacityFor(product)',
    ),
    'contract sufficiency UI': (
        'lib/presentation/features/contracts/contracts_screen.dart',
        'Команды хватает',
    ),
    'contract detail max four UI': (
        'lib/presentation/features/contracts/contract_detail_screen.dart',
        'работ $assignmentCount/4',
    ),
    'project review tiles': (
        'lib/presentation/features/products/create_product_screen.dart',
        'color: AppColors.surfaceMuted',
    ),
    'progressive design structure': (
        'lib/presentation/features/products/product_development_experience.dart',
        '_MockupPainter(seed: scene.seed, structure: value)',
    ),
    'design final coherent copy': (
        'lib/presentation/features/products/product_development_experience.dart',
        'Финальный макет: элементы выровнены в цельную структуру.',
    ),
    'released product compact rail state': (
        'lib/presentation/shared/widgets/development_stage_progress_rail.dart',
        "english ? 'Development complete' : 'Разработка завершена'",
    ),
    'legacy two-product allocation regression updated': (
        'test/domain/game_engine_test.dart',
        "expect(state.employeeAllocationForProduct('c_anna', firstId), 70);",
    ),
    'legacy v10 allocation regression updated': (
        'test/domain/ux_economy_v10_test.dart',
        'closeTo(70, 0.01)',
    ),
    'index allocation regression updated': (
        'test/domain/game_state_index_test.dart',
        "state.employeeAllocationForProduct(employee.id, 'fixture_product'),\n      100,",
    ),
    'v12 challenge regression updated': (
        'test/domain/v12_founder_expansion_test.dart',
        'development challenge is rewarded at most once per project',
    ),
    'focused v12.2 domain tests': (
        'test/domain/v12_2_pre_testflight_test.dart',
        'parallel employee efficiency is deterministic from one to four works',
    ),
    'focused v12.2 widget tests': (
        'test/presentation/v12_2_pre_testflight_widget_test.dart',
        'new company reset clears the entire previous simulation cycle',
    ),
    'legacy contract tap fully visible': (
        'test/widget_test.dart',
        'await tester.ensureVisible(accept);',
    ),
}


def main() -> None:
    errors: list[str] = []
    cache: dict[str, str] = {}
    for label, (rel, marker) in CHECKS.items():
        path = ROOT / rel
        if not path.is_file():
            errors.append(f'{label}: missing file {rel}')
            continue
        text = cache.setdefault(rel, path.read_text(encoding='utf-8'))
        if marker not in text:
            errors.append(f'{label}: missing marker {marker!r}')

    dev = (ROOT / 'lib/presentation/features/products/product_development_experience.dart')
    if dev.is_file():
        dev_text = dev.read_text(encoding='utf-8')
        if 'CompleteDevelopmentChallenge(' in dev_text:
            errors.append('daily/inline challenge still exists inside ProductDevelopmentExperience')

    if errors:
        print('v12.2 pre-TestFlight audit: FAILED')
        for error in errors:
            print(f'- {error}')
        raise SystemExit(1)

    print('v12.2 pre-TestFlight audit: ok')
    print(f'checks: {len(CHECKS)}')


if __name__ == '__main__':
    main()
