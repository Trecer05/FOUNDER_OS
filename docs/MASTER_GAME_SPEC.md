# FOUNDER.OS — MASTER GAME SPECIFICATION

**Статус:** каноническое ТЗ текущей игры
**Источник истины:** актуальный `main` репозитория `Trecer05/FOUNDER_OS` на checkpoint `b453ed8fc3c95a3044bfde3f7bfb66954647dc2d` (`feat: complete R16 business simulation`)
**Snapshot schema:** 16
**Приложение:** Flutter / Dart, offline-first, iOS + Android
**Языки интерфейса:** RU / EN
**Базовая игровая валюта:** RUB; USD/EUR — только отображение по фиксированным offline-курсам

---

## 1. Назначение продукта

FOUNDER.OS — системный tycoon о создании технологической компании от первого bootstrap-продукта до глобальной технологической экосистемы.

Игрок управляет не абстрактным «уровнем компании», а конкретными взаимосвязанными сущностями:

- профилем основателя и штаб-квартирой;
- продуктами и их жизненным циклом;
- исследованиями технологий и функций;
- сотрудниками, HR, назначениями, обучением и релокацией;
- клиентскими контрактами;
- инфраструктурой, hosting и собственными ЦОД;
- безопасностью;
- маркетингом и рекламой;
- monetization и product-market метриками;
- денежным потоком, кредитами, инвесторами и долями;
- внешними инвестициями, конкурентами, M&A;
- экосистемными связями продуктов;
- событиями, фанатами, репутацией и legends;
- мировыми проектами и post-game.

Главный принцип: **каждое сильное действие должно иметь видимую цену, срок, риск или opportunity cost.** Реклама не заменяет продукт, серверы не заменяют команду, инвестиции не являются бесплатными деньгами, а поздняя игра требует миллиардных обязательств.

---

## 2. Техническая архитектура

### 2.1. Основной поток

```text
UI → GameAction → GameController.dispatch → GameEngine.reduce → GameState → UI
```

- `GameState` — immutable source of truth игрового состояния.
- `GameEngine` — детерминированный reducer и симуляция.
- `GameController` — lifecycle, ticker, persistence, manual saves, rollback.
- UI не должен напрямую изменять игровые показатели.
- RNG хранится как `rngSeed + rngCounter`; одинаковый seed и одинаковая последовательность действий должны давать идентичный encoded state.

### 2.2. Platform boundary

Native bridge используется только для:
- atomic snapshot I/O;
- monotonic-clock diagnostics.

Игровая симуляция остаётся в Dart и не должна расходиться между iOS, Android и тестами.

### 2.3. Текущая snapshot schema

`currentSnapshotVersion = 16`.

Требования:
- любой поддерживаемый старый snapshot мигрирует к schema 16;
- snapshot с версией выше текущей отклоняется контролируемой `FormatException`;
- новые поля имеют безопасные migration defaults;
- round-trip `decode(encode(state))` сохраняет игровые сущности и RNG.

---

## 3. Старт новой компании

Исходное состояние:

- игровая дата: **05.01.2026**;
- время: **08:00**;
- игра на паузе;
- скорость `x1`;
- базовый cash до настройки профиля: `450 000 ₽`;
- HQ по умолчанию: Москва;
- офис: `remote_first`;
- server room: `no_server_room`;
- hosting: `no_hosting`;
- серверов нет;
- продуктов нет;
- сотрудников нет;
- контрактов нет;
- инвесторов нет;
- founder ownership: `100%`;
- company fans: `0`;
- brand reputation: `10`;
- mini-games включены;
- рынок кандидатов генерируется детерминированно из seed.

---

## 4. Главное меню, onboarding и shell

### 4.1. Главное меню

Игра стартует с Main Menu. При входе в menu активная симуляция должна быть поставлена на паузу.

Доступны:
- продолжение;
- новая компания;
- ручные save slots;
- вход в игру.

### 4.2. Настройка компании

Игрок задаёт:

- название компании, максимум 28 символов;
- имя CEO, максимум 24 символа;
- логотип `company_logo_01...company_logo_25`;
- стартовый бюджет: `250k / 450k / 750k / 1.2m ₽`;
- background;
- 22 очка навыков основателя;
- HQ city.

