import 'dart:math' as math;

import '../../catalog/contract_catalog.dart';
import '../../catalog/game_catalog.dart';
import '../../catalog/operations_catalog.dart';
import '../../catalog/product_evolution_catalog.dart';
import '../../commands/game_action.dart';
import '../../entities/business_models.dart';
import '../../entities/game_state.dart';
import '../../entities/models.dart';
import '../../entities/operations_models.dart';
import '../../entities/product_evolution_models.dart';
import '../product_estimator.dart';

class GameEngine {
  const GameEngine();

  GameState reduce(GameState state, GameAction action) {
    if (action is ResetGame) {
      return GameState.initial();
    }
    if (state.gameOver && action is! ResolveCriticalEvent) {
      return state;
    }

    return switch (action) {
      CompleteOnboarding() => state.copyWith(onboardingCompleted: true),
      RestartOnboarding() => state.copyWith(onboardingCompleted: false),
      AdvanceTime() => _advanceTime(state, action.realSeconds),
      SetGameSpeed() => state.copyWith(speed: action.speed),
      TogglePause() => state.copyWith(paused: !state.paused),
      SkipNight() => _skipNight(state),
      CreateConfiguredProduct() => _createProduct(state, action),
      LaunchProduct() => _launchProduct(state, action.productId),
      AddProductFeature() => _addProductFeature(
        state,
        action.productId,
        action.featureId,
      ),
      SetAiDeploymentMode() => _setAiDeploymentMode(
        state,
        action.productId,
        action.mode,
      ),
      ConnectCorporateAi() => _connectCorporateAi(
        state,
        action.aiProductId,
        action.targetProductId,
      ),
      DisconnectCorporateAi() => _disconnectCorporateAi(
        state,
        action.targetProductId,
      ),
      ApplyProductImprovement() => _applyProductImprovement(
        state,
        action.productId,
        action.type,
      ),
      SetProductMonetization() => _setMonetization(
        state,
        action.productId,
        action.model,
      ),
      SetProductPrice() => _setProductPrice(
        state,
        action.productId,
        action.price,
      ),
      SetProductMarketingBudget() => _setMarketingBudget(
        state,
        action.productId,
        action.monthlyBudget,
      ),
      SetProductAllocation() => _setAllocation(
        state,
        action.productId,
        action.percent,
      ),
      HireCandidate() => _hireCandidate(state, action.candidateId),
      AssignEmployeeToProduct() => _assignEmployee(
        state,
        action.employeeId,
        action.productId,
      ),
      FireEmployee() => _fireEmployee(state, action.employeeId),
      GiveEmployeeRaise() => _giveRaise(
        state,
        action.employeeId,
        action.percent,
      ),
      TrainEmployee() => _trainEmployee(
        state,
        action.employeeId,
        action.programId,
      ),
      PurchaseSecurityControl() => _purchaseSecurityControl(
        state,
        action.productId,
        action.controlId,
      ),
      RunSecurityAudit() => _runSecurityAudit(state, action.productId),
      RentOffice() => _rentOffice(state, action.officeId),
      RentServerRoom() => _rentServerRoom(state, action.serverRoomId),
      InstallServer() => _installServer(state, action.hardwareId),
      RemoveServer() => _removeServer(state, action.hardwareId),
      ConnectProducts() => _connectProducts(
        state,
        action.firstProductId,
        action.secondProductId,
      ),
      DisconnectProducts() => _disconnectProducts(
        state,
        action.firstProductId,
        action.secondProductId,
      ),
      AcceptClientContract() => _acceptClientContract(state, action.templateId),
      RequestInvestorFunding() => _requestFunding(state, action),
      AcceptInvestorOffer() => _acceptOffer(state, action.offerId),
      RejectInvestorOffer() => _rejectOffer(state, action.offerId),
      BuyBackInvestor() => _buyBack(state, action.agreementId),
      InvestInMarketCompany() => _investInMarketCompany(state, action),
      AcquireMarketProduct() => _acquireProduct(state, action),
      AcquireMarketCompany() => _acquireCompany(state, action.companyId),
      TriggerSecurityIncident() => _triggerSecurityIncident(
        state,
        action.productId,
      ),
      ResolveCriticalEvent() => _resolveCriticalEvent(state),
      ToggleMiniGames() => state.copyWith(
        miniGamesEnabled: !state.miniGamesEnabled,
      ),
      ResetGame() => GameState.initial(),
    };
  }

  GameState _advanceTime(GameState state, int realSeconds) {
    if (state.paused || state.criticalEvent != CriticalEventType.none) {
      return state;
    }
    final deltaMinutes = realSeconds * state.speed.multiplier * 4;
    return _simulateMinutes(state, deltaMinutes);
  }

  GameState _skipNight(GameState state) {
    if (state.criticalEvent != CriticalEventType.none || state.gameOver) {
      return state;
    }
    final currentMinute = state.minuteOfDay;
    final nextMorning = currentMinute < 8 * 60
        ? state.simulationMinutes + (8 * 60 - currentMinute)
        : state.simulationMinutes + (24 * 60 - currentMinute) + 8 * 60;
    final simulated = _simulateMinutes(
      state.copyWith(paused: false),
      nextMorning - state.simulationMinutes,
    );
    if (simulated.criticalEvent != CriticalEventType.none) {
      return simulated;
    }
    return simulated.copyWith(paused: state.paused);
  }

