#!/usr/bin/env python3
from pathlib import Path
import sys

root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()

checks = {
    "lib/app/app.dart": [
        "_ModalRouteObserver",
        "IgnorePointer(",
        "ignoring: _modalDepth > 0",
    ],
    "lib/presentation/features/research/research_screen.dart": [
        "title: 'Функции продукта'",
        "maxLines: 3",
        "width: double.infinity",
    ],
    "lib/presentation/features/menu/save_slots_dialog.dart": [
        "return Dialog(",
        "maxHeight: maxDialogHeight",
        "save-slots-scroll",
        "save-slot-action-",
    ],
    "lib/domain/catalog/candidate_market_catalog.dart": [
        "surnameForFirstName",
        "_femaleFirstNames",
    ],
    "lib/presentation/features/team/team_screen.dart": [
        "Прокачка только через грейд",
        "team-upgrade-to-grade",
    ],
    "lib/domain/catalog/contract_catalog.dart": [
        "weeklyOffers(",
        "tierForCompleted(",
        "weekly_",
    ],
    "lib/presentation/features/contracts/contracts_screen.dart": [
        "ContractCatalog.weeklyOffers(",
        "Обновление рынка через",
    ],
    "lib/domain/commands/game_action.dart": ["class RepayBusinessLoanEarly"],
    "lib/domain/entities/product_strategy_models.dart": [
        "earlyPayoffAmountAt",
        "earlyPayoffSavingsAt",
    ],
    "lib/domain/simulation/engine/game_engine.dart": [
        "RepayBusinessLoanEarly() => _repayBusinessLoanEarly(state)",
        "FeatureImpactCatalog.portfolioImpact(",
        "featureImpact.acquisitionMultiplier",
    ],
    "lib/presentation/features/finance/finance_screen.dart": [
        "repay-business-loan-early",
        "Экономия процентов",
    ],
    "lib/domain/catalog/feature_impact_catalog.dart": [
        "class ProductFeaturePortfolioImpact",
        "featureMark(",
        "technologyMark(",
    ],
    "lib/domain/simulation/product_estimator.dart": [
        "FeatureImpactCatalog.fitWeight",
    ],
    "lib/presentation/features/products/create_product_screen.dart": [
        "FeatureImpactCatalog.featureMark",
        "Нужно R&D",
    ],
    "lib/presentation/shared/widgets/technology_selector_panel.dart": [
        "FeatureImpactCatalog.technologyMark",
        "Совместимость: ++",
    ],
    "lib/presentation/features/products/product_detail_screen.dart": [
        "FeatureImpactCatalog.featureMark",
        "FeatureImpactCatalog.technologyMark",
    ],
    "lib/application/localization/v12_localization_lexicon.dart": [
        "Grade-only progression",
        "Pay off loan early",
        "Available jobs • week",
        "Fit: ++ core feature",
    ],
    "test/domain/uat_behavior_test.dart": [
        "weekly contract market rotates",
        "early loan payoff",
        "feature fit creates demand",
    ],
    "test/presentation/uat_layout_test.dart": [
        "R&D stays responsive on narrow iPhone viewport",
        "manual save dialog scrolls without narrow-screen overflow",
        "popup route blocks global time controls behind modal",
    ],
}

errors = []
for rel, markers in checks.items():
    path = root / rel
    if not path.is_file():
        errors.append(f"missing {rel}")
        continue
    text = path.read_text(encoding="utf-8")
    for marker in markers:
        if marker not in text:
            errors.append(f"{rel}: missing marker {marker!r}")

team = (root / "lib/presentation/features/team/team_screen.dart").read_text(
    encoding="utf-8"
)
for forbidden in (
    "team-bulk-course-selector",
    "team-start-bulk-course",
    "key: Key('train-${employee.id}')",
):
    if forbidden in team:
        errors.append(f"team courses still exposed: {forbidden}")

if errors:
    print("CURRENT UAT FIXPACK AUDIT: FAIL")
    for error in errors:
        print(f"- {error}")
    raise SystemExit(1)

print("CURRENT UAT FIXPACK AUDIT: PASS")
print(f"Validated {len(checks)} patched surfaces.")
