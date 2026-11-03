{*
  Редизайн: страница копирайтинга — «Корисні СЕО-тексти від професіоналів» (section 3 copywriting_1920.pdf).
  Поля (TV): cw_services_title — заголовок (золото — в <span>);
             cw_services — MIGX «rd_cards»: title, text (жирный — <b>). Номера 01, 02… — по порядку.
  Карточки 2 в ряд (телефон — столбик); первая — тёмная с сеткой и золотым свечением. На десктопе при наведении
  тёмной становится карточка под курсором: тёмная заливка заезжает слева (у прежней — уходит вправо), сетка и свечение
  проявляются следом, за курсором — золотой свет, номер «прокручивается», название сдвигается (rd.js / rd-wow.js).
  Слои фона — в .rd-cws__bg (под текстом).
*}
{set $r = $_modx->resource}
{set $items = $r['cw_services'] | json_decode : true}
{set $title = $r['cw_services_title'] | strip_tags : '<span><br>' | preg_replace : '~<span[^>]*>~iu' : '<span>' | trim}
{if $items}
<section class="rd-cws" id="services-list">
  <div class="rd-container">
    {if $title}<h2 class="rd-cws__title" data-rd-fit>{$title}</h2>{/if}
    <ol class="rd-cws__list">
      {foreach $items as $i => $it}
        {set $num = $i < 9 ? ('0' ~ ($i + 1)) : ($i + 1)}
        <li class="rd-cws__card{if $i == 0} rd-cws__card--dark{/if}" style="--i: {$i}">
          <span class="rd-cws__bg" aria-hidden="true"><span class="rd-cws__fill"></span><span class="rd-cws__grid"></span><span class="rd-cws__glow"></span></span>
          <span class="rd-cws__num" aria-hidden="true"><span>{$num}</span><span>{$num}</span></span>
          {if $it.title}<h3 class="rd-cws__name">{$it.title | strip_tags | trim}</h3>{/if}
          {if $it.text}<p class="rd-cws__text">{$it.text | strip_tags : '<br><b><strong>' | trim}</p>{/if}
        </li>
      {/foreach}
    </ol>
  </div>
</section>
{/if}
