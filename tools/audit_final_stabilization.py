#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
failures: list[str] = []


def load(rel: str) -> str:
    path = root / rel
    if not path.is_file():
        failures.append(f"missing {rel}")
        return ""
    return path.read_text(encoding="utf-8")


toast = load("lib/presentation/shared/widgets/company_notification_toast_host.dart")
for marker in (
    "DismissDirection.up",
    "CompanyNotificationCenterScreen",
    "item.kind != CompanyNotificationKind.research",
    "top-company-notification-toast",
):
    if marker not in toast:
        failures.append(f"toast missing {marker}")
for forbidden in ("_queue", "_GenieClipper"):
    if forbidden in toast:
        failures.append(f"toast still contains {forbidden}")

hub = load("lib/presentation/features/company/company_hub_screen.dart")
for marker in (
    "События и достижения",
    "Widget _opportunities",
    "Widget _legacy",
    "Мировые проекты",
):
    if marker not in hub:
        failures.append(f"strategic company hub missing {marker}")
for forbidden in (
    "_CompanyHubSection.notifications",
    "Widget _notifications",
    "company-hub-sections",
):
    if forbidden in hub:
        failures.append(f"strategic company hub still contains {forbidden}")

more = load("lib/presentation/features/more/more_screen.dart")
spacing = (
    "          ),\n"
    "        ),\n"
    "        const SizedBox(height: 10),\n"
    "        _MenuCard(\n"
    "          icon: Icons.event_note_outlined,"
)
if spacing not in more:
    failures.append("intelligence/events spacing marker missing")

strategy = load("lib/domain/catalog/product_strategy_catalog.dart")
if re.search(r"requiredInvestorCount:\s*[1-9]\d*", strategy):
    failures.append("mandatory investor count remains in strategy catalog")

state = load("lib/domain/entities/game_state.dart")
if "linkedInvestors < requiredInvestors" in state:
    failures.append("GameState mandatory investor gate remains")

engine = load("lib/domain/simulation/engine/game_engine.dart")
if "productInvestors < requiredInvestors" in engine:
    failures.append("simulation mandatory investor gate remains")
if "research_start_${key}_${state.simulationMinutes}" in engine:
    failures.append("research-start notification remains")

create = load("lib/presentation/features/products/create_product_screen.dart")
for forbidden in ("requiredInvestorCount", "investorsReady", "currentInvestors"):
    if forbidden in create:
        failures.append(f"product creation still exposes {forbidden}")

workspace = load("lib/presentation/features/products/product_workspace_screen.dart")
if "development-waiting-investor" in workspace:
    failures.append("workspace investor waiting card remains")

world = load("lib/domain/catalog/world_economy_catalog.dart")
for marker in (
    "FacilitySize.small => 128",
    "FacilitySize.medium => 384",
    "FacilitySize.large => 1280",
    "FacilitySize.campus => 4096",
):
    if marker not in world:
        failures.append(f"DC capacity missing {marker}")

catalog = load("lib/domain/catalog/game_catalog.dart")
for marker in (
    "compute_hypershelf_c128",
    "storage_fabric_s256",
    "ai_megapod_m256",
    "computeUnits: 260000",
    "storageGb: 2000000",
):
    if marker not in catalog:
        failures.append(f"hyperscale hardware missing {marker}")

if "products develop without mandatory investors" not in load(
    "test/domain/r2_gameplay_test.dart"
):
    failures.append("optional investor regression missing")
if "starting player-selected research does not create notification spam" not in load(
    "test/domain/research_endgame_test.dart"
):
    failures.append("research spam regression missing")
if "medium owned data center can host AI MegaPod M256" not in load(
    "test/domain/infrastructure_security_test.dart"
):
    failures.append("late-game infra fit regression missing")

ui_test = load("test/presentation/r2_surfaces_test.dart")
for marker in (
    "top toast ignores unread backlog and opens safe notification center",
    "top toast can be dismissed upward",
    "company hub shows events legacy and world projects without notification tab",
):
    if marker not in ui_test:
        failures.append(f"presentation regression missing {marker}")

if failures:
    print("FINAL STABILIZATION AUDIT: FAIL", file=sys.stderr)
    for failure in failures:
        print(f"- {failure}", file=sys.stderr)
    raise SystemExit(1)

print("FINAL STABILIZATION AUDIT: PASS")
print(
    "Validated notification UX, strategic hub, optional investors and late-game infrastructure."
)
