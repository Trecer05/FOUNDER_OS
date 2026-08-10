## V17 R14 — empty mutation replacements are first-class operations

- Code deletion is handled by explicit `delete_once()`; empty text is never used as an `already applied` sentinel.
- For non-empty replacements, idempotency still checks the replacement text. For deletions, the old anchor must be present or the mutation fails loudly.
- M&A remains independent from campaign victory; victory still depends only on the three world projects.

## V17 R13 — zero-warning analyzer gate

- `flutter analyze` remains a hard release gate; lint findings are fixed in source rather than ignored.
- The removed product-count victory gate must not survive as constant-false UI state: M&A code contains no `finalAcquisitionLocked` branch.

## V17 R12 — bootstrap capacity is a protected compatibility contract

The V17 resource rebalance must make scaled web/AI products materially expensive without invalidating the starter `shared_launch` path. The zero-user company website therefore uses a deliberately light bootstrap baseline (0.75 GB RAM, 8 GB storage); user-driven demand still scales aggressively. Critical liquidity recovery must not be pre-empted by an artificial overload on the first basic site.

## V17 R11 — component-level Material ownership
- Responsive Infrastructure navigation must not rely on an external Material ancestor. The narrow selector provides `Material(type: MaterialType.transparency)` locally around its `ChoiceChip` controls.
- Keep the desktop segmented selector unchanged.

## V17 R10 — responsive navigation
- On widths below 620px Infrastructure uses a wrapping chip selector instead of an off-screen horizontal segmented control. All primary infrastructure sections must be directly visible and tappable.
- Automated section-switching tests use stable control keys rather than localized display text.

## V17 R9 — UI resilience
- Не расширять продуктовую стратегию ради старого несовместимого save. UI обязан показать текущую legacy-модель без assert, а GameEngine остаётся источником истины для допустимых новых моделей.
- Hosting plan cards на мобильной ширине используют вертикальную компоновку вместо сжатия provider/cost/status/action в одну строку.

# Product and Engineering Decisions

## v15 systemic decisions

- Long-term profitability is not permanent: release age imposes an irreversible freshness ceiling after 180 days, while ordinary updates only recover recency up to that ceiling.
- Product defects are persistent weighted entities (`minor=1`, `major=3`, `critical=7`) that affect latency, reliability, quality, churn and revenue until the team completes a real fix task.
- Post-release feature, technology, improvement and bug work share one technical queue so every change consumes team time and remains explainable.
- Each category has one deterministic 100-point market leader and nineteen varied rivals. The player uses the same visible scoring table and may exceed 100 through stronger product execution.
- VPS is self-service rather than blocked: without DevOps it provides 82% of nominal compute. Managed hosting includes operations in its price; owned infrastructure still requires operational specialists.
- Owned-server capacity is constrained by compute, memory, storage, rack, power, cooling and network. Product overload is defined by the scarcest allocated resource.
- Bankruptcy recovery uses three rotating weekly checkpoints separate from the active autosave. Recovery never silently overwrites the current game; it is an explicit insolvency action.
- Rival cyber incidents are stored as deterministic news and reduce the affected rival's displayed users and market score.

## Product structure

- The interface is list-first and centered on managing company entities rather than a single action dashboard.
- Product metrics belong to product surfaces, not the global dashboard.
- Product development remains active after release through roadmap work and repeatable improvements.
- Market performance is based on product quality, positioning and competition rather than marketing spend alone.

## Simulation

- The simulation is deterministic and driven by `GameEngine` + versioned `GameState` snapshots.
- Development progress is based on working time and effective team capacity.
- Product configuration is constrained by framework, language and technology compatibility.
- Product features and improvements consume team time and operational resources rather than behaving as instant purchases.
- Financial outcomes are modeled through revenue, payroll, infrastructure, marketing, contracts, credit and ownership mechanics.

## Founder and team

- The founder is a real contributor to development but is not represented as an `Employee` record.
- Founder capacity is shared across simultaneous development work.
- Employees may remain assigned to several products, but only products with current development/update work and active contracts count as parallel work. Inactive assignments do not reduce productivity.
- Employee productivity is visible as a percentage and is derived from skill profile, morale, overload and the number of genuinely active work items.
- HR automation reuses suitable existing staff first, fills only required role gaps and does not create spare headcount. The lead HR can hire candidates only at or below the HR's own grade.
- Project and contract staffing rules are explicit and visible to the player.

## Products

- New products begin at zero development progress.
- The player-facing development pipeline uses four stages: planning, design, development and debugging.
- Released products no longer display active development-stage UI.
- Product configuration review prioritizes selected stack, expected development cost and required compute.
- Product improvements are available after release and use the same team-capacity model as other development work.

## Contracts

- Client contracts use assigned capacity rather than an unrestricted global reserve.
- Contract acceptance can automatically match suitable low-load employees to missing roles.
- Parallel contracts share available employee capacity.
- Contract progress, deadlines, payouts and failure conditions are deterministic.

