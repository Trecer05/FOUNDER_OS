part of 'game_state.dart';

final Expando<_GameStateIndex> _gameStateIndexes = Expando<_GameStateIndex>(
  'founder_os_game_state_index',
);

extension _GameStateIndexAccess on GameState {
  _GameStateIndex get _index =>
      _gameStateIndexes[this] ??= _GameStateIndex(this);
}

/// Lazy indexes for one immutable GameState instance.
///
/// A new state receives a new index; unchanged states reuse their maps during a
/// simulation batch/render. Expando keeps this cache out of serialization and
/// lets the VM release it together with the state.
class _GameStateIndex {
  _GameStateIndex(this.state);

  final GameState state;

  late final Map<String, Product> productsById =
      Map<String, Product>.unmodifiable(<String, Product>{
        for (final item in state.products) item.id: item,
      });
  late final Map<String, Candidate> candidatesById =
      Map<String, Candidate>.unmodifiable(<String, Candidate>{
        for (final item in state.candidates) item.id: item,
      });
  late final Map<String, Employee> employeesById =
      Map<String, Employee>.unmodifiable(<String, Employee>{
        for (final item in state.employees) item.id: item,
      });
  late final Map<String, ClientContract> contractsById =
      Map<String, ClientContract>.unmodifiable(<String, ClientContract>{
        for (final item in state.clientContracts) item.id: item,
      });
  late final Map<String, InvestorOffer> offersById =
      Map<String, InvestorOffer>.unmodifiable(<String, InvestorOffer>{
        for (final item in state.investorOffers) item.id: item,
      });
  late final Map<String, InvestorAgreement> agreementsById =
      Map<String, InvestorAgreement>.unmodifiable(<String, InvestorAgreement>{
        for (final item in state.investorAgreements) item.id: item,
      });
  late final Map<String, PortfolioHolding> holdingsByCompanyId =
      Map<String, PortfolioHolding>.unmodifiable(<String, PortfolioHolding>{
        for (final item in state.portfolioHoldings) item.companyId: item,
      });
  late final Map<String, List<EmployeeAssignment>> assignmentsByEmployee =
      _group<EmployeeAssignment>(
        state.employeeAssignments,
        (item) => item.employeeId,
      );
  late final Map<String, List<EmployeeAssignment>> assignmentsByProduct =
      _group<EmployeeAssignment>(
        state.employeeAssignments,
        (item) => item.productId,
      );
  late final Map<String, EmployeeAssignment> assignmentByEmployeeProduct =
      _firstBy<EmployeeAssignment>(
        state.employeeAssignments,
        (item) => pair(item.employeeId, item.productId),
      );
  late final Map<String, List<Employee>> employeesByProduct = _resolveEmployees(
    assignmentsByProduct,
  );
  late final Map<String, List<ContractEmployeeAssignment>>
  contractAssignmentsByEmployee = _group<ContractEmployeeAssignment>(
    state.contractEmployeeAssignments,
    (item) => item.employeeId,
  );
  late final Map<String, List<ContractEmployeeAssignment>>
  contractAssignmentsByContract = _group<ContractEmployeeAssignment>(
    state.contractEmployeeAssignments,
    (item) => item.contractId,
  );
  late final Map<String, List<Employee>> employeesByContract =
      _resolveContractEmployees(contractAssignmentsByContract);
  late final Map<String, List<ProductSecurityControl>> securityByProduct =
      _group<ProductSecurityControl>(
        state.securityControls,
        (item) => item.productId,
      );
  late final Map<String, List<ProductImprovementRecord>> improvementsByProduct =
      _group<ProductImprovementRecord>(
        state.productImprovements,
        (item) => item.productId,
      );
  late final Map<String, List<ProductFeatureDevelopment>> featureWorkByProduct =
      _group<ProductFeatureDevelopment>(
        state.productFeatureDevelopments,
        (item) => item.productId,
      );
  late final Map<String, List<AdvertisingCampaign>> campaignsByProduct =
      _group<AdvertisingCampaign>(
        state.advertisingCampaigns,
        (item) => item.productId,
      );
  late final Map<String, List<ProductMetricPoint>> metricHistoryByProduct =
      _group<ProductMetricPoint>(
        state.productMetricHistory,
        (item) => item.productId,
      );
  late final Map<String, int> installedCountByHardwareId =
      _firstValueBy<InstalledServer, int>(
        state.installedServers,
        (item) => item.hardwareId,
        (item) => item.count,
      );
  late final Map<String, int> improvementLevelByProductType =
      _maximumImprovementLevels(state.productImprovements);

  Map<String, List<Employee>> _resolveEmployees(
    Map<String, List<EmployeeAssignment>> assignments,
  ) => Map<String, List<Employee>>.unmodifiable(<String, List<Employee>>{
    for (final entry in assignments.entries)
      entry.key: List<Employee>.unmodifiable(
        entry.value
            .map((item) => employeesById[item.employeeId])
            .whereType<Employee>(),
      ),
  });

  Map<String, List<Employee>> _resolveContractEmployees(
    Map<String, List<ContractEmployeeAssignment>> assignments,
  ) => Map<String, List<Employee>>.unmodifiable(<String, List<Employee>>{
    for (final entry in assignments.entries)
      entry.key: List<Employee>.unmodifiable(
        entry.value
            .map((item) => employeesById[item.employeeId])
            .whereType<Employee>(),
      ),
  });

  static Map<String, T> _firstBy<T>(
    Iterable<T> source,
    String Function(T item) keyOf,
  ) {
    final mutable = <String, T>{};
    for (final item in source) {
      mutable.putIfAbsent(keyOf(item), () => item);
    }
    return Map<String, T>.unmodifiable(mutable);
  }

  static Map<String, V> _firstValueBy<T, V>(
    Iterable<T> source,
    String Function(T item) keyOf,
    V Function(T item) valueOf,
  ) {
    final mutable = <String, V>{};
    for (final item in source) {
      mutable.putIfAbsent(keyOf(item), () => valueOf(item));
    }
    return Map<String, V>.unmodifiable(mutable);
  }

  static Map<String, int> _maximumImprovementLevels(
    Iterable<ProductImprovementRecord> source,
  ) {
    final mutable = <String, int>{};
    for (final item in source) {
      final key = pair(item.productId, item.type.name);
      final current = mutable[key] ?? 0;
      if (item.level > current) {
        mutable[key] = item.level;
      }
    }
    return Map<String, int>.unmodifiable(mutable);
  }

  static String pair(String first, String second) => '$first\u001f$second';

  static Map<String, List<T>> _group<T>(
    Iterable<T> source,
    String Function(T item) keyOf,
  ) {
    final mutable = <String, List<T>>{};
    for (final item in source) {
      mutable.putIfAbsent(keyOf(item), () => <T>[]).add(item);
    }
    return Map<String, List<T>>.unmodifiable(<String, List<T>>{
      for (final entry in mutable.entries)
        entry.key: List<T>.unmodifiable(entry.value),
    });
  }
}
