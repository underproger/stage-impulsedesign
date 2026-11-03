{*
  Редизайн: первый экран страницы услуги (шаблон 21 «Услуги - Подкатегория»).
  Тот же блок, что на главной (.rd-hero — вся хореография «вау», подгонка заголовка, прожектор), с модификатором
  .rd-hero--svc: тёмная карточка под светлой шапкой, хлебные крошки, золотой 3D-узел (WebGL, src/knot.js).
  Поля (TV ресурса): title-banner (пусто — longtitle/pagetitle), sub-title-banner (золото — <b>/<strong>/<span>),
  link-left-banner + link_text-left-banner (кнопка), link-right-banner + link_text-right-banner (круглая кнопка).
  Пустые ссылки — как у главной своего контекста (её TV link-left-banner / link-right-banner). ID или URL.
  Таблетка: перед «під ключ» / «под ключ» в конце заголовка, иначе — перед последним словом.
  Вариант страницы копирайтинга (шаблон «Услуги - Копирайтинг») — параметры include:
    nopill=1      — заголовок без таблетки;
    obj='pyramid' — золотая пирамида вместо узла (src/knot.js, data-rd-knot="pyramid"; картинка — pyramid.webp);
    brief=1       — рядом с кнопкой «Завантажити бриф» (файл — системная настройка brief, как в баннере главной).
  и поля (TV): banner_price — строка с ценой под подзаголовком (золото — <b>: «Від <b>120 грн</b> за 1000 символів…»),
    banner_tags — метки через запятую («Українська мова, Російська мова»): первая — золотая, остальные — контуром.
*}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $r = $_modx->resource}
{set $start = $_modx->config.site_start}

{* --- Заголовок --- *}
{set $title = $r['title-banner'] | strip_tags | preg_replace : '/\s+/u' : ' ' | trim}
{if !$title}{set $title = $r.longtitle ?: $r.pagetitle}{/if}
{if $title | preg_match : '/\s(під|под)\s+ключ$/iu'}
  {set $titleHead = $title | preg_replace : '/\s+(під|под)\s+ключ$/iu' : ''}
  {set $titleTail = $title | preg_replace : '/^.*\s((під|под)\s+ключ)$/iu' : '$1'}
{else}
  {set $titleHead = $title | preg_replace : '/\s*\S+$/u' : ''}
  {set $titleTail = $title | preg_replace : '/^.*\s/u' : ''}
{/if}
{* таблетка держится за первое слово хвоста, остальное переносится как обычно *}
{set $tailFirst = $titleTail | preg_replace : '/\s.*$/u' : ''}
{set $tailRest = $titleTail | preg_replace : '/^\S+\s{0,9}/u' : ''}
{set $longest = 0}
{* дефис — тоже место переноса («SEO-копірайтинг»): считаем куски по отдельности *}
{set $words = $title | preg_split : '/[\s\-‐]+|&shy;|\x{00AD}/u'}
{foreach $words as $w}
  {set $len = $w | length}
  {if $len > $longest}{set $longest = $len}{/if}
{/foreach}

{* --- Кнопки: свои ссылки или как у главной --- *}
{set $btnUrl = $r['link-left-banner'] | trim}
{if !$btnUrl || $btnUrl == '#'}{set $btnUrl = $start | resource : 'link-left-banner'}{/if}
{if $btnUrl && ($btnUrl | preg_match : '/^\d+$/')}{set $btnUrl = $btnUrl | url}{/if}
{set $btnText = $r['link_text-left-banner']}
{if !$btnText || $btnText == 'contact us'}{set $btnText = $isRu ? 'Обсудить проект' : 'Обговорити проект'}{/if}

{set $worksUrl = $r['link-right-banner'] | trim}
{if !$worksUrl || $worksUrl == '#'}{set $worksUrl = $start | resource : 'link-right-banner'}{/if}
{if $worksUrl && ($worksUrl | preg_match : '/^\d+$/')}{set $worksUrl = $worksUrl | url}{/if}
{set $worksText = $r['link_text-right-banner']}
{if !$worksText || $worksText == 'portfolio'}{set $worksText = $isRu ? 'Последние работы' : 'Останні роботи'}{/if}
{set $price = $r['banner_price'] | strip_tags : '<b><strong><span><br>' | trim}
{set $tags = ($r['banner_tags'] | strip_tags | trim) ? ($r['banner_tags'] | strip_tags | trim | preg_split : '/\s{0,9}[,;\n]\s{0,9}/u') : []}
{set $briefUrl = ''}
{if $brief?}
  {set $briefUrl = ('brief' | option)}
  {if $briefUrl && !($briefUrl | preg_match : '#^(https?:)?/#')}{set $briefUrl = '/' ~ $briefUrl}{/if}
{/if}
{set $ringLen = $worksText | length}
{set $ringFs = $ringLen > 14 ? (196 / $ringLen) : 14}

{* --- Хлебные крошки: от раздела «Послуги» до текущей страницы (без «Головна», как в макете) --- *}
{set $p1 = $r.parent}
{set $p2 = $p1 ? ($p1 | resource : 'parent') : 0}
{set $p3 = $p2 ? ($p2 | resource : 'parent') : 0}
{set $chain = [$p3, $p2, $p1]}
{set $pos = 0}

