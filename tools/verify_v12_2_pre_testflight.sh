#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(pwd)}"
cd "$ROOT"

echo "== v12.2 pre-TestFlight audit =="
python3 tools/audit_v12_2_pre_testflight.py "$ROOT"

echo "== pub cache =="
flutter pub get --offline

echo "== format v12.2 =="
dart format \
  lib/application/controllers/game_controller.dart \
  lib/domain/entities/game_state.dart \
  lib/domain/entities/v12_game_state_extensions.dart \
  lib/domain/simulation/engine/game_engine.dart \
  lib/presentation/features/dashboard/founder_dashboard.dart \
  lib/presentation/features/products/create_product_screen.dart \
  lib/presentation/features/products/products_screen.dart \
  lib/presentation/features/products/product_workspace_screen.dart \
  lib/presentation/features/products/product_detail_screen.dart \
  lib/presentation/features/products/product_development_experience.dart \
  lib/presentation/features/products/project_challenge_dialog.dart \
  lib/presentation/features/operations/operations_screen.dart \
  lib/presentation/features/contracts/contracts_screen.dart \
  lib/presentation/features/contracts/contract_detail_screen.dart \
  lib/presentation/shared/widgets/development_stage_progress_rail.dart \
  test/domain/v12_founder_expansion_test.dart \
  test/domain/game_state_index_test.dart \
  test/domain/game_engine_test.dart \
  test/domain/ux_economy_v10_test.dart \
  test/domain/v12_2_pre_testflight_test.dart \
  test/presentation/v12_2_pre_testflight_widget_test.dart \
  test/presentation/management_refactor_widget_test.dart \
  test/presentation/v12_founder_expansion_widget_test.dart \
  test/widget_test.dart

echo "== analyze =="
flutter analyze

echo "== focused v12.2 domain tests =="
flutter test test/domain/v12_2_pre_testflight_test.dart --reporter expanded

echo "== focused v12.2 widget tests =="
flutter test test/presentation/v12_2_pre_testflight_widget_test.dart --reporter expanded

echo "== updated project challenge regression =="
flutter test \
  test/domain/v12_founder_expansion_test.dart \
  --plain-name "development challenge is rewarded at most once per project" \
  --reporter expanded

echo "== legacy contract viewport regression =="
flutter test \
  test/widget_test.dart \
  --plain-name "contracts screen accepts a simple client order" \
  --reporter expanded

echo "== full verified v12.1 + v12 regression/build gate =="
bash tools/verify_v12_1_uat_hotfix.sh "$ROOT"

echo "== final diff check =="
git diff --check

echo "✅ v12.2 pre-TestFlight verification passed"
