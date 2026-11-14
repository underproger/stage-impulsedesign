{*
  Редизайн: страница «Послуги студії» (шаблон 19 «Услуги - Список услуг»; UA 383 /ua/poslugy.html, RU 80 /services.html).
  Макета нет — собрана из языка сайта: шапка как у «Портфоліо сайтів», разделы — тёмные карточки с сеткой и золотым
  3D-объектом (WebGL той же серии, что на главной и страницах услуг: узел, икосаэдр, пирамида, спираль — по кругу;
  картинка — заглушка), под каждой — плитки услуг.
  Данные — дерево: разделы — дочерние ресурсы страницы (шаблон 20), услуги — их дочерние; как и раньше, только
  опубликованные и видимые в меню (hidemenu = 0), по порядку в дереве.
  Поля страницы (TV): svcl_title — заголовок (золото — <span>; пусто — pagetitle), svcl_quote — подводка справа.
  Поля раздела: services-category-title / -subtitle / -text (жирный — золотом).
  Поля услуги: название — menutitle (как в меню и футере; пусто — services-subcategory-title), коротко —
  services-subcategory-text, цена — services-subcategory-price («<span>ціна від </span>$600»:
  подпись в <span> заменяется на «від / от» языка страницы, остальное — сумма).
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $home = $_modx->config.site_start}
{set $t = $isRu
  ? ['home' => 'Главная', 'crumbs' => 'Навигация по разделам', 'from' => 'от', 'all' => 'Все услуги раздела', 'n1' => 'услуга', 'n2' => 'услуги', 'n5' => 'услуг', 'sections' => 'Разделы услуг']
  : ['home' => 'Головна', 'crumbs' => 'Навігація по розділах', 'from' => 'від', 'all' => 'Усі послуги розділу', 'n1' => 'послуга', 'n2' => 'послуги', 'n5' => 'послуг', 'sections' => 'Розділи послуг']}
{set $title = $r['svcl_title'] | strip_tags : '<span><br>' | trim}
{if !$title}{set $title = $r.pagetitle}{/if}
{set $quote = $r['svcl_quote'] | strip_tags : '<span><b><br>' | trim}
{set $objs = ['knot', 'ico', 'pyramid', 'spiral']}
{set $blob = '/assets/templates/rd/js/rd-blob.js?v=' ~ $.php.filemtime($.const.MODX_ASSETS_PATH ~ 'templates/rd/js/rd-blob.js')}

{set $cats = $_modx->getResources(
  ['parent' => $r.id, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0],
  ['sortby' => ['menuindex' => 'ASC', 'id' => 'ASC'], 'limit' => 0, 'select' => 'id,pagetitle,menutitle,alias',
   'includeTVs' => 'services-category-title,services-category-subtitle,services-category-text', 'tvPrefix' => '']
)}

