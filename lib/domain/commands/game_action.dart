// UAT_FIXPACK_R1
import '../entities/game_state.dart';
import '../entities/models.dart';
import '../entities/product_evolution_models.dart';
import '../entities/v12_models.dart';
import '../entities/v16_models.dart';
import '../entities/v17_models.dart';

sealed class GameAction {
  const GameAction();
}

class CompleteOnboarding extends GameAction {
  const CompleteOnboarding();
}

class RestartOnboarding extends GameAction {
  const RestartOnboarding();
}

class ConfigureCompany extends GameAction {
  const ConfigureCompany({
    required this.companyName,
    required this.founderName,
    required this.logoId,
    required this.startingBudget,
    required this.background,
    required this.skills,
    this.headquartersCityId = 'moscow',
  });

  final String companyName;
  final String founderName;
  final String logoId;
  final double startingBudget;
  final FounderBackground background;
  final Map<FounderSkill, int> skills;
  final String headquartersCityId;
}

class CompleteDevelopmentChallenge extends GameAction {
  const CompleteDevelopmentChallenge({
    required this.productId,
    required this.stage,
    required this.correct,
  });

  final String productId;
  final FounderDevelopmentStage stage;
  final bool correct;
}

class AdvanceTime extends GameAction {
  const AdvanceTime(this.realSeconds);
  final int realSeconds;
}

class SetGameSpeed extends GameAction {
  const SetGameSpeed(this.speed);
  final GameSpeed speed;
}

class TogglePause extends GameAction {
  const TogglePause();
}

class SkipNight extends GameAction {
  const SkipNight();
}

class CreateConfiguredProduct extends GameAction {
  const CreateConfiguredProduct({
    required this.name,
    required this.blueprintId,
    required this.frameworkId,
    required this.languageIds,
    required this.technologyIds,
    required this.featureIds,
    this.monetization,
  });

  final String name;
  final String blueprintId;
  final String frameworkId;
  final List<String> languageIds;
  final List<String> technologyIds;
  final List<String> featureIds;
  final MonetizationModel? monetization;
}

class LaunchProduct extends GameAction {
  const LaunchProduct(this.productId);
  final String productId;
}

class SellProduct extends GameAction {
  const SellProduct(this.productId);
  final String productId;
}

class RenameProduct extends GameAction {
  const RenameProduct({required this.productId, required this.name});

  final String productId;
  final String name;
}

class AddProductFeature extends GameAction {
  const AddProductFeature({required this.productId, required this.featureId});

  final String productId;
  final String featureId;
}

class AddProductTechnology extends GameAction {
  const AddProductTechnology({
    required this.productId,
    required this.technologyId,
  });

  final String productId;
  final String technologyId;
}

class FixProductBug extends GameAction {
  const FixProductBug({required this.productId, required this.bugId});

  final String productId;
  final String bugId;
}

class FixAllProductBugs extends GameAction {
  const FixAllProductBugs(this.productId);
  final String productId;
}

class SetAiDeploymentMode extends GameAction {
  const SetAiDeploymentMode({required this.productId, required this.mode});

  final String productId;
  final AiDeploymentMode mode;
}

class ConnectCorporateAi extends GameAction {
  const ConnectCorporateAi({
    required this.aiProductId,
    required this.targetProductId,
  });

  final String aiProductId;
  final String targetProductId;
}

class DisconnectCorporateAi extends GameAction {
  const DisconnectCorporateAi(this.targetProductId);
  final String targetProductId;
}

class ApplyProductImprovement extends GameAction {
  const ApplyProductImprovement({required this.productId, required this.type});

  final String productId;
  final ProductImprovementType type;
}

class SetProductMonetization extends GameAction {
  const SetProductMonetization({required this.productId, required this.model});

  final String productId;
  final MonetizationModel model;
}

class SetProductPrice extends GameAction {
  const SetProductPrice({required this.productId, required this.price});

  final String productId;
  final double price;
}

class SetProductMonetizationSettings extends GameAction {
  const SetProductMonetizationSettings({
    required this.productId,
    required this.intensity,
    required this.freeTierPercent,
  });

  final String productId;
  final double intensity;
  final double freeTierPercent;
}

class StartProductCrunch extends GameAction {
  const StartProductCrunch(this.productId);

  final String productId;
}

class SetProductMarketingBudget extends GameAction {
  const SetProductMarketingBudget({
    required this.productId,
    required this.monthlyBudget,
  });

  final String productId;
  final double monthlyBudget;
}

class SetProductAllocation extends GameAction {
  const SetProductAllocation({required this.productId, required this.percent});

  final String productId;
  final double percent;
}

class HireCandidate extends GameAction {
  const HireCandidate(this.candidateId);
  final String candidateId;
}

