import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

const founderSkills = <FounderSkill, int>{
  FounderSkill.engineering: 4,
  FounderSkill.design: 3,
  FounderSkill.product: 5,
  FounderSkill.growth: 3,
  FounderSkill.negotiation: 3,
  FounderSkill.operations: 4,
};

GameState fundedInitial({int seed = 424242, double cash = 1000000000}) =>
    GameState.initial(seed: seed).copyWith(
      cash: cash,
      companyProfile: const FounderCompanyProfile.legacy(),
      onboardingCompleted: true,
    );

GameState configuredCompany(
  GameEngine engine, {
  String cityId = 'moscow',
  double budget = 1200000,
  FounderBackground background = FounderBackground.product,
}) => engine.reduce(
  GameState.initial(seed: 424242),
  ConfigureCompany(
    companyName: 'Current Labs',
    founderName: 'Alex',
    logoId: 'company_logo_01',
    startingBudget: budget,
    background: background,
    skills: founderSkills,
    headquartersCityId: cityId,
  ),
);

Product productFixture({
  String id = 'product_fixture',
  String blueprintId = 'company_website',
  String name = 'Fixture Product',
  ProductStage stage = ProductStage.live,
  int users = 25000,
  int dau = 6000,
  int mau = 18000,
  double activation = 0.55,
  double retention = 0.62,
  double churn = 0.05,
  double rating = 4.2,
  double speedMs = 180,
  double design = 80,
  double security = 75,
  double reliability = 0.995,
  double featureCoverage = 0.8,
  double quality = 84,
  double monthlyRevenue = 500000,
  double monthlyCost = 30000,
  double monthlyGrowth = 2200,
  MonetizationModel monetization = MonetizationModel.advertising,
  double? price,
  double intensity = 0.5,
  double freeTierPercent = 0.35,
  double brandAwareness = 0.35,
  double brandTrust = 0.72,
  List<String>? technologyIds,
  List<String>? featureIds,
  double allocatedCapacityPercent = 30,
}) {
  final blueprint = GameCatalog.blueprintById(blueprintId);
  final website = blueprintId == 'company_website';
  return Product(
    id: id,
    blueprintId: blueprint.id,
    name: name,
    category: blueprint.category,
    stage: stage,
    frameworkId: website ? 'static_web' : 'flutter_firebase',
    languageIds: website ? const <String>['html_css'] : const <String>['dart'],
    technologyIds: technologyIds ?? const <String>[],
    featureIds: featureIds ?? const <String>['landing_page'],
    developmentProgress: stage == ProductStage.development ? 0.5 : 1,
    users: users,
    dau: dau,
    mau: mau,
    activationRate: activation,
    retention30d: retention,
    churnRate: churn,
    rating: rating,
    speedMs: speedMs,
    designScore: design,
    securityScore: security,
    reliability: reliability,
    featureCoverage: featureCoverage,
    qualityScore: quality,
    monthlyRevenue: monthlyRevenue,
    monthlyCost: monthlyCost,
    monthlyGrowth: monthlyGrowth,
    price: price ?? (blueprint.basePrice <= 0 ? 1 : blueprint.basePrice),
    monetization: monetization,
    marketingBudget: 0,
    allocatedCapacityPercent: allocatedCapacityPercent,
    computeMultiplier: 1,
    createdAtMinutes: 0,
    acquired: false,
    brandAwareness: brandAwareness,
    brandTrust: brandTrust,
    priceSentiment: 0,
    monetizationIntensity: intensity,
    freeTierPercent: freeTierPercent,
  );
}

GameState liveWebsiteState({
  double cash = 10000000,
  bool paused = true,
  int seed = 424242,
}) => fundedInitial(seed: seed, cash: cash).copyWith(
  paused: paused,
  selectedHostingPlanId: 'shared_launch',
  products: <Product>[
    productFixture(
      id: 'website',
      blueprintId: 'company_website',
      name: 'Founder Site',
      monetization: MonetizationModel.advertising,
      users: 1000,
      dau: 180,
      mau: 700,
      monthlyRevenue: 30000,
    ),
  ],
);

GameState liveSaasState({
  double cash = 10000000,
  bool paused = true,
  int seed = 424242,
}) => fundedInitial(seed: seed, cash: cash).copyWith(
  paused: paused,
  selectedHostingPlanId: 'vps_core',
  products: <Product>[
    productFixture(
      id: 'saas',
      blueprintId: 'team_saas',
      name: 'Current SaaS',
      monetization: MonetizationModel.subscription,
      price: 500,
      users: 25000,
      dau: 6000,
      mau: 18000,
      monthlyRevenue: 450000,
      featureIds: const <String>['realtime_collaboration'],
      technologyIds: const <String>['postgresql'],
    ),
  ],
);

Employee employeeFixture({
  String id = 'employee_fixture',
  String name = 'Employee Fixture',
  EmployeeRole role = EmployeeRole.backend,
  int skill = 70,
  int speed = 70,
  int quality = 70,
  int autonomy = 70,
  int communication = 70,
  int reliability = 70,
  double salary = 200000,
  int loyalty = 75,
  int morale = 78,
  int workload = 35,
  bool remote = true,
  EmployeeGrade grade = EmployeeGrade.middle,
  String cityId = 'moscow',
}) => Employee(
  id: id,
  name: name,
  role: role,
  skill: skill,
  speed: speed,
  quality: quality,
  autonomy: autonomy,
  communication: communication,
  reliability: reliability,
  salary: salary,
  loyalty: loyalty,
  morale: morale,
  workload: workload,
  remote: remote,
  hiredAtMinutes: 0,
  grade: grade,
  locationCityId: cityId,
);
