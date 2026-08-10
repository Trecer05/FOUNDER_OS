import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../application/settings/display_preferences.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/v12_models.dart';
import '../../../domain/catalog/world_economy_catalog.dart';
import '../../shared/widgets/company_logo.dart';

Future<void> showCompanySetup(
  BuildContext context,
  GameController controller,
) async {
  if (controller.state.companyProfile.configured) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    useSafeArea: false,
    builder: (_) => _CompanySetupDialog(controller: controller),
  );
}

class _CompanySetupDialog extends StatefulWidget {
  const _CompanySetupDialog({required this.controller});

  final GameController controller;

  @override
  State<_CompanySetupDialog> createState() => _CompanySetupDialogState();
}

class _CompanySetupDialogState extends State<_CompanySetupDialog> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Nova Labs',
  );
  final TextEditingController _founderNameController = TextEditingController(
    text: 'Alex',
  );
  FounderBackground _background = FounderBackground.engineer;
  String _logoId = 'company_logo_01';
  String _headquartersCityId = 'moscow';
  double _budget = 450000;
  final Map<FounderSkill, int> _skills = <FounderSkill, int>{
    FounderSkill.engineering: 4,
    FounderSkill.design: 3,
    FounderSkill.product: 5,
    FounderSkill.growth: 3,
    FounderSkill.negotiation: 3,
    FounderSkill.operations: 4,
  };

  int get _spent => _skills.values.fold<int>(0, (sum, value) => sum + value);
  int get _remaining => FounderCompanyProfile.distributableSkillPoints - _spent;

  @override
  void dispose() {
    _nameController.dispose();
    _founderNameController.dispose();
    super.dispose();
  }

  String _t(String ru, String en) => DisplayPreferences.instance.text(ru, en);

  @override
  Widget build(BuildContext context) {
    final valid =
        _nameController.text.trim().isNotEmpty &&
        _founderNameController.text.trim().isNotEmpty &&
        _remaining == 0;
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(_t('Новая компания', 'New company')),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              Text(
                _t(
                  'Настрой компанию и основателя. Эти параметры влияют на экономику и сохраняются в игре.',
                  'Configure the company and founder. These choices affect the economy and are stored in the snapshot.',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              _SectionTitle(_t('Компания', 'Company')),
              const SizedBox(height: 8),
              TextField(
                key: const Key('company-name-field'),
                controller: _nameController,
                maxLength: 28,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: _t('Название компании', 'Company name'),
                  hintText: 'Nova Labs',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('founder-name-field'),
                controller: _founderNameController,
                maxLength: 24,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: _t('Имя CEO', 'Founder name'),
                  hintText: _t('Алекс', 'Alex'),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Text(
                _t('Стартовый бюджет', 'Starting budget'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <double>[250000, 450000, 750000, 1200000]
                    .map(
                      (value) => ChoiceChip(
                        selected: _budget == value,
                        label: Text(_budgetLabel(value)),
                        onSelected: (_) => setState(() => _budget = value),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 8),
              Text(
                _t(
                  'Бюджет — настройка старта, а не бесплатный доход после начала игры.',
                  'The budget is a starting setup choice, not free money after the game begins.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              _SectionTitle(_t('Логотип', 'Logo')),
              const SizedBox(height: 8),
              GridView.builder(
                key: const Key('company-logo-grid'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 25,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final id =
                      'company_logo_${(index + 1).toString().padLeft(2, '0')}';
                  final selected = id == _logoId;
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _logoId = id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                          width: selected ? 2.5 : 1,
                        ),
                        color: selected
                            ? AppColors.primary.withAlpha(12)
                            : Colors.transparent,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: CompanyLogo(
                        logoId: id,
                        size: 54,
                        borderRadius: 12,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              _SectionTitle(_t('Кем CEO был раньше', 'Founder background')),
              const SizedBox(height: 8),
              ...FounderBackground.values.map(
                (background) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<FounderBackground>(
                    value: background,
                    // ignore: deprecated_member_use
                    groupValue: _background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: Text(
                      DisplayPreferences.instance.isEnglish
                          ? founderBackgroundNameEn(background)
                          : founderBackgroundNameRu(background),
                    ),
                    subtitle: Text(_backgroundDescription(background)),
                    // ignore: deprecated_member_use
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _background = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _SectionTitle(_t('Навыки CEO', 'Founder skills')),
                  ),
                  Text(
                    _t('Осталось: $_remaining', 'Remaining: $_remaining'),
                    style: TextStyle(
                      color: _remaining == 0
                          ? AppColors.green
                          : AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _t(
                  'Распредели ровно ${FounderCompanyProfile.distributableSkillPoints} очков. Предыстория CEO даёт отдельные +2 к двум связанным навыкам и не расходует эти очки.',
                  'Spend exactly ${FounderCompanyProfile.distributableSkillPoints} points. The background adds +2 to two related skills without consuming these points.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              ...FounderSkill.values.map(
                (skill) => _SkillRow(
                  label: DisplayPreferences.instance.isEnglish
                      ? founderSkillNameEn(skill)
                      : founderSkillNameRu(skill),
                  value: _skills[skill] ?? 0,
                  bonus: FounderCompanyProfile(
                    configured: true,
                    companyName: '_',
                    founderName: _founderNameController.text.trim(),
                    logoId: '_',
                    startingBudget: _budget,
                    background: _background,
                    skills: _skills,
                  ).backgroundBonus(skill),
                  canDecrease: (_skills[skill] ?? 0) > 0,
                  canIncrease:
                      _remaining > 0 &&
                      (_skills[skill] ?? 0) <
                          FounderCompanyProfile.maximumSkill,
                  onDecrease: () => setState(
                    () => _skills[skill] = (_skills[skill] ?? 0) - 1,
                  ),
                  onIncrease: () => setState(
                    () => _skills[skill] = (_skills[skill] ?? 0) + 1,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _FounderEffectPreview(
                profile: FounderCompanyProfile(
                  configured: true,
                  companyName: _nameController.text.trim(),
                  founderName: _founderNameController.text.trim(),
                  logoId: _logoId,
                  startingBudget: _budget,
                  background: _background,
                  skills: Map<FounderSkill, int>.unmodifiable(_skills),
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                key: const Key('create-company-button'),
                onPressed: valid ? _complete : null,
                icon: const Icon(Icons.rocket_launch_outlined),
                label: Text(_t('Создать компанию', 'Create company')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _budgetLabel(double value) {
    final amount = value >= 1000000
        ? '${(value / 1000000).toStringAsFixed(1)}M'
        : '${(value / 1000).round()}K';
    final label = switch (value.round()) {
      250000 => _t('Хардкор', 'Hard'),
      450000 => _t('Стандарт', 'Standard'),
      750000 => _t('Комфорт', 'Comfort'),
      _ => _t('Песочница', 'Sandbox'),
    };
    return '$amount ₽ · $label';
  }

  String _backgroundDescription(FounderBackground value) => switch (value) {
    FounderBackground.engineer => _t(
      '+2 Разработка, +2 Операционка. Быстрее пишет код и чинит технические проблемы.',
      '+2 Engineering, +2 Operations. Writes code and solves technical problems faster.',
    ),
    FounderBackground.designer => _t(
      '+2 Дизайн, +2 Продукт. Быстрее проходит дизайн и лучше понимает интерфейс.',
      '+2 Design, +2 Product. Moves through design faster and understands interfaces better.',
    ),
    FounderBackground.product => _t(
      '+2 Продукт, +2 Переговоры. Сильнее в проектировании и продуктовых решениях.',
      '+2 Product, +2 Negotiation. Stronger at planning and product decisions.',
    ),
    FounderBackground.growth => _t(
      '+2 Рост, +2 Продукт. Лучше понимает аудиторию и продуктовый рост.',
      '+2 Growth, +2 Product. Better at audience and product growth.',
    ),
    FounderBackground.sales => _t(
      '+2 Переговоры, +2 Рост. Сильнее в найме, сделках и коммерции.',
      '+2 Negotiation, +2 Growth. Stronger at hiring, deals, and commercial work.',
    ),
    FounderBackground.operations => _t(
      '+2 Операционка, +2 Разработка. Снижает расходы и быстрее устраняет узкие места.',
      '+2 Operations, +2 Engineering. Reduces burn and resolves bottlenecks faster.',
    ),
  };

  void _complete() {
    final profile = FounderCompanyProfile(
      configured: true,
      companyName: _nameController.text.trim(),
      founderName: _founderNameController.text.trim(),
      logoId: _logoId,
      startingBudget: _budget,
      background: _background,
      skills: Map<FounderSkill, int>.unmodifiable(_skills),
    );
    if (!profile.hasValidSkillBudget) return;
    widget.controller.dispatch(
      ConfigureCompany(
        companyName: profile.companyName,
        founderName: profile.founderName,
        logoId: profile.logoId,
        startingBudget: profile.startingBudget,
        background: profile.background,
        skills: profile.skills,
        headquartersCityId: _headquartersCityId,
      ),
      playSound: false,
    );
    Navigator.of(context).pop();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
  );
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.label,
    required this.value,
    required this.bonus,
    required this.canDecrease,
    required this.canIncrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final int value;
  final int bonus;
  final bool canDecrease;
  final bool canIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$label${bonus > 0 ? '  +$bonus ${DisplayPreferences.instance.text('предыстория', 'background')}' : ''}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: canDecrease ? onDecrease : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 30,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: canIncrease ? onIncrease : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _FounderEffectPreview extends StatelessWidget {
  const _FounderEffectPreview({required this.profile});

  final FounderCompanyProfile profile;

  @override
  Widget build(BuildContext context) {
    final english = DisplayPreferences.instance.isEnglish;
    final salaryDiscount = (1 - profile.employeeSalaryMultiplier) * 100;
    final officeDiscount = (1 - profile.officeRentMultiplier) * 100;
    final setupDiscount = (1 - profile.productSetupCostMultiplier) * 100;
    final improvementDiscount = (1 - profile.improvementHoursMultiplier) * 100;
    final growthBonus = (profile.growthEfficiencyMultiplier - 1) * 100;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              english ? 'Current founder bonuses' : 'Текущие бонусы CEO',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              english
                  ? 'Employee salary cost: −${salaryDiscount.toStringAsFixed(1)}%'
                  : 'Стоимость сотрудников: −${salaryDiscount.toStringAsFixed(1)}%',
            ),
            Text(
              english
                  ? 'Office, server room and hosting: −${officeDiscount.toStringAsFixed(1)}%'
                  : 'Офис, серверная и хостинг: −${officeDiscount.toStringAsFixed(1)}%',
            ),
            Text(
              english
                  ? 'Product setup: −${setupDiscount.toStringAsFixed(1)}%'
                  : 'Стартовая настройка продукта: −${setupDiscount.toStringAsFixed(1)}%',
            ),
            Text(
              english
                  ? 'Upgrade work: −${improvementDiscount.toStringAsFixed(1)}%'
                  : 'Время технических улучшений: −${improvementDiscount.toStringAsFixed(1)}%',
            ),
            Text(
              english
                  ? 'Growth efficiency: +${growthBonus.toStringAsFixed(1)}%'
                  : 'Эффективность роста: +${growthBonus.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );
  }
}
