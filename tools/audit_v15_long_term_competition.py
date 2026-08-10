#!/usr/bin/env python3
"""Static release audit for the v15 long-term competition patch."""

from pathlib import Path
import sys


ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
failures: list[str] = []


def require(relative: str, needle: str, label: str) -> None:
    path = ROOT / relative
    if not path.is_file():
        failures.append(f"{label}: missing {relative}")
        return
    if needle not in path.read_text(encoding="utf-8"):
        failures.append(f"{label}: missing {needle!r}")


def require_ordered(relative: str, needles: tuple[str, ...], label: str) -> None:
    path = ROOT / relative
    if not path.is_file():
        failures.append(f"{label}: missing {relative}")
        return
    text = path.read_text(encoding="utf-8")
    cursor = 0
    for needle in needles:
        position = text.find(needle, cursor)
        if position < 0:
            failures.append(f"{label}: missing or out of order {needle!r}")
            return
        cursor = position + len(needle)


checks = (
    ("lib/domain/entities/game_state.dart", "currentSnapshotVersion = 13", "snapshot v13"),
    ("lib/domain/simulation/engine/game_engine.dart", "next.productIncidentMultiplier(target.id) /\n                3", "player attacks divided by three"),
    ("lib/domain/simulation/engine/game_engine.dart", "rivalCyberRoll < 0.035", "rival cyber incidents"),
    ("lib/persistence/storage/snapshot_store.dart", "BankruptcyRecoveryStore", "weekly recovery contract"),
    ("lib/persistence/storage/game_snapshot_store.dart", "weekly_recovery.v1", "rotating recovery persistence"),
    ("lib/application/controllers/game_controller.dart", "restoreWeekBeforeBankruptcy", "bankruptcy recovery action"),
    ("lib/presentation/features/dashboard/founder_dashboard.dart", "if (!mounted) return;\n                if (!dialogContext.mounted) return;", "bankruptcy dialog async context guards"),
    ("lib/domain/catalog/game_catalog.dart", "for (var index = 1; index < 20; index += 1)", "twenty competitors"),
    ("lib/domain/catalog/game_catalog.dart", "marketScore: 100", "market leader benchmark"),
    ("lib/domain/entities/game_state.dart", "clicks * conversion * 2.4", "paid acquisition rebalance"),
    ("lib/presentation/features/team/team_screen.dart", "team-employee-search", "employee filters"),
    ("lib/domain/entities/models.dart", "required this.memoryGb", "server memory"),
    ("lib/domain/entities/models.dart", "required this.storageGb", "server storage"),
    ("lib/domain/entities/game_state.dart", "productResourceLoad", "multi-resource load"),
    ("lib/domain/explainability/product_configuration_resolver.dart", "'swift', 'dart'", "Dart HSM support"),
    ("lib/presentation/features/products/product_workspace_screen.dart", "_WorkspaceSection.monetization", "separate monetization screen"),
    ("lib/domain/commands/game_action.dart", "class AddProductTechnology", "post-release stack expansion"),
    ("lib/domain/commands/game_action.dart", "class RenameProduct", "product rename"),
    ("lib/domain/entities/models.dart", "List<ProductBug> openBugs", "weighted product bugs"),
    ("lib/domain/entities/models.dart", "releasedAtMinutes", "release age persistence"),
    ("lib/domain/simulation/engine/game_engine.dart", "promotedGrade", "course grade promotion"),
    ("lib/domain/entities/game_state.dart", "EmployeeGrade.senior => 0.24", "grade-based PM bonus"),
    ("lib/domain/entities/game_state.dart", "if (age <= 180) return 100", "technical aging grace"),
    ("lib/domain/entities/game_state.dart", "(age - 180) * 0.18", "irreversible freshness ceiling"),
    ("lib/domain/entities/game_state.dart", "? 0.82 : 1.0", "VPS operations efficiency"),
    ("lib/presentation/shared/widgets/global_time_control_bar.dart", "fontSize: 14.5", "larger date"),
    ("lib/presentation/shared/widgets/global_time_control_bar.dart", "shortWeekdayName", "weekday in time bar"),
    ("lib/application/controllers/game_controller.dart", "finally {\n      if (_startClock && !_disposed)", "slot-load ticker restart in finally"),
    ("lib/domain/entities/game_state.dart", "final baselineMemoryGb =", "website RAM baseline value"),
    ("lib/domain/entities/game_state.dart", "product.blueprintId == 'company_website'", "website RAM baseline selector"),
    ("lib/domain/simulation/engine/game_engine.dart", ".min(0.53, math.max(0, state.productServerLoad(product) - 0.82))", "market overload penalty capped at critical threshold"),
    ("lib/presentation/shared/widgets/global_time_control_bar.dart", "AppText.rich(", "single rich date-time text block"),
    ("lib/presentation/features/infrastructure/infrastructure_screen.dart", "final width = (constraints.maxWidth - 10) / 2", "compact infrastructure grid"),
    ("test/application/v15_full_suite_compatibility_test.dart", "domain/entities/product_strategy_models.dart", "CompanyLoan compatibility-test import"),
)

for relative, needle, label in checks:
    require(relative, needle, label)

require_ordered(
    "test/presentation/v14_publisher_uat_polish_widget_test.dart",
    (
        "await tester.tap(find.text('Монетизация'));",
        "workspace-monetization-controls",
        "await tester.tap(find.text('Реклама'));",
        "DropdownButtonFormField<String>",
        "Прогноз по всем каналам",
    ),
    "workspace monetization-to-advertising regression flow",
)

for relative in (
    "test/domain/v15_long_term_competition_test.dart",
    "test/application/v15_bankruptcy_recovery_test.dart",
    "test/application/v15_full_suite_compatibility_test.dart",
    "test/presentation/v14_publisher_uat_polish_widget_test.dart",
):
    if not (ROOT / relative).is_file():
        failures.append(f"focused regression missing: {relative}")

if failures:
    print("V15 LONG-TERM COMPETITION AUDIT: FAIL", file=sys.stderr)
    for failure in failures:
        print(f"- {failure}", file=sys.stderr)
    raise SystemExit(1)

print("V15 LONG-TERM COMPETITION AUDIT: PASS")
print(f"Validated {len(checks) + 1} implementation invariants and 4 focused test files.")
