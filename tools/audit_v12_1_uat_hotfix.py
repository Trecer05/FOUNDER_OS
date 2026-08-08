from pathlib import Path
import sys

root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
errors = []

def text(path):
    p = root / path
    if not p.exists():
        errors.append(f"missing file: {path}")
        return ""
    return p.read_text(encoding="utf-8")

checks = {
    "reset setup listener": (
        "lib/presentation/features/dashboard/founder_dashboard.dart",
        "!state.companyProfile.configured",
    ),
    "company setup russian": (
        "lib/presentation/features/onboarding/company_setup_dialog.dart",
        "Предыстория CEO",
    ),
    "technology panel russian": (
        "lib/presentation/shared/widgets/technology_selector_panel.dart",
        "Техдолг",
    ),
    "wizard payroll estimate": (
        "lib/presentation/features/products/create_product_screen.dart",
        "Ориентировочная стоимость разработки",
    ),
    "wizard compute estimate": (
        "lib/presentation/features/products/create_product_screen.dart",
        "Мощность инфраструктуры",
    ),
    "wizard selected language names": (
        "lib/presentation/features/products/create_product_screen.dart",
        "_selectedLanguageNames",
    ),
    "stage rail product list": (
        "lib/presentation/features/products/products_screen.dart",
        "DevelopmentStageProgressRail",
    ),
    "stage rail project center": (
        "lib/presentation/features/operations/operations_screen.dart",
        "DevelopmentStageProgressRail",
    ),
    "stage rail workspace": (
        "lib/presentation/features/products/product_workspace_screen.dart",
        "DevelopmentStageProgressRail",
    ),
    "rich development workspace": (
        "lib/presentation/features/products/product_workspace_screen.dart",
        "ProductDevelopmentExperience",
    ),
    "full development stage names": (
        "lib/presentation/features/products/product_development_experience.dart",
        "Проектирование",
    ),
    "stage rail details": (
        "lib/presentation/features/products/product_detail_screen.dart",
        "DevelopmentStageProgressRail",
    ),
    "security russian header": (
        "lib/presentation/features/security/security_center_screen.dart",
        "Управление безопасностью",
    ),
}
for label, (path, marker) in checks.items():
    if marker not in text(path):
        errors.append(f"{label}: missing marker {marker!r}")

forbidden = {
    "lib/presentation/features/operations/operations_screen.dart": [
        "'Capacity ${capacity.toStringAsFixed(2)} FTE'",
    ],
    "lib/presentation/features/security/security_center_screen.dart": [
        "title: 'Security operations'",
        "label: 'Security'",
        "label: 'Incident multiplier'",
        "_Tag('Setup ",
        " security')",
    ],
    "lib/presentation/features/products/products_screen.dart": [
        "_MetricPill('Users'",
        "_MetricPill('Rating'",
        "_MetricPill('Load'",
        "_MetricPill('Fresh'",
        "_MetricPill('Team'",
    ],
    "lib/presentation/features/products/product_detail_screen.dart": [
        "label: 'Users'",
        "label: 'Activation'",
        "label: 'Retention 30d'",
        "label: 'Churn'",
        "label: 'Rating'",
        "label: 'Latency'",
        "label: 'Design'",
        "label: 'Security'",
        "label: 'Reliability'",
        "'Development capacity'",
    ],
    "lib/presentation/features/onboarding/company_setup_dialog.dart": [
        "сохраняются в snapshot",
        "Background даёт",
        "Снижает burn",
        "'бэкграунд'",
    ],
    "lib/presentation/shared/widgets/technology_selector_panel.dart": [
        "tech debt",
        "OPEX",
        "'Infra ",
        "'Support ",
        "'Stability ",
        "framework/roadmap",
    ],
    "lib/presentation/features/products/create_product_screen.dart": [
        "'Setup сейчас'",
        "'Зарплаты и инфраструктура'",
        "'динамический лимит'",
    ],
}
for path, markers in forbidden.items():
    body = text(path)
    for marker in markers:
        if marker in body:
            errors.append(f"{path}: forbidden old UI marker remains: {marker}")

if errors:
    print("v12.1 UAT hotfix audit: FAILED")
    for error in errors:
        print(f"- {error}")
    raise SystemExit(1)

print("v12.1 UAT hotfix audit: ok")
