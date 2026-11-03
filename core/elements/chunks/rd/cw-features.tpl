{*
  Редизайн: страница копирайтинга — 4 преимущества под первым экраном (section 2 copywriting_1920.pdf).
  Поле (TV) cw_features — MIGX «rd_features»: icon (type / feather / list / stars / check / shield; пусто — по порядку),
  title (заголовок; «*» в конце — ссылка на сноску), note (сноска мелко под заголовком, жирный — <b>).
  Нет пунктов — блока нет.
*}
{set $items = $_modx->resource['cw_features'] | json_decode : true}
{set $order = ['type', 'feather', 'list', 'stars']}
{if $items}
<section class="rd-feat" id="features">
  <div class="rd-container">
    <ul class="rd-feat__list">
      {foreach $items as $i => $it}
        {set $ic = $it.icon ?: $order[$i % 4]}
        <li class="rd-feat__item" style="--i: {$i}">
          <span class="rd-feat__pill" aria-hidden="true">
            <svg class="rd-feat__ic rd-feat__ic--{$ic}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
              {switch $ic}
                {case 'feather'}
                  <path pathLength="1" d="M20.24 12.24a6 6 0 0 0-8.49-8.49L5 10.5V19h8.5z"/><path pathLength="1" d="M16 8 2 22"/><path pathLength="1" d="M17.5 15H9"/>
                {case 'list'}
                  <path pathLength="1" d="M21 12H9m12-6H9m12 12H9"/><g class="rd-feat__dots"><circle pathLength="1" cx="4" cy="6" r="1.6"/><circle pathLength="1" cx="4" cy="12" r="1.6"/><circle pathLength="1" cx="4" cy="18" r="1.6"/></g>
                {case 'stars'}
                  <path class="rd-feat__plus" pathLength="1" d="M4.5 22v-5m0-10V2M2 4.5h5m-5 15h5"/><path class="rd-feat__star" pathLength="1" d="m13 3-1.73 4.5c-.29.74-.43 1.1-.65 1.41a3 3 0 0 1-.7.7c-.31.22-.68.37-1.41.65L4 12l4.5 1.73c.74.29 1.1.43 1.41.65a3 3 0 0 1 .7.7c.22.31.37.68.65 1.41L13 21l1.73-4.5c.29-.74.43-1.1.65-1.41a3 3 0 0 1 .7-.7c.31-.22.68-.37 1.41-.65L22 12l-4.5-1.73c-.74-.29-1.1-.43-1.41-.65a3 3 0 0 1-.7-.7c-.22-.31-.37-.68-.65-1.41z"/>
                {case 'check'}
                  <path pathLength="1" d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><path pathLength="1" d="m22 4-10 10.01-3-3"/>
                {case 'shield'}
                  <path pathLength="1" d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path pathLength="1" d="m9 12 2 2 4-4"/>
                {default}
                  <path pathLength="1" d="M4 7c0-.93 0-1.4.15-1.77a2 2 0 0 1 1.08-1.08C5.6 4 6.07 4 7 4h10c.93 0 1.4 0 1.77.15a2 2 0 0 1 1.08 1.08C20 5.6 20 6.07 20 7"/><path pathLength="1" d="M8 20h8M10.25 4v16m3.5-16v16"/>
              {/switch}
            </svg>
          </span>
          <h3 class="rd-feat__title">{$it.title | strip_tags : '<br>'}</h3>
          {if $it.note}<p class="rd-feat__note">{$it.note | strip_tags : '<b><strong><br>'}</p>{/if}
        </li>
      {/foreach}
    </ul>
  </div>
</section>
{/if}
