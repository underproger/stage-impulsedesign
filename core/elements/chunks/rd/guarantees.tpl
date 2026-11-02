{*
  Редизайн: блок «4 унікальні гарантії від студії Impulse Design» — section 4 макета.
  Поля (TV):
    guaranty_title_bl7      — заголовок (золотое слово оберните в <span>)
    guaranty_list_bl7       — MIGX «guaranty»: title, text, icon (cart / diamond / speed / zap).
                              Последняя гарантия — золотая карточка справа. Иконка не выбрана — по порядку.
    guaranty_link_bl7       — куда ведёт круглая кнопка: ID ресурса или URL (пусто — как кнопка первого экрана)
    guaranty_link_text_bl7  — надпись на круглой кнопке
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $items = $r['guaranty_list_bl7'] | json_decode : true}

{set $ctaUrl = $r['guaranty_link_bl7'] ?: $r['link-left-banner']}
{if $ctaUrl && ($ctaUrl | preg_match : '/^\d+$/')}{set $ctaUrl = $ctaUrl | url}{/if}
{set $ctaText = $r['guaranty_link_text_bl7'] ?: ($isRu ? 'Обсудить проект' : 'Обговорити проект')}
{* размер надписи на круге — как у кнопки первого экрана *}
{set $ringLen = $ctaText | length}
{set $ringFs = $ringLen > 14 ? (196 / $ringLen) : 14}
{set $icons = ['cart', 'diamond', 'speed', 'zap']}

{if $items}
<section class="rd-gar" id="garanty">
  <div class="rd-gar__glow" aria-hidden="true"></div>
  <div class="rd-container rd-gar__wrap">
    {if $r['guaranty_title_bl7']}
      <h2 class="rd-gar__title">{$r['guaranty_title_bl7'] | strip_tags : '<span><br>'}</h2>
    {/if}

    {if $ctaUrl}
      <a class="rd-works rd-works--inline rd-gar__cta" href="{$ctaUrl}" aria-label="{$ctaText}" data-rd-magnet>
        <span class="rd-works__disc"></span>
        <span class="rd-works__fill"></span>
        <svg class="rd-works__ring" viewBox="0 0 160 160" aria-hidden="true">
          <defs>
            <path id="rd-gar-path" d="M19 80a61 61 0 1 1 122 0a61 61 0 1 1 -122 0"/>
          </defs>
          <text text-anchor="middle" font-size="{$ringFs}"><textPath href="#rd-gar-path" startOffset="25%">{$ctaText}</textPath></text>
          <text text-anchor="middle" font-size="{$ringFs}"><textPath href="#rd-gar-path" startOffset="75%">{$ctaText}</textPath></text>
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