Background:
- engineer;
- designer;
- product;
- growth;
- sales;
- operations.

Founder skills:
- engineering;
- design;
- product;
- growth;
- negotiation;
- operations.

Каждый skill: `0...7`, сумма ровно `22`.

Background добавляет +2 к двум тематическим skill, effective skill ограничен 7.

### 4.3. Влияние основателя

Навыки основателя должны влиять на:
- зарплатный multiplier;
- стоимость аренды офиса;
- setup cost продуктов;
- время improvements;
- growth efficiency;
- личный вклад founder в разработку.

Founder не является `Employee` и не занимает физическое место в офисе.

### 4.4. Основная навигация

Шесть постоянных вкладок:

1. Обзор;
2. Продукты;
3. Команда;
4. Инфра;
5. События;
6. Ещё.

Labels в NavigationBar показываются всегда.

В AppBar:
- логотип компании;
- название с ellipsis при нехватке места;
- справа иконки + значения fans и reputation.

Global time controls располагаются поверх основного shell и скрываются при открытой клавиатуре.

---

## 5. Время и симуляция

Скорости:
- x1;
- x2;
- x4.

1 real second = 4 игровых минуты × speed multiplier.

Правила:
- pause блокирует AdvanceTime;
- critical event блокирует обычное течение времени;
- Skip Night симулирует до следующего 08:00;
- рабочие часы используются для development capacity;
- игровые deadlines основаны только на simulation time, не на real-world clock;
- limited-time events/legends используют детерминированное внутриигровое время.

---

## 6. Каталог продуктов

Текущие product blueprints:

1. `company_website` — Сайт компании;
2. `ai_assistant` — AI-ассистент;
3. `cloud_platform` — Cloud-платформа;
4. `team_saas` — Командный SaaS;
5. `privacy_browser` — Браузер;
6. `crypto_wallet` — Криптокошелёк;
7. `city_system` — Цифровая система города;
8. `developer_platform` — Developer platform;
9. `mobile_marketplace` — Мобильный маркетплейс;
10. `analytics_platform` — Analytics Platform;
11. `fintech_payments` — Fintech Payments;
12. `video_workspace` — Video Workspace;
13. `creator_suite` — Creator Suite;
14. `community_platform` — Community Platform;
15. `cloud_drive` — Cloud Drive;
16. `ai_search` — AI Search;
17. `code_forge` — Code Forge.

Каталог определяет:
- category;
- base development cost/hours;
- base price;
- latency/design/security/reliability;
- compute pressure;
- expected features.

ProductCategory:
- aiAssistant;
- cloud;
- saas;
- browser;
- cryptoWallet;
- developerTool.

ProductStage:
- development;
- beta;
- live;
- failed.

---

## 7. Конфигурация нового продукта

Wizard должен проверять:

- blueprint;
- framework;
- language stack;
- technology stack;
- features;
- monetization;
- итоговый review.

Конфигурация ограничивается:
- category/framework compatibility;
- required languages;
- max language count;
- max technology count;
- specialist deficits;
- R&D availability;
- product scope;
- allowed monetization models.

Нельзя создавать продукт с неоткрытой исследованием технологией.

`company_website` — bootstrap path и должен оставаться реальным безопасным первым релизом.

---

## 8. Development lifecycle

Player-facing pipeline:
- planning;
- design;
- implementation/development;
- debugging;
- release/live.

Новый продукт начинает с `developmentProgress = 0`.

Development speed зависит от:
- founder contribution;
- assigned employees;
- skill/role/language coverage;
- active workload;
- product complexity;
- crunch;
- office/perks;
- текущих активных задач.

Технические mini-games/challenges:
- не обязательны для прохождения;
- challenge доступен на implementation/debugging;
- правильный ответ добавляет 30% span текущей стадии и небольшой quality bonus;
- неправильный ответ не должен штрафовать скрыто.

После release development не заканчивается: работают roadmap, features, technologies, bug fixing и improvements.

---

## 9. Product roadmap, bugs и improvements

Post-release work использует реальное время команды.

### 9.1. Features / technologies

- feature/technology сначала исследуется компанией;
- R&D оплачивается один раз на компанию;
- затем интеграция в конкретный продукт занимает team work;
- добавление не является мгновенной покупкой;
- research reusable across products.