  GameState _simulateMinutes(GameState state, int deltaMinutes) {
    if (deltaMinutes <= 0) {
      return state;
    }

    final monthFraction = deltaMinutes / 43200;
    var nextCounter = state.rngCounter;

    final updatedProducts = state.products
        .map((product) {
          final projection = ProductEstimator.estimate(
            blueprintId: product.blueprintId,
            frameworkId: product.frameworkId,
            languageIds: product.languageIds,
            technologyIds: product.technologyIds,
            featureIds: product.featureIds,
          );

          if (product.stage == ProductStage.development) {
            final gameHours = deltaMinutes / 60;
            final developmentCapacity = state.productDevelopmentCapacity(
              product.id,
            );
            final compressedWorkHours =
                gameHours * (3.5 + developmentCapacity / 14);
            final progressDelta =
                compressedWorkHours / projection.developmentHours;
            return product.copyWith(
              developmentProgress: math
                  .min(1, product.developmentProgress + progressDelta)
                  .toDouble(),
              monthlyCost: projection.monthlyTechCost,
            );
          }

          if (product.stage == ProductStage.failed) {
            return product.copyWith(monthlyRevenue: 0, monthlyGrowth: 0);
          }

          final load = state.productServerLoad(product);
          final overload = math.max(0, load - 0.82);
          final assignedTeam = state.employeesForProduct(product.id);
          final effectiveTeam = assignedTeam.isEmpty
              ? const <Employee>[]
              : assignedTeam;
          final teamQuality = _roleQualityForProduct(
            effectiveTeam,
            product.category,
          );
          final supportQuality = _roleAverage(
            effectiveTeam,
            const <EmployeeRole>[EmployeeRole.support, EmployeeRole.qa],
            (employee) => employee.quality,
          );
          final securityTeam = _roleAverage(effectiveTeam, const <EmployeeRole>[
            EmployeeRole.security,
            EmployeeRole.devOps,
          ], (employee) => employee.skill);
          final designerQuality = _roleAverage(
            effectiveTeam,
            const <EmployeeRole>[EmployeeRole.designer],
            (employee) => employee.quality,
          );
          final performanceLevel = state.improvementLevel(
            product.id,
            ProductImprovementType.performance,
          );
          final algorithmLevel = state.improvementLevel(
            product.id,
            ProductImprovementType.algorithms,
          );
          final designLevel = state.improvementLevel(
            product.id,
            ProductImprovementType.design,
          );
          final securityLevel = state.improvementLevel(
            product.id,
            ProductImprovementType.security,
          );
          final reliabilityLevel = state.improvementLevel(
            product.id,
            ProductImprovementType.reliability,
          );
          final performanceOption = ProductEvolutionCatalog.improvementByType(
            ProductImprovementType.performance,
          );
          final algorithmOption = ProductEvolutionCatalog.improvementByType(
            ProductImprovementType.algorithms,
          );
          final designOption = ProductEvolutionCatalog.improvementByType(
            ProductImprovementType.design,
          );
          final securityOption = ProductEvolutionCatalog.improvementByType(
            ProductImprovementType.security,
          );
          final reliabilityOption = ProductEvolutionCatalog.improvementByType(
            ProductImprovementType.reliability,
          );
          final freshnessPenalty = state.productStalenessPenalty(product);
          final aiQualityBonus = state.productAiQualityBoost(product.id);

          final speedMs =
              (projection.speedMs *
                      math.pow(
                        performanceOption.speedMultiplier,
                        performanceLevel,
                      ) *
                      (1 + overload * 1.8) *
                      (1 - math.min(0.18, teamQuality / 900)))
                  .clamp(45, 25000)
                  .toDouble();
          final designScore =
              (projection.designScore +
                      designerQuality * 0.08 +
                      designOption.designDelta * designLevel)
                  .clamp(5, 100)
                  .toDouble();
          final securityScore =
              (projection.securityScore +
                      securityTeam * 0.10 +
                      state.productSecurityBonus(product.id) +
                      securityOption.securityDelta * securityLevel +
                      reliabilityOption.securityDelta * reliabilityLevel)
                  .clamp(1, 100)
                  .toDouble();
          final reliability =
              (projection.reliability +
                      supportQuality / 12000 +
                      state.hardwareReliability * 0.018 +
                      state.productSecurityReliabilityBonus(product.id) +
                      reliabilityOption.reliabilityDelta * reliabilityLevel +
                      performanceOption.reliabilityDelta * performanceLevel +
                      algorithmOption.reliabilityDelta * algorithmLevel -
                      overload * 0.035)
                  .clamp(0.50, 0.9999)
                  .toDouble();

          final outcome = _marketOutcome(
            state: state,
            product: product,
            speedMs: speedMs,
            designScore: designScore,
            securityScore: securityScore,
            reliability: reliability,
            qualityBonus:
                aiQualityBonus +
                algorithmOption.qualityDelta * algorithmLevel +
                designOption.qualityDelta * designLevel +
                securityOption.qualityDelta * securityLevel +
                reliabilityOption.qualityDelta * reliabilityLevel,
            retentionBonus:
                algorithmOption.retentionDelta * algorithmLevel +
                designOption.retentionDelta * designLevel +
                securityOption.retentionDelta * securityLevel +
                reliabilityOption.retentionDelta * reliabilityLevel,
            freshnessPenalty: freshnessPenalty,
          );

          final publicAi =
              product.category != ProductCategory.aiAssistant ||
              state.aiDeploymentModeFor(product.id) ==
                  AiDeploymentMode.publicMarket;
          final potentialNewUsers =
              (publicAi ? outcome.monthlyNewUsers : 0) * monthFraction;
          final churnedUsers =
              product.users * outcome.churnRate * monthFraction;
          final nextUsers = math
              .max(
                0,
                (product.users + potentialNewUsers - churnedUsers).round(),
              )
              .toInt();
          final mau = math
              .min(nextUsers, (nextUsers * outcome.mauRatio).round())
              .toInt();
          final dau = math
              .min(mau, (mau * outcome.dauMauRatio).round())
              .toInt();
          final ecosystemBoost = state.ecosystemBoostFor(product.id);
          final revenue = publicAi
              ? _monthlyRevenue(
                  product: product,
                  mau: mau,
                  reliability: reliability,
                  ecosystemBoost: ecosystemBoost,
                )
              : 0.0;
          final rating = (outcome.qualityScore / 20).clamp(1.0, 5.0).toDouble();

          return product.copyWith(
            users: nextUsers,
            dau: dau,
            mau: mau,
            activationRate: outcome.activationRate,
            retention30d: outcome.retention30d,
            churnRate: outcome.churnRate,
            rating: rating,
            speedMs: speedMs,
            designScore: designScore,
            securityScore: securityScore,
            reliability: reliability,
            featureCoverage: outcome.featureCoverage,
            qualityScore: outcome.qualityScore,
            monthlyRevenue: revenue,
            monthlyCost: projection.monthlyTechCost + product.marketingBudget,
            monthlyGrowth:
                (publicAi ? outcome.monthlyNewUsers : 0) -
                product.users * outcome.churnRate,
          );
        })
        .toList(growable: false);

    var next = state.copyWith(
      simulationMinutes: state.simulationMinutes + deltaMinutes,
      products: updatedProducts,
      rngCounter: nextCounter,
    );
    final cashDelta = next.monthlyProfit * monthFraction;
    next = next.copyWith(cash: next.cash + cashDelta);
    next = _advanceClientContracts(next, deltaMinutes);

    if (next.products.any(
          (product) =>
              product.stage == ProductStage.live &&
              next.productServerLoad(product) > 1.35,
        ) &&
        next.criticalEvent == CriticalEventType.none) {
      final overloaded = next.products.firstWhere(
        (product) =>
            product.stage == ProductStage.live &&
            next.productServerLoad(product) > 1.35,
      );
      next = _withNews(
        next.copyWith(
          criticalEvent: CriticalEventType.serverOverload,
          criticalProductId: overloaded.id,
          paused: true,
        ),
        NewsItem(
          id: 'overload_${next.simulationMinutes}_${overloaded.id}',
          kind: NewsKind.infrastructure,
          title: 'Перегрузка ${overloaded.name}',
          body:
              'Продукт использует ${(next.productServerLoad(overloaded) * 100).round()}% выделенной мощности. Скорость и uptime падают.',
          simulationMinutes: next.simulationMinutes,
          critical: true,
        ),
      );
      return _withFeed(
        next,
        'Критическая перегрузка ${overloaded.name}: симуляция остановлена.',
      );
    }

    final oldDay = state.simulationMinutes ~/ (24 * 60);
    final newDay = next.simulationMinutes ~/ (24 * 60);
    if (newDay > oldDay && next.criticalEvent == CriticalEventType.none) {
      for (var day = oldDay + 1; day <= newDay; day += 1) {
        final dailyResult = _dailyEvents(next, day, nextCounter);
        next = dailyResult.state;
        nextCounter = dailyResult.counter;
        if (next.criticalEvent != CriticalEventType.none) {
          break;
        }
      }
      next = next.copyWith(rngCounter: nextCounter);
    }

    if (next.founderOwnershipPercent < 50 && !next.gameOver) {
      next = _withNews(
        next.copyWith(
          criticalEvent: CriticalEventType.lostControl,
          paused: true,
          gameOver: true,
        ),
        NewsItem(
          id: 'lost_control_${next.simulationMinutes}',
          kind: NewsKind.funding,
          title: 'Основатель потерял контроль',
          body:
              'Доля основателя упала ниже 50%. Совет инвесторов получил контроль над компанией.',
          simulationMinutes: next.simulationMinutes,
          critical: true,
        ),
      );
    }

    return next;
  }

  GameState _advanceClientContracts(GameState state, int deltaMinutes) {
    if (state.activeContracts.isEmpty || deltaMinutes <= 0) {
      return state;
    }
    var cashDelta = 0.0;
    final messages = <String>[];
    final updated = state.clientContracts
        .map((contract) {
          if (contract.status != ContractStatus.active) {
            return contract;
          }
          final template = ContractCatalog.byId(contract.templateId);
          final roleCoverage = state.contractRoleCoverage(template);
          final parallelLoad = math.max(1, state.activeContracts.length);
          final effectiveCapacity =
              state.contractDevelopmentCapacity *
              (0.45 + roleCoverage * 0.55) /
              parallelLoad;
          final previousMinutes = state.simulationMinutes - deltaMinutes;
          final minutesBeforeDeadline = math.max(
            0,
            contract.deadlineAtMinutes - previousMinutes,
          );
          final workableMinutes = math.min(deltaMinutes, minutesBeforeDeadline);
          final gameHours = workableMinutes / 60;
          final progressDelta =
              gameHours *
              (0.30 + effectiveCapacity / 80) /
              template.developmentHours;
          final nextProgress = math
              .min(1, contract.progress + progressDelta)
              .toDouble();
          if (nextProgress >= 1) {
            final remainingReward =
                contract.reward * (1 - template.upfrontPercent);
            cashDelta += remainingReward;
            messages.add(
              '${template.client}: контракт «${template.name}» завершён. Получено ${remainingReward.round()} ₽.',
            );
            return contract.copyWith(
              status: ContractStatus.completed,
              progress: 1,
            );
          }
          if (state.simulationMinutes >= contract.deadlineAtMinutes) {
            final penalty = contract.reward * 0.10;
            cashDelta -= penalty;
            messages.add(
              '${template.client}: срок «${template.name}» сорван. Штраф ${penalty.round()} ₽.',
            );
            return contract.copyWith(status: ContractStatus.failed);
          }
          return contract.copyWith(progress: nextProgress);
        })
        .toList(growable: false);

    var next = state.copyWith(
      cash: state.cash + cashDelta,
      clientContracts: updated,
    );
    for (final message in messages) {
      next = _withFeed(next, message);
    }
    return next;
  }

  _DailyResult _dailyEvents(GameState state, int day, int counter) {
    var next = state;
    var nextCounter = counter;

    if (day % 4 == 0) {
      final competitor =
          GameCatalog.competitors[day % GameCatalog.competitors.length];
      next = _withNews(
        next,
        NewsItem(
          id: 'competitor_${day}_${competitor.id}',
          kind: NewsKind.competitor,
          title: '${competitor.productName}: новое обновление',
          body:
              '${competitor.companyName} усилила продукт. Скорость ${competitor.speedMs.round()} ms, security ${competitor.securityScore.round()}/100.',
          simulationMinutes: next.simulationMinutes,
          critical: false,
        ),
      );
    }

    final liveProducts = next.products
        .where((product) => product.stage == ProductStage.live)
        .toList(growable: false);
    if (liveProducts.isEmpty) {
      return _DailyResult(next, nextCounter);
    }

    if (day % 7 == 0 && next.investorOffers.isEmpty) {
      final inbound = _maybeGenerateInboundOffer(
        next,
        liveProducts,
        nextCounter,
      );
      next = inbound.state;
      nextCounter = inbound.counter;
    }

    final risky = List<Product>.of(liveProducts)
      ..sort((a, b) => a.securityScore.compareTo(b.securityScore));
    final target = risky.first;
    final random = _random01(next.rngSeed, nextCounter++);
    final categoryRisk = target.category == ProductCategory.cryptoWallet
        ? 0.055
        : 0.0;
    final securityRisk = (100 - target.securityScore) / 650;
    final scaleRisk = math.min(0.035, target.users / 12000000);
    final physicalProtection =
        next.serverRoom.physicalSecurityScore / 100 * 0.025;
    final chance =
        (math.max(
                  0.002,
                  0.008 +
                      categoryRisk +
                      securityRisk +
                      scaleRisk -
                      physicalProtection,
                ) *
                next.productIncidentMultiplier(target.id))
            .clamp(0.0005, 0.45)
            .toDouble();

    if (random < chance) {
      next = _triggerSecurityIncident(next, target.id);
    }
    return _DailyResult(next, nextCounter);
  }

