import '../entities/v16_models.dart';

abstract final class WorldEconomyCatalog {
  static const List<WorldCityOption> cities = <WorldCityOption>[
    WorldCityOption(
      id: 'moscow',
      cityRu: 'Москва',
      cityEn: 'Moscow',
      countryRu: 'Россия',
      countryEn: 'Russia',
      corporateTaxRate: 0.20,
      payrollTaxRate: 0.30,
      salaryMultiplier: 1.00,
      rentMultiplier: 1.00,
      utilityMultiplier: 1.00,
      constructionMultiplier: 1.00,
      talentScore: 87,
      investorScore: 62,
      marketAccessScore: 76,
      regulationScore: 58,
      networkScore: 84,
    ),
    WorldCityOption(
      id: 'dubai',
      cityRu: 'Дубай',
      cityEn: 'Dubai',
      countryRu: 'ОАЭ',
      countryEn: 'UAE',
      corporateTaxRate: 0.09,
      payrollTaxRate: 0.05,
      salaryMultiplier: 1.56,
      rentMultiplier: 1.60,
      utilityMultiplier: 1.64,
      constructionMultiplier: 1.45,
      talentScore: 78,
      investorScore: 91,
      marketAccessScore: 88,
      regulationScore: 82,
      networkScore: 91,
    ),
    WorldCityOption(
      id: 'singapore',
      cityRu: 'Сингапур',
      cityEn: 'Singapore',
      countryRu: 'Сингапур',
      countryEn: 'Singapore',
      corporateTaxRate: 0.17,
      payrollTaxRate: 0.12,
      salaryMultiplier: 1.86,
      rentMultiplier: 1.90,
      utilityMultiplier: 1.47,
      constructionMultiplier: 1.78,
      talentScore: 94,
      investorScore: 96,
      marketAccessScore: 96,
      regulationScore: 94,
      networkScore: 98,
    ),
    WorldCityOption(
      id: 'san_francisco',
      cityRu: 'Сан-Франциско',
      cityEn: 'San Francisco',
      countryRu: 'США',
      countryEn: 'USA',
      corporateTaxRate: 0.27,
      payrollTaxRate: 0.18,
      salaryMultiplier: 2.57,
      rentMultiplier: 2.44,
      utilityMultiplier: 1.67,
      constructionMultiplier: 2.26,
      talentScore: 100,
      investorScore: 100,
      marketAccessScore: 98,
      regulationScore: 72,
      networkScore: 97,
    ),
    WorldCityOption(
      id: 'london',
      cityRu: 'Лондон',
      cityEn: 'London',
      countryRu: 'Великобритания',
      countryEn: 'United Kingdom',
      corporateTaxRate: 0.25,
      payrollTaxRate: 0.16,
      salaryMultiplier: 1.97,
      rentMultiplier: 2.08,
      utilityMultiplier: 1.74,
      constructionMultiplier: 1.91,
      talentScore: 93,
      investorScore: 95,
      marketAccessScore: 96,
      regulationScore: 86,
      networkScore: 96,
    ),
    WorldCityOption(
      id: 'berlin',
      cityRu: 'Берлин',
      cityEn: 'Berlin',
      countryRu: 'Германия',
      countryEn: 'Germany',
      corporateTaxRate: 0.30,
      payrollTaxRate: 0.21,
      salaryMultiplier: 1.46,
      rentMultiplier: 1.38,
      utilityMultiplier: 1.64,
      constructionMultiplier: 1.53,
      talentScore: 90,
      investorScore: 84,
      marketAccessScore: 92,
      regulationScore: 88,
      networkScore: 93,
    ),
    WorldCityOption(
      id: 'warsaw',
      cityRu: 'Варшава',
      cityEn: 'Warsaw',
      countryRu: 'Польша',
      countryEn: 'Poland',
      corporateTaxRate: 0.19,
      payrollTaxRate: 0.17,
      salaryMultiplier: 1.08,
      rentMultiplier: 0.92,
      utilityMultiplier: 1.22,
      constructionMultiplier: 1.08,
      talentScore: 84,
      investorScore: 74,
      marketAccessScore: 87,
      regulationScore: 83,
      networkScore: 90,
    ),
    WorldCityOption(
      id: 'helsinki',
      cityRu: 'Хельсинки',
      cityEn: 'Helsinki',
      countryRu: 'Финляндия',
      countryEn: 'Finland',
      corporateTaxRate: 0.20,
      payrollTaxRate: 0.20,
      salaryMultiplier: 1.56,
      rentMultiplier: 1.47,
      utilityMultiplier: 1.32,
      constructionMultiplier: 1.58,
      talentScore: 91,
      investorScore: 86,
      marketAccessScore: 86,
      regulationScore: 96,
      networkScore: 96,
    ),
    WorldCityOption(
      id: 'bangalore',
      cityRu: 'Бангалор',
      cityEn: 'Bangalore',
      countryRu: 'Индия',
      countryEn: 'India',
      corporateTaxRate: 0.25,
      payrollTaxRate: 0.10,
      salaryMultiplier: 0.67,
      rentMultiplier: 0.56,
      utilityMultiplier: 0.86,
      constructionMultiplier: 0.68,
      talentScore: 92,
      investorScore: 76,
      marketAccessScore: 91,
      regulationScore: 64,
      networkScore: 84,
    ),
    WorldCityOption(
      id: 'toronto',
      cityRu: 'Торонто',
      cityEn: 'Toronto',
      countryRu: 'Канада',
      countryEn: 'Canada',
      corporateTaxRate: 0.265,
      payrollTaxRate: 0.14,
      salaryMultiplier: 1.69,
      rentMultiplier: 1.64,
      utilityMultiplier: 1.31,
      constructionMultiplier: 1.71,
      talentScore: 92,
      investorScore: 90,
      marketAccessScore: 91,
      regulationScore: 90,
      networkScore: 94,
    ),
    WorldCityOption(
      id: 'sao_paulo',
      cityRu: 'Сан-Паулу',
      cityEn: 'São Paulo',
      countryRu: 'Бразилия',
      countryEn: 'Brazil',
      corporateTaxRate: 0.34,
      payrollTaxRate: 0.20,
      salaryMultiplier: 0.86,
      rentMultiplier: 0.74,
      utilityMultiplier: 1.08,
      constructionMultiplier: 0.87,
      talentScore: 79,
      investorScore: 68,
      marketAccessScore: 92,
      regulationScore: 55,
      networkScore: 81,
    ),
    WorldCityOption(
      id: 'tokyo',
      cityRu: 'Токио',
      cityEn: 'Tokyo',
      countryRu: 'Япония',
      countryEn: 'Japan',
      corporateTaxRate: 0.30,
      payrollTaxRate: 0.15,
      salaryMultiplier: 1.78,
      rentMultiplier: 1.86,
      utilityMultiplier: 1.53,
      constructionMultiplier: 1.79,
      talentScore: 94,
      investorScore: 88,
      marketAccessScore: 95,
      regulationScore: 91,
      networkScore: 98,
    ),
    WorldCityOption(
      id: 'limassol',
      cityRu: 'Лимасол',
      cityEn: 'Limassol',
      countryRu: 'Кипр',
      countryEn: 'Cyprus',
      corporateTaxRate: 0.125,
      payrollTaxRate: 0.12,
      salaryMultiplier: 1.34,
      rentMultiplier: 1.42,
      utilityMultiplier: 1.28,
      constructionMultiplier: 1.36,
      talentScore: 82,
      investorScore: 90,
      marketAccessScore: 88,
      regulationScore: 84,
      networkScore: 91,
    ),
  ];