### 9.2. Bugs

Bug severity:
- minor = weight 1;
- major = 3;
- critical = 7.

Открытые bugs влияют на:
- latency;
- reliability;
- quality;
- churn;
- revenue.

Fix занимает реальную техническую очередь.

### 9.3. Improvements

Типы:
- performance;
- algorithms;
- design;
- security;
- reliability.

Performance/algorithms должны реально уменьшать resource footprint, включая compute.

Features/tech/improvements увеличивают supported lifetime продукта, но не делают старение бессмысленным.

---

## 10. Causal product-market model

R16-модель должна следовать причинной цепочке:

```text
Interest
→ Started using
→ Active
→ Paying
→ Retained / Churned / Loyal
```

### 10.1. Источники interest

- organic discovery;
- advertising;
- referrals;
- portfolio/ecosystem/brand effects;
- events.

Реклама не должна мгновенно создавать MAU.

### 10.2. Experience

User satisfaction формируется из причин:
- quality;
- reliability;
- speed;
- feature coverage;
- security;
- price fairness;
- monetization comfort;
- staleness;
- bugs.

Satisfaction не должна вычисляться из уже полученных churn/rating/retention, чтобы не создавать feedback loop.

### 10.3. Видимые метрики

Для live product должны быть объяснимо доступны:
- satisfaction;
- trust;
- interest;
- started using;
- users;
- DAU;
- MAU;
- paying users;
- paid conversion;
- CAC;
- ARPU;
- organic acquisition share;
- revenue;
- retention;
- churn;
- rating;
- growth.

---

## 11. Monetization

MonetizationModel:
- free;
- subscription;
- usageBased;
- advertising;
- transactionFee.

Monetization — не чистый revenue multiplier.

Настройки:
- price;
- monetization intensity;
- free tier / paywall;
- ad intensity / fee pressure в зависимости от модели.

Перед подтверждением UI показывает trade-off:
- satisfaction;
- paid conversion;
- monetized users;
- ARPU;
- expected revenue.

Правила:
- более высокая subscription price снижает paid conversion;
- более жёсткий paywall может увеличить short-term revenue, но ухудшает satisfaction/retention;
- чрезмерная монетизация должна давать distinguishable failure state, а не схлопываться с умеренной.

---

## 12. Advertising

AdvertisingAgency содержит:
- quality;
- minimum budget;
- fee;
- forecast accuracy.

AdvertisingChannel содержит:
- CPM/CPC/hybrid billing;
- trust/brand weights;
- category fit.

Campaign:
- ongoing monthly operating decision;
- не списывает весь бюджет upfront;
- списывается пропорционально времени;
- активен до явного Stop;
- одновременно не более трёх каналов;
- forecast показывает impressions/clicks/qualified interest range;
- прогноз не гарантирует пользователей.

---

## 13. Команда и HR

Employee roles:
- productManager;
- frontend;
- backend;
- mobile;
- aiMl;
- designer;
- qa;
- devOps;
- security;
- growth;
- sales;
- support.

Grades:
- intern;
- junior;
- middle;
- senior.

Skill thresholds:
- junior: 45;
- middle: 63;
- senior: 79.

Employee attributes:
- skill;
- speed;
- quality;
- autonomy;
- communication;
- reliability;
- salary;
- loyalty;
- morale;
- workload;
- remote/on-site;
- languages;
- city;
- grade.

### 13.1. Assignments

- employee может быть назначен на несколько продуктов;
- productivity penalty учитывает только реально активную параллельную работу;
- неактивные product assignments не должны штрафовать;
- compute allocation и employee allocation — разные системы.

### 13.2. Office capacity

- remote не занимает seat;
- on-site занимает seat;
- нельзя нанять/переместить on-site сотрудника сверх capacity;
- incoming relocation резервирует место.

### 13.3. Training

Программы:
- architecture;
- quality;
- security;
- leadership.

Обучение:
- стоит денег;
- занимает игровые дни;
- не применяет результат мгновенно.

Senior не проходит обычные курсы; senior progression — отдельный grade upgrade.

### 13.4. Grade upgrade

