import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/contract_catalog.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/catalog/operations_catalog.dart';
import 'package:founder_os/domain/catalog/world_economy_catalog.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/v16_models.dart';
import 'package:founder_os/domain/explainability/product_configuration_resolver.dart';
import 'package:founder_os/domain/validation/v9_content_validator.dart';

void main() {
  test('world economy exposes thirteen unique current cities', () {
    expect(WorldEconomyCatalog.cities, hasLength(13));
    expect(
      WorldEconomyCatalog.cities.map((item) => item.id).toSet(),
      hasLength(13),
    );
    expect(
      WorldEconomyCatalog.cities.map((item) => item.id),
      containsAll(<String>[
        'moscow',
        'dubai',
        'singapore',
        'san_francisco',
        'london',
        'berlin',
        'warsaw',
        'helsinki',
        'bangalore',
        'toronto',
        'sao_paulo',
        'tokyo',
        'limassol',
      ]),
    );
  });

  test('city balance creates salary tax and construction tradeoffs', () {
    final moscow = WorldEconomyCatalog.cityById('moscow');
    final sf = WorldEconomyCatalog.cityById('san_francisco');
    final bangalore = WorldEconomyCatalog.cityById('bangalore');
    final dubai = WorldEconomyCatalog.cityById('dubai');
    final berlin = WorldEconomyCatalog.cityById('berlin');

    expect(sf.salaryMultiplier, greaterThan(moscow.salaryMultiplier));
    expect(bangalore.salaryMultiplier, lessThan(moscow.salaryMultiplier));
    expect(dubai.corporateTaxRate, lessThan(berlin.corporateTaxRate));
  });

  test(
    'office and data-center size ladders have increasing physical capacity',
    () {
      expect(
        WorldEconomyCatalog.officeCapacity(FacilitySize.medium),
        greaterThan(WorldEconomyCatalog.officeCapacity(FacilitySize.small)),
      );
      expect(
        WorldEconomyCatalog.officeCapacity(FacilitySize.campus),
        greaterThan(WorldEconomyCatalog.officeCapacity(FacilitySize.large)),
      );
      expect(
        WorldEconomyCatalog.dataCenterRackUnits(FacilitySize.large),
        greaterThan(
          WorldEconomyCatalog.dataCenterRackUnits(FacilitySize.medium),
        ),
      );
    },
  );

  test('product catalog contains seventeen unique current blueprints', () {
    expect(GameCatalog.productBlueprints, hasLength(17));
    expect(
      GameCatalog.productBlueprints.map((item) => item.id).toSet(),
      hasLength(17),
    );
    expect(
      GameCatalog.productBlueprints.map((item) => item.id),
      containsAll(<String>[
        'company_website',
        'ai_assistant',
        'cloud_platform',
        'team_saas',
        'privacy_browser',
        'crypto_wallet',
        'city_system',
        'developer_platform',
        'mobile_marketplace',
        'analytics_platform',
        'fintech_payments',
        'video_workspace',
        'creator_suite',
        'community_platform',
        'cloud_drive',
        'ai_search',
        'code_forge',
      ]),
    );
  });

  test(
    'every product blueprint has positive development work and category',
    () {
      for (final blueprint in GameCatalog.productBlueprints) {
        expect(
          blueprint.baseDevelopmentHours,
          greaterThan(0),
          reason: blueprint.id,
        );
        expect(
          blueprint.baseDevelopmentCost,
          greaterThanOrEqualTo(0),
          reason: blueprint.id,
        );
        expect(ProductCategory.values, contains(blueprint.category));
      }
    },
  );

  test('contract catalog contains five unique role-gated templates', () {
    expect(ContractCatalog.templates, hasLength(5));
    expect(
      ContractCatalog.templates.map((item) => item.id).toSet(),
      hasLength(5),
    );
    for (final template in ContractCatalog.templates) {
      expect(template.reward, greaterThan(0), reason: template.id);
      expect(template.developmentHours, greaterThan(0), reason: template.id);
      expect(template.deadlineDays, greaterThan(0), reason: template.id);
      expect(template.requiredRoles, isNotEmpty, reason: template.id);
    }
  });

  test('security and training catalogs keep complete unique ids', () {
    expect(OperationsCatalog.securityControls, hasLength(6));
    expect(
      OperationsCatalog.securityControls.map((item) => item.id).toSet(),
      hasLength(6),
    );
    expect(OperationsCatalog.trainingPrograms, hasLength(4));
    expect(
      OperationsCatalog.trainingPrograms.map((item) => item.id).toSet(),
      hasLength(4),
    );
  });

  test('production content validator returns zero issues', () {
    expect(V9ContentValidator.validate(), isEmpty);
  });

  test('configuration resolver allows Dart stack to use HSM', () {
    final result = ProductConfigurationResolver.availability(
      frameworkId: 'flutter_firebase',
      languageIds: const <String>['dart'],
      selectedTechnologyIds: const <String>[],
      technology: GameCatalog.technologyById('hsm'),
    );
    expect(result.enabled, isTrue);
    expect(result.reason, isNull);
  });
}
