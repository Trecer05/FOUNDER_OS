import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/catalog/operations_catalog.dart';
import '../../../domain/catalog/v17_endgame_catalog.dart';
import '../../../domain/catalog/world_economy_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/models.dart';
import '../../../domain/entities/v12_game_state_extensions.dart';
import '../../../domain/entities/v16_models.dart';
import '../../../domain/entities/v17_models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/compact_team_averages.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';
import '../../../application/localization/app_text.dart';
import '../../../application/localization/app_localizer.dart';

enum _TeamView { candidates, employees }

enum _CandidateSort { skill, salary, reliability, communication }

class TeamScreen extends StatefulWidget {
  const TeamScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final TextEditingController _searchController = TextEditingController();
  _TeamView _view = _TeamView.candidates;
  EmployeeRole? _role;
  EmployeeGrade? _grade;
  _CandidateSort _sort = _CandidateSort.skill;
  bool _remoteOnly = false;
  bool _hrOnly = false;
  final Set<String> _selectedEmployeeIds = <String>{};
  String _bulkTrainingProgramId = OperationsCatalog.trainingPrograms.first.id;
  EmployeeGrade _targetGrade = EmployeeGrade.middle;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final query = _searchController.text.trim().toLowerCase();
    final candidates =
        state.candidates
            .where((candidate) {
              final roleMatch = _hrOnly
                  ? candidate.isHr
                  : _role == null || candidate.role == _role;
              final languageMatch = candidate.languageIds.any(
                (id) => GameCatalog.languageById(
                  id,
                ).name.toLowerCase().contains(query),
              );
              final searchMatch =
                  query.isEmpty ||
                  candidate.name.toLowerCase().contains(query) ||
                  candidateRoleName(candidate).toLowerCase().contains(query) ||
                  languageMatch;
              final remoteMatch = !_remoteOnly || candidate.remote;
              final gradeMatch = _grade == null || candidate.grade == _grade;
              return roleMatch && searchMatch && remoteMatch && gradeMatch;
            })
            .toList(growable: false)
          ..sort(_candidateComparator);
    final employees =
        state.employees
            .where((employee) {
              final roleMatch = _role == null || employee.role == _role;
              final gradeMatch = _grade == null || employee.grade == _grade;
              final remoteMatch = !_remoteOnly || employee.remote;
              final searchMatch =
                  query.isEmpty ||
                  employee.name.toLowerCase().contains(query) ||
                  employeeRoleName(employee).toLowerCase().contains(query) ||
                  employee.languageIds.any(
                    (id) => GameCatalog.languageById(
                      id,
                    ).name.toLowerCase().contains(query),
                  );
              return roleMatch && gradeMatch && remoteMatch && searchMatch;
            })
            .toList(growable: false)
          ..sort((left, right) => right.skill.compareTo(left.skill));