- отдельный timed plan;
- стоимость зависит от target grade;
- senior upgrade существенно дороже/дольше;
- повышает несколько компетенций;
- grade после work/training соответствует реальному skill.

### 13.5. Relocation

Remote → owned office:
- стоит денег;
- занимает время;
- резервирует seat;
- employee остаётся remote до завершения;
- по завершении меняется city и on-site status.

### 13.6. Wellbeing / retention

На loyalty/morale влияют:
- workload;
- office conditions;
- perks;
- vacation;
- bonus;
- salary;
- remote/on-site context.

Voluntary departure:
- появляется pending departure;
- есть explicit counter-offer window;
- required raise видим;
- пропуск deadline удаляет employee и создаёт notification.

---

## 14. Company perks

Perks включаются сразу для всей компании, но стоимость рассчитывается **на каждого текущего сотрудника** и автоматически меняется при найме/увольнении.

Текущие per-employee значения:

| Perk | Upfront / employee | Monthly / employee |
|---|---:|---:|
| Премиальное железо | 120 000 ₽ | 8 000 ₽ |
| ДМС+ | 15 000 ₽ | 18 000 ₽ |
| Такси до офиса | 5 000 ₽ | 12 000 ₽ |
| Питание и кофе | 20 000 ₽ | 22 000 ₽ |
| Личный бюджет развития | 25 000 ₽ | 28 000 ₽ |
| Family support | 20 000 ₽ | 35 000 ₽ |

Perks дают loyalty/morale/productivity trade-off и являются recurring OPEX.

---

## 15. Клиентские контракты

Contracts открываются после release сайта компании.

Текущие шаблоны:
- landing_launch;
- internal_dashboard;
- mobile_prototype;
- api_integration;
- ai_support_pilot.

Контракт имеет:
- reward;
- development hours;
- deadline;
- upfront percent;
- required roles;
- grace period;
- active/completed/failed state.

Правила:
- прогресс использует назначенную employee capacity;
- контрактные команды отделены от product team;
- auto team использует подходящих существующих сотрудников прежде найма;
- не создаёт лишний headcount;
- параллельные контракты конкурируют за реальную capacity;
- failure/deadline deterministic.

---

## 16. География

Текущие cities:

- Moscow;
- Dubai;
- Singapore;
- San Francisco;
- London;
- Berlin;
- Warsaw;
- Helsinki;
- Bangalore;
- Toronto;
- São Paulo;
- Tokyo;
- Limassol.

Каждый city задаёт:
- corporate tax;
- payroll tax;
- salary multiplier;
- rent multiplier;
- utility multiplier;
- construction multiplier;
- talent;
- investors;
- market access;
- regulation;
- network.

Это **игровые balance coefficients**, не юридическая/налоговая справка.

---

## 17. Offices

FacilitySize:
- small;
- medium;
- large;
- campus.

Seat capacity:
- 12;
- 36;
- 90;
- 220.

FacilityQuality:
- basic;
- standard;
- premium.

Owned office:
- требует CAPEX;
- имеет recurring cost;
- comfort зависит от fitout/equipment;
- город влияет на стоимость;
- влияет только на on-site staff.

Remote-first старт не имеет офисного OPEX.

---

## 18. Hosting и infrastructure

Ранняя игра:
- shared;
- VPS;
- managed hosting;
- rented server room.

Late game:
- owned data centers;
- physical server hardware;
- service routing.

Infrastructure pressure измеряется не одним compute:
- compute;
- RAM;
- storage;
- network;
- rack units;
- power;
- cooling.

Product overload определяется самым дефицитным ресурсом.

VPS без DevOps не блокируется, но даёт 82% nominal compute.

---

## 19. Service-segmented owned infrastructure

InfrastructureService:
- sharedLegacy;
- appApi;
- dataStorage;
- aiCompute.

Правила:
- новые серверы dedicated конкретному service pool;
- `sharedLegacy` только для compatibility старых saves;
- product service может маршрутизироваться в конкретный owned DC;
- ресурсы разных площадок не складываются физически для установки одного сервера;
- owned servers не расходуют capacity rented server room;
- migration/acquisition должны проверять подготовленную capacity.

---

## 20. Security

Security controls:
1. secure_sdlc;
2. sast_dependency;
3. waf_ddos;
4. kms_encryption;
5. backup_dr;
6. soc_response.

