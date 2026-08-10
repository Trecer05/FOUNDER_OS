#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding='utf-8')
    if new in text:
        print(f'✅ {label}: already applied')
        return
    if old not in text:
        raise SystemExit(f'❌ {label}: anchor not found in {path}')
    path.write_text(text.replace(old, new, 1), encoding='utf-8')
    print(f'✅ {label}')


# ---------------------------------------------------------------------------
# Company setup: headquarters location is part of new-company configuration.
# ---------------------------------------------------------------------------
setup = ROOT / 'lib/presentation/features/onboarding/company_setup_dialog.dart'
if not setup.is_file():
    raise SystemExit(f'❌ Missing {setup}')

replace_once(
    setup,
    "import '../../../domain/entities/v12_models.dart';\n",
    "import '../../../domain/entities/v12_models.dart';\nimport '../../../domain/catalog/world_economy_catalog.dart';\n",
    'company setup world catalog import',
)
replace_once(
    setup,
    "  String _logoId = 'company_logo_01';\n  double _budget = 450000;\n",
    "  String _logoId = 'company_logo_01';\n  String _headquartersCityId = 'moscow';\n  double _budget = 450000;\n",
    'company setup HQ state',
)

hq_block = r'''              const SizedBox(height: 20),
              _SectionTitle(_t('Где открыть компанию', 'Company headquarters')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: const Key('company-headquarters-city'),
                initialValue: _headquartersCityId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: _t('Город и страна', 'City and country'),
                  helperText: _t(
                    'HQ определяет налоги и базовую стоимость найма. Позже можно строить офисы и ЦОД в других городах.',
                    'HQ determines taxes and baseline hiring costs. Later you can build offices and data centers in other cities.',
                  ),
                ),
                items: WorldEconomyCatalog.cities
                    .map(
                      (city) => DropdownMenuItem<String>(
                        value: city.id,
                        child: Text(
                          DisplayPreferences.instance.isEnglish
                              ? '${city.cityEn}, ${city.countryEn}'
                              : '${city.cityRu}, ${city.countryRu}',
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _headquartersCityId = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              Builder(
                builder: (context) {
                  final city = WorldEconomyCatalog.cityById(
                    _headquartersCityId,
                  );
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('Стратегический профиль', 'Strategic profile'),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _t(
                              'Налог на прибыль ${(city.corporateTaxRate * 100).toStringAsFixed(1)}% • payroll tax ${(city.payrollTaxRate * 100).toStringAsFixed(1)}%',
                              'Profit tax ${(city.corporateTaxRate * 100).toStringAsFixed(1)}% • payroll tax ${(city.payrollTaxRate * 100).toStringAsFixed(1)}%',
                            ),
                          ),
                          Text(
                            _t(
                              'Зарплаты ×${city.salaryMultiplier.toStringAsFixed(2)} • аренда ×${city.rentMultiplier.toStringAsFixed(2)} • коммунальные ×${city.utilityMultiplier.toStringAsFixed(2)}',
                              'Salaries ×${city.salaryMultiplier.toStringAsFixed(2)} • rent ×${city.rentMultiplier.toStringAsFixed(2)} • utilities ×${city.utilityMultiplier.toStringAsFixed(2)}',
                            ),
                          ),
                          Text(
                            _t(
                              'Таланты ${city.talentScore}/100 • инвесторы ${city.investorScore}/100 • рынок ${city.marketAccessScore}/100 • регулирование ${city.regulationScore}/100 • сеть ${city.networkScore}/100',
                              'Talent ${city.talentScore}/100 • investors ${city.investorScore}/100 • market ${city.marketAccessScore}/100 • regulation ${city.regulationScore}/100 • network ${city.networkScore}/100',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
'''
replace_once(
    setup,
    "              const SizedBox(height: 20),\n              _SectionTitle(_t('Логотип', 'Logo')),\n",
    hq_block + "              const SizedBox(height: 20),\n              _SectionTitle(_t('Логотип', 'Logo')),\n",
    'company setup HQ UI',
)
replace_once(
    setup,
    "        skills: profile.skills,\n      ),\n",
    "        skills: profile.skills,\n        headquartersCityId: _headquartersCityId,\n      ),\n",
    'company setup ConfigureCompany city',
)

