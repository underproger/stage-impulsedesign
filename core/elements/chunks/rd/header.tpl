{*
  Редизайн: шапка + мега-меню «Послуги» + мобильное меню.
  Подключается чанком [[$header]] → {include 'file:chunks/rd/header.tpl'}
  Меню строится из дерева ресурсов текущего контекста (web = ru, uk = ua).
  {include 'file:chunks/rd/header.tpl' light=1} — шапка на белом (страница услуги): вверху страницы текст тёмный,
  после прокрутки и с открытым меню — как обычно, светлый на тёмном.
*}
{set $ctx = $_modx->context.key}
{set $isRu = $ctx == 'web'}
{set $start = $_modx->config.site_start}
{set $servicesRoot = $isRu ? 80 : 383}
{set $cur = $_modx->resource.id}
{set $curParent = $_modx->resource.parent}
{set $curGrand = $curParent ? ($curParent | resource : 'parent') : 0}
{set $img = '/assets/templates/rd/img/'}

{set $t = $isRu ? [
  'nav' => 'Главное меню',
  'open' => 'Открыть меню',
  'close' => 'Закрыть меню',
  'brief' => 'Скачать бриф',
  'home' => 'Impulse Design — на главную',
  'lang' => 'Язык сайта'
] : [
  'nav' => 'Головне меню',
  'open' => 'Відкрити меню',
  'close' => 'Закрити меню',
  'brief' => 'Завантажити бриф',
  'home' => 'Impulse Design — на головну',
  'lang' => 'Мова сайту'
]}

{* --- Пункты верхнего уровня (без «Головна») --- *}
{set $top = $_modx->getResources(
  ['parent' => 0, 'context_key' => $ctx, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0, 'id:!=' => $start],
  ['sortby' => 'menuindex', 'sortdir' => 'ASC', 'limit' => 0, 'select' => 'id,pagetitle,menutitle']
)}

{* --- Услуги: группы и их подпункты --- *}
{set $groups = $_modx->getResources(
  ['parent' => $servicesRoot, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0],
  ['sortby' => 'menuindex', 'sortdir' => 'ASC', 'limit' => 0, 'select' => 'id,pagetitle,menutitle']
)}
{set $servicesTitle = $servicesRoot | resource : 'menutitle'}
{if !$servicesTitle}{set $servicesTitle = $servicesRoot | resource : 'pagetitle'}{/if}

{* --- Языки: Ua | Ru --- *}
{set $ukId = $_modx->runSnippet('BabelTranslation', ['contextKey' => 'uk', 'resourceId' => $cur])}
{set $ruId = $_modx->runSnippet('BabelTranslation', ['contextKey' => 'web', 'resourceId' => $cur])}
{set $ukUrl = $_modx->makeUrl(($ukId ?: 382), 'uk', '', 'full')}
{set $ruUrl = $_modx->makeUrl(($ruId ?: 1), 'web', '', 'full')}

{set $phone = ('phone-1' | option)}
{set $phoneHref = $phone | preg_replace : '/[^0-9+]/' : ''}
{set $brief = ('brief' | option)}
{if $brief && !($brief | preg_match : '#^(https?:)?/#')}{set $brief = '/' ~ $brief}{/if}

{set $socials = [
  ['url' => ('facebook' | option), 'icon' => 'soc-facebook.svg', 'label' => 'Facebook'],
  ['url' => ('insta' | option), 'icon' => 'soc-instagram.svg', 'label' => 'Instagram'],
  ['url' => ('youtube' | option), 'icon' => 'soc-youtube.svg', 'label' => 'YouTube'],
  ['url' => ('behance' | option), 'icon' => 'soc-behance.svg', 'label' => 'Behance'],
  ['url' => ('facebook_messenger' | option), 'icon' => 'soc-messenger.svg', 'label' => 'Messenger']
]}

