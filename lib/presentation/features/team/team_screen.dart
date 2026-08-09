import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/game_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/models.dart';
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

    return ListView(
      key: const Key('team-screen-list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        SectionHeader(
          title: 'Команда',
          subtitle:
              '${state.onSiteEmployeeCount}/${state.office.capacity} в офисе • ${state.remoteEmployeeCount} remote • зарплаты ${money(state.monthlyPayroll)}/мес.',
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
                  canHire:
                      (candidate.remote ||
                          state.onSiteEmployeeCount < state.office.capacity) &&
                      state.cash >= candidate.salary * 0.15,
                  onHire: () =>
                      widget.controller.dispatch(HireCandidate(candidate.id)),
                ),
              ),
            ),
        ] else if (state.employees.isEmpty)
          const AppCard(
            child: AppText('Команда пуста. Наймите людей из рынка кандидатов.'),
          )
        else
          ...state.employees.map(
            (employee) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EmployeeCard(state: state, employee: employee),
            ),
          ),
      ],
    );
  }

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
    required this.canHire,
    required this.onHire,
  });

  final Candidate candidate;
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
                '${money(candidate.salary)}/мес.',
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
                    ? 'Нанять • signing bonus ${money(candidate.salary * 0.15)}'
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
  const _EmployeeCard({required this.state, required this.employee});
  final GameState state;
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final productivity = state.employeeProductivityPercent(employee);
    final activeWorks = state.activeAssignmentCountForEmployee(employee.id);
    final factors = state.employeeProductivityFactors(employee);
    return AppCard(
      hintTitle: 'Сотрудник ${employee.name}',
      hintBody:
          '${gradeName(employee.grade)} • ${employeeRoleName(employee)}: ${employee.isHr ? 'Разрешает автоматический подбор специалистов под проекты.' : rolePurpose(employee.role)} Языки: ${employee.languageIds.isEmpty ? 'не указаны' : employee.languageIds.map((id) => GameCatalog.languageById(id).name).join(', ')}. Зарплата списывается каждый месяц. Реальный вклад появляется только после назначения на продукт или контракт.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
          const SizedBox(height: 12),
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