# ---------------------------------------------------------------------------
# Tutorial: geography/taxes + detailed monetization + global infrastructure.
# ---------------------------------------------------------------------------
tutorial = ROOT / 'lib/presentation/features/tutorial/founder_tutorial_dialog.dart'
if not tutorial.is_file():
    raise SystemExit(f'❌ Missing {tutorial}')
text = tutorial.read_text(encoding='utf-8')
start = text.index('  static const _pages = <_TutorialPage>[')
end = text.index('\n  ];', start) + len('\n  ];')
new_pages = r'''  static const _pages = <_TutorialPage>[
    _TutorialPage(
      icon: Icons.person_outline,
      title: '0. CEO — тоже часть команды',
      body:
          'CEO умеет проектировать, рисовать, писать код и отлаживать продукт. Background и 22 распределённых очка определяют скорость этой работы и экономические бонусы.',
      tip:
          'В одиночку можно довести продукт до релиза, но профильные сотрудники ускоряют работу в разы.',
    ),
    _TutorialPage(
      icon: Icons.public_outlined,
      title: '1. Выберите географию компании',
      body:
          'Город HQ задаёт налог на прибыль, payroll tax, базовые зарплаты, аренду и коммунальные расходы. Одновременно он влияет на доступ к талантам, инвесторам, рынку, регулирование и качество сети.',
      tip:
          'Самая дешёвая юрисдикция не всегда лучшая: дорогой город может быстрее дать сильную команду, капитал или рынок.',
    ),
    _TutorialPage(
      icon: Icons.rocket_launch_outlined,
      title: '2. Создайте первый продукт',
      body:
          'Во вкладке «Продукты» выберите категорию, framework, языки, технологии и функции. После создания работа проходит через проектирование, дизайн, разработку и отладку.',
      tip:
          'Не выбирайте всё сразу: лишние технологии повышают стоимость и compute.',
    ),
    _TutorialPage(
      icon: Icons.payments_outlined,
      title: '3. Поймите монетизацию до релиза',
      body:
          'Free ускоряет набор аудитории, но не даёт прямой выручки. Subscription даёт повторяющийся доход и требует retention. Usage based растёт вместе с использованием и расходами compute. Advertising зависит от MAU и вовлечённости. Transaction fee требует объёма операций и доверия.',
      tip:
          'Цена, free tier, рекламная нагрузка и комиссия — рычаги. Смотрите одновременно на прогноз выручки, activation, retention, churn и доверие.',
    ),
    _TutorialPage(
      icon: Icons.groups_2_outlined,
      title: '4. Соберите и развивайте команду',
      body:
          'Каждому продукту нужны конкретные роли. Skill растёт от реальной разработки. Курсы занимают 2–3 игровых дня, на это время сотрудник выпадает из разработки. Грейд повышается вместе с навыком или через план повышения до выбранного целевого грейда.',
      tip:
          'Можно выбрать нескольких сотрудников или всех из фильтра и отправить их на один курс одновременно.',
    ),
    _TutorialPage(
      icon: Icons.apartment_outlined,
      title: '5. Масштабируйте офисы по миру',
      body:
          'Аренда подходит для старта. Позже можно строить несколько собственных офисов в разных городах, выбирая размер, качество ремонта и оснащения. Каждый город меняет стоимость команды и стратегические возможности.',
      tip:
          'Не стройте кампус раньше времени: CAPEX и содержание должны окупаться реальной потребностью в людях.',
    ),
    _TutorialPage(
      icon: Icons.dns_outlined,
      title: '6. Стройте дата-центры осознанно',
      body:
          'Собственные ЦОД можно размещать в разных городах. Размер задаёт rack-потолок, а качество помещения и оборудования влияет на power, cooling и network. Сервер при покупке устанавливается на конкретную площадку.',
      tip:
          'Дешёвое электричество не компенсирует плохую сеть или слишком маленький ЦОД, если продукт растёт глобально.',
    ),
    _TutorialPage(
      icon: Icons.receipt_long_outlined,
      title: '7. Планируйте годовые налоги',
      body:
          'Раз в игровой год компания платит налог с накопленной прибыли и payroll tax с фонда оплаты труда. Они не спрятаны в месячном burn: обязательство накапливается и списывается отдельной транзакцией.',
      tip:
          'Держите резерв к концу года. Высокая прибыль без кэша после CAPEX всё равно может создать кассовый разрыв.',
    ),
    _TutorialPage(
      icon: Icons.psychology_alt_outlined,
      title: '8. Используйте собственную AI',
      body:
          'AI-продукт можно вывести на рынок либо перевести во внутренний корпоративный режим и подключать к другим продуктам.',
      tip:
          'Корпоративная AI ускоряет разработку и повышает качество, но требует дополнительных серверов и ежемесячных расходов.',
    ),
    _TutorialPage(
      icon: Icons.update_outlined,
      title: '9. Не дайте продукту устареть',
      body:
          'После долгого периода без обновлений падают свежесть, органический рост и retention. Даже после завершения roadmap всегда доступны технические улучшения и массовое исправление накопившихся багов.',
      tip:
          'Рост — это цикл: продукт → команда → инфраструктура → рынок → налоги → следующая инвестиция. Не максимизируйте один показатель в отрыве от остальных.',
    ),
  ];'''