Каждый имеет:
- setup cost;
- monthly cost;
- security delta;
- reliability delta;
- incident multiplier.

Security audit сохраняет:
- product;
- risk percent;
- findings;
- simulation time.

Security incident:
- влияет на trust/rating/users/news;
- создаёт critical event;
- до resolution показывает конкретную стоимость локализации;
- resolution списывает ту же стоимость;
- crypto wallet breach имеет особенно тяжёлые последствия;
- attacks могут происходить и у generated competitors.

---

## 21. Финансы и P&L

FinanceTransactionCategory:
- product;
- contract;
- payroll;
- infrastructure;
- security;
- marketing;
- investment;
- financing;
- other.

Финансы показывают:
- cash;
- income run-rate;
- expense run-rate;
- monthly profit;
- runway;
- product revenue;
- payroll;
- hosting/infrastructure;
- advertising;
- security;
- scale operations;
- regulatory cost;
- taxes;
- world-project OPEX/revenue;
- ledger;
- history chart с touch scrub.

Runway warning:
- если monthlyProfit < 0;
- cash > 0;
- runway ≤ 2 месяцев;
- не спамит чаще одного раза за 30 игровых дней.

---

## 22. Business loan

Игрок сам вводит сумму.

Минимальный запрос: 50 000 ₽.

UI до отправки показывает:
- requested amount;
- company valuation;
- долю суммы от valuation;
- approval probability;
- interest;
- total repayment;
- weekly payment.

Правила:
- чем больше amount / valuation, тем ниже approval chance;
- учитываются burn/risk;
- RNG deterministic;
- при approval зачисляется **ровно requested amount**;
- 16 weekly payments;
- active loan — реальное обязательство;
- результат approval/refusal всегда явный.

---

## 23. Negative cash / insolvency / rollback

При проблемах ликвидности доступны:
- controllable business credit;
- emergency liquidity flow;
- insolvency critical event.

GameController хранит 3 rotating weekly bankruptcy checkpoints.

При insolvency UI может:
- восстановить checkpoint примерно за неделю до банкротства;
- начать новую компанию.

Rollback:
- не должен молча перезаписывать current game;
- после восстановления снимает gameOver/critical state и ставит игру на паузу.

---

## 24. Investors и ownership

Investor flow:
- request amount;
- delayed decision;
- counter-offer может быть меньше запроса;
- offer содержит equity/revenue share;
- accept меняет cash и cap table;
- buyback поддерживается;
- founder ownership видим.

Если после сделки founder ownership < 50%:
- gameOver;
- criticalEvent = lostControl.

Отдельные продукты могут требовать minimum investor count.

---

## 25. Competition / Market / M&A

Для каждой product category:
- один deterministic market leader с score 100;
- ещё 19 varied competitors;
- игрок может превысить 100 за счёт реального execution.

Competition учитывает:
- quality;
- features;
- speed;
- reliability;
- trust;
- brand;
- freshness;
- monetization;
- market fit.

Marketing alone не должен побеждать существенно лучший продукт.

Market actions:
- купить внешнюю долю;
- приобрести product;
- migrate users;
- приобрести company;
- сохранить acquired product отдельно либо мигрировать;
- M&A не является условием campaign victory.

---

## 26. Ecosystem

Products могут иметь many-to-many links.

Правила:
- duplicate link запрещён независимо от порядка пары;
- продукт не исчезает после интеграции;
- каждый connected product продолжает самостоятельно зарабатывать;
- связь активируется после integration time;
- corporate AI может быть подключён к собственным продуктам;
- bonus небольшой и не заменяет качество каждого продукта.

---

## 27. R&D

R&D — отдельный company-level экран.

ResearchTargetKind:
- technology;
- feature.

Baseline capabilities:
- PostgreSQL;
- Observability stack.

Technology dependency tree:
- PostgreSQL → Redis;
- Redis → CDN / Vector DB;
- Observability → Kubernetes;
- Observability → E2EE → HSM.

Feature research распределяется по tier/depth из сложности.

Правила:
- locked child нельзя начать без prerequisite;
- цена и срок видны заранее;
- stronger/deeper nodes дороже и дольше;
- completed research reusable;
- integration в live product после research всё равно требует work;
- cost/days завершённого research = 0;
- один и тот же research нельзя оплачивать бесконечно повторно.

