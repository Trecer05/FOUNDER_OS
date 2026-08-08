import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../settings/display_preferences.dart';
import 'glossary_english.dart';
import 'v12_localization_lexicon.dart';

/// Runtime localization adapter used while historic UI strings are extracted
/// from the domain/content catalog. New UI should still pass explicit RU/EN
/// pairs through [DisplayPreferences.text].
///
/// The adapter has two strict guarantees:
/// - RU presentation translates only authored UI phrases. Unknown Latin copy,
///   proper names, technical roles, units and promo codes remain untouched.
/// - EN presentation contains no Cyrillic fallback. Known copy is translated;
///   unknown proper/content names are transliterated rather than leaking a
///   second alphabet into the English interface.
abstract final class AppLocalizer {
  static const int _cacheLimit = 768;
  static final LinkedHashMap<String, String> _translationCache =
      LinkedHashMap<String, String>();
  static const Set<String> approvedRussianTerms = <String>{
    'activation',
    'ai',
    'api',
    'arr',
    'arpu',
    'bandwidth',
    'bottleneck',
    'brand',
    'brand awareness',
    'burn',
    'burn rate',
    'rate',
    'cac',
    'cdn',
    'churn',
    'compute',
    'conversion',
    'cpc',
    'cpm',
    'cpu',
    'crm',
    'ctr',
    'dau',
    'devops',
    'dilution',
    'equity',
    'fte',
    'gpu',
    'hr',
    'frontend',
    'backend',
    'product manager',
    'people partner',
    'ml',
    'latency',
    'ltv',
    'mau',
    'mrr',
    'onboarding',
    'overstaffing',
    'profit',
    'ram',
    'retention',
    'revenue',
    'roadmap',
    'runway',
    'saas',
    'sla',
    'storage',
    'technical',
    'technical debt',
    'debt',
    'trust',
    'uptime',
    'valuation',
    'vpn',
    'qa',
    'b2b',
    'b2c',
    'ios',
    'android',
    'swift',
    'kotlin',
    'flutter',
    'dart',
    'kubernetes',
    'redis',
    'postgresql',
    'javascript',
    'typescript',
    'python',
    'rust',
    'go',
    'html',
    'css',
    'sql',
    'm&a',
    'capex',
    'opex',
  };