class HireCandidateForProduct extends GameAction {
  const HireCandidateForProduct({
    required this.candidateId,
    required this.productId,
  });

  final String candidateId;
  final String productId;
}

class AutoHireProjectTeam extends GameAction {
  const AutoHireProjectTeam(this.productId);
  final String productId;
}

class AssignEmployeeToProduct extends GameAction {
  const AssignEmployeeToProduct({required this.employeeId, this.productId});

  final String employeeId;
  final String? productId;
}

class SetProductTeam extends GameAction {
  const SetProductTeam({required this.productId, required this.employeeIds});

  final String productId;
  final List<String> employeeIds;
}

class AutoHireContractTeam extends GameAction {
  const AutoHireContractTeam(this.contractId);

  final String contractId;
}

class SetContractTeam extends GameAction {
  const SetContractTeam({required this.contractId, required this.employeeIds});

  final String contractId;
  final List<String> employeeIds;
}

class SendEmployeeOnVacation extends GameAction {
  const SendEmployeeOnVacation(this.employeeId);
  final String employeeId;
}

class GiveWellbeingBonus extends GameAction {
  const GiveWellbeingBonus(this.employeeId);
  final String employeeId;
}

class FireEmployee extends GameAction {
  const FireEmployee(this.employeeId);
  final String employeeId;
}

class GiveEmployeeRaise extends GameAction {
  const GiveEmployeeRaise({required this.employeeId, required this.percent});

  final String employeeId;
  final double percent;
}

class TrainEmployee extends GameAction {
  const TrainEmployee({required this.employeeId, required this.programId});

  final String employeeId;
  final String programId;
}

class TrainEmployees extends GameAction {
  const TrainEmployees({required this.employeeIds, required this.programId});
  final List<String> employeeIds;
  final String programId;
}

class UpgradeEmployeesToGrade extends GameAction {
  const UpgradeEmployeesToGrade({
    required this.employeeIds,
    required this.targetGrade,
  });
  final List<String> employeeIds;
  final EmployeeGrade targetGrade;
}

class RelocateEmployeeToOffice extends GameAction {
  const RelocateEmployeeToOffice({
    required this.employeeId,
    required this.officeSiteId,
  });

  final String employeeId;
  final String officeSiteId;
}

class PurchaseSecurityControl extends GameAction {
  const PurchaseSecurityControl({
    required this.productId,
    required this.controlId,
  });

  final String productId;
  final String controlId;
}

class RunSecurityAudit extends GameAction {
  const RunSecurityAudit(this.productId);
  final String productId;
}

class BuildOwnedOffice extends GameAction {
  const BuildOwnedOffice({
    required this.cityId,
    required this.size,
    required this.fitoutQuality,
    required this.equipmentQuality,
  });
  final String cityId;
  final FacilitySize size;
  final FacilityQuality fitoutQuality;
  final FacilityQuality equipmentQuality;
}

class BuildOwnedDataCenter extends GameAction {
  const BuildOwnedDataCenter({
    required this.cityId,
    required this.size,
    required this.facilityQuality,
    required this.equipmentQuality,
  });
  final String cityId;
  final FacilitySize size;
  final FacilityQuality facilityQuality;
  final FacilityQuality equipmentQuality;
}

class RentOffice extends GameAction {
  const RentOffice(this.officeId);
  final String officeId;
}

class RentServerRoom extends GameAction {
  const RentServerRoom(this.serverRoomId);
  final String serverRoomId;
}

class RentHostingPlan extends GameAction {
  const RentHostingPlan(this.hostingPlanId);
  final String hostingPlanId;
}

class MigrateToOwnedInfrastructure extends GameAction {
  const MigrateToOwnedInfrastructure();
}

class InstallServer extends GameAction {
  const InstallServer(
    this.hardwareId, {
    this.dataCenterSiteId,
    this.service = InfrastructureService.sharedLegacy,
  });
  final String hardwareId;
  final String? dataCenterSiteId;
  final InfrastructureService service;
}

class RemoveServer extends GameAction {
  const RemoveServer(this.hardwareId, {this.dataCenterSiteId, this.service});
  final String hardwareId;
  final String? dataCenterSiteId;
  final InfrastructureService? service;
}

class ConnectProducts extends GameAction {
  const ConnectProducts({
    required this.firstProductId,
    required this.secondProductId,
  });

  final String firstProductId;
  final String secondProductId;
}

class DisconnectProducts extends GameAction {
  const DisconnectProducts({
    required this.firstProductId,
    required this.secondProductId,
  });

  final String firstProductId;
  final String secondProductId;
}

class AcceptClientContract extends GameAction {
  const AcceptClientContract(this.templateId);
  final String templateId;
}