---

## 28. Legends

Legends — редкие late-game offers, не обычные candidates.

Текущие:
- Alex Rain — backend/architecture;
- Mira Chen — AI;
- Nick Vale — product;
- Sofia Marquez — growth;
- Ethan Crow — security.

У них:
- all core stats = 100 после найма;
- огромная salary;
- signing cost;
- product-specific unique bonus;
- requirements по valuation/products/city/office quality.

Offer имеет внутриигровой deadline.

---

## 29. Industry events

Текущие:
- Global Tech Expo;
- AI World Summit;
- Founder Week;
- Enterprise Future Forum.

Event:
- entry cost;
- product slot cost;
- максимум 3 showcased products;
- scheduled simulation time;
- даёт users/fans/reputation;
- opportunity имеет deadline.

---

## 30. Fans, reputation и notifications

Company-level:
- fans;
- brand reputation;
- unread notifications.

Источники:
- successful products;
- events;
- ecosystem doctrine;
- philanthropy;
- company events.

UI header:
- fans/reputation справа от company name;
- иконки вместо длинных подписей;
- long name ellipsized.

Notifications:
- employee;
- legend;
- investor;
- tax;
- event;
- research;
- product;
- finance;
- legacy.

Есть Mark All Read.

---

## 31. World projects

Это отдельный late-game тип, не ordinary products и не подчиняется обычному freshness decay.

### 31.1. AURA OS

- 4 phases: 12 / 22 / 38 / 55 млрд ₽;
- 45 / 70 / 95 / 120 дней;
- OPEX 1.8 млрд ₽/мес.;
- revenue 3.6 млрд ₽/мес. после completion;
- valuation gate 25 млрд ₽;
- fans gate 1.5 млн;
- research gate 12;
- required upgrades 8;
- отдельное глубокое дерево upgrades.

### 31.2. OpenMind AI

- 18 / 32 / 52 / 78 млрд ₽;
- 60 / 85 / 120 / 150 дней;
- OPEX 2.6 млрд ₽/мес.;
- valuation gate 45 млрд ₽;
- fans 3 млн;
- research 18;
- upgrades 6.

### 31.3. Planet Compute Grid

- 25 / 45 / 80 / 125 млрд ₽;
- 75 / 110 / 150 / 180 дней;
- OPEX 3.8 млрд ₽/мес.;
- revenue 6.2 млрд ₽/мес. после completion;
- valuation gate 80 млрд ₽;
- fans 5 млн;
- research 24;
- upgrades 5.

World project:
- можно переименовать;
- custom name сохраняется в snapshot;
- завершённый revenue продолжает начисляться отдельно;
- имеет собственный recurring OPEX.

---

## 32. Ecosystem doctrine

Doctrine:
- balanced;
- open;
- dominant.

Смысл:
- open — больше demand/fans;
- dominant — выше monetization/revenue;
- balanced — нейтральный trade-off.

Выбор должен быть видимым стратегическим решением, а не скрытым modifier.

---

## 33. Philanthropy

Late-game cash можно конвертировать в:
- fans;
- reputation;
- Legacy Score.

Philanthropy не обязана иметь положительный прямой ROI.

---

## 34. Campaign victory и post-game

Campaign victory зависит **только** от достижения world status всеми тремя world projects:
- AURA OS;
- OpenMind AI;
- Planet Compute Grid.

Не являются victory gates:
- количество ordinary products;
- число acquisitions;
- размер M&A portfolio.

После victory:
- показывается legacy completion;
- игра не заканчивается принудительно;
- открывается PostGamePath.

PostGamePath:
- infiniteGrowth;
- sellAndExit;
- openFoundation;
- holdingCompany.

До victory выбор post-game path заблокирован.

---

## 35. Critical events

CriticalEventType:
- serverOverload;
- securityBreach;
- lostControl;
- insolvency.

Critical event:
- ставит обычное течение симуляции на паузу;
- требует explicit player response.

Server overload отправляет игрока к инфраструктуре.

Security breach требует localization.

Lost control / insolvency позволяют начать новую компанию; insolvency дополнительно предлагает weekly rollback.

