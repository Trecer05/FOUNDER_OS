# DESIGN_SYSTEM

## Принципы

- portrait mobile-first;
- светлый off-white фон;
- белые карточки с тонкой границей;
- минимум декоративного шума;
- списки и detail screens вместо единой панели с несвязанными кнопками;
- число всегда подписано единицей: ₽, ₽/мес., ms, %, U, kW, Gbps, compute units;
- продуктовые метрики показываются только в списке/карточке продукта;
- блокировки объясняются рядом с действием.

## Цвета

- Background `#F4F6FB`
- Surface `#FFFFFF`
- Border `#DDE4F0`
- Text `#151A2D`
- Muted `#687089`
- Primary `#4169E1`
- Violet `#7357D9`
- Cyan `#1F9FC2`
- Positive `#258B5B`
- Warning `#B77A14`
- Danger `#C74646`

## Компоненты

- `AppCard` — базовая интерактивная карточка.
- `SectionHeader` — заголовок раздела, объяснение и optional trailing action.
- `MetricCard` — одно число с подписью и контекстом.
- Filter/Choice chips — фильтры каталогов и дискретные экономические решения.
- SegmentedButton — переключение независимых подсистем одного экрана.
- Modal critical event — только необратимые или срочные события.

## Context help v5

- Каждая основная `AppCard` показывает круглую кнопку `i` размером 28×28.
- Ключевые механики получают конкретные title/body/bullets; карточки без специализированного текста используют общий шаблон чтения параметров.
- `MetricCard` не получает второй верхний hint-row: её `i` встроена рядом с названием метрики, чтобы не ломать фиксированную сетку.
- Нажатие на `i` открывает `AlertDialog` и не должно запускать `onTap` родительской карточки.
- Диалог прокручивается и закрывается явной кнопкой «Понятно».
- Tutorial использует пять коротких шагов, progress indicator и кнопки «Пропустить / Назад / Далее / Начать».
- Минимальная цель проверки: iPhone viewport 430×932, default text scale, отсутствие RenderFlex overflow.
<!-- FOUNDER_OS_V9 -->
## v9 responsive additions
- Global time controls: 48–58 pt floating glass surface, safe-area aware, max width 430, no Tooltip dependency.
- Narrow iPhone: controls use fixed compact targets and a fitted day/time label.
- Team averages: compact 3×2 metric grid capped at 148 pt.
- Ecosystem and hosting: stacked cards, wrapping chips and explicit blocker text; no fixed wide rows.
