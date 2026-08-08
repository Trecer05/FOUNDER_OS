#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []


def text(path: str) -> str:
    target = ROOT / path
    if not target.is_file():
        errors.append(f"missing file: {path}")
        return ""
    return target.read_text(encoding="utf-8")


def require(path: str, marker: str, label: str) -> None:
    if marker not in text(path):
        errors.append(f"{label}: missing {marker!r}")


def forbid(path: str, marker: str, label: str) -> None:
    if marker in text(path):
        errors.append(f"{label}: forbidden {marker!r}")


# 1 — zero-cost fresh start
require("lib/domain/entities/game_state.dart", "selectedOfficeId: 'remote_first'", "remote start")
require("lib/domain/entities/game_state.dart", "selectedServerRoomId: 'no_server_room'", "no server room")
require("lib/domain/entities/game_state.dart", "selectedHostingPlanId: 'no_hosting'", "no hosting")
require("lib/domain/catalog/game_catalog.dart", "id: 'no_server_room'", "zero server room option")
require("lib/domain/catalog/v9_content_catalog.dart", "id: 'no_hosting'", "zero hosting option")

# 2 — alert navigation + top-of-page tab recreation
require("lib/presentation/features/dashboard/founder_dashboard.dart", "void _selectTab(int value)", "critical alert navigation")
require("lib/presentation/features/dashboard/founder_dashboard.dart", "KeyedSubtree(", "tab scroll reset")

# 3 — exact contract staffing
require("lib/domain/commands/game_action.dart", "class AutoHireContractTeam", "contract hiring action")
require("lib/domain/simulation/engine/game_engine.dart", "_autoHireContractTeam", "contract hiring engine")
require("lib/presentation/features/contracts/contract_detail_screen.dart", "Нанять недостающих под контракт", "contract hiring UI")
require("lib/domain/simulation/engine/game_engine.dart", "remainingRoles", "exact contract roles")

# 4 — attack localization no longer clamps cash to zero
require("lib/domain/simulation/engine/game_engine.dart", "cash: state.cash - cost,", "security response debit")
forbid("lib/domain/simulation/engine/game_engine.dart", "math.min(state.cash, cost)", "security zero-balance bug")

# 5/6 — live staffing through Team, settings entry removed
require("lib/presentation/features/products/product_workspace_screen.dart", "Подходящие сотрудники уже в штате", "existing employee assignment")
require("lib/presentation/features/products/product_workspace_screen.dart", "SetProductTeam(", "team removal")
forbid("lib/presentation/features/products/product_workspace_screen.dart", "Все расширенные инструменты", "redundant project settings")
forbid("lib/presentation/features/products/product_workspace_screen.dart", "Icons.tune", "redundant project settings icon")
forbid("lib/presentation/features/products/product_detail_screen.dart", "Управлять проектной командой", "legacy project team button")
forbid("lib/presentation/features/products/product_detail_screen.dart", "OperationsScreen(", "legacy operations navigation")

# 7 — detailed interactive metrics
require("lib/presentation/shared/widgets/interactive_metric_chart_card.dart", "onHorizontalDragUpdate", "interactive chart")
for metric in ("DAU", "MAU", "Retention 30d", "Churn", "Рейтинг", "Требуемая мощность"):
    require("lib/presentation/features/products/product_workspace_screen.dart", f"title: '{metric}'", f"metric {metric}")

# 8 — CEO stays after release
require("lib/domain/entities/v12_game_state_extensions.dart", "product.stage == ProductStage.live", "live CEO capacity")
require("lib/presentation/features/products/product_workspace_screen.dart", "Автоматический участник", "CEO Team UI")

# 9 — product sale and valuation
require("lib/domain/commands/game_action.dart", "class SellProduct", "sell action")
require("lib/domain/entities/v12_game_state_extensions.dart", "blueprint.baseDevelopmentCost * 0.30", "30 percent sale floor")
require("lib/domain/entities/v12_game_state_extensions.dart", "double productSaleValue", "sale valuation")
require("lib/presentation/features/products/product_workspace_screen.dart", "Продать продукт", "sale UI")
require("lib/domain/simulation/engine/game_engine.dart", "product_sale_${buyer.id}", "sale destination")

# 10 — company drilldown/products
require("lib/presentation/features/market/market_screen.dart", "MarketCompanyDetailScreen", "market drilldown")
require("lib/presentation/features/market/market_company_detail_screen.dart", "Продукты компании", "market products")

