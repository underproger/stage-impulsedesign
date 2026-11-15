{*
  Стили старого дизайна (reset, fonts, media, animate, style + Swiper с unpkg). Подключается из чанка head (миграция 39)
  вместо прежних <link>. Нужны только старым шаблонам (3, 7, 8, 13, 14 — опубликованных страниц на них нет).
  На страницах редизайна всё оформление — rd.css: нужные редизайну старые правила (reset, Gotham Pro, формы статей,
  старые кейсы и т.п. — 115 правил) перенесены в scss/_legacy.css, вычисленные стили страниц не изменились (сверено
  на образцах всех шаблонов, 1920 и 360). Сами файлы (~110 КБ) блокировали первую отрисовку (PageSpeed: «Ресурсы,
  блокирующие отрисовку»), а Swiper без версии с unpkg — это ещё и переадресация на стороннем сервере.
*}
{set $legacyTpl = [3, 7, 8, 13, 14]}
{if ($_modx->resource.template | int) in list $legacyTpl}
    <link rel="stylesheet" href="https://unpkg.com/swiper/swiper-bundle.min.css" />
    <link rel="stylesheet" href="/assets/templates/css/reset.css"/>
    <link rel="stylesheet" href="/assets/templates/css/fonts.css"/>
    <link rel="stylesheet" href="/assets/templates/css/media.css"/>
    <link rel="stylesheet" href="/assets/templates/css/animate.css"/>
    <link rel="stylesheet" href="/assets/templates/css/style.css?ver=1.0.4"/>
{/if}
