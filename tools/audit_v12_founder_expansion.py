#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []

def require(path: str, needle: str, label: str) -> None:
    target = ROOT / path
    if not target.is_file():
        errors.append(f"{label}: missing {path}")
        return
    text = target.read_text(encoding="utf-8")
    if needle not in text:
        errors.append(f"{label}: missing marker {needle!r}")

def forbid(path: str, needle: str, label: str) -> None:
    target = ROOT / path
    if not target.is_file():
        errors.append(f"{label}: missing {path}")
        return
    text = target.read_text(encoding="utf-8")
    if needle in text:
        errors.append(f"{label}: forbidden marker {needle!r}")

require(
    "lib/domain/entities/game_state.dart",
    "const int currentSnapshotVersion = 12;",
    "snapshot schema",
)
require(
    "lib/domain/entities/game_state.dart",
    "selectedOfficeId: 'remote_first'",
    "remote-first initial state",
)
require(
    "lib/domain/entities/game_state.dart",
    "FounderCompanyProfile companyProfile",
    "company/founder snapshot",
)
require(
    "lib/domain/catalog/game_catalog.dart",
    "id: 'remote_first'",
    "remote-first office option",
)
require(
    "lib/domain/simulation/engine/game_engine.dart",
    "founderDevelopmentCapacityFor(",
    "founder development contribution",
)
require(
    "lib/domain/simulation/engine/game_engine.dart",
    "минимальному плану проекта",
    "exact HR staffing",
)
forbid(
    "lib/domain/simulation/engine/game_engine.dart",
    "ProductImprovementType.values.byName(typeName)",
    "unsafe improvement parser",
)
require(
    "lib/presentation/features/products/product_detail_screen.dart",
    "ProductDevelopmentExperience(",
    "four-stage product experience",
)
require(
    "lib/application/localization/app_localizer.dart",
    "V12LocalizationLexicon",
    "expanded localization",
)

require(
    "lib/domain/simulation/engine/game_engine.dart",
    "founderFeatureWorkCapacityFor(",
    "founder post-release contribution",
)
require(
    "lib/domain/simulation/engine/game_engine.dart",
    "requirement.minimumCount -",
    "HR exact headcount calculation",
)
require(
    "lib/presentation/features/products/product_detail_screen.dart",
    "_safeActiveWorkTitle",
    "immediate improvement crash guard",
)
require(
    "lib/presentation/features/onboarding/company_setup_dialog.dart",
    "itemCount: 25",
    "25-logo company setup",
)
require(
    "lib/application/localization/v12_localization_lexicon.dart",
    '"Структура расходов": "Expense breakdown"',
    "English full-screen terminology",
)

forbid(
    "lib/presentation/features/infrastructure/infrastructure_screen.dart",
    "'Hiring +",
    "untranslated hiring metric",
)
require(
    "lib/presentation/features/infrastructure/infrastructure_screen.dart",
    "'Бонус к найму +",
    "Russian hiring metric",
)

logo_dir = ROOT / "assets/company_logos"
logos = sorted(logo_dir.glob("company_logo_*.png")) if logo_dir.is_dir() else []
if len(logos) != 25:
    errors.append(f"logos: expected 25 PNG files, got {len(logos)}")
else:
    for logo in logos:
        if logo.stat().st_size < 1000:
            errors.append(f"logo too small/empty: {logo.name}")

catalog = ROOT / "lib/domain/catalog/development_content_catalog.dart"
if catalog.is_file():
    text = catalog.read_text(encoding="utf-8")
    code_count = text.count("r'''")
    if code_count < 160:
        errors.append(
            f"development content: expected a large code/options pool, raw snippets={code_count}"
        )
    for language in (
        "html_css",
        "javascript",
        "typescript",
        "python",
        "go",
        "rust",
        "dart",
        "swift",
        "kotlin",
        "java",
        "php",
        "cpp",
    ):
        if f'"{language}"' not in text:
            errors.append(f"development content: language {language} missing")
else:
    errors.append("development content catalog missing")

if errors:
    print("v12 founder expansion audit: FAILED")
    for error in errors:
        print(f" - {error}")
    sys.exit(1)

print("v12 founder expansion audit: ok")
print(f"logos: {len(logos)}")
print("development languages: 12")