  static final Map<String, WorldCityOption> _byId = <String, WorldCityOption>{
    for (final city in cities) city.id: city,
  };

  static bool containsCity(String id) => _byId.containsKey(id);

  static WorldCityOption cityById(String id) => _byId[id] ?? _byId['moscow']!;

  static int officeCapacity(FacilitySize size) => switch (size) {
    FacilitySize.small => 12,
    FacilitySize.medium => 36,
    FacilitySize.large => 90,
    FacilitySize.campus => 220,
  };

  static int dataCenterRackUnits(FacilitySize size) => switch (size) {
    FacilitySize.small => 42,
    FacilitySize.medium => 140,
    FacilitySize.large => 420,
    FacilitySize.campus => 1100,
  };

  static double officeBaseBuildCost(FacilitySize size) => switch (size) {
    FacilitySize.small => 2200000,
    FacilitySize.medium => 7200000,
    FacilitySize.large => 22000000,
    FacilitySize.campus => 65000000,
  };

  static double dataCenterBaseBuildCost(FacilitySize size) => switch (size) {
    FacilitySize.small => 6500000,
    FacilitySize.medium => 22000000,
    FacilitySize.large => 78000000,
    FacilitySize.campus => 240000000,
  };

  static double qualityMultiplier(FacilityQuality quality) => switch (quality) {
    FacilityQuality.basic => 0.90,
    FacilityQuality.standard => 1.0,
    FacilityQuality.premium => 1.28,
  };

  static double officeBuildCost({
    required String cityId,
    required FacilitySize size,
    required FacilityQuality fitout,
    required FacilityQuality equipment,
  }) {
    final city = cityById(cityId);
    return officeBaseBuildCost(size) *
        city.constructionMultiplier *
        qualityMultiplier(fitout) *
        qualityMultiplier(equipment);
  }

  static double dataCenterBuildCost({
    required String cityId,
    required FacilitySize size,
    required FacilityQuality facility,
    required FacilityQuality equipment,
  }) {
    final city = cityById(cityId);
    return dataCenterBaseBuildCost(size) *
        city.constructionMultiplier *
        qualityMultiplier(facility) *
        qualityMultiplier(equipment);
  }

  static double officeMonthlyCost(OwnedOfficeSite site) {
    final city = cityById(site.cityId);
    final base = officeBaseBuildCost(site.size) * 0.0085;
    return base *
            city.rentMultiplier *
            qualityMultiplier(site.fitoutQuality) *
            0.72 +
        base *
            city.utilityMultiplier *
            qualityMultiplier(site.equipmentQuality) *
            0.28;
  }

  static double dataCenterMonthlyCost(OwnedDataCenterSite site) {
    final city = cityById(site.cityId);
    final base = dataCenterBaseBuildCost(site.size) * 0.0105;
    return base *
        city.utilityMultiplier *
        qualityMultiplier(site.equipmentQuality);
  }

  static double dataCenterPowerKw(OwnedDataCenterSite site) =>
      dataCenterRackUnits(site.size) *
      0.95 *
      qualityMultiplier(site.facilityQuality);

  static double dataCenterCoolingKw(OwnedDataCenterSite site) =>
      dataCenterRackUnits(site.size) *
      0.82 *
      qualityMultiplier(site.facilityQuality);

  static double dataCenterNetworkGbps(OwnedDataCenterSite site) {
    final city = cityById(site.cityId);
    return dataCenterRackUnits(site.size) *
        0.09 *
        qualityMultiplier(site.equipmentQuality) *
        (city.networkScore / 84).clamp(0.75, 1.25);
  }

  static int officeComfortScore(OwnedOfficeSite site) =>
      (55 + site.fitoutQuality.index * 14 + site.equipmentQuality.index * 8)
          .clamp(0, 100)
          .toInt();
}
