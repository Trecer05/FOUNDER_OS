#!/usr/bin/env python3
from pathlib import Path
import sys

root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()

checks = {
    "1_feature_rnd_gate": (
        "lib/presentation/features/products/create_product_screen.dart",
        ["featureIds.every(", "researchCompleted(", "Сначала исследуйте выбранные функции"],
    ),
    "2_lazy_rnd": (
        "lib/presentation/features/research/research_screen.dart",
        ["ListView.builder(", "research-feature-list", "RepaintBoundary("],
    ),
    "3_cold_start": (
        "lib/main.dart",
        ["cold-start-progress", "FOUNDER.OS", "Совет:"],
    ),
    "4_background_time": (
        "lib/application/controllers/game_controller.dart",
        ["background_started_at_epoch_ms", "_applyBackgroundCatchUp", "scheduleCriticalNotification"],
    ),
    "5_notification_routing": (
        "lib/presentation/features/dashboard/founder_dashboard.dart",
        ["open-company-notifications", "Icons.handshake_outlined", "CompanyNotificationToastHost"],
    ),
    "6_loan_cooldown": (
        "lib/domain/entities/r2_gameplay_extensions.dart",
        ["businessLoanRetryRemainingDays", "7 * 1440"],
    ),
    "7_language_and_phases": (
        "lib/domain/entities/r2_gameplay_extensions.dart",
        ["employeeLanguageFitForProduct", "R2DevelopmentWorkstream.frontend", "R2DevelopmentWorkstream.backend", "serverSetup"],
    ),
    "8_notification_read_delete": (
        "lib/presentation/features/company/company_notification_center_screen.dart",
        ["Dismissible(", "clear-all-notifications", "MarkCompanyNotificationRead"],
    ),
    "9_dev_metrics_top": (
        "lib/presentation/features/products/product_workspace_screen.dart",
        ["development-technical-summary", "Текущая фаза"],
    ),
    "10_staffing_rebalance": (
        "lib/domain/entities/game_state.dart",
        ["0.62 + 0.38", ".clamp(0.42, 1.0)", "languageMatch"],
    ),
    "11_live_impact": (
        "lib/presentation/features/products/product_workspace_screen.dart",
        ["live-roadmap-impact", "acquisitionMultiplier", "retentionBonus"],
    ),
    "12_event_dates": (
        "lib/presentation/features/company/company_hub_screen.dart",
        ["availableUntil = state.formatDateAt", "eventDate = state.formatDateAt"],
    ),
    "13_reputation_breakdown": (
        "lib/presentation/features/overview/overview_screen.dart",
        ["reputation-breakdown", "Почему меняется репутация"],
    ),
    "14_top_toasts": (
        "lib/presentation/shared/widgets/company_notification_toast_host.dart",
        ["Duration(seconds: 5)", "_GenieClipper", "top-company-notification-toast"],
    ),
    "15_ad_budget": (
        "lib/presentation/features/products/product_workspace_screen.dart",
        ["1000000000.0", "maxCampaignBudget"],
    ),
    "16_hr_retention": (
        "lib/domain/simulation/engine/game_engine.dart",
        ["hrDepartureMultiplier", "HR удержал сотрудника", "hr_preventive_"],
    ),
    "17_paywall_ru": (
        "lib/presentation/features/products/product_workspace_screen.dart",
        ["Жёсткость платного доступа"],
    ),
    "18_free_tier": (
        "lib/domain/entities/game_state.dart",
        ["freeTier * 0.20", "freeTier * 0.028"],
    ),
    "19_multi_hosting": (
        "lib/domain/entities/game_state.dart",
        ["routedHostingFor(", "hosting:", "dedicatedHostingRoutes"],
    ),
    "20_sale_name": (
        "test/domain/r2_gameplay_test.dart",
        ["selling website never changes surviving AI product name", "AURA Intelligence"],
    ),
    "21_investor_wait": (
        "lib/domain/entities/game_state.dart",
        ["requiredInvestorCount", "productDevelopmentCapacity"],
    ),
}

failures = []
for name, (rel, markers) in checks.items():
    path = root / rel
    if not path.is_file():
        failures.append(f"{name}: missing {rel}")
        continue
    text = path.read_text(encoding="utf-8")
    for marker in markers:
        if marker not in text:
            failures.append(f"{name}: {rel} missing {marker!r}")

# Additional high-leverage invariants.
for rel in (
    "test/domain/r2_gameplay_test.dart",
    "test/application/r2_background_test.dart",
    "test/presentation/r2_surfaces_test.dart",
):
    if not (root / rel).is_file():
        failures.append(f"missing R2 test file: {rel}")

manifest = (root / "android/app/src/main/AndroidManifest.xml").read_text(encoding="utf-8")
if "POST_NOTIFICATIONS" not in manifest or "CriticalNotificationReceiver" not in manifest:
    failures.append("Android native critical notification registration missing")

ios = (root / "ios/Runner/AppDelegate.swift").read_text(encoding="utf-8")
if "scheduleCriticalNotification" not in ios or "UNUserNotificationCenter" not in ios:
    failures.append("iOS native critical notification bridge missing")

if failures:
    print("R2 21-POINT AUDIT: FAIL", file=sys.stderr)
    for failure in failures:
        print(f"- {failure}", file=sys.stderr)
    raise SystemExit(1)

print("R2 21-POINT AUDIT: PASS")
print(f"Validated {len(checks)}/21 requested product changes plus native/test invariants.")