  static const Map<String, String> _ruExact = <String, String>{
    'Cash': 'Деньги',
    'Framework': 'Фреймворк',
    'Hosting': 'Хостинг',
    'Development capacity': 'Скорость разработки',
    'Stack coherence': 'Совместимость стека',
    'Coherence': 'Совместимость',
    'Workload': 'Нагрузка',
    'Morale': 'Мораль',
    'Skill': 'Навык',
    'Security score': 'Уровень безопасности',
    'Signing bonus': 'Бонус при найме',
    'Hiring': 'Бонус к найму',
    'Runway': 'Запас денег',
    'Valuation': 'Оценка компании',
    'Burn': 'Темп расходов',
    'Burn rate': 'Темп расходов',
    'Revenue share': 'Доля выручки',
    'Cap table': 'Структура владения',
    'Profit': 'Прибыль',
    'Revenue': 'Выручка',
    'Equity': 'Доля',
    'Dilution': 'Размытие доли',
    'Onboarding': 'Вводное обучение',
    'Overstaffing': 'Лишний найм',
    'Capacity': 'Мощность разработки',
    'Security': 'Безопасность',
    'Incident multiplier': 'Коэффициент риска',
    'Setup': 'Разовая настройка',
    'Users': 'Пользователи',
    'Rating': 'Рейтинг',
    'Load': 'Загрузка',
    'Fresh': 'Свежесть',
    'Activation': 'Активация',
    'Retention': 'Удержание',
    'Retention 30d': 'Удержание 30 дн.',
    'Churn': 'Отток',
    'Latency': 'Задержка',
    'Design': 'Дизайн',
    'Reliability': 'Надёжность',
    'Security operations': 'Управление безопасностью',
    'Secure SDLC': 'Безопасный SDLC',
    'SAST + dependency scanning': 'SAST + сканирование зависимостей',
    'WAF и DDoS protection': 'WAF и защита от DDoS',
    'Backups и disaster recovery': 'Резервные копии и аварийное восстановление',
    'SOC и incident response': 'SOC и реагирование на инциденты',
    'Application Security': 'Безопасность приложений',
    'Cold start': 'Холодный запуск',
    'Vendor lock-in': 'Зависимость от поставщика',
    'Provider lock-in': 'Зависимость от провайдера',
    'Mobile': 'Мобильная разработка',
    'AI/ML': 'AI/ML',
    'Ai Ml': 'AI/ML',
    'Designer': 'Дизайнер',
    'QA': 'QA',
    'Qa': 'QA',
    'DevOps': 'DevOps',
    'Devops': 'DevOps',
    'Security Engineer': 'Инженер по безопасности',
    'Growth': 'Рост',
    'Sales': 'Продажи',
    'Support': 'Поддержка',
    'Company website': 'Сайт компании',
    'AI assistant': 'AI-ассистент',
    'Cloud platform': 'Облачная платформа',
    'Team SaaS': 'Командный SaaS',
    'Privacy browser': 'Защищённый браузер',
    'Crypto wallet': 'Криптокошелёк',
    'City system': 'Городская система',
    'Developer platform': 'Платформа для разработчиков',
    'Product': 'Продукт',
    'Overview': 'Обзор',
    'Development': 'Разработка',
    'Marketing': 'Маркетинг',
    'Metrics': 'Метрики',
    'Infrastructure': 'Инфраструктура',
    'Team': 'Команда',
    'Settings': 'Настройки',
    'Language': 'Язык',
    'Currency': 'Валюта',
    'Save': 'Сохранить',
    'Cancel': 'Отмена',
    'Close': 'Закрыть',
    'Continue': 'Продолжить',
    'Search': 'Поиск',
    'Active': 'Активно',
    'Pending': 'Ожидание',
    'Completed': 'Завершено',
    'Failed': 'Провалено',
  };

