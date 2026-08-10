#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding='utf-8')
    if new and new in text:
        print(f'✅ {label}: already applied')
        return
    if old not in text:
        raise SystemExit(f'❌ {label}: anchor not found in {path}')
    path.write_text(text.replace(old, new, 1), encoding='utf-8')
    print(f'✅ {label}')


def delete_once(
    path: Path,
    old: str,
    label: str,
    forbidden_marker: str,
) -> None:
    text = path.read_text(encoding='utf-8')
    if old in text:
        path.write_text(text.replace(old, '', 1), encoding='utf-8')
        print(f'✅ {label}')
        return
    if forbidden_marker not in text:
        print(f'✅ {label}: already applied')
        return
    raise SystemExit(
        f'❌ {label}: exact delete anchor not found but stale marker remains in {path}'
    )


# ---------------------------------------------------------------------------
# GameState lazy indexes for V17 relocation + service routing.
# ---------------------------------------------------------------------------
index = ROOT / 'lib/domain/entities/game_state_index.dart'
if not index.is_file():
    raise SystemExit(f'❌ Missing {index}')
replace_once(
    index,
    """  late final Map<String, EmployeeGradeUpgrade> gradeUpgradeByEmployee =
      _firstBy<EmployeeGradeUpgrade>(
        state.employeeGradeUpgrades,
        (item) => item.employeeId,
      );
""",
    """  late final Map<String, EmployeeGradeUpgrade> gradeUpgradeByEmployee =
      _firstBy<EmployeeGradeUpgrade>(
        state.employeeGradeUpgrades,
        (item) => item.employeeId,
      );
  late final Map<String, EmployeeRelocationAssignment> relocationByEmployee =
      _firstBy<EmployeeRelocationAssignment>(
        state.employeeRelocations,
        (item) => item.employeeId,
      );
  late final Map<String, ProductServiceRoute> serviceRouteByProductAndService =
      _firstBy<ProductServiceRoute>(
        state.productServiceRoutes,
        (item) => pair(item.productId, item.service.name),
      );
""",
    'V17 relocation and service-route indexes',
)

# ---------------------------------------------------------------------------
# Finance history: finger/touch scrubbing and a longer detailed ledger.
# ---------------------------------------------------------------------------
finance = ROOT / 'lib/presentation/features/finance/finance_screen.dart'
if not finance.is_file():
    raise SystemExit(f'❌ Missing {finance}')
replace_once(
    finance,
    """  _FinanceSeries _series = _FinanceSeries.cash;
  bool _dailyProfit = false;
  final TextEditingController _promoController = TextEditingController();
""",
    """  _FinanceSeries _series = _FinanceSeries.cash;
  bool _dailyProfit = false;
  int? _selectedHistoryIndex;
  final TextEditingController _promoController = TextEditingController();
""",
    'finance selected history index',
)

