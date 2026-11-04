{*
  Редизайн: первый экран главной.
  Фон: почти чёрный, редкие линии «рамки» с золотыми крестиками на пересечениях (.rd-hero__frame, только десктоп),
  тёмная каменная «планета» с тёплым отсветом под объектом (картинка hero-planet.webp, снята с шейдера).
  Объект — жидкое золото с орбитой и двумя шариками (WebGL, src/liquid.js); заглушка — hero-liquid.webp/png.
  Поля (TV ресурса): title-banner, sub-title-banner,
  link-left-banner + link_text-left-banner (кнопка), link-right-banner + link_text-right-banner (круглая кнопка).
  В полях-ссылках можно указать ID ресурса или URL.
*}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $r = $_modx->resource}

{* Заголовок: последнее слово идёт вместе с золотой «таблеткой» *}
{* мягкие переносы (&shy;) убираем: заголовок набран узким начертанием, длинное слово помещается целиком *}
{set $title = $r['title-banner'] | strip_tags | replace : '&shy;' : '' | preg_replace : '/\x{00AD}/u' : '' | preg_replace : '/\s+/u' : ' ' | trim}
{if !$title}{set $title = $r.longtitle ?: $r.pagetitle}{/if}
{set $titleHead = $title | preg_replace : '/\s*\S+$/u' : ''}
{set $titleLast = $title | preg_replace : '/^.*\s/u' : ''}
{* Длина самого длинного слова — по ней кегль (CSS: ширина колонки / (длина · 0.55em)) *}
{set $longest = 0}
{set $words = $title | preg_split : '/\s+/u'}
{foreach $words as $w}
  {set $len = $w | length}
  {if $len > $longest}{set $longest = $len}{/if}
{/foreach}

{set $btnUrl = $r['link-left-banner']}
{if $btnUrl && ($btnUrl | preg_match : '/^\d+$/')}{set $btnUrl = $btnUrl | url}{/if}
{set $btnText = $r['link_text-left-banner']}
{if !$btnText || $btnText == 'contact us'}{set $btnText = $isRu ? 'Обсудить проект' : 'Обговорити проект'}{/if}

{set $worksUrl = $r['link-right-banner']}
{if $worksUrl && ($worksUrl | preg_match : '/^\d+$/')}{set $worksUrl = $worksUrl | url}{/if}
{set $worksText = $r['link_text-right-banner']}
{if !$worksText || $worksText == 'portfolio'}{set $worksText = $isRu ? 'Последние работы' : 'Останні роботи'}{/if}

{* размер надписи на круге: 14px, но меньше для длинного текста (полкруга ≈ 175px) *}
{set $ringLen = $worksText | length}
{set $ringFs = $ringLen > 14 ? (196 / $ringLen) : 14}

{set $brief = ('brief' | option)}
{if $brief && !($brief | preg_match : '#^(https?:)?/#')}{set $brief = '/' ~ $brief}{/if}

{set $socials = [
  ['url' => ('facebook' | option), 'icon' => 'soc-facebook.svg', 'label' => 'Facebook'],
  ['url' => ('insta' | option), 'icon' => 'soc-instagram.svg', 'label' => 'Instagram'],
  ['url' => ('youtube' | option), 'icon' => 'soc-youtube.svg', 'label' => 'YouTube'],
  ['url' => ('behance' | option), 'icon' => 'soc-behance.svg', 'label' => 'Behance'],
  ['url' => ('facebook_messenger' | option), 'icon' => 'soc-messenger.svg', 'label' => 'Messenger']
]}

<section class="rd-hero rd-hero--main">
  <div class="rd-hero__frame" aria-hidden="true">
    <div class="rd-hero__frame-box">
      <span class="rd-hero__fl rd-hero__fl--l"></span>
      <span class="rd-hero__fl rd-hero__fl--m"></span>
      <span class="rd-hero__fl rd-hero__fl--r"></span>
      <span class="rd-hero__fl rd-hero__fl--t"></span>
      <span class="rd-hero__fl rd-hero__fl--b"></span>
      <span class="rd-hero__cross rd-hero__cross--t"></span>
      <span class="rd-hero__cross rd-hero__cross--b"></span>
    </div>
  </div>
  {include 'file:chunks/rd/header.tpl'}

  <div class="rd-container rd-hero__inner">
    <div class="rd-hero__content">
      <div class="rd-hero__heading">
        <h1 class="rd-hero__title" style="--rd-longest: {$longest ?: 10}">
          {if $titleHead}{$titleHead} {/if}<span class="rd-hero__last"><span class="rd-hero__pill" aria-hidden="true"><svg viewBox="0 0 40 40" fill="none"><path class="rd-hero__caret" d="M23.334 5 16.667 35"/><path d="M11.873 11.647 3.308 19.919l8.468 8.468"/><path d="m28.321 11.679 8.759 8.37-8.662 8.564"/></svg></span>{$titleLast}</span>
        </h1>
        {if $r['sub-title-banner']}
          <p class="rd-hero__text">{$r['sub-title-banner'] | strip_tags : '<b><strong><br><a>'}</p>
        {/if}
      </div>
      {if $btnUrl}
        <a class="rd-btn rd-hero__btn" href="{$btnUrl}">
          {$btnText}
          <span class="rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right.svg" width="24" height="24" alt="" loading="eager"><img class="rd-arrow__b" src="{$img}arrow-up-right.svg" width="24" height="24" alt="" loading="eager"></span>
        </a>
      {/if}
    </div>

    <div class="rd-hero__visual">
      <div class="rd-hero__glob" data-rd-glob data-src="/assets/templates/rd/js/rd-blob.js?v={$.php.filemtime($.const.MODX_ASSETS_PATH ~ 'templates/rd/js/rd-blob.js')}">
        <img class="rd-hero__planet" src="{$img}hero-planet.webp?v={$.php.filemtime($.const.MODX_ASSETS_PATH ~ 'templates/rd/img/hero-planet.webp')}" width="1710" height="450" alt="" loading="eager" decoding="async">
        <span class="rd-hero__halo"></span>
        <picture>
          <source srcset="{$img}hero-liquid.webp" type="image/webp">
          <img class="rd-hero__blob" src="{$img}hero-liquid.png" width="900" height="900" alt="" fetchpriority="high" loading="eager">
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

    <div class="rd-hero__bottom">
      <ul class="rd-social">
        {foreach $socials as $s}
          {if $s.url && $s.url != '#'}
            <li><a href="{$s.url}" target="_blank" rel="nofollow noopener" aria-label="{$s.label}" style="--rd-icon: url({$img}{$s.icon})"></a></li>
          {/if}
        {/foreach}
      </ul>
      {if $brief}
        <a class="rd-brief rd-dl" href="{$brief}" download>
          {include 'file:chunks/rd/icon-download.tpl' id='rd-dl-hero'}
          <span>{$isRu ? 'Скачать бриф' : 'Завантажити бриф'}</span>
        </a>
      {/if}
    </div>
  </div>
</section>
