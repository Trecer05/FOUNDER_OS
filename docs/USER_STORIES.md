# USER_STORIES

## Products

- As a founder, I choose a category, framework, languages, technologies and features so the product has a concrete cost and measurable technical profile.
- As a founder, I open a product card to see users, DAU/MAU, activation, retention, churn, MRR, quality, speed, security and infrastructure load.
- As a founder, I compare my product with a direct competitor to understand why users switch or stay.
- As a founder, I add an expected feature from the product roadmap and see its exact cost and metric effects before confirming.

## Team

- As a founder, I search and filter candidates by role and remote format.
- As a founder, I compare skill, speed, quality, autonomy, communication, reliability and salary before hiring.

## Office and infrastructure

- As a founder, I rent an office based on exact capacity, comfort and cost.
- As a founder, I rent a server room based on rack, cooling, power, network and physical security.
- As a founder, I install concrete server hardware and see why an installation is blocked.
- As a founder, I allocate percentages of total compute to every product and see its load.

## Ecosystem

- As a founder, I connect one product to several different products without merging them.
- As a founder, I cannot create a self-link or reverse duplicate.
- As a founder, I see a limited ecosystem boost while every product retains separate users and revenue.

## Investors

- As a founder, I request a specific amount from a compatible investor.
- As a founder, I receive a refusal or counteroffer based on thesis, readiness, capital and risk.
- As a founder, I may receive an inbound offer when a product and company build a strong track record.
- As a founder, I see exact equity and product revenue share before accepting.
- As a founder, I buy back an investor stake to protect control.
- As a founder, I lose the company when my ownership falls below 50%.

## Market, security and M&A

- As a founder, I invest in external companies and receive portfolio income.
- As a founder, I buy a product and choose to maintain it or migrate users to my analogue.
- As a founder, I prepare spare compute before a migration.
- As a founder, I buy a company together with its product and core team.
- As a founder, I react to attacks and understand their measurable effect.
- As a founder, I read only important competitor, security, funding, deal, market, product and infrastructure news.

## Operations/security v4

### US-OPS-01 — Назначить сотрудника на продукт

Как основатель, я хочу назначить сотрудника на конкретный продукт, чтобы понимать, какой проект получает его вклад.

**Acceptance criteria**

- один сотрудник не может быть назначен на два продукта одновременно;
- новое назначение удаляет предыдущее;
- резерв отображается отдельно;
- product development capacity пересчитывается сразу;
- назначение сохраняется в snapshot.

### US-OPS-02 — Управлять удержанием и развитием сотрудника

Как основатель, я хочу повысить зарплату, обучить или уволить сотрудника, чтобы управлять качеством команды и payroll.

**Acceptance criteria**

- raise увеличивает зарплату, morale и loyalty;
- обучение списывает точную стоимость и меняет заявленные метрики;
- увольнение требует компенсацию 50% зарплаты;
- уволенный сотрудник удаляется из назначения.

### US-SEC-01 — Усилить безопасность продукта

Как основатель, я хочу выбрать конкретные security controls, чтобы снизить вероятность и последствия атаки.

**Acceptance criteria**

- каждый control показывает setup/OPEX/effects до покупки;
- control нельзя купить дважды для одного продукта;
- incident multiplier пересчитывается сразу;
- security OPEX входит в P&L;
- controls сохраняются в snapshot.

### US-SEC-02 — Провести аудит

Как основатель, я хочу провести аудит продукта, чтобы получить risk percent и число findings.

**Acceptance criteria**

- аудит стоит 75 000 ₽;
- запись содержит product ID, время, risk и findings;
- последний аудит виден в Security Center;
- история восстанавливается после перезапуска.

### US-MKT-01 — Понять причину рыночного результата

Как основатель, я хочу видеть метрики конкурента и веса сегментов, чтобы понимать, что именно улучшать в продукте.

**Acceptance criteria**

- сравнение доступно по каждой категории;
- показаны latency, design, security, reliability и аудитория;
- показаны размеры сегментов и их веса;
- экран не создаёт скрытых бонусов и отражает данные market model.

### US-FIN-01 — Видеть структуру P&L

Как основатель, я хочу видеть источники доходов и расходов, чтобы управлять runway.

**Acceptance criteria**

- отдельно показаны payroll, infrastructure, product/marketing, security и investor payouts;
- показаны cash, profit, runway и valuation;
- cap table предупреждает о пороге 50%;
- внешний портфель показан отдельно от продуктовой выручки.

## Guidance/AI/product evolution v5

### US-GUIDE-01 — Понять основной цикл

Как новый основатель, я хочу пройти короткое обучение и открывать контекстные подсказки, чтобы понимать последствия действий без внешней инструкции.

**Acceptance criteria**

- обучение состоит из пяти шагов и показывается один раз;
- его можно пропустить, завершить и открыть повторно;
- карточки имеют круглую `i`-кнопку;
- нажатие на `i` не запускает основное действие карточки.

### US-TEAM-02 — Оценить команду целиком

Как основатель, я хочу видеть средние показатели всех сотрудников, чтобы быстро оценивать сильные и слабые стороны компании.

**Acceptance criteria**

- показаны skill, speed, quality, reliability, morale и loyalty;
- отдельно видны назначенные сотрудники и резерв;
- нулевая команда отображается контролируемо.

### US-PROD-05 — Собрать нужные специальности

Как основатель, я хочу видеть требования по ролям для каждого продукта, чтобы понимать, кого нанимать и назначать.

**Acceptance criteria**

- requirements зависят от категории;
- показаны actual/minimum и reason;
- role coverage входит в development capacity;
- нехватка ролей не является скрытой.

### US-AI-01 — Вывести AI на рынок

Как основатель, я хочу оставить AI публичным продуктом, чтобы она получала пользователей и выручку.

### US-AI-02 — Использовать AI внутри компании

Как основатель, я хочу перевести AI в corporate mode и подключить её к продуктам, чтобы ускорить разработку и повысить качество ценой compute и OPEX.

**Acceptance criteria**

- режимы взаимоисключающие;
- один target использует одну AI;
- одна AI обслуживает несколько targets;
- бонусы, OPEX и compute показаны до действия;
- public/corporate state и integrations сохраняются.

### US-PROD-06 — Поддерживать свежесть продукта

Как основатель, я хочу видеть устаревание и выпускать повторяемые технические обновления, чтобы продукт не умирал после завершения roadmap.

**Acceptance criteria**

- freshness и время с последнего обновления видны;
- устаревание постепенно влияет на рынок;
- пять improvements доступны всегда;
- следующий уровень дороже;
- улучшение возвращает freshness и сохраняется.