  static const Map<String, String> _ruPhrases = <String, String>{
    'development capacity': 'скорость разработки',
    'coherence': 'совместимость',
    'stack coherence': 'совместимость стека',
    'security score': 'уровень безопасности',
    'signing bonus': 'бонус при найме',
    'provider lock-in': 'зависимость от провайдера',
    'vendor lock-in': 'зависимость от поставщика',
    'cold start': 'холодный запуск',
    'failover': 'аварийное переключение',
    'cache invalidation': 'сброс кэша',
    'downtime': 'простой',
    'observability': 'наблюдаемость',
    'cash flow': 'денежный поток',
    'cashflow': 'денежный поток',
    'coordination cost': 'расходы на координацию',
    'setup cost': 'расходы на запуск',
    'hardware': 'оборудование',
    'software': 'программное обеспечение',
    'capacity': 'мощность',
    'active compute': 'активная вычислительная мощность',
    'prepared compute': 'подготовленная вычислительная мощность',
    'hosting plan': 'тариф хостинга',
    'server load': 'нагрузка на серверы',
    'monthly cost': 'ежемесячные расходы',
    'monthly revenue': 'ежемесячная выручка',
    'team capacity': 'возможности команды',
    'product workspace': 'рабочее пространство продукта',
    'feature development': 'разработка функции',
    'grace period': 'льготный срок',
    'auto-hire': 'автоматический найм',
    'auto hire': 'автоматический найм',
    'people partner': 'специалист по персоналу',
    'product manager': 'менеджер продукта',
    'mobile developer': 'мобильный разработчик',
    'ai/ml engineer': 'AI/ML-инженер',
    'cloud platform': 'облачная платформа',
    'company website': 'сайт компании',
    'ai assistant': 'AI-ассистент',
    'privacy browser': 'защищённый браузер',
    'crypto wallet': 'криптокошелёк',
    'city system': 'городская система',
    'developer platform': 'платформа для разработчиков',
    'framework requires': 'фреймворк требует',
    'cash': 'деньги',
    'payroll': 'зарплаты',
    'runway': 'запас денег',
    'valuation': 'оценка компании',
    'burn rate': 'темп расходов',
    'burn': 'расходы',
    'revenue share': 'доля выручки',
    'cap table': 'структура владения',
    'profit': 'прибыль',
    'revenue': 'выручка',
    'equity': 'доля',
    'dilution': 'размытие доли',
    'onboarding': 'вводное обучение',
    'overstaffing': 'лишний найм',
    'product': 'продукт',
    'team': 'команда',
    'overview': 'обзор',
    'development': 'разработка',
    'marketing': 'маркетинг',
    'metrics': 'метрики',
    'infrastructure': 'инфраструктура',
    'settings': 'настройки',
    'language': 'язык',
    'currency': 'валюта',
    'save': 'сохранить',
    'cancel': 'отмена',
    'close': 'закрыть',
    'continue': 'продолжить',
    'search': 'поиск',
    'feature': 'функция',
    'features': 'функции',
    'technology': 'технология',
    'technologies': 'технологии',
    'languages': 'языки',
    'framework': 'фреймворк',
    'compute': 'вычислительная мощность',
    'hosting': 'хостинг',
    'provider': 'провайдер',
    'vendor': 'поставщик',
    'workload': 'нагрузка',
    'morale': 'мораль',
    'backend': 'серверная разработка',
    'frontend': 'интерфейсная разработка',
    'security engineer': 'инженер по безопасности',
    'performance': 'производительность',
    'reliability': 'надёжность',
    'security': 'безопасность',
    'quality': 'качество',
    'scalability': 'масштабируемость',
    'remote': 'удалённо',
    'monthly': 'ежемесячно',
    'maximum': 'максимум',
    'minimum': 'минимум',
    'optimal': 'оптимум',
    'starter': 'начальный',
    'standard': 'стандартный',
    'advanced': 'продвинутый',
    'moonshot': 'прорывной',
    'active': 'активно',
    'pending': 'ожидание',
    'live': 'запущен',
    'failed': 'провален',
    'free': 'бесплатно',
    'subscription': 'подписка',
    'usage based': 'оплата за использование',
    'usage-based': 'оплата за использование',
    'transaction fee': 'комиссия за операции',
    'transaction-fee': 'комиссия за операции',
    'onboarding cost': 'расходы на адаптацию',
    'scope': 'объём работ',
  };