text = finance.read_text(encoding='utf-8')
chart_start_marker = """                    SizedBox(
                      key: const Key('finance-history-chart'),
                      height: 210,
                      width: double.infinity,
                      child: CustomPaint(
"""
chart_end_marker = """                    const SizedBox(height: 8),
                    AppText(
                      'Точек: ${history.length} • от дня ${history.first.simulationMinutes ~/ 1440 + 1} до дня ${history.last.simulationMinutes ~/ 1440 + 1}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
"""
if "finance-history-selection" not in text:
    start = text.find(chart_start_marker)
    end = text.find(chart_end_marker, start)
    if start < 0 or end < 0:
        raise SystemExit(f'❌ finance interactive chart anchors not found in {finance}')
    end += len(chart_end_marker)
    replacement = r'''                    LayoutBuilder(
                      builder: (context, constraints) {
                        void selectAt(double dx) {
                          if (history.isEmpty || constraints.maxWidth <= 0) {
                            return;
                          }
                          final fraction = (dx / constraints.maxWidth)
                              .clamp(0.0, 1.0)
                              .toDouble();
                          final index =
                              (fraction * math.max(0, history.length - 1))
                                  .round()
                                  .clamp(0, history.length - 1)
                                  .toInt();
                          if (_selectedHistoryIndex != index) {
                            setState(() => _selectedHistoryIndex = index);
                          }
                        }

                        return GestureDetector(
                          key: const Key('finance-history-chart'),
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (details) =>
                              selectAt(details.localPosition.dx),
                          onHorizontalDragStart: (details) =>
                              selectAt(details.localPosition.dx),
                          onHorizontalDragUpdate: (details) =>
                              selectAt(details.localPosition.dx),
                          child: SizedBox(
                            height: 210,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _FinanceChartPainter(
                                points: history,
                                series: _series,
                                lineColor: _series == _FinanceSeries.expenses
                                    ? AppColors.red
                                    : _series == _FinanceSeries.profit &&
                                          state.monthlyProfit < 0
                                    ? AppColors.red
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final index = (_selectedHistoryIndex ?? history.length - 1)
                            .clamp(0, history.length - 1)
                            .toInt();
                        final point = history[index];
                        final value = switch (_series) {
                          _FinanceSeries.cash => point.cash,
                          _FinanceSeries.income => point.incomeRunRate,
                          _FinanceSeries.expenses => point.expenseRunRate,
                          _FinanceSeries.profit => point.profitRunRate,
                        };
                        final label = switch (_series) {
                          _FinanceSeries.cash => 'Cash',
                          _FinanceSeries.income => 'Доход / мес.',
                          _FinanceSeries.expenses => 'Расход / мес.',
                          _FinanceSeries.profit => 'Profit / мес.',
                        };
                        return Container(
                          key: const Key('finance-history-selection'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AppText(
                            '${state.formatDateAt(point.simulationMinutes)} • $label ${money(value)} • проведите пальцем по графику',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      'Точек: ${history.length} • от дня ${history.first.simulationMinutes ~/ 1440 + 1} до дня ${history.last.simulationMinutes ~/ 1440 + 1}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
'''
    finance.write_text(text[:start] + replacement + text[end:], encoding='utf-8')
    print('✅ finance finger-scrubbable history chart')
else:
    print('✅ finance finger-scrubbable history chart: already applied')

finance_text = finance.read_text(encoding='utf-8')
finance_text = finance_text.replace(
    """                subtitle:
                    'Разовые покупки, авансы, инвестиции и другие изменения cash.',
""",
    """                subtitle:
                    'Разовые покупки и ежедневные списания. Для крупных расходов здесь видна категория и причина.',
""",
    1,
)
finance_text = finance_text.replace('.take(30)', '.take(60)', 1)
finance_text = finance_text.replace(
    """                    _BreakdownBar(
                      label: 'Безопасность',
                      value: state.monthlySecurityCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Выплаты инвесторам',
""",
    """                    _BreakdownBar(
                      label: 'Безопасность',
                      value: state.monthlySecurityCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Реклама',
                      value: state.monthlyAdvertisingSpend,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Масштабирование продуктов',
                      value: state.monthlyScaleOperationsCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Регуляторные расходы',
                      value: state.monthlyRegulatoryComplianceCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Плюшки команды',
                      value: state.monthlyCompanyPerkCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Мировые проекты',
                      value: state.monthlyWorldProjectOperatingCost,
                      total: state.monthlyCosts,
                    ),
                    _BreakdownBar(
                      label: 'Выплаты инвесторам',
""",
    1,
)
finance.write_text(finance_text, encoding='utf-8')
print('✅ finance detailed ledger window')


# ---------------------------------------------------------------------------
# Remove the obsolete product-count legacy goal from Products and Market UI.
# The campaign is now completed only through the three world projects.
# ---------------------------------------------------------------------------
products_screen = ROOT / 'lib/presentation/features/products/products_screen.dart'
if not products_screen.is_file():
    raise SystemExit(f'❌ Missing {products_screen}')
replace_once(
    products_screen,
    """          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag_outlined, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        'Путь основателя: ${state.releasedBlueprintCount}/${state.requiredReleasedBlueprintsForLegacy} разных релизов',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                LinearProgressIndicator(value: state.legacyProductProgress),
                const SizedBox(height: 7),
                AppText(
                  state.legacyProductRequirementMet
                      ? 'Порог 70% пройден. Финальная консолидация рынка доступна.'
                      : 'Для финала нужно самостоятельно выпустить не меньше 70% направлений каталога. Купленные продукты не засчитываются.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
""",
    """          AppCard(
            key: const Key('world-project-legacy-summary'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.public_outlined, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        'Мировые проекты: ${(state.worldProjectCompletionProgress * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                LinearProgressIndicator(value: state.worldProjectCompletionProgress),
                const SizedBox(height: 7),
                AppText(
                  state.founderLegacyCompleted
                      ? 'Все три мировых проекта завершены. Кампания пройдена, свободная игра продолжается.'
                      : 'Обычные продукты больше не закрывают кампанию. Финал — AURA OS, OpenMind AI и Planet Compute Grid во вкладке «События».',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
""",
    'products world-project legacy summary',
)