---

## 36. Persistence

### 36.1. Autosave

- controller сохраняет после state-changing actions;
- crossing cash below zero обязательно инициирует save;
- periodic autosave — каждые 4 игровых часа;
- lifecycle pause/inactive/detached вызывает save;
- save writes сериализованы;
- burst coalescing гарантирует, что старый async write не перезапишет более новый state.

### 36.2. Storage hierarchy

Primary:
- native atomic snapshot через NativePerformanceBridge.

Fallback:
- SharedPreferences async snapshot.

Если primary повреждён:
- fallback восстанавливается;
- native primary ремонтируется.

Legacy storage keys мигрируются и удаляются после успешной загрузки.

### 36.3. Manual slots

3 слота:
- slot_1;
- slot_2;
- slot_3.

Manual slot:
- независим от autosave;
- не удаляется при clear autosave;
- повреждённый slot не должен ломать остальные.

### 36.4. Bankruptcy checkpoints

3 rotating recovery slots.

Checkpoint выбирается по simulation time и должен быть не новее target rollback time.

---

## 37. Localization и display preferences

UI поддерживает:
- Russian;
- English.

Display currency:
- RUB;
- USD;
- EUR.

Внутри состояния деньги хранятся в RUB.

Текущие offline display rates:
- USD: 80.9293 RUB;
- EUR: 93.1901 RUB.

Технические названия framework/provider/API могут оставаться без перевода, если перевод ухудшает ясность.

English UI не должен содержать случайную кириллицу в пользовательских строках.

---

## 38. Content / explainability

В игре есть:
- glossary;
- hosting explainability;
- technology limits;
- technology impact;
- specialist deficit explanations;
- configuration resolver.

Игрок должен понимать конкретную причину блокировки или неэффективности, а не получать generic «нельзя».

V9 content validator обязан возвращать 0 issues для production catalog.

---

## 39. Performance и UX contracts

- direct scoped listening вместо небезопасной перестройки inherited tree;
- navigation должна выдерживать быстрые переключения;
- product workspace и infrastructure должны переживать rapid switching;
- narrow iPhone layouts не должны overflow;
- Infrastructure при width < 620 использует адаптивный wrapping selector;
- charts поддерживают touch scrub;
- expensive snapshot encoding может уходить из UI isolate;
- simulation formulas не переносятся в native code.

---

## 40. Каноническая тестовая стратегия

Старые тесты, названные по патчам (`v8`, `v10`, `v11`, `v12`, `v14`, `v15`, `v16`, `v17`, hotfix/optimization/stabilization), не являются источником требований.

Новый suite организован по системе:

### Domain
- simulation contracts;
- company & people;
- product lifecycle;
- market & monetization;
- infrastructure & security;
- finance & ownership;
- contracts/ecosystem/M&A;
- R&D/endgame;
- geography/content;
- persistence schema.

### Application
- controller/persistence ordering;
- storage fallback/manual/recovery;
- preferences/native bridge.

### Presentation
- app shell/navigation;
- core product/team flows;
- business surfaces;
- responsive/localization/critical event flows.

Каждый тест проверяет один актуальный бизнес-инвариант и не зависит от номера исторического патча.

---

## 41. Definition of Done для дальнейших изменений

Изменение считается готовым только если:

1. ТЗ обновлено, если меняется product contract.
2. Domain rule реализован в `GameEngine/GameState`, не в UI.
3. Snapshot compatibility не нарушена.
4. Добавлен/изменён canonical test.
5. `dart format` clean.
6. `flutter analyze` — 0 issues.
7. `python3 tools/audit_current_release.py .` — PASS.
8. English locale audit — PASS.
9. domain tests — PASS.
10. application tests — PASS.
11. presentation/widget tests — PASS.
12. full `flutter test` — PASS.
13. `git diff --check` — PASS.
14. iOS Simulator debug build — PASS.
15. Android build — PASS, когда SDK доступен.
16. Manual Simulator UAT пройден для изменённого user flow.
17. Diff просмотрен; случайных изменений нет.

---

## 42. Что не является источником истины

Не считать доказательством реализации:
- старый номер версии в имени test/audit файла;
- README прошлой версии;
- успешную компиляцию без тестов;
- наличие кнопки без рабочего reducer flow;
- static string audit без runtime/domain regression.

