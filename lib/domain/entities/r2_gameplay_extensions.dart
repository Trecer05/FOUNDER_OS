import 'dart:math' as math;

import '../catalog/product_strategy_catalog.dart';
import 'game_state.dart';
import 'management_models.dart';
import 'models.dart';
import 'v17_models.dart';

enum R2DevelopmentWorkstream {
  discovery,
  architecture,
  frontend,
  backend,
  serverSetup,
  integration,
  stabilization,
  release,
}

class R2DevelopmentWorkstreamInfo {
  const R2DevelopmentWorkstreamInfo({
    required this.workstream,
    required this.name,
    required this.start,
    required this.end,
    required this.criticalRoles,
  });

  final R2DevelopmentWorkstream workstream;
  final String name;
  final double start;
  final double end;
  final List<EmployeeRole> criticalRoles;
}

class ReputationDriver {
  const ReputationDriver({
    required this.label,
    required this.deltaPerDay,
    required this.explanation,
  });

  final String label;
  final double deltaPerDay;
  final String explanation;
}

class ReputationBreakdown {
  const ReputationBreakdown({
    required this.projectedDailyDelta,
    required this.drivers,
  });

  final double projectedDailyDelta;
  final List<ReputationDriver> drivers;
}

const String r2LoanRejectionMarker = 'loan_request_rejected:';

extension R2GameplayState on GameState {
  R2DevelopmentWorkstreamInfo r2DevelopmentWorkstreamFor(Product product) {
    final requiresDevOps = roleRequirementsFor(
      product,
    ).any((item) => item.role == EmployeeRole.devOps && item.minimumCount > 0);
    final progress = product.developmentProgress;
    if (progress < 0.08) {
      return const R2DevelopmentWorkstreamInfo(
        workstream: R2DevelopmentWorkstream.discovery,
        name: 'Исследование и требования',
        start: 0,
        end: 0.08,
        criticalRoles: <EmployeeRole>[
          EmployeeRole.productManager,
          EmployeeRole.designer,
        ],
      );
    }
    if (progress < 0.18) {
      return const R2DevelopmentWorkstreamInfo(
        workstream: R2DevelopmentWorkstream.architecture,
        name: 'Архитектура',
        start: 0.08,
        end: 0.18,
        criticalRoles: <EmployeeRole>[
          EmployeeRole.backend,
          EmployeeRole.security,
        ],
      );
    }
    if (progress < 0.38) {
      return const R2DevelopmentWorkstreamInfo(
        workstream: R2DevelopmentWorkstream.frontend,
        name: 'Frontend / клиент',
        start: 0.18,
        end: 0.38,
        criticalRoles: <EmployeeRole>[
          EmployeeRole.frontend,
          EmployeeRole.mobile,
          EmployeeRole.designer,
        ],
      );
    }
    if (progress < 0.62) {
      return const R2DevelopmentWorkstreamInfo(
        workstream: R2DevelopmentWorkstream.backend,
        name: 'Backend / данные',
        start: 0.38,
        end: 0.62,
        criticalRoles: <EmployeeRole>[EmployeeRole.backend, EmployeeRole.aiMl],
      );
    }
    if (progress < 0.72 && requiresDevOps) {
      return const R2DevelopmentWorkstreamInfo(
        workstream: R2DevelopmentWorkstream.serverSetup,
        name: 'Настройка серверов и deployment',
        start: 0.62,
        end: 0.72,
        criticalRoles: <EmployeeRole>[
          EmployeeRole.devOps,
          EmployeeRole.security,
        ],
      );
    }
    if (progress < 0.84) {
      return R2DevelopmentWorkstreamInfo(
        workstream: R2DevelopmentWorkstream.integration,
        name: requiresDevOps
            ? 'Интеграции и функции'
            : 'Backend, интеграции и deployment',
        start: 0.62,
        end: 0.84,
        criticalRoles: const <EmployeeRole>[
          EmployeeRole.frontend,
          EmployeeRole.backend,
          EmployeeRole.mobile,
          EmployeeRole.aiMl,
        ],
      );
    }
    if (progress < 0.96) {
      return const R2DevelopmentWorkstreamInfo(
        workstream: R2DevelopmentWorkstream.stabilization,
        name: 'QA и стабилизация',
        start: 0.84,
        end: 0.96,
        criticalRoles: <EmployeeRole>[
          EmployeeRole.qa,
          EmployeeRole.security,
          EmployeeRole.devOps,
        ],
      );
    }
    return const R2DevelopmentWorkstreamInfo(
      workstream: R2DevelopmentWorkstream.release,
      name: 'Подготовка релиза',
      start: 0.96,
      end: 1,
      criticalRoles: <EmployeeRole>[
        EmployeeRole.productManager,
        EmployeeRole.qa,
        EmployeeRole.devOps,
      ],
    );
  }

