/// Exact English copy for the founder handbook. Keeping these definitions
/// explicit avoids falling back to transliteration for educational content.
const Map<String, String> glossaryEnglish = <String, String>{
  'Повторяющаяся месячная выручка.': 'Monthly recurring revenue.',
  'Сумма ожидаемых регулярных платежей клиентов за один месяц. Разовые сделки сюда не входят.':
      'The expected recurring customer payments for one month. One-time deals are excluded.',
  '1 000 подписчиков по 500 ₽ дают около 500 000 ₽ MRR до скидок и churn.':
      '1,000 subscribers paying ₽500 generate about ₽500,000 MRR before discounts and churn.',
  'Показывает устойчивость выручки.': 'Shows how stable recurring revenue is.',

  'Повторяющаяся годовая выручка.': 'Annual recurring revenue.',
  'MRR, умноженный примерно на 12. Это ориентир масштаба подписочного бизнеса, а не деньги на счёте.':
      'MRR multiplied by roughly 12. It indicates subscription-business scale, not cash in the bank.',
  'MRR 500 000 ₽ соответствует ARR около 6 млн ₽.':
      '₽500,000 MRR corresponds to roughly ₽6 million ARR.',
  'Инвесторы сравнивают компании по годовому масштабу.':
      'Investors compare companies by annual recurring scale.',

  'Вся выручка компании.': 'All company revenue.',
  'Деньги от продуктов, контрактов и других источников до вычета расходов.':
      'Money from products, contracts, and other sources before expenses.',
  'Подписки и финальная выплата по контракту увеличивают revenue.':
      'Subscriptions and a contract completion payment increase revenue.',
  'Без выручки компания не может долго финансировать рост.':
      'Without revenue, the company cannot fund growth for long.',

  'Выручка минус расходы.': 'Revenue minus expenses.',
  'Положительный profit означает, что компания зарабатывает больше, чем тратит.':
      'Positive profit means the company earns more than it spends.',
  'Revenue 900 000 ₽ и расходы 700 000 ₽ дают profit 200 000 ₽.':
      '₽900,000 revenue and ₽700,000 expenses produce ₽200,000 profit.',
  'Определяет самоокупаемость.':
      'Determines whether the company is self-sustaining.',

  'Скорость сжигания денег.': 'The rate at which cash is being spent.',
  'Сколько денег компания теряет за месяц при отрицательном profit.':
      'How much money the company loses per month when profit is negative.',
  'Profit −300 000 ₽ означает burn rate 300 000 ₽/мес.':
      'A profit of −₽300,000 means a ₽300,000 monthly burn rate.',
  'От burn зависит срок жизни компании.': 'Runway depends on burn.',

  'Сколько месяцев осталось до нуля.':
      'How many months remain before cash reaches zero.',
  'Cash, разделённый на текущий burn rate. Это прогноз при неизменной экономике.':
      'Cash divided by the current burn rate. This is a forecast assuming the economics do not change.',
  '1,2 млн ₽ при burn 300 000 ₽ дают runway 4 месяца.':
      '₽1.2 million with a ₽300,000 burn gives four months of runway.',
  'Помогает понять срочность сокращений или привлечения денег.':
      'Shows how urgently the company must cut costs or raise money.',

  'Начисленная зарплата команды.': 'Accrued team payroll.',
  'Зарплата начисляется пропорционально прошедшему игровому времени. Signing bonus и onboarding cost — отдельные расходы.':
      'Salary accrues in proportion to elapsed game time. Signing bonuses and onboarding costs are separate expenses.',
  'Сотрудник с зарплатой 120 000 ₽ за половину месяца создаёт около 60 000 ₽ payroll.':
      'An employee earning ₽120,000 per month creates about ₽60,000 of payroll over half a month.',
  'Обычно это крупнейшая часть burn.':
      'This is usually the largest part of burn.',

  'Стоимость привлечения клиента.': 'Customer acquisition cost.',
  'Расходы на маркетинг и продажи, поделённые на число новых платящих клиентов.':
      'Marketing and sales spending divided by the number of new paying customers.',
  '100 000 ₽ рекламы и 200 клиентов дают CAC 500 ₽.':
      '₽100,000 of advertising and 200 customers produce a ₽500 CAC.',
  'CAC должен окупаться ценностью клиента.':
      'CAC must be repaid by customer value.',

  'Доход от клиента за всё время.': 'Lifetime value of a customer.',
  'Ожидаемая маржа от клиента до его ухода.':
      'The expected margin from a customer before they leave.',
  'Клиент платит 500 ₽ 12 месяцев — грубый LTV 6 000 ₽.':
      'A customer paying ₽500 for 12 months has a rough LTV of ₽6,000.',
  'LTV выше CAC делает рост экономически разумным.':
      'LTV above CAC makes growth economically sustainable.',

  'Доля ушедших пользователей.': 'The share of users who leave.',
  'Процент клиентов, переставших пользоваться или платить за период.':
      'The percentage of customers who stop using or paying during a period.',
  'Из 1 000 клиентов ушло 80 — churn 8%.':
      'If 80 out of 1,000 customers leave, churn is 8%.',
  'Высокий churn уничтожает MRR.': 'High churn destroys MRR.',

  'Доля вернувшихся пользователей.': 'The share of users who return.',
  'Показывает, сколько пользователей остаются активными после определённого времени.':
      'Shows how many users remain active after a given period.',
  'Retention 30d 40% означает, что через месяц остаются 4 из 10.':
      '40% 30-day retention means four out of ten users remain after a month.',
  'Без retention реклама только временно надувает аудиторию.':
      'Without retention, advertising only inflates the audience temporarily.',

  'Доля пользователей, получивших первую ценность.':
      'The share of users who reach their first value moment.',
  'Процент новых пользователей, совершивших ключевое действие.':
      'The percentage of new users who complete a key action.',
  'Создание первого проекта может быть activation для SaaS.':
      'Creating the first project can be activation for a SaaS product.',
  'Плохая activation ломает воронку сразу после регистрации.':
      'Poor activation breaks the funnel immediately after registration.',

  'Активные пользователи за день.': 'Daily active users.',
  'Уникальные пользователи, использовавшие продукт в течение суток.':
      'Unique users who used the product during one day.',
  'DAU 12 000 означает 12 000 активных за игровой день.':
      'A DAU of 12,000 means 12,000 active users during a game day.',
  'Показывает ежедневную вовлечённость.': 'Shows daily engagement.',

  'Активные пользователи за месяц.': 'Monthly active users.',
  'Уникальные пользователи за последние 30 дней.':
      'Unique users during the last 30 days.',
  'DAU 10 000 и MAU 50 000 дают DAU/MAU 20%.':
      'A DAU of 10,000 and MAU of 50,000 produce a 20% DAU/MAU ratio.',
  'Основа расчёта масштаба аудитории и части монетизации.':
      'A basis for measuring audience scale and some monetization models.',

  'Средняя выручка на пользователя.': 'Average revenue per user.',
  'Revenue продукта, поделённый на число активных пользователей.':
      'Product revenue divided by the number of active users.',
  'MRR 500 000 ₽ при 10 000 MAU даёт ARPU 50 ₽.':
      '₽500,000 MRR with 10,000 MAU produces a ₽50 ARPU.',
  'Показывает качество монетизации.': 'Shows monetization quality.',

  'Цена тысячи показов.': 'Cost per thousand impressions.',
  'Модель рекламы, где оплачивается охват, а не клик.':
      'An advertising model that charges for reach rather than clicks.',
  'CPM 500 ₽ и бюджет 50 000 ₽ дают примерно 100 000 показов.':
      'A ₽500 CPM and ₽50,000 budget produce roughly 100,000 impressions.',
  'Нужен для оценки brand awareness.': 'Used to evaluate brand awareness.',

  'Цена одного клика.': 'Cost per click.',
  'Модель рекламы, где списание привязано к переходу пользователя.':
      'An advertising model in which spending is tied to user clicks.',
  'CPC 100 ₽ и 50 000 ₽ бюджета дают около 500 кликов.':
      'A ₽100 CPC and ₽50,000 budget produce about 500 clicks.',
  'Связывает бюджет с трафиком.': 'Connects budget to traffic.',

  'Доля показов, ставших кликами.':
      'The share of impressions that become clicks.',
  'Клики, поделённые на показы.': 'Clicks divided by impressions.',
  '1 000 кликов из 100 000 показов — CTR 1%.':
      '1,000 clicks from 100,000 impressions produce a 1% CTR.',
  'Показывает привлекательность объявления.':
      'Shows how attractive an advertisement is.',

  'Доля пользователей, совершивших цель.':
      'The share of users who complete a target action.',
  'Например, доля кликов, завершившихся регистрацией или оплатой.':
      'For example, the share of clicks that end in registration or payment.',
  '50 регистраций из 500 кликов — conversion 10%.':
      '50 registrations from 500 clicks produce a 10% conversion.',
  'Определяет результат одного и того же трафика.':
      'Determines the outcome produced by the same traffic.',

  'Насколько рынок знает бренд.': 'How well the market knows the brand.',
  'Узнаваемость повышает органический спрос и эффективность массовой рекламы.':
      'Awareness increases organic demand and the effectiveness of broad advertising.',
  'Обзоры и широкий охват повышают awareness.':
      'Reviews and broad reach increase awareness.',
  'Неизвестный продукт хуже конвертирует большой бюджет.':
      'An unknown product converts a large budget less effectively.',

  'Доверие пользователей к бренду.': 'User trust in the brand.',
  'Зависит от качества, безопасности, uptime, отзывов и истории компании.':
      'Depends on quality, security, uptime, reviews, and company history.',
  'Security breach снижает trust и повышает churn.':
      'A security breach lowers trust and increases churn.',
  'Доверие защищает выручку и цену.': 'Trust protects revenue and pricing.',

  'Доля времени без сбоев.': 'The share of time without outages.',
  '99,9% uptime означает небольшое, но не нулевое время недоступности.':
      '99.9% uptime still includes a small amount of downtime.',
  'Перегрузка hosting plan снижает uptime.':
      'Overloading the hosting plan reduces uptime.',
  'Сбои ухудшают retention и trust.': 'Outages damage retention and trust.',

  'Задержка ответа системы.': 'System response delay.',
  'Время между действием пользователя и ответом продукта.':
      'The time between a user action and the product response.',
  'CDN и cache уменьшают latency, перегрузка увеличивает.':
      'A CDN and cache reduce latency; overload increases it.',
  'Медленный продукт проигрывает конкурентам.':
      'A slow product loses to competitors.',

  'Вычислительная мощность.': 'Compute capacity.',
  'Условные единицы CPU/GPU, доступные продуктам.':
      'Abstract CPU/GPU units available to products.',
  'Нужно compute 120, а plan даёт 80 — запуск блокируется.':
      'If 120 compute is required and the plan provides 80, launch is blocked.',
  'Недостаток compute вызывает перегрузку.':
      'Insufficient compute causes overload.',

  'Место для данных.': 'Space for data.',
  'Базы, файлы, логи и резервные копии занимают storage.':
      'Databases, files, logs, and backups consume storage.',
  'Анализ файлов требует больше storage.':
      'File analysis requires more storage.',
  'Переполненное хранилище останавливает операции.':
      'Full storage stops operations.',

  'Объём передаваемых данных.': 'The amount of data transferred.',
  'Сколько трафика инфраструктура может обслужить за период.':
      'How much traffic the infrastructure can serve during a period.',
  'Видео и файлы быстрее расходуют bandwidth.':
      'Video and files consume bandwidth faster.',
  'Лимит влияет на скорость и стоимость.': 'The limit affects speed and cost.',

  'Обещанный уровень сервиса.': 'The promised service level.',
  'Обязательство провайдера по доступности и реакции на сбои.':
      'A provider commitment covering availability and incident response.',
  'SLA 99,95% надёжнее 98,5%, но дороже.':
      'A 99.95% SLA is more reliable than 98.5%, but costs more.',
  'SLA ограничивает риск downtime.': 'SLA limits downtime risk.',

  'Людей больше эффективного максимума.':
      'The team has more people than its efficient maximum.',
  'Лишние сотрудники увеличивают коммуникации и payroll быстрее, чем скорость.':
      'Extra employees increase communication and payroll faster than delivery speed.',
  '15 человек там, где максимум 10, получают штраф эффективности.':
      'A 15-person team where the maximum is 10 receives an efficiency penalty.',
  'Больше людей не всегда быстрее.': 'More people are not always faster.',

  'Главное узкое место.': 'The primary bottleneck.',
  'Ресурс или роль, которая ограничивает весь проект.':
      'A resource or role that limits the entire project.',
  'Нет DevOps для Kubernetes — bottleneck на стадии архитектуры.':
      'No DevOps specialist for Kubernetes creates an architecture-stage bottleneck.',
  'Устранение bottleneck даёт максимальный эффект.':
      'Removing the bottleneck produces the largest improvement.',

  'План развития продукта.': 'The product development plan.',
  'Последовательность функций, обновлений и технических работ.':
      'A sequence of features, updates, and technical work.',
  'Функции первого релиза образуют стартовый roadmap.':
      'The first-release features form the initial roadmap.',
  'Помогает контролировать scope.': 'Helps control scope.',

  'Будущая цена быстрых решений.': 'The future cost of fast decisions.',
  'Компромиссы ускоряют релиз, но увеличивают поддержку и риск ошибок.':
      'Shortcuts speed up release but increase maintenance and defect risk.',
  'Большой стек и Chromium fork повышают technical debt.':
      'A large stack and Chromium fork increase technical debt.',
  'Долг замедляет будущие обновления.': 'Debt slows future updates.',

  'Доля владения компанией.': 'Ownership in the company.',
  'Процент компании, принадлежащий основателю и инвесторам.':
      'The percentage of the company owned by the founder and investors.',
  'Инвестор получает 10% equity за капитал.':
      'An investor receives 10% equity in exchange for capital.',
  'Ниже 50% основатель теряет контроль.':
      'Below 50%, the founder loses control.',

  'Оценка стоимости компании.': 'Estimated company value.',
  'Расчётная цена бизнеса с учётом выручки, пользователей, технологий и прибыли.':
      'The estimated business price based on revenue, users, technology, and profit.',
  'Рост MRR и качества увеличивает valuation.':
      'Growth in MRR and quality increases valuation.',
  'От оценки зависит цена доли.': 'The share price depends on valuation.',

  'Уменьшение доли основателя.': 'A reduction in the founder’s ownership.',
  'После новых инвестиций доля основателя становится меньше.':
      'After new investment, the founder owns a smaller percentage.',
  'Продажа ещё 15% снижает founder equity.':
      'Selling another 15% reduces founder equity.',
  'Слишком сильное dilution приводит к потере контроля.':
      'Excessive dilution leads to loss of control.',
};