## Infrastructure

- Infrastructure is modeled through measurable capacity, cost and operational limits.
- Rental hosting and owned hardware remain separate capacity models.
- Owned-infrastructure migration is controlled from the compute-allocation surface, next to the capacity it activates.
- Late-game owned hardware provides explicit high-density AI and enterprise tiers with improving cost per compute unit, balanced by rack, power and cooling requirements.
- Office capacity applies to on-site employees; remote employees do not consume physical seats.
- A remote-first company starts without office rent or physical seats.

## Finance and ownership

- Pricing and monetization affect both revenue and market attractiveness.
- Investment changes company ownership and can reduce founder control.
- Forecasts are shown as estimates rather than guaranteed outcomes.
- Credit and negative-cash recovery follow explicit eligibility and failure rules.

## Persistence

- Save writes are serialized so newer state cannot be overwritten by older asynchronous writes.
- Snapshot migrations preserve valid historical state and provide controlled defaults for new fields.
- Platform-specific native code is limited to persistence and diagnostics where necessary; simulation rules remain shared in Dart.

## Localization

- RU and EN presentation use explicit user-facing terminology.
- Technical identifiers, framework names, provider names, language names and common industry abbreviations may remain untranslated where translation reduces clarity.
- Unknown content is never converted into pseudo-localized text.

## Verification

- Changes must pass formatting, static analysis, focused regression tests, the full Flutter test suite and `git diff --check`.
- Platform build checks cover iOS Simulator and Android.
- Physical-device UAT is required before external distribution.


## V15 R4 — совместимость новой ресурсной модели со старой экономикой

- `company_website` остаётся первым лёгким продуктом: его базовая RAM-потребность ниже полноценного SaaS, чтобы `shared_launch` выдерживал базовый сайт при стандартном первом распределении 30% без мгновенной critical overload.
- Multi-resource load по-прежнему определяется самым дефицитным из compute/RAM/storage. Никакой ресурс не исключён из расчёта.
- В market-метриках overload-штраф ограничен диапазоном от 82% до critical threshold 135%. Нагрузка выше 135% всё равно немедленно создаёт `serverOverload` и ставит симуляцию на паузу, поэтому дополнительное обрушение activation/retention сверх этого порога не несёт игрового смысла и не должно инвертировать сравнение качества продуктов.
- Неудачная загрузка ручного save slot обязана восстанавливать simulation ticker через `finally`, независимо от ошибки storage.
- День недели, дата и время остаются визуально двухуровневыми, но рендерятся одним rich-text блоком, чтобы сохранить старый UX-контракт и избежать дублирования `Text`-узлов.

## V16 — география, налоги и экономика роста
- География — системная механика, а не косметический выбор. HQ определяет налоговые ставки и базовую экономику найма; дополнительные офисы/ЦОД расширяют присутствие по миру.
- Городские tax/cost коэффициенты являются игровыми эффективными параметрами для баланса; они не заявляются как реальные действующие налоговые ставки или юридическая консультация.
- Не используется скрытый rubber-banding. Напряжение создают видимые обязательства: payroll, обучение/простой, CAPEX, содержание площадок, налоги, инфраструктура и старение продуктов.
- Аренда и managed hosting сохраняются как ранняя стадия. Собственная распределённая инфраструктура — дорогая mid/late-game стратегия, а не обязательный стартовый расход.
- Курсы не повышают сотрудника мгновенно. Повышение до грейда — отдельный понятный план с автоматически рассчитанными сроком и стоимостью.
- Skill развивается как от курса, так и от активной продуктовой работы. Грейд — следствие компетенции, а не независимая косметическая цифра.
- Сервер физически принадлежит конкретной площадке. Rack/power/cooling нельзя объединять между городами для установки отдельного сервера.
- Налоги списываются раз в 365 игровых дней отдельной транзакцией; игрок заранее видит накопленный резерв.
- HQ rent/utilities и регуляторная нагрузка входят в видимый recurring OPEX; собственные ЦОД продолжают требовать содержания даже когда временно не выбраны активной hosting-схемой.
- Арендованная серверная и собственные ЦОД имеют раздельные физические лимиты: железо одной площадки не может блокировать расширение другой.
- Оптимизация V16 опирается на lazy immutable indexes внутри GameStateIndex, включая city capacity/occupancy/comfort, и не меняет детерминированность reducer/RNG.


## V16 R5 — analyzer hygiene without behavior changes

- Verification hotfixes must not alter gameplay to satisfy lints. Deprecated widget API migrations preserve the same selected values and callbacks.
- Dead immutable-index helpers are removed rather than ignored so hot-path optimization code remains auditable.

## V17 — product pressure, monetization and segmented infrastructure