class AssignProductInfrastructureService extends GameAction {
  const AssignProductInfrastructureService({
    required this.productId,
    required this.service,
    required this.dataCenterSiteId,
  });

  final String productId;
  final InfrastructureService service;
  final String dataCenterSiteId;
}

class StartAdvertisingCampaign extends GameAction {
  const StartAdvertisingCampaign({
    required this.productId,
    required this.agencyId,
    required this.channelId,
    required this.budget,
  });

  final String productId;
  final String agencyId;
  final String channelId;
  final double budget;
}

class StopAdvertisingCampaign extends GameAction {
  const StopAdvertisingCampaign(this.campaignId);
  final String campaignId;
}

class RepayBusinessLoanEarly extends GameAction {
  const RepayBusinessLoanEarly();
}

class RequestBusinessLoan extends GameAction {
  const RequestBusinessLoan({this.amount = 50000});
  final double amount;
}

class AcceptEmergencyLoan extends GameAction {
  const AcceptEmergencyLoan();
}

class RedeemDebugPromo extends GameAction {
  const RedeemDebugPromo(this.code);

  final String code;
}

class RequestInvestorFunding extends GameAction {
  const RequestInvestorFunding({
    required this.investorId,
    required this.productId,
    required this.requestedAmount,
  });

  final String investorId;
  final String productId;
  final double requestedAmount;
}

class AcceptInvestorOffer extends GameAction {
  const AcceptInvestorOffer(this.offerId);
  final String offerId;
}

class RejectInvestorOffer extends GameAction {
  const RejectInvestorOffer(this.offerId);
  final String offerId;
}

class BuyBackInvestor extends GameAction {
  const BuyBackInvestor(this.agreementId);
  final String agreementId;
}

class InvestInMarketCompany extends GameAction {
  const InvestInMarketCompany({
    required this.companyId,
    required this.ownershipPercent,
  });

  final String companyId;
  final double ownershipPercent;
}

class AcquireMarketProduct extends GameAction {
  const AcquireMarketProduct({
    required this.companyId,
    required this.mode,
    this.targetProductId,
  });

  final String companyId;
  final AcquisitionMode mode;
  final String? targetProductId;
}

class AcquireMarketCompany extends GameAction {
  const AcquireMarketCompany(this.companyId);
  final String companyId;
}

class TriggerSecurityIncident extends GameAction {
  const TriggerSecurityIncident(this.productId);
  final String productId;
}

class ResolveCriticalEvent extends GameAction {
  const ResolveCriticalEvent();
}

class ToggleMiniGames extends GameAction {
  const ToggleMiniGames();
}

class ResetGame extends GameAction {
  const ResetGame();
}

class StartCompanyResearch extends GameAction {
  const StartCompanyResearch({required this.kind, required this.targetId});
  final ResearchTargetKind kind;
  final String targetId;
}

class ToggleCompanyPerk extends GameAction {
  const ToggleCompanyPerk(this.perkId);
  final String perkId;
}

class HireMarketLegend extends GameAction {
  const HireMarketLegend({required this.legendId, required this.productId});
  final String legendId;
  final String productId;
}

class CounterOfferEmployee extends GameAction {
  const CounterOfferEmployee(this.employeeId);
  final String employeeId;
}

class JoinIndustryEvent extends GameAction {
  const JoinIndustryEvent({
    required this.opportunityId,
    required this.productIds,
  });
  final String opportunityId;
  final List<String> productIds;
}

class MarkCompanyNotificationRead extends GameAction {
  const MarkCompanyNotificationRead(this.notificationId);
  final String notificationId;
}

class DeleteCompanyNotification extends GameAction {
  const DeleteCompanyNotification(this.notificationId);
  final String notificationId;
}

class ClearCompanyNotifications extends GameAction {
  const ClearCompanyNotifications();
}

class MarkAllCompanyNotificationsRead extends GameAction {
  const MarkAllCompanyNotificationsRead();
}

class FundWorldProjectPhase extends GameAction {
  const FundWorldProjectPhase(this.projectId);
  final String projectId;
}

class RenameWorldProject extends GameAction {
  const RenameWorldProject({required this.projectId, required this.name});
  final String projectId;
  final String name;
}

class StartWorldProjectUpgrade extends GameAction {
  const StartWorldProjectUpgrade({
    required this.projectId,
    required this.upgradeId,
  });
  final String projectId;
  final String upgradeId;
}

class SetEcosystemDoctrine extends GameAction {
  const SetEcosystemDoctrine(this.doctrine);
  final EcosystemDoctrine doctrine;
}

class FundPhilanthropy extends GameAction {
  const FundPhilanthropy(this.amount);
  final double amount;
}

class ChoosePostGamePath extends GameAction {
  const ChoosePostGamePath(this.path);
  final PostGamePath path;
}
