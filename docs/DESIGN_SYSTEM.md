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