  int get businessLoanRetryRemainingMinutes {
    FinanceTransaction? latest;
    for (final transaction in financeTransactions) {
      if (!transaction.description.startsWith(r2LoanRejectionMarker)) continue;
      if (latest == null ||
          transaction.simulationMinutes > latest.simulationMinutes) {
        latest = transaction;
      }
    }
    if (latest == null) return 0;
    final remaining = latest.simulationMinutes + 7 * 1440 - simulationMinutes;
    return math.max(0, remaining).toInt();
  }

  int get businessLoanRetryRemainingDays =>
      businessLoanRetryRemainingMinutes <= 0
      ? 0
      : (businessLoanRetryRemainingMinutes / 1440).ceil();

  int productInvestorCount(String productId) =>
      investorAgreements.where((item) => item.productId == productId).length;

  int productRequiredInvestorCount(Product product) =>
      ProductStrategyCatalog.strategyFor(
        product.blueprintId,
      ).requiredInvestorCount;

  int productMissingInvestorCount(Product product) => math
      .max(
        0,
        productRequiredInvestorCount(product) -
            productInvestorCount(product.id),
      )
      .toInt();

  bool productFundingReady(Product product) =>
      productMissingInvestorCount(product) == 0;

  double employeeLanguageFitForProduct(Employee employee, Product product) {
    if (product.languageIds.isEmpty) return 1;
    final knowsAny = employee.languageIds.any(product.languageIds.contains);
    return knowsAny ? 1 : 0.5;
  }

  ReputationBreakdown get reputationBreakdown {
    final live = products
        .where((item) => item.stage == ProductStage.live)
        .toList(growable: false);
    final avgTrust = live.isEmpty
        ? 0.5
        : live.fold<double>(0, (sum, item) => sum + item.brandTrust) /
              live.length;
    final avgRating = live.isEmpty
        ? 3.8
        : live.fold<double>(0, (sum, item) => sum + item.rating) / live.length;
    final staffLoyalty = employees.isEmpty ? 60.0 : averageEmployeeLoyalty;
    final doctrine = switch (ecosystemDoctrine) {
      EcosystemDoctrine.balanced => 0.0,
      EcosystemDoctrine.open => 0.004,
      EcosystemDoctrine.dominant => -0.006,
    };
    final trust = (avgTrust - 0.5) * 0.08;
    final rating = (avgRating - 3.8) * 0.025;
    final loyalty = (staffLoyalty - 60) / 5000;
    final total = trust + rating + loyalty + doctrine;
    return ReputationBreakdown(
      projectedDailyDelta: total,
      drivers: <ReputationDriver>[
        ReputationDriver(
          label: 'Доверие к продуктам',
          deltaPerDay: trust,
          explanation: 'Среднее доверие ${(avgTrust * 100).round()}%',
        ),
        ReputationDriver(
          label: 'Рейтинг продуктов',
          deltaPerDay: rating,
          explanation: 'Средний рейтинг ${avgRating.toStringAsFixed(2)}',
        ),
        ReputationDriver(
          label: 'Лояльность команды',
          deltaPerDay: loyalty,
          explanation: 'Средняя лояльность ${staffLoyalty.round()}/100',
        ),
        ReputationDriver(
          label: 'Доктрина экосистемы',
          deltaPerDay: doctrine,
          explanation: ecosystemDoctrine.name,
        ),
      ],
    );
  }
}