  _DailyResult _maybeGenerateInboundOffer(
    GameState state,
    List<Product> liveProducts,
    int counter,
  ) {
    final ranked = List<Product>.of(liveProducts)
      ..sort((a, b) {
        final aScore =
            a.qualityScore +
            a.featureCoverage * 35 +
            math.min(30, a.users / 2500);
        final bScore =
            b.qualityScore +
            b.featureCoverage * 35 +
            math.min(30, b.users / 2500);
        return bScore.compareTo(aScore);
      });
    final product = ranked.first;
    final successScore =
        (product.qualityScore / 100 * 0.42 +
                product.featureCoverage * 0.24 +
                math.min(1, product.users / 50000) * 0.24 +
                math.min(1, state.successfulProducts / 4) * 0.10)
            .clamp(0, 1)
            .toDouble();
    final interestChance = (0.06 + successScore * 0.60)
        .clamp(0.06, 0.82)
        .toDouble();
    final interestRoll = _random01(state.rngSeed, counter++);
    if (interestRoll >= interestChance) {
      return _DailyResult(state, counter);
    }

    final candidates = GameCatalog.investors
        .where(
          (investor) =>
              investor.preferredCategories.contains(product.category) &&
              !state.investorAgreements.any(
                (agreement) => agreement.investorId == investor.id,
              ) &&
              !state.investorOffers.any(
                (offer) => offer.investorId == investor.id,
              ),
        )
        .toList(growable: false);
    if (candidates.isEmpty) {
      return _DailyResult(state, counter);
    }

    final investorRoll = _random01(state.rngSeed, counter++);
    final investorIndex = (investorRoll * candidates.length)
        .floor()
        .clamp(0, candidates.length - 1)
        .toInt();
    final investor = candidates[investorIndex];
    final readiness =
        (product.qualityScore / 100 * 0.55 +
                product.featureCoverage * 0.20 +
                math.min(1, product.users / 50000) * 0.25)
            .clamp(0, 1)
            .toDouble();
    final productRisk =
        (state.productSecurityRisk(product) * 0.70 +
                (1 - product.featureCoverage) * 0.25)
            .clamp(0, 1)
            .toDouble();
    if (readiness + state.successfulProducts * 0.04 <
            investor.minimumReadiness ||
        productRisk > investor.riskTolerance + 0.18) {
      return _DailyResult(state, counter);
    }

    final desiredAmount = math
        .max(250000, state.valuation * (0.025 + successScore * 0.035))
        .toDouble();
    final offeredAmount = math
        .min(desiredAmount, investor.availableCapital)
        .toDouble();
    final riskPremium = 1 + productRisk * (1.3 - investor.riskTolerance);
    final equity = (offeredAmount / state.valuation * 100 * riskPremium)
        .clamp(2.5, investor.maximumEquityPercent)
        .toDouble();
    final revenueShare = (1.5 + productRisk * 6.5).clamp(1.5, 8).toDouble();
    final offer = InvestorOffer(
      id: 'inbound_${investor.id}_${state.simulationMinutes}_$counter',
      investorId: investor.id,
      productId: product.id,
      requestedAmount: desiredAmount,
      offeredAmount: offeredAmount,
      equityPercent: equity,
      revenueSharePercent: revenueShare,
      createdAtMinutes: state.simulationMinutes,
    );
    final next = _withNews(
      _withFeed(
        state.copyWith(
          investorOffers: <InvestorOffer>[...state.investorOffers, offer],
        ),
        '${investor.name} сам вышел на компанию после результатов ${product.name}.',
      ),
      NewsItem(
        id: 'inbound_offer_${offer.id}',
        kind: NewsKind.funding,
        title: 'Инвестор заинтересовался ${product.name}',
        body:
            '${investor.name} предлагает ${offeredAmount.round()} ₽ за ${equity.toStringAsFixed(1)}% компании и ${revenueShare.toStringAsFixed(1)}% выручки продукта.',
        simulationMinutes: state.simulationMinutes,
        critical: false,
      ),
    );
    return _DailyResult(next, counter);
  }

  GameState _createProduct(GameState state, CreateConfiguredProduct action) {
    if (action.name.trim().isEmpty ||
        action.languageIds.isEmpty ||
        action.featureIds.isEmpty ||
        state.products.length >= 10) {
      return state;
    }

    final blueprint = GameCatalog.blueprintById(action.blueprintId);
    final framework = GameCatalog.frameworkById(action.frameworkId);
    if (!framework.supportedCategories.contains(blueprint.category)) {
      return state;
    }
    final validFeatures = action.featureIds.every(
      (id) => GameCatalog.featureById(
        id,
      ).supportedCategories.contains(blueprint.category),
    );
    if (!validFeatures) {
      return state;
    }

    final projection = ProductEstimator.estimate(
      blueprintId: action.blueprintId,
      frameworkId: action.frameworkId,
      languageIds: action.languageIds,
      technologyIds: action.technologyIds,
      featureIds: action.featureIds,
    );
    if (state.cash < projection.developmentCost) {
      return _withFeed(
        state,
        'Недостаточно денег: разработка стоит ${projection.developmentCost.round()} ₽.',
      );
    }

    final sequence = state.rngCounter + 1;
    final freePercent = math.max(0, 100 - state.totalAllocatedPercent);
    final initialAllocation = math.min(30, freePercent).toDouble();
    final product = Product(
      id: '${action.blueprintId}_$sequence',
      blueprintId: action.blueprintId,
      name: action.name.trim(),
      category: blueprint.category,
      stage: ProductStage.development,
      frameworkId: action.frameworkId,
      languageIds: List<String>.unmodifiable(action.languageIds),
      technologyIds: List<String>.unmodifiable(action.technologyIds),
      featureIds: List<String>.unmodifiable(action.featureIds),
      developmentProgress: 0,
      users: 0,
      dau: 0,
      mau: 0,
      activationRate: 0,
      retention30d: 0,
      churnRate: 0,
      rating: 0,
      speedMs: projection.speedMs,
      designScore: projection.designScore,
      securityScore: projection.securityScore,
      reliability: projection.reliability,
      featureCoverage: projection.featureCoverage,
      qualityScore: projection.qualityScore,
      monthlyRevenue: 0,
      monthlyCost: projection.monthlyTechCost,
      monthlyGrowth: 0,
      price: blueprint.basePrice,
      monetization: blueprint.category == ProductCategory.browser
          ? MonetizationModel.advertising
          : blueprint.category == ProductCategory.cryptoWallet
          ? MonetizationModel.transactionFee
          : MonetizationModel.subscription,
      marketingBudget: 0,
      allocatedCapacityPercent: initialAllocation,
      computeMultiplier: projection.computeMultiplier,
      createdAtMinutes: state.simulationMinutes,
      acquired: false,
    );

    return _withNews(
      _withFeed(
        state.copyWith(
          cash: state.cash - projection.developmentCost,
          products: <Product>[...state.products, product],
          productUpdates: <ProductUpdateRecord>[
            ...state.productUpdates,
            ProductUpdateRecord(
              productId: product.id,
              updatedAtMinutes: state.simulationMinutes,
              reason: 'Создание продукта',
            ),
          ],
          rngCounter: sequence,
        ),
        '${product.name}: выбран стек и запущена разработка за ${projection.developmentCost.round()} ₽.',
      ),
      NewsItem(
        id: 'product_created_${product.id}',
        kind: NewsKind.product,
        title: 'Новый продукт в разработке',
        body:
            '${product.name}: ${framework.name}, ${action.featureIds.length} функций, прогноз качества ${projection.qualityScore.round()}/100.',
        simulationMinutes: state.simulationMinutes,
        critical: false,
      ),
    );
  }

  GameState _launchProduct(GameState state, String productId) {
    final product = state.productById(productId);
    if (product == null ||
        product.stage != ProductStage.development ||
        product.developmentProgress < 1 ||
        product.allocatedCapacityPercent <= 0) {
      return state;
    }
    final updated = state.products
        .map(
          (item) => item.id == productId
              ? item.copyWith(
                  stage: ProductStage.live,
                  users: 120,
                  mau: 90,
                  dau: 24,
                  activationRate: 0.32,
                  retention30d: 0.38,
                  churnRate: 0.12,
                  rating: math.max(2.5, item.qualityScore / 20).toDouble(),
                )
              : item,
        )
        .toList(growable: false);
    return _withNews(
      _withFeed(
        state.copyWith(
          products: updated,
          productUpdates: <ProductUpdateRecord>[
            ...state.productUpdates,
            ProductUpdateRecord(
              productId: product.id,
              updatedAtMinutes: state.simulationMinutes,
              reason: 'Публичный запуск',
            ),
          ],
        ),
        '${product.name} выпущен. Рынок сравнивает его с прямым конкурентом.',
      ),
      NewsItem(
        id: 'launch_$productId',
        kind: NewsKind.product,
        title: '${product.name} вышел на рынок',
        body:
            'Первые пользователи оценивают скорость, дизайн, безопасность и полноту функций.',
        simulationMinutes: state.simulationMinutes,
        critical: false,
      ),
    );
  }