  static const Map<String, String> _enExact = <String, String>{
    'Деньги': 'Cash',
    'День': 'Day',
    'Обзор': 'Overview',
    'Продукты': 'Products',
    'Продукт': 'Product',
    'Команда': 'Team',
    'Менеджер продукта': 'Product Manager',
    'Мобильная разработка': 'Mobile development',
    'Дизайнер': 'Designer',
    'Инженер по безопасности': 'Security Engineer',
    'Рост': 'Growth',
    'Продажи': 'Sales',
    'Поддержка': 'Support',
    'Специалист по персоналу': 'People Partner',
    'Сайт компании': 'Company website',
    'AI-ассистент': 'AI assistant',
    'Облачная платформа': 'Cloud platform',
    'Командный SaaS': 'Team SaaS',
    'Защищённый браузер': 'Privacy browser',
    'Криптокошелёк': 'Crypto wallet',
    'Городская система': 'City system',
    'Платформа для разработчиков': 'Developer platform',
    'Инфра': 'Infrastructure',
    'Инфраструктура': 'Infrastructure',
    'Ещё': 'More',
    'Финансы': 'Finance',
    'Инвесторы': 'Investors',
    'Контракты': 'Contracts',
    'Операции': 'Operations',
    'Настройки': 'Settings',
    'Язык': 'Language',
    'Валюта': 'Currency',
    'Русский': 'Russian',
    'Английский': 'English',
    'Начать новую компанию': 'Start a new company',
    'Новая компания': 'New company',
    'Начать заново?': 'Start over?',
    'Текущее локальное сохранение будет удалено.':
        'The current local save will be deleted.',
    'Отмена': 'Cancel',
    'Сбросить': 'Reset',
    'Закрыть': 'Close',
    'Продолжить': 'Continue',
    'Сохранить': 'Save',
    'Поиск': 'Search',
    'Не найдено': 'Not found',
    'Всё': 'All',
    'Загрузка…': 'Loading…',
    'Разработка': 'Development',
    'Реклама': 'Marketing',
    'Маркетинг': 'Marketing',
    'Метрики': 'Metrics',
    'Мощности': 'Capacity',
    'Скорость разработки': 'Development capacity',
    'Совместимость стека': 'Stack coherence',
    'Совместимость': 'Coherence',
    'Нагрузка': 'Workload',
    'Мораль': 'Morale',
    'Навык': 'Skill',
    'Уровень безопасности': 'Security score',
    'Бонус при найме': 'Signing bonus',
    'Фреймворк': 'Framework',
    'Вычислительная мощность': 'Compute capacity',
    'Хостинг': 'Hosting',
    'Арендованный хостинг': 'Rented hosting',
    'Собственные серверы': 'Owned servers',
    'Активная мощность': 'Active capacity',
    'Подготовленные серверы': 'Prepared servers',
    'Нанять': 'Hire',
    'Нанять под проект': 'Hire for project',
    'Нанять команду под проект': 'Hire a team for project',
    'Автоматический найм': 'Automatic hiring',
    'Отправить в отпуск': 'Send on vacation',
    'Корпоративный бонус': 'Wellbeing bonus',
    'Повысить зарплату': 'Give a raise',
    'Уволить': 'Fire',
    'Активно': 'Active',
    'Ожидание': 'Pending',
    'Завершено': 'Completed',
    'Провалено': 'Failed',
    'Заблокировано': 'Blocked',
    'Доступно': 'Available',
    'Недоступно': 'Unavailable',
    'Доход': 'Income',
    'Расход': 'Expense',
    'Прибыль': 'Profit',
    'Выручка': 'Revenue',
    'Расходы': 'Costs',
    'Оценка компании': 'Company valuation',
    'Срок жизни': 'Runway',
    'Кредит': 'Loan',
    'Взять кредит': 'Take a loan',
    'Переговоры': 'Negotiation',
    'Предложение': 'Offer',
    'Отклонено': 'Rejected',
    'Принять': 'Accept',
    'Отклонить': 'Reject',
    'Требования': 'Requirements',
    'Причина': 'Reason',
    'Следующий шаг': 'Next step',
    'Лимит языков': 'Language limit',
    'Лимит технологий': 'Technology limit',
    'Функции': 'Features',
    'Технологии': 'Technologies',
    'Языки': 'Languages',
    'Название': 'Name',
    'Создать продукт': 'Create product',
    'Запустить продукт': 'Launch product',
    'Пользователи': 'Users',
    'Активные пользователи': 'Active users',
    'Цена': 'Price',
    'Срок': 'Deadline',
    'Прогресс': 'Progress',
    'Риск': 'Risk',
    'Надёжность': 'Reliability',
    'Безопасность': 'Security',
    'Дизайн': 'Design',
    'Качество': 'Quality',
    'Поиск кандидатов': 'Candidate search',
    'Справочник основателя': 'Founder handbook',
    'Метрики и терминология': 'Metrics and terminology',
    'Термин не найден.': 'Term not found.',
    'Пример из игры': 'Game example',
    'Где применяется': 'Where it is used',
    'Почему важно': 'Why it matters',
  };

