#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-$(pwd)}"
cd "$ROOT"

echo "== v12.1 UAT audit =="
python3 tools/audit_v12_1_uat_hotfix.py "$ROOT"

echo "== pub cache =="
flutter pub get --offline

echo "== format =="
dart format \
  lib/presentation/features/dashboard/founder_dashboard.dart \
  lib/presentation/features/onboarding/company_setup_dialog.dart \
  lib/presentation/shared/widgets/technology_selector_panel.dart \
  lib/presentation/features/products/create_product_screen.dart \
  lib/presentation/features/products/products_screen.dart \
  lib/presentation/features/operations/operations_screen.dart \
  lib/presentation/features/security/security_center_screen.dart \
  lib/presentation/features/products/product_detail_screen.dart \
  lib/presentation/features/products/product_workspace_screen.dart \
  lib/presentation/features/products/product_development_experience.dart \
  lib/domain/catalog/operations_catalog.dart \
  lib/application/localization/app_localizer.dart \
  lib/application/localization/v12_localization_lexicon.dart \
  lib/presentation/shared/widgets/development_stage_progress_rail.dart \
  test/presentation/v12_1_uat_hotfix_widget_test.dart \
  test/widget_test.dart

echo "== analyze =="
flutter analyze

echo "== focused v12.1 tests =="
flutter test test/presentation/v12_1_uat_hotfix_widget_test.dart --reporter expanded

echo "== legacy overview fixture regression =="
flutter test test/widget_test.dart --plain-name "overview shows every project from zero progress" --reporter expanded

echo "== v12 regressions =="
flutter test test/presentation/v12_founder_expansion_widget_test.dart --reporter expanded

echo "== full existing v12 verifier =="
bash tools/verify_v12_founder_expansion.sh

echo "== diff check =="
git diff --check

echo "✅ v12.1 UAT hotfix verification passed"
