{*
  Редизайн: блок «Digital агентство Impulse Design» — section 6 макета.
  Поля (TV, категория «Блок 6 - Digital агентство»):
    display_bl_about   — показывать блок
    about_title        — заголовок (золотое слово оберните в <span>)
    about_text         — подзаголовок (золотой акцент — <b>)
    about_img          — объект слева (PNG/WebP с прозрачным фоном, квадрат; пусто — золотая 3D-спираль на WebGL,
                         картинка spiral.webp — её заглушка до загрузки и без WebGL)
    about_stats        — MIGX «rd_about_stats»: value (число), prefix («топ»), suffix («+», «років»), text
    about_people       — MIGX «rd_about_people»: image (фото, квадрат), name (подпись для alt)
    about_people_text  — подпись рядом с фото (перенос строки — <br>)
    about_quote        — цитата (золотые фрагменты — в <span>)
    about_more_link    — «Дізнатися більше»: ID ресурса или URL (пусто — «Про нас»)
    about_more_text    — текст ссылки
    about_card_value   — «20%» в золотой «таблетке»
    about_card_note    — подпись рядом («проти минулого місяця*»)
    about_card_text    — текст на тёмной карточке (золото — <span>, жирный — <b>)
    about_cta_link / about_cta_text — круглая кнопка (пусто — как в блоке гарантий / первом экране)
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $stats = $r['about_stats'] | json_decode : true}
{set $people = $r['about_people'] | json_decode : true}

{set $obj = $r['about_img'] ?: 'assets/templates/rd/img/spiral.webp'}
{if !($obj | preg_match : '~^(https?:)?/~')}{set $obj = '/' ~ $obj}{/if}

{set $moreUrl = $r['about_more_link'] ?: ($isRu ? 102 : 449)}
{if $moreUrl | preg_match : '/^\d+$/'}{set $moreUrl = $moreUrl | url}{/if}
{set $moreText = $r['about_more_text'] ?: ($isRu ? 'Узнать больше' : 'Дізнатися більше')}

{set $ctaUrl = $r['about_cta_link'] ?: ($r['guaranty_link_bl7'] ?: $r['link-left-banner'])}
{if $ctaUrl && ($ctaUrl | preg_match : '/^\d+$/')}{set $ctaUrl = $ctaUrl | url}{/if}
{set $ctaText = $r['about_cta_text'] ?: ($r['guaranty_link_text_bl7'] ?: ($isRu ? 'Обсудить проект' : 'Обговорити проект'))}
{set $ringLen = $ctaText | length}
{set $ringFs = $ringLen > 14 ? (196 / $ringLen) : 14}

{* кривая графика (снята с макета), область под ней — та же кривая, замкнутая вниз *}
{set $curve = 'M0 150C4 147.7 16 142.5 24 136C32 129.5 40 119.1 48 111C56 102.9 64 93.1 72 87.2C80 81.3 88 77.3 96 75.5C104 73.7 112 73.9 120 76.2C128 78.5 136 84.5 144 89.5C152 94.5 160 102.2 168 106.2C176 110.2 184 113.6 192 113.5C200 113.4 208 112 216 105.5C224 99 232 87.4 240 74.5C248 61.6 256 40.1 264 28.2C272 16.3 281.7 8 288 3.2C294.3 1 299.7 0.3 302 0'}