  static const Map<String, String> _enPhrases = <String, String>{
    'День ': 'Day ',
    'На счету': 'Cash balance',
    'Сохранение повреждено': 'Save is corrupted',
    'Не удалось сохранить': 'Could not save',
    'Проект почти стоит': 'The project is nearly stalled',
    'работает только основатель': 'only the founder is working',
    'Перегруз команды': 'Team overload',
    'коммуникации съедают скорость': 'communication overhead reduces speed',
    'Рабочая команда': 'Functional team',
    'до оптимума не хватает людей': 'more people are needed for the optimum',
    'Сбалансированная команда': 'Balanced team',
    'не хватает': 'missing',
    'нужен': 'requires',
    'нужна': 'requires',
    'нужно': 'requires',
    'нет ': 'no ',
    'Выбрано': 'Selected',
    'из допустимых': 'of the allowed',
    'База продукта': 'Product base',
    'Масштаб': 'Scope',
    'Сложность фреймворка': 'Framework complexity',
    'Возможности команды': 'Team capability',
    'Итоговый лимит': 'Final limit',
    'пересчитывается после изменения': 'is recalculated after changing',
    'ежемесячно': 'monthly',
    'в месяц': 'per month',
    'в день': 'per day',
    'дней': 'days',
    'дня': 'days',
    'часов': 'hours',
    'часа': 'hours',
    'минут': 'minutes',
    'Сотрудник': 'Employee',
    'Кандидат': 'Candidate',
    'Удалённо': 'Remote',
    'В офисе': 'On-site',
    'зарплата': 'salary',
    'бонус': 'bonus',
    'команда проекта': 'project team',
    'активный контракт': 'active contract',
    'собственные серверы': 'owned servers',
    'арендованный хостинг': 'rented hosting',
    'вычислительная мощность': 'compute capacity',
    'подготовленная мощность': 'prepared capacity',
    'активная мощность': 'active capacity',
    'пользователей': 'users',
    'пользователя': 'users',
    'выручка': 'revenue',
    'расходы': 'costs',
    'прибыль': 'profit',
    'переговоры с инвестором': 'investor negotiation',
    'ответ инвестора': 'investor response',
    'льготный срок': 'grace period',
    'частичная выплата': 'partial payout',
    'разработка функции': 'feature development',
    'готово': 'complete',
    'заблокирована': 'is blocked',
    'заблокирован': 'is blocked',
    'Подготовьте': 'Prepare',
    'Добавьте': 'Add',
    'Наймите': 'Hire',
    'Купите': 'Buy',
    'Откройте': 'Open',
    'Выберите': 'Select',
  };

  static const Map<String, String> _enWords = <String, String>{
    'компания': 'company',
    'компании': 'company',
    'продукт': 'product',
    'продукта': 'product',
    'продукты': 'products',
    'проект': 'project',
    'проекта': 'project',
    'команда': 'team',
    'команды': 'team',
    'сотрудник': 'employee',
    'сотрудники': 'employees',
    'кандидат': 'candidate',
    'кандидаты': 'candidates',
    'деньги': 'cash',
    'баланс': 'balance',
    'день': 'day',
    'время': 'time',
    'разработка': 'development',
    'инфраструктура': 'infrastructure',
    'сервер': 'server',
    'серверы': 'servers',
    'мощность': 'capacity',
    'нагрузка': 'load',
    'пользователи': 'users',
    'пользователь': 'user',
    'выручка': 'revenue',
    'расходы': 'costs',
    'прибыль': 'profit',
    'цена': 'price',
    'качество': 'quality',
    'надёжность': 'reliability',
    'безопасность': 'security',
    'дизайн': 'design',
    'скорость': 'speed',
    'навык': 'skill',
    'мораль': 'morale',
    'язык': 'language',
    'языки': 'languages',
    'технология': 'technology',
    'технологии': 'technologies',
    'функция': 'feature',
    'функции': 'features',
    'требования': 'requirements',
    'требование': 'requirement',
    'риск': 'risk',
    'риски': 'risks',
    'срок': 'deadline',
    'прогресс': 'progress',
    'доступно': 'available',
    'недоступно': 'unavailable',
    'активно': 'active',
    'завершено': 'completed',
    'ошибка': 'error',
    'сохранение': 'save',
    'настройки': 'settings',
    'поиск': 'search',
    'обзор': 'overview',
    'маркетинг': 'marketing',
    'реклама': 'advertising',
    'метрики': 'metrics',
    'контракт': 'contract',
    'контракты': 'contracts',
    'инвестор': 'investor',
    'инвесторы': 'investors',
    'кредит': 'loan',
    'офис': 'office',
    'удалённо': 'remote',
    'зарплата': 'salary',
    'отпуск': 'vacation',
    'уровень': 'level',
    'оценка': 'valuation',
    'доход': 'income',
    'расход': 'expense',
    'причина': 'reason',
    'решение': 'solution',
    'выбрать': 'select',
    'создать': 'create',
    'запустить': 'launch',
    'нанять': 'hire',
    'купить': 'buy',
    'принять': 'accept',
    'отклонить': 'reject',
  };

