# FOUNDER.OS v12 — Founder Expansion

## Goal

v12 turns the founder from an abstract owner into a real participant in the simulation and makes product development visibly happen instead of being represented only by a progress bar.

## Company setup

A new company configures:
- company name;
- founder / CEO name;
- one of four starting budgets: 250k / 450k / 750k / 1.2m RUB;
- one of 25 transparent logo assets;
- founder background;
- exactly 12 distributable founder skill points.

The budget can only be chosen before the company is created. `ConfigureCompany` is ignored after the profile is configured, preventing repeated free cash changes.

## Founder backgrounds

- Engineer — +2 Engineering, +2 Operations.
- Designer — +2 Design, +2 Product.
- Product manager — +2 Product, +2 Negotiation.
- Growth marketer — +2 Growth, +2 Product.
- Sales / BizDev — +2 Negotiation, +2 Growth.
- Operations manager — +2 Operations, +2 Engineering.

Background bonuses do not consume the 12 distributable points.

## Founder skills

- Engineering
- Design
- Product
- Growth
- Negotiation
- Operations

A configured founder:
- contributes development capacity to every product stage;
- shares personal capacity across all simultaneously developing products;
- reduces negotiated employee salaries;
- reduces office rent;
- reduces initial product setup costs;
- reduces work hours for product improvements and new features.

The founder never becomes a fake `Employee`; this keeps headcount, payroll and office-capacity rules correct.

## Remote-first company

A new company starts in `remote_first`:
- rent: 0;
- deposit: 0;
- on-site capacity: 0;
- remote candidates can be hired;
- an office is optional until on-site employees are needed.

Once a paid office is rented, its rent is charged even if seats are temporarily empty.

## Development pipeline

Player-facing pipeline:
1. Planning — 0–20%
2. Design — 20–38%
3. Development — 38–82%
4. Debugging — 82–100%

The original strategy phases remain available for deeper staffing logic, while v12 adds a simpler player-facing four-stage layer.

### Planning content

A deterministic combinatorial spec generator combines:
- 16 goal sections;
- 16 architecture sections;
- 16 data sections;
- 16 risk sections.

That produces 65,536 base document combinations. Each blueprint adds 12 product-specific contexts, so one product type has up to 786,432 authored combinations before day/seed selection; across the eight blueprint families the catalog can address more than 6.2 million deterministic planning combinations.

### Design content

The design stage combines multiple layout families and UX focuses and renders a deterministic animated wireframe. No external image generation or network access is required.

### Development content

The catalog includes code pools for:
- HTML/CSS
- JavaScript
- TypeScript
- Python
- Go
- Rust
- Dart
- Swift
- Kotlin
- Java
- PHP
- C++

The visible language follows the primary language chosen for the product. Each development scene composes two distinct authored snippets plus a product-specific context, producing far more visible combinations than the raw snippet count alone.

### Debugging content

Each supported language has a pool of realistic error messages. A debugging scene combines a primary failure, a secondary trace and product-specific context; selection is deterministic from save seed + product + game day.

### Mini-challenges

When mini-games are enabled, the current stage can offer one challenge per product per game day.
- one clearly correct option;
- two intentionally unsafe/incorrect options;
- correct answer adds a small progress/quality bonus;
- the same daily challenge cannot be farmed repeatedly.

## HR exact auto-hire

Auto-hire now:
1. requires a hired HR / People Partner;
2. reads minimum role requirements;
3. subtracts roles already assigned to the product;
4. hires only the missing number;
5. never creates spare headcount;
6. prefers language fit, then quality, then lower salary;
7. keeps HR outside project assignments.

## Product-improvement crash recovery

Legacy/malformed improvement work can contain identifiers that no longer map to a `ProductImprovementType`. v12 never calls `values.byName` on an untrusted identifier.

Unknown improvement or feature work is skipped with a controlled feed message instead of throwing `Bad state: No element`.

## Localization

v12 keeps technical identifiers and familiar role names intact in RU where translation hurts clarity:
- Frontend
- Backend
- DevOps / SRE
- Product Manager
- HR / People Partner
- framework/language/provider names
- promo codes
- CU / U / kW / Gbps

Business/UI wording that is clearer in Russian is translated, e.g. `Hiring` → `Бонус к найму`.

English localization receives an additional high-coverage explicit phrase/word lexicon on top of the existing localization adapter. New v12 screens use explicit RU/EN pairs for dynamic text.

## Native code

The existing iOS Swift / Android Kotlin native bridge remains responsible for critical atomic snapshot persistence and monotonic diagnostics. Domain simulation stays shared in deterministic Dart; duplicating simulation logic in two native implementations would create platform divergence and is intentionally avoided.

## Verification

`tools/verify_v12_founder_expansion.sh` runs:
- v12 static/content audit;
- existing localization/native audit;
- dependency resolution;
- Dart format;
- Flutter analyze;
- focused v12 domain tests;
- focused v12 widget tests;
- snapshot/migration regressions;
- all domain tests;
- all application/presentation tests;
- full Flutter test suite;
- git diff check;
- iOS Simulator debug build;
- Android debug build.

Physical iPhone UAT remains mandatory before commit/push.