Источники истины:
1. текущий production code;
2. current canonical test suite;
3. MASTER_GAME_SPEC;
4. проходящий runtime UAT.

## UAT Fix Pack R1 — 2026-08-11

Статус: реализуется и проверяется пакетом `CURRENT_UAT_FIXPACK_R1`; ручной UAT после автоматического verifier обязателен.

- R&D на узких iPhone использует вертикальную адаптивную карточку без trailing-overflow; технологии и функции открыты отдельными явно видимыми группами.
- Любой PopupRoute блокирует глобальную панель времени; технический вызов не позволяет нажимать элементы за модальным барьером.
- Стек и функции показывают `++`, `+`, `-` до релиза и в карточке продукта после релиза.
- Русские женские имена получают женскую форму склоняемой фамилии.
- Курсы сотрудников удалены из игрового цикла; новая прокачка запускается только через повышение грейда. Старые snapshot-поля обучения сохраняются для совместимости.
- Клиентский рынок генерирует детерминированные предложения на каждую игровую неделю; сложность и награда растут по числу завершённых контрактов.
- Бизнес-кредит можно закрыть досрочно с исключением ещё не заработанных процентов.
- Исследованные функции реально входят в roadmap; продуктовый fit определяет влияние функции на приток, retention и quality. Неподходящая функция не создаёт спрос сама по себе.
- Окно ручных сохранений адаптивно, скроллится и не должно переполняться на узком iPhone.

## R2 — Background Operations & Product Depth (2026-08-12)

Статус: автоматическая проверка выполняется пакетом R2; ручной Simulator UAT обязателен перед release-ready/commit.

1. Функции первого релиза больше не выдаются бесплатно: выбранная функция должна быть завершена в R&D. Продукт может стартовать без функций.
2. R&D разделён на lazy tabs «Технологии» / «Функции продукта» с ListView.builder и RepaintBoundary.
3. Холодный старт сразу рисует FOUNDER.OS splash с логотипом, реальным progress state и советом; настройки и snapshot грузятся параллельно.
4. При background приложение сохраняет wall-clock. При возврате GameEngine детерминированно догоняет время до elapsed или critical event. Нативный слой прогнозирует ближайший critical event и ставит локальное уведомление.
5. Контракты — primary navigation. Уведомления — top bell; contract=blue, development/product=green.
6. Отказ по business-loan создаёт 7-дневный retry cooldown.
7. Сотрудник без языка проекта работает с 50% language contribution и детерминированно осваивает язык на реальной назначенной работе. Development UI выделяет frontend/backend/server setup/QA phases.
8. Notification center помечает прочитанными только реально построенные видимые карточки, поддерживает clear-all и swipe-left delete.
9. Development technical summary вынесен вверх. Завершение core development — одно notification при launch.
10. Staffing penalty смягчён: один недостающий специалист создаёт bottleneck, но не обрушает всю скорость.
11. Live product показывает acquisition/retention/quality impact текущих функций и improvements.
12. Industry events показывают конкретные игровые даты вместо «через N дней».
13. Overview показывает signed drivers репутации: trust, rating, team loyalty, ecosystem doctrine.
14. Новые уведомления 5 секунд показываются сверху, кликабельны и затем genie-like анимируются в центр уведомлений.
15. Campaign budget масштабируется до 100 млн ₽ и текущего cash, с крупными presets.
16. HR снижает departure probability, постепенно поддерживает loyalty/morale и может автоматически удержать сотрудника небольшим raise.
17. «Жёсткость paywall» → «Жёсткость платного доступа».
18. Free tier теперь положительно влияет на satisfaction/retention и снижает churn pressure.
19. Infrastructure routes разделены по API/storage/AI compute. Dedicated hosting задаётся на product+service, одновременно можно использовать несколько hosting plans и owned DC.
20. Продажа продукта не меняет identity/name остальных продуктов; добавлен regression.
21. Investor-gated продукт можно создать до инвестиций; capacity=0 до нужного количества agreements именно на этот product.

Snapshot schema остаётся 16: новые долговечные правила используют уже сохраняемые Employee.languageIds, FinanceTransaction и ProductServiceRoute.
