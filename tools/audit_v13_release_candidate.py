#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []


def read(path: str) -> str:
    target = ROOT / path
    if not target.is_file():
        errors.append(f"missing file: {path}")
        return ""
    return target.read_text(encoding="utf-8")


def require(path: str, marker: str, label: str) -> None:
    if marker not in read(path):
        errors.append(f"{label}: missing {marker!r}")


def forbid(path: str, marker: str, label: str) -> None:
    if marker in read(path):
        errors.append(f"{label}: forbidden {marker!r}")


game = read("lib/domain/catalog/game_catalog.dart")
strategy = read("lib/domain/catalog/product_strategy_catalog.dart")
extended = read("lib/domain/catalog/extended_feature_catalog.dart")
engine = read("lib/domain/simulation/engine/game_engine.dart")
state = read("lib/domain/entities/game_state.dart")

# Procedural labour market and four grades.
require("lib/domain/entities/models.dart", "enum EmployeeGrade { intern, junior, middle, senior }", "employee grades")
require("lib/domain/catalog/candidate_market_catalog.dart", "remainingUniqueNames", "unique-name exhaustion")
require("lib/domain/catalog/candidate_market_catalog.dart", "nameCombinationCount", "generated names")
require("lib/domain/catalog/candidate_market_catalog.dart", "_metricBand", "grade metric bands")
require("lib/domain/catalog/candidate_market_catalog.dart", "_salaryBand", "grade salary bands")
require("lib/application/controllers/game_controller.dart", "_freshInitialState", "new-game random seed")
forbid("lib/domain/catalog/game_catalog.dart", "Candidate(\n", "pre-authored candidate profiles")
for old_id in ("c_anna", "c_timur", "c_hr_natalia", "c_daria"):
    if old_id in read("test/domain/game_engine_test.dart"):
        errors.append(f"legacy candidate fixture remains: {old_id}")

# Catalog integrity: 17+ products, a strategy for each, and 95+ unique features.
product_ids = re.findall(r"ProductBlueprint\(\s*id: '([^']+)'", game)
strategy_ids = re.findall(r"ProductStrategyProfile\(\s*blueprintId: '([^']+)'", strategy)
core_feature_ids = re.findall(r"FeatureOption\(\s*id: '([^']+)'", game)
extended_feature_ids = re.findall(r"\b_f\('([^']+)'", extended)
feature_ids = core_feature_ids + extended_feature_ids
if len(product_ids) < 17:
    errors.append(f"product catalog too small: {len(product_ids)} < 17")
if set(product_ids) != set(strategy_ids):
    errors.append(f"product/strategy mismatch: products={set(product_ids) - set(strategy_ids)}, strategies={set(strategy_ids) - set(product_ids)}")
if len(feature_ids) < 95:
    errors.append(f"feature catalog too small: {len(feature_ids)} < 95")
if len(feature_ids) != len(set(feature_ids)):
    errors.append("feature ids are not unique")
for expected_block in re.findall(r"expectedFeatureIds:\s*<String>\[(.*?)\]", game, re.S):
    for feature_id in re.findall(r"'([^']+)'", expected_block):
        if feature_id not in feature_ids:
            errors.append(f"blueprint references missing feature: {feature_id}")

# Advertising forecasts stay visible pre-launch and are materially sized.
for marker in ("titan_growth", "short_video", "newsletters", "developer_communities", "affiliate_partners"):
    if marker not in strategy:
        errors.append(f"advertising content missing: {marker}")
require("lib/presentation/features/products/product_workspace_screen.dart", "Прогноз по всем каналам", "prelaunch all-channel forecast")
require("lib/domain/entities/game_state.dart", "'search_ads' => 0.38", "campaign conversion rebalance")

# Development/release/upgrade usability and free overload navigation.
require("lib/presentation/features/products/product_workspace_screen.dart", "release-from-development", "release from development")
require("lib/presentation/features/products/product_workspace_screen.dart", "LinearProgressIndicator(", "upgrade progress")
require("lib/domain/entities/game_state.dart", "option.baseCost / 1600", "faster improvements")
require("lib/domain/simulation/engine/game_engine.dart", "Переход к инфраструктуре ничего не списывает", "free overload navigation")
require("lib/presentation/features/products/product_workspace_screen.dart", "Относительно ${competitor.productName}", "competitor comparison")

