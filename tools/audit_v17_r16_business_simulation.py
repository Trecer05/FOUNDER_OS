#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
checks = [
    ('lib/domain/entities/game_state.dart', 'List<String> researchPrerequisiteKeys(', 'R&D prerequisites'),
    ('lib/domain/entities/game_state.dart', 'double businessLoanApprovalChance(double requestedAmount)', 'loan probability'),
    ('lib/domain/entities/game_state.dart', 'double productPaidConversionRate(Product product)', 'paid conversion'),
    ('lib/domain/entities/game_state.dart', 'double productCac(Product product)', 'CAC'),
    ('lib/domain/commands/game_action.dart', 'const RequestBusinessLoan({this.amount = 50000});', 'requested loan amount'),
    ('lib/domain/simulation/engine/game_engine.dart', 'final monthlyInterested =', 'funnel interest'),
    ('lib/domain/simulation/engine/game_engine.dart', 'final referralInterest =', 'referrals'),
    ('lib/domain/simulation/engine/game_engine.dart', 'final startUsingRate =', 'start using conversion'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _appendRunwayWarning(GameState state)', 'runway warning'),
    ('lib/domain/simulation/engine/game_engine.dart', 'double _securityIncidentLocalizationCost(', 'security price'),
    ('lib/presentation/features/research/research_screen.dart', "'Сначала предыдущий уровень'", 'R&D tree UI'),
    ('lib/presentation/features/products/product_workspace_screen.dart', "key: const Key('product-business-funnel')", 'funnel UI'),
    ('lib/presentation/features/products/product_detail_screen.dart', "label: 'Начали пользоваться'", 'product detail activation rename'),
    ('lib/presentation/features/finance/finance_screen.dart', 'Future<void> _showBusinessLoanRequest(BuildContext context)', 'loan dialog'),
    ('test/domain/v17_r16_business_simulation_test.dart', 'larger loan relative to company valuation has lower approval chance', 'loan regression'),
]
failures = []
for rel, needle, label in checks:
    path = ROOT / rel
    if not path.is_file() or needle not in path.read_text(encoding='utf-8'):
        failures.append(f'{label}: {rel} missing {needle!r}')

engine = (ROOT / 'lib/domain/simulation/engine/game_engine.dart').read_text(encoding='utf-8')
start = engine.find('GameState _advanceAdvertisingCampaigns')
end = engine.find('GameState _appendRecurringMarketingTransactions', start)
block = engine[start:end]
if start < 0 or end < 0:
    failures.append('advertising function boundaries missing')
elif re.search(r'\busers\s*:', block) or re.search(r'\bmau\s*:', block) or re.search(r'\bdau\s*:', block):
    failures.append('advertising still mutates users/MAU/DAU directly')

churn_start = engine.find('GameState _advanceChurnShocks')
churn_end = engine.find('GameState _advanceLoanAndLiquidity', churn_start)
churn_block = engine[churn_start:churn_end]
if 'monetizationExperienceImpact' in churn_block:
    failures.append('weekly churn still uses direct monetization coefficient deltas')

market_start = engine.find('_MarketOutcome _marketOutcome')
market_end = engine.find('double _roleQualityForProduct', market_start)
market_block = engine[market_start:market_end]
if market_start < 0 or market_end < 0:
    failures.append('market funnel boundaries missing')
elif 'monetizationExperienceImpact' in market_block:
    failures.append('market funnel still uses direct monetization coefficient deltas')

workspace = (ROOT / 'lib/presentation/features/products/product_workspace_screen.dart').read_text(encoding='utf-8')
if re.search(r"['\"][^'\"]*Активаци", workspace):
    failures.append('workspace still exposes old activation label')

catalog = (ROOT / 'lib/domain/catalog/v17_endgame_catalog.dart').read_text(encoding='utf-8')
expected = {
    'premium_workstations': ('120000', '8000'),
    'health_insurance': ('15000', '18000'),
    'office_taxi': ('5000', '12000'),
    'meals_and_coffee': ('20000', '22000'),
    'education_budget': ('25000', '28000'),
    'family_support': ('20000', '35000'),
}
for perk_id, (upfront, monthly) in expected.items():
    pattern = rf"id:\s*'{perk_id}'.*?upfrontCost:\s*{upfront},\s*monthlyCost:\s*{monthly}"
    if not re.search(pattern, catalog, flags=re.DOTALL):
        failures.append(f'perk {perk_id} price mismatch')

if failures:
    print('R16 BUSINESS SIMULATION AUDIT: FAIL')
    for failure in failures:
        print(' -', failure)
    raise SystemExit(1)
print(f'R16 BUSINESS SIMULATION AUDIT: PASS ({len(checks)} structural checks + semantic guards)')