{if $r['about_title']}
<section class="rd-about" id="about">
  <div class="rd-container rd-about__wrap">
    <div class="rd-about__head">
      <div class="rd-about__obj" aria-hidden="true"{if !$r['about_img']} data-rd-3d data-src="/assets/templates/rd/js/rd-blob.js?v={$.php.filemtime($.const.MODX_ASSETS_PATH ~ 'templates/rd/js/rd-blob.js')}"{/if}>
        <span class="rd-about__float"><img class="rd-about__spiral" src="{$obj}" width="600" height="600" alt="" draggable="false"></span>
      </div>
      <div class="rd-about__intro">
        <h2 class="rd-about__title">{$r['about_title'] | strip_tags : '<span><br>'}</h2>
        {if $r['about_text']}
          <p class="rd-about__text">{$r['about_text'] | strip_tags : '<b><strong><br><a><span>'}</p>
        {/if}
      </div>
    </div>

    {if $stats}
      <div class="rd-about__plate">
        <span class="rd-about__glow" aria-hidden="true"></span>
        {foreach $stats as $i => $s}
          {set $suf = $s.suffix | strip_tags}
          <div class="rd-stat" style="--i: {$i}">
            <p class="rd-stat__num">
              {if $s.prefix}<span class="rd-stat__pre">{$s.prefix | strip_tags}</span>{/if}
              {set $val = $s.value | strip_tags}<span class="rd-stat__val{if $val | preg_match : '/^1/'} rd-stat__val--one{/if}">{$val}</span>
              {if $suf}<span class="rd-stat__suf{if ($suf | length) < 2} rd-stat__suf--sign{/if}">{$suf}</span>{/if}
            </p>
            {if $s.text}<p class="rd-stat__text">{$s.text | strip_tags : '<br>'}</p>{/if}
          </div>
        {/foreach}
      </div>
    {/if}

    <div class="rd-about__bottom">
      <div class="rd-about__say">
        {if $people || $r['about_people_text']}
          {* --n — сколько фото после первого: на наведении фото расходятся, подпись отъезжает на столько же *}
          <div class="rd-about__people" style="--n: {$people ? (($people | length) - 1) : 0}">
            {if $people}
              <span class="rd-about__faces">
                {foreach $people as $i => $p}
                  {set $ps = $p.image}
                  {if $ps && !($ps | preg_match : '~^(https?:)?/~')}{set $ps = '/' ~ $ps}{/if}
                  {if $ps}<img class="rd-about__face" src="{$ps}" width="54" height="54" alt="{$p.name | strip_tags | escape}" style="--i: {$i}" draggable="false">{/if}
                {/foreach}
              </span>
            {/if}
            {if $r['about_people_text']}<span class="rd-about__people-text">{$r['about_people_text'] | strip_tags : '<br>'}</span>{/if}
          </div>
        {/if}
        {if $r['about_quote']}
          <blockquote class="rd-about__quote"><p>{$r['about_quote'] | strip_tags : '<span><b><strong><br>'}</p></blockquote>
        {/if}
        <a class="rd-about__more" href="{$moreUrl}">
          <span class="rd-about__more-text">{$moreText}</span>
          <span class="rd-arrow"><img class="rd-arrow__a" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt=""></span>
        </a>
      </div>

      <div class="rd-about__card">
        <div class="rd-about__row">
          {if $r['about_card_value']}
            <div class="rd-about__growth">
              <span class="rd-about__pill">
                <span class="rd-about__pill-back" aria-hidden="true"></span>
                <span class="rd-about__pill-mid" aria-hidden="true"></span>
                <span class="rd-about__pill-front">
                  <svg class="rd-about__up" width="27" height="27" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20V4M5 11l7-7 7 7"/></svg>
                  <span class="rd-about__pct">{$r['about_card_value'] | strip_tags}</span>
                </span>
              </span>
              {if $r['about_card_note']}<span class="rd-about__note">{$r['about_card_note'] | strip_tags : '<br>'}</span>{/if}
            </div>
          {/if}
          <svg class="rd-about__chart" viewBox="0 0 302 151" preserveAspectRatio="none" aria-hidden="true">
            <defs>
              <linearGradient id="rd-about-area" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#bfa660" stop-opacity="0.5"/>
                <stop offset="1" stop-color="#bfa660" stop-opacity="0.05"/>
              </linearGradient>
            </defs>
            <path class="rd-about__area" d="{$curve}L302 151L0 151Z" fill="url(#rd-about-area)"/>
            <path class="rd-about__line" d="{$curve}" pathLength="1" vector-effect="non-scaling-stroke"/>
          </svg>
        </div>
        {if $r['about_card_text']}
          <p class="rd-about__card-text">{$r['about_card_text'] | strip_tags : '<span><b><strong><br>'}</p>
        {/if}
        {if $ctaUrl}
          <a class="rd-works rd-works--inline rd-about__cta" href="{$ctaUrl}" aria-label="{$ctaText}" data-rd-magnet>
            <span class="rd-works__disc"></span>
            <span class="rd-works__fill"></span>
            <svg class="rd-works__ring" viewBox="0 0 160 160" aria-hidden="true">
              <defs>
                <path id="rd-about-path" d="M19 80a61 61 0 1 1 122 0a61 61 0 1 1 -122 0"/>
              </defs>
              <text text-anchor="middle" font-size="{$ringFs}"><textPath href="#rd-about-path" startOffset="25%">{$ctaText}</textPath></text>
              <text text-anchor="middle" font-size="{$ringFs}"><textPath href="#rd-about-path" startOffset="75%">{$ctaText}</textPath></text>
              <circle cx="145" cy="80" r="2"/>
              <circle cx="15" cy="80" r="2"/>
            </svg>
            <span class="rd-works__arrow rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-narrow-up-right.svg" width="36" height="36" alt=""><img class="rd-arrow__b" src="{$img}arrow-narrow-up-right.svg" width="36" height="36" alt=""></span>
          </a>
        {/if}
      </div>
    </div>
  </div>
</section>
{/if}
