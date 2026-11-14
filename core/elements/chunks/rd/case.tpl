{*
  Редизайн: страница кейса (шаблон 18 «Внутренняя - Портфолио»), макет case_page_1920.pdf.
  Шапка: крошки (Головна · Портфоліо · кейс), заголовок, подзаголовок, характеристики («таблетка» + значение),
  обложка с кольцом «Дивитися сайт». Дальше — блоки-полосы, отзыв заказчика, «Попередній / Хочу такий же сайт /
  Наступний»; форма и футер — общие (lead.tpl, чанк footer — в шаблоне).
  Поля (TV, категория «Кейс (редизайн)»):
    case_title  — заголовок (пусто — pagetitle);         case_sub — подзаголовок;
    case_meta   — MIGX rd_cards: title — подпись в «таблетке», text — значение;
    case_cover  — обложка (пусто — без обложки и кольца; старое portfolio-banner-img не берём: у старых кейсов
                  там одна заглушка); кольцо ведёт на старое поле portfolio-banner-site_url;
    case_color  — цвет проекта (полосы «Цвет проекта»; пусто — #16202e);
    case_blocks — MIGX rd_case_blocks: bg (white / light / accent), title (<br> — перенос), text (абзацы),
                  image (+ image2 — вторая колонка), flush (картинка до низа полосы, без отступа);
    case_review_text / _name / _role / _photo / _stars — отзыв (пусто — без отзыва).
  Блоки подряд с одним фоном идут одной полосой; два текстовых подряд — через тонкую линию.
  Старый кейс (шаблон 22 — с миграции 37 у него та же разметка, что у 18) без заполненных блоков: выводится его старый
  текст portfolio-content-text (с картинками) одной полосой во всю ширину — <h1> текста становится <h2>, старые «богатые»
  раскладки (portfolio__imgs_5 — коллаж устройств, __img_parallax, __cols_2 «Адаптація під мобільні», __href — ссылка
  на сайт) оформлены заново в _case.scss, анимации старого wow.js в них выключены; характеристики — из старых «Услуга» /
  «Срок» / «Сайт»; скриншоты телефонов (portfolio-content-mobile) — лентой под текстом.
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $home = $_modx->config.site_start}
{set $t = $isRu
  ? ['home' => 'Главная', 'crumbs' => 'Навигация по разделам', 'site' => 'Смотреть сайт', 'review' => 'Отзыв заказчика', 'prev' => 'Предыдущий проект', 'next' => 'Следующий проект', 'want' => 'Хочу такой же сайт']
  : ['home' => 'Головна', 'crumbs' => 'Навігація по розділах', 'site' => 'Дивитися сайт', 'review' => 'Відгук замовника', 'prev' => 'Попередній проект', 'next' => 'Наступний проект', 'want' => 'Хочу такий же сайт']}

{set $title = ($r['case_title'] | strip_tags : '<br>' | trim) ?: $r.pagetitle}
{set $sub = $r['case_sub'] | strip_tags : '<b><strong><br>' | trim}
{set $meta = $r['case_meta'] | json_decode : true}
{if !$meta}
  {set $meta = []}
  {if $r['portfolio-banner-service']}{set $meta[] = ['title' => $isRu ? 'Услуга' : 'Послуга', 'text' => $r['portfolio-banner-service']]}{/if}
  {if $r['portfolio-banner-term']}{set $meta[] = ['title' => $isRu ? 'Срок разработки' : 'Строк розробки', 'text' => $r['portfolio-banner-term']]}{/if}
  {if ($r['portfolio-banner-site'] | trim) && ($r['portfolio-banner-site_url'] | trim)}{set $meta[] = ['title' => 'Сайт', 'text' => $r['portfolio-banner-site'], 'url' => ($r['portfolio-banner-site_url'] | trim)]}{/if}
{/if}
{set $cover = $r['case_cover'] | trim}
{if $cover && !($cover | preg_match : '#^(https?:)?/#')}{set $cover = '/' ~ $cover}{/if}
{set $site = $r['portfolio-banner-site_url'] | trim}
{set $color = $r['case_color'] | trim}
{if !($color | preg_match : '/^#[0-9a-f]{3,8}$/i')}{set $color = '#16202e'}{/if}
{* тёмный цвет проекта — текст на его полосах белый (по яркости цвета) *}
{set $hex = $color | replace : '#' : ''}
{if ($hex | length) < 6}{set $hex = $.php.substr($hex, 0, 1) ~ $.php.substr($hex, 0, 1) ~ $.php.substr($hex, 1, 1) ~ $.php.substr($hex, 1, 1) ~ $.php.substr($hex, 2, 1) ~ $.php.substr($hex, 2, 1)}{/if}
{set $lum = 0.299 * $.php.hexdec($.php.substr($hex, 0, 2)) + 0.587 * $.php.hexdec($.php.substr($hex, 2, 2)) + 0.114 * $.php.hexdec($.php.substr($hex, 4, 2))}
{set $blocks = $r['case_blocks'] | json_decode : true}
{set $ringLen = $t.site | length}
{set $ringFs = $ringLen > 14 ? (196 / $ringLen) : 14}

{* --- соседние кейсы: в порядке страницы «Портфоліо сайтів» (родитель, поле rd_portfolio_list), по кругу;
     если кейса там нет — соседи в разделе по порядку в дереве (menuindex, затем id) --- *}
{set $order = []}
{foreach (($r.parent | resource : 'rd_portfolio_list') | json_decode : true) ?: [] as $it}
  {if ($it.link | preg_match : '/^\d+$/') && !($it.link in $order)}{set $order[] = $it.link}{/if}
{/foreach}
{if !($r.id in $order)}
  {set $order = []}
  {foreach $_modx->getResources(
    ['parent' => $r.parent, 'published' => 1, 'deleted' => 0],
    ['sortby' => ['menuindex' => 'ASC', 'id' => 'ASC'], 'limit' => 0, 'select' => 'id']
  ) as $s}{set $order[] = $s.id}{/foreach}
{/if}
{set $prevId = 0}
{set $nextId = 0}
{set $n = $order | length}
{foreach $order as $k => $oid}
  {if $oid == $r.id && $n > 1}
    {set $prevId = $order[($k + $n - 1) % $n]}
    {set $nextId = $order[($k + 1) % $n]}
  {/if}
{/foreach}

<article class="rd-case-page{if $lum < 150} rd-case-page--dark{/if}" style="--rd-case-accent: {$color}">
  {* ----- шапка ----- *}
  <section class="rd-chead">
    <div class="rd-container">
      <nav class="rd-crumbs rd-crumbs--light rd-chead__crumbs" aria-label="{$t.crumbs}">
        <ol class="rd-crumbs__list" itemscope itemtype="https://schema.org/BreadcrumbList">
          <li class="rd-crumbs__item" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <a class="rd-crumbs__link" href="{$home | url}" itemprop="item"><span itemprop="name">{$t.home}</span></a>
            <meta itemprop="position" content="1">
          </li>
          {if $r.parent}
            <li class="rd-crumbs__item" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
              <a class="rd-crumbs__link" href="{$r.parent | url}" itemprop="item"><span itemprop="name">{($r.parent | resource : 'menutitle') ?: ($r.parent | resource : 'pagetitle')}</span></a>
              <meta itemprop="position" content="2">
            </li>
          {/if}
          <li class="rd-crumbs__item rd-crumbs__item--current" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <span itemprop="name" aria-current="page">{$r.menutitle ?: $r.pagetitle}</span>
            <meta itemprop="item" content="{$r.id | url : ['scheme' => 'full']}">
            <meta itemprop="position" content="{$r.parent ? 3 : 2}">
          </li>
        </ol>
      </nav>
      <h1 class="rd-chead__title" data-rd-fit>{$title}</h1>
      {if $sub}<p class="rd-chead__sub">{$sub}</p>{/if}
      {if $meta}
        <dl class="rd-chead__meta">
          {foreach $meta as $i => $m}
            <div class="rd-chead__fact" style="--i: {$i}">
              <dt class="rd-chead__label">{$m.title | strip_tags}</dt>
              <dd class="rd-chead__value">{if $m.url}<a class="rd-chead__link" href="{$m.url}" target="_blank" rel="noopener">{$m.text | strip_tags}</a>{else}{$m.text | strip_tags : '<br>'}{/if}</dd>
            </div>
          {/foreach}
        </dl>
      {/if}
      {if $cover}
        <div class="rd-chead__cover-wrap">
          <div class="rd-chead__cover">
            <img src="{$cover}" alt="{$r.pagetitle | escape}" width="1500" height="700" loading="eager" fetchpriority="high" decoding="async">
          </div>
          {if $site}
            <a class="rd-works rd-works--case" href="{$site}" target="_blank" rel="noopener" aria-label="{$t.site}" data-rd-magnet>
              <span class="rd-works__disc"></span>
              <span class="rd-works__fill"></span>
              <svg class="rd-works__ring" viewBox="0 0 160 160" aria-hidden="true">
                <defs>
                  <path id="rd-case-ring" d="M19 80a61 61 0 1 1 122 0a61 61 0 1 1 -122 0"/>
                </defs>
                <text text-anchor="middle" font-size="{$ringFs}"><textPath href="#rd-case-ring" startOffset="25%">{$t.site}</textPath></text>
                <text text-anchor="middle" font-size="{$ringFs}"><textPath href="#rd-case-ring" startOffset="75%">{$t.site}</textPath></text>
                <circle cx="145" cy="80" r="2"/>
                <circle cx="15" cy="80" r="2"/>
              </svg>
              <span class="rd-works__arrow rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-narrow-up-right.svg" width="36" height="36" alt="" loading="lazy"><img class="rd-arrow__b" src="{$img}arrow-narrow-up-right.svg" width="36" height="36" alt="" loading="lazy"></span>
            </a>
          {/if}
        </div>
      {/if}
    </div>
  </section>

  {* ----- блоки-полосы ----- *}
  {if $blocks}
    {set $prevBg = ''}
    {set $prevText = 0}
    {foreach $blocks as $i => $b}
      {set $bg = ($b.bg in ['white', 'light', 'accent']) ? $b.bg : 'white'}
      {set $bTitle = $b.title | strip_tags : '<br>' | trim}
      {set $bText = $b.text | strip_tags : '<p><br><b><strong><ul><ol><li><a>' | trim}
      {if $bText && !($bText | preg_match : '~<(p|ul|ol)[\s>]~i')}{set $bText = '<p>' ~ $.php.nl2br($bText) ~ '</p>'}{/if}
      {set $im1 = $b.image | trim}
      {set $im2 = $b.image2 | trim}
      {if $im1 && !($im1 | preg_match : '#^(https?:)?/#')}{set $im1 = '/' ~ $im1}{/if}
      {if $im2 && !($im2 | preg_match : '#^(https?:)?/#')}{set $im2 = '/' ~ $im2}{/if}
      {* размеры картинок — из файлов (ленивая загрузка без прыжков страницы) *}
      {set $f1 = $im1 ? ($.const.MODX_BASE_PATH ~ $.php.ltrim($im1, '/')) : ''}
      {set $f2 = $im2 ? ($.const.MODX_BASE_PATH ~ $.php.ltrim($im2, '/')) : ''}
      {set $sz1 = ($f1 && $.php.is_file($f1)) ? $.php.getimagesize($f1) : []}
      {set $sz2 = ($f2 && $.php.is_file($f2)) ? $.php.getimagesize($f2) : []}
      {set $hasText = $bTitle || $bText}
      {set $cls = 'rd-cblk rd-cblk--' ~ $bg}
      {if $bg == $prevBg}{set $cls = $cls ~ ' rd-cblk--cont'}{/if}
      {if $hasText && !$im1 && !$im2}{set $cls = $cls ~ ' rd-cblk--text'}{/if}
      {if $hasText && !$im1 && !$im2 && $bg == $prevBg && $prevText}{set $cls = $cls ~ ' rd-cblk--rule'}{/if}
      {if $b.flush}{set $cls = $cls ~ ' rd-cblk--flush'}{/if}
      <section class="{$cls}">
        <div class="rd-container rd-cblk__in">
          {if $hasText}
            <div class="rd-cblk__head">
              {if $bTitle}<h2 class="rd-cblk__title">{$bTitle}</h2>{/if}
              {if $bText}<div class="rd-cblk__text">{$bText}</div>{/if}
            </div>
          {/if}
          {if $im1 || $im2}
            <div class="rd-cblk__media{if $im1 && $im2} rd-cblk__media--two{/if}">
              {if $im1}<img src="{$im1}"{if $sz1} width="{$sz1[0]}" height="{$sz1[1]}"{/if} alt="{$bTitle ? ($bTitle | strip_tags | escape) : ($r.pagetitle | escape)}" loading="lazy" decoding="async">{/if}
              {if $im2}<img src="{$im2}"{if $sz2} width="{$sz2[0]}" height="{$sz2[1]}"{/if} alt="{$bTitle ? ($bTitle | strip_tags | escape) : ($r.pagetitle | escape)}" loading="lazy" decoding="async">{/if}
            </div>
          {/if}
        </div>
      </section>
      {set $prevBg = $bg}
      {set $prevText = $hasText && !$im1 && !$im2}
    {/foreach}
  {/if}

  {* старый кейс без новых блоков — его прежний текст с картинками: <h1> → <h2> (h1 страницы — заголовок выше),
     подпись-ссылка блока portfolio__href (домен сайта) становится ссылкой на сайт.
     В регулярках латинская «e» — как \x65: проверка pdoTools на модификатор eval ложно срабатывает на ней *}
  {if !$blocks && ($r['portfolio-content-text'] | trim)}
    {set $legacy = $r['portfolio-content-text'] | replace : '<strong>' : '<b>' | replace : '</strong>' : '</b>' | preg_replace : '~<(/?)h1\b~i' : '<$1h2'}
    {if $site}
      {set $legacy = $legacy | preg_replace : '~<div class="portfolio__hr\x65f_link">(.*?)</div>~su' : ('<a class="portfolio__href_link" href="' ~ ($site | escape) ~ '" target="_blank" rel="noopener">$1</a>')}
    {/if}
    <section class="rd-cblk rd-cblk--white rd-cblk--legacy">
      <div class="rd-container"><div class="rd-cblk__legacy">{$legacy}</div></div>
    </section>
  {/if}
  {* скриншоты телефонов старого кейса (MIGX portfolio-content-mobile) — лентой в рамках телефонов *}
  {set $mob = !$blocks ? ($r['portfolio-content-mobile'] | json_decode : true) : []}
  {if $mob}
    <section class="rd-cblk rd-cblk--light rd-cmob">
      <div class="rd-container">
        <ul class="rd-cmob__list" data-rd-no-smooth>
          {foreach $mob as $mi}
            {set $mImg = $mi.image | trim}
            {if $mImg}
              {if !($mImg | preg_match : '#^(https?:)?/#')}{set $mImg = '/' ~ $mImg}{/if}
              <li class="rd-cmob__phone"><img src="{$mImg}" alt="{$r.pagetitle | escape}" loading="lazy" decoding="async"></li>
            {/if}
          {/foreach}
        </ul>
      </div>
    </section>
  {/if}

  {* ----- отзыв и навигация ----- *}
  {set $rvText = $r['case_review_text'] | strip_tags : '<b><strong><br>' | trim}
  {set $rvPhoto = $r['case_review_photo'] | trim}
  {if $rvPhoto && !($rvPhoto | preg_match : '#^(https?:)?/#')}{set $rvPhoto = '/' ~ $rvPhoto}{/if}
  {set $stars = ($r['case_review_stars'] | trim) ?: 5}
  <section class="rd-cend">
    <div class="rd-container">
      {if $rvText}
        <figure class="rd-crev">
          <h2 class="rd-crev__title">{$t.review}</h2>
          <div class="rd-crev__body">
            <figcaption class="rd-crev__who">
              {if $rvPhoto}<img class="rd-crev__photo" src="{$rvPhoto}" alt="{$r['case_review_name'] | escape}" width="172" height="100" loading="lazy">{/if}
              <span class="rd-crev__person">
                {if $r['case_review_name']}<span class="rd-crev__name">{$r['case_review_name'] | strip_tags}</span>{/if}
                {if $r['case_review_role']}<span class="rd-crev__role">{$r['case_review_role'] | strip_tags}</span>{/if}
              </span>
              <span class="rd-crev__stars" role="img" aria-label="{$stars} / 5">
                {for $s=1 to=5}<svg class="rd-crev__star{if $s > $stars} rd-crev__star--off{/if}" viewBox="0 0 24 24" aria-hidden="true" style="--s: {$s}"><path d="M12 2.2l2.95 6.6 7.2.66-5.45 4.78 1.63 7.06L12 17.6 5.67 21.3l1.63-7.06L1.85 9.46l7.2-.66z"/></svg>{/for}
              </span>
            </figcaption>
            <blockquote class="rd-crev__text">“{$rvText | preg_replace : '~^[“"«]+|[”"»]+$~u' : ''}”</blockquote>
          </div>
        </figure>
      {/if}
      <nav class="rd-cnav" aria-label="{$t.crumbs}">
        {if $prevId}
          <a class="rd-cnav__link rd-cnav__link--prev" href="{$prevId | url}" rel="prev">
            <span class="rd-cnav__arrow" aria-hidden="true"><svg viewBox="0 0 18 18" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M15 9H3m0 0 5-5M3 9l5 5"/></svg></span>
            <span>{$t.prev}</span>
          </a>
        {else}<span></span>{/if}
        <a class="rd-cnav__want" href="#order-form">{$t.want}</a>
        {if $nextId}
          <a class="rd-cnav__link rd-cnav__link--next" href="{$nextId | url}" rel="next">
            <span>{$t.next}</span>
            <span class="rd-cnav__arrow" aria-hidden="true"><svg viewBox="0 0 18 18" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9h12m0 0-5-5m5 5-5 5"/></svg></span>
          </a>
        {else}<span></span>{/if}
      </nav>
    </div>
  </section>
</article>