  GameState _addProductFeature(
    GameState state,
    String productId,
    String featureId,
  ) {
    final product = state.productById(productId);
    if (product == null ||
        product.stage == ProductStage.failed ||
        product.featureIds.contains(featureId)) {
      return state;
    }

    final feature = GameCatalog.featureById(featureId);
    if (!feature.supportedCategories.contains(product.category)) {
      return state;
    }

    final implementationCost =
        feature.developmentCost *
        (product.stage == ProductStage.live ? 1.25 : 1.0);
    if (state.cash < implementationCost) {
      return _withFeed(
        state,
        '${product.name}: для ${feature.name} нужно ${implementationCost.round()} ₽.',
      );
    }

    final featureIds = <String>[...product.featureIds, featureId];
    final projection = ProductEstimator.estimate(
      blueprintId: product.blueprintId,
      frameworkId: product.frameworkId,
      languageIds: product.languageIds,
      technologyIds: product.technologyIds,
      featureIds: featureIds,
    );
    final updatedProducts = state.products
        .map(
          (item) => item.id == productId
              ? item.copyWith(
                  featureIds: featureIds,
                  speedMs: projection.speedMs,
                  designScore: projection.designScore,
                  securityScore: projection.securityScore,
                  reliability: projection.reliability,
                  featureCoverage: projection.featureCoverage,
                  qualityScore: projection.qualityScore,
                  monthlyCost:
                      projection.monthlyTechCost + item.marketingBudget,
                  computeMultiplier: projection.computeMultiplier,
                )
              : item,
        )
        .toList(growable: false);

    return _withNews(
      _withFeed(
        state.copyWith(
          cash: state.cash - implementationCost,
          products: updatedProducts,
          productUpdates: <ProductUpdateRecord>[
            ...state.productUpdates,
            ProductUpdateRecord(
              productId: product.id,
              updatedAtMinutes: state.simulationMinutes,
              reason: 'Функция: ${feature.name}',
            ),
          ],
        ),
        '${product.name}: добавлена функция ${feature.name} за ${implementationCost.round()} ₽.',
      ),
      NewsItem(
        id: 'feature_${product.id}_${feature.id}_${state.simulationMinutes}',
        kind: NewsKind.product,
        title: '${product.name}: обновление',
        body:
            '${feature.name} повышает покрытие ожиданий и меняет технические метрики продукта.',
        simulationMinutes: state.simulationMinutes,
        critical: false,
      ),
    );
  }

  GameState _setAiDeploymentMode(
    GameState state,
    String productId,
    AiDeploymentMode mode,
  ) {
    final product = state.productById(productId);
    if (product == null || product.category != ProductCategory.aiAssistant) {
      return state;
    }
    final deployments =
        state.productAiDeployments
            .where((item) => item.productId != productId)
            .toList(growable: true)
          ..add(ProductAiDeployment(productId: productId, mode: mode));
    final integrations = mode == AiDeploymentMode.corporate
        ? state.productAiIntegrations
        : state.productAiIntegrations
              .where((item) => item.aiProductId != productId)
              .toList(growable: false);
    final products = mode == AiDeploymentMode.corporate
        ? state.products
              .map(
                (item) => item.id == productId
                    ? item.copyWith(
                        marketingBudget: 0,
                        monthlyCost: math
                            .max(0, item.monthlyCost - item.marketingBudget)
                            .toDouble(),
                      )
                    : item,
              )
              .toList(growable: false)
        : state.products;
    return _withFeed(
      state.copyWith(
        products: products,
        productAiDeployments: deployments,
        productAiIntegrations: integrations,
      ),
      mode == AiDeploymentMode.corporate
          ? '${product.name}: AI переведена во внутренний корпоративный режим.'
          : '${product.name}: AI выведена на публичный рынок.',
    );
  }

  GameState _connectCorporateAi(
    GameState state,
    String aiProductId,
    String targetProductId,
  ) {
    final ai = state.productById(aiProductId);
    final target = state.productById(targetProductId);
    if (ai == null ||
        target == null ||
        ai.id == target.id ||
        ai.category != ProductCategory.aiAssistant ||
        ai.stage != ProductStage.live ||
        target.stage == ProductStage.failed ||
        state.aiDeploymentModeFor(ai.id) != AiDeploymentMode.corporate) {
      return state;
    }
    final integrations =
        state.productAiIntegrations
            .where((item) => item.targetProductId != targetProductId)
            .toList(growable: true)
          ..add(
            ProductAiIntegration(
              aiProductId: ai.id,
              targetProductId: target.id,
              connectedAtMinutes: state.simulationMinutes,
            ),
          );
    return _withFeed(
      state.copyWith(productAiIntegrations: integrations),
      '${ai.name} подключена к ${target.name}: +18% development capacity, +4 quality и дополнительная нагрузка на серверы.',
    );
  }

  GameState _disconnectCorporateAi(GameState state, String targetProductId) {
    final target = state.productById(targetProductId);
    final next = state.productAiIntegrations
        .where((item) => item.targetProductId != targetProductId)
        .toList(growable: false);
    if (next.length == state.productAiIntegrations.length) {
      return state;
    }
    return _withFeed(
      state.copyWith(productAiIntegrations: next),
      '${target?.name ?? 'Продукт'}: корпоративная AI отключена.',
    );
  }

  GameState _applyProductImprovement(
    GameState state,
    String productId,
    ProductImprovementType type,
  ) {
    final product = state.productById(productId);
    if (product == null || product.stage == ProductStage.failed) {
      return state;
    }
    if (product.stage != ProductStage.live) {
      return _withFeed(
        state,
        '${product.name}: постоянные технические улучшения доступны только после выхода на рынок.',
      );
    }
    final option = ProductEvolutionCatalog.improvementByType(type);
    final currentLevel = state.improvementLevel(productId, type);
    final cost = state.improvementCost(productId, type);
    if (state.cash < cost) {
      return _withFeed(
        state,
        '${product.name}: для «${option.name}» нужно ${cost.round()} ₽.',
      );
    }
    final level = currentLevel + 1;
    final record = ProductImprovementRecord(
      productId: productId,
      type: type,
      level: level,
      appliedAtMinutes: state.simulationMinutes,
    );
    final updatedProducts = state.products
        .map(
          (item) => item.id == productId
              ? item.copyWith(
                  speedMs: item.speedMs * option.speedMultiplier,
                  designScore: math
                      .min(100, item.designScore + option.designDelta)
                      .toDouble(),
                  securityScore: math
                      .min(100, item.securityScore + option.securityDelta)
                      .toDouble(),
                  reliability: math
                      .min(0.9999, item.reliability + option.reliabilityDelta)
                      .toDouble(),
                  qualityScore: math
                      .min(100, item.qualityScore + option.qualityDelta)
                      .toDouble(),
                )
              : item,
        )
        .toList(growable: false);
    return _withNews(
      _withFeed(
        state.copyWith(
          cash: state.cash - cost,
          products: updatedProducts,
          productImprovements: <ProductImprovementRecord>[
            ...state.productImprovements,
            record,
          ],
          productUpdates: <ProductUpdateRecord>[
            ...state.productUpdates,
            ProductUpdateRecord(
              productId: productId,
              updatedAtMinutes: state.simulationMinutes,
              reason: '${option.name} L$level',
            ),
          ],
        ),
        '${product.name}: ${option.name}, уровень $level. Продукт снова считается свежим.',
      ),
      NewsItem(
        id: 'continuous_${product.id}_${type.name}_${state.simulationMinutes}',
        kind: NewsKind.product,
        title: '${product.name}: техническое обновление',
        body:
            '${option.name} достигло уровня $level. Стоимость следующей итерации вырастет.',
        simulationMinutes: state.simulationMinutes,
        critical: false,
      ),
    );
  }

  GameState _setMonetization(
    GameState state,
    String productId,
    MonetizationModel model,
  ) {
    final product = state.productById(productId);
    if (product == null || product.monetization == model) {
      return state;
    }
    return _withFeed(
      state.copyWith(
        products: state.products
            .map(
              (item) => item.id == productId
                  ? item.copyWith(monetization: model)
                  : item,
            )
            .toList(growable: false),
      ),
      '${product.name}: монетизация изменена на ${_monetizationName(model)}.',
    );
  }

  GameState _setProductPrice(GameState state, String productId, double price) {
    final product = state.productById(productId);
    if (product == null || product.stage != ProductStage.live) {
      return _withFeed(
        state,
        'Цена подписки меняется только у выпущенного продукта.',
      );
    }
    if (product.monetization != MonetizationModel.subscription) {
      return _withFeed(
        state,
        '${product.name}: сначала выберите модель «Подписка».',
      );
    }
    final blueprint = GameCatalog.blueprintById(product.blueprintId);
    final minimum = math.max(49, blueprint.basePrice * 0.25).toDouble();
    final maximum = math.max(minimum, blueprint.basePrice * 4).toDouble();
    final normalized = price.clamp(minimum, maximum).toDouble();
    return _withFeed(
      state.copyWith(
        products: state.products
            .map(
              (item) => item.id == productId
                  ? item.copyWith(price: normalized)
                  : item,
            )
            .toList(growable: false),
      ),
      '${product.name}: цена подписки ${normalized.round()} ₽/мес.',
    );
  }

  GameState _setMarketingBudget(
    GameState state,
    String productId,
    double monthlyBudget,
  ) {
    final product = state.productById(productId);
    if (product == null || monthlyBudget < 0 || monthlyBudget > 3000000) {
      return state;
    }
    return _withFeed(
      state.copyWith(
        products: state.products
            .map(
              (item) => item.id == productId
                  ? item.copyWith(
                      marketingBudget: monthlyBudget,
                      monthlyCost: math
                          .max(
                            0,
                            item.monthlyCost -
                                item.marketingBudget +
                                monthlyBudget,
                          )
                          .toDouble(),
                    )
                  : item,
            )
            .toList(growable: false),
      ),
      '${product.name}: рекламный бюджет ${monthlyBudget.round()} ₽/мес. Реклама не компенсирует слабый продукт.',
    );
  }

  GameState _setAllocation(GameState state, String productId, double percent) {
    final product = state.productById(productId);
    if (product == null || percent < 0 || percent > 100) {
      return state;
    }
    final otherTotal = state.products
        .where((item) => item.id != productId)
        .fold<double>(0, (sum, item) => sum + item.allocatedCapacityPercent);
    if (otherTotal + percent > 100.0001) {
      return _withFeed(
        state,
        'Нельзя выделить ${percent.round()}%: свободно ${(100 - otherTotal).round()}%.',
      );
    }
    return state.copyWith(
      products: state.products
          .map(
            (item) => item.id == productId
                ? item.copyWith(allocatedCapacityPercent: percent)
                : item,
          )
          .toList(growable: false),
    );
  }