# Explanations and global time legibility.
require("lib/presentation/shared/widgets/metric_card.dart", "доля основателя", "founder share hint")
require("lib/presentation/shared/widgets/metric_card.dart", "загрузка сервер", "server load hint")
require("lib/presentation/shared/widgets/metric_card.dart", "оценк", "valuation hint")
require("lib/presentation/shared/widgets/global_time_control_bar.dart", "fontSize: 14.5", "larger date/time")

# Rival scale and non-calendar-template behaviour.
market_pairs = re.findall(r"MarketCompany\(.*?valuation: ([0-9.]+),.*?users: ([0-9]+),", game, re.S)
if not market_pairs:
    errors.append("market company metrics not parsed")
else:
    total_valuation = sum(float(value) for value, _ in market_pairs)
    max_users = max(int(users) for _, users in market_pairs)
    if total_valuation <= 100_000_000_000:
        errors.append(f"market finale too cheap: {total_valuation:.0f}")
    if max_users < 1_000_000_000:
        errors.append(f"market audience too small: {max_users}")
require("lib/domain/simulation/engine/game_engine.dart", "_simulateRivalMove", "stateful rival actions")
forbid("lib/domain/simulation/engine/game_engine.dart", "day % 4 == 0", "fixed competitor news cadence")
forbid("lib/domain/simulation/engine/game_engine.dart", "day % 5 == 0", "fixed competitor pressure cadence")

# 70% psychological progression hook and finale.
require("lib/domain/entities/game_state.dart", "* 0.70", "70 percent gate")
require("lib/domain/entities/game_state.dart", "founderLegacyCompleted", "finale state")
require("lib/domain/entities/game_state.dart", "fullyAcquiredCompanyIds", "persistent full-company acquisition")
require("lib/domain/simulation/engine/game_engine.dart", "Финальная сделка пока закрыта", "final acquisition gate")
require("lib/presentation/features/dashboard/founder_dashboard.dart", "Founder Legacy завершён", "finale dialog")

# Production main menu and three manual save slots.
require("lib/main.dart", "startAtMainMenu: true", "production main menu")
require("lib/persistence/storage/snapshot_store.dart", "abstract interface class SaveSlotStore", "save slot contract")
require("lib/persistence/storage/game_snapshot_store.dart", "['slot_1', 'slot_2', 'slot_3']", "three save slots")
for marker in ("main-menu-continue", "main-menu-new-game", "main-menu-load"):
    require("lib/presentation/features/menu/main_menu_screen.dart", marker, f"main menu {marker}")

# Release-focused regression coverage.
for path in (
    "test/domain/v13_release_candidate_test.dart",
    "test/presentation/v13_main_menu_widget_test.dart",
    "test/application/game_snapshot_store_optimization_test.dart",
):
    read(path)

# Full-suite hotfixes discovered by the Mac release-candidate gate.
require(
    "lib/domain/simulation/engine/game_engine.dart",
    "action is AcceptClientContract",
    "single contract advance ledger entry",
)
require(
    "test/domain/game_engine_test.dart",
    "advanceTransactions, hasLength(1)",
    "contract advance regression",
)
require(
    "lib/presentation/features/team/team_screen.dart",
    "candidate-card-${candidate.id}",
    "stable generated candidate card key",
)
require(
    "lib/presentation/features/products/product_detail_screen.dart",
    "product-roadmap-expansion",
    "collapsed product roadmap",
)
require(
    "tools/verify_v13_release_candidate.sh",
    "КОРОТКИЙ ИТОГ",
    "stage-by-stage verifier summary",
)

if errors:
    print("v13 release-candidate audit: FAILED")
    for error in errors:
        print(f" - {error}")
    sys.exit(1)

print("v13 release-candidate audit: ok")
print(f"products={len(product_ids)}, features={len(feature_ids)}, rival_valuation={sum(float(v) for v, _ in market_pairs):.0f}")
