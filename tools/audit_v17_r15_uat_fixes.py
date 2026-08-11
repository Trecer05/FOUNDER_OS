#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
checks = [
    ('lib/domain/entities/game_state.dart', 'double companyPerkMonthlyCost(String perkId)', 'per-employee perk OPEX'),
    ('lib/domain/entities/game_state.dart', 'double get monthlyWorldProjectRevenue', 'world project revenue'),
    ('lib/domain/entities/game_state.dart', 'double productUserSatisfaction(Product product)', 'user satisfaction'),
    ('lib/domain/entities/v17_models.dart', 'final String customName;', 'world project custom name snapshot'),
    ('lib/domain/commands/game_action.dart', 'class RenameWorldProject extends GameAction', 'world rename action'),
    ('lib/domain/simulation/engine/game_engine.dart', 'Сначала исследуйте технологию в R&D:', 'new product research gate'),
    ('lib/presentation/features/research/research_screen.dart', "key: const Key('research-screen-list')", 'dedicated R&D screen'),
    ('lib/presentation/shared/widgets/technology_selector_panel.dart', "const Chip(label: AppText('Нужно R&D'))", 'creation UI research gate'),
    ('lib/presentation/features/products/product_workspace_screen.dart', "key: const Key('product-user-satisfaction')", 'satisfaction UI'),
    ('lib/presentation/features/products/product_workspace_screen.dart', "MonetizationModel.advertising => 'Количество рекламы'", 'ad amount copy'),
    ('lib/presentation/features/products/product_workspace_screen.dart', "MonetizationModel.advertising => 'Навязчивость рекламы'", 'ad intrusiveness copy'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'double _relativeDeltaPercent(double delta, double baseline)', 'ad percentage recalculation'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'TextFormField(', 'safe rename field'),
    ('lib/presentation/features/dashboard/founder_dashboard.dart', 'Icons.favorite_outline', 'fan icon header'),
    ('lib/presentation/features/dashboard/founder_dashboard.dart', 'Icons.workspace_premium_outlined', 'reputation icon header'),
    ('lib/presentation/features/company/company_hub_screen.dart', "Key('rename-world-project-${definition.id}')", 'world project rename UI'),
    ('lib/presentation/features/finance/finance_screen.dart', 'state.monthlyWorldProjectRevenue', 'finance world revenue'),
    ('test/domain/v17_r15_uat_fixes_test.dart', 'perk recurring cost follows employee headcount after enable', 'perk regression'),
    ('test/domain/v17_r15_uat_fixes_test.dart', 'researched technology integrates into a live product', 'post-research integration regression'),
    ('test/domain/v17_r15_uat_fixes_test.dart', 'rename dialog can be closed with back without disposed controller error', 'rename regression'),
]
failed = []
# R15_SEMANTIC_BASELINE_RESEARCH_AUDIT
_game_state_text = (ROOT / 'lib/domain/entities/game_state.dart').read_text(encoding='utf-8')
_baseline_research_pattern = re.compile(
    r"if\s*\(\s*kind\s*==\s*ResearchTargetKind\.technology\s*&&\s*"
    r"const\s*<String>\s*\{\s*'postgresql'\s*,\s*'observability_stack'\s*,?\s*"
    r"\}\s*\.contains\(targetId\)\s*\)",
    re.DOTALL,
)
if not _baseline_research_pattern.search(_game_state_text):
    failed.append(
        'baseline researched technologies: semantic researchCompleted gate '
        'for PostgreSQL + Observability Stack is missing'
    )
for rel, needle, label in checks:
    path = ROOT / rel
    if not path.exists() or needle not in path.read_text(encoding='utf-8'):
        failed.append(f'{label}: {rel} missing {needle!r}')
if failed:
    print('R15 STATIC AUDIT: FAIL')
    for item in failed:
        print(' -', item)
    raise SystemExit(1)
print(f'R15 STATIC AUDIT: PASS ({len(checks)} checks)')