# 11 — expanded content, weekly candidates, calendar
catalog = text("lib/domain/catalog/game_catalog.dart")
for marker in ("mobile_marketplace", "analytics_platform", "fintech_payments", "video_workspace"):
    if marker not in catalog:
        errors.append(f"product content missing: {marker}")
for marker in ("django_react", "dotnet_react", "rails_hotwire", "spring_kotlin"):
    if marker not in catalog:
        errors.append(f"framework content missing: {marker}")
for marker in ("csharp", "ruby", "scala", "elixir"):
    if marker not in catalog:
        errors.append(f"language content missing: {marker}")
for marker in ('"csharp": <String>[', '"ruby": <String>[', '"scala": <String>[', '"elixir": <String>['):
    require("lib/domain/catalog/development_content_catalog.dart", marker, f"development content {marker}")
require("lib/domain/simulation/engine/game_engine.dart", "day % 7 == 0", "weekly candidates")
require("lib/domain/entities/game_state.dart", "DateTime.utc(2026, 1, 5)", "calendar epoch")
require("lib/presentation/shared/widgets/global_time_control_bar.dart", "state.formattedDateTime", "calendar UI")

# 12 — cash/date only once
forbid("lib/presentation/features/dashboard/founder_dashboard.dart", "class _HeaderMetric", "duplicate cash")
forbid("lib/presentation/features/dashboard/founder_dashboard.dart", "'День ${state.day}", "duplicate date/time")

# 13 — no spare roles/headcount
require("lib/presentation/features/products/product_workspace_screen.dart", "Лишние должности", "no unnecessary product roles")
require("lib/domain/simulation/engine/game_engine.dart", "requirement.minimumCount -", "exact product auto-hire retained")

# 14 — PM boost
require("lib/domain/entities/game_state.dart", "productManagerMultiplier", "PM multiplier")
require("lib/domain/entities/game_state.dart", "? 1.15", "PM 15 percent boost")
require("lib/domain/catalog/product_evolution_catalog.dart", "Ведёт roadmap браузера и ускоряет разработку команды на 15%", "PM is a meaningful browser role")

# Legacy isolated fixtures with live products must provision hosting explicitly
# now that a real fresh company intentionally starts with none.
require(
    "test/domain/game_engine_test.dart",
    "GameState _fundedInitial() => GameState.initial().copyWith(\n  selectedHostingPlanId: 'shared_launch',",
    "market fixture explicit hosting",
)
require(
    "test/domain/product_economy_v8_test.dart",
    "selectedHostingPlanId: 'shared_launch',",
    "liquidity fixture explicit hosting",
)

# 15 — CEO extra points
require("lib/domain/entities/v12_models.dart", "distributableSkillPoints = 22", "CEO points")
require("lib/domain/entities/v12_models.dart", "maximumSkill = 7", "CEO skill ceiling")
require("lib/presentation/features/onboarding/company_setup_dialog.dart", "FounderSkill.product: 5", "default 22-point founder allocation")
for legacy_fixture in (
    "test/domain/v12_2_pre_testflight_test.dart",
    "test/domain/v12_founder_expansion_test.dart",
    "test/presentation/v12_1_uat_hotfix_widget_test.dart",
    "test/presentation/v12_2_pre_testflight_widget_test.dart",
    "test/presentation/v12_founder_expansion_widget_test.dart",
):
    legacy_text = text(legacy_fixture)
    if (
        "FounderSkill.engineering: 4," in legacy_text
        and "FounderSkill.design: 2," in legacy_text
        and "FounderSkill.operations: 2," in legacy_text
    ):
        errors.append(f"{legacy_fixture}: old 12-point founder fixture remains")
    if (
        "FounderSkill.engineering: 5," in legacy_text
        and "FounderSkill.design: 1," in legacy_text
        and "FounderSkill.operations: 3," in legacy_text
    ):
        errors.append(f"{legacy_fixture}: old 12-point founder fixture remains")
require("lib/domain/entities/v12_models.dart", "switch (skill)", "legacy JSON skill fallback")
forbid("lib/presentation/features/tutorial/founder_tutorial_dialog.dart", "12 распределённых очков", "old CEO tutorial copy")

if errors:
    print("v12.3 gameplay polish audit: FAILED")
    for error in errors:
        print(f" - {error}")
    sys.exit(1)

print("v12.3 gameplay polish audit: ok")
print("requirements covered: 15/15")