market_screen = ROOT / 'lib/presentation/features/market/market_screen.dart'
if not market_screen.is_file():
    raise SystemExit(f'❌ Missing {market_screen}')
replace_once(
    market_screen,
    """                    _InfoRow(
                      'Путь основателя',
                      '${state.releasedBlueprintCount}/${state.requiredReleasedBlueprintsForLegacy} релизов',
                    ),
""",
    """                    _InfoRow(
                      'Мировые проекты',
                      '${(state.worldProjectCompletionProgress * 100).round()}% завершено',
                    ),
""",
    'market world-project status',
)
replace_once(
    market_screen,
    """                    AppText(
                      state.founderLegacyCompleted
                          ? 'Рынок консолидирован. Вы достигли финала Founder Legacy.'
                          : state.legacyProductRequirementMet
                          ? 'Порог 70% выполнен — можно завершать консолидацию рынка.'
                          : 'Последнего конкурента можно поглотить только после самостоятельного релиза 70% каталога.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
""",
    """                    AppText(
                      state.founderLegacyCompleted
                          ? 'Мировые проекты завершены. Кампания пройдена, M&A остаётся частью свободной игры.'
                          : 'Покупка конкурентов больше не является условием финала. Победа достигается тремя мировыми проектами.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
""",
    'market removes old 70-percent legacy copy',
)
delete_once(
    market_screen,
    """    final finalAcquisitionLocked =
        !acquired &&
        state.remainingRivalCount == 1 &&
        !state.legacyProductRequirementMet;
""",
    'market removes obsolete last-rival lock variable',
    'finalAcquisitionLocked',
)
replace_once(
    market_screen,
    """              onPressed: !acquired &&
                      !finalAcquisitionLocked &&
                      state.cash >= remainingCompanyPrice
""",
    """              onPressed: !acquired &&
                      state.cash >= remainingCompanyPrice
""",
    'market acquisition button no longer reads obsolete victory lock',
)
delete_once(
    market_screen,
    """          if (finalAcquisitionLocked) ...[
            const SizedBox(height: 8),
            AppText(
              'Финальная сделка: сначала ${state.requiredReleasedBlueprintsForLegacy} собственных релизов (${state.releasedBlueprintCount} готово).',
              style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w700),
            ),
          ],
""",
    'market removes unreachable final-acquisition warning',
    'Финальная сделка: сначала',
)


# ---------------------------------------------------------------------------
# Legacy tests now honour the R&D-before-implementation contract.
# ---------------------------------------------------------------------------
game_engine_test = ROOT / 'test/domain/game_engine_test.dart'
if not game_engine_test.is_file():
    raise SystemExit(f'❌ Missing {game_engine_test}')
replace_once(
    game_engine_test,
    "import 'package:founder_os/domain/entities/product_evolution_models.dart';\n",
    "import 'package:founder_os/domain/entities/product_evolution_models.dart';\nimport 'package:founder_os/domain/entities/v17_models.dart';\n",
    'game engine test V17 research import',
)
replace_once(
    game_engine_test,
    """    final cashBefore = state.cash;

    state = engine.reduce(
      state,
      AddProductFeature(productId: created.id, featureId: 'file_analysis'),
    );
""",
    """    final cashBefore = state.cash;
    state = state.copyWith(
      completedResearchKeys: <String>[
        state.researchKey(ResearchTargetKind.feature, 'file_analysis'),
      ],
    );

    state = engine.reduce(
      state,
      AddProductFeature(productId: created.id, featureId: 'file_analysis'),
    );
""",
    'game engine feature roadmap uses completed R&D',
)

product_economy_test = ROOT / 'test/domain/product_economy_v8_test.dart'
if not product_economy_test.is_file():
    raise SystemExit(f'❌ Missing {product_economy_test}')
