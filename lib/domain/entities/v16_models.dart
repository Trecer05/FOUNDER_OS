import 'models.dart';

enum FacilitySize { small, medium, large, campus }

enum FacilityQuality { basic, standard, premium }

class WorldCityOption {
  const WorldCityOption({
    required this.id,
    required this.cityRu,
    required this.cityEn,
    required this.countryRu,
    required this.countryEn,
    required this.corporateTaxRate,
    required this.payrollTaxRate,
    required this.salaryMultiplier,
    required this.rentMultiplier,
    required this.utilityMultiplier,
    required this.constructionMultiplier,
    required this.talentScore,
    required this.investorScore,
    required this.marketAccessScore,
    required this.regulationScore,
    required this.networkScore,
  });

  final String id;
  final String cityRu;
  final String cityEn;
  final String countryRu;
  final String countryEn;
  final double corporateTaxRate;
  final double payrollTaxRate;
  final double salaryMultiplier;
  final double rentMultiplier;
  final double utilityMultiplier;
  final double constructionMultiplier;
  final int talentScore;
  final int investorScore;
  final int marketAccessScore;
  final int regulationScore;
  final int networkScore;
}

class OwnedOfficeSite {
  const OwnedOfficeSite({
    required this.id,
    required this.cityId,
    required this.size,
    required this.fitoutQuality,
    required this.equipmentQuality,
    required this.builtAtMinutes,
  });

  final String id;
  final String cityId;
  final FacilitySize size;
  final FacilityQuality fitoutQuality;
  final FacilityQuality equipmentQuality;
  final int builtAtMinutes;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'cityId': cityId,
    'size': size.name,
    'fitoutQuality': fitoutQuality.name,
    'equipmentQuality': equipmentQuality.name,
    'builtAtMinutes': builtAtMinutes,
  };

  factory OwnedOfficeSite.fromJson(Map<String, Object?> json) =>
      OwnedOfficeSite(
        id: json['id']! as String,
        cityId: json['cityId']! as String,
        size: FacilitySize.values.byName(json['size']! as String),
        fitoutQuality: FacilityQuality.values.byName(
          json['fitoutQuality']! as String,
        ),
        equipmentQuality: FacilityQuality.values.byName(
          json['equipmentQuality']! as String,
        ),
        builtAtMinutes: (json['builtAtMinutes']! as num).toInt(),
      );
}

class OwnedDataCenterSite {
  const OwnedDataCenterSite({
    required this.id,
    required this.cityId,
    required this.size,
    required this.facilityQuality,
    required this.equipmentQuality,
    required this.builtAtMinutes,
  });

  final String id;
  final String cityId;
  final FacilitySize size;
  final FacilityQuality facilityQuality;
  final FacilityQuality equipmentQuality;
  final int builtAtMinutes;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'cityId': cityId,
    'size': size.name,
    'facilityQuality': facilityQuality.name,
    'equipmentQuality': equipmentQuality.name,
    'builtAtMinutes': builtAtMinutes,
  };

  factory OwnedDataCenterSite.fromJson(Map<String, Object?> json) =>
      OwnedDataCenterSite(
        id: json['id']! as String,
        cityId: json['cityId']! as String,
        size: FacilitySize.values.byName(json['size']! as String),
        facilityQuality: FacilityQuality.values.byName(
          json['facilityQuality']! as String,
        ),
        equipmentQuality: FacilityQuality.values.byName(
          json['equipmentQuality']! as String,
        ),
        builtAtMinutes: (json['builtAtMinutes']! as num).toInt(),
      );
}

class EmployeeTrainingAssignment {
  const EmployeeTrainingAssignment({
    required this.id,
    required this.employeeId,
    required this.programId,
    required this.startedAtMinutes,
    required this.completesAtMinutes,
  });

  final String id;
  final String employeeId;
  final String programId;
  final int startedAtMinutes;
  final int completesAtMinutes;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'employeeId': employeeId,
    'programId': programId,
    'startedAtMinutes': startedAtMinutes,
    'completesAtMinutes': completesAtMinutes,
  };

  factory EmployeeTrainingAssignment.fromJson(Map<String, Object?> json) =>
      EmployeeTrainingAssignment(
        id: json['id']! as String,
        employeeId: json['employeeId']! as String,
        programId: json['programId']! as String,
        startedAtMinutes: (json['startedAtMinutes']! as num).toInt(),
        completesAtMinutes: (json['completesAtMinutes']! as num).toInt(),
      );
}

class EmployeeGradeUpgrade {
  const EmployeeGradeUpgrade({
    required this.id,
    required this.employeeId,
    required this.targetGrade,
    required this.startedAtMinutes,
    required this.completesAtMinutes,
    required this.cost,
  });

  final String id;
  final String employeeId;
  final EmployeeGrade targetGrade;
  final int startedAtMinutes;
  final int completesAtMinutes;
  final double cost;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'employeeId': employeeId,
    'targetGrade': targetGrade.name,
    'startedAtMinutes': startedAtMinutes,
    'completesAtMinutes': completesAtMinutes,
    'cost': cost,
  };

  factory EmployeeGradeUpgrade.fromJson(Map<String, Object?> json) =>
      EmployeeGradeUpgrade(
        id: json['id']! as String,
        employeeId: json['employeeId']! as String,
        targetGrade: EmployeeGrade.values.byName(
          json['targetGrade']! as String,
        ),
        startedAtMinutes: (json['startedAtMinutes']! as num).toInt(),
        completesAtMinutes: (json['completesAtMinutes']! as num).toInt(),
        cost: (json['cost']! as num).toDouble(),
      );
}

class AnnualTaxRecord {
  const AnnualTaxRecord({
    required this.yearIndex,
    required this.cityId,
    required this.corporateTax,
    required this.payrollTax,
    required this.paidAtMinutes,
  });

  final int yearIndex;
  final String cityId;
  final double corporateTax;
  final double payrollTax;
  final int paidAtMinutes;

  double get total => corporateTax + payrollTax;

  Map<String, Object?> toJson() => <String, Object?>{
    'yearIndex': yearIndex,
    'cityId': cityId,
    'corporateTax': corporateTax,
    'payrollTax': payrollTax,
    'paidAtMinutes': paidAtMinutes,
  };

  factory AnnualTaxRecord.fromJson(Map<String, Object?> json) =>
      AnnualTaxRecord(
        yearIndex: (json['yearIndex']! as num).toInt(),
        cityId: json['cityId']! as String,
        corporateTax: (json['corporateTax']! as num).toDouble(),
        payrollTax: (json['payrollTax']! as num).toDouble(),
        paidAtMinutes: (json['paidAtMinutes']! as num).toInt(),
      );
}
