{*
  Редизайн: страница копирайтинга — карточки 2 в ряд с номерами. Один шаблон на два блока:
  1) «Корисні СЕО-тексти від професіоналів» (section 3):  {include 'file:chunks/rd/cw-services.tpl'}
     cw_services_title — заголовок (золото — в <span>); cw_services — MIGX «rd_cards»: title, text (жирный — <b>).
     Тёмная — первая карточка.
  2) «Вартість СЕО-текстів» (section 7):  {include 'file:chunks/rd/cw-services.tpl' src='prices'}
     cw_prices_title — заголовок; cw_prices — MIGX «rd_price_cards»: title, price («150 ₴» — число «досчитывается»),
     unit («/1000 символів»), from (подпись над ценой; пусто — «від», «-» — без подписи). Тёмная — последняя.
  Номера 01, 02… — по порядку. Телефон — столбик. На десктопе тёмной становится карточка под курсором: тёмная заливка
  заезжает слева (у прежней — уходит вправо), сетка и свечение проявляются следом, за курсором — золотой свет,
  номер «прокручивается», название сдвигается (rd.js / rd-wow.js). Слои фона — в .rd-cws__bg (под текстом).
  Дефис в заголовке — место переноса и в «вау» (<wbr>): «ВАРТІСТЬ СЕО- / ТЕКСТІВ», как в макете.
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $prices = $src == 'prices'}
{set $items = ($prices ? $r['cw_prices'] : $r['cw_services']) | json_decode : true}
{set $title = ($prices ? $r['cw_prices_title'] : $r['cw_services_title']) | strip_tags : '<span><br>' | preg_replace : '~<span[^>]*>~iu' : '<span>' | trim}
{if $prices && !$title}{set $title = $isRu ? 'Стоимость СЕО-текстов' : 'Вартість СЕО-текстів'}{/if}
{set $title = $title | preg_replace : '~(\w)-(\w)~u' : '$1-<wbr>$2'}
{set $last = ($items | length) - 1}
{if $items}
<section class="rd-cws{if $prices} rd-cws--prices{/if}" id="{$prices ? 'text-prices' : 'services-list'}">
  <div class="rd-container">
    {if $title}<h2 class="rd-cws__title" data-rd-fit>{$title}</h2>{/if}
    <ol class="rd-cws__list">
      {foreach $items as $i => $it}
        {set $num = $i < 9 ? ('0' ~ ($i + 1)) : ($i + 1)}
        {set $dark = $prices ? ($i == $last) : ($i == 0)}
        <li class="rd-cws__card{if $dark} rd-cws__card--dark{/if}" style="--i: {$i}">
          <span class="rd-cws__bg" aria-hidden="true"><span class="rd-cws__fill"></span><span class="rd-cws__grid"></span><span class="rd-cws__glow"></span></span>
          <span class="rd-cws__num" aria-hidden="true"><span>{$num}</span><span>{$num}</span></span>
          {if $it.title}<h3 class="rd-cws__name">{$it.title | strip_tags | trim}</h3>{/if}
          {if $prices}
            {set $from = $it.from | strip_tags | trim}
            {if !$from}{set $from = $isRu ? 'от' : 'від'}{/if}
            {if $it.price}
              <p class="rd-cws__price">
                {if $from != '-'}<span class="rd-cws__from">{$from}</span>{/if}
                <span class="rd-cws__sum"><b class="rd-cws__value">{$it.price | strip_tags | trim}</b>{if $it.unit} <span class="rd-cws__unit">{$it.unit | strip_tags | trim}</span>{/if}</span>
              </p>
            {/if}
          {elseif $it.text}
            <p class="rd-cws__text">{$it.text | strip_tags : '<br><b><strong>' | trim}</p>
          {/if}
        </li>
      {/foreach}
    </ol>
  </div>
</section>
{/if}
