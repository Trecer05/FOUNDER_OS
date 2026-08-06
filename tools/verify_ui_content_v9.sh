#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$HOME/Developer/founder_os}"
cd "$ROOT"

fail() { echo "❌ $*" >&2; exit 1; }
[[ "$(git branch --show-current)" == "main" ]] || fail "Текущая ветка не main"
[[ -f pubspec.yaml && -f lib/domain/entities/game_state.dart ]] || fail "Это не FOUNDER.OS"
grep -q 'const int currentSnapshotVersion = 9;' lib/domain/entities/game_state.dart || fail "Snapshot v9 не применён"
grep -q "selectedHostingPlanId: 'shared_launch'" lib/domain/entities/game_state.dart || fail "Default hosting не применён"

python3 - <<'PYCONTENT'
import json
from pathlib import Path
p = Path('assets/data/content_catalog_v9.json')
data = json.loads(p.read_text(encoding='utf-8'))
assert data['schemaVersion'] == 9
assert data['totals']['v9'] > data['totals']['v8'] * 7
all_ids = []
aliases = set()
field_aliases = {
    'roleId': 'role',
    'languageId': 'language',
    'frameworkId': 'framework',
    'technologyId': 'technology',
    'productTypeId': 'product_type',
    'providerId': 'provider',
}
for category, items in data['categories'].items():
    local_ids = set()
    for item in items:
        assert item['id'] and item['name'].strip() and item['tooltip'].strip()
        assert 'уникальная игровая конфигурация' not in item['description'].lower()
        assert 'Преимущество 1' not in item['strengths']
        assert isinstance(item['requirements'], list)
        assert isinstance(item['references'], list)
        assert item['cost'] >= 0 and 0 <= item['load'] <= 100
        assert item['id'] not in local_ids, f'duplicate {category}:{item["id"]}'
        local_ids.add(item['id'])
        all_ids.append(item['id'])
        aliases.add(item['id'])
        for field, prefix in field_aliases.items():
            if field in item:
                aliases.add(f"{prefix}:{item[field]}")
assert len(all_ids) == len(set(all_ids)), 'duplicate global IDs'
for category, items in data['categories'].items():
    for item in items:
        for reference in item['references']:
            assert reference in aliases, f'broken reference {category}:{item["id"]} -> {reference}'
print(f"content: v8={data['totals']['v8']} v9={data['totals']['v9']} growth={data['growthFactor']}x references=ok")
PYCONTENT

echo '== dart format =='
dart format lib test

echo '== flutter analyze =='
flutter analyze

echo '== focused domain tests =='
flutter test test/domain/ui_content_v9_test.dart

echo '== focused widget tests =='
flutter test test/presentation/ui_content_v9_widget_test.dart

echo '== all domain tests =='
flutter test test/domain

echo '== all widget/presentation tests =='
if [[ -d test/presentation ]]; then flutter test test/presentation; fi

echo '== full flutter test =='
flutter test

echo '== git diff check =='
git diff --check

echo '== iOS simulator debug build =='
flutter build ios --simulator --debug

echo '✅ FOUNDER.OS v9 verification passed'
