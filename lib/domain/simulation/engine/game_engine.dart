import 'dart:math' as math;

import '../../catalog/contract_catalog.dart';
import '../../catalog/candidate_market_catalog.dart';
import '../../catalog/game_catalog.dart';
import '../../catalog/operations_catalog.dart';
import '../../catalog/product_evolution_catalog.dart';
import '../../catalog/product_strategy_catalog.dart';
import '../../catalog/v9_content_catalog.dart';
import '../../commands/game_action.dart';
import '../../entities/business_models.dart';
import '../../entities/game_state.dart';
import '../../entities/management_models.dart';
import '../../entities/models.dart';
import '../../entities/operations_models.dart';
import '../../entities/product_evolution_models.dart';
import '../../entities/product_strategy_models.dart';
import '../../entities/v9_models.dart';
import '../../entities/v10_models.dart';
import '../../entities/v12_game_state_extensions.dart';
import '../../entities/v12_models.dart';
import '../../explainability/language_limit_resolver.dart';
import '../../explainability/product_configuration_resolver.dart';
import '../product_projection_cache.dart';

class GameEngine {
  const GameEngine();

  GameState reduce(GameState state, GameAction action) {
    if (action is ResetGame) {
      return GameState.initial();
    }
    if (state.gameOver && action is! ResolveCriticalEvent) {
      return state;
    }

    final next = switch (action) {
      CompleteOnboarding() => state.copyWith(onboardingCompleted: true),
      RestartOnboarding() => state.copyWith(onboardingCompleted: false),
      ConfigureCompany() => _configureCompany(state, action),
      CompleteDevelopmentChallenge() => _completeDevelopmentChallenge(
        state,
        action,
      ),
      AdvanceTime() => _advanceTime(state, action.realSeconds),
      SetGameSpeed() => state.copyWith(speed: action.speed),
      TogglePause() => state.copyWith(paused: !state.paused),
      SkipNight() => _skipNight(state),
      CreateConfiguredProduct() => _createProduct(state, action),
      LaunchProduct() => _launchProduct(state, action.productId),
      SellProduct() => _sellProduct(state, action.productId),
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
      HireCandidateForProduct() => _hireCandidateForProduct(
        state,
        action.candidateId,
        action.productId,
      ),
      AutoHireProjectTeam() => _autoHireProjectTeam(state, action.productId),
      AssignEmployeeToProduct() => _assignEmployee(
        state,
        action.employeeId,
        action.productId,
      ),
      SetProductTeam() => _setProductTeam(
        state,
        action.productId,
        action.employeeIds,
      ),
      AutoHireContractTeam() => _autoHireContractTeam(state, action.contractId),
      SetContractTeam() => _setContractTeam(
        state,
        action.contractId,
        action.employeeIds,
      ),
      SendEmployeeOnVacation() => _sendEmployeeOnVacation(
        state,
        action.employeeId,
      ),
      GiveWellbeingBonus() => _giveWellbeingBonus(state, action.employeeId),
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
      RentHostingPlan() => _rentHostingPlan(state, action.hostingPlanId),
      MigrateToOwnedInfrastructure() => _migrateToOwnedInfrastructure(state),
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
      StartAdvertisingCampaign() => _startAdvertisingCampaign(state, action),
      RequestBusinessLoan() => _requestBusinessLoan(state),
      AcceptEmergencyLoan() => _acceptEmergencyLoan(state),
      RedeemDebugPromo() => _redeemDebugPromo(state, action.code),
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
    return _recordActionTransaction(state, next, action);
  }

  GameState _configureCompany(GameState state, ConfigureCompany action) {
    if (state.companyProfile.configured) {
      return state;
    }
    final name = action.companyName.trim();
    final founderName = action.founderName.trim();
    const allowedBudgets = <double>[250000, 450000, 750000, 1200000];
    final validBudget = allowedBudgets.any(
      (value) => (value - action.startingBudget).abs() < 0.5,
    );
    final validLogo = RegExp(
      r'^company_logo_(0[1-9]|1[0-9]|2[0-5])$',
    ).hasMatch(action.logoId);
    final profile = FounderCompanyProfile(
      configured: true,
      companyName: name,
      founderName: founderName,
      logoId: action.logoId,
      startingBudget: action.startingBudget,
      background: action.background,
      skills: Map<FounderSkill, int>.unmodifiable(action.skills),
    );
    if (name.isEmpty ||
        name.length > 28 ||
        founderName.isEmpty ||
        founderName.length > 24 ||
        !validBudget ||
        !validLogo ||
        !profile.hasValidSkillBudget) {
      return _withFeed(
        state,
        'Настройка компании отклонена: проверьте название, имя CEO, бюджет, логотип и 22 очка навыков.',
      );
    }
    return state.copyWith(
      companyProfile: profile,
      cash: action.startingBudget,
      selectedOfficeId: 'remote_first',
      feed: <String>[
        '$name зарегистрирована. Стартовый бюджет ${action.startingBudget.round()} ₽.',
        'CEO начинает без офиса и может самостоятельно двигать любой этап продукта, но команда работает быстрее.',
      ],
    );
  }

  GameState _completeDevelopmentChallenge(
    GameState state,
    CompleteDevelopmentChallenge action,
  ) {
    final product = state.productById(action.productId);
    if (product == null || product.stage != ProductStage.development) {
      return state;
    }
    final currentStage = state.founderStageFor(product);
    if (currentStage != action.stage ||
        state.projectChallengeHandled(product)) {
      return state;
    }
    if (currentStage != FounderDevelopmentStage.implementation &&
        currentStage != FounderDevelopmentStage.debugging) {
      return state;
    }

    final key = state.projectChallengeKey(product);
    final start = state.founderStageStart(currentStage);
    final end = state.founderStageEnd(currentStage);
    final stageSpan = end - start;
    final bonus = action.correct ? stageSpan * 0.30 : 0.0;
    final products = state.products
        .map(
          (item) => item.id == product.id
              ? item.copyWith(
                  developmentProgress: action.correct
                      ? math
                            .min(end, item.developmentProgress + bonus)
                            .toDouble()
                      : item.developmentProgress,
                  qualityScore: action.correct
                      ? math.min(100, item.qualityScore + 0.75).toDouble()
                      : item.qualityScore,
                )
              : item,
        )
        .toList(growable: false);
    return _withFeed(
      state.copyWith(
        products: products,
        productUpdates: <ProductUpdateRecord>[
          ...state.productUpdates,
          ProductUpdateRecord(
            productId: product.id,
            updatedAtMinutes: state.simulationMinutes,
            reason: key,
          ),
        ],
      ),
      action.correct
          ? '${product.name}: проектный вызов решён — +30% прогресса текущего этапа.'
          : '${product.name}: проектный вызов пропущен/не решён. Разработка продолжается без штрафа.',
    );
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
    final productiveHours = _workingHoursBetween(
      state.simulationMinutes,
      deltaMinutes,
    );

    final updatedProducts = state.products
        .map((product) {
          final projection = ProductProjectionCache.estimate(
            blueprintId: product.blueprintId,
            frameworkId: product.frameworkId,
            languageIds: product.languageIds,
            technologyIds: product.technologyIds,
            featureIds: product.featureIds,
          );

          if (product.stage == ProductStage.development) {
            final developmentCapacity = state.productDevelopmentCapacity(
              product.id,
            );
            final founderCapacity = state.founderDevelopmentCapacityFor(
              product,
            );
            final completedHours =
                productiveHours * (developmentCapacity + founderCapacity);
            final progressDelta = completedHours / projection.developmentHours;
            final staffing = state.developmentStaffingFor(product.id);
            final qualityAdjustment = staffing.efficiency < 0.55
                ? -0.015 * monthFraction
                : staffing.efficiency > 0.92
                ? 0.006 * monthFraction
                : 0.0;
            return product.copyWith(
              developmentProgress: math
                  .min(1, product.developmentProgress + progressDelta)
                  .toDouble(),
              monthlyCost: projection.monthlyTechCost,
              qualityScore: (product.qualityScore + qualityAdjustment)
                  .clamp(1, 92)
                  .toDouble(),
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
            brandAwareness:
                (product.brandAwareness +
                        math.min(0.012, potentialNewUsers / 500000))
                    .clamp(0, 1)
                    .toDouble(),
            brandTrust:
                (product.brandTrust +
                        (outcome.retention30d - product.churnRate) *
                            monthFraction *
                            0.08)
                    .clamp(0.01, 1)
                    .toDouble(),
            priceSentiment: state.currentPriceSentiment(product),
          );
        })
        .toList(growable: false);

    var next = state.copyWith(
      simulationMinutes: state.simulationMinutes + deltaMinutes,
      products: updatedProducts,
      rngCounter: nextCounter,
    );
    next = _advanceProductFeatureDevelopments(state, next, deltaMinutes);
    next = _advanceEmployeeWellbeing(next, deltaMinutes);
    next = _advanceInvestorNegotiations(next);
    final cashDelta = next.monthlyProfit * monthFraction;
    next = next.copyWith(cash: next.cash + cashDelta);
    next = _appendPayrollTransactions(state, next, deltaMinutes);
    next = _advanceClientContracts(next, deltaMinutes);
    next = _advanceAdvertisingCampaigns(next, deltaMinutes);
    next = _advanceLoanAndLiquidity(state, next);
    final previousDay = state.simulationMinutes ~/ 1440;
    final currentDay = next.simulationMinutes ~/ 1440;
    if (currentDay > previousDay) {
      next = next.copyWith(
        financeHistory:
            <FinanceHistoryPoint>[
                  ...next.financeHistory,
                  FinanceHistoryPoint(
                    simulationMinutes: next.simulationMinutes,
                    cash: next.cash,
                    incomeRunRate:
                        next.monthlyProductRevenue + next.portfolioIncome,
                    expenseRunRate: next.monthlyCosts,
                    profitRunRate: next.monthlyProfit,
                  ),
                ]
                .skip(math.max(0, next.financeHistory.length + 1 - 120))
                .toList(growable: false),
      );
    }

    next = _appendProductMetricHistory(state, next);

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

  GameState _appendProductMetricHistory(GameState previous, GameState state) {
    final previousDay = previous.simulationMinutes ~/ 1440;
    final currentDay = state.simulationMinutes ~/ 1440;
    if (currentDay <= previousDay || state.products.isEmpty) {
      return state;
    }
    final points = state.products
        .map(
          (product) => ProductMetricPoint(
            productId: product.id,
            simulationMinutes: state.simulationMinutes,
            users: product.users,
            dau: product.dau,
            mau: product.mau,
            revenue: product.monthlyRevenue,
            requiredCompute: state.productComputeDemand(product),
            rating: product.rating,
            retention30d: product.retention30d,
            churnRate: product.churnRate,
          ),
        )
        .toList(growable: false);
    final history = <ProductMetricPoint>[
      ...state.productMetricHistory,
      ...points,
    ];
    final trimmed = history.length <= 720
        ? history
        : history.skip(history.length - 720).toList(growable: false);
    return state.copyWith(productMetricHistory: trimmed);
  }

  GameState _advanceEmployeeWellbeing(GameState state, int deltaMinutes) {
    if (state.employees.isEmpty || deltaMinutes <= 0) return state;
    final days = deltaMinutes / 1440;
    final employees = state.employees
        .map((employee) {
          final parallelWork = state.activeAssignmentCountForEmployee(
            employee.id,
          );
          final targetWorkload = math.min(100, 18 + parallelWork * 31).toInt();
          final current = employee.workload;
          final step = math.max(1, (days * 12).round());
          final workload = current < targetWorkload
              ? math.min(targetWorkload, current + step).toInt()
              : math.max(targetWorkload, current - step).toInt();
          final moraleDelta = workload >= 82
              ? -math.max(1, (days * 3).round())
              : workload <= 48
              ? math.max(0, (days * 1.5).round())
              : 0;
          return employee.managedCopyWith(
            workload: workload,
            morale: (employee.morale + moraleDelta).clamp(5, 100).toInt(),
          );
        })
        .toList(growable: false);
    return state.copyWith(employees: employees);
  }

  int _investorDecisionDays(InvestorOffer offer) {
    final value = int.tryParse(offer.id.split('_').last);
    return (value ?? 7).clamp(1, 14);
  }

  GameState _advanceInvestorNegotiations(GameState state) {
    if (!state.investorOffers.any((offer) => offer.offeredAmount < 0)) {
      return state;
    }
    final remaining = <InvestorOffer>[];
    final messages = <String>[];
    final news = <NewsItem>[...state.news];
    for (final offer in state.investorOffers) {
      if (offer.offeredAmount >= 0) {
        remaining.add(offer);
        continue;
      }
      final decisionAt =
          offer.createdAtMinutes + _investorDecisionDays(offer) * 1440;
      if (state.simulationMinutes < decisionAt) {
        remaining.add(offer);
        continue;
      }
      final investor = GameCatalog.investorById(offer.investorId);
      final product = state.productById(offer.productId);
      if (product == null) {
        messages.add(
          '${investor.name}: переговоры прекращены — продукт закрыт.',
        );
        continue;
      }
      final readiness = product.stage == ProductStage.development
          ? product.developmentProgress
          : (product.qualityScore / 100 * 0.55 +
                    math.min(1, product.users / 50000) * 0.45)
                .clamp(0, 1)
                .toDouble();
      final productRisk =
          (state.productSecurityRisk(product) * 0.70 +
                  (1 - product.featureCoverage) * 0.25 +
                  (product.stage == ProductStage.live ? 0 : 0.18))
              .clamp(0, 1)
              .toDouble();
      final categoryFits = investor.preferredCategories.contains(
        product.category,
      );
      final approved =
          categoryFits &&
          readiness + state.successfulProducts * 0.04 >=
              investor.minimumReadiness &&
          productRisk <= investor.riskTolerance + 0.18;
      if (!approved) {
        final reason = !categoryFits
            ? 'категория не входит в фокус фонда'
            : readiness < investor.minimumReadiness
            ? 'готовность ${(readiness * 100).round()}% ниже требуемой'
            : 'риск ${(productRisk * 100).round()}% выше профиля фонда';
        messages.add('${investor.name} отказал: $reason.');
        news.insert(
          0,
          NewsItem(
            id: 'funding_rejected_${offer.id}',
            kind: NewsKind.funding,
            title: 'Инвестор отказал',
            body: '${investor.name}: $reason.',
            simulationMinutes: state.simulationMinutes,
            critical: false,
          ),
        );
        continue;
      }
      final offered = math
          .min(offer.requestedAmount, investor.availableCapital)
          .toDouble();
      final riskPremium = 1 + productRisk * (1.3 - investor.riskTolerance);
      final equity = (offered / state.valuation * 100 * riskPremium)
          .clamp(2.5, investor.maximumEquityPercent)
          .toDouble();
      final revenueShare = (1.5 + productRisk * 6.5).clamp(1.5, 8).toDouble();
      remaining.add(
        InvestorOffer(
          id: offer.id,
          investorId: offer.investorId,
          productId: offer.productId,
          requestedAmount: offer.requestedAmount,
          offeredAmount: offered,
          equityPercent: equity,
          revenueSharePercent: revenueShare,
          createdAtMinutes: offer.createdAtMinutes,
        ),
      );
      messages.add(
        '${investor.name} прислал оффер: ${offered.round()} ₽ за ${equity.toStringAsFixed(1)}% компании.',
      );
      news.insert(
        0,
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
    var next = state.copyWith(
      investorOffers: remaining,
      news: news.take(40).toList(growable: false),
    );
    for (final message in messages) {
      next = _withFeed(next, message);
    }
    return next;
  }

  double _workingHoursBetween(int startMinutes, int deltaMinutes) {
    if (deltaMinutes <= 0) {
      return 0;
    }
    final endMinutes = startMinutes + deltaMinutes;
    final firstDay = startMinutes ~/ 1440;
    final lastDay = (endMinutes - 1) ~/ 1440;
    var workingMinutes = 0;
    for (var day = firstDay; day <= lastDay; day += 1) {
      final weekday = day % 7;
      if (weekday >= 5) {
        continue;
      }
      final workStart = day * 1440 + 9 * 60;
      final workEnd = day * 1440 + 18 * 60;
      final overlapStart = math.max(startMinutes, workStart);
      final overlapEnd = math.min(endMinutes, workEnd);
      if (overlapEnd > overlapStart) {
        workingMinutes += overlapEnd - overlapStart;
      }
    }
    return workingMinutes / 60;
  }

  GameState _appendPayrollTransactions(
    GameState previous,
    GameState state,
    int deltaMinutes,
  ) {
    if (previous.employees.isEmpty || deltaMinutes <= 0) return state;
    final previousDay = previous.simulationMinutes ~/ 1440;
    final currentDay = state.simulationMinutes ~/ 1440;
    if (currentDay <= previousDay) return state;
    final longAdvance = deltaMinutes >= 1440;
    final periodEnd = longAdvance ? state.simulationMinutes : currentDay * 1440;
    final defaultPeriodStart = longAdvance
        ? previous.simulationMinutes
        : math.max(0, periodEnd - 1440);
    final transactions = previous.employees
        .map((employee) {
          final payableStart = math.max(
            defaultPeriodStart,
            employee.hiredAtMinutes,
          );
          final payableMinutes = math.max(0, periodEnd - payableStart);
          final amount = employee.salary * payableMinutes / 43200;
          return FinanceTransaction(
            id: 'payroll_${employee.id}_$periodEnd',
            simulationMinutes: periodEnd,
            amount: -amount,
            category: FinanceTransactionCategory.payroll,
            description:
                'Зарплата • ${employee.name} • период Д${payableStart ~/ 1440 + 1}–Д${periodEnd ~/ 1440 + 1}',
          );
        })
        .where((item) => item.amount.abs() > 0.01)
        .toList(growable: false);
    return state.copyWith(
      financeTransactions: <FinanceTransaction>[
        ...transactions,
        ...state.financeTransactions,
      ].take(120).toList(growable: false),
    );
  }

  GameState _advanceProductFeatureDevelopments(
    GameState previous,
    GameState state,
    int deltaMinutes,
  ) {
    if (previous.productFeatureDevelopments.isEmpty || deltaMinutes <= 0) {
      return state;
    }
    final productiveHours = _workingHoursBetween(
      previous.simulationMinutes,
      deltaMinutes,
    );
    if (productiveHours <= 0) {
      return state;
    }

    final remainingWorks = <ProductFeatureDevelopment>[];
    final completed = <ProductFeatureDevelopment>[];
    for (final work in previous.productFeatureDevelopments) {
      final product = previous.productById(work.productId);
      if (product == null || product.stage != ProductStage.live) {
        continue;
      }
      final capacity =
          previous.productDevelopmentCapacity(product.id) +
          previous.founderFeatureWorkCapacityFor(product);
      final progressDelta = productiveHours * capacity / work.requiredHours;
      final progress = math.min(1, work.progress + progressDelta).toDouble();
      if (progress >= 1) {
        completed.add(work.copyWith(progress: 1));
      } else {
        remainingWorks.add(work.copyWith(progress: progress));
      }
    }
    if (completed.isEmpty) {
      return state.copyWith(productFeatureDevelopments: remainingWorks);
    }

    var products = List<Product>.of(state.products);
    final updates = <ProductUpdateRecord>[...state.productUpdates];
    final improvements = <ProductImprovementRecord>[
      ...state.productImprovements,
    ];
    final messages = <String>[];
    final news = <NewsItem>[...state.news];
    for (final work in completed) {
      final productIndex = products.indexWhere(
        (item) => item.id == work.productId,
      );
      if (productIndex < 0) {
        continue;
      }
      final product = products[productIndex];
      if (work.featureId.startsWith('__improvement_')) {
        final payload = work.featureId.substring('__improvement_'.length);
        final separator = payload.lastIndexOf('_');
        if (separator <= 0) continue;
        final typeName = payload.substring(0, separator);
        final level = int.tryParse(payload.substring(separator + 1)) ?? 1;
        ProductImprovementType? type;
        for (final candidate in ProductImprovementType.values) {
          if (candidate.name == typeName) {
            type = candidate;
            break;
          }
        }
        if (type == null) {
          messages.add(
            '${product.name}: пропущена несовместимая старая запись улучшения «${work.featureId}».',
          );
          continue;
        }
        final option = ProductEvolutionCatalog.improvementByType(type);
        products[productIndex] = product.copyWith(
          speedMs: product.speedMs * option.speedMultiplier,
          designScore: math
              .min(100, product.designScore + option.designDelta)
              .toDouble(),
          securityScore: math
              .min(100, product.securityScore + option.securityDelta)
              .toDouble(),
          reliability: math
              .min(0.9999, product.reliability + option.reliabilityDelta)
              .toDouble(),
          qualityScore: math
              .min(100, product.qualityScore + option.qualityDelta)
              .toDouble(),
        );
        improvements.add(
          ProductImprovementRecord(
            productId: product.id,
            type: type,
            level: level,
            appliedAtMinutes: state.simulationMinutes,
          ),
        );
        updates.add(
          ProductUpdateRecord(
            productId: product.id,
            updatedAtMinutes: state.simulationMinutes,
            reason: '${option.name} L$level',
          ),
        );
        messages.add(
          '${product.name}: ${option.name}, уровень $level завершён командой.',
        );
        news.insert(
          0,
          NewsItem(
            id: 'improvement_${product.id}_${type.name}_${state.simulationMinutes}',
            kind: NewsKind.product,
            title: '${product.name}: техническое улучшение',
            body:
                '${option.name} завершено за ${work.requiredHours.round()} рабочих часов.',
            simulationMinutes: state.simulationMinutes,
            critical: false,
          ),
        );
        continue;
      }
      final featureMatches = GameCatalog.features.where(
        (item) => item.id == work.featureId,
      );
      if (featureMatches.isEmpty) {
        messages.add(
          '${product.name}: пропущена неизвестная старая функция «${work.featureId}».',
        );
        continue;
      }
      final feature = featureMatches.first;
      final featureIds = <String>[...product.featureIds, feature.id];
      final projection = ProductProjectionCache.estimate(
        blueprintId: product.blueprintId,
        frameworkId: product.frameworkId,
        languageIds: product.languageIds,
        technologyIds: product.technologyIds,
        featureIds: featureIds,
      );
      products[productIndex] = product.copyWith(
        featureIds: featureIds,
        speedMs: projection.speedMs,
        designScore: projection.designScore,
        securityScore: projection.securityScore,
        reliability: projection.reliability,
        featureCoverage: projection.featureCoverage,
        qualityScore: projection.qualityScore,
        monthlyCost: projection.monthlyTechCost,
        computeMultiplier: projection.computeMultiplier,
      );
      updates.add(
        ProductUpdateRecord(
          productId: product.id,
          updatedAtMinutes: state.simulationMinutes,
          reason: 'Функция: ${feature.name}',
        ),
      );
      messages.add('${product.name}: обновление «${feature.name}» выпущено.');
      news.insert(
        0,
        NewsItem(
          id: 'feature_${product.id}_${feature.id}_${state.simulationMinutes}',
          kind: NewsKind.product,
          title: '${product.name}: обновление',
          body:
              '${feature.name} завершена командой за ${work.requiredHours.round()} рабочих часов.',
          simulationMinutes: state.simulationMinutes,
          critical: false,
        ),
      );
    }
    var next = state.copyWith(
      products: products,
      productFeatureDevelopments: remainingWorks,
      productImprovements: improvements,
      productUpdates: updates,
      news: news.take(40).toList(growable: false),
    );
    for (final message in messages) {
      next = _withFeed(next, message);
    }
    return next;
  }

  GameState _advanceAdvertisingCampaigns(GameState state, int deltaMinutes) {
    if (state.advertisingCampaigns.isEmpty || deltaMinutes <= 0) {
      return state;
    }
    var nextCounter = state.rngCounter;
    final completedMessages = <String>[];
    final completedNow = <AdvertisingCampaign>[];
    final deliveredByProduct = <String, int>{};
    final updated = state.advertisingCampaigns
        .map((campaign) {
          if (campaign.status != AdvertisingCampaignStatus.active ||
              state.simulationMinutes < campaign.endsAtMinutes) {
            return campaign;
          }
          final product = state.productById(campaign.productId);
          if (product == null || product.stage != ProductStage.live) {
            return campaign.copyWith(status: AdvertisingCampaignStatus.stopped);
          }
          final forecast = state.advertisingForecast(
            product: product,
            agencyId: campaign.agencyId,
            channelId: campaign.channelId,
            budget: campaign.budget,
          );
          final roll = _random01(state.rngSeed, nextCounter++);
          final delivered =
              (forecast.usersLow +
                      (forecast.usersHigh - forecast.usersLow) * roll)
                  .round()
                  .clamp(0, forecast.usersHigh)
                  .toInt();
          deliveredByProduct.update(
            product.id,
            (value) => value + delivered,
            ifAbsent: () => delivered,
          );
          completedMessages.add(
            '${product.name}: кампания завершена, пришло $delivered пользователей при прогнозе ${forecast.usersLow}–${forecast.usersHigh}.',
          );
          final completedCampaign = campaign.copyWith(
            status: AdvertisingCampaignStatus.completed,
            deliveredUsers: delivered,
          );
          completedNow.add(completedCampaign);
          return completedCampaign;
        })
        .toList(growable: false);

    if (deliveredByProduct.isEmpty) {
      return state.copyWith(
        advertisingCampaigns: updated,
        rngCounter: nextCounter,
      );
    }

    final products = state.products
        .map((product) {
          final delivered = deliveredByProduct[product.id] ?? 0;
          if (delivered <= 0) {
            return product;
          }
          final campaigns = completedNow.where(
            (item) => item.productId == product.id,
          );
          var brandDelta = delivered / 250000;
          var trustDelta = delivered / 1000000;
          for (final campaign in campaigns) {
            final channel = ProductStrategyCatalog.channelById(
              campaign.channelId,
            );
            brandDelta +=
                campaign.projectedImpressions / 8000000 * channel.brandWeight;
            trustDelta += channel.trustWeight * 0.006;
          }
          return product.copyWith(
            users: product.users + delivered,
            mau: product.mau + (delivered * 0.72).round(),
            dau: product.dau + (delivered * 0.14).round(),
            brandAwareness: (product.brandAwareness + brandDelta)
                .clamp(0, 1)
                .toDouble(),
            brandTrust: (product.brandTrust + trustDelta)
                .clamp(0.01, 1)
                .toDouble(),
          );
        })
        .toList(growable: false);

    var next = state.copyWith(
      products: products,
      advertisingCampaigns: updated,
      rngCounter: nextCounter,
    );
    for (final message in completedMessages) {
      next = _withFeed(next, message);
    }
    return next;
  }

  GameState _advanceLoanAndLiquidity(GameState previous, GameState state) {
    var next = state;
    final loan = next.activeLoan;
    if (loan != null) {
      final oldWeeks = math.max(
        0,
        (previous.simulationMinutes - loan.issuedAtMinutes) ~/ (7 * 1440),
      );
      final newWeeks = math.max(
        0,
        (next.simulationMinutes - loan.issuedAtMinutes) ~/ (7 * 1440),
      );
      if (newWeeks > oldWeeks && loan.remaining > 0) {
        final paymentCount = newWeeks - oldWeeks;
        final scheduled = loan.weeklyPayment * paymentCount;
        final principalPayment = math.min(loan.remaining, scheduled).toDouble();
        final remaining = math
            .max(0, loan.remaining - principalPayment)
            .toDouble();
        next = _withFeed(
          next.copyWith(
            activeLoan: remaining <= 0
                ? null
                : loan.copyWith(remaining: remaining),
            clearActiveLoan: remaining <= 0,
            financeTransactions: <FinanceTransaction>[
              FinanceTransaction(
                id: 'loan_payment_${next.simulationMinutes}',
                simulationMinutes: next.simulationMinutes,
                amount: -scheduled,
                category: FinanceTransactionCategory.financing,
                description: remaining <= 0
                    ? 'Кредит погашен'
                    : 'Еженедельный платёж по кредиту',
              ),
              ...next.financeTransactions,
            ].take(120).toList(growable: false),
          ),
          remaining <= 0
              ? 'Кредит полностью погашен.'
              : 'Списан платёж ${scheduled.round()} ₽. Остаток долга ${remaining.round()} ₽.',
        );
      }
    }

    if (next.cash >= 0) {
      return next.copyWith(clearNegativeCashSinceMinutes: true);
    }

    final negativeSince =
        next.negativeCashSinceMinutes ?? next.simulationMinutes;
    final negativeDays = (next.simulationMinutes - negativeSince) / 1440;
    final currentLoan = next.activeLoan;

    if (currentLoan == null) {
      if (negativeDays >= 14) {
        return _triggerInsolvency(
          next,
          'Компания две недели не вышла из отрицательного баланса и осталась без финансирования.',
        );
      }
      if (negativeDays >= 7 && !next.creditOffered) {
        return _withFeed(
          next.copyWith(
            negativeCashSinceMinutes: negativeSince,
            creditOffered: true,
          ),
          'Баланс отрицательный уже неделю. Банк готов рассмотреть экстренный кредит в разделе «Финансы». Решение зависит от продуктов, burn и рисков.',
        );
      }
      return next.copyWith(negativeCashSinceMinutes: negativeSince);
    }

    if (currentLoan.repaidFraction < 0.70) {
      return _triggerInsolvency(
        next,
        'Компания снова ушла в минус, пока погашено меньше 70% кредита.',
      );
    }
    if (!next.liquidityGraceUsed) {
      return _withFeed(
        next.copyWith(
          negativeCashSinceMinutes: next.simulationMinutes,
          liquidityGraceUsed: true,
        ),
        'Погашено больше 70% кредита. Банк дал последнюю неделю на восстановление ликвидности.',
      );
    }
    if (negativeDays >= 7) {
      return _triggerInsolvency(
        next,
        'Последняя неделя после почти погашенного кредита закончилась, баланс всё ещё отрицательный.',
      );
    }
    return next.copyWith(negativeCashSinceMinutes: negativeSince);
  }

  GameState _triggerInsolvency(GameState state, String reason) {
    if (state.gameOver) {
      return state;
    }
    return _withNews(
      _withFeed(
        state.copyWith(
          criticalEvent: CriticalEventType.insolvency,
          paused: true,
          gameOver: true,
        ),
        reason,
      ),
      NewsItem(
        id: 'insolvency_${state.simulationMinutes}',
        kind: NewsKind.finance,
        title: 'Компания неплатёжеспособна',
        body: reason,
        simulationMinutes: state.simulationMinutes,
        critical: true,
      ),
    );
  }

  GameState _advanceClientContracts(GameState state, int deltaMinutes) {
    if (state.activeContracts.isEmpty || deltaMinutes <= 0) return state;
    var cashDelta = 0.0;
    final messages = <String>[];
    final transactions = <FinanceTransaction>[];
    final updated = state.clientContracts
        .map((contract) {
          if (contract.status != ContractStatus.active) return contract;
          final template = ContractCatalog.byId(contract.templateId);
          final roleCoverage = state.contractRoleCoverageFor(contract.id);
          final effectiveCapacity =
              state.contractDevelopmentCapacityFor(contract.id) *
              (0.45 + roleCoverage * 0.55);
          final previousMinutes = state.simulationMinutes - deltaMinutes;
          final graceDeadline =
              contract.deadlineAtMinutes + template.graceDays * 1440;
          final minutesBeforeGraceEnd = math.max(
            0,
            graceDeadline - previousMinutes,
          );
          final workableMinutes = math.min(deltaMinutes, minutesBeforeGraceEnd);
          final productiveHours = _workingHoursBetween(
            previousMinutes,
            workableMinutes,
          );
          final progressDelta =
              productiveHours *
              (0.30 + effectiveCapacity / 80) /
              template.developmentHours;
          final nextProgress = math
              .min(1, contract.progress + progressDelta)
              .toDouble();
          var milestonePaid = contract.milestonePaid;
          if (!milestonePaid && nextProgress >= 0.5) {
            final milestone = contract.reward * 0.35;
            cashDelta += milestone;
            milestonePaid = true;
            messages.add(
              '${template.client}: этап 50% принят. Получено ${milestone.round()} ₽.',
            );
            transactions.add(
              FinanceTransaction(
                id: 'contract_milestone_${contract.id}_${state.simulationMinutes}',
                simulationMinutes: state.simulationMinutes,
                amount: milestone,
                category: FinanceTransactionCategory.contract,
                description: 'Этап 50% • ${template.name}',
              ),
            );
          }
          if (nextProgress >= 1) {
            final remainingReward =
                contract.reward * (1 - template.upfrontPercent - 0.35);
            cashDelta += remainingReward;
            messages.add(
              '${template.client}: контракт «${template.name}» завершён. Получено ${remainingReward.round()} ₽.',
            );
            transactions.add(
              FinanceTransaction(
                id: 'contract_complete_${contract.id}_${state.simulationMinutes}',
                simulationMinutes: state.simulationMinutes,
                amount: remainingReward,
                category: FinanceTransactionCategory.contract,
                description: 'Финальная выплата • ${template.name}',
              ),
            );
            return contract.copyWith(
              status: ContractStatus.completed,
              progress: 1,
              milestonePaid: milestonePaid,
            );
          }
          if (state.simulationMinutes >= graceDeadline) {
            final unpaidFraction =
                1 - template.upfrontPercent - (milestonePaid ? 0.35 : 0);
            final partialPayment = math
                .max(0, contract.reward * unpaidFraction * nextProgress * 0.55)
                .toDouble();
            cashDelta += partialPayment;
            messages.add(
              '${template.client}: допустимый срок срыва ${template.graceDays} дн. закончился. Выплачено ${partialPayment.round()} ₽ за фактическую готовность ${(nextProgress * 100).round()}%.',
            );
            if (partialPayment > 0) {
              transactions.add(
                FinanceTransaction(
                  id: 'contract_partial_${contract.id}_${state.simulationMinutes}',
                  simulationMinutes: state.simulationMinutes,
                  amount: partialPayment,
                  category: FinanceTransactionCategory.contract,
                  description: 'Частичная выплата • ${template.name}',
                ),
              );
            }
            return contract.copyWith(
              status: ContractStatus.failed,
              progress: nextProgress,
              milestonePaid: milestonePaid,
            );
          }
          return contract.copyWith(
            progress: nextProgress,
            milestonePaid: milestonePaid,
          );
        })
        .toList(growable: false);

    final activeIds = updated
        .where((item) => item.status == ContractStatus.active)
        .map((item) => item.id)
        .toSet();
    var next = state.copyWith(
      cash: state.cash + cashDelta,
      clientContracts: updated,
      contractEmployeeAssignments: state.contractEmployeeAssignments
          .where((item) => activeIds.contains(item.contractId))
          .toList(growable: false),
      financeTransactions: <FinanceTransaction>[
        ...transactions.reversed,
        ...state.financeTransactions,
      ].take(120).toList(growable: false),
    );
    for (final message in messages) {
      next = _withFeed(next, message);
    }
    return next;
  }

  GameState _refreshCandidateMarket(GameState state, int day) {
    final week = day ~/ 7;
    final existingIds = state.candidates.map((item) => item.id).toSet();
    final usedNames = <String>{
      ...state.candidates.map((item) => item.name),
      ...state.employees.map((item) => item.name),
    };
    final additions = CandidateMarketCatalog.weeklyArrivals(
      seed: state.rngSeed,
      week: week,
    )
        .where(
          (candidate) =>
              !existingIds.contains(candidate.id) &&
              !usedNames.contains(candidate.name),
        )
        .toList(growable: false);
    if (additions.isEmpty) return state;
    final market = <Candidate>[...state.candidates, ...additions];
    final capped = market.length <= CandidateMarketCatalog.maximumVisibleCandidates
        ? market
        : market.sublist(
            market.length - CandidateMarketCatalog.maximumVisibleCandidates,
          );
    return _withFeed(
      state.copyWith(candidates: capped),
      'Рынок труда обновился: ${additions.length} новых профилей с разным грейдом и зарплатой.',
    );
  }

  _DailyResult _dailyEvents(GameState state, int day, int counter) {
    var next = state;
    var nextCounter = counter;
    if (day > 0 && day % 7 == 0) {
      next = _refreshCandidateMarket(next, day);
    }

    final liveProducts = next.products
        .where((product) => product.stage == ProductStage.live)
        .toList(growable: false);
    final rivalEventRoll = _random01(next.rngSeed, nextCounter++);
    if (rivalEventRoll < 0.34) {
      final rivalMove = _simulateRivalMove(next, liveProducts, nextCounter);
      next = rivalMove.state;
      nextCounter = rivalMove.counter;
    }
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

    final pressureRoll = _random01(next.rngSeed, nextCounter++);
    if (pressureRoll < 0.18 && next.criticalEvent == CriticalEventType.none) {
      final pressure = _applyCompetitorPressure(
        next,
        liveProducts,
        nextCounter,
      );
      next = pressure.state;
      nextCounter = pressure.counter;
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

  _DailyResult _simulateRivalMove(
    GameState state,
    List<Product> liveProducts,
    int counter,
  ) {
    final rivals = GameCatalog.marketCompanies
        .where((company) => !state.acquiredCompanyIds.contains(company.id))
        .toList(growable: false);
    if (rivals.isEmpty) return _DailyResult(state, counter);

    final companyRoll = _random01(state.rngSeed, counter++);
    final companyIndex = (companyRoll * rivals.length)
        .floor()
        .clamp(0, rivals.length - 1)
        .toInt();
    final company = rivals[companyIndex];
    final matching = liveProducts
        .where((product) => product.category == company.category)
        .toList(growable: false)
      ..sort((a, b) => b.users.compareTo(a.users));
    final target = matching.isEmpty ? null : matching.first;
    final actionRoll = _random01(state.rngSeed, counter++);
    final canThreatenControl =
        target != null &&
        company.valuation > state.valuation * 1.4 &&
        state.founderOwnershipPercent < 82;
    final action = canThreatenControl && actionRoll < 0.22
        ? 5
        : (actionRoll * 5).floor().clamp(0, 4).toInt();
    final audienceMillions = math.max(1, (company.users / 1000000).round());

    final (title, body) = switch (action) {
      0 => (
        '${company.productName}: крупный продуктовый релиз',
        '${company.companyName} выкатила пакет новых возможностей для аудитории около $audienceMillions млн пользователей. Команда делает ставку на удержание и ускорение ключевых сценариев.',
      ),
      1 => (
        '${company.companyName} наращивает инфраструктуру',
        'Конкурент направляет около ${(company.monthlyRevenue * 0.9).round()} ₽ в compute, reliability и безопасность. Это снижает пространство для слабых продуктов той же категории.',
      ),
      2 => (
        '${company.companyName} усиливает дистрибуцию',
        target == null
            ? 'Компания расширяет маркетинг и партнёрства, используя базу примерно $audienceMillions млн пользователей.'
            : 'Новая кампания напрямую конкурирует с ${target.name}. Оценочный месячный бюджет — ${(company.monthlyRevenue * 0.35).round()} ₽.',
      ),
      3 => (
        '${company.companyName} закрыла M&A-сделку',
        'Рыночный игрок поглотил нишевую технологическую команду примерно за ${(company.valuation * 0.015).round()} ₽ и интегрирует её технологию в ${company.productName}.',
      ),
      4 => (
        '${company.productName} меняет коммерческую стратегию',
        target == null
            ? 'Конкурент тестирует новые тарифы и пакетные предложения, чтобы увеличить конверсию своей крупной аудитории.'
            : 'Цены и пакеты перестраиваются вокруг сегмента ${target.name}; без свежего roadmap и бренда давление на удержание будет расти.',
      ),
      _ => (
        '${company.companyName} изучает поглощение вашей компании',
        'Банкиры конкурента контактируют с внешними инвесторами. Прямой захват невозможен, пока у основателя контрольный пакет, но при доле ниже 50% кампания закончится потерей контроля.',
      ),
    };

    return _DailyResult(
      _withNews(
        state,
        NewsItem(
          id: 'rival_${company.id}_${state.simulationMinutes}_$action',
          kind: NewsKind.competitor,
          title: title,
          body: body,
          simulationMinutes: state.simulationMinutes,
          critical: false,
        ),
      ),
      counter,
    );
  }

  _DailyResult _applyCompetitorPressure(
    GameState state,
    List<Product> liveProducts,
    int counter,
  ) {
    final ranked = List<Product>.of(liveProducts)
      ..sort((left, right) {
        final leftScore =
            left.qualityScore * 0.45 +
            left.featureCoverage * 100 * 0.25 +
            left.brandTrust * 100 * 0.18 +
            state.productFreshnessScore(left) * 0.12;
        final rightScore =
            right.qualityScore * 0.45 +
            right.featureCoverage * 100 * 0.25 +
            right.brandTrust * 100 * 0.18 +
            state.productFreshnessScore(right) * 0.12;
        return leftScore.compareTo(rightScore);
      });
    final product = ranked.first;
    final competitor = GameCatalog.competitorFor(product.category);
    final competitorScore =
        competitor.designScore * 0.28 +
        competitor.securityScore * 0.30 +
        competitor.reliability * 100 * 0.22 +
        20;
    final ownScore =
        product.qualityScore * 0.42 +
        product.featureCoverage * 100 * 0.24 +
        product.brandTrust * 100 * 0.18 +
        state.productFreshnessScore(product) * 0.16;
    final gap = ((competitorScore - ownScore) / 100).clamp(0, 0.65).toDouble();
    final team = state.employeesForProduct(product.id);
    final hasGrowth = team.any(
      (employee) => employee.role == EmployeeRole.growth,
    );
    final hasProductManager = team.any(
      (employee) => employee.role == EmployeeRole.productManager,
    );
    final activeAds = state.activeCampaignsFor(product.id).isNotEmpty;
    final mitigation =
        (hasGrowth ? 0.07 : 0) +
        (hasProductManager ? 0.04 : 0) +
        (activeAds ? 0.04 : 0) +
        product.brandTrust * 0.06;
    final chance = (0.025 + gap * 0.42 - mitigation)
        .clamp(0.005, 0.32)
        .toDouble();
    final roll = _random01(state.rngSeed, counter++);
    if (roll >= chance || gap <= 0.02) {
      return _DailyResult(state, counter);
    }

    final severity = (0.025 + gap * 0.13).clamp(0.025, 0.12).toDouble();
    final lostUsers = (product.users * severity).round();
    final products = state.products
        .map(
          (item) => item.id == product.id
              ? item.copyWith(
                  users: math.max(0, item.users - lostUsers).toInt(),
                  mau: math
                      .max(0, item.mau - (lostUsers * 0.70).round())
                      .toInt(),
                  dau: math
                      .max(0, item.dau - (lostUsers * 0.22).round())
                      .toInt(),
                  brandTrust: math
                      .max(0.01, item.brandTrust - severity * 0.18)
                      .toDouble(),
                )
              : item,
        )
        .toList(growable: false);
    final reasons = <String>[
      if (product.featureCoverage < 0.75) 'неполный roadmap',
      if (state.productFreshnessScore(product) < 75) 'устаревание',
      if (product.brandTrust < 0.18) 'низкое доверие',
      if (!hasGrowth) 'нет Growth в команде',
      if (!hasProductManager) 'нет Product Manager',
    ];
    final reasonText = reasons.isEmpty
        ? 'разрыв по качеству'
        : reasons.join(', ');
    final next = _withNews(
      _withFeed(
        state.copyWith(products: products),
        '${competitor.productName} забрал $lostUsers пользователей у ${product.name}: $reasonText.',
      ),
      NewsItem(
        id: 'competitive_pressure_${product.id}_${state.simulationMinutes}',
        kind: NewsKind.competitor,
        title: '${competitor.productName} усилил давление',
        body:
            '${product.name} потерял $lostUsers пользователей. Причины: $reasonText. Это можно снизить обновлениями, сильной командой, рекламой и ростом доверия.',
        simulationMinutes: state.simulationMinutes,
        critical: false,
      ),
    );
    return _DailyResult(next, counter);
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
    final strategy = ProductStrategyCatalog.strategyFor(action.blueprintId);
    final frameworkStrategy = ProductStrategyCatalog.frameworkProfile(
      action.frameworkId,
    );
    if (!strategy.allowedFrameworkIds.contains(action.frameworkId) ||
        !framework.supportedCategories.contains(blueprint.category)) {
      return _withFeed(
        state,
        'Этот framework не подходит выбранному масштабу продукта.',
      );
    }
    final technologyLimit = ProductConfigurationResolver.technologyLimit(
      state: state,
      blueprintId: action.blueprintId,
      frameworkId: action.frameworkId,
      featureIds: action.featureIds,
      selectedTechnologyIds: action.technologyIds,
    );
    if (action.technologyIds.length > technologyLimit.allowed) {
      return _withFeed(
        state,
        '${blueprint.name}: максимум ${technologyLimit.allowed} технологий, выбрано ${action.technologyIds.length}. ${technologyLimit.reasons.join(' ')}',
      );
    }
    final mandatoryTechnology =
        ProductConfigurationResolver.mandatoryTechnologyId(action.frameworkId);
    if (mandatoryTechnology != null &&
        !action.technologyIds.contains(mandatoryTechnology)) {
      return _withFeed(
        state,
        '${framework.name} требует технологию ${GameCatalog.technologyById(mandatoryTechnology).name}.',
      );
    }
    final sortedTechnologies = action.technologyIds.toList()..sort();
    for (final technologyId in sortedTechnologies) {
      final technology = GameCatalog.technologyById(technologyId);
      final availability = ProductConfigurationResolver.availability(
        frameworkId: action.frameworkId,
        languageIds: action.languageIds,
        selectedTechnologyIds: action.technologyIds,
        technology: technology,
      );
      if (!availability.enabled) {
        return _withFeed(
          state,
          '${technology.name}: ${availability.reason} ${availability.nextStep}',
        );
      }
    }
    final languageLimit = LanguageLimitResolver.resolve(
      blueprintId: action.blueprintId,
      frameworkId: action.frameworkId,
    );
    if (action.languageIds.length > languageLimit.allowed) {
      return _withFeed(
        state,
        '${blueprint.name}: максимум ${languageLimit.allowed} языков для ${framework.name}. ${languageLimit.reasons.join(' ')}',
      );
    }
    final missingFrameworkLanguages = frameworkStrategy.requiredLanguageIds
        .where((id) => !action.languageIds.contains(id))
        .toList(growable: false);
    if (missingFrameworkLanguages.isNotEmpty) {
      return _withFeed(
        state,
        '${framework.name} требует: ${missingFrameworkLanguages.map((id) => GameCatalog.languageById(id).name).join(', ')}.',
      );
    }
    if (state.investorAgreements.length < strategy.requiredInvestorCount) {
      return _withFeed(
        state,
        '${blueprint.name}: нужно инвесторов ${strategy.requiredInvestorCount}, сейчас ${state.investorAgreements.length}.',
      );
    }
    final validFeatures = action.featureIds.every(
      (id) => GameCatalog.featureById(
        id,
      ).supportedCategories.contains(blueprint.category),
    );
    if (!validFeatures) {
      return state;
    }
    if (action.monetization != null &&
        !strategy.allowedMonetizationModels.contains(action.monetization)) {
      return _withFeed(
        state,
        'Эта модель монетизации недоступна для ${blueprint.name}.',
      );
    }

    final projection = ProductProjectionCache.estimate(
      blueprintId: action.blueprintId,
      frameworkId: action.frameworkId,
      languageIds: action.languageIds,
      technologyIds: action.technologyIds,
      featureIds: action.featureIds,
    );
    final effectiveSetupCost =
        projection.developmentCost * state.founderProductSetupMultiplier;
    if (state.cash < effectiveSetupCost) {
      return _withFeed(
        state,
        'Недостаточно денег на стартовую настройку: нужно ${effectiveSetupCost.round()} ₽. Функции отдельно не покупаются — дальше оплачиваются зарплаты и инфраструктура.',
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
      monetization:
          action.monetization != null &&
              strategy.allowedMonetizationModels.contains(action.monetization)
          ? action.monetization!
          : strategy.allowedMonetizationModels.first,
      marketingBudget: 0,
      allocatedCapacityPercent: initialAllocation,
      computeMultiplier: projection.computeMultiplier,
      createdAtMinutes: state.simulationMinutes,
      acquired: false,
      brandAwareness: 0,
      brandTrust: strategy.initialTrust,
      priceSentiment: 0,
    );

    return _withNews(
      _withFeed(
        state.copyWith(
          cash: state.cash - effectiveSetupCost,
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
        '${product.name}: стартовая настройка ${effectiveSetupCost.round()} ₽, объём ${projection.developmentHours.round()} рабочих часов. Дальше расходы идут через зарплаты и инфраструктуру.',
      ),
      NewsItem(
        id: 'product_created_${product.id}',
        kind: NewsKind.product,
        title: 'Новый продукт в разработке',
        body:
            '${product.name}: ${framework.name}, ${action.featureIds.length} функций, coherence ${(projection.stackCoherence * 100).round()}%.',
        simulationMinutes: state.simulationMinutes,
        critical: false,
      ),
    );
  }

  GameState _sellProduct(GameState state, String productId) {
    final product = state.productById(productId);
    if (product == null || product.stage != ProductStage.live) {
      return state;
    }
    final buyer = state.productBuyerFor(product);
    final value = state.productSaleValue(product);
    var next = state.copyWith(
      cash: state.cash + value,
      products: state.products
          .where((item) => item.id != product.id)
          .toList(growable: false),
      employeeAssignments: state.employeeAssignments
          .where((item) => item.productId != product.id)
          .toList(growable: false),
      securityControls: state.securityControls
          .where((item) => item.productId != product.id)
          .toList(growable: false),
      securityAudits: state.securityAudits
          .where((item) => item.productId != product.id)
          .toList(growable: false),
      productAiDeployments: state.productAiDeployments
          .where((item) => item.productId != product.id)
          .toList(growable: false),
      productAiIntegrations: state.productAiIntegrations
          .where(
            (item) =>
                item.aiProductId != product.id &&
                item.targetProductId != product.id,
          )
          .toList(growable: false),
      productImprovements: state.productImprovements
          .where((item) => item.productId != product.id)
          .toList(growable: false),
      productUpdates: state.productUpdates
          .where((item) => item.productId != product.id)
          .toList(growable: false),
      monetizationChanges: state.monetizationChanges
          .where((item) => item.productId != product.id)
          .toList(growable: false),
      advertisingCampaigns: state.advertisingCampaigns
          .where((item) => item.productId != product.id)
          .toList(growable: false),
      priceChanges: state.priceChanges
          .where((item) => item.productId != product.id)
          .toList(growable: false),
      productFeatureDevelopments: state.productFeatureDevelopments
          .where((item) => item.productId != product.id)
          .toList(growable: false),
      productMetricHistory: state.productMetricHistory
          .where((item) => item.productId != product.id)
          .toList(growable: false),
      ecosystemLinks: state.ecosystemLinks
          .where((item) => !item.contains(product.id))
          .toList(growable: false),
      investorOffers: state.investorOffers
          .where((item) => item.productId != product.id)
          .toList(growable: false),
      financeTransactions: <FinanceTransaction>[
        FinanceTransaction(
          id: 'product_sale_${buyer.id}_${product.id}_${state.simulationMinutes}',
          simulationMinutes: state.simulationMinutes,
          amount: value,
          category: FinanceTransactionCategory.product,
          description:
              'Продажа продукта • ${product.name} → ${buyer.companyName}',
        ),
        ...state.financeTransactions,
      ].take(120).toList(growable: false),
    );
    next = _recalculateTeamWorkload(next);
    return _withNews(
      _withFeed(
        next,
        '${product.name} продан компании ${buyer.companyName} за ${value.round()} ₽.',
      ),
      NewsItem(
        id: 'product_sale_${buyer.id}_${product.id}_${state.simulationMinutes}',
        kind: NewsKind.acquisition,
        title: '${buyer.companyName} купила ${product.name}',
        body:
            'Цена сделки учла аудиторию, обновления и качество продукта относительно рынка.',
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
                  users: item.blueprintId == 'company_website' ? 35 : 60,
                  mau: item.blueprintId == 'company_website' ? 28 : 42,
                  dau: item.blueprintId == 'company_website' ? 5 : 12,
                  activationRate: 0.32,
                  retention30d: 0.38,
                  churnRate: 0.12,
                  rating: math.max(2.2, item.qualityScore / 20).toDouble(),
                  brandAwareness: item.blueprintId == 'company_website'
                      ? 0.08
                      : 0.03,
                  brandTrust: math.max(0.04, item.brandTrust).toDouble(),
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
        product.stage != ProductStage.live ||
        product.featureIds.contains(featureId)) {
      return state;
    }
    if (state.activeFeatureDevelopmentFor(productId) != null) {
      return _withFeed(
        state,
        '${product.name}: сначала завершите текущее обновление.',
      );
    }

    final feature = GameCatalog.featureById(featureId);
    if (!feature.supportedCategories.contains(product.category)) {
      return state;
    }

    final requiredHours =
        (math.max(24, feature.developmentCost / 450 * 1.25) *
                state.founderImprovementMultiplier)
            .toDouble();
    final work = ProductFeatureDevelopment(
      productId: product.id,
      featureId: feature.id,
      startedAtMinutes: state.simulationMinutes,
      requiredHours: requiredHours,
      progress: 0,
    );
    return _withFeed(
      state.copyWith(
        productFeatureDevelopments: <ProductFeatureDevelopment>[
          ...state.productFeatureDevelopments,
          work,
        ],
      ),
      '${product.name}: «${feature.name}» добавлена в разработку. Нужно ${requiredHours.round()} рабочих часов; отдельной покупки нет, расходы идут через зарплаты и инфраструктуру.',
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
        '${product.name}: технические улучшения доступны после выхода на рынок.',
      );
    }
    if (state.activeFeatureDevelopmentFor(productId) != null) {
      return _withFeed(
        state,
        '${product.name}: сначала завершите текущую техническую работу.',
      );
    }
    final option = ProductEvolutionCatalog.improvementByType(type);
    final level = state.improvementLevel(productId, type) + 1;
    final requiredHours = state.improvementRequiredHours(productId, type);
    final work = ProductFeatureDevelopment(
      productId: productId,
      featureId: '__improvement_${type.name}_$level',
      startedAtMinutes: state.simulationMinutes,
      requiredHours: requiredHours,
      progress: 0,
    );
    return _withFeed(
      state.copyWith(
        productFeatureDevelopments: <ProductFeatureDevelopment>[
          ...state.productFeatureDevelopments,
          work,
        ],
      ),
      '${product.name}: «${option.name}» поставлено в работу на ${requiredHours.round()} рабочих часов. Отдельного списания нет — компания оплачивает зарплаты и инфраструктуру во времени.',
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
    final strategy = ProductStrategyCatalog.strategyFor(product.blueprintId);
    if (!strategy.allowedMonetizationModels.contains(model)) {
      return _withFeed(
        state,
        '${product.name}: эта модель монетизации не подходит выбранному продукту.',
      );
    }
    final remainingDays = state.monetizationCooldownRemainingDays(productId);
    if (product.stage == ProductStage.live && remainingDays > 0) {
      return _withFeed(
        state,
        '${product.name}: модель монетизации можно сменить через $remainingDays дн.',
      );
    }
    final changes = product.stage == ProductStage.live
        ? <ProductMonetizationChange>[
            ...state.monetizationChanges,
            ProductMonetizationChange(
              productId: productId,
              model: model,
              changedAtMinutes: state.simulationMinutes,
            ),
          ]
        : state.monetizationChanges;
    return _withFeed(
      state.copyWith(
        monetizationChanges: changes,
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
    if ((normalized - product.price).abs() < 0.5) {
      return state;
    }
    final forecast = state.priceImpactForecast(product, normalized);
    final change = ProductPriceChange(
      productId: product.id,
      previousPrice: product.price,
      newPrice: normalized,
      changedAtMinutes: state.simulationMinutes,
      initialSentimentShock: forecast.sentimentShock,
    );
    return _withFeed(
      state.copyWith(
        priceChanges: <ProductPriceChange>[...state.priceChanges, change],
        products: state.products
            .map(
              (item) => item.id == productId
                  ? item.copyWith(
                      price: normalized,
                      priceSentiment: forecast.sentimentShock,
                    )
                  : item,
            )
            .toList(growable: false),
      ),
      '${product.name}: цена ${normalized.round()} ₽/мес. Прогноз пользователей ${(forecast.expectedUserChangePercent * 100).toStringAsFixed(1)}%, выручка ${forecast.expectedRevenueAfter.round()} ₽/мес. Реакция рынка сгладится примерно за 45 дней.',
    );
  }

  GameState _setMarketingBudget(
    GameState state,
    String productId,
    double monthlyBudget,
  ) {
    final product = state.productById(productId);
    if (product == null) {
      return state;
    }
    return _withFeed(
      state,
      '${product.name}: общий рекламный бюджет отключён. Выберите агентство, канал, CPM/CPC и прогноз пользователей в карточке продукта.',
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

  GameState _hireCandidate(GameState state, String candidateId) =>
      _hireCandidateInternal(state, candidateId);

  GameState _hireCandidateInternal(
    GameState state,
    String candidateId, {
    double salaryMultiplier = 1,
    double bonusMultiplier = 1,
  }) {
    final candidate = state.candidateById(candidateId);
    if (candidate == null) return state;
    if (!candidate.remote &&
        state.onSiteEmployeeCount >= state.office.capacity) {
      return _withFeed(
        state,
        'Найм заблокирован: все ${state.office.capacity} офисных мест заняты. Remote-кандидаты доступны.',
      );
    }
    final employerBrandDiscount = state.office.hiringBoostPercent
        .clamp(0, 0.45)
        .toDouble();
    final founderSalaryMultiplier = state.founderSalaryMultiplier;
    final signingBonus =
        candidate.salary *
        0.15 *
        bonusMultiplier *
        founderSalaryMultiplier *
        (1 - employerBrandDiscount);
    if (state.cash < signingBonus) {
      return _withFeed(state, 'Недостаточно денег на бонус при найме.');
    }
    final employee = candidate.toEmployee(
      hiredAtMinutes: state.simulationMinutes,
      salaryMultiplier: salaryMultiplier * founderSalaryMultiplier,
    );
    return _withFeed(
      state.copyWith(
        cash: state.cash - signingBonus,
        candidates: state.candidates
            .where((item) => item.id != candidateId)
            .toList(growable: false),
        employees: <Employee>[...state.employees, employee],
        financeTransactions: <FinanceTransaction>[
          FinanceTransaction(
            id: 'signing_${candidate.id}_${state.simulationMinutes}',
            simulationMinutes: state.simulationMinutes,
            amount: -signingBonus,
            category: FinanceTransactionCategory.payroll,
            description: 'Бонус при найме • ${candidate.name}',
          ),
          ...state.financeTransactions,
        ].take(120).toList(growable: false),
      ),
      '${candidate.name} принят. Зарплата ${employee.salary.round()} ₽/мес., бонус при найме ${signingBonus.round()} ₽.',
    );
  }

  GameState _hireCandidateForProduct(
    GameState state,
    String candidateId,
    String productId,
  ) {
    if (state.productById(productId) == null) return state;
    final candidate = state.candidateById(candidateId);
    if (candidate?.isHr ?? false) {
      return _withFeed(
        state,
        'HR нанимается в разделе «Команда» и не назначается как специалист продукта.',
      );
    }
    final hired = _hireCandidateInternal(state, candidateId);
    if (hired.employeeById(candidateId) == null) return hired;
    return _assignEmployee(hired, candidateId, productId);
  }

  GameState _autoHireProjectTeam(GameState state, String productId) {
    final product = state.productById(productId);
    if (product == null) return state;
    if (!state.employees.any((employee) => employee.isHr)) {
      return _withFeed(
        state,
        '${product.name}: автоматический подбор заблокирован — сначала наймите HR / People Partner в разделе «Команда».',
      );
    }

    var next = state;
    var hiredCount = 0;
    final plan = state.roleRequirementsFor(product).toList(growable: false)
      ..sort((left, right) => left.role.index.compareTo(right.role.index));

    for (final requirement in plan) {
      var missing =
          requirement.minimumCount -
          next.assignedRoleCount(productId, requirement.role);
      while (missing > 0) {
        final candidates =
            next.candidates
                .where((candidate) => !candidate.isHr)
                .where((candidate) => candidate.role == requirement.role)
                .where(
                  (candidate) =>
                      candidate.remote ||
                      next.onSiteEmployeeCount < next.office.capacity,
                )
                .toList(growable: false)
              ..sort((left, right) {
                final leftLanguage =
                    left.languageIds.any(product.languageIds.contains) ? 1 : 0;
                final rightLanguage =
                    right.languageIds.any(product.languageIds.contains) ? 1 : 0;
                if (leftLanguage != rightLanguage) {
                  return rightLanguage.compareTo(leftLanguage);
                }
                final qualityScore =
                    (right.skill + right.quality + right.reliability).compareTo(
                      left.skill + left.quality + left.reliability,
                    );
                if (qualityScore != 0) return qualityScore;
                final salary = left.salary.compareTo(right.salary);
                if (salary != 0) return salary;
                return left.id.compareTo(right.id);
              });

        if (candidates.isEmpty) break;
        final candidate = candidates.first;
        final beforeEmployees = next.employees.length;
        next = _hireCandidateInternal(
          next,
          candidate.id,
          salaryMultiplier: 1.25,
          bonusMultiplier: 1.25,
        );
        if (next.employees.length == beforeEmployees) break;
        next = _assignEmployee(next, candidate.id, productId);
        hiredCount += 1;
        missing -= 1;
      }
    }

    final remaining = state
        .roleRequirementsFor(product)
        .fold<int>(
          0,
          (sum, requirement) =>
              sum +
              math
                  .max(
                    0,
                    requirement.minimumCount -
                        next.assignedRoleCount(productId, requirement.role),
                  )
                  .toInt(),
        );

    return _withFeed(
      next,
      hiredCount == 0
          ? remaining == 0
                ? '${product.name}: минимальный состав уже закрыт. HR никого лишнего не нанял.'
                : '${product.name}: HR не нашёл кандидатов на $remaining незакрытых мест.'
          : '${product.name}: HR нанял ровно $hiredCount специалистов по минимальному плану проекта. Лишний запас не создаётся.',
    );
  }

  List<EmployeeAssignment> _normalizeProductAllocations(
    List<EmployeeAssignment> source,
  ) {
    final counts = <String, int>{};
    for (final item in source) {
      counts.update(item.employeeId, (value) => value + 1, ifAbsent: () => 1);
    }
    return source
        .map(
          (item) => item.copyWith(
            allocationPercent: 100 / (counts[item.employeeId] ?? 1),
          ),
        )
        .toList(growable: false);
  }

  GameState _recalculateTeamWorkload(GameState state) {
    final employees = state.employees
        .map((employee) {
          final count = state.activeAssignmentCountForEmployee(employee.id);
          final workload = switch (count) {
            0 => 18,
            1 => 35,
            2 => 65,
            3 => 82,
            _ => 96,
          };
          return employee.managedCopyWith(workload: workload);
        })
        .toList(growable: false);
    return state.copyWith(employees: employees);
  }

  GameState _setProductTeam(
    GameState state,
    String productId,
    List<String> employeeIds,
  ) {
    final product = state.productById(productId);
    if (product == null) {
      return state;
    }
    final selected = employeeIds.toSet();
    if (selected.any((id) => state.employeeById(id) == null)) {
      return state;
    }
    final blocked = selected.where(
      (id) =>
          state.assignmentForEmployeeOnProduct(id, productId) == null &&
          !state.canAssignEmployeeToMoreWork(id),
    );
    if (blocked.isNotEmpty) {
      return _withFeed(
        state,
        'Нельзя назначить сотрудника больше чем на 4 активные работы.',
      );
    }
    final assignments = state.employeeAssignments
        .where((item) => item.productId != productId)
        .toList(growable: true);
    for (final employeeId in selected) {
      assignments.add(
        EmployeeAssignment(
          employeeId: employeeId,
          productId: productId,
          assignedAtMinutes: state.simulationMinutes,
        ),
      );
    }
    final next = _recalculateTeamWorkload(
      state.copyWith(
        employeeAssignments: _normalizeProductAllocations(assignments),
      ),
    );
    return _withFeed(
      next,
      '${product.name}: команда сохранена, сотрудников ${selected.length}. До 4 параллельных работ на человека; эффективность 100% → 70% → 55% → 40%.',
    );
  }

  GameState _autoHireContractTeam(GameState state, String contractId) {
    final contract = state.contractById(contractId);
    if (contract == null || contract.status != ContractStatus.active) {
      return state;
    }
    final template = state.contractTemplate(contract.templateId);
    var next = state;
    final chosen = next
        .employeesForContract(contract.id)
        .toList(growable: true);
    final chosenIds = chosen.map((item) => item.id).toSet();
    final remainingRoles = <EmployeeRole>[...template.requiredRoles];
    for (final employee in chosen) {
      final index = remainingRoles.indexOf(employee.role);
      if (index >= 0) remainingRoles.removeAt(index);
    }
    var reused = 0;
    var hired = 0;

    for (final role in List<EmployeeRole>.of(remainingRoles)) {
      final available =
          next.employees
              .where(
                (employee) =>
                    !employee.isHr &&
                    employee.role == role &&
                    !chosenIds.contains(employee.id) &&
                    next.canAssignEmployeeToMoreWork(employee.id),
              )
              .toList(growable: false)
            ..sort((left, right) {
              final load = next
                  .activeAssignmentCountForEmployee(left.id)
                  .compareTo(next.activeAssignmentCountForEmployee(right.id));
              if (load != 0) return load;
              final skill = right.skill.compareTo(left.skill);
              if (skill != 0) return skill;
              return left.id.compareTo(right.id);
            });
      if (available.isNotEmpty) {
        final employee = available.first;
        chosen.add(employee);
        chosenIds.add(employee.id);
        remainingRoles.remove(role);
        reused += 1;
      }
    }

    for (final role in List<EmployeeRole>.of(remainingRoles)) {
      final candidates =
          next.candidates
              .where((candidate) => !candidate.isHr && candidate.role == role)
              .where(
                (candidate) =>
                    candidate.remote || next.availableOfficeSeats > 0,
              )
              .toList(growable: false)
            ..sort((left, right) {
              final l =
                  left.skill * 2 + left.speed + left.quality + left.reliability;
              final r =
                  right.skill * 2 +
                  right.speed +
                  right.quality +
                  right.reliability;
              final score = r.compareTo(l);
              if (score != 0) return score;
              return left.salary.compareTo(right.salary);
            });
      if (candidates.isEmpty) continue;
      final candidate = candidates.first;
      final bonus = candidate.salary * 0.10 * next.founderSalaryMultiplier;
      if (next.cash < bonus) continue;
      final employee = candidate.toEmployee(
        hiredAtMinutes: next.simulationMinutes,
        salaryMultiplier: next.founderSalaryMultiplier,
      );
      next = next.copyWith(
        cash: next.cash - bonus,
        employees: <Employee>[...next.employees, employee],
        candidates: next.candidates
            .where((item) => item.id != candidate.id)
            .toList(growable: false),
        financeTransactions: <FinanceTransaction>[
          FinanceTransaction(
            id: 'contract_hire_${contract.id}_${candidate.id}_${next.simulationMinutes}',
            simulationMinutes: next.simulationMinutes,
            amount: -bonus,
            category: FinanceTransactionCategory.payroll,
            description:
                'Найм под контракт • ${template.name} • ${candidate.name}',
          ),
          ...next.financeTransactions,
        ].take(120).toList(growable: false),
      );
      chosen.add(employee);
      chosenIds.add(employee.id);
      remainingRoles.remove(role);
      hired += 1;
    }

    // Final normalization protects the engine from spare roles and duplicate counts.
    final normalized = <Employee>[];
    final exactRoles = <EmployeeRole>[...template.requiredRoles];
    for (final employee in chosen) {
      final index = exactRoles.indexOf(employee.role);
      if (index < 0) continue;
      normalized.add(employee);
      exactRoles.removeAt(index);
    }
    final assignments = <ContractEmployeeAssignment>[
      ...next.contractEmployeeAssignments.where(
        (item) => item.contractId != contract.id,
      ),
      for (final employee in normalized)
        ContractEmployeeAssignment(
          contractId: contract.id,
          employeeId: employee.id,
          assignedAtMinutes: next.simulationMinutes,
        ),
    ];
    next = _recalculateTeamWorkload(
      next.copyWith(contractEmployeeAssignments: assignments),
    );
    return _withFeed(
      next,
      '${template.name}: из штата назначено $reused, нанято $hired. '
      '${exactRoles.isEmpty ? 'Команда полностью укомплектована.' : 'Не все роли удалось закрыть.'} '
      'Лишний состав не создаётся.',
    );
  }

  GameState _setContractTeam(
    GameState state,
    String contractId,
    List<String> employeeIds,
  ) {
    final contract = state.contractById(contractId);
    if (contract == null || contract.status != ContractStatus.active) {
      return state;
    }
    final template = state.contractTemplate(contract.templateId);
    final remainingRoles = <EmployeeRole>[...template.requiredRoles];
    final selected = <String>[];
    final seen = <String>{};
    final currentlyAssigned = state
        .employeesForContract(contractId)
        .map((item) => item.id)
        .toSet();
    for (final id in employeeIds) {
      if (!seen.add(id)) continue;
      final employee = state.employeeById(id);
      if (employee == null || employee.isHr) continue;
      final atLimit =
          !currentlyAssigned.contains(id) &&
          !state.canAssignEmployeeToMoreWork(id);
      if (atLimit) continue;
      final roleIndex = remainingRoles.indexOf(employee.role);
      if (roleIndex < 0) continue;
      remainingRoles.removeAt(roleIndex);
      selected.add(id);
    }
    final assignments = state.contractEmployeeAssignments
        .where((item) => item.contractId != contractId)
        .toList(growable: true);
    for (final employeeId in selected) {
      assignments.add(
        ContractEmployeeAssignment(
          contractId: contractId,
          employeeId: employeeId,
          assignedAtMinutes: state.simulationMinutes,
        ),
      );
    }
    final next = _recalculateTeamWorkload(
      state.copyWith(contractEmployeeAssignments: assignments),
    );
    return _withFeed(
      next,
      '${template.name}: команда сохранена, сотрудников ${selected.length}. '
      'Лишние роли и сотрудники отброшены.',
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
    var assignments = state.employeeAssignments.toList(growable: true);
    if (productId == null) {
      assignments.removeWhere((item) => item.employeeId == employeeId);
    } else if (!assignments.any(
      (item) => item.employeeId == employeeId && item.productId == productId,
    )) {
      if (!state.canAssignEmployeeToMoreWork(employeeId)) {
        return _withFeed(
          state,
          '${employee.name}: максимум 4 активные работы одновременно.',
        );
      }
      assignments.add(
        EmployeeAssignment(
          employeeId: employeeId,
          productId: productId,
          assignedAtMinutes: state.simulationMinutes,
        ),
      );
    }
    assignments = _normalizeProductAllocations(assignments);
    final next = _recalculateTeamWorkload(
      state.copyWith(employeeAssignments: assignments),
    );
    final targetName = productId == null
        ? 'резерв команды'
        : state.productById(productId)!.name;
    return _withFeed(
      next,
      '${employee.name}: назначение обновлено — $targetName.',
    );
  }

  GameState _sendEmployeeOnVacation(GameState state, String employeeId) {
    final employee = state.employeeById(employeeId);
    if (employee == null) return state;
    return _withFeed(
      state.copyWith(
        employeeAssignments: state.employeeAssignments
            .where((item) => item.employeeId != employeeId)
            .toList(growable: false),
        contractEmployeeAssignments: state.contractEmployeeAssignments
            .where((item) => item.employeeId != employeeId)
            .toList(growable: false),
        employees: state.employees
            .map(
              (item) => item.id == employeeId
                  ? item.managedCopyWith(morale: 100, workload: 5)
                  : item,
            )
            .toList(growable: false),
      ),
      '${employee.name} отправлен в отпуск: morale полностью восстановлена, назначения сняты.',
    );
  }

  GameState _giveWellbeingBonus(GameState state, String employeeId) {
    final employee = state.employeeById(employeeId);
    if (employee == null) return state;
    final cost = employee.salary * 0.12;
    if (state.cash < cost) {
      return _withFeed(state, 'Недостаточно денег на корпоративный бонус.');
    }
    return _withFeed(
      state.copyWith(
        cash: state.cash - cost,
        employees: state.employees
            .map(
              (item) => item.id == employeeId
                  ? item.managedCopyWith(
                      morale: math.min(100, item.morale + 24).toInt(),
                      workload: math.max(10, item.workload - 14).toInt(),
                    )
                  : item,
            )
            .toList(growable: false),
        financeTransactions: <FinanceTransaction>[
          FinanceTransaction(
            id: 'wellbeing_${employee.id}_${state.simulationMinutes}',
            simulationMinutes: state.simulationMinutes,
            amount: -cost,
            category: FinanceTransactionCategory.payroll,
            description: 'Корпоративный бонус • ${employee.name}',
          ),
          ...state.financeTransactions,
        ].take(120).toList(growable: false),
      ),
      '${employee.name}: корпоративный бонус ${cost.round()} ₽, morale восстановлена.',
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
        contractEmployeeAssignments: state.contractEmployeeAssignments
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

  GameState _rentHostingPlan(GameState state, String planId) {
    final plan = V9ContentCatalog.hostingById(planId);
    if (plan.kind == HostingKind.owned) {
      return _migrateToOwnedInfrastructure(state);
    }
    if (plan.id == state.selectedHostingPlanId) return state;
    final employeeRoles = state.employees.map((item) => item.role.name).toSet();
    final missingRoles =
        plan.requiredRoles
            .where((role) => !employeeRoles.contains(role))
            .toList()
          ..sort();
    if (missingRoles.isNotEmpty) {
      return _withFeed(
        state,
        '${plan.name}: требуются ${missingRoles.join(', ')}. Наймите специалиста или выберите управляемый plan.',
      );
    }
    if (state.cash < plan.setupCost) {
      return _withFeed(
        state,
        '${plan.name}: не хватает ${(plan.setupCost - state.cash).round()} ₽ на setup.',
      );
    }
    return _withFeed(
      state.copyWith(
        selectedHostingPlanId: plan.id,
        cash: state.cash - plan.setupCost,
        financeTransactions: <FinanceTransaction>[
          FinanceTransaction(
            id: 'hosting_${plan.id}_${state.simulationMinutes}',
            simulationMinutes: state.simulationMinutes,
            amount: -plan.setupCost,
            category: FinanceTransactionCategory.infrastructure,
            description: 'Setup hosting • ${plan.provider} • ${plan.name}',
          ),
          ...state.financeTransactions,
        ].take(120).toList(growable: false),
      ),
      'Арендован ${plan.name}: ${plan.computeUnits.round()} compute, ${plan.storageGb.round()} GB, SLA ${(plan.sla * 100).toStringAsFixed(2)}%, ${plan.monthlyCost.round()} ₽/мес.',
    );
  }

  GameState _migrateToOwnedInfrastructure(GameState state) {
    final plan = V9ContentCatalog.hostingById('owned');
    if (state.usingOwnedInfrastructure) return state;
    final roles = state.employees.map((item) => item.role).toSet();
    final reasons = <String>[
      if (!roles.contains(EmployeeRole.devOps)) 'нет DevOps-инженера',
      if (!roles.contains(EmployeeRole.security)) 'нет Security Engineer',
      if (state.installedServers.isEmpty) 'не куплен ни один сервер',
      if (state.usedRackUnits > state.serverRoom.rackUnits)
        'не хватает rack units',
      if (state.usedPowerKw > state.serverRoom.powerKw) 'не хватает питания',
      if (state.usedCoolingKw > state.serverRoom.coolingKw)
        'не хватает охлаждения',
      if (state.cash < plan.setupCost)
        'не хватает ${(plan.setupCost - state.cash).round()} ₽',
    ]..sort();
    if (reasons.isNotEmpty) {
      return _withFeed(
        state,
        'Миграция на собственные серверы заблокирована: ${reasons.join('; ')}. Подготовьте помещение, железо и специалистов.',
      );
    }
    const migrationDays = 5;
    return _withFeed(
      state.copyWith(
        selectedHostingPlanId: 'owned',
        cash: state.cash - plan.setupCost,
        financeTransactions: <FinanceTransaction>[
          FinanceTransaction(
            id: 'owned_migration_${state.simulationMinutes}',
            simulationMinutes: state.simulationMinutes,
            amount: -plan.setupCost,
            category: FinanceTransactionCategory.infrastructure,
            description:
                'Миграция на собственные серверы • $migrationDays дней • риск downtime 12%',
          ),
          ...state.financeTransactions,
        ].take(120).toList(growable: false),
      ),
      'Миграция завершена: $migrationDays дней, стоимость ${plan.setupCost.round()} ₽, расчётный риск downtime 12%. Активна физическая мощность серверной.',
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
        financeTransactions: <FinanceTransaction>[
          FinanceTransaction(
            id: 'server_${hardware.id}_${state.simulationMinutes}_${current + 1}',
            simulationMinutes: state.simulationMinutes,
            amount: -hardware.purchaseCost,
            category: FinanceTransactionCategory.infrastructure,
            description: 'Покупка сервера • ${hardware.name}',
          ),
          ...state.financeTransactions,
        ].take(120).toList(growable: false),
      ),
      '${hardware.name} установлен: +${hardware.computeUnits.round()} CU.',
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
        state.hasLink(firstProductId, secondProductId)) {
      return state;
    }
    final first = state.productById(firstProductId)!;
    final second = state.productById(secondProductId)!;
    final profile = V9ContentCatalog.integrationFor(
      first.category.name,
      second.category.name,
    );
    final hasFreeSpecialist = state.unassignedEmployees.any(
      (employee) =>
          employee.role == EmployeeRole.backend ||
          employee.role == EmployeeRole.devOps,
    );
    final reasons = <String>[
      if (first.stage == ProductStage.failed ||
          second.stage == ProductStage.failed)
        'нельзя связать проваленный продукт',
      if (!hasFreeSpecialist) 'нет свободного Backend или DevOps',
      if (state.cash < profile.cost)
        'не хватает ${(profile.cost - state.cash).round()} ₽',
    ]..sort();
    if (reasons.isNotEmpty) {
      return _withFeed(
        state,
        '${first.name} ↔ ${second.name}: интеграция заблокирована — ${reasons.join('; ')}.',
      );
    }
    final activeAt = state.simulationMinutes + profile.integrationDays * 1440;
    return _withFeed(
      state.copyWith(
        cash: state.cash - profile.cost,
        ecosystemLinks: <EcosystemLink>[
          ...state.ecosystemLinks,
          EcosystemLink(
            firstProductId,
            secondProductId,
            connectedAtMinutes: state.simulationMinutes,
            activeAtMinutes: activeAt,
          ),
        ],
        financeTransactions: <FinanceTransaction>[
          FinanceTransaction(
            id: 'ecosystem_${first.id}_${second.id}_${state.simulationMinutes}',
            simulationMinutes: state.simulationMinutes,
            amount: -profile.cost,
            category: FinanceTransactionCategory.product,
            description:
                'Интеграция ${first.name} ↔ ${second.name} • ${profile.integrationDays} дней',
          ),
          ...state.financeTransactions,
        ].take(120).toList(growable: false),
      ),
      '${first.name} ↔ ${second.name}: ${profile.title}, ${profile.integrationDays} дней, стоимость ${profile.cost.round()} ₽, риск ${(profile.risk * 100).round()}%. Продукты сохраняют собственную выручку.',
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
    if (!state.contractsUnlocked) {
      return _withFeed(
        state,
        'Сначала выпустите сайт компании. После релиза контракты появятся в его карточке и в центре проектов.',
      );
    }
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
      milestonePaid: false,
    );
    var next = state.copyWith(
      cash: state.cash + upfront,
      clientContracts: <ClientContract>[...state.clientContracts, contract],
      financeTransactions: <FinanceTransaction>[
        FinanceTransaction(
          id: 'contract_advance_${contract.id}',
          simulationMinutes: state.simulationMinutes,
          amount: upfront,
          category: FinanceTransactionCategory.contract,
          description: 'Аванс по контракту • ${template.name}',
        ),
        ...state.financeTransactions,
      ].take(120).toList(growable: false),
      rngCounter: sequence,
    );

    final selected = <String>[];
    for (final role in template.requiredRoles) {
      final candidates =
          next.employees
              .where((employee) => employee.role == role)
              .where((employee) => !selected.contains(employee.id))
              .where(
                (employee) => next.canAssignEmployeeToMoreWork(employee.id),
              )
              .toList(growable: false)
            ..sort((left, right) {
              final leftCount = next.activeAssignmentCountForEmployee(left.id);
              final rightCount = next.activeAssignmentCountForEmployee(
                right.id,
              );
              if (leftCount != rightCount) {
                return leftCount.compareTo(rightCount);
              }
              final skill = right.skill.compareTo(left.skill);
              if (skill != 0) {
                return skill;
              }
              final speed = right.speed.compareTo(left.speed);
              if (speed != 0) {
                return speed;
              }
              return left.id.compareTo(right.id);
            });
      if (candidates.isNotEmpty) {
        selected.add(candidates.first.id);
      }
    }
    if (selected.isNotEmpty) {
      next = _recalculateTeamWorkload(
        next.copyWith(
          contractEmployeeAssignments: <ContractEmployeeAssignment>[
            ...next.contractEmployeeAssignments,
            for (final employeeId in selected)
              ContractEmployeeAssignment(
                contractId: contract.id,
                employeeId: employeeId,
                assignedAtMinutes: next.simulationMinutes,
              ),
          ],
        ),
      );
    }
    final coverage = next.contractRoleCoverageFor(contract.id);
    return _withFeed(
      next,
      '${template.client}: контракт «${template.name}» принят. Аванс ${upfront.round()} ₽. Автоназначено ${selected.length}; покрытие ролей ${(coverage * 100).round()}%.',
    );
  }

  GameState _startAdvertisingCampaign(
    GameState state,
    StartAdvertisingCampaign action,
  ) {
    final product = state.productById(action.productId);
    if (product == null || product.stage != ProductStage.live) {
      return _withFeed(
        state,
        'Рекламу можно запускать только для продукта на рынке.',
      );
    }
    final agency = ProductStrategyCatalog.agencyById(action.agencyId);
    final channel = ProductStrategyCatalog.channelById(action.channelId);
    if (action.budget < agency.minimumBudget) {
      return _withFeed(
        state,
        '${agency.name}: минимальный бюджет ${agency.minimumBudget.round()} ₽.',
      );
    }
    if (state.cash < action.budget) {
      return _withFeed(state, 'Недостаточно денег на рекламную кампанию.');
    }
    if (state.activeCampaignsFor(product.id).length >= 2) {
      return _withFeed(
        state,
        '${product.name}: одновременно можно вести не больше двух кампаний.',
      );
    }
    final forecast = state.advertisingForecast(
      product: product,
      agencyId: agency.id,
      channelId: channel.id,
      budget: action.budget,
    );
    final sequence = state.rngCounter + 1;
    final campaign = AdvertisingCampaign(
      id: 'campaign_${product.id}_$sequence',
      productId: product.id,
      agencyId: agency.id,
      channelId: channel.id,
      budget: action.budget,
      startedAtMinutes: state.simulationMinutes,
      endsAtMinutes: state.simulationMinutes + 7 * 1440,
      status: AdvertisingCampaignStatus.active,
      projectedImpressions: forecast.impressions,
      projectedClicks: forecast.clicks,
      projectedUsersLow: forecast.usersLow,
      projectedUsersExpected: forecast.usersExpected,
      projectedUsersHigh: forecast.usersHigh,
      deliveredUsers: 0,
    );
    return _withFeed(
      state.copyWith(
        cash: state.cash - action.budget,
        advertisingCampaigns: <AdvertisingCampaign>[
          ...state.advertisingCampaigns,
          campaign,
        ],
        financeTransactions: <FinanceTransaction>[
          FinanceTransaction(
            id: 'campaign_start_${campaign.id}',
            simulationMinutes: state.simulationMinutes,
            amount: -action.budget,
            category: FinanceTransactionCategory.marketing,
            description: '${agency.name} • ${channel.name}',
          ),
          ...state.financeTransactions,
        ].take(120).toList(growable: false),
        rngCounter: sequence,
      ),
      '${product.name}: ${channel.name} через ${agency.name}. Прогноз ${forecast.usersLow}–${forecast.usersHigh} пользователей за 7 дней. ${forecast.note}',
    );
  }

  GameState _requestBusinessLoan(GameState state) {
    if (state.activeLoan != null) {
      return _withFeed(state, 'Сначала погасите активный кредит.');
    }
    final hasProof =
        state.products.isNotEmpty ||
        state.activeContracts.isNotEmpty ||
        state.completedContracts.isNotEmpty;
    if (!hasProof) {
      return _withFeed(
        state,
        'Банк отказал: сначала создайте продукт или получите контракт.',
      );
    }
    final riskCount = state.products
        .where((product) => state.productSecurityRisk(product) > 0.72)
        .length;
    if (riskCount >= 2 || state.monthlyCosts > 2500000) {
      return _withFeed(
        state,
        'Банк отказал: burn или security-риск слишком высокий.',
      );
    }
    final amount = math
        .min(3000000, math.max(350000, state.monthlyCosts * 1.4 + 250000))
        .toDouble();
    final totalRepayment = amount * 1.10;
    final loan = CompanyLoan(
      principal: totalRepayment,
      remaining: totalRepayment,
      issuedAtMinutes: state.simulationMinutes,
      weeklyPayment: totalRepayment / 16,
      interestRate: 0.10,
    );
    return _withFeed(
      state.copyWith(
        cash: state.cash + amount,
        activeLoan: loan,
        financeTransactions: <FinanceTransaction>[
          FinanceTransaction(
            id: 'business_loan_${state.simulationMinutes}',
            simulationMinutes: state.simulationMinutes,
            amount: amount,
            category: FinanceTransactionCategory.financing,
            description: 'Бизнес-кредит',
          ),
          ...state.financeTransactions,
        ].take(120).toList(growable: false),
      ),
      'Бизнес-кредит одобрен: ${amount.round()} ₽. К возврату ${totalRepayment.round()} ₽ за 16 недель.',
    );
  }

  GameState _acceptEmergencyLoan(GameState state) {
    if (!state.creditOffered || state.activeLoan != null) {
      return _withFeed(state, 'Экстренный кредит сейчас недоступен.');
    }
    final riskyProducts = state.products.where(
      (product) => state.productSecurityRisk(product) > 0.62,
    );
    final hasEconomicProof =
        state.products.any(
          (product) =>
              product.stage == ProductStage.live &&
              (product.monthlyRevenue > 0 || product.brandTrust >= 0.12),
        ) ||
        state.completedContracts.isNotEmpty ||
        state.activeContracts.isNotEmpty;
    final burnTooHigh = state.monthlyCosts > 1500000;
    if (!hasEconomicProof || riskyProducts.length >= 2 || burnTooHigh) {
      return _withFeed(
        state,
        'Банк отказал: нет подтверждённой экономики или риск/burn слишком высокий. На решение влияют релизы, контракты, безопасность и расходы.',
      );
    }
    final amount = math
        .min(
          2200000,
          math.max(300000, state.cash.abs() + state.monthlyCosts * 0.85),
        )
        .toDouble();
    final totalRepayment = amount * 1.12;
    final loan = CompanyLoan(
      principal: totalRepayment,
      remaining: totalRepayment,
      issuedAtMinutes: state.simulationMinutes,
      weeklyPayment: totalRepayment / 12,
      interestRate: 0.12,
    );
    return _withFeed(
      state.copyWith(
        cash: state.cash + amount,
        activeLoan: loan,
        creditOffered: false,
        clearNegativeCashSinceMinutes: true,
        financeTransactions: <FinanceTransaction>[
          FinanceTransaction(
            id: 'loan_issue_${state.simulationMinutes}',
            simulationMinutes: state.simulationMinutes,
            amount: amount,
            category: FinanceTransactionCategory.financing,
            description: 'Экстренный кредит',
          ),
          ...state.financeTransactions,
        ].take(120).toList(growable: false),
      ),
      'Кредит одобрен: ${amount.round()} ₽. К возврату ${totalRepayment.round()} ₽, 12 еженедельных платежей.',
    );
  }

  GameState _redeemDebugPromo(GameState state, String rawCode) {
    final code = rawCode.trim().toUpperCase();
    if (code == 'FOUNDER-RICH') {
      const amount = 5000000.0;
      return _withFeed(
        state.copyWith(
          cash: state.cash + amount,
          financeTransactions: <FinanceTransaction>[
            FinanceTransaction(
              id: 'promo_rich_${state.simulationMinutes}',
              simulationMinutes: state.simulationMinutes,
              amount: amount,
              category: FinanceTransactionCategory.other,
              description: 'Тестовый промокод FOUNDER-RICH',
            ),
            ...state.financeTransactions,
          ].take(120).toList(growable: false),
        ),
        'Тестовый баланс увеличен на 5 млн ₽.',
      );
    }
    if (code == 'FOUNDER-BROKE') {
      const targetCash = -500000.0;
      return _withFeed(
        state.copyWith(
          cash: targetCash,
          negativeCashSinceMinutes: state.simulationMinutes,
          creditOffered: false,
        ),
        'Тестовый баланс установлен на −500 тыс. ₽. Запущен сценарий финансового кризиса.',
      );
    }
    return _withFeed(state, 'Промокод не найден.');
  }

  GameState _requestFunding(GameState state, RequestInvestorFunding action) {
    final investor = GameCatalog.investorById(action.investorId);
    final product = state.productById(action.productId);
    if (product == null || action.requestedAmount <= 0) return state;
    final duplicate = state.investorOffers.any(
      (offer) =>
          offer.investorId == investor.id && offer.productId == product.id,
    );
    if (duplicate) {
      return _withFeed(
        state,
        '${investor.name}: переговоры по ${product.name} уже идут.',
      );
    }
    final sequence = state.rngCounter + 1;
    final decisionDays = 1 + sequence % 14;
    final pending = InvestorOffer(
      id: 'negotiation_${investor.id}_${sequence}_$decisionDays',
      investorId: investor.id,
      productId: product.id,
      requestedAmount: action.requestedAmount,
      offeredAmount: -1,
      equityPercent: -1,
      revenueSharePercent: -1,
      createdAtMinutes: state.simulationMinutes,
    );
    return _withFeed(
      state.copyWith(
        investorOffers: <InvestorOffer>[...state.investorOffers, pending],
        rngCounter: sequence,
      ),
      '${investor.name}: запрос принят в переговоры. Ответ придёт не позднее чем через $decisionDays дн.',
    );
  }

  GameState _acceptOffer(GameState state, String offerId) {
    final offer = state.offerById(offerId);
    if (offer == null || offer.offeredAmount <= 0) {
      return _withFeed(state, 'Инвестиционный оффер ещё не готов.');
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
    final blueprintId = switch (company.id) {
      'm_pixel' => 'creator_suite',
      'm_guard' => 'crypto_wallet',
      'm_api' => 'code_forge',
      'm_orbit' => 'cloud_drive',
      'm_neural' => 'ai_search',
      'm_browser' => 'privacy_browser',
      'm_work' => 'team_saas',
      'm_data' => 'community_platform',
      _ => GameCatalog.productBlueprints
          .firstWhere((item) => item.category == company.category)
          .id,
    };
    final blueprint = GameCatalog.blueprintById(blueprintId);
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
    if (state.marketCompanyFullyAcquired(company.id)) {
      return state;
    }
    if (state.remainingRivalCount == 1 && !state.legacyProductRequirementMet) {
      return _withFeed(
        state,
        'Финальная сделка пока закрыта: выпустите ${state.requiredReleasedBlueprintsForLegacy} разных продуктов из каталога. Сейчас ${state.releasedBlueprintCount}.',
      );
    }
    final productAlreadyOwned = state.acquiredCompanyIds.contains(company.id);
    final existingStake = state.holdingByCompanyId(company.id)?.ownershipPercent ?? 0;
    final equityAdjustedPrice = company.valuation * (1 - existingStake / 100);
    final remainingPrice = math
        .max(0, equityAdjustedPrice - (productAlreadyOwned ? company.productPrice : 0))
        .toDouble();
    if (state.cash < remainingPrice) {
      return state;
    }
    final acquired = productAlreadyOwned
        ? state
        : _acquireProduct(
            state,
            AcquireMarketProduct(
              companyId: companyId,
              mode: AcquisitionMode.maintainSeparate,
            ),
          );
    if (!productAlreadyOwned && identical(acquired, state)) return state;
    final companyBalance = productAlreadyOwned
        ? remainingPrice
        : math.max(0, equityAdjustedPrice - company.productPrice).toDouble();
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
        languageIds: const <String>['typescript', 'python'],
        grade: EmployeeGrade.senior,
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
        languageIds: const <String>['go', 'java', 'typescript'],
        grade: EmployeeGrade.senior,
      ),
    ];
    return _withFeed(
      acquired.copyWith(
        cash: acquired.cash - companyBalance,
        employees: <Employee>[...acquired.employees, ...generatedEmployees],
        fullyAcquiredCompanyIds: <String>[
          ...acquired.fullyAcquiredCompanyIds,
          if (!acquired.fullyAcquiredCompanyIds.contains(company.id)) company.id,
        ],
        portfolioHoldings: acquired.portfolioHoldings
            .where((holding) => holding.companyId != company.id)
            .toList(growable: false),
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
    if (state.criticalEvent == CriticalEventType.lostControl ||
        state.criticalEvent == CriticalEventType.insolvency) {
      return state;
    }
    final responseMultiplier = state.criticalProductId == null
        ? 1.0
        : state.productIncidentMultiplier(state.criticalProductId!);
    final isSecurityBreach =
        state.criticalEvent == CriticalEventType.securityBreach;
    final cost = isSecurityBreach
        ? 240000.0 * (0.55 + responseMultiplier * 0.45)
        : 0.0;
    return _withFeed(
      state.copyWith(
        cash: state.cash - cost,
        criticalEvent: CriticalEventType.none,
        clearCriticalProductId: true,
        paused: true,
      ),
      isSecurityBreach
          ? 'Инцидент локализован за ${cost.round()} ₽. Проверьте безопасность перед продолжением.'
          : 'Перегрузка отмечена. Переход к инфраструктуре ничего не списывает — исправьте compute или распределение мощности.',
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
      final brandFactor =
          (0.0015 +
                  product.brandAwareness * 0.70 +
                  product.brandTrust * 0.025)
              .clamp(0.001, 1.0)
              .toDouble();
      final organic =
          segment.addressableUsers *
          (0.0007 + preference * 0.0048) *
          brandFactor;
      monthlyNewUsers += organic * (1 - freshnessPenalty * 0.72);
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
        (0.12 +
                designScore / 330 +
                featureCoverage * 0.22 +
                preference * 0.18 +
                product.brandTrust * 0.10 +
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
    final priceSentiment = state.currentPriceSentiment(product);
    final churn =
        (0.19 -
                retention * 0.14 +
                (1 - preference) * 0.08 +
                overload * 0.10 +
                freshnessPenalty * 0.11 +
                priceSentiment * 0.12 +
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
    var total = 0;
    var count = 0;
    for (final employee in employees) {
      if (roles.contains(employee.role)) {
        total += metric(employee);
        count += 1;
      }
    }
    return count == 0 ? 0 : total / count;
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

  GameState _recordActionTransaction(
    GameState before,
    GameState after,
    GameAction action,
  ) {
    if (identical(before, after) ||
        action is AdvanceTime ||
        action is SkipNight ||
        action is StartAdvertisingCampaign ||
        action is AcceptClientContract ||
        action is HireCandidate ||
        action is HireCandidateForProduct ||
        action is AutoHireProjectTeam ||
        action is GiveWellbeingBonus ||
        action is RequestBusinessLoan ||
        action is AcceptEmergencyLoan ||
        action is RedeemDebugPromo ||
        action is ResetGame) {
      return after;
    }
    final delta = after.cash - before.cash;
    if (delta.abs() < 0.01) {
      return after;
    }
    final category = switch (action) {
      AcceptClientContract() => FinanceTransactionCategory.contract,
      RequestInvestorFunding() ||
      AcceptInvestorOffer() => FinanceTransactionCategory.financing,
      InvestInMarketCompany() ||
      AcquireMarketProduct() ||
      AcquireMarketCompany() ||
      BuyBackInvestor() => FinanceTransactionCategory.investment,
      HireCandidate() ||
      FireEmployee() ||
      GiveEmployeeRaise() ||
      TrainEmployee() => FinanceTransactionCategory.payroll,
      RentOffice() ||
      RentServerRoom() ||
      InstallServer() ||
      RemoveServer() => FinanceTransactionCategory.infrastructure,
      PurchaseSecurityControl() ||
      RunSecurityAudit() => FinanceTransactionCategory.security,
      SetProductMarketingBudget() => FinanceTransactionCategory.marketing,
      CreateConfiguredProduct() ||
      AddProductFeature() ||
      ApplyProductImprovement() => FinanceTransactionCategory.product,
      _ => FinanceTransactionCategory.other,
    };
    final description = switch (action) {
      AcceptClientContract() => 'Аванс по клиентскому контракту',
      AcceptInvestorOffer() => 'Получена инвестиция',
      RequestInvestorFunding() => 'Изменение после запроса инвестору',
      HireCandidate() => 'Signing bonus сотруднику',
      FireEmployee() => 'Компенсация при увольнении',
      TrainEmployee() => 'Обучение сотрудника',
      CreateConfiguredProduct() => 'Запуск разработки продукта',
      AddProductFeature() => 'Новая функция продукта',
      ApplyProductImprovement() => 'Техническое улучшение продукта',
      RentOffice() => 'Депозит за офис',
      RentServerRoom() => 'Депозит за серверную',
      InstallServer() => 'Покупка сервера',
      PurchaseSecurityControl() => 'Внедрение security control',
      RunSecurityAudit() => 'Security-аудит',
      InvestInMarketCompany() => 'Покупка внешней доли',
      AcquireMarketProduct() => 'Покупка продукта',
      AcquireMarketCompany() => 'Покупка компании',
      BuyBackInvestor() => 'Обратный выкуп доли',
      _ => 'Изменение денежных средств',
    };
    final transaction = FinanceTransaction(
      id: 'action_${after.simulationMinutes}_${after.rngCounter}_${action.runtimeType}',
      simulationMinutes: after.simulationMinutes,
      amount: delta,
      category: category,
      description: description,
    );
    return after.copyWith(
      financeTransactions: <FinanceTransaction>[
        transaction,
        ...after.financeTransactions,
      ].take(120).toList(growable: false),
    );
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
