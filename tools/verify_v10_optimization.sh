#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export GIT_PAGER=cat
export PAGER=cat

echo "== v10_optimization static gate =="
python3 - <<'PY'
from pathlib import Path

required = {
    "lib/application/performance/native_performance_bridge.dart": "founder_os/native_performance",
    "lib/domain/simulation/product_projection_cache.dart": "LinkedHashMap",
    "lib/domain/entities/game_state_index.dart": "Expando<_GameStateIndex>",
    "lib/application/localization/app_text.dart": "class AppText",
    "lib/application/localization/app_localizer.dart": "class AppLocalizer",
    "lib/application/localization/glossary_english.dart": "glossaryEnglish",
    "lib/presentation/shared/widgets/scoped_listenable_builder.dart": "class ScopedListenableBuilder",
    "ios/Runner/AppDelegate.swift": "swift_atomic_file",
    "android/app/src/main/kotlin/com/example/founder_os/MainActivity.kt": "kotlin_atomic_file",
}
for relative, marker in required.items():
    path = Path(relative)
    if not path.is_file() or marker not in path.read_text(encoding="utf-8"):
        raise SystemExit(f"static gate failed: {relative} / {marker}")

controller = Path("lib/application/controllers/game_controller.dart").read_text(encoding="utf-8")
if "_pendingSnapshot" not in controller or "_consumeElapsedTime" not in controller:
    raise SystemExit("static gate failed: optimized controller is not installed")

engine = Path("lib/domain/simulation/engine/game_engine.dart").read_text(encoding="utf-8")
if "ProductProjectionCache.estimate" not in engine:
    raise SystemExit("static gate failed: simulation projection cache is not used")

bar = Path("lib/presentation/shared/widgets/global_time_control_bar.dart").read_text(encoding="utf-8")
if "BackdropFilter" in bar:
    raise SystemExit("static gate failed: expensive backdrop blur remains in global controls")

dashboard = Path(
    "lib/presentation/features/dashboard/founder_dashboard.dart"
).read_text(encoding="utf-8")
if "ActiveTabScope" not in dashboard:
    raise SystemExit("static gate failed: retained tabs are not notification-gated")

snapshot_store = Path(
    "lib/persistence/storage/game_snapshot_store.dart"
).read_text(encoding="utf-8")
if "Isolate.run" not in snapshot_store or "saveSnapshot" not in snapshot_store:
    raise SystemExit("static gate failed: optimized snapshot pipeline is incomplete")

print("v10_optimization static gate: ok")
PY

echo "== localization/native audit =="
python3 tools/audit_localization_v10_optimization.py

echo "== dart format =="
dart format lib test

echo "== flutter analyze =="
flutter analyze

echo "== focused optimization tests =="
flutter test test/domain/product_projection_cache_test.dart
flutter test test/domain/game_state_index_test.dart
flutter test test/application/native_performance_bridge_test.dart
flutter test test/application/game_snapshot_store_optimization_test.dart
flutter test test/application/game_controller_optimization_test.dart
flutter test test/application/localization_v10_optimization_test.dart
flutter test test/presentation/v10_optimization_widget_test.dart
flutter test test/presentation/scoped_listenable_builder_test.dart

echo "== all domain tests =="
flutter test test/domain

echo "== all application and presentation tests =="
flutter test test/application test/presentation

echo "== full flutter test =="
flutter test

echo "== git diff check =="
git diff --check

echo "== iOS simulator debug build =="
flutter build ios --simulator --debug

echo "== Android debug build =="
flutter build apk --debug

echo "✅ FOUNDER.OS v10_optimization verification passed"