tutorial.write_text(text[:start] + new_pages + text[end:], encoding='utf-8')
print('✅ founder tutorial V16 pages')

# ---------------------------------------------------------------------------
# Immutable-state indexes: avoid rebuilding employee/training/server/competitor
# lookups on every one-second UI rebuild.
# ---------------------------------------------------------------------------
index = ROOT / 'lib/domain/entities/game_state_index.dart'
if not index.is_file():
    raise SystemExit(f'❌ Missing {index}')
replace_once(
    index,
    "  late final Map<String, List<Employee>> employeesByProduct = _resolveEmployees(\n    assignmentsByProduct,\n  );\n",
    "  late final Map<String, List<Employee>> employeesByProduct = _resolveEmployees(\n    assignmentsByProduct,\n  );\n  late final Map<String, EmployeeTrainingAssignment> trainingByEmployee =\n      _firstBy<EmployeeTrainingAssignment>(\n        state.employeeTrainings,\n        (item) => item.employeeId,\n      );\n  late final Map<String, EmployeeGradeUpgrade> gradeUpgradeByEmployee =\n      _firstBy<EmployeeGradeUpgrade>(\n        state.employeeGradeUpgrades,\n        (item) => item.employeeId,\n      );\n  late final List<String> staffingCityIds = List<String>.unmodifiable(\n    <String>{state.headquartersCityId, ...state.ownedOffices.map((item) => item.cityId)},\n  );\n  late final Map<String, int> ownedOfficeCapacityByCity =\n      _sumValueBy<OwnedOfficeSite, int>(\n        state.ownedOffices,\n        (item) => item.cityId,\n        (item) => WorldEconomyCatalog.officeCapacity(item.size),\n        (left, right) => left + right,\n      );\n  late final Map<String, int> onSiteEmployeeCountByCity =\n      _sumValueBy<Employee, int>(\n        state.employees.where((item) => !item.remote),\n        (item) => state.employeeCityId(item),\n        (_) => 1,\n        (left, right) => left + right,\n      );\n  late final Map<String, int> bestOwnedOfficeComfortByCity =\n      _maximumIntValueBy<OwnedOfficeSite>(\n        state.ownedOffices,\n        (item) => item.cityId,\n        WorldEconomyCatalog.officeComfortScore,\n      );\n",
    'V16 employee development indexes',
)
replace_once(
    index,
    "  late final Map<String, int> installedCountByHardwareId =\n      _firstValueBy<InstalledServer, int>(\n        state.installedServers,\n        (item) => item.hardwareId,\n        (item) => item.count,\n      );\n",
    "  late final Map<String, int> installedCountByHardwareId =\n      _sumValueBy<InstalledServer, int>(\n        state.installedServers,\n        (item) => item.hardwareId,\n        (item) => item.count,\n        (left, right) => left + right,\n      );\n  late final Map<String, List<InstalledServer>> serversByDataCenter =\n      _group<InstalledServer>(\n        state.installedServers,\n        (item) => item.dataCenterSiteId,\n      );\n  final Map<ProductCategory, List<CompetitorBenchmark>> _competitorsByCategory =\n      <ProductCategory, List<CompetitorBenchmark>>{};\n\n  List<CompetitorBenchmark> competitorsForCategory(ProductCategory category) =>\n      _competitorsByCategory.putIfAbsent(\n        category,\n        () => state._buildCompetitorsForCategory(category),\n      );\n",
    'V16 infrastructure and competitor indexes',
)
# Add aggregate helpers, then remove the old first-value helper. V16 needs
# real aggregation because the same hardware can live in several data centers.
replace_once(
    index,
    "  static Map<String, V> _firstValueBy<T, V>(\n",
    "  static Map<String, int> _maximumIntValueBy<T>(\n    Iterable<T> source,\n    String Function(T item) keyOf,\n    int Function(T item) valueOf,\n  ) {\n    final mutable = <String, int>{};\n    for (final item in source) {\n      final key = keyOf(item);\n      final value = valueOf(item);\n      final current = mutable[key];\n      if (current == null || value > current) {\n        mutable[key] = value;\n      }\n    }\n    return Map<String, int>.unmodifiable(mutable);\n  }\n\n  static Map<String, V> _sumValueBy<T, V>(\n    Iterable<T> source,\n    String Function(T item) keyOf,\n    V Function(T item) valueOf,\n    V Function(V left, V right) combine,\n  ) {\n    final mutable = <String, V>{};\n    for (final item in source) {\n      final key = keyOf(item);\n      final value = valueOf(item);\n      mutable[key] = mutable.containsKey(key)\n          ? combine(mutable[key] as V, value)\n          : value;\n    }\n    return Map<String, V>.unmodifiable(mutable);\n  }\n\n  static Map<String, V> _firstValueBy<T, V>(\n",
    'V16 index sum helper',
)
first_value_helper = "  static Map<String, V> _firstValueBy<T, V>(\n    Iterable<T> source,\n    String Function(T item) keyOf,\n    V Function(T item) valueOf,\n  ) {\n    final mutable = <String, V>{};\n    for (final item in source) {\n      mutable.putIfAbsent(keyOf(item), () => valueOf(item));\n    }\n    return Map<String, V>.unmodifiable(mutable);\n  }\n\n"
index_text = index.read_text(encoding='utf-8')
if first_value_helper in index_text:
    index.write_text(index_text.replace(first_value_helper, '', 1), encoding='utf-8')
    print('✅ remove unused first-value index helper')
