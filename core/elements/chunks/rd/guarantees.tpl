{*
  Редизайн: плашка из 4 карточек с иконками (последняя — золотая) и круглой кнопкой. Один шаблон на два блока:
  1) главная, «4 унікальні гарантії від студії Impulse Design» (section 4):  {include 'file:chunks/rd/guarantees.tpl'}
     guaranty_title_bl7      — заголовок (золотое слово оберните в <span>)
     guaranty_list_bl7       — MIGX «guaranty»: title, text, icon (cart / diamond / speed / zap).
                               Последняя — золотая карточка справа. Иконка не выбрана — по порядку.
     guaranty_link_bl7       — куда ведёт круглая кнопка: ID ресурса или URL (пусто — как кнопка первого экрана)
     guaranty_link_text_bl7  — надпись на круглой кнопке
  2) страница услуги, «Переваги наших …»:  {include 'file:chunks/rd/guarantees.tpl' src='bl12'}
     title-bl12 — заголовок, list-bl12 — MIGX «advantages»: title, text, icon (иконки — в $icons ниже);
     круглая кнопка — как кнопка «Обговорити проект» первого экрана услуги (link-left-banner, пусто — как у главной).
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}

{if $src == 'bl12'}
  {set $sid = 'advantages'}
  {set $title = $r['title-bl12']}
  {set $items = $r['list-bl12'] | json_decode : true}
  {set $ctaUrl = $r['link-left-banner'] | trim}
  {if !$ctaUrl || $ctaUrl == '#'}{set $ctaUrl = $_modx->config.site_start | resource : 'link-left-banner'}{/if}
  {set $ctaText = $r['link_text-left-banner']}
  {if $ctaText == 'contact us'}{set $ctaText = ''}{/if}
  {set $icons = ['target', 'rocket', 'coins', 'smile']}
{else}
  {set $sid = 'garanty'}
  {set $title = $r['guaranty_title_bl7']}
  {set $items = $r['guaranty_list_bl7'] | json_decode : true}
  {set $ctaUrl = $r['guaranty_link_bl7'] ?: $r['link-left-banner']}
  {set $ctaText = $r['guaranty_link_text_bl7']}
  {set $icons = ['cart', 'diamond', 'speed', 'zap']}
{/if}
{if $ctaUrl && ($ctaUrl | preg_match : '/^\d+$/')}{set $ctaUrl = $ctaUrl | url}{/if}
{if !$ctaText}{set $ctaText = $isRu ? 'Обсудить проект' : 'Обговорити проект'}{/if}
{* размер надписи на круге — как у кнопки первого экрана *}
{set $ringLen = $ctaText | length}
{set $ringFs = $ringLen > 14 ? (196 / $ringLen) : 14}

