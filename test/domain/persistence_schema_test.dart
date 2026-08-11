import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/v17_models.dart';

import '../support/fixtures.dart';

void main() {
  test('current snapshot schema is sixteen', () {
    expect(currentSnapshotVersion, 16);
    expect(GameState.initial().snapshotVersion, 16);
  });

  test('full current state round-trip preserves business systems', () {
    final state = fundedInitial(seed: 77).copyWith(
      companyFans: 999,
      brandReputation: 88,
      products: <Product>[productFixture()],
      completedResearchKeys: const <String>['technology:redis'],
      enabledCompanyPerkIds: const <String>['health_insurance'],
      ecosystemDoctrine: EcosystemDoctrine.open,
      philanthropySpent: 123456,
    );
    final restored = GameState.decode(state.encode());
    expect(restored.snapshotVersion, 16);
    expect(restored.rngSeed, state.rngSeed);
    expect(restored.companyFans, 999);
    expect(restored.products.single.id, state.products.single.id);
    expect(restored.completedResearchKeys, contains('technology:redis'));
    expect(restored.enabledCompanyPerkIds, contains('health_insurance'));
    expect(restored.ecosystemDoctrine, EcosystemDoctrine.open);
    expect(restored.philanthropySpent, 123456);
  });

  test('older geography snapshot migrates to current defaults', () {
    final raw =
        jsonDecode(GameState.initial().encode()) as Map<String, dynamic>;
    raw['snapshotVersion'] = 13;
    for (final key in <String>[
      'headquartersCityId',
      'ownedOffices',
      'ownedDataCenters',
      'employeeTrainings',
      'employeeGradeUpgrades',
      'taxRecords',
      'taxYearRevenueAccrued',
      'taxYearExpensesAccrued',
      'taxYearPayrollAccrued',
    ]) {
      raw.remove(key);
    }
    final restored = GameState.decode(jsonEncode(raw));
    expect(restored.snapshotVersion, 16);
    expect(restored.headquartersCityId, 'moscow');
    expect(restored.ownedOffices, isEmpty);
    expect(restored.ownedDataCenters, isEmpty);
    expect(restored.taxRecords, isEmpty);
  });

  test(
    'pre-endgame snapshot migrates R&D fans notifications and world defaults',
    () {
      final raw =
          jsonDecode(GameState.initial().encode()) as Map<String, dynamic>;
      raw['snapshotVersion'] = 15;
      for (final key in <String>[
        'activeResearchProjects',
        'completedResearchKeys',
        'enabledCompanyPerkIds',
        'legendMarketOffers',
        'hiredLegendBonuses',
        'pendingEmployeeDepartures',
        'companyFans',
        'brandReputation',
        'industryEventOpportunities',
        'bookedIndustryEvents',
        'companyNotifications',
        'worldProjects',
        'ecosystemDoctrine',
        'philanthropySpent',
        'postGamePath',
      ]) {
        raw.remove(key);
      }
      final restored = GameState.decode(jsonEncode(raw));
      expect(restored.snapshotVersion, 16);
      expect(restored.completedResearchKeys, isEmpty);
      expect(restored.companyFans, 0);
      expect(restored.brandReputation, 10);
      expect(restored.companyNotifications, isEmpty);
      expect(restored.worldProjects, isEmpty);
      expect(restored.postGamePath, PostGamePath.none);
    },
  );

  test('legacy service-routing fields migrate to empty current defaults', () {
    final raw =
        jsonDecode(GameState.initial().encode()) as Map<String, dynamic>;
    raw['snapshotVersion'] = 14;
    raw.remove('employeeRelocations');
    raw.remove('productServiceRoutes');
    final restored = GameState.decode(jsonEncode(raw));
    expect(restored.snapshotVersion, 16);
    expect(restored.employeeRelocations, isEmpty);
    expect(restored.productServiceRoutes, isEmpty);
  });

  test('product monetization fields have controlled defaults when absent', () {
    final raw = productFixture().toJson();
    raw.remove('monetizationIntensity');
    raw.remove('freeTierPercent');
    final restored = Product.fromJson(raw);
    expect(restored.monetizationIntensity, 0.5);
    expect(restored.freeTierPercent, 0.25);
  });

  test(
    'future snapshot versions fail loudly instead of guessing migration',
    () {
      final raw =
          jsonDecode(GameState.initial().encode()) as Map<String, dynamic>;
      raw['snapshotVersion'] = 999;
      expect(() => GameState.decode(jsonEncode(raw)), throwsFormatException);
    },
  );

  test('malformed snapshot root fails loudly', () {
    expect(() => GameState.decode('"not-an-object"'), throwsFormatException);
  });
}