<header class="rd-header{if $light?} rd-header--light{/if}" data-rd-header>
  <span class="rd-header__probe" aria-hidden="true"></span>

  {* ===== Мега-меню (десктоп) ===== *}
  <div class="rd-mega" id="rd-mega" data-rd-mega>
    <div class="rd-container rd-mega__row">
      {foreach $groups as $gi => $g}
        {set $links = $_modx->getResources(
          ['parent' => $g.id, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0],
          ['sortby' => 'menuindex', 'sortdir' => 'ASC', 'limit' => 0, 'select' => 'id,pagetitle,menutitle']
        )}
        <div class="rd-mega__col">
          <div class="rd-mega__head">
            <span class="rd-mega__num">{($gi + 1) | preg_replace : '/^(\d)$/' : '0$1'}</span>
            <a class="rd-mega__title" href="{$g.id | url}">{$g.menutitle ?: $g.pagetitle}</a>
          </div>
          {if $links}
            <ul class="rd-mega__links">
              {foreach $links as $l}
                <li><a class="rd-mega__link{if $l.id == $cur} is-active{/if}" href="{$l.id | url}">{$l.menutitle ?: $l.pagetitle}</a></li>
              {/foreach}
            </ul>
          {/if}
        </div>
      {/foreach}
    </div>
  </div>

  {* ===== Полоса шапки ===== *}
  <div class="rd-container rd-header__bar">
    <a class="rd-header__logo" href="{$_modx->config.site_url}" aria-label="{$t.home}">
      <img src="{$img}logo.svg" width="167" height="27" alt="Impulse Design" loading="eager">
      {if $light?}<img class="rd-header__logo-dark" src="{$img}logo-dark.svg" width="167" height="27" alt="" aria-hidden="true" loading="eager">{/if}
    </a>

    <nav class="rd-nav" aria-label="{$t.nav}">
      <ul class="rd-nav__list">
        {foreach $top as $r}
          {set $isServices = $r.id == $servicesRoot}
          {set $active = ($r.id == $cur || $r.id == $curParent || $r.id == $curGrand)}
          <li class="rd-nav__item{if $isServices} rd-nav__item--mega{/if}{if $active} is-active{/if}"{if $isServices} data-rd-mega-trigger{/if}>
            <a class="rd-nav__link" href="{$r.id | url}"{if $isServices} aria-haspopup="true" aria-expanded="false" aria-controls="rd-mega"{/if}>{$r.menutitle ?: $r.pagetitle}</a>
          </li>
        {/foreach}
      </ul>
      <div class="rd-lang" aria-label="{$t.lang}">
        <a class="rd-lang__item{if !$isRu} is-active{/if}" href="{$ukUrl}" hreflang="uk" lang="uk"{if !$isRu} aria-current="true"{/if}>Ua</a>
        <span class="rd-lang__sep" aria-hidden="true"></span>
        <a class="rd-lang__item{if $isRu} is-active{/if}" href="{$ruUrl}" hreflang="ru" lang="ru"{if $isRu} aria-current="true"{/if}>Ru</a>
      </div>
    </nav>

    {if $phone}
      <a class="rd-header__phone" href="tel:{$phoneHref}">{$phone}</a>
    {/if}

    <button class="rd-burger" type="button" aria-expanded="false" aria-controls="rd-mobile"
            aria-label="{$t.open}" data-label-open="{$t.open}" data-label-close="{$t.close}" data-rd-burger>
      <span></span><span></span>
    </button>
  </div>

  {* ===== Мобильное меню ===== *}
  <div class="rd-mobile" id="rd-mobile" data-rd-mobile>
    <div class="rd-mobile__top">
      {if $phone}<a class="rd-mobile__phone" href="tel:{$phoneHref}">{$phone}</a>{/if}
    </div>

    <div class="rd-mobile__body">
      <nav class="rd-mobile__nav" aria-label="{$t.nav}">
        {foreach $top as $r}
          {if $r.id == $servicesRoot}
            <div class="rd-mobile__services">
              <a class="rd-mobile__heading" href="{$r.id | url}">{$servicesTitle}</a>
              <ul class="rd-mobile__groups">
                {foreach $groups as $gi => $g}
                  {set $links = $_modx->getResources(
                    ['parent' => $g.id, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0],
                    ['sortby' => 'menuindex', 'sortdir' => 'ASC', 'limit' => 0, 'select' => 'id,pagetitle,menutitle']
                  )}
                  {set $groupOpen = ($g.id == $cur || $g.id == $curParent)}
                  {set $gName = $g.menutitle ?: $g.pagetitle}
                  <li class="rd-mobile__group{if $groupOpen} is-open{/if}" data-rd-group>
                    <div class="rd-mobile__group-head">
                      <a class="rd-mobile__group-link{if $g.id == $cur} is-active{/if}" href="{$g.id | url}">{$gName}</a>
                      {if $links}
                        <button class="rd-mobile__toggle" type="button" aria-expanded="{$groupOpen ? 'true' : 'false'}" aria-controls="rd-group-{$g.id}" aria-label="{$gName}">
                          <i class="rd-mobile__toggle-icon" aria-hidden="true"></i>
                        </button>
                      {/if}
                    </div>
                    <div class="rd-mobile__sub" id="rd-group-{$g.id}">
                      <ul>
                        {foreach $links as $l}
                          <li><a class="rd-mobile__sub-link{if $l.id == $cur} is-active{/if}" href="{$l.id | url}">{$l.menutitle ?: $l.pagetitle}</a></li>
                        {/foreach}
                      </ul>
                    </div>
                  </li>
                {/foreach}
              </ul>
            </div>
          {else}
            {set $active = ($r.id == $cur || $r.id == $curParent)}
            <div><a class="rd-mobile__link{if $active} is-active{/if}" href="{$r.id | url}">{$r.menutitle ?: $r.pagetitle}</a></div>
          {/if}
        {/foreach}

        <div class="rd-lang" aria-label="{$t.lang}">
          <a class="rd-lang__item{if !$isRu} is-active{/if}" href="{$ukUrl}" hreflang="uk" lang="uk">Ua</a>
          <span class="rd-lang__sep" aria-hidden="true"></span>
          <a class="rd-lang__item{if $isRu} is-active{/if}" href="{$ruUrl}" hreflang="ru" lang="ru">Ru</a>
        </div>
      </nav>

      {if $brief}
        <a class="rd-btn rd-mobile__brief" href="{$brief}" download>
          {$t.brief}
          <img src="{$img}download-cloud.svg" width="24" height="24" alt="" loading="eager">
        </a>
      {/if}
    </div>

    <div class="rd-mobile__foot">
      <ul class="rd-social">
        {foreach $socials as $s}
          {if $s.url && $s.url != '#'}
            <li><a href="{$s.url}" target="_blank" rel="nofollow noopener" aria-label="{$s.label}" style="--rd-icon: url({$img}{$s.icon})"></a></li>
          {/if}
        {/foreach}
      </ul>
    </div>
  </div>
</header>