  GameState _hireCandidate(GameState state, String candidateId) {
    final candidate = state.candidateById(candidateId);
    if (candidate == null) {
      return state;
    }
    if (!candidate.remote &&
        state.onSiteEmployeeCount >= state.office.capacity) {
      return _withFeed(
        state,
        'Найм заблокирован: все ${state.office.capacity} офисных мест заняты. Remote-кандидаты по-прежнему доступны.',
      );
    }
    final employerBrandDiscount = state.office.hiringBoostPercent
        .clamp(0, 0.45)
        .toDouble();
    final signingBonus = candidate.salary * 0.35 * (1 - employerBrandDiscount);
    if (state.cash < signingBonus) {
      return state;
    }
    return _withFeed(
      state.copyWith(
        cash: state.cash - signingBonus,
        candidates: state.candidates
            .where((item) => item.id != candidateId)
            .toList(growable: false),
        employees: <Employee>[...state.employees, candidate.toEmployee()],
      ),
      '${candidate.name} принят. Зарплата ${candidate.salary.round()} ₽/мес., signing bonus ${signingBonus.round()} ₽.',
    );
  }

  GameState _assignEmployee(
    GameState state,
    String employeeId,
    String? productId,
  ) {
    final employee = state.employeeById(employeeId);
    if (employee == null) {
      return state;
    }
    if (productId != null && state.productById(productId) == null) {
      return state;
    }

    final assignments = state.employeeAssignments
        .where((item) => item.employeeId != employeeId)
        .toList(growable: true);
    if (productId != null) {
      assignments.add(
        EmployeeAssignment(
          employeeId: employeeId,
          productId: productId,
          assignedAtMinutes: state.simulationMinutes,
        ),
      );
    }

    final updatedEmployees = state.employees
        .map(
          (item) => item.id == employeeId
              ? item.managedCopyWith(
                  workload: productId == null ? 20 : 78,
                  morale: productId == null
                      ? math.min(100, item.morale + 2).toInt()
                      : item.morale,
                )
              : item,
        )
        .toList(growable: false);
    final targetName = productId == null
        ? 'резерв команды'
        : state.productById(productId)!.name;
    return _withFeed(
      state.copyWith(
        employees: updatedEmployees,
        employeeAssignments: assignments,
      ),
      '${employee.name}: назначение изменено — $targetName.',
    );
  }

  GameState _fireEmployee(GameState state, String employeeId) {
    final employee = state.employeeById(employeeId);
    if (employee == null) {
      return state;
    }
    final severance = employee.salary * 0.5;
    if (state.cash < severance) {
      return _withFeed(
        state,
        'Для увольнения ${employee.name} нужна компенсация ${severance.round()} ₽.',
      );
    }
    return _withFeed(
      state.copyWith(
        cash: state.cash - severance,
        employees: state.employees
            .where((item) => item.id != employeeId)
            .toList(growable: false),
        employeeAssignments: state.employeeAssignments
            .where((item) => item.employeeId != employeeId)
            .toList(growable: false),
      ),
      '${employee.name} покинул компанию. Выплачено ${severance.round()} ₽.',
    );
  }

  GameState _giveRaise(GameState state, String employeeId, double percent) {
    final employee = state.employeeById(employeeId);
    if (employee == null || percent < 5 || percent > 30) {
      return state;
    }
    final newSalary = employee.salary * (1 + percent / 100);
    final retentionBonus = newSalary - employee.salary;
    if (state.cash < retentionBonus) {
      return state;
    }
    return _withFeed(
      state.copyWith(
        cash: state.cash - retentionBonus,
        employees: state.employees
            .map(
              (item) => item.id == employeeId
                  ? item.managedCopyWith(
                      salary: newSalary,
                      loyalty: math.min(100, item.loyalty + 7).toInt(),
                      morale: math.min(100, item.morale + 6).toInt(),
                    )
                  : item,
            )
            .toList(growable: false),
      ),
      '${employee.name}: зарплата повышена на ${percent.round()}% до ${newSalary.round()} ₽/мес.',
    );
  }

  GameState _trainEmployee(
    GameState state,
    String employeeId,
    String programId,
  ) {
    final employee = state.employeeById(employeeId);
    final program = OperationsCatalog.trainingProgramById(programId);
    if (employee == null || state.cash < program.cost) {
      return state;
    }
    final updated = employee.managedCopyWith(
      skill: math.min(100, employee.skill + program.skillDelta).toInt(),
      speed: math.min(100, employee.speed + program.speedDelta).toInt(),
      quality: math.min(100, employee.quality + program.qualityDelta).toInt(),
      autonomy: math
          .min(100, employee.autonomy + program.autonomyDelta)
          .toInt(),
      communication: math
          .min(100, employee.communication + program.communicationDelta)
          .toInt(),
      reliability: math
          .min(100, employee.reliability + program.reliabilityDelta)
          .toInt(),
      morale: math.min(100, employee.morale + 3).toInt(),
    );
    return _withFeed(
      state.copyWith(
        cash: state.cash - program.cost,
        employees: state.employees
            .map((item) => item.id == employeeId ? updated : item)
            .toList(growable: false),
      ),
      '${employee.name} завершил программу «${program.name}» за ${program.cost.round()} ₽.',
    );
  }

  GameState _purchaseSecurityControl(
    GameState state,
    String productId,
    String controlId,
  ) {
    final product = state.productById(productId);
    final control = OperationsCatalog.securityControlById(controlId);
    if (product == null ||
        product.stage == ProductStage.failed ||
        state.hasSecurityControl(productId, controlId)) {
      return state;
    }
    if (state.cash < control.setupCost) {
      return _withFeed(
        state,
        '${product.name}: внедрение ${control.name} стоит ${control.setupCost.round()} ₽.',
      );
    }
    final deployment = ProductSecurityControl(
      productId: productId,
      controlId: controlId,
      installedAtMinutes: state.simulationMinutes,
    );
    return _withNews(
      _withFeed(
        state.copyWith(
          cash: state.cash - control.setupCost,
          securityControls: <ProductSecurityControl>[
            ...state.securityControls,
            deployment,
          ],
        ),
        '${product.name}: внедрён ${control.name}. Риск атаки пересчитан.',
      ),
      NewsItem(
        id: 'security_control_${product.id}_${control.id}_${state.simulationMinutes}',
        kind: NewsKind.security,
        title: '${product.name}: усилена безопасность',
        body:
            '${control.name}: +${control.securityDelta.round()} security, ${control.monthlyCost.round()} ₽/мес.',
        simulationMinutes: state.simulationMinutes,
        critical: false,
      ),
    );
  }

  GameState _runSecurityAudit(GameState state, String productId) {
    final product = state.productById(productId);
    const auditCost = 75000.0;
    if (product == null || state.cash < auditCost) {
      return state;
    }
    final risk = state.productSecurityRisk(product);
    final findings = math.max(0, (risk * 12).round() - 1).toInt();
    final audit = SecurityAuditRecord(
      productId: productId,
      simulationMinutes: state.simulationMinutes,
      riskPercent: risk * 100,
      findingsCount: findings,
    );
    return _withFeed(
      state.copyWith(
        cash: state.cash - auditCost,
        securityAudits: <SecurityAuditRecord>[...state.securityAudits, audit],
      ),
      '${product.name}: аудит завершён. Риск ${(risk * 100).toStringAsFixed(1)}%, найдено проблем: $findings.',
    );
  }

  GameState _rentOffice(GameState state, String officeId) {
    if (state.selectedOfficeId == officeId) {
      return state;
    }
    final office = GameCatalog.officeById(officeId);
    if (office.capacity < state.onSiteEmployeeCount ||
        state.cash < office.deposit) {
      return state;
    }
    return _withFeed(
      state.copyWith(
        selectedOfficeId: officeId,
        cash: state.cash - office.deposit,
      ),
      'Арендован ${office.name}: ${office.capacity} мест, комфорт ${office.comfortScore}/100.',
    );
  }

  GameState _rentServerRoom(GameState state, String roomId) {
    if (state.selectedServerRoomId == roomId) {
      return state;
    }
    final room = GameCatalog.serverRoomById(roomId);
    if (state.usedRackUnits > room.rackUnits ||
        state.usedCoolingKw > room.coolingKw ||
        state.usedPowerKw > room.powerKw ||
        state.cash < room.deposit) {
      return state;
    }
    return _withFeed(
      state.copyWith(
        selectedServerRoomId: roomId,
        cash: state.cash - room.deposit,
      ),
      'Арендована серверная ${room.name}: ${room.rackUnits}U, охлаждение ${room.coolingKw} кВт.',
    );
  }

  GameState _installServer(GameState state, String hardwareId) {
    final hardware = GameCatalog.serverHardwareById(hardwareId);
    if (state.cash < hardware.purchaseCost) {
      return state;
    }
    final nextRack = state.usedRackUnits + hardware.rackUnits;
    final nextCooling = state.usedCoolingKw + hardware.heatKw;
    final nextPower = state.usedPowerKw + hardware.powerKw;
    if (nextRack > state.serverRoom.rackUnits ||
        nextCooling > state.serverRoom.coolingKw ||
        nextPower > state.serverRoom.powerKw) {
      return _withFeed(
        state,
        'Нельзя установить ${hardware.name}: серверная не выдержит rack/power/cooling.',
      );
    }
    final current = state.installedCount(hardwareId);
    final installed = <InstalledServer>[
      ...state.installedServers.where((item) => item.hardwareId != hardwareId),
      InstalledServer(hardwareId: hardwareId, count: current + 1),
    ];
    return _withFeed(
      state.copyWith(
        installedServers: installed,
        cash: state.cash - hardware.purchaseCost,
      ),
      '${hardware.name} установлен: +${hardware.computeUnits.round()} compute units.',
    );
  }

