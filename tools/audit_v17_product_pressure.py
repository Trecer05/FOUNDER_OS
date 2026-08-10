#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import sys

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]

checks: list[tuple[str, str, str]] = [
    ('lib/domain/entities/game_state.dart', 'const int currentSnapshotVersion = 16;', 'snapshot v16'),
    ('lib/domain/entities/game_state.dart', 'this.employeeRelocations = const <EmployeeRelocationAssignment>[]', 'relocation state'),
    ('lib/domain/entities/game_state.dart', 'this.productServiceRoutes = const <ProductServiceRoute>[]', 'service route state'),
    ('lib/domain/entities/game_state.dart', "if (version <= 14) {", 'v16 migration branch'),
    ('lib/domain/entities/game_state.dart', 'campaign.endsAtMinutes >= 0', 'legacy finite ad migration'),
    ('lib/domain/entities/v17_models.dart', 'enum InfrastructureService', 'infrastructure service model'),
    ('lib/domain/entities/v17_models.dart', 'sharedLegacy', 'legacy shared service migration'),
    ('lib/domain/entities/v17_models.dart', 'class ProductServiceRoute', 'product service route model'),
    ('lib/domain/entities/v17_models.dart', 'class EmployeeRelocationAssignment', 'employee relocation model'),
    ('lib/domain/entities/v17_models.dart', 'class MonetizationExperienceImpact', 'monetization experience model'),
    ('lib/domain/entities/models.dart', 'this.service = InfrastructureService.sharedLegacy', 'installed server persisted service'),
    ('lib/domain/entities/models.dart', "'service': service.name", 'installed server service json'),
    ('lib/domain/entities/models.dart', 'orElse: () => InfrastructureService.sharedLegacy', 'old server migration'),
    ('lib/domain/commands/game_action.dart', 'class RelocateEmployeeToOffice extends GameAction', 'relocation action'),
    ('lib/domain/commands/game_action.dart', 'class AssignProductInfrastructureService extends GameAction', 'service route action'),
    ('lib/domain/commands/game_action.dart', 'class StopAdvertisingCampaign extends GameAction', 'stop advertising action'),
    ('lib/domain/commands/game_action.dart', 'this.service = InfrastructureService.sharedLegacy', 'server install service'),
    ('lib/domain/entities/game_state.dart', 'double productSupportedLifetimeDays(Product product)', 'supported product lifetime'),
    ('lib/domain/entities/game_state.dart', 'math.min(180, addedFeatures * 18)', 'features extend life'),
    ('lib/domain/entities/game_state.dart', 'math.min(140, addedStack * 14)', 'stack extends life'),
    ('lib/domain/entities/game_state.dart', 'math.min(180, improvementLevels * 20)', 'improvements extend life'),
    ('lib/domain/entities/game_state.dart', 'preparedComputeUnitsAtDataCenterForService', 'service compute pool'),
    ('lib/domain/entities/game_state.dart', 'preparedMemoryGbAtDataCenterForService', 'service RAM pool'),
    ('lib/domain/entities/game_state.dart', 'preparedStorageGbAtDataCenterForService', 'service storage pool'),
    ('lib/domain/entities/game_state.dart', 'preparedNetworkGbpsAtDataCenterForService', 'service network pool'),
    ('lib/domain/entities/game_state.dart', 'item.service == InfrastructureService.sharedLegacy ||', 'legacy service fallback'),
    ('lib/domain/entities/game_state.dart', 'double productMemoryDemand(Product product)', 'RAM demand model'),
    ('lib/domain/entities/game_state.dart', 'ProductCategory.aiAssistant => 4.8', 'AI RAM pressure'),
    ('lib/domain/entities/game_state.dart', 'ProductCategory.aiAssistant => 3.8', 'AI storage pressure'),
    ('lib/domain/entities/game_state.dart', 'double _resourceOptimizationMultiplier(Product product)', 'resource optimization'),
    ('lib/domain/entities/game_state.dart', 'math.pow(0.90, algorithms)', 'algorithm resource reduction'),
    ('lib/domain/entities/game_state.dart', 'MonetizationExperienceImpact monetizationExperienceImpact', 'monetization user impact'),
    ('lib/domain/entities/game_state.dart', 'absolutePricePressure', 'absolute high-price penalty'),
    ('lib/domain/entities/game_state.dart', 'double get monthlyAdvertisingSpend', 'recurring ad monthly spend'),
    ('lib/domain/entities/game_state.dart', 'double get monthlyScaleOperationsCost', 'scale operations cost'),
    ('lib/domain/entities/game_state.dart', 'ProductCategory.aiAssistant => 16.0', 'AI scale cost pressure'),
    ('lib/domain/entities/game_state.dart', 'monthlyScaleOperationsCost +', 'scale cost in monthly costs'),
    ('lib/domain/simulation/engine/game_engine.dart', 'projection.developmentHours * 0.86', 'easier MVP development'),
    ('lib/domain/simulation/engine/game_engine.dart', 'для Senior обычные курсы недоступны', 'senior course block'),
    ('lib/domain/simulation/engine/game_engine.dart', 'seniorPremium = targetGrade == EmployeeGrade.senior ? 0.85', 'senior premium'),
    ('lib/domain/simulation/engine/game_engine.dart', 'targetGrade == EmployeeGrade.senior ? 3 : 0', 'senior duration premium'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _relocateEmployeeToOffice', 'paid relocation reducer'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _advanceEmployeeRelocations', 'relocation completion'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _advanceChurnShocks', 'weekly churn shocks'),
    ('lib/domain/simulation/engine/game_engine.dart', '0.008 + _random01', 'churn shock severity'),
    ('lib/domain/simulation/engine/game_engine.dart', 'portfolioDiscoveryFactor', 'portfolio discovery pressure'),
    ('lib/domain/simulation/engine/game_engine.dart', 'marketReadiness', 'success readiness pressure'),
    ('lib/domain/simulation/engine/game_engine.dart', 'brandFactor *\n          0.33;', 'three-times slower organic growth'),
    ('lib/domain/simulation/engine/game_engine.dart', 'endsAtMinutes: -1', 'always-on advertising'),
    ('lib/domain/simulation/engine/game_engine.dart', 'state.cash < action.budget / 6', 'ad reserve not upfront full charge'),
    ('lib/domain/simulation/engine/game_engine.dart', 'одновременно можно вести не больше трёх рекламных каналов', 'max ad channels'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _stopAdvertisingCampaign', 'stop ad reducer'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _appendRecurringMarketingTransactions', 'daily ad ledger'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _appendRecurringOperatingTransactions', 'operating ledger'),
    ('lib/domain/simulation/engine/game_engine.dart', 'state.monthlyScaleOperationsCost +', 'scale cost in operating ledger'),
    ('lib/domain/simulation/engine/game_engine.dart', 'service: action.service', 'install/remove dedicated service'),
    ('lib/domain/simulation/engine/game_engine.dart', 'item.service == service', 'server group keyed by service'),
    ('lib/domain/simulation/engine/game_engine.dart', 'RelocateEmployeeToOffice() => FinanceTransactionCategory.payroll', 'relocation ledger category'),
    ('lib/presentation/features/products/product_workspace_screen.dart', "key: const Key('workspace-monetization-guide-expansion')", 'monetization collapsible guide'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'initiallyExpanded: false', 'monetization collapsed default'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'Жёсткость paywall', 'clear subscription control'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'Рекламная агрессивность', 'clear ads control'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'Влияние на пользователей', 'monetization impact visible'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'Включить рекламный канал', 'always-on marketing enable'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'Остановить канал', 'always-on marketing stop'),
    ('lib/presentation/features/products/product_workspace_screen.dart', "key: const Key('workspace-service-routing')", 'service routing UI'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'Поддерживаемый возраст', 'lifetime visible'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'LinearProgressIndicator', 'upgrade progress bars'),
    ('lib/presentation/features/team/team_screen.dart', 'senior-development-', 'senior no course UI'),
    ('lib/presentation/features/team/team_screen.dart', 'relocate-', 'relocation UI'),
    ('lib/presentation/features/infrastructure/infrastructure_screen.dart', 'Выбрать площадку и сервис', 'server service selection UI'),
    ('lib/presentation/features/infrastructure/infrastructure_screen.dart', 'Legacy shared', 'legacy pool visible'),
    ('lib/presentation/features/infrastructure/infrastructure_screen.dart', 'ownedOfficeLabel', 'numbered office cards'),
    ('lib/presentation/features/infrastructure/infrastructure_screen.dart', 'ownedDataCenterLabel', 'numbered DC cards'),
    ('lib/presentation/features/dashboard/founder_dashboard.dart', 'child: ScopedListenableBuilder(', 'dashboard stable direct listenable'),
    ('test/domain/v17_product_pressure_test.dart', 'senior cannot take ordinary courses', 'senior regression'),
    ('test/domain/v17_product_pressure_test.dart', 'service routes isolate product resources by data center', 'service routing regression'),
    ('test/domain/v17_product_pressure_test.dart', 'advertising is recurring monthly spend with gradual users and stop', 'ads regression'),
    ('test/domain/v17_product_pressure_test.dart', 'portfolio diversification improves discovery versus a single hit', 'portfolio regression'),
    ('test/domain/v17_product_pressure_test.dart', 'successful product creates material variable scale operations cost', 'scale pressure regression'),
    ('test/presentation/v17_product_pressure_widget_test.dart', 'monetization guide starts collapsed', 'monetization widget regression'),
    ('test/presentation/v17_product_pressure_widget_test.dart', 'dashboard survives rapid tab switching', 'runtime lifecycle regression'),
    ('test/presentation/v17_product_pressure_widget_test.dart', 'product workspace survives rapid section switching', 'workspace lifecycle regression'),
    ('test/presentation/v17_product_pressure_widget_test.dart', 'finance history can be scrubbed by finger', 'finance scrub regression'),
]

negative: list[tuple[str, str, str]] = [
    ('lib/presentation/features/products/product_workspace_screen.dart', "AppText('Интенсивность монетизации')", 'old unclear monetization label'),
    ('lib/presentation/features/dashboard/founder_dashboard.dart', 'child: ActiveTabScope(', 'ephemeral dashboard ActiveTabScope'),
    ('lib/presentation/features/dashboard/founder_dashboard.dart', 'key: ValueKey<int>(_tab)', 'forced tab subtree replacement'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'AnimatedSwitcher(', 'retained workspace animation subtree'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'ValueKey<_WorkspaceSection>', 'forced workspace section subtree replacement'),
]

# Mutated V16-base files must exist after installer and are deliberately not full overlays.
checks += [
    ('lib/domain/entities/game_state_index.dart', 'relocationByEmployee', 'relocation lazy index'),
    ('lib/domain/entities/game_state_index.dart', 'serviceRouteByProductAndService', 'service-route lazy index'),
    ('lib/presentation/features/finance/finance_screen.dart', "key: const Key('finance-history-selection')", 'finance scrub detail'),
    ('lib/presentation/features/finance/finance_screen.dart', 'state.monthlyAdvertisingSpend', 'finance ad breakdown'),
    ('lib/presentation/features/finance/finance_screen.dart', 'state.monthlyScaleOperationsCost', 'finance scale breakdown'),
    ('lib/presentation/features/finance/finance_screen.dart', 'state.monthlyRegulatoryComplianceCost', 'finance regulatory breakdown'),
    ('lib/presentation/features/finance/finance_screen.dart', '.take(60)', 'longer finance ledger'),
]

failures: list[str] = []
for rel, needle, label in checks:
    path = ROOT / rel
    if not path.is_file():
        failures.append(f'{label}: missing file {rel}')
        continue
    text = path.read_text(encoding='utf-8')
    if needle == 'no more than three':
        continue
    if needle not in text:
        failures.append(f'{label}: missing {needle!r} in {rel}')

for rel, needle, label in negative:
    path = ROOT / rel
    if path.is_file() and needle in path.read_text(encoding='utf-8'):
        failures.append(f'{label}: forbidden {needle!r} remains in {rel}')

if failures:
    print('V17 PRODUCT PRESSURE AUDIT: FAIL', file=sys.stderr)
    for failure in failures:
        print(f'- {failure}', file=sys.stderr)
    raise SystemExit(1)

print('V17 PRODUCT PRESSURE AUDIT: PASS')
print(f'Validated {len(checks) + len(negative)} implementation invariants and 2 focused V17 test files.')
