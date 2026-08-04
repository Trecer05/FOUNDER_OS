import '../entities/game_state.dart';
import '../entities/models.dart';

sealed class GameAction {
  const GameAction();
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
  });

  final String name;
  final String blueprintId;
  final String frameworkId;
  final List<String> languageIds;
  final List<String> technologyIds;
  final List<String> featureIds;
}

class LaunchProduct extends GameAction {
  const LaunchProduct(this.productId);
  final String productId;
}

class AddProductFeature extends GameAction {
  const AddProductFeature({required this.productId, required this.featureId});

  final String productId;
  final String featureId;
}

class SetProductMonetization extends GameAction {
  const SetProductMonetization({required this.productId, required this.model});

  final String productId;
  final MonetizationModel model;
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

class RentOffice extends GameAction {
  const RentOffice(this.officeId);
  final String officeId;
}

class RentServerRoom extends GameAction {
  const RentServerRoom(this.serverRoomId);
  final String serverRoomId;
}

class InstallServer extends GameAction {
  const InstallServer(this.hardwareId);
  final String hardwareId;
}

class RemoveServer extends GameAction {
  const RemoveServer(this.hardwareId);
  final String hardwareId;
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