<div class="rd-svcl">
  {* ----- шапка ----- *}
  <section class="rd-svcl__top">
    <div class="rd-container">
      <div class="rd-svcl__head">
        <nav class="rd-crumbs rd-crumbs--light rd-svcl__crumbs" aria-label="{$t.crumbs}">
          <ol class="rd-crumbs__list" itemscope itemtype="https://schema.org/BreadcrumbList">
            <li class="rd-crumbs__item" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
              <a class="rd-crumbs__link" href="{$home | url}" itemprop="item"><span itemprop="name">{$t.home}</span></a>
              <meta itemprop="position" content="1">
            </li>
            <li class="rd-crumbs__item rd-crumbs__item--current" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
              <span itemprop="name" aria-current="page">{$r.menutitle ?: $r.pagetitle}</span>
              <meta itemprop="item" content="{$r.id | url : ['scheme' => 'full']}">
              <meta itemprop="position" content="2">
            </li>
          </ol>
        </nav>
        <h1 class="rd-svcl__title" data-rd-fit>{$title}</h1>
        {if $quote}<p class="rd-svcl__quote">{$quote}</p>{/if}
      </div>

      {if $cats}
        <nav class="rd-svcl__tabs" aria-label="{$t.sections}">
          {foreach $cats as $ci => $c}
            {set $cnt = $_modx->getResources(['parent' => $c.id, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0], ['limit' => 0, 'select' => 'id']) | length}
            <a class="rd-svcl__tab" href="{$r.id | url}#{$c.alias}" data-rd-svcl-tab="{$c.alias}" style="--i: {$ci}">
              <span>{$c['services-category-title'] ?: ($c.menutitle ?: $c.pagetitle)}</span>
              <sup class="rd-svcl__tab-n">{$cnt}</sup>
            </a>
          {/foreach}
        </nav>
      {/if}
    </div>
  </section>

  {* ----- разделы ----- *}
  {foreach $cats as $ci => $c}
    {set $items = $_modx->getResources(
      ['parent' => $c.id, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0],
      ['sortby' => ['menuindex' => 'ASC', 'id' => 'ASC'], 'limit' => 0, 'select' => 'id,pagetitle,menutitle',
       'includeTVs' => 'services-subcategory-title,services-subcategory-text,services-subcategory-price', 'tvPrefix' => '']
    )}
    {set $n = $items | length}
    {set $nWord = ($n % 10 == 1 && $n % 100 != 11) ? $t.n1 : (($n % 10 >= 2 && $n % 10 <= 4 && ($n % 100 < 10 || $n % 100 >= 20)) ? $t.n2 : $t.n5)}
    {set $cTitle = $c['services-category-title'] ?: ($c.menutitle ?: $c.pagetitle)}
    {set $obj = $objs[$ci % 4]}
    <section class="rd-svcl__cat{if $ci % 2} rd-svcl__cat--flip{/if}" id="{$c.alias}">
      <div class="rd-container">
        <div class="rd-svcl__card" data-rd-svcl-card>
          <div class="rd-svcl__info">
            <p class="rd-svcl__meta"><span class="rd-svcl__num">{$ci < 9 ? ('0' ~ ($ci + 1)) : ($ci + 1)}</span><span class="rd-svcl__count">{$n} {$nWord}</span></p>
            <h2 class="rd-svcl__name">{$cTitle}</h2>
            {if $c['services-category-subtitle']}<p class="rd-svcl__sub">{$c['services-category-subtitle'] | strip_tags}</p>{/if}
            {if $c['services-category-text']}<p class="rd-svcl__text">{$c['services-category-text'] | strip_tags : '<b><strong><br>'}</p>{/if}
            <a class="rd-btn rd-svcl__btn" href="{$c.id | url}">
              {$t.all}
              <span class="rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right.svg" width="24" height="24" alt="" loading="lazy"><img class="rd-arrow__b" src="{$img}arrow-up-right.svg" width="24" height="24" alt="" loading="lazy"></span>
            </a>
          </div>
          {* 3D (rd-blob.js, грузит rd.js по data-src первого 3D-блока): узел и пирамида — knot.js на .rd-svcl__float,
             икосаэдр — ico.js, спираль — spiral.js на .rd-svcl__obj; картинка — заглушка до первого кадра,
             без WebGL и при reduced motion *}
          {if $obj == 'knot' || $obj == 'pyramid'}
            <div class="rd-svcl__obj rd-svcl__obj--{$obj}" aria-hidden="true">
              <div class="rd-svcl__float" data-rd-knot="{$obj == 'pyramid' ? 'pyramid' : ''}" data-src="{$blob}">
                <img src="{$img}{$obj}.webp" width="600" height="600" alt="" loading="lazy" decoding="async">
              </div>
            </div>
          {else}
            <div class="rd-svcl__obj rd-svcl__obj--{$obj}" {$obj == 'ico' ? 'data-rd-ico' : 'data-rd-3d'} data-src="{$blob}" aria-hidden="true">
              <div class="rd-svcl__float">
                <img src="{$img}{$obj}.webp" width="600" height="600" alt="" loading="lazy" decoding="async">
              </div>
            </div>
          {/if}
        </div>

        {if $items}
          <ul class="rd-svcl__list">
            {foreach $items as $i => $s}
              {set $sTitle = $s.menutitle ?: ($s['services-subcategory-title'] | strip_tags | trim) ?: $s.pagetitle}
              {set $price = $s['services-subcategory-price'] | preg_replace : '~^\s{0,9}<span[^>]*>[^<]*</span>\s{0,9}~u' : '' | strip_tags : '<span>' | trim}
              <li class="rd-svct" style="--i: {$i}">
                <a class="rd-svct__link" href="{$s.id | url}">
                  <span class="rd-svct__top">
                    <span class="rd-svct__name">{$sTitle}</span>
                    <span class="rd-svct__arrow rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right-dark.svg" width="24" height="24" alt="" loading="lazy"><img class="rd-arrow__b" src="{$img}arrow-up-right-dark.svg" width="24" height="24" alt="" loading="lazy"></span>
                  </span>
                  {if $s['services-subcategory-text']}<span class="rd-svct__text">{$s['services-subcategory-text'] | strip_tags | trim}</span>{/if}
                  {if $price}<span class="rd-svct__price"><span class="rd-svct__from">{$t.from}</span> <span class="rd-svct__val">{$price}</span></span>{/if}
                </a>
              </li>
            {/foreach}
          </ul>
        {/if}
      </div>
    </section>
  {/foreach}
</div>