replace_once(
    product_economy_test,
    "import 'package:founder_os/domain/entities/product_strategy_models.dart';\n",
    "import 'package:founder_os/domain/entities/product_strategy_models.dart';\nimport 'package:founder_os/domain/entities/v17_models.dart';\n",
    'product economy V17 research import',
)
replace_once(
    product_economy_test,
    """    final product = state.products.single;
    final beforeCash = state.cash;

    state = engine.reduce(
      state,
      AddProductFeature(productId: product.id, featureId: 'contact_form'),
    );
""",
    """    final product = state.products.single;
    final beforeCash = state.cash;
    state = state.copyWith(
      completedResearchKeys: <String>[
        state.researchKey(ResearchTargetKind.feature, 'contact_form'),
      ],
    );

    state = engine.reduce(
      state,
      AddProductFeature(productId: product.id, featureId: 'contact_form'),
    );
""",
    'product economy feature roadmap uses completed R&D',
)


# ---------------------------------------------------------------------------
# V13 release-candidate regressions: product-count victory was intentionally
# replaced by the three world projects. M&A is no longer locked behind 70%.
# ---------------------------------------------------------------------------
v13_release_test = ROOT / 'test/domain/v13_release_candidate_test.dart'
if not v13_release_test.is_file():
    raise SystemExit(f'❌ Missing {v13_release_test}')
replace_once(
    v13_release_test,
    """    expect(GameState.initial().requiredReleasedBlueprintsForLegacy, 12);\n""",
    """    expect(GameState.initial().requiredReleasedBlueprintsForLegacy, 0);\n""",
    'V13 catalog regression uses world-project victory contract',
)
replace_once(
    v13_release_test,
    """  test('rival landscape is billion-scale and final acquisition respects 70 percent gate', () {\n""",
    """  test('rival landscape is billion-scale and final acquisition is independent from campaign victory', () {\n""",
    'V13 final-acquisition test title',
)
replace_once(
    v13_release_test,
    """    final blocked = engine.reduce(\n      state,\n      AcquireMarketCompany(last.id),\n    );\n\n    expect(blocked.acquiredRivalCount, GameCatalog.marketCompanies.length - 1);\n    expect(blocked.feed.first, contains('Финальная сделка'));\n""",
    """    final acquired = engine.reduce(\n      state,\n      AcquireMarketCompany(last.id),\n    );\n\n    expect(acquired.acquiredRivalCount, GameCatalog.marketCompanies.length);\n    expect(acquired.founderLegacyCompleted, isFalse);\n""",
    'V13 M&A no longer completes or blocks the campaign',
)


# ---------------------------------------------------------------------------
# Hosting plans: narrow iPhone cards must not overflow horizontally.
# Keep plan title/provider/cost and action stacked so long localized text wraps.
# ---------------------------------------------------------------------------
hosting = ROOT / 'lib/presentation/shared/widgets/hosting_plans_panel.dart'
if not hosting.is_file():
    raise SystemExit(f'❌ Missing {hosting}')
replace_once(
    hosting,
    """                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              plan.name,
                              translate: false,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Flexible(
                                  child: AppText(
                                    plan.provider,
                                    translate: false,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                                AppText(
                                  ' • ${owned ? 'CAPEX' : '${money(plan.monthlyCost)}/мес.'}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (current)
                        const Chip(label: AppText('Текущий'))
                      else if (owned)
                        const Chip(
                          avatar: Icon(Icons.pie_chart_outline, size: 18),
                          label: AppText('Миграция в «Мощностях»'),
                        )
                      else
                        FilledButton(
                          key: Key('select-hosting-${plan.id}'),
                          onPressed: reasons.isEmpty
                              ? () => controller.dispatch(
                                  RentHostingPlan(plan.id),
                                )
                              : null,
                          child: const AppText('Арендовать'),
                        ),
                    ],
                  ),
""",
    """                  AppText(
                    plan.name,
                    translate: false,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    plan.provider,
                    translate: false,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    owned ? 'CAPEX' : '${money(plan.monthlyCost)}/мес.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: current
                        ? const Chip(label: AppText('Текущий'))
                        : owned
                        ? const Chip(
                            avatar: Icon(Icons.pie_chart_outline, size: 18),
                            label: AppText('Миграция в «Мощностях»'),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              key: Key('select-hosting-${plan.id}'),
                              onPressed: reasons.isEmpty
                                  ? () => controller.dispatch(
                                      RentHostingPlan(plan.id),
                                    )
                                  : null,
                              child: const AppText('Арендовать'),
                            ),
                          ),
                  ),
""",
    'hosting plans narrow responsive layout',
)

print('V17 BASE MUTATIONS: PASS')