  GameState _removeServer(GameState state, String hardwareId) {
    final current = state.installedCount(hardwareId);
    if (current <= 0) {
      return state;
    }
    final installed = <InstalledServer>[];
    for (final item in state.installedServers) {
      if (item.hardwareId != hardwareId) {
        installed.add(item);
      } else if (item.count > 1) {
        installed.add(item.copyWith(count: item.count - 1));
      }
    }
    return state.copyWith(installedServers: installed);
  }

  GameState _connectProducts(
    GameState state,
    String firstProductId,
    String secondProductId,
  ) {
    if (firstProductId == secondProductId ||
        state.productById(firstProductId) == null ||
        state.productById(secondProductId) == null ||
        state.hasLink(firstProductId, secondProductId) ||
        state.cash < 85000) {
      return state;
    }
    final first = state.productById(firstProductId)!;
    final second = state.productById(secondProductId)!;
    return _withFeed(
      state.copyWith(
        cash: state.cash - 85000,
        ecosystemLinks: <EcosystemLink>[
          ...state.ecosystemLinks,
          EcosystemLink(firstProductId, secondProductId),
        ],
      ),
      '${first.name} ↔ ${second.name}: связь создана. Оба продукта сохраняют собственных пользователей и выручку.',
    );
  }

  GameState _disconnectProducts(
    GameState state,
    String firstProductId,
    String secondProductId,
  ) {
    if (!state.hasLink(firstProductId, secondProductId)) {
      return state;
    }
    final key = EcosystemLink(firstProductId, secondProductId).key;
    return state.copyWith(
      ecosystemLinks: state.ecosystemLinks
          .where((item) => item.key != key)
          .toList(growable: false),
    );
  }

  GameState _acceptClientContract(GameState state, String templateId) {
    final template = ContractCatalog.byId(templateId);
    if (state.hasActiveContractTemplate(templateId)) {
      return _withFeed(state, '${template.name}: контракт уже выполняется.');
    }
    if (state.activeContracts.length >= 3) {
      return _withFeed(
        state,
        'Одновременно можно вести не больше трёх клиентских контрактов.',
      );
    }
    final sequence = state.rngCounter + 1;
    final upfront = template.reward * template.upfrontPercent;
    final contract = ClientContract(
      id: '${template.id}_$sequence',
      templateId: template.id,
      status: ContractStatus.active,
      progress: 0,
      acceptedAtMinutes: state.simulationMinutes,
      deadlineAtMinutes:
          state.simulationMinutes + template.deadlineDays * 24 * 60,
      reward: template.reward,
    );
    return _withFeed(
      state.copyWith(
        cash: state.cash + upfront,
        clientContracts: <ClientContract>[...state.clientContracts, contract],
        rngCounter: sequence,
      ),
      '${template.client}: контракт «${template.name}» принят. Аванс ${upfront.round()} ₽.',
    );
  }

  GameState _requestFunding(GameState state, RequestInvestorFunding action) {
    final investor = GameCatalog.investorById(action.investorId);
    final product = state.productById(action.productId);
    if (product == null || action.requestedAmount <= 0) {
      return state;
    }
    if (!investor.preferredCategories.contains(product.category)) {
      return _withFeed(
        state,
        '${investor.name} отказал: категория ${_categoryName(product.category)} не входит в инвестиционный фокус.',
      );
    }
    final readiness = product.stage == ProductStage.development
        ? product.developmentProgress
        : (product.qualityScore / 100 * 0.55 +
                  math.min(1, product.users / 50000) * 0.45)
              .clamp(0, 1)
              .toDouble();
    final reputationBonus = state.successfulProducts * 0.04;
    if (readiness + reputationBonus < investor.minimumReadiness) {
      return _withFeed(
        state,
        '${investor.name} отказал: готовность ${(readiness * 100).round()}%, требуется ${(investor.minimumReadiness * 100).round()}%.',
      );
    }

    final productRisk =
        (state.productSecurityRisk(product) * 0.70 +
                (1 - product.featureCoverage) * 0.25 +
                (product.stage == ProductStage.live ? 0 : 0.18))
            .clamp(0, 1)
            .toDouble();
    if (productRisk > investor.riskTolerance + 0.18) {
      return _withFeed(
        state,
        '${investor.name} отказал: риск продукта ${(productRisk * 100).round()}% выше допустимого профиля фонда.',
      );
    }

    final offered = math
        .min(action.requestedAmount, investor.availableCapital)
        .toDouble();
    final riskPremium = 1 + productRisk * (1.3 - investor.riskTolerance);
    final baseEquity = offered / state.valuation * 100 * riskPremium;
    final equity = baseEquity
        .clamp(2.5, investor.maximumEquityPercent)
        .toDouble();
    final revenueShare = (1.5 + productRisk * 6.5).clamp(1.5, 8).toDouble();
    final sequence = state.rngCounter + 1;
    final offer = InvestorOffer(
      id: 'offer_${investor.id}_$sequence',
      investorId: investor.id,
      productId: product.id,
      requestedAmount: action.requestedAmount,
      offeredAmount: offered,
      equityPercent: equity,
      revenueSharePercent: revenueShare,
      createdAtMinutes: state.simulationMinutes,
    );
    final wording = offered < action.requestedAmount
        ? 'Запрошено ${action.requestedAmount.round()} ₽, доступно только ${offered.round()} ₽.'
        : 'Запрос принят полностью.';
    return _withNews(
      _withFeed(
        state.copyWith(
          investorOffers: <InvestorOffer>[...state.investorOffers, offer],
          rngCounter: sequence,
        ),
        '${investor.name}: $wording Доля ${equity.toStringAsFixed(1)}%, revenue share ${revenueShare.toStringAsFixed(1)}%.',
      ),
      NewsItem(
        id: 'funding_offer_${offer.id}',
        kind: NewsKind.funding,
        title: 'Инвестиционное предложение',
        body:
            '${investor.name} предлагает ${offered.round()} ₽ за ${equity.toStringAsFixed(1)}% компании.',
        simulationMinutes: state.simulationMinutes,
        critical: false,
      ),
    );
  }

  GameState _acceptOffer(GameState state, String offerId) {
    final offer = state.offerById(offerId);
    if (offer == null) {
      return state;
    }
    final agreement = InvestorAgreement(
      id: 'agreement_${offer.id}',
      investorId: offer.investorId,
      productId: offer.productId,
      investedAmount: offer.offeredAmount,
      equityPercent: offer.equityPercent,
      revenueSharePercent: offer.revenueSharePercent,
      buybackPrice: offer.offeredAmount * 1.45,
    );
    final founderOwnership =
        state.founderOwnershipPercent - offer.equityPercent;
    var next = _withFeed(
      state.copyWith(
        cash: state.cash + offer.offeredAmount,
        founderOwnershipPercent: founderOwnership,
        investorOffers: state.investorOffers
            .where((item) => item.id != offerId)
            .toList(growable: false),
        investorAgreements: <InvestorAgreement>[
          ...state.investorAgreements,
          agreement,
        ],
      ),
      'Инвестиция принята. Доля основателя ${founderOwnership.toStringAsFixed(1)}%.',
    );
    if (founderOwnership < 50) {
      next = _withNews(
        next.copyWith(
          criticalEvent: CriticalEventType.lostControl,
          paused: true,
          gameOver: true,
        ),
        NewsItem(
          id: 'lost_control_${state.simulationMinutes}_$offerId',
          kind: NewsKind.funding,
          title: 'Основатель потерял контроль',
          body:
              'После сделки доля основателя составила ${founderOwnership.toStringAsFixed(1)}%. Инвесторы получили контроль над компанией.',
          simulationMinutes: state.simulationMinutes,
          critical: true,
        ),
      );
    }
    return next;
  }

  GameState _rejectOffer(GameState state, String offerId) => state.copyWith(
    investorOffers: state.investorOffers
        .where((item) => item.id != offerId)
        .toList(growable: false),
  );

  GameState _buyBack(GameState state, String agreementId) {
    final agreement = state.agreementById(agreementId);
    if (agreement == null || state.cash < agreement.buybackPrice) {
      return state;
    }
    return _withFeed(
      state.copyWith(
        cash: state.cash - agreement.buybackPrice,
        founderOwnershipPercent: math
            .min(100, state.founderOwnershipPercent + agreement.equityPercent)
            .toDouble(),
        investorAgreements: state.investorAgreements
            .where((item) => item.id != agreementId)
            .toList(growable: false),
      ),
      'Доля ${agreement.equityPercent.toStringAsFixed(1)}% выкуплена обратно за ${agreement.buybackPrice.round()} ₽.',
    );
  }

  GameState _investInMarketCompany(
    GameState state,
    InvestInMarketCompany action,
  ) {
    final company = GameCatalog.marketCompanyById(action.companyId);
    final current = state.holdingByCompanyId(company.id);
    final currentPercent = current?.ownershipPercent ?? 0;
    if (action.ownershipPercent <= 0 ||
        currentPercent + action.ownershipPercent >
            company.availableStakePercent) {
      return state;
    }
    final cost = company.valuation * action.ownershipPercent / 100;
    if (state.cash < cost) {
      return state;
    }
    final nextHolding = PortfolioHolding(
      companyId: company.id,
      ownershipPercent: currentPercent + action.ownershipPercent,
      amountPaid: (current?.amountPaid ?? 0) + cost,
    );
    return _withFeed(
      state.copyWith(
        cash: state.cash - cost,
        portfolioHoldings: <PortfolioHolding>[
          ...state.portfolioHoldings.where(
            (item) => item.companyId != company.id,
          ),
          nextHolding,
        ],
      ),
      'Куплено ${action.ownershipPercent.toStringAsFixed(1)}% ${company.companyName} за ${cost.round()} ₽.',
    );
  }