    return ListView(
      key: const Key('team-screen-list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        SectionHeader(
          title: 'Команда',
          subtitle:
              '${state.onSiteEmployeeCount}/${state.totalOfficeCapacity} в офисах • ${state.remoteEmployeeCount} remote • зарплаты ${money(state.monthlyPayroll)}/мес.',
          hintTitle: 'Как читать команду',
          hintBody:
              'Общие значения сверху — средние показатели всех нанятых сотрудников. Назначать и нанимать людей можно прямо из рабочей области проекта.',
          hintBullets: const [
            'Skill и speed ускоряют разработку.',
            'Quality и reliability влияют на результат и стабильность.',
            'Morale и loyalty помогают удерживать сильных сотрудников.',
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          hintTitle: 'Общая статистика команды',
          hintBody:
              'Средние значения считаются по всем сотрудникам компании, включая резерв. Это быстрый индикатор силы команды, но не замена проверке специальностей по каждому продукту.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Средние показатели',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              CompactTeamAverages(state: state),
              const SizedBox(height: 10),
              AppText(
                '${state.employees.length - state.unassignedEmployees.length} назначено • ${state.unassignedEmployees.length} в резерве',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          key: const Key('team-hr-status'),
          hintTitle: 'HR / People Partner',
          hintBody:
              'Только нанятый HR открывает автоматический подбор команды. Грейд HR ограничивает грейд автоматически нанимаемых специалистов: intern нанимает intern, junior — до junior, middle — до middle, senior — любой грейд. HR не считается Product Manager и не закрывает продуктовые дефициты.',
          child: Builder(
            builder: (context) {
              final hiredHr = state.employees
                  .where((item) => item.isHr)
                  .toList();
              final hrCandidates = state.candidates
                  .where((item) => item.isHr)
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'HR / People Partner',
                    translate: false,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    hiredHr.isNotEmpty
                        ? 'Нанят: ${hiredHr.map((item) => '${item.name} (${gradeName(item.grade)})').join(', ')}. Автоподбор доступен.'
                        : 'HR не нанят. Автоподбор проектов заблокирован.',
                  ),
                  if (hiredHr.isEmpty && hrCandidates.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('hire-visible-hr'),
                        onPressed:
                            state.cash >= hrCandidates.first.salary * 0.15
                            ? () => widget.controller.dispatch(
                                HireCandidate(hrCandidates.first.id),
                              )
                            : null,
                        icon: const Icon(Icons.person_add_alt_1),
                        label: AppText(
                          'Нанять ${hrCandidates.first.name} • ${money(hrCandidates.first.salary)}/мес.',
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _companyCultureCard(state),
        const SizedBox(height: 12),
        _legendMarketCard(state),
        if (state.pendingEmployeeDepartures.isNotEmpty) ...[
          const SizedBox(height: 12),
          _departureRiskCard(state),
        ],
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: _ViewButton(
                  label: 'Кандидаты (${state.candidates.length})',
                  selected: _view == _TeamView.candidates,
                  onTap: () => setState(() => _view = _TeamView.candidates),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ViewButton(
                  label: 'Сотрудники (${state.employees.length})',
                  selected: _view == _TeamView.employees,
                  onTap: () => setState(() => _view = _TeamView.employees),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_view == _TeamView.candidates) ...[
          TextField(
            key: const Key('team-candidate-search'),
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: trContext(context, 'Имя, роль или язык'),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const AppText('Все роли'),
                  selected: _role == null && !_hrOnly,
                  onSelected: (_) => setState(() {
                    _role = null;
                    _hrOnly = false;
                  }),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const AppText('HR', translate: false),
                  selected: _hrOnly,
                  onSelected: (_) => setState(() {
                    _role = null;
                    _hrOnly = true;
                  }),
                ),
                const SizedBox(width: 8),
                ...EmployeeRole.values.map(
                  (role) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: AppText(roleName(role)),
                      selected: _role == role,
                      onSelected: (_) => setState(() {
                        _role = role;
                        _hrOnly = false;
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const AppText('Все грейды'),
                  selected: _grade == null,
                  onSelected: (_) => setState(() => _grade = null),
                ),
                const SizedBox(width: 8),
                ...EmployeeGrade.values.map(
                  (grade) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: AppText(gradeName(grade)),
                      selected: _grade == grade,
                      onSelected: (_) => setState(() => _grade = grade),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            hintTitle: 'Фильтры рынка кандидатов',
            hintBody:
                'Каждый профиль генерируется при появлении на рынке. Грейд задаёт диапазон характеристик и зарплаты, а конкретные значения случайны. Имя в рамках одной игры не переиспользуется. Remote-сотрудник не занимает место в офисе.',
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.sort, color: AppColors.textMuted),
                    const SizedBox(width: 10),
                    const Expanded(child: AppText('Сортировка')),
                    DropdownButton<_CandidateSort>(
                      value: _sort,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(
                          value: _CandidateSort.skill,
                          child: AppText('Навык'),
                        ),
                        DropdownMenuItem(
                          value: _CandidateSort.salary,
                          child: AppText('Зарплата'),
                        ),
                        DropdownMenuItem(
                          value: _CandidateSort.reliability,
                          child: AppText('Надёжность'),
                        ),
                        DropdownMenuItem(
                          value: _CandidateSort.communication,
                          child: AppText('Коммуникация'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sort = value);
                        }
                      },
                    ),
                  ],
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _remoteOnly,
                  title: const AppText('Только remote'),
                  onChanged: (value) => setState(() => _remoteOnly = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (candidates.isEmpty)
            const AppCard(child: AppText('По фильтрам кандидаты не найдены.'))
          else
            ...candidates.map(
              (candidate) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CandidateCard(
                  candidate: candidate,
                  cityLabel: _candidateCityLabel(state, candidate),
                  effectiveSalary: _candidateEffectiveSalary(state, candidate),
                  signingBonus: _candidateSigningBonus(state, candidate),
                  canHire:
                      _candidateFitsOffice(state, candidate) &&
                      state.cash >= _candidateSigningBonus(state, candidate),
                  onHire: () =>
                      widget.controller.dispatch(HireCandidate(candidate.id)),
                ),
              ),
            ),
        ] else ...[
          TextField(
            key: const Key('team-employee-search'),
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: trContext(context, 'Имя, роль или язык'),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const AppText('Все роли'),
                  selected: _role == null,
                  onSelected: (_) => setState(() => _role = null),
                ),
                const SizedBox(width: 8),
                ...EmployeeRole.values.map(
                  (role) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: AppText(roleName(role)),
                      selected: _role == role,
                      onSelected: (_) => setState(() => _role = role),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const AppText('Все грейды'),
                  selected: _grade == null,
                  onSelected: (_) => setState(() => _grade = null),
                ),
                const SizedBox(width: 8),
                ...EmployeeGrade.values.map(
                  (grade) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: AppText(gradeName(grade)),
                      selected: _grade == grade,
                      onSelected: (_) => setState(() => _grade = grade),
                    ),
                  ),
                ),
                FilterChip(
                  label: const AppText('Только remote'),
                  selected: _remoteOnly,
                  onSelected: (value) => setState(() => _remoteOnly = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (employees.isNotEmpty) ...[
            _teamDevelopmentCard(state, employees),
            const SizedBox(height: 12),
          ],
          if (state.employees.isEmpty)
            const AppCard(
              child: AppText(
                'Команда пуста. Наймите людей из рынка кандидатов.',
              ),
            )
          else if (employees.isEmpty)
            const AppCard(child: AppText('По фильтрам сотрудники не найдены.'))
          else
            ...employees.map(
              (employee) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _EmployeeCard(
                  state: state,
                  employee: employee,
                  controller: widget.controller,
                  selected: _selectedEmployeeIds.contains(employee.id),
                  onSelectionChanged: (selected) => setState(() {
                    if (selected) {
                      _selectedEmployeeIds.add(employee.id);
                    } else {
                      _selectedEmployeeIds.remove(employee.id);
                    }
                  }),
                ),
              ),
            ),
        ],
      ],
    );
  }

  String _candidateCityLabel(GameState state, Candidate candidate) {
    final city = WorldEconomyCatalog.cityById(
      state.recruitmentCityIdFor(candidate),
    );
    return '${city.cityRu}, ${city.countryRu}';
  }

  double _candidateEffectiveSalary(GameState state, Candidate candidate) {
    final city = WorldEconomyCatalog.cityById(
      state.recruitmentCityIdFor(candidate),
    );
    return candidate.salary *
        state.founderSalaryMultiplier *
        city.salaryMultiplier;
  }

  double _candidateSigningBonus(GameState state, Candidate candidate) {
    final cityId = state.recruitmentCityIdFor(candidate);
    final ownedComfort = state.bestOwnedOfficeComfortIn(cityId);
    final employerBrandDiscount = math
        .max(
          cityId == state.headquartersCityId
              ? state.office.hiringBoostPercent
              : 0,
          ownedComfort / 1000,
        )
        .clamp(0, 0.45)
        .toDouble();
    return candidate.salary *
        0.15 *
        state.founderSalaryMultiplier *
        (1 - employerBrandDiscount);
  }

  bool _candidateFitsOffice(GameState state, Candidate candidate) {
    if (candidate.remote) {
      return true;
    }
    final cityId = state.recruitmentCityIdFor(candidate);
    final legacyCapacity = cityId == state.headquartersCityId
        ? state.office.capacity
        : 0;
    final capacity = legacyCapacity + state.ownedOfficeCapacityIn(cityId);
    return state.onSiteEmployeesIn(cityId) < capacity;
  }

  Widget _teamDevelopmentCard(
    GameState state,
    List<Employee> visibleEmployees,
  ) {
    final selectedEmployees = visibleEmployees
        .where((employee) => _selectedEmployeeIds.contains(employee.id))
        .toList(growable: false);
    final program = OperationsCatalog.trainingProgramById(
      _bulkTrainingProgramId,
    );
    final eligibleEmployees = selectedEmployees
        .where(
          (employee) =>
              employee.grade != EmployeeGrade.senior &&
              state.trainingForEmployee(employee.id) == null &&
              state.gradeUpgradeForEmployee(employee.id) == null &&
              state.relocationForEmployee(employee.id) == null,
        )
        .toList(growable: false);
    final totalCourseCost = eligibleEmployees.fold<double>(
      0,
      (sum, _) => sum + program.cost,
    );
    final allVisibleSelected =
        visibleEmployees.isNotEmpty &&
        visibleEmployees.every(
          (employee) => _selectedEmployeeIds.contains(employee.id),
        );
    final busyCount = selectedEmployees
        .where(
          (employee) =>
              state.trainingForEmployee(employee.id) != null ||
              state.gradeUpgradeForEmployee(employee.id) != null ||
              state.relocationForEmployee(employee.id) != null,
        )
        .length;

    return AppCard(
      key: const Key('team-development-controls'),
      hintTitle: 'Развитие сотрудников',
      hintBody:
          'Курсы занимают реальное игровое время. Во время обучения сотрудник не участвует в разработке. Skill также растёт от активной работы над продуктами, а грейд автоматически подтягивается к накопленному навыку.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  'Развитие команды',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              AppText('Выбрано: ${selectedEmployees.length}'),
            ],
          ),
          const SizedBox(height: 6),
          AppText(
            'Можно выбрать отдельных сотрудников или всех из текущего фильтра. Senior не ходят на обычные курсы: для них используйте повышение грейда и рабочий опыт.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (busyCount > 0)
            AppText(
              'Занятых в выборе: $busyCount — они не входят в стоимость и не будут запущены повторно.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('team-select-all-visible'),
                  onPressed: () => setState(() {
                    if (allVisibleSelected) {
                      for (final employee in visibleEmployees) {
                        _selectedEmployeeIds.remove(employee.id);
                      }
                    } else {
                      _selectedEmployeeIds.addAll(
                        visibleEmployees.map((employee) => employee.id),
                      );
                    }
                  }),
                  icon: Icon(
                    allVisibleSelected
                        ? Icons.deselect_outlined
                        : Icons.select_all_outlined,
                  ),
                  label: AppText(
                    allVisibleSelected ? 'Снять выбор' : 'Выбрать всех',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: trContext(context, 'Очистить выбор'),
                onPressed: _selectedEmployeeIds.isEmpty
                    ? null
                    : () => setState(_selectedEmployeeIds.clear),
                icon: const Icon(Icons.clear_all),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            key: const Key('team-bulk-course-selector'),
            initialValue: _bulkTrainingProgramId,
            isExpanded: true,
            decoration: InputDecoration(labelText: trContext(context, 'Курс')),
            items: OperationsCatalog.trainingPrograms
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.id,
                    child: AppText(
                      '${item.name} • ${item.durationDays} дн. • ${money(item.cost)}',
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                setState(() => _bulkTrainingProgramId = value);
              }
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('team-start-bulk-course'),
              onPressed:
                  eligibleEmployees.isEmpty || state.cash < totalCourseCost
                  ? null
                  : () => widget.controller.dispatch(
                      TrainEmployees(
                        employeeIds: eligibleEmployees
                            .map((employee) => employee.id)
                            .toList(growable: false),
                        programId: _bulkTrainingProgramId,
                      ),
                    ),
              icon: const Icon(Icons.school_outlined),
              label: AppText(
                'Отправить на курс • ${program.durationDays} дн. • ${money(totalCourseCost)}',
              ),
            ),
          ),
          const Divider(height: 28),
          DropdownButtonFormField<EmployeeGrade>(
            key: const Key('team-target-grade-selector'),
            initialValue: _targetGrade,
            decoration: InputDecoration(
              labelText: trContext(context, 'Целевой грейд'),
              helperText: trContext(
                context,
                'Выберите только итоговый грейд — стоимость и срок считаются автоматически.',
              ),
            ),
            items: EmployeeGrade.values
                .map(
                  (grade) => DropdownMenuItem<EmployeeGrade>(
                    value: grade,
                    child: AppText(gradeName(grade)),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                setState(() => _targetGrade = value);
              }
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('team-upgrade-to-grade'),
              onPressed: selectedEmployees.isEmpty
                  ? null
                  : () => widget.controller.dispatch(
                      UpgradeEmployeesToGrade(
                        employeeIds: selectedEmployees
                            .map((employee) => employee.id)
                            .toList(growable: false),
                        targetGrade: _targetGrade,
                      ),
                    ),
              icon: const Icon(Icons.trending_up_outlined),
              label: AppText('Прокачать до ${gradeName(_targetGrade)}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _companyCultureCard(GameState state) {
    return AppCard(
      key: const Key('team-company-perks'),
      hintTitle: 'Условия и плюшки',
      hintBody:
          'Плюшка включается сразу для всей команды. Стоимость считается на каждого сотрудника, поэтому общий расход автоматически меняется после найма или ухода.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Условия команды • ${money(state.monthlyCompanyPerkCost)}/мес.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          AppText(
            'Бонус loyalty +${state.companyPerkLoyaltyBonus} • morale +${state.companyPerkMoraleBonus}',
          ),
          const SizedBox(height: 8),
          ...V17EndgameCatalog.companyPerks.map((perk) {
            final enabled = state.enabledCompanyPerkIds.contains(perk.id);
            final activationCost = state.companyPerkActivationCost(perk.id);
            final monthlyCost = state.companyPerkMonthlyCost(perk.id);
            return SwitchListTile(
              key: Key('company-perk-${perk.id}'),
              contentPadding: EdgeInsets.zero,
              value: enabled,
              onChanged: !enabled && state.cash < activationCost
                  ? null
                  : (_) =>
                        widget.controller.dispatch(ToggleCompanyPerk(perk.id)),
              title: AppText(perk.name),
              subtitle: AppText(
                '${perk.description} • на 1 сотрудника: запуск ${money(perk.upfrontCost)}, ${money(perk.monthlyCost)}/мес. • сейчас ${state.employees.length} чел.: запуск ${money(activationCost)}, ${money(monthlyCost)}/мес. • loyalty +${perk.loyaltyBonus}',
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _departureRiskCard(GameState state) {
    return AppCard(
      key: const Key('team-departure-risks'),
      hintTitle: 'Риск ухода',
      hintBody:
          'Сотрудник может захотеть уйти при низкой loyalty из-за перегруза, простоя и плохих условий. До ухода есть короткое окно на counter-offer повышением зарплаты.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Сотрудники собираются уйти',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...state.pendingEmployeeDepartures.map((departure) {
            final employee = state.employeeById(departure.employeeId);
            if (employee == null) {
              return const SizedBox.shrink();
            }
            final days =
                ((departure.deadlineMinutes - state.simulationMinutes) / 1440)
                    .ceil()
                    .clamp(0, 99);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: AppText(employee.name, translate: false),
              subtitle: AppText(
                'Loyalty ${employee.loyalty}% • workload ${employee.workload}% • уйдёт через $days дн.',
              ),
              trailing: FilledButton.tonal(
                key: Key('counter-offer-${employee.id}'),
                onPressed: () => widget.controller.dispatch(
                  CounterOfferEmployee(employee.id),
                ),
                child: AppText(
                  '+${departure.requiredRaisePercent.round()}% зарплата',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _legendMarketCard(GameState state) {
    return AppCard(
      key: const Key('team-legend-market'),
      hintTitle: 'Легенды рынка',
      hintBody:
          'Легенды появляются редко даже после выполнения требований. У них все рабочие показатели 100, огромная зарплата и signing bonus, а также уникальный случайный буст одному выпущенному продукту.',
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: AppText(
          'Легенды рынка • активных предложений ${state.legendMarketOffers.length}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: const AppText('Редкие специалисты мирового уровня.'),
        children: V17EndgameCatalog.legends
            .map((legend) {
              final offer = state.legendOfferFor(legend.id);
              final hired = state.hiredLegendBonuses.any(
                (item) => item.legendId == legend.id,
              );
              final city = legend.requiredOfficeCityId.isEmpty
                  ? 'любой город'
                  : WorldEconomyCatalog.cityById(
                      legend.requiredOfficeCityId,
                    ).cityRu;
              final officeRequirement = legend.requiredOfficeQuality == null
                  ? 'офис не требуется'
                  : '${_facilityQualityLabel(legend.requiredOfficeQuality!)} офис • $city';
              final eligible = state.hasLegendRequirement(legend.id);
              final product = offer == null
                  ? null
                  : state.productById(offer.productId);
              return ListTile(
                key: Key('legend-${legend.id}'),
                contentPadding: EdgeInsets.zero,
                title: AppText('${legend.name} • ${roleName(legend.role)}'),
                subtitle: AppText(
                  hired
                      ? 'Нанят • все навыки 100.'
                      : offer != null
                      ? '${legend.description} • предложение для ${product?.name ?? 'продукта'} • бонус ${_legendBonusLabel(offer.bonusKind)} • signing ${money(legend.signingCost)} • ${money(legend.salary)}/мес.'
                      : '${legend.description} • ${legend.requiredReleasedProducts} выпущенных продукта • valuation ${money(legend.requiredValuation)} • $officeRequirement • ${eligible ? 'требования выполнены, ждите редкое окно' : 'требования не выполнены'}',
                ),
                trailing: offer != null && !hired
                    ? FilledButton(
                        key: Key('hire-legend-${legend.id}'),
                        onPressed: state.cash >= legend.signingCost
                            ? () => widget.controller.dispatch(
                                HireMarketLegend(
                                  legendId: legend.id,
                                  productId: offer.productId,
                                ),
                              )
                            : null,
                        child: const AppText('Нанять'),
                      )
                    : null,
              );
            })
            .toList(growable: false),
      ),
    );
  }

  String _legendBonusLabel(LegendProductBonusKind kind) => switch (kind) {
    LegendProductBonusKind.performance => 'performance',
    LegendProductBonusKind.reliability => 'reliability',
    LegendProductBonusKind.aiQuality => 'AI quality',
    LegendProductBonusKind.retention => 'retention',
    LegendProductBonusKind.activation => 'activation',
    LegendProductBonusKind.growth => 'growth',
    LegendProductBonusKind.brand => 'brand',
    LegendProductBonusKind.security => 'security',
  };

  String _facilityQualityLabel(FacilityQuality quality) => switch (quality) {
    FacilityQuality.basic => 'Базовый',
    FacilityQuality.standard => 'Стандартный',
    FacilityQuality.premium => 'Премиум',
  };

  int _candidateComparator(Candidate left, Candidate right) => switch (_sort) {
    _CandidateSort.skill => right.skill.compareTo(left.skill),
    _CandidateSort.salary => left.salary.compareTo(right.salary),
    _CandidateSort.reliability => right.reliability.compareTo(left.reliability),
    _CandidateSort.communication => right.communication.compareTo(
      left.communication,
    ),
  };
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary.withAlpha(24) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: AppText(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.cityLabel,
    required this.effectiveSalary,
    required this.signingBonus,
    required this.canHire,
    required this.onHire,
  });

  final Candidate candidate;
  final String cityLabel;
  final double effectiveSalary;
  final double signingBonus;
  final bool canHire;
  final VoidCallback onHire;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: Key('candidate-card-${candidate.id}'),
      hintTitle: 'Кандидат ${candidate.name}',
      hintBody:
          '${gradeName(candidate.grade)} • ${candidateRoleName(candidate)}: ${candidate.isHr ? 'Открывает автоматический подбор команды под проект.' : rolePurpose(candidate.role)} Грейд задаёт вилку зарплаты и показателей, конкретный профиль сгенерирован для этой игры. Языки: ${candidate.languageIds.isEmpty ? 'не указаны' : candidate.languageIds.map((id) => GameCatalog.languageById(id).name).join(', ')}. ${candidate.remote ? 'Remote-кандидат не занимает офисное место.' : 'Office-кандидату требуется свободное место.'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _roleColor(candidate.role).withAlpha(24),
                foregroundColor: _roleColor(candidate.role),
                child: AppText(
                  candidate.name.isEmpty ? '?' : candidate.name.substring(0, 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      candidate.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppText(
                      '${gradeName(candidate.grade)} • ${candidateRoleName(candidate)} • ${candidate.remote ? 'remote' : 'office'} • loyalty ${candidate.loyalty}/100',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AppText(
                '${money(effectiveSalary)}/мес.',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: candidate.languageIds.isEmpty
                ? const <Widget>[Chip(label: AppText('Языки не указаны'))]
                : candidate.languageIds
                      .map(
                        (id) => Chip(
                          avatar: const Icon(Icons.code, size: 16),
                          label: AppText(GameCatalog.languageById(id).name),
                        ),
                      )
                      .toList(growable: false),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.65,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _Skill(label: 'Навык', value: candidate.skill),
              _Skill(label: 'Скорость', value: candidate.speed),
              _Skill(label: 'Качество', value: candidate.quality),
              _Skill(label: 'Автономность', value: candidate.autonomy),
              _Skill(label: 'Коммуникация', value: candidate.communication),
              _Skill(label: 'Надёжность', value: candidate.reliability),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: Key('hire-${candidate.id}'),
              onPressed: canHire ? onHire : null,
              child: AppText(
                canHire
                    ? 'Нанять • $cityLabel • signing bonus ${money(signingBonus)}'
                    : candidate.remote
                    ? 'Недостаточно денег'
                    : 'Нет офисного места или денег',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({
    required this.state,
    required this.employee,
    required this.controller,
    required this.selected,
    required this.onSelectionChanged,
  });
  final GameState state;
  final Employee employee;
  final GameController controller;
  final bool selected;
  final ValueChanged<bool> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final productivity = state.employeeProductivityPercent(employee);
    final activeWorks = state.activeAssignmentCountForEmployee(employee.id);
    final factors = state.employeeProductivityFactors(employee);
    final training = state.trainingForEmployee(employee.id);
    final gradeUpgrade = state.gradeUpgradeForEmployee(employee.id);
    final relocation = state.relocationForEmployee(employee.id);
    final busy = training != null || gradeUpgrade != null || relocation != null;
    final trainingProgram = training == null
        ? null
        : OperationsCatalog.trainingProgramById(training.programId);
    final remainingTrainingDays = training == null
        ? 0
        : ((training.completesAtMinutes - state.simulationMinutes) / 1440)
              .ceil()
              .clamp(0, 999);
    final remainingUpgradeDays = gradeUpgrade == null
        ? 0
        : ((gradeUpgrade.completesAtMinutes - state.simulationMinutes) / 1440)
              .ceil()
              .clamp(0, 999);
    final remainingRelocationDays = relocation == null
        ? 0
        : ((relocation.completesAtMinutes - state.simulationMinutes) / 1440)
              .ceil()
              .clamp(0, 999);
    return AppCard(
      hintTitle: 'Сотрудник ${employee.name}',
      hintBody:
          '${gradeName(employee.grade)} • ${employeeRoleName(employee)}: ${employee.isHr ? 'Разрешает автоматический подбор специалистов под проекты.' : rolePurpose(employee.role)} Языки: ${employee.languageIds.isEmpty ? 'не указаны' : employee.languageIds.map((id) => GameCatalog.languageById(id).name).join(', ')}. Зарплата списывается каждый месяц. Реальный вклад появляется только после назначения на продукт или контракт.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                key: Key('select-employee-${employee.id}'),
                value: selected,
                onChanged: (value) => onSelectionChanged(value ?? false),
              ),
              CircleAvatar(
                backgroundColor: _roleColor(employee.role).withAlpha(24),
                foregroundColor: _roleColor(employee.role),
                child: AppText(
                  employee.name.isEmpty ? '?' : employee.name.substring(0, 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      employee.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppText(
                      '${gradeName(employee.grade)} • ${employeeRoleName(employee)} • ${employee.remote ? 'remote' : 'office'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AppText('${money(employee.salary)}/мес.'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ValueChip('Skill ${employee.skill}'),
              _ValueChip('Quality ${employee.quality}'),
              _ValueChip('Morale ${employee.morale}'),
              _ValueChip('Load ${employee.workload}%'),
              _ValueChip('Loyalty ${employee.loyalty}'),
              ...employee.languageIds.map(
                (id) => _ValueChip(GameCatalog.languageById(id).name),
              ),
            ],
          ),
          if (busy) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(60)),
              ),
              child: AppText(
                training != null
                    ? 'На курсе: ${trainingProgram!.name} • осталось $remainingTrainingDays дн. • разработка приостановлена'
                    : gradeUpgrade != null
                    ? 'Повышение до ${gradeName(gradeUpgrade.targetGrade)} • осталось $remainingUpgradeDays дн. • разработка приостановлена'
                    : 'Релокация в офис • осталось $remainingRelocationDays дн. • разработка приостановлена',
              ),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            key: Key('employee-productivity-${employee.id}'),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: productivity >= 70
                  ? AppColors.green.withAlpha(14)
                  : AppColors.yellow.withAlpha(18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: productivity >= 70
                    ? AppColors.green.withAlpha(80)
                    : AppColors.yellow.withAlpha(90),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: AppText(
                        'Текущая продуктивность',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    AppText(
                      '${productivity.round()}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AppText(
                  'Активных работ: $activeWorks. Назначения без текущей разработки или обновления не создают штраф.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                ...factors.map(
                  (factor) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: AppText(
                      '• $factor',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (employee.grade == EmployeeGrade.senior)
            Container(
              key: Key('senior-development-${employee.id}'),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const AppText(
                'Senior: обычные курсы недоступны. Навыки растут от реальной разработки; для следующего скачка используйте программу повышения грейда.',
              ),
            )
          else
            PopupMenuButton<String>(
              key: Key('train-${employee.id}'),
              enabled: !busy,
              onSelected: (programId) => controller.dispatch(
                TrainEmployee(employeeId: employee.id, programId: programId),
              ),
              itemBuilder: (_) => OperationsCatalog.trainingPrograms
                  .map(
                    (program) => PopupMenuItem<String>(
                      value: program.id,
                      enabled: state.cash >= program.cost,
                      child: AppText(
                        '${program.name} • ${program.durationDays} дн. • ${money(program.cost)}',
                      ),
                    ),
                  )
                  .toList(growable: false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined),
                    SizedBox(width: 8),
                    AppText('Отправить на курс'),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          if (employee.remote && state.ownedOffices.isNotEmpty) ...[
            const SizedBox(height: 8),
            PopupMenuButton<String>(
              key: Key('relocate-${employee.id}'),
              enabled: !busy,
              onSelected: (officeId) => controller.dispatch(
                RelocateEmployeeToOffice(
                  employeeId: employee.id,
                  officeSiteId: officeId,
                ),
              ),
              itemBuilder: (_) => state.ownedOffices
                  .map((office) {
                    final city = WorldEconomyCatalog.cityById(office.cityId);
                    final cost = state.employeeRelocationCost(employee, office);
                    final days = state.employeeRelocationDurationDays(
                      employee,
                      office,
                    );
                    return PopupMenuItem<String>(
                      value: office.id,
                      enabled:
                          state.availableOwnedOfficeSeatsIn(office.cityId) >
                              0 &&
                          state.cash >= cost,
                      child: AppText(
                        '${state.ownedOfficeLabel(office)} • ${city.cityRu} • $days дн. • ${money(cost)}',
                      ),
                    );
                  })
                  .toList(growable: false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flight_takeoff_outlined),
                    SizedBox(width: 8),
                    AppText('Релокация в офис'),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: Key('fire-${employee.id}'),
              onPressed: state.cash >= employee.salary * 0.5
                  ? () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const AppText('Уволить сотрудника?'),
                          content: AppText(
                            '${employee.name} покинет все продукты и контракты. Компенсация: ${money(employee.salary * 0.5)}.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const AppText('Отмена'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const AppText('Уволить'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        controller.dispatch(FireEmployee(employee.id));
                      }
                    }
                  : null,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.red),
              icon: const Icon(Icons.person_remove_outlined),
              label: AppText('Уволить • ${money(employee.salary * 0.5)}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Skill extends StatelessWidget {
  const _Skill({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              height: 1,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 3),
          AppText(
            '$value',
            style: const TextStyle(
              fontSize: 14,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

Color _roleColor(EmployeeRole role) => switch (role) {
  EmployeeRole.productManager => AppColors.yellow,
  EmployeeRole.frontend => AppColors.primary,
  EmployeeRole.backend => AppColors.cyan,
  EmployeeRole.mobile => AppColors.violet,
  EmployeeRole.aiMl => AppColors.violet,
  EmployeeRole.designer => AppColors.green,
  EmployeeRole.qa => AppColors.textMuted,
  EmployeeRole.devOps => AppColors.cyan,
  EmployeeRole.security => AppColors.red,
  EmployeeRole.growth => AppColors.green,
  EmployeeRole.sales => AppColors.yellow,
  EmployeeRole.support => AppColors.textMuted,
};
