{*
  Редизайн: страница копирайтинга — «Чому ми» (section 8 copywriting_1920.pdf).
  Поля (TV шаблона копирайтинга):
    cw_why_title       — заголовок (пусто — «Чому ми»; золото — в <span>)
    cw_why_text        — подзаголовок (жирный — <b>)
    cw_why_card_title  — тёмная карточка: заголовок («Не використовуємо AI»; пусто — карточки нет)
    cw_why_card_text   — тёмная карточка: текст (золото — <span>, жирный — <b>)
    cw_why             — MIGX «rd_why_items»: icon (shield / support / target; пусто — по порядку), title,
                         text (жирный — <b>), note (сноска мелко под текстом)
  Нет ни пунктов, ни карточки — блока нет.
  Картинка карточки: 15 «волнистых» колец (рисует rd.js по [data-rd-rings], оживляет rd-wow.js) и знак «запрещено».
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $items = $r['cw_why'] | json_decode : true}
{set $title = $r['cw_why_title'] | strip_tags : '<span><br>' | trim}
{if !$title}{set $title = $isRu ? 'Почему мы' : 'Чому ми'}{/if}
{set $cardTitle = $r['cw_why_card_title'] | strip_tags | trim}
{set $order = ['shield', 'support', 'target']}
{if $items || $cardTitle}
<section class="rd-why" id="why">
  <div class="rd-container rd-why__wrap">
    <div class="rd-why__head">
      <h2 class="rd-why__title" data-rd-fit>{$title}</h2>
      {if $r['cw_why_text']}<p class="rd-why__text">{$r['cw_why_text'] | strip_tags : '<b><strong><br>' | trim}</p>{/if}
      {if $cardTitle}
        <div class="rd-why__card">
          <span class="rd-why__grid" aria-hidden="true"></span>
          <svg class="rd-why__art" viewBox="-112 -104 224 208" fill="none" aria-hidden="true" focusable="false" data-rd-rings>
            <defs>
              {* золото → оранжевый к правому краю колец (эллипс подобран по макету) *}
              <radialGradient id="rd-why-grad" gradientUnits="userSpaceOnUse" cx="70.3" cy="-12.4" r="86.8" gradientTransform="matrix(1 0 0 1.573 0 7.1)">
                <stop offset="0.25" stop-color="#f4720d"/>
                <stop offset="0.95" stop-color="#bfa660"/>
              </radialGradient>
            </defs>
            <g class="rd-why__rings" stroke="url(#rd-why-grad)" stroke-width="1"></g>
            {* знак: внешняя группа «штампуется» при появлении, внутренняя качается на наведении *}
            <g class="rd-why__ban" stroke="#bfa660" stroke-width="3">
              <g class="rd-why__ban-in">
                <circle pathLength="1" cx="-61.5" cy="70.5" r="20" transform="rotate(-135 -61.5 70.5)"/>
                <path pathLength="1" d="M-75.6 56.4-47.4 84.6"/>
              </g>
            </g>
          </svg>
          <div class="rd-why__body">
            <h3 class="rd-why__card-title">{$cardTitle}</h3>
            {if $r['cw_why_card_text']}<p class="rd-why__card-text">{$r['cw_why_card_text'] | strip_tags : '<span><b><strong><br>' | preg_replace : '~<span[^>]*>~iu' : '<span>' | trim}</p>{/if}
          </div>
        </div>
      {/if}
    </div>
    {if $items}
      <ul class="rd-why__list">
        {foreach $items as $i => $it}
          {set $ic = $it.icon ?: $order[$i % 3]}
          <li class="rd-why__item" style="--i: {$i}">
            <div class="rd-why__row">
              <span class="rd-why__pill" aria-hidden="true">
                <svg class="rd-why__ic rd-why__ic--{$ic}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
                  {switch $ic}
                    {case 'support'}
                      {* гарнитура «24» — нарисована по макету (линия 1.2, как у остальных) *}
                      <path class="rd-why__band" pathLength="1" d="M10.3 2.05A10 10 0 0 0 2 12v5.4c0 .5.4.9.9.9h1.8c.5 0 .9-.4.9-.9v-3.65c0-.5-.4-.9-.9-.9H2M22 10.1v9l-6.65 2.88H12.3M22 12.85h-2.7c-.5 0-.9.4-.9.9v3.65c0 .5.4.9.9.9H22"/>
                      <rect class="rd-why__mic" pathLength="1" x="11.1" y="21.1" width="1.8" height=".9" rx=".45"/>
                      <path class="rd-why__24" pathLength="1" d="M12.9 3.8a1.8 1.8 0 0 1 3.6 0c0 .55-.25 1-.65 1.35L12.9 7.45h3.6M22 6.9V2.05L19 5.33h3"/>
                    {case 'target'}
                      {* Untitled UI target-04 *}
                      <path class="rd-why__dart" pathLength="1" d="M16 8V5l3-3 1 2 2 1-3 3h-3Zm0 0-4 4"/>
                      <path pathLength="1" d="M22 12c0 5.523-4.477 10-10 10S2 17.523 2 12 6.477 2 12 2m5 10a5 5 0 1 1-5-5"/>
                    {default}
                      {* Untitled UI shield-tick (в макете чуть шире) *}
                      <g transform="matrix(1.04 0 0 1 -.02 0)">
                        <path pathLength="1" d="M20 12c0 4.908-5.354 8.478-7.302 9.615-.221.129-.332.194-.488.227a1.137 1.137 0 0 1-.42 0c-.156-.034-.267-.098-.488-.227C9.354 20.478 4 16.908 4 12V7.217c0-.799 0-1.199.13-1.542a2 2 0 0 1 .548-.79c.276-.243.65-.383 1.398-.664l5.362-2.01c.208-.078.312-.117.419-.133a1 1 0 0 1 .286 0c.107.016.21.055.419.133l5.362 2.01c.748.28 1.123.421 1.398.664a2 2 0 0 1 .547.79c.131.343.131.743.131 1.542V12Z"/>
                        <path class="rd-why__tick" pathLength="1" d="m9 11.5 2 2L15.5 9"/>
                      </g>
                  {/switch}
                </svg>
              </span>
              {if $it.title}<h3 class="rd-why__name">{$it.title | strip_tags | trim}</h3>{/if}
            </div>
            {if $it.text}<p class="rd-why__desc">{$it.text | strip_tags : '<b><strong><br>' | trim}</p>{/if}
            {if $it.note}<p class="rd-why__note">{$it.note | strip_tags : '<b><strong><br>' | trim}</p>{/if}
          </li>
        {/foreach}
      </ul>
    {/if}
  </div>
</section>
{/if}