<section class="rd-hero rd-hero--svc{if $nopill?} rd-hero--copy{/if}">
  <div class="rd-container rd-hero__inner">
    <div class="rd-hero__content">
      <div class="rd-hero__heading">
        <nav class="rd-crumbs" aria-label="{$isRu ? 'Навигация по разделам' : 'Навігація по розділах'}">
          <ol class="rd-crumbs__list" itemscope itemtype="https://schema.org/BreadcrumbList">
            {foreach $chain as $cid}
              {if $cid}
                {set $pos = $pos + 1}
                <li class="rd-crumbs__item" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
                  <a class="rd-crumbs__link" href="{$cid | url}" itemprop="item"><span itemprop="name">{($cid | resource : 'menutitle') ?: ($cid | resource : 'pagetitle')}</span></a>
                  <meta itemprop="position" content="{$pos}">
                </li>
              {/if}
            {/foreach}
            <li class="rd-crumbs__item rd-crumbs__item--current" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
              <span itemprop="name" aria-current="page">{$r.menutitle ?: $r.pagetitle}</span>
              <meta itemprop="item" content="{$r.id | url : ['scheme' => 'full']}">
              <meta itemprop="position" content="{$pos + 1}">
            </li>
          </ol>
        </nav>

        <h1 class="rd-hero__title" style="--rd-longest: {$longest ?: 10}">
          {if $nopill?}{$title}{else}{if $titleHead}{$titleHead} {/if}<span class="rd-hero__last"><span class="rd-hero__pill" aria-hidden="true"><svg viewBox="0 0 40 40" fill="none"><path d="M14.5 9.5h-1c-1.9 0-3 1.1-3 3v4.2c0 1.7-.8 2.8-2.5 3.3 1.7.5 2.5 1.6 2.5 3.3v4.2c0 1.9 1.1 3 3 3h1"/><path d="M25.5 9.5h1c1.9 0 3 1.1 3 3v4.2c0 1.7.8 2.8 2.5 3.3-1.7.5-2.5 1.6-2.5 3.3v4.2c0 1.9-1.1 3-3 3h-1"/><path class="rd-hero__check" d="m15.6 20.4 3.1 3.1 5.9-6.2" pathLength="1"/></svg></span>{$tailFirst}</span>{if $tailRest} {$tailRest}{/if}{/if}
        </h1>
        {if $r['sub-title-banner']}
          <p class="rd-hero__text">{$r['sub-title-banner'] | strip_tags : '<b><strong><span><br><a>'}</p>
        {/if}
        {if $price}<p class="rd-hero__text rd-hero__price">{$price}</p>{/if}
        {if $tags}
          <ul class="rd-hero__tags">
            {foreach $tags as $i => $tag}{if $tag}<li class="rd-hero__tag{if $i == 0} rd-hero__tag--gold{/if}">{$tag}</li>{/if}{/foreach}
          </ul>
        {/if}
      </div>
      {if $briefUrl}<div class="rd-hero__actions">{/if}
      {if $btnUrl}
        <a class="rd-btn rd-hero__btn" href="{$btnUrl}">
          {$btnText}
          <span class="rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right.svg" width="24" height="24" alt="" loading="eager"><img class="rd-arrow__b" src="{$img}arrow-up-right.svg" width="24" height="24" alt="" loading="eager"></span>
        </a>
      {/if}
      {if $briefUrl}
        <a class="rd-brief rd-dl rd-hero__brief" href="{$briefUrl}" download>
          {include 'file:chunks/rd/icon-download.tpl' id='rd-dl-hero'}
          <span>{$isRu ? 'Скачать бриф' : 'Завантажити бриф'}</span>
        </a>
      </div>
      {/if}
    </div>

    <div class="rd-hero__visual">
      {set $objName = ($obj? && $obj == 'pyramid') ? 'pyramid' : 'knot'}
      <div class="rd-hero__glob rd-hero__glob--{$objName}" data-rd-knot="{$objName == 'pyramid' ? 'pyramid' : ''}" data-src="/assets/templates/rd/js/rd-blob.js?v={$.php.filemtime($.const.MODX_ASSETS_PATH ~ 'templates/rd/js/rd-blob.js')}">
        <picture>
          <source srcset="{$img}{$objName}.webp" type="image/webp">
          <img class="rd-hero__blob" src="{$img}{$objName}.png" width="600" height="600" alt="" fetchpriority="high" loading="eager">
        </picture>
      </div>

      {if $worksUrl}
        <a class="rd-works" href="{$worksUrl}" aria-label="{$worksText}" data-rd-magnet>
          <span class="rd-works__disc"></span>
          <span class="rd-works__fill"></span>
          <svg class="rd-works__ring" viewBox="0 0 160 160" aria-hidden="true">
            <defs>
              <path id="rd-works-path" d="M19 80a61 61 0 1 1 122 0a61 61 0 1 1 -122 0"/>
            </defs>
            <text text-anchor="middle" font-size="{$ringFs}"><textPath href="#rd-works-path" startOffset="25%">{$worksText}</textPath></text>
            <text text-anchor="middle" font-size="{$ringFs}"><textPath href="#rd-works-path" startOffset="75%">{$worksText}</textPath></text>
            <circle cx="145" cy="80" r="2"/>
            <circle cx="15" cy="80" r="2"/>
          </svg>
          <span class="rd-works__arrow rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-narrow-up-right.svg" width="36" height="36" alt="" loading="eager"><img class="rd-arrow__b" src="{$img}arrow-narrow-up-right.svg" width="36" height="36" alt="" loading="eager"></span>
        </a>
      {/if}
    </div>
  </div>
</section>