- Monetization is a product-market decision, not a pure revenue multiplier. Price/paywall/ad/fee pressure must be visible before confirmation and must affect activation, retention, churn and trust.
- Advertising is an ongoing monthly operating decision. Cash is charged proportionally over time; channels remain active until explicitly stopped.
- Organic acquisition is intentionally modest. Marketing, product quality, freshness, retention and a diversified portfolio are the primary paths to sustained growth.
- Launch friction and success difficulty are separate levers: MVP development is slightly faster, while scaling and maintaining a hit product creates higher market and operating pressure.
- A successful product has variable scale operations cost. Revenue can grow faster than cost, but MAU can no longer scale with almost-fixed OPEX.
- Product freshness lifetime is extendable through real product work: new functions, technologies and improvements increase the supported window rather than resetting age for free.
- Senior progression uses grade promotion/work experience instead of ordinary courses. Promotion is a time/cash commitment and changes multiple employee competencies.
- Remote-to-office movement is a paid relocation with duration and seat reservation; office bonuses are not obtained instantly for free.
- Owned infrastructure is service-segmented. API/app, data/storage and AI/compute are routed independently, and new server purchases are dedicated to one service pool. Legacy V16 hardware remains `sharedLegacy` only for save compatibility.
- Performance/algorithm work is allowed to reduce infrastructure demand because optimization should improve both user latency and operating efficiency.
- Finance must explain cash movement. Daily recurring costs are ledger records, and chart history is touch-scrubbable on mobile.
- Runtime lifecycle fixes must remove the underlying unsafe inherited-scope churn rather than suppress Flutter assertions.

## V17 R2 — endgame is built, not counted

- Campaign victory is defined only by completing the three world projects at world status. Ordinary release count and rival acquisition count are no longer victory gates.
- R&D is a company-level reusable capability: research is paid/time-gated once, then implementation still consumes product-team work.
- Market legends are rare strategic opportunities rather than normal candidates. Their 100-stat profile is balanced by enormous recurring compensation, signing cost and demanding eligibility gates.
- Employee benefits are recurring strategic OPEX, not cosmetic toggles. They trade cash for retention/productivity and work together with workload and office conditions.
- Voluntary departures are deterministic-seeded risks with an explicit counter-offer window; player agency exists before a staff loss becomes final.
- Fans/reputation are company capital. Events and open ecosystem choices can grow them; staff failures and exploitative strategy can damage them.
- Limited-time legends and event windows provide FOMO without real-world timers: all deadlines use deterministic in-game time.
- AURA OS and OpenMind AI are world projects, not ordinary aging products. Their progression is defined by dedicated capabilities and ongoing operating cost rather than freshness decay.
- Open vs Control is a visible strategic trade-off: openness favors demand/fans; control favors monetization.
- Philanthropy is intentionally not required to have positive direct ROI; it converts late-game cash into social influence and Legacy Score.
- Post-game direction is unavailable until the campaign is completed and never hard-stops free play.


## V17 R7 — resource optimization and severe churn

- `performance` and `algorithms` improvements must reduce the product's real server footprint, including CPU/compute, not only RAM/storage. The V17 resource optimization multiplier is therefore applied to product compute demand after legacy improvement compute multipliers.
- The previous 38% monthly churn ceiling was too low for failure states because mildly bad and catastrophically aggressive monetization could flatten to the same live metric. The hard safety ceiling is 65%; this is not a target churn value and only permits severe product/monetization failures to remain distinguishable.
- Product Pressure regressions remain strict and are not weakened to accommodate either mismatch.

- V17 R9: legacy-safe monetization dropdown и narrow hosting-plan layout; UI regression gate усилен.

## V17 R15 — prelaunch risk и адаптивная навигация
- Runtime infrastructure risk применяется только к `ProductStage.live`: development-продукт ещё не обслуживает трафик и не должен терять инвестиции из-за непроданной мощности.
- Team averages остаются верхней сводкой, а HR/culture/legends идут после неё.
- Основная NavigationBar должна полностью помещаться и принимать нажатия при viewport 800×600; высота 68 pt закреплена как совместимый desktop/test baseline.

## V17 R16 — нижняя навигация всегда подписана
- Для шести основных разделов используем `NavigationDestinationLabelBehavior.alwaysShow`.
- Причина: скрытые labels остаются в widget tree и могут быть геометрически вне viewport; кроме тестовой проблемы, icon-only navigation хуже объясняет разделы пользователю.
- Высота 68 pt сохраняется; изменение не затрагивает маршрутизацию или состояние игры.

## V17 R17 — документация обязана проходить diff check
- `docs/CHANGELOG.md`, `docs/DECISIONS.md` и `docs/IMPLEMENTATION_STATUS.md` должны заканчиваться ровно одним `\n`, без дополнительной пустой строки в EOF.
- Это release hygiene, а не изменение gameplay: после полностью зелёных тестов/сборок `git diff --check` остаётся обязательным финальным gate.