  static String translate(String source, Locale locale) =>
      locale.languageCode.toLowerCase() == 'en'
      ? toEnglish(source)
      : toRussian(source);

  static String toRussian(String source) =>
      _cached('ru', source, () => _toRussianUncached(source));

  static String _toRussianUncached(String source) {
    if (!RegExp(r'[A-Za-z]').hasMatch(source)) {
      return source;
    }
    final exact = _ruExact[source];
    if (exact != null) {
      return exact;
    }
    var result = source;
    final phrases = _ruPhrases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    const safeInlineTerms = <String>{
      'cash',
      'workload',
      'morale',
      'payroll',
      'runway',
      'valuation',
      'burn',
      'burn rate',
      'revenue',
      'profit',
      'equity',
      'dilution',
      'onboarding',
      'overstaffing',
    };
    const translateEvenIfApproved = <String>{
      'runway',
      'valuation',
      'burn',
      'burn rate',
      'revenue',
      'profit',
      'equity',
      'dilution',
      'onboarding',
      'overstaffing',
    };
    for (final phrase in phrases) {
      final isMultiWord = phrase.contains(' ') || phrase.contains('-');
      if ((!isMultiWord && !safeInlineTerms.contains(phrase)) ||
          (_isApprovedTerm(phrase) &&
              !translateEvenIfApproved.contains(phrase))) {
        continue;
      }
      result = result.replaceAllMapped(
        RegExp(RegExp.escape(phrase), caseSensitive: false),
        (match) => _preserveLeadingCase(match.group(0)!, _ruPhrases[phrase]!),
      );
    }
    return _preserveLeadingCase(source, result);
  }

  static String toEnglish(String source) =>
      _cached('en', source, () => _toEnglishUncached(source));

