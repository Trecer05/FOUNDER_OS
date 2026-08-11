#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]

checks = [
    ('lib/domain/entities/game_state.dart', 'const int currentSnapshotVersion = 16;', 'snapshot v16'),
    ('lib/domain/catalog/world_economy_catalog.dart', "id: 'limassol'", 'Limassol city'),
    ('lib/domain/catalog/world_economy_catalog.dart', "countryRu: 'Кипр'", 'Cyprus geography'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "id: 'premium_workstations'", 'workstation perk'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "id: 'health_insurance'", 'health perk'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "id: 'office_taxi'", 'taxi perk'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "id: 'education_budget'", 'education perk'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "id: 'legend_architect'", 'architect legend'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', 'requiredReleasedProducts: 3', 'legend released-product requirement'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', 'requiredValuation: 3000000000', 'legend valuation requirement'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "requiredOfficeCityId: 'limassol'", 'legend Cyprus office requirement'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', 'requiredOfficeQuality: FacilityQuality.premium', 'legend premium office requirement'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "id: 'global_tech_expo'", 'industry event'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "id: 'world_os'", 'AURA OS project'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "id: 'free_ai'", 'free AI project'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "id: 'planet_compute'", 'planet compute project'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "id: 'os_sdk'", 'OS SDK upgrade'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "id: 'os_store'", 'OS App Store upgrade'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', "id: 'os_ai'", 'OS System AI upgrade'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', 'phaseCosts: <double>[12000000000, 22000000000, 38000000000, 55000000000]', 'OS huge phase costs'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', 'phaseCosts: <double>[18000000000, 32000000000, 52000000000, 78000000000]', 'AI huge phase costs'),
    ('lib/domain/catalog/v17_endgame_catalog.dart', 'phaseCosts: <double>[25000000000, 45000000000, 80000000000, 125000000000]', 'grid huge phase costs'),
    ('lib/domain/entities/v17_models.dart', 'class CompanyResearchProject', 'research model'),
    ('lib/domain/entities/v17_models.dart', 'class LegendMarketOffer', 'legend offer model'),
    ('lib/domain/entities/v17_models.dart', 'class HiredLegendBonus', 'legend product bonus model'),
    ('lib/domain/entities/v17_models.dart', 'class PendingEmployeeDeparture', 'departure model'),
    ('lib/domain/entities/v17_models.dart', 'class IndustryEventOpportunity', 'event opportunity model'),
    ('lib/domain/entities/v17_models.dart', 'class CompanyNotification', 'notification model'),
    ('lib/domain/entities/v17_models.dart', 'class WorldProjectProgress', 'world project progress model'),
    ('lib/domain/entities/v17_models.dart', 'enum EcosystemDoctrine', 'power-freedom doctrine'),
    ('lib/domain/entities/v17_models.dart', 'enum PostGamePath', 'postgame path model'),
    ('lib/domain/commands/game_action.dart', 'class StartCompanyResearch extends GameAction', 'research action'),
    ('lib/domain/commands/game_action.dart', 'class ToggleCompanyPerk extends GameAction', 'perk action'),
    ('lib/domain/commands/game_action.dart', 'class HireMarketLegend extends GameAction', 'legend hire action'),
    ('lib/domain/commands/game_action.dart', 'class CounterOfferEmployee extends GameAction', 'counteroffer action'),
    ('lib/domain/commands/game_action.dart', 'class JoinIndustryEvent extends GameAction', 'event action'),
    ('lib/domain/commands/game_action.dart', 'class MarkAllCompanyNotificationsRead extends GameAction', 'notification action'),
    ('lib/domain/commands/game_action.dart', 'class FundWorldProjectPhase extends GameAction', 'world phase action'),
    ('lib/domain/commands/game_action.dart', 'class StartWorldProjectUpgrade extends GameAction', 'world upgrade action'),
    ('lib/domain/commands/game_action.dart', 'class SetEcosystemDoctrine extends GameAction', 'doctrine action'),
    ('lib/domain/commands/game_action.dart', 'class FundPhilanthropy extends GameAction', 'philanthropy action'),
    ('lib/domain/commands/game_action.dart', 'class ChoosePostGamePath extends GameAction', 'postgame action'),
    ('lib/domain/entities/game_state.dart', 'this.activeResearchProjects = const <CompanyResearchProject>[]', 'research state'),
    ('lib/domain/entities/game_state.dart', 'this.completedResearchKeys = const <String>[]', 'completed research state'),
    ('lib/domain/entities/game_state.dart', 'this.enabledCompanyPerkIds = const <String>[]', 'perk state'),
    ('lib/domain/entities/game_state.dart', 'this.legendMarketOffers = const <LegendMarketOffer>[]', 'legend state'),
    ('lib/domain/entities/game_state.dart', 'this.pendingEmployeeDepartures = const <PendingEmployeeDeparture>[]', 'departure state'),
    ('lib/domain/entities/game_state.dart', 'this.companyFans = 0', 'fan state'),
    ('lib/domain/entities/game_state.dart', 'this.brandReputation = 10', 'brand state'),
    ('lib/domain/entities/game_state.dart', 'this.companyNotifications = const <CompanyNotification>[]', 'notification state'),
    ('lib/domain/entities/game_state.dart', 'this.worldProjects = const <WorldProjectProgress>[]', 'world project state'),
    ('lib/domain/entities/game_state.dart', 'double get monthlyCompanyPerkCost', 'perk OPEX'),
    ('lib/domain/entities/game_state.dart', 'double get monthlyWorldProjectOperatingCost', 'world project OPEX'),
    ('lib/domain/entities/game_state.dart', 'double get brandDemandMultiplier', 'fans/reputation demand'),
    ('lib/domain/entities/game_state.dart', 'int get requiredReleasedBlueprintsForLegacy => 0;', 'old product-count victory removed'),
    ('lib/domain/entities/game_state.dart', 'bool get founderLegacyCompleted =>', 'world-project victory'),
    ('lib/domain/entities/game_state.dart', 'V17EndgameCatalog.worldProjects.every', 'all three projects required'),
    ('lib/domain/entities/game_state.dart', 'String researchKey(ResearchTargetKind kind, String targetId)', 'research key helper'),
    ('lib/domain/entities/game_state.dart', 'bool researchCompleted(ResearchTargetKind kind, String targetId)', 'research completion helper'),
    ('lib/domain/entities/game_state.dart', 'double get companyLegacyScore', 'legacy score'),
    ('lib/domain/simulation/engine/game_engine.dart', 'StartCompanyResearch() => _startCompanyResearch', 'research reducer routing'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _advanceCompanyResearch', 'timed research'),
    ('lib/domain/simulation/engine/game_engine.dart', "id: 'research_start_${key}_${state.simulationMinutes}'", 'research notification id interpolation'),
    ('lib/domain/simulation/engine/game_engine.dart', 'Сначала исследуйте функцию в R&D:', 'feature R&D gate'),
    ('lib/domain/simulation/engine/game_engine.dart', 'Сначала исследуйте технологию в R&D:', 'technology R&D gate'),
    ('lib/domain/simulation/engine/game_engine.dart', '_DailyResult _advanceEmployeeRetention', 'employee retention simulation'),
    ('lib/domain/simulation/engine/game_engine.dart', 'PendingEmployeeDeparture(', 'resignation intent'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _counterOfferEmployee', 'counteroffer reducer'),
    ('lib/domain/simulation/engine/game_engine.dart', '_DailyResult _advanceLegendMarket', 'rare legend market'),
    ('lib/domain/simulation/engine/game_engine.dart', '>= 0.025', 'rare legend probability'),
    ('lib/domain/simulation/engine/game_engine.dart', 'skill: 100', 'legend skill 100'),
    ('lib/domain/simulation/engine/game_engine.dart', 'speed: 100', 'legend speed 100'),
    ('lib/domain/simulation/engine/game_engine.dart', 'quality: 100', 'legend quality 100'),
    ('lib/domain/simulation/engine/game_engine.dart', 'autonomy: 100', 'legend autonomy 100'),
    ('lib/domain/simulation/engine/game_engine.dart', 'communication: 100', 'legend communication 100'),
    ('lib/domain/simulation/engine/game_engine.dart', 'reliability: 100', 'legend reliability 100'),
    ('lib/domain/simulation/engine/game_engine.dart', '.take(3).toList(growable: false)', 'event max three showcase slots'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _advanceBookedIndustryEvents', 'event completion'),
    ('lib/domain/simulation/engine/game_engine.dart', 'companyFans: next.companyFans + definition.baseFanGain', 'event fan gain'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _advanceCompanyFansAndReputation', 'organic fans/reputation'),
    ('lib/domain/simulation/engine/game_engine.dart', 'CompanyNotificationKind.tax', 'tax notification'),
    ('lib/domain/simulation/engine/game_engine.dart', 'CompanyNotificationKind.investor', 'investor notification'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _fundWorldProjectPhase', 'world project funding'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _startWorldProjectUpgrade', 'world upgrade funding'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _fundPhilanthropy', 'philanthropy reducer'),
    ('lib/domain/simulation/engine/game_engine.dart', 'GameState _choosePostGamePath', 'postgame reducer'),
    ('lib/domain/simulation/engine/game_engine.dart', 'if (!state.founderLegacyCompleted) {', 'postgame locked before victory'),
    ('lib/presentation/features/dashboard/founder_dashboard.dart', "label: trContext(context, 'События')", 'events navigation tab'),
    ('lib/presentation/features/dashboard/founder_dashboard.dart', 'unreadCompanyNotificationCount', 'notification badge'),
    ('lib/presentation/features/company/company_hub_screen.dart', "key: const Key('company-notifications')", 'notification hub'),
    ('lib/presentation/features/company/company_hub_screen.dart', 'Забронировать', 'event booking UI'),
    ('lib/presentation/features/company/company_hub_screen.dart', 'worldProjectCompletionProgress', 'world project UI'),
    ('lib/presentation/features/company/company_hub_screen.dart', 'GameCatalog.marketCompanies.reduce', 'competitor comparison'),
    ('lib/presentation/features/company/company_hub_screen.dart', 'FundPhilanthropy', 'philanthropy UI'),
    ('lib/presentation/features/company/company_hub_screen.dart', 'ChoosePostGamePath', 'postgame UI'),
    ('lib/presentation/features/team/team_screen.dart', "../../../domain/entities/v16_models.dart", 'Team FacilityQuality import'),
    ('test/presentation/v17_endgame_ecosystem_widget_test.dart', "package:founder_os/domain/entities/v12_models.dart", 'widget FounderCompanyProfile import'),
    ('lib/presentation/features/team/team_screen.dart', "key: const Key('team-company-perks')", 'perks UI'),
    ('lib/presentation/features/research/research_screen.dart', "key: const Key('research-screen-list')", 'dedicated R&D screen'),
    ('lib/presentation/features/team/team_screen.dart', "key: const Key('team-legend-market')", 'legend UI'),
    ('lib/presentation/features/team/team_screen.dart', "key: const Key('team-departure-risks')", 'departure UI'),
    ('lib/presentation/features/products/product_workspace_screen.dart', "Key('research-feature-${feature.id}')", 'feature R&D UI'),
    ('lib/presentation/features/products/product_workspace_screen.dart', "Key('research-technology-${technology.id}')", 'technology R&D UI'),
    ('lib/presentation/features/products/product_detail_screen.dart', 'ResearchScreen(', 'product detail routes to dedicated R&D'),
    ('test/domain/v17_endgame_ecosystem_test.dart', 'post-release feature requires paid research before implementation', 'R&D regression'),
    ('test/domain/v17_endgame_ecosystem_test.dart', 'counter offer keeps a resigning employee with required raise', 'counteroffer regression'),
    ('test/domain/v17_endgame_ecosystem_test.dart', 'architect legend requires three products valuation and premium Cyprus office', 'legend requirement regression'),
    ('test/domain/v17_endgame_ecosystem_test.dart', 'event sells at most three product slots and later creates users and fans', 'event regression'),
    ('test/domain/v17_endgame_ecosystem_test.dart', 'campaign completion depends only on all three world projects', 'victory regression'),
    ('test/domain/v17_endgame_ecosystem_test.dart', 'post-game path is locked before victory and available after it', 'postgame regression'),
    ('test/presentation/v17_endgame_ecosystem_widget_test.dart', 'dashboard exposes a dedicated notifications and events tab', 'events widget regression'),
    ('test/presentation/v17_endgame_ecosystem_widget_test.dart', 'company events hub fits a narrow iPhone without overflow', 'narrow company hub regression'),
    ('test/presentation/v17_endgame_ecosystem_widget_test.dart', 'team exposes perks legends and resignation counter offer', 'team widget regression'),
    ('test/presentation/v17_endgame_ecosystem_widget_test.dart', 'post-release feature shows paid research before implementation', 'R&D widget regression'),
    ('test/domain/v17_product_pressure_test.dart', "selectedHostingPlanId: 'owned'", 'R1 owned-infrastructure fixture uses hosting-plan contract'),
    ('lib/domain/entities/game_state.dart', 'productImprovementComputeMultiplier(product.id) *\n            _resourceOptimizationMultiplier(product)', 'R7 compute optimization reaches CPU demand'),
    ('lib/domain/simulation/engine/game_engine.dart', '.clamp(0.012, 0.58)', 'R16 causal churn ceiling preserves monetization differentiation'),
    ('test/presentation/v17_product_pressure_widget_test.dart', 'package:founder_os/domain/entities/operations_models.dart', 'R8 widget Employee managedCopyWith extension import'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'final monetizationOptions = <MonetizationModel>{', 'R9 workspace legacy-safe monetization options'),
    ('lib/presentation/features/products/product_workspace_screen.dart', 'items: monetizationOptions', 'R9 workspace dropdown uses safe options'),
    ('lib/presentation/features/products/product_detail_screen.dart', 'final monetizationOptions = <MonetizationModel>{', 'R9 detail legacy-safe monetization options'),
    ('lib/presentation/features/products/product_detail_screen.dart', 'items: monetizationOptions', 'R9 detail dropdown uses safe options'),
    ('test/presentation/v17_product_pressure_widget_test.dart', 'legacy incompatible monetization opens product detail without dropdown assertion', 'R9 legacy monetization detail widget regression'),
    ('lib/presentation/features/infrastructure/infrastructure_screen.dart', 'constraints.maxWidth < 620', 'R11 narrow infrastructure selector breakpoint'),
    ('lib/presentation/features/infrastructure/infrastructure_screen.dart', "Key('infra-tab-${item.$1.name}')", 'R11 visible narrow infrastructure tab keys'),
    ('lib/presentation/features/infrastructure/infrastructure_screen.dart', 'type: MaterialType.transparency', 'R11 narrow infrastructure selector owns Material ancestor'),
    ('lib/presentation/features/products/product_workspace_screen.dart', "Key('workspace-section-${item.$1.name}')", 'R11 stable workspace section keys'),
    ('test/presentation/v17_product_pressure_widget_test.dart', "find.byKey(Key('workspace-section-$section'))", 'R11 rapid workspace switching uses stable section targets'),
    ('test/presentation/v17_product_pressure_widget_test.dart', "Key('infra-tab-rooms')", 'R11 narrow infrastructure regression targets visible rooms tab'),
    ('test/presentation/v17_product_pressure_widget_test.dart', 'expect(rect.right, lessThanOrEqualTo(390));', 'R11 narrow infrastructure controls stay inside viewport'),
    ('lib/domain/entities/game_state.dart', "product.blueprintId == 'company_website'\n        ? 0.75", 'R12 bootstrap website RAM baseline'),
    ('lib/domain/entities/game_state.dart', "final baselineStorageGb = product.blueprintId == 'company_website'", 'R12 bootstrap website storage baseline'),
    ('lib/domain/entities/game_state.dart', '? 8.0\n        : 18.0;', 'R12 bootstrap website storage value'),
    ('test/domain/v17_product_pressure_test.dart', 'bootstrap website remains safe on shared launch while scaled usage stays material', 'R12 bootstrap hosting compatibility regression'),
    ('lib/domain/entities/game_state.dart', 'valuation < legend.requiredValuation) {\n      return false;\n    }', 'R15 legend requirement uses braced control flow'),
    ('lib/domain/simulation/engine/game_engine.dart', '!state.hasLegendRequirement(action.legendId)) {\n      return state;\n    }', 'R15 legend hire uses braced control flow'),
    ('lib/domain/entities/game_state.dart', 'final servesTraffic = product.stage == ProductStage.live;', 'R15 prelaunch risk separates live traffic'),
    ('lib/domain/entities/game_state.dart', 'final infrastructureRisk = servesTraffic', 'R15 infrastructure risk is live-only'),
    ('lib/presentation/features/dashboard/founder_dashboard.dart', 'height: 68,', 'R15 dashboard nav compact height'),
    ('lib/presentation/features/dashboard/founder_dashboard.dart', 'labelBehavior: NavigationDestinationLabelBehavior.alwaysShow', 'R16 dashboard navigation labels stay visible and tappable'),
    ('test/presentation/v17_product_pressure_widget_test.dart', "final infrastructure = find.text('Инфра').last;", 'R16 focused regression taps the actual navigation label'),
    ('test/domain/v17_product_pressure_test.dart', 'prelaunch investor negotiation ignores live infrastructure overload risk', 'R15 investor counter-offer regression'),
    ('test/presentation/v17_product_pressure_widget_test.dart', 'team averages stay visible at the top on narrow iPhone', 'R15 Team averages visibility regression'),
    ('test/presentation/v17_product_pressure_widget_test.dart', 'dashboard bottom navigation remains tappable at 800 by 600', 'R15 800x600 navigation regression'),
]

# These files are mutated on top of the V16 checkout to preserve unrelated local content.
checks += [
    ('lib/domain/entities/game_state_index.dart', 'serviceRouteByProductAndService', 'R1 service route index'),
    ('lib/presentation/features/finance/finance_screen.dart', 'state.monthlyCompanyPerkCost', 'finance perk breakdown'),
    ('lib/presentation/shared/widgets/hosting_plans_panel.dart', "width: double.infinity", 'R9 hosting full-width narrow action'),
    ('lib/presentation/shared/widgets/hosting_plans_panel.dart', "alignment: Alignment.centerLeft", 'R9 hosting stacked narrow status'),
    ('lib/presentation/features/finance/finance_screen.dart', 'state.monthlyWorldProjectOperatingCost', 'finance world project breakdown'),
    ('lib/presentation/features/products/products_screen.dart', "key: const Key('world-project-legacy-summary')", 'Products new campaign goal'),
    ('lib/presentation/features/market/market_screen.dart', 'onPressed: !acquired &&\n                      state.cash >= remainingCompanyPrice', 'R15 M&A detached from victory without dead code'),
    ('tools/apply_v17_base_mutations.py', 'if new and new in text:', 'R15 replace helper never treats empty replacement as already applied'),
    ('tools/apply_v17_base_mutations.py', 'def delete_once(', 'R15 explicit idempotent delete helper'),
    ('tools/apply_v17_base_mutations.py', 'if forbidden_marker not in text:', 'R15 delete helper distinguishes removed code from anchor drift'),
    ('test/domain/game_engine_test.dart', "state.researchKey(ResearchTargetKind.feature, 'file_analysis')", 'legacy feature test R&D'),
    ('test/domain/product_economy_v8_test.dart', "state.researchKey(ResearchTargetKind.feature, 'contact_form')", 'v8 feature test R&D'),
    ('test/domain/v13_release_candidate_test.dart', 'final acquisition is independent from campaign victory', 'v13 new victory test'),
]

negative = [
    ('lib/presentation/features/products/product_workspace_screen.dart', 'items: strategy.allowedMonetizationModels', 'unsafe workspace monetization dropdown source'),
    ('lib/presentation/features/products/product_detail_screen.dart', 'items: strategy.allowedMonetizationModels', 'unsafe detail monetization dropdown source'),
    ('lib/presentation/shared/widgets/hosting_plans_panel.dart', 'overflow: TextOverflow.ellipsis', 'old narrow-hosting provider row'),
    ('test/domain/v17_product_pressure_test.dart', 'usingOwnedInfrastructure: true', 'invalid computed owned-infrastructure copyWith fixture'),
    ('lib/domain/simulation/engine/game_engine.dart', 'research_start_$key_', 'invalid research notification interpolation'),
    ('lib/presentation/features/products/products_screen.dart', 'Порог 70% пройден', 'old Products 70% victory copy'),
    ('lib/presentation/features/market/market_screen.dart', 'Последнего конкурента можно поглотить только', 'old M&A victory lock copy'),
    ('test/domain/v13_release_candidate_test.dart', 'final acquisition respects 70 percent gate', 'old v13 70% test'),
    ('test/presentation/v17_product_pressure_widget_test.dart', "'Инфраструктура',", 'fragile R1 rapid-switch text target'),
    ('test/presentation/v17_product_pressure_widget_test.dart', "tester.tap(find.text('Серверные'))", 'off-screen infrastructure tab tap regression'),
    ('lib/presentation/features/market/market_screen.dart', 'finalAcquisitionLocked', 'obsolete M&A lock variable / dead code'),
    ('lib/domain/entities/game_state.dart', 'valuation < legend.requiredValuation) return false;', 'unbraced legend requirement lint'),
    ('lib/domain/simulation/engine/game_engine.dart', '!state.hasLegendRequirement(action.legendId)) return state;', 'unbraced legend hire lint'),
    ('tools/apply_v17_base_mutations.py', '    """""",', 'empty-string delete replacement in mutation script'),
    ('lib/presentation/features/dashboard/founder_dashboard.dart', 'NavigationDestinationLabelBehavior.onlyShowSelected', 'hidden unselected bottom-navigation labels'),
]

failures = []
for rel, needle, label in checks:
    path = ROOT / rel
    if not path.is_file():
        failures.append(f'{label}: missing file {rel}')
        continue
    text = path.read_text(encoding='utf-8')
    compact_text = re.sub(r'\s+', '', text)
    compact_needle = re.sub(r'\s+', '', needle)
    if needle not in text and compact_needle not in compact_text:
        failures.append(f'{label}: missing {needle!r} in {rel}')
for rel, needle, label in negative:
    path = ROOT / rel
    if path.is_file() and needle in path.read_text(encoding='utf-8'):
        failures.append(f'{label}: forbidden {needle!r} remains in {rel}')

team_path = ROOT / 'lib/presentation/features/team/team_screen.dart'
if team_path.is_file():
    team_text = team_path.read_text(encoding='utf-8')
    averages_pos = team_text.find("'Средние показатели'")
    hr_pos = team_text.find("key: const Key('team-hr-status')")
    if averages_pos < 0 or hr_pos < 0 or averages_pos > hr_pos:
        failures.append('R15 Team averages must remain before HR/culture/legend cards')

eof_files = [
    'docs/CHANGELOG.md',
    'docs/DECISIONS.md',
    'docs/IMPLEMENTATION_STATUS.md',
]
for rel in eof_files:
    path = ROOT / rel
    if not path.is_file():
        failures.append(f'R17 EOF hygiene: missing file {rel}')
        continue
    data = path.read_bytes()
    if not data.endswith(b'\n') or data.endswith(b'\n\n'):
        failures.append(f'R17 EOF hygiene: {rel} must end with exactly one newline')

if failures:
    print('V17 R17 ENDGAME ECOSYSTEM AUDIT: FAIL', file=sys.stderr)
    for failure in failures:
        print(f'- {failure}', file=sys.stderr)
    raise SystemExit(1)

print('V17 R17 ENDGAME ECOSYSTEM AUDIT: PASS')
print(f'Validated {len(checks) + len(negative) + len(eof_files)} implementation invariants and 2 focused R2 test files.')