  GameState _acquireProduct(GameState state, AcquireMarketProduct action) {
    final company = GameCatalog.marketCompanyById(action.companyId);
    if (state.acquiredCompanyIds.contains(company.id) ||
        state.cash < company.productPrice) {
      return state;
    }

    if (action.mode == AcquisitionMode.migrateUsers) {
      final target = state.productById(action.targetProductId ?? '');
      if (target == null ||
          target.category != company.category ||
          target.stage != ProductStage.live) {
        return _withFeed(
          state,
          'Миграция невозможна: нужен выпущенный собственный продукт той же категории.',
        );
      }
      final spareCompute = math.max(
        0,
        state.totalComputeUnits - state.totalComputeDemand,
      );
      if (spareCompute < company.computeDemand * 1.2) {
        return _withFeed(
          state,
          'Миграция заблокирована: нужно ${(company.computeDemand * 1.2).round()} свободных compute units, доступно ${spareCompute.round()}.',
        );
      }
      final updatedProducts = state.products
          .map(
            (item) => item.id == target.id
                ? item.copyWith(
                    users: item.users + (company.users * 0.82).round(),
                    mau: item.mau + (company.users * 0.62).round(),
                    rating: math.max(1, item.rating - 0.15).toDouble(),
                  )
                : item,
          )
          .toList(growable: false);
      return _withNews(
        _withFeed(
          state.copyWith(
            cash: state.cash - company.productPrice,
            products: updatedProducts,
            acquiredCompanyIds: <String>[
              ...state.acquiredCompanyIds,
              company.id,
            ],
          ),
          '${company.productName} куплен. 82% пользователей переведены в ${target.name}.',
        ),
        NewsItem(
          id: 'migrate_${company.id}_${state.simulationMinutes}',
          kind: NewsKind.acquisition,
          title: 'Миграция ${company.productName}',
          body:
              'Инфраструктура выдержала перенос пользователей без критической просадки.',
          simulationMinutes: state.simulationMinutes,
          critical: false,
        ),
      );
    }

    final freeAllocation = math.max(0, 100 - state.totalAllocatedPercent);
    final blueprint = GameCatalog.productBlueprints.firstWhere(
      (item) => item.category == company.category,
    );
    final product = Product(
      id: 'acquired_${company.id}',
      blueprintId: blueprint.id,
      name: company.productName,
      category: company.category,
      stage: ProductStage.live,
      frameworkId: GameCatalog.frameworks
          .firstWhere(
            (item) => item.supportedCategories.contains(company.category),
          )
          .id,
      languageIds: const <String>['typescript'],
      technologyIds: const <String>['postgresql', 'observability_stack'],
      featureIds: List<String>.unmodifiable(blueprint.expectedFeatureIds),
      developmentProgress: 1,
      users: company.users,
      dau: (company.users * 0.22).round(),
      mau: (company.users * 0.68).round(),
      activationRate: 0.46,
      retention30d: 0.58,
      churnRate: 0.065,
      rating: 4.1,
      speedMs: company.speedMs,
      designScore: company.designScore,
      securityScore: company.securityScore,
      reliability: 0.991,
      featureCoverage: 1,
      qualityScore: (company.designScore + company.securityScore) / 2,
      monthlyRevenue: company.monthlyRevenue,
      monthlyCost: company.monthlyRevenue - company.monthlyProfit,
      monthlyGrowth: company.users * company.growthRate,
      price: blueprint.basePrice,
      monetization: MonetizationModel.subscription,
      marketingBudget: 0,
      allocatedCapacityPercent: math.min(18, freeAllocation).toDouble(),
      computeMultiplier: 1.25,
      createdAtMinutes: state.simulationMinutes,
      acquired: true,
    );
    return _withNews(
      state.copyWith(
        cash: state.cash - company.productPrice,
        products: <Product>[...state.products, product],
        acquiredCompanyIds: <String>[...state.acquiredCompanyIds, company.id],
      ),
      NewsItem(
        id: 'acquire_product_${company.id}',
        kind: NewsKind.acquisition,
        title: 'Куплен ${company.productName}',
        body:
            'Продукт продолжает работать отдельно. Выделено ${product.allocatedCapacityPercent.round()}% общей мощности.',
        simulationMinutes: state.simulationMinutes,
        critical: false,
      ),
    );
  }

  GameState _acquireCompany(GameState state, String companyId) {
    final company = GameCatalog.marketCompanyById(companyId);
    if (state.acquiredCompanyIds.contains(company.id) ||
        state.cash < company.valuation) {
      return state;
    }
    final acquired = _acquireProduct(
      state,
      AcquireMarketProduct(
        companyId: companyId,
        mode: AcquisitionMode.maintainSeparate,
      ),
    );
    if (identical(acquired, state)) {
      return state;
    }
    final generatedEmployees = <Employee>[
      Employee(
        id: 'acq_${company.id}_lead',
        name: '${company.companyName} Product Lead',
        role: EmployeeRole.productManager,
        skill: 82,
        speed: 72,
        quality: 84,
        autonomy: 88,
        communication: 79,
        reliability: 82,
        salary: 260000,
        loyalty: 64,
        morale: 72,
        workload: 58,
        remote: true,
      ),
      Employee(
        id: 'acq_${company.id}_engineer',
        name: '${company.companyName} Lead Engineer',
        role: EmployeeRole.backend,
        skill: 87,
        speed: 75,
        quality: 88,
        autonomy: 86,
        communication: 65,
        reliability: 89,
        salary: 290000,
        loyalty: 61,
        morale: 70,
        workload: 62,
        remote: true,
      ),
    ];
    return _withFeed(
      acquired.copyWith(
        cash: acquired.cash - (company.valuation - company.productPrice),
        employees: <Employee>[...acquired.employees, ...generatedEmployees],
      ),
      '${company.companyName} куплена целиком. Команда и продукт сохранены.',
    );
  }

  GameState _triggerSecurityIncident(GameState state, String productId) {
    final product = state.productById(productId);
    if (product == null || product.stage != ProductStage.live) {
      return state;
    }
    final wallet = product.category == ProductCategory.cryptoWallet;
    final hardenedWallet =
        wallet &&
        state.hasSecurityControl(productId, 'kms_encryption') &&
        state.hasSecurityControl(productId, 'backup_dr') &&
        state.hasSecurityControl(productId, 'soc_response');
    final walletCatastrophe = wallet && !hardenedWallet;
    final incidentMultiplier = state.productIncidentMultiplier(productId);
    final ordinaryUserFactor = (0.70 + (1 - incidentMultiplier) * 0.17).clamp(
      0.70,
      0.87,
    );
    final updatedProducts = state.products
        .map((item) {
          if (item.id != productId) {
            return item;
          }
          if (walletCatastrophe) {
            return item.copyWith(
              stage: ProductStage.failed,
              users: (item.users * 0.08).round(),
              mau: (item.mau * 0.05).round(),
              dau: 0,
              rating: 1.1,
              securityScore: math.max(1, item.securityScore - 35).toDouble(),
              monthlyRevenue: 0,
              monthlyGrowth: 0,
            );
          }
          if (hardenedWallet) {
            return item.copyWith(
              users: (item.users * 0.55).round(),
              mau: (item.mau * 0.48).round(),
              dau: (item.dau * 0.40).round(),
              rating: math.max(1.5, item.rating - 1.2).toDouble(),
              securityScore: math.max(12, item.securityScore - 20).toDouble(),
              reliability: math.max(0.76, item.reliability - 0.028).toDouble(),
              monthlyRevenue: item.monthlyRevenue * 0.38,
            );
          }
          return item.copyWith(
            users: (item.users * ordinaryUserFactor).round(),
            mau: (item.mau * (ordinaryUserFactor - 0.04)).round(),
            dau: (item.dau * (ordinaryUserFactor - 0.10)).round(),
            rating: math.max(1, item.rating - 0.8).toDouble(),
            securityScore: math.max(5, item.securityScore - 14).toDouble(),
            reliability: math.max(0.70, item.reliability - 0.035).toDouble(),
          );
        })
        .toList(growable: false);

    final news = walletCatastrophe
        ? NewsItem(
            id: 'wallet_attack_${state.simulationMinutes}_$productId',
            kind: NewsKind.security,
            title: '${product.name}: украдены средства пользователей',
            body:
                'Нет полного KMS + backup + SOC контура. Доверие уничтожено: 92% пользователей ушли, продукт фактически погиб.',
            simulationMinutes: state.simulationMinutes,
            critical: true,
          )
        : hardenedWallet
        ? NewsItem(
            id: 'wallet_contained_${state.simulationMinutes}_$productId',
            kind: NewsKind.security,
            title: '${product.name}: атаку удалось ограничить',
            body:
                'KMS, disaster recovery и SOC сохранили продукт, но часть средств и 45% пользователей потеряны.',
            simulationMinutes: state.simulationMinutes,
            critical: true,
          )
        : NewsItem(
            id: 'breach_${state.simulationMinutes}_$productId',
            kind: NewsKind.security,
            title: 'Утечка данных в ${product.name}',
            body:
                'Масштаб потерь снижен внедрёнными контролями. Пользователей осталось ${(ordinaryUserFactor * 100).round()}%.',
            simulationMinutes: state.simulationMinutes,
            critical: true,
          );
    return _withNews(
      _withFeed(
        state.copyWith(
          products: updatedProducts,
          criticalEvent: CriticalEventType.securityBreach,
          criticalProductId: productId,
          paused: true,
        ),
        news.title,
      ),
      news,
    );
  }

