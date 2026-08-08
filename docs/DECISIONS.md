# Product and Engineering Decisions

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
- Employees can participate in multiple active work items, with reduced per-work efficiency as workload increases.
- HR automation fills only required role gaps and does not create spare headcount.
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
