#!/usr/bin/env python3
"""Static release audit for V16 global company/economy patch."""
from pathlib import Path
import sys

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
failures: list[str] = []


def require(relative: str, needle: str, label: str) -> None:
    path = ROOT / relative
    if not path.is_file():
        failures.append(f'{label}: missing {relative}')
        return
    if needle not in path.read_text(encoding='utf-8'):
        failures.append(f'{label}: missing {needle!r}')


def require_count(relative: str, needle: str, minimum: int, label: str) -> None:
    path = ROOT / relative
    if not path.is_file():
        failures.append(f'{label}: missing {relative}')
        return
    count = path.read_text(encoding='utf-8').count(needle)
    if count < minimum:
        failures.append(f'{label}: expected >= {minimum}, got {count}')

def forbid(relative: str, needle: str, label: str) -> None:
    path = ROOT / relative
    if not path.is_file():
        failures.append(f'{label}: missing {relative}')
        return
    if needle in path.read_text(encoding='utf-8'):
        failures.append(f'{label}: forbidden {needle!r}')

checks = (
    ('lib/domain/entities/game_state.dart', 'currentSnapshotVersion = 14', 'snapshot v14'),
    ('lib/domain/entities/v16_models.dart', 'class EmployeeTrainingAssignment', 'timed course persistence'),
    ('lib/domain/entities/v16_models.dart', 'class OwnedOfficeSite', 'owned offices model'),
    ('lib/domain/entities/v16_models.dart', 'class OwnedDataCenterSite', 'owned data centers model'),
    ('lib/domain/entities/v16_models.dart', 'class AnnualTaxRecord', 'annual tax model'),
    ('lib/domain/catalog/world_economy_catalog.dart', "id: 'san_francisco'", 'global city catalog'),
    ('lib/domain/catalog/world_economy_catalog.dart', 'marketAccessScore', 'city market factor'),
    ('lib/domain/catalog/world_economy_catalog.dart', 'networkScore / 84', 'city network factor'),
    ('lib/domain/catalog/world_economy_catalog.dart', 'containsCity(String id)', 'city id validation'),
    ('lib/domain/entities/operations_models.dart', 'final int durationDays', 'course duration'),
    ('lib/domain/catalog/operations_catalog.dart', 'durationDays: 3', 'course duration data'),
    ('lib/domain/commands/game_action.dart', 'class TrainEmployees', 'bulk training action'),
    ('lib/domain/commands/game_action.dart', 'class UpgradeEmployeesToGrade', 'target grade action'),
    ('lib/domain/commands/game_action.dart', 'class BuildOwnedOffice', 'office construction action'),
    ('lib/domain/commands/game_action.dart', 'class BuildOwnedDataCenter', 'data center construction action'),
    ('lib/domain/commands/game_action.dart', 'class FixAllProductBugs', 'bulk bug action'),
    ('lib/domain/commands/game_action.dart', 'final String? dataCenterSiteId', 'site-specific servers'),
    ('lib/domain/simulation/engine/game_engine.dart', '_advanceEmployeeDevelopment', 'employee progression pipeline'),
    ('lib/domain/simulation/engine/game_engine.dart', 'oldThreeDay', 'work skill growth cadence'),
    ('lib/domain/simulation/engine/game_engine.dart', 'program.durationDays * 1440', 'courses take game time'),
    ('lib/domain/simulation/engine/game_engine.dart', '_upgradeEmployeesToGrade', 'grade upgrade plan'),
    ('lib/domain/simulation/engine/game_engine.dart', '_advanceTaxLedger', 'annual tax ledger'),
    ('lib/domain/simulation/engine/game_engine.dart', "featureId: '__bug_all__'", 'bulk bug work queue'),
    ('lib/domain/simulation/engine/game_engine.dart', 'city.salaryMultiplier', 'city salary economy'),
    ('lib/domain/simulation/engine/game_engine.dart', 'investorAccessBonus', 'city investor access'),
    ('lib/domain/simulation/engine/game_engine.dart', 'containsCity(action.headquartersCityId)', 'HQ city validation'),
    ('lib/domain/simulation/engine/game_engine.dart', 'выбранный ЦОД не существует', 'invalid data center rejection'),
    ('lib/domain/simulation/engine/game_engine.dart', "usedRackUnitsAtDataCenter('') > room.rackUnits", 'rented server room isolated from owned DCs'),
    ('lib/domain/entities/game_state.dart', 'marketAccessMultiplier', 'city market access'),
    ('lib/domain/entities/game_state.dart', 'ownedOfficeMonthlyCost', 'owned office OPEX'),
    ('lib/domain/entities/game_state.dart', 'ownedDataCenterMonthlyCost', 'owned DC OPEX'),
    ('lib/domain/entities/game_state.dart', 'totalOfficeCapacity', 'multi-office capacity'),
    ('lib/domain/entities/game_state.dart', 'bestOwnedOfficeComfortIn(cityId)', 'city office productivity'),
    ('lib/domain/entities/game_state.dart', 'monthlyRegulatoryComplianceCost', 'regulation affects recurring economy'),
    ('lib/domain/entities/game_state.dart', 'office.monthlyRent * headquartersCity.rentMultiplier', 'HQ city affects rented office cost'),
    ('lib/presentation/features/infrastructure/infrastructure_screen.dart', "import '../../../domain/entities/models.dart';", 'server hardware UI type import'),
    ('lib/presentation/features/team/team_screen.dart', "import '../../../domain/entities/v12_game_state_extensions.dart';", 'founder salary extension import'),
    ('lib/presentation/features/team/team_screen.dart', "Key('team-development-controls')", 'bulk employee UI'),
    ('lib/presentation/features/team/team_screen.dart', "Key('team-select-all-visible')", 'select all employees UI'),
    ('lib/presentation/features/team/team_screen.dart', "Key('team-target-grade-selector')", 'simple grade UI'),
    ('lib/presentation/features/team/team_screen.dart', '_candidateEffectiveSalary', 'city-adjusted salary UI'),
    ('lib/presentation/features/infrastructure/infrastructure_screen.dart', "Key('build-owned-office')", 'office build UI'),
    ('lib/presentation/features/infrastructure/infrastructure_screen.dart', "Key('build-owned-datacenter')", 'data center build UI'),
    ('lib/presentation/features/products/product_workspace_screen.dart', "Key('workspace-monetization-guide')", 'monetization education'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'Когда брать: нужен быстрый рост или экосистема', 'monetization decision guidance'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'Правило выбора: сначала определите, за какую ценность пользователь платит', 'monetization unit economics guidance'),
    ('lib/presentation/features/products/product_workspace_screen.dart', "FixAllProductBugs(product.id)", 'bulk bug UI'),
    ('lib/presentation/features/onboarding/company_setup_dialog.dart', "Key('company-headquarters-city')", 'HQ selector'),
    ('lib/presentation/features/tutorial/founder_tutorial_dialog.dart', '3. Поймите монетизацию до релиза', 'monetization tutorial'),
    ('lib/presentation/features/finance/finance_screen.dart', "Key('annual-tax-summary')", 'visible tax reserve'),
    ('lib/presentation/features/finance/finance_screen.dart', 'Регуляторный OPEX / мес.', 'visible regulation OPEX'),
    ('lib/domain/entities/game_state_index.dart', 'trainingByEmployee', 'training lookup index'),
    ('lib/domain/entities/game_state_index.dart', 'ownedOfficeCapacityByCity', 'city office capacity cache'),
    ('lib/domain/entities/game_state_index.dart', 'onSiteEmployeeCountByCity', 'city occupancy cache'),
    ('lib/domain/entities/game_state_index.dart', 'bestOwnedOfficeComfortByCity', 'city office comfort cache'),
    ('lib/domain/entities/game_state_index.dart', '_competitorsByCategory', 'competitor ranking cache'),
    ('lib/presentation/features/infrastructure/infrastructure_screen.dart', 'initialValue: cityId', 'non-deprecated infrastructure city form fields'),
    ('lib/presentation/features/infrastructure/infrastructure_screen.dart', 'if (value != null) {', 'braced infrastructure form callbacks'),
    ('docs/DECISIONS.md', 'Не используется скрытый rubber-banding', 'transparent balance decision'),
    ('docs/DECISIONS.md', 'игровыми эффективными параметрами для баланса', 'gameplay tax disclaimer'),
    ('test/domain/v16_global_company_test.dart', 'v15 snapshot migrates to v16 geography and tax defaults', 'V15 to V16 migration regression'),
    ('test/domain/v16_global_company_test.dart', 'courses take game days', 'V16 domain regressions'),
    ('test/domain/game_engine_test.dart', 'final pending = state.employeeById(candidateId)!;', 'legacy training regression migrated'),
    ('test/domain/v16_global_company_test.dart', 'global city balance keeps start free and creates material tradeoffs', 'visible economy tradeoffs'),
    ('test/domain/v16_global_company_test.dart', 'balance pressure escalates from bootstrap to global scale', 'economy pressure bands'),
    ('test/domain/v16_global_company_test.dart', 'HQ rent and regulation create recurring city tradeoffs', 'recurring geography tradeoffs'),
    ('test/domain/v16_global_company_test.dart', 'owned data-center servers do not consume rented server-room capacity', 'multi-site room isolation'),
    ('test/presentation/v16_global_company_widget_test.dart', 'team screen exposes bulk development controls', 'V16 widget regressions'),
    ('test/presentation/v16_global_company_widget_test.dart', 'Scaffold(body: TeamScreen(controller: controller))', 'Team widget fixture provides Material'),
    ('test/presentation/v16_global_company_widget_test.dart', '_scrollListUntilFound', 'Team bulk controls lazy-scroll fixture'),
    ('test/presentation/v14_publisher_uat_polish_widget_test.dart', 'final monetizationControls = find.byKey(', 'V14 monetization lazy-child finder'),
    ('test/presentation/v14_publisher_uat_polish_widget_test.dart', 'target: monetizationControls', 'V14 monetization lazy-scroll regression'),
)
for relative, needle, label in checks:
    require(relative, needle, label)

require_count('lib/domain/catalog/world_economy_catalog.dart', 'WorldCityOption(', 12, 'twelve strategic cities')

require_count('lib/presentation/features/infrastructure/infrastructure_screen.dart', 'initialValue:', 8, 'V16 infrastructure form fields use initialValue')
forbid('lib/domain/entities/game_state_index.dart', 'static Map<String, V> _firstValueBy<T, V>', 'unused first-value index helper removed')
forbid('test/presentation/v16_global_company_widget_test.dart', "import 'package:founder_os/domain/entities/models.dart';", 'unused V16 widget-test import removed')

if failures:
    print('V16 GLOBAL COMPANY AUDIT: FAIL', file=sys.stderr)
    for failure in failures:
        print(f'- {failure}', file=sys.stderr)
    raise SystemExit(1)

print('V16 GLOBAL COMPANY AUDIT: PASS')
print(f'Validated {len(checks) + 4} implementation invariants and 2 focused V16 test files.')
