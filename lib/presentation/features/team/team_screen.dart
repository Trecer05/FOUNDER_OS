import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/section_header.dart';

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
  _CandidateSort _sort = _CandidateSort.skill;
  bool _remoteOnly = false;

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
              final roleMatch = _role == null || candidate.role == _role;
              final searchMatch =
                  query.isEmpty ||
                  candidate.name.toLowerCase().contains(query) ||
                  roleName(candidate.role).toLowerCase().contains(query);
              final remoteMatch = !_remoteOnly || candidate.remote;
              return roleMatch && searchMatch && remoteMatch;
            })
            .toList(growable: false)
          ..sort(_candidateComparator);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        SectionHeader(
          title: 'Команда',
          subtitle:
              '${state.employees.length}/${state.office.capacity} мест • payroll ${money(state.monthlyPayroll)}/мес.',
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
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Имя или роль',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Все роли'),
                  selected: _role == null,
                  onSelected: (_) => setState(() => _role = null),
                ),
                const SizedBox(width: 8),
                ...EmployeeRole.values.map(
                  (role) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(roleName(role)),
                      selected: _role == role,
                      onSelected: (_) => setState(() => _role = role),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.sort, color: AppColors.textMuted),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Сортировка')),
                    DropdownButton<_CandidateSort>(
                      value: _sort,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(
                          value: _CandidateSort.skill,
                          child: Text('Навык'),
                        ),
                        DropdownMenuItem(
                          value: _CandidateSort.salary,
                          child: Text('Зарплата'),
                        ),
                        DropdownMenuItem(
                          value: _CandidateSort.reliability,
                          child: Text('Надёжность'),
                        ),
                        DropdownMenuItem(
                          value: _CandidateSort.communication,
                          child: Text('Коммуникация'),
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
                  title: const Text('Только remote'),
                  onChanged: (value) => setState(() => _remoteOnly = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (candidates.isEmpty)
            const AppCard(child: Text('По фильтрам кандидаты не найдены.'))
          else
            ...candidates.map(
              (candidate) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CandidateCard(
                  candidate: candidate,
                  canHire:
                      state.employees.length < state.office.capacity &&
                      state.cash >= candidate.salary * 0.35,
                  onHire: () =>
                      widget.controller.dispatch(HireCandidate(candidate.id)),
                ),
              ),
            ),
        ] else if (state.employees.isEmpty)
          const AppCard(
            child: Text('Команда пуста. Наймите людей из рынка кандидатов.'),
          )
        else
          ...state.employees.map(
            (employee) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EmployeeCard(employee: employee),
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
          child: Text(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _roleColor(candidate.role).withAlpha(24),
                foregroundColor: _roleColor(candidate.role),
                child: Text(
                  candidate.name.isEmpty ? '?' : candidate.name.substring(0, 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${roleName(candidate.role)} • ${candidate.remote ? 'remote' : 'office'} • loyalty ${candidate.loyalty}/100',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${money(candidate.salary)}/мес.',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
              child: Text(
                canHire
                    ? 'Нанять • signing ${money(candidate.salary * 0.35)}'
                    : 'Нет места или денег',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.employee});
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _roleColor(employee.role).withAlpha(24),
                foregroundColor: _roleColor(employee.role),
                child: Text(
                  employee.name.isEmpty ? '?' : employee.name.substring(0, 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${roleName(employee.role)} • ${employee.remote ? 'remote' : 'office'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text('${money(employee.salary)}/мес.'),
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
            ],
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
          Text(
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
          Text(
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
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
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