  static String _toEnglishUncached(String source) {
    if (!RegExp(r'[А-Яа-яЁё]').hasMatch(source)) {
      return source;
    }
    final glossary = glossaryEnglish[source];
    if (glossary != null) {
      return glossary;
    }
    final exact = _enExact[source];
    if (exact != null) {
      return exact;
    }
    final v12Exact = V12LocalizationLexicon.exact[source];
    if (v12Exact != null) {
      return v12Exact;
    }
    var result = source;
    final v12Phrases = V12LocalizationLexicon.phrases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final phrase in v12Phrases) {
      result = result.replaceAll(
        RegExp(RegExp.escape(phrase), caseSensitive: false),
        V12LocalizationLexicon.phrases[phrase]!,
      );
    }
    final phrases = _enPhrases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final phrase in phrases) {
      result = result.replaceAll(
        RegExp(RegExp.escape(phrase), caseSensitive: false),
        _enPhrases[phrase]!,
      );
    }
    final v12Words = V12LocalizationLexicon.words.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in v12Words) {
      result = result.replaceAllMapped(
        RegExp(
          '(^|[^А-Яа-яЁё])${RegExp.escape(entry.key)}(?=[^А-Яа-яЁё]|\$)',
          caseSensitive: false,
        ),
        (match) => '${match.group(1) ?? ''}${entry.value}',
      );
    }
    final words = _enWords.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in words) {
      result = result.replaceAll(
        RegExp(RegExp.escape(entry.key), caseSensitive: false),
        entry.value,
      );
    }
    return _transliterateRemainingCyrillic(result);
  }

  static String _preserveLeadingCase(String source, String value) {
    if (source.isEmpty || value.isEmpty) {
      return value;
    }

    final sourceFirst = source[0];
    final valueFirst = value[0];

    final sourceStartsUppercase =
        sourceFirst == sourceFirst.toUpperCase() &&
        sourceFirst != sourceFirst.toLowerCase();

    final valueStartsLowercase =
        valueFirst == valueFirst.toLowerCase() &&
        valueFirst != valueFirst.toUpperCase();

    if (!sourceStartsUppercase || !valueStartsLowercase) {
      return value;
    }

    return valueFirst.toUpperCase() + value.substring(1);
  }

  static String _cached(
    String locale,
    String source,
    String Function() compute,
  ) {
    // Dynamic counters and money strings should not evict reusable static copy.
    if (RegExp(r'\d').hasMatch(source) || source.length > 240) {
      return compute();
    }
    final key = '$locale\u001f$source';
    final cached = _translationCache.remove(key);
    if (cached != null) {
      _translationCache[key] = cached;
      return cached;
    }
    final value = compute();
    _translationCache[key] = value;
    if (_translationCache.length > _cacheLimit) {
      _translationCache.remove(_translationCache.keys.first);
    }
    return value;
  }

  static bool _isApprovedTerm(String value) =>
      approvedRussianTerms.contains(value.toLowerCase());

  static String _transliterateRemainingCyrillic(String value) {
    const map = <String, String>{
      'А': 'A',
      'Б': 'B',
      'В': 'V',
      'Г': 'G',
      'Д': 'D',
      'Е': 'E',
      'Ё': 'Yo',
      'Ж': 'Zh',
      'З': 'Z',
      'И': 'I',
      'Й': 'Y',
      'К': 'K',
      'Л': 'L',
      'М': 'M',
      'Н': 'N',
      'О': 'O',
      'П': 'P',
      'Р': 'R',
      'С': 'S',
      'Т': 'T',
      'У': 'U',
      'Ф': 'F',
      'Х': 'Kh',
      'Ц': 'Ts',
      'Ч': 'Ch',
      'Ш': 'Sh',
      'Щ': 'Sch',
      'Ъ': '',
      'Ы': 'Y',
      'Ь': '',
      'Э': 'E',
      'Ю': 'Yu',
      'Я': 'Ya',
      'а': 'a',
      'б': 'b',
      'в': 'v',
      'г': 'g',
      'д': 'd',
      'е': 'e',
      'ё': 'yo',
      'ж': 'zh',
      'з': 'z',
      'и': 'i',
      'й': 'y',
      'к': 'k',
      'л': 'l',
      'м': 'm',
      'н': 'n',
      'о': 'o',
      'п': 'p',
      'р': 'r',
      'с': 's',
      'т': 't',
      'у': 'u',
      'ф': 'f',
      'х': 'kh',
      'ц': 'ts',
      'ч': 'ch',
      'ш': 'sh',
      'щ': 'sch',
      'ъ': '',
      'ы': 'y',
      'ь': '',
      'э': 'e',
      'ю': 'yu',
      'я': 'ya',
    };
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final character = String.fromCharCode(rune);
      buffer.write(map[character] ?? character);
    }
    return buffer.toString();
  }
}

String trContext(BuildContext context, String source) {
  // Registers a Localizations dependency so non-Text properties (tooltips,
  // hints, tabs) rebuild when the selected application locale changes.
  Localizations.maybeLocaleOf(context);
  return tr(source);
}

String tr(String source) {
  final language = DisplayPreferences.instance.language;
  return language == AppLanguage.en
      ? AppLocalizer.toEnglish(source)
      : AppLocalizer.toRussian(source);
}