elif 'static Map<String, V> _firstValueBy<T, V>' not in index_text:
    print('✅ remove unused first-value index helper: already applied')
else:
    raise SystemExit(f'❌ remove unused first-value index helper: anchor changed in {index}')

# ---------------------------------------------------------------------------
# Finance: make annual taxes visible before they hit cash.
# ---------------------------------------------------------------------------
finance = ROOT / 'lib/presentation/features/finance/finance_screen.dart'
if not finance.is_file():
    raise SystemExit(f'❌ Missing {finance}')
finance_block = r'''              const SizedBox(height: 18),
              SectionHeader(
                title: 'Налоги и годовой резерв',
                subtitle:
                    'Налоговое обязательство накапливается весь игровой год и списывается отдельной транзакцией.',
                hintTitle: 'Как работают налоги',
                hintBody:
                    'Налог на прибыль считается с положительной накопленной прибыли года. Payroll tax считается с фонда оплаты труда. Ставки задаются городом HQ.',
              ),
              const SizedBox(height: 10),
              Builder(
                builder: (context) {
                  final taxableProfit = math.max(
                    0,
                    state.taxYearRevenueAccrued - state.taxYearExpensesAccrued,
                  );
                  final corporateReserve =
                      taxableProfit * state.effectiveCorporateTaxRate;
                  final payrollReserve =
                      state.taxYearPayrollAccrued * state.effectivePayrollTaxRate;
                  final dayInTaxYear = (state.simulationMinutes ~/ 1440) % 365;
                  final daysUntilTax = 365 - dayInTaxYear;
                  return AppCard(
                    key: const Key('annual-tax-summary'),
                    child: Column(
                      children: [
                        _FinanceStatusRow(
                          label: 'Налог на прибыль',
                          value:
                              '${(state.effectiveCorporateTaxRate * 100).toStringAsFixed(1)}% • резерв ${money(corporateReserve)}',
                        ),
                        _FinanceStatusRow(
                          label: 'Payroll tax',
                          value:
                              '${(state.effectivePayrollTaxRate * 100).toStringAsFixed(1)}% • резерв ${money(payrollReserve)}',
                        ),
                        _FinanceStatusRow(
                          label: 'Ожидаемое списание',
                          value: money(corporateReserve + payrollReserve),
                        ),
                        _FinanceStatusRow(
                          label: 'Регуляторный OPEX / мес.',
                          value: money(state.monthlyRegulatoryComplianceCost),
                        ),
                        _FinanceStatusRow(
                          label: 'До конца налогового года',
                          value: '$daysUntilTax дн.',
                          last: true,
                        ),
                      ],
                    ),
                  );
                },
              ),
'''
replace_once(
    finance,
    "              const SizedBox(height: 18),\n              SectionHeader(\n                title: 'Ликвидность и кредит',\n",
    finance_block + "              const SizedBox(height: 18),\n              SectionHeader(\n                title: 'Ликвидность и кредит',\n",
    'finance annual tax reserve UI',
)