{if $items}
<section class="rd-gar{if $sid != 'garanty'} rd-gar--{$sid}{/if}" id="{$sid}">
  <div class="rd-gar__glow" aria-hidden="true"></div>
  <div class="rd-container rd-gar__wrap">
    {if $title}
      {set $title = $title | strip_tags : '<span><br>' | trim}
      {* в заголовке нет <span> — золотым становится первое слово («Переваги наших …») *}
      {if !($title | preg_match : '~<span~')}{set $title = $title | preg_replace : '~^(\S+)~u' : '<span>$1</span>'}{/if}
      {* data-rd-fit: длинное слово («ПРЕИМУЩЕСТВА») не влезает — rd.js уменьшает кегль *}
      <h2 class="rd-gar__title" data-rd-fit>{$title}</h2>
    {/if}

    {if $ctaUrl}
      <a class="rd-works rd-works--inline rd-gar__cta" href="{$ctaUrl}" aria-label="{$ctaText}" data-rd-magnet>
        <span class="rd-works__disc"></span>
        <span class="rd-works__fill"></span>
        <svg class="rd-works__ring" viewBox="0 0 160 160" aria-hidden="true">
          <defs>
            <path id="rd-{$sid}-path" d="M19 80a61 61 0 1 1 122 0a61 61 0 1 1 -122 0"/>
          </defs>
          <text text-anchor="middle" font-size="{$ringFs}"><textPath href="#rd-{$sid}-path" startOffset="25%">{$ctaText}</textPath></text>
          <text text-anchor="middle" font-size="{$ringFs}"><textPath href="#rd-{$sid}-path" startOffset="75%">{$ctaText}</textPath></text>
          <circle cx="145" cy="80" r="2"/>
          <circle cx="15" cy="80" r="2"/>
        </svg>
        <span class="rd-works__arrow rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-narrow-up-right.svg" width="36" height="36" alt=""><img class="rd-arrow__b" src="{$img}arrow-narrow-up-right.svg" width="36" height="36" alt=""></span>
      </a>
    {/if}

    <div class="rd-gar__panel">
      {set $last = ($items | length) - 1}
      {foreach $items as $i => $item}
        {set $icon = $item.icon ?: $icons[$i % 4]}
        <article class="rd-gar-card{if $i == $last} rd-gar-card--gold{/if}">
          <span class="rd-gar-card__icon" aria-hidden="true">
            <svg class="rd-gar-ic rd-gar-ic--{$icon}" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
              {switch $icon}
                {case 'cart'}
                  <g class="rd-gar-ic__body"><path pathLength="1" d="M2 2h1.2a.8.8 0 0 1 .8.75L5 18h14"/><path pathLength="1" d="M4.19 5h17.85l-.84 7.4a1.8 1.8 0 0 1-1.79 1.6H4.75"/></g>
                  <circle class="rd-gar-ic__wheel" cx="7.5" cy="21.5" r=".6"/><circle class="rd-gar-ic__wheel" cx="16.5" cy="21.5" r=".6"/>
                {case 'diamond'}
                  <path pathLength="1" d="M12.614 20.263l8.959-10.75c.152-.183.228-.274.257-.376a.5.5 0 0 0 0-.274c-.03-.102-.105-.193-.257-.375L17.24 3.288c-.088-.106-.132-.159-.186-.197a.5.5 0 0 0-.158-.074C16.83 3 16.763 3 16.625 3h-9.25c-.138 0-.207 0-.271.017a.5.5 0 0 0-.158.074c-.054.038-.098.091-.186.197L2.426 8.488c-.152.182-.228.273-.257.375a.5.5 0 0 0 0 .274c.03.102.105.193.257.375l8.959 10.75c.211.254.316.38.443.427a.5.5 0 0 0 .343 0c.126-.047.232-.173.443-.426Z"/>
                  <path class="rd-gar-ic__facets" pathLength="1" d="M2.5 9h19M10 3 8 9l4 11.5L16 9l-2-6"/>
                {case 'speed'}
                  <path pathLength="1" d="M22 12c0 5.523-4.477 10-10 10S2 17.523 2 12 6.477 2 12 2s10 4.477 10 10Z"/>
                  <path pathLength="1" d="M5 12a7 7 0 0 1 7-7"/>
                  <path class="rd-gar-ic__needle" d="M16.5 7.5 12 12"/>
                  <circle cx="12" cy="12" r="1"/>
                {case 'target'}
                  <path pathLength="1" d="M21.95 13c-.501 5.053-4.765 9-9.95 9-5.523 0-10-4.477-10-10 0-5.185 3.947-9.449 9-9.95"/>
                  <path class="rd-gar-ic__dash" pathLength="1" d="M15.5 3.5V2M19.44 4.56 20.5 3.5M20.51 8.5h1.5"/>
                  <g class="rd-gar-ic__arrow"><path pathLength="1" d="M12 8h4v4"/><path pathLength="1" d="M15.62 8A12.984 12.984 0 0 1 5 13.5c-1.003 0-1.98-.114-2.917-.329"/></g>
                {case 'rocket'}
                  <g class="rd-gar-ic__rocket">
                    <path pathLength="1" d="m12 15-3-3m3 3a22.355 22.355 0 0 0 4-2m-4 2v5s3.03-.55 4-2c1.08-1.62 0-5 0-5m-7-1a21.999 21.999 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11m-7-1H4s.55-3.03 2-4c1.62-1.08 5 0 5 0"/>
                    <path class="rd-gar-ic__flame" pathLength="1" d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09Z"/>
                  </g>
                {case 'coins'}
                  <path pathLength="1" d="M13 5c0 1.105-2.462 2-5.5 2S2 6.105 2 5m11 0c0-1.105-2.462-2-5.5-2S2 3.895 2 5m11 0v4.457c-1.222.367-2 .922-2 1.543M2 5v12c0 1.105 2.462 2 5.5 2 1.33 0 2.55-.172 3.5-.457V11M2 9c0 1.105 2.462 2 5.5 2 1.33 0 2.55-.172 3.5-.457M2 13c0 1.105 2.462 2 5.5 2 1.33 0 2.55-.172 3.5-.457"/>
                  <g class="rd-gar-ic__stack"><path pathLength="1" d="M22 11c0 1.105-2.462 2-5.5 2s-5.5-.895-5.5-2m11 0c0-1.105-2.462-2-5.5-2s-5.5.895-5.5 2m11 0v8c0 1.105-2.462 2-5.5 2s-5.5-.895-5.5-2v-8m11 4c0 1.105-2.462 2-5.5 2s-5.5-.895-5.5-2"/></g>
                {case 'smile'}
                  <path pathLength="1" d="M7 18v2.335c0 .533 0 .8.11.937a.5.5 0 0 0 .39.188c.176 0 .384-.167.8-.5l2.385-1.908c.487-.39.731-.585 1.002-.724.241-.122.497-.212.762-.267.299-.061.61-.061 1.235-.061H16.2c1.68 0 2.52 0 3.162-.327a3 3 0 0 0 1.311-1.311C21 15.72 21 14.88 21 13.2V7.8c0-1.68 0-2.52-.327-3.162a3 3 0 0 0-1.311-1.311C18.72 3 17.88 3 16.2 3H7.8c-1.68 0-2.52 0-3.162.327a3 3 0 0 0-1.311 1.311C3 5.28 3 6.12 3 7.8V14c0 .93 0 1.395.102 1.777a3 3 0 0 0 2.122 2.12C5.605 18 6.07 18 7 18Z"/>
                  <path class="rd-gar-ic__mouth" pathLength="1" d="M8.5 12.5S9.813 14 12 14c2.188 0 3.5-1.5 3.5-1.5"/>
                  <g class="rd-gar-ic__eyes"><circle cx="9.25" cy="7.5" r=".5"/><circle cx="14.75" cy="7.5" r=".5"/></g>
                {default}
                  <path pathLength="1" d="M13 2 4.093 12.688c-.348.418-.523.628-.525.804a.5.5 0 0 0 .185.397c.138.111.41.111.955.111H12l-1 8 8.907-10.688c.348-.418.523-.628.525-.804a.5.5 0 0 0-.185-.397C20.109 10 19.837 10 19.292 10H12l1-8Z"/>
              {/switch}
            </svg>
          </span>
          {* слова через дефис в заголовке не переносим («SEO-оптимізація») *}
          <h3 class="rd-gar-card__title">{$item.title | strip_tags : '<br><span>' | preg_replace : '~([^\s<>"]*-[^\s<>"]+)~u' : '<span class="rd-nowrap">$1</span>'}</h3>
          {if $item.text}<p class="rd-gar-card__text">{$item.text | strip_tags : '<br><b><strong><span>'}</p>{/if}
        </article>
      {/foreach}
    </div>
  </div>
</section>
{/if}