  GameState _resolveCriticalEvent(GameState state) {
    if (state.criticalEvent == CriticalEventType.none) {
      return state;
    }
    if (state.criticalEvent == CriticalEventType.lostControl) {
      return state;
    }
    final responseMultiplier = state.criticalProductId == null
        ? 1.0
        : state.productIncidentMultiplier(state.criticalProductId!);
    final cost = state.criticalEvent == CriticalEventType.securityBreach
        ? 240000.0 * (0.55 + responseMultiplier * 0.45)
        : 90000.0;
    return _withFeed(
      state.copyWith(
        cash: state.cash - math.min(state.cash, cost),
        criticalEvent: CriticalEventType.none,
        clearCriticalProductId: true,
        paused: true,
      ),
      'Инцидент локализован за ${cost.round()} ₽. Проверьте инфру и безопасность перед продолжением.',
    );
  }

  _MarketOutcome _marketOutcome({
    required GameState state,
    required Product product,
    required double speedMs,
    required double designScore,
    required double securityScore,
    required double reliability,
    required double qualityBonus,
    required double retentionBonus,
    required double freshnessPenalty,
  }) {
    final competitor = GameCatalog.competitorFor(product.category);
    final segments = GameCatalog.marketSegments
        .where((segment) => segment.category == product.category)
        .toList(growable: false);
    final expectedFeatures = competitor.featureIds.toSet();
    final ownFeatures = product.featureIds.toSet();
    final featureCoverage = expectedFeatures.isEmpty
        ? 1.0
        : expectedFeatures.intersection(ownFeatures).length /
              expectedFeatures.length;
    final competitorFeatureCoverage = 1.0;
    final ownSpeedScore = (100 - speedMs / math.max(1, competitor.speedMs) * 45)
        .clamp(0, 100)
        .toDouble();
    final competitorSpeedScore = 55.0;
    final ownPriceScore = _priceScore(product.price, competitor.monthlyPrice);
    final competitorPriceScore = 65.0;
    var monthlyNewUsers = 0.0;
    var weightedPreference = 0.0;
    var totalAddressable = 0.0;

    for (final segment in segments) {
      final ownScore =
          ownSpeedScore * segment.speedWeight +
          designScore * segment.designWeight +
          securityScore * segment.securityWeight +
          featureCoverage * 100 * segment.featureWeight +
          ownPriceScore * segment.priceWeight;
      final competitorScore =
          competitorSpeedScore * segment.speedWeight +
          competitor.designScore * segment.designWeight +
          competitor.securityScore * segment.securityWeight +
          competitorFeatureCoverage * 100 * segment.featureWeight +
          competitorPriceScore * segment.priceWeight;
      final preference =
          1 / (1 + math.exp(-(ownScore - competitorScore) / 8.5));
      final organic = segment.addressableUsers * (0.0007 + preference * 0.0048);
      final cac = (2200 - preference * 1500).clamp(280, 2200).toDouble();
      final paidVisitors = product.marketingBudget / cac;
      monthlyNewUsers +=
          (organic + paidVisitors * (0.18 + preference * 0.72)) *
          (1 - freshnessPenalty * 0.72);
      weightedPreference += preference * segment.addressableUsers;
      totalAddressable += segment.addressableUsers;
    }

    final preference = totalAddressable <= 0
        ? 0.35
        : weightedPreference / totalAddressable;
    final ecosystemBoost = state.ecosystemBoostFor(product.id);
    final featureRetentionBonus = product.featureIds
        .map(GameCatalog.featureById)
        .fold<double>(0, (sum, feature) => sum + feature.retentionDelta)
        .clamp(0, 0.24)
        .toDouble();
    final overload = math.max(0, state.productServerLoad(product) - 0.82);
    final activation =
        (0.18 +
                designScore / 330 +
                featureCoverage * 0.22 +
                preference * 0.18 +
                qualityBonus / 500 -
                freshnessPenalty * 0.12 -
                overload * 0.12)
            .clamp(0.05, 0.92)
            .toDouble();
    final retention =
        (0.22 +
                featureCoverage * 0.24 +
                featureRetentionBonus +
                designScore / 500 +
                reliability * 0.14 +
                ecosystemBoost +
                retentionBonus +
                qualityBonus / 600 -
                freshnessPenalty * 0.16 -
                overload * 0.10)
            .clamp(0.08, 0.92)
            .toDouble();
    final churn =
        (0.19 -
                retention * 0.14 +
                (1 - preference) * 0.08 +
                overload * 0.10 +
                freshnessPenalty * 0.11 +
                (100 - securityScore) / 1000)
            .clamp(0.015, 0.38)
            .toDouble();
    final quality =
        (ownSpeedScore * 0.22 +
                designScore * 0.20 +
                securityScore * 0.24 +
                featureCoverage * 100 * 0.22 +
                reliability * 100 * 0.12 +
                qualityBonus -
                freshnessPenalty * 24)
            .clamp(1, 100)
            .toDouble();

    return _MarketOutcome(
      monthlyNewUsers: monthlyNewUsers * activation * (1 + ecosystemBoost),
      activationRate: activation,
      retention30d: retention,
      churnRate: churn,
      qualityScore: quality,
      featureCoverage: featureCoverage,
      mauRatio: (0.48 + retention * 0.38).clamp(0.35, 0.92).toDouble(),
      dauMauRatio: (0.16 + retention * 0.28).clamp(0.12, 0.58).toDouble(),
    );
  }

  double _monthlyRevenue({
    required Product product,
    required int mau,
    required double reliability,
    required double ecosystemBoost,
  }) {
    final base = switch (product.monetization) {
      MonetizationModel.free => 0.0,
      MonetizationModel.subscription => mau * product.price * 0.092,
      MonetizationModel.usageBased => mau * product.price * 0.061,
      MonetizationModel.advertising => mau * 34.0,
      MonetizationModel.transactionFee => mau * product.price * 0.18,
    };
    return base * reliability * (1 + ecosystemBoost * 0.55);
  }

  double _roleQualityForProduct(
    List<Employee> employees,
    ProductCategory category,
  ) {
    final roles = switch (category) {
      ProductCategory.aiAssistant => const <EmployeeRole>[
        EmployeeRole.aiMl,
        EmployeeRole.backend,
        EmployeeRole.frontend,
      ],
      ProductCategory.cloud => const <EmployeeRole>[
        EmployeeRole.backend,
        EmployeeRole.devOps,
        EmployeeRole.security,
      ],
      ProductCategory.saas => const <EmployeeRole>[
        EmployeeRole.frontend,
        EmployeeRole.backend,
        EmployeeRole.productManager,
      ],
      ProductCategory.browser => const <EmployeeRole>[
        EmployeeRole.frontend,
        EmployeeRole.backend,
        EmployeeRole.security,
      ],
      ProductCategory.cryptoWallet => const <EmployeeRole>[
        EmployeeRole.backend,
        EmployeeRole.security,
        EmployeeRole.mobile,
      ],
      ProductCategory.developerTool => const <EmployeeRole>[
        EmployeeRole.backend,
        EmployeeRole.devOps,
        EmployeeRole.productManager,
      ],
    };
    return _roleAverage(employees, roles, (employee) => employee.quality);
  }

  double _roleAverage(
    List<Employee> employees,
    List<EmployeeRole> roles,
    int Function(Employee employee) metric,
  ) {
    final matching = employees.where(
      (employee) => roles.contains(employee.role),
    );
    if (matching.isEmpty) {
      return 0;
    }
    return matching.map(metric).reduce((a, b) => a + b) / matching.length;
  }

  double _priceScore(double ownPrice, double competitorPrice) {
    if (competitorPrice <= 0) {
      return ownPrice <= 0 ? 90 : (60 - ownPrice / 20).clamp(0, 60).toDouble();
    }
    return (80 - (ownPrice / competitorPrice - 1) * 50)
        .clamp(0, 100)
        .toDouble();
  }

  double _random01(int seed, int counter) {
    var value = seed ^ (counter * 1103515245);
    value = (1664525 * value + 1013904223) & 0x7fffffff;
    return value / 0x7fffffff;
  }

  GameState _withFeed(GameState state, String message) {
    final feed = <String>[message, ...state.feed];
    return state.copyWith(feed: feed.take(16).toList(growable: false));
  }

  GameState _withNews(GameState state, NewsItem item) {
    final items = <NewsItem>[item, ...state.news];
    return state.copyWith(news: items.take(40).toList(growable: false));
  }

  String _monetizationName(MonetizationModel model) => switch (model) {
    MonetizationModel.free => 'бесплатная',
    MonetizationModel.subscription => 'подписка',
    MonetizationModel.usageBased => 'оплата за использование',
    MonetizationModel.advertising => 'реклама',
    MonetizationModel.transactionFee => 'комиссия с транзакций',
  };

  String _categoryName(ProductCategory category) => switch (category) {
    ProductCategory.aiAssistant => 'AI',
    ProductCategory.cloud => 'Cloud',
    ProductCategory.saas => 'SaaS',
    ProductCategory.browser => 'Browser',
    ProductCategory.cryptoWallet => 'Crypto',
    ProductCategory.developerTool => 'Developer tools',
  };
}

class _MarketOutcome {
  const _MarketOutcome({
    required this.monthlyNewUsers,
    required this.activationRate,
    required this.retention30d,
    required this.churnRate,
    required this.qualityScore,
    required this.featureCoverage,
    required this.mauRatio,
    required this.dauMauRatio,
  });

  final double monthlyNewUsers;
  final double activationRate;
  final double retention30d;
  final double churnRate;
  final double qualityScore;
  final double featureCoverage;
  final double mauRatio;
  final double dauMauRatio;
}

class _DailyResult {
  const _DailyResult(this.state, this.counter);
  final GameState state;
  final int counter;
}