# ---------------------------------------------------------------------------
# Legacy V15/V8 regression: training is now intentionally timed, not instant.
# Keep the old full-suite test, but update its product contract to verify both
# the pending state and the completed 3-day security course.
# ---------------------------------------------------------------------------
engine_test = ROOT / 'test/domain/game_engine_test.dart'
if not engine_test.is_file():
    raise SystemExit(f'❌ Missing {engine_test}')
replace_once(
    engine_test,
    """    state = engine.reduce(
      state,
      TrainEmployee(employeeId: candidateId, programId: 'security'),
    );
    final trained = state.employeeById(candidateId)!;
    expect(trained.skill, before.skill + 4);
    expect(trained.reliability, before.reliability + 6);
    expect(state.cash, cashBefore - 110000);

    final salaryBefore = trained.salary;
""",
    """    state = engine.reduce(
      state,
      TrainEmployee(employeeId: candidateId, programId: 'security'),
    );
    final pending = state.employeeById(candidateId)!;
    expect(pending.skill, before.skill);
    expect(pending.reliability, before.reliability);
    expect(state.trainingForEmployee(candidateId), isNotNull);
    expect(state.cash, cashBefore - 110000);

    state = engine.reduce(
      state.copyWith(paused: false),
      const AdvanceTime(3 * 360),
    );
    final trained = state.employeeById(candidateId)!;
    expect(trained.skill, before.skill + 4);
    expect(trained.reliability, before.reliability + 6);
    expect(state.trainingForEmployee(candidateId), isNull);

    final salaryBefore = trained.salary;
""",
    'legacy training regression uses timed course contract',
)

print('V16 BASE MUTATIONS: PASS')
