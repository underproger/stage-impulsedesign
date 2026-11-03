{*
  Редизайн: блок «Вартість розробки сайту під ключ» — section 5 макета.
  Поля (TV):
    title-bl7       — заголовок (золотое слово оберните в <span>)
    sub-title-bl7   — подзаголовок (можно <b>)
    price-list_bl7  — MIGX «price_list»: title — услуга, prefix — «від», price — цена («600$»),
                      link — ID ресурса или URL (карточка становится ссылкой; ID текущей страницы — без ссылки).
                      Номера 01, 02… ставятся сами. Последняя карточка — тёмная.
  Старая разметка страниц услуг тоже понимается: в заголовке <span class="cost-upper">ВЕБ-САЙТІВ</span>
  <span class="gold">під ключ</span> — золотым остаётся «gold» (а если его нет — «cost-upper»), классы снимаются;
  в подзаголовке <span> → <b>.
*}
{set $r = $_modx->resource}
{set $img = '/assets/templates/rd/img/'}
{set $items = $r['price-list_bl7'] | json_decode : true}
{set $title = $r['title-bl7'] | trim}
{if $title | preg_match : '~class="?gold~iu'}
  {set $title = $title | preg_replace : '~<span[^>]*cost-upper[^>]*>(.*?)</span>~isu' : '$1'}
{/if}
{set $title = $title | preg_replace : '~<span[^>]*>\s*~iu' : '<span>' | preg_replace : '~\s*</span>~iu' : '</span>' | preg_replace : '~\s*(<span>)~u' : ' $1' | trim}
{set $sub = $r['sub-title-bl7'] | preg_replace : '~<span[^>]*>(.*?)</span>~isu' : '<b>$1</b>' | strip_tags : '<b><strong><br>' | preg_replace : '~\s+([,.!?])~u' : '$1' | trim}

{if $items}
<section class="rd-prices" id="price">
  <div class="rd-container rd-prices__wrap">
    <div class="rd-prices__heading">
      {if $title}
        <h2 class="rd-prices__title">{$title | strip_tags : '<span><br>'}</h2>
      {/if}
      {if $sub}
        <p class="rd-prices__text">{$sub}</p>
      {/if}
    </div>

    <div class="rd-prices__list">
      {set $last = ($items | length) - 1}
      {foreach $items as $i => $item}
        {set $link = $item.link}
        {if $link == $_modx->resource.id}{set $link = ''}{/if}{* карточка текущей страницы — без ссылки *}
        {if $link && ($link | preg_match : '/^\d+$/')}{set $link = $link | url}{/if}
        {* цена: «600$»; старый формат «<sup>від</sup> 600 $» тоже понимаем *}
        {set $raw = $item.price ?: ''}
        {set $prefix = $item.prefix | strip_tags | trim}
        {if !$prefix && ($raw | preg_match : '~<sup~i')}
          {set $prefix = $raw | preg_replace : '~^.*?<sup[^>]*>(.*?)</sup>.*$~isu' : '$1' | strip_tags | trim}
          {set $raw = $raw | preg_replace : '~<sup[^>]*>.*?</sup>~isu' : ''}
        {/if}
        {set $price = $raw | strip_tags | preg_replace : '~\s+~u' : ' ' | preg_replace : '~\s+(?=[$€₴])~u' : '' | trim}
        {set $tag = $link ? 'a' : 'div'}
        <{$tag} class="rd-price{if $i == $last} rd-price--accent{/if}"{if $link} href="{$link}"{/if}>
          <span class="rd-price__fill" aria-hidden="true"><span></span></span>
          {if $i == $last}<span class="rd-price__aglow" aria-hidden="true"></span>{/if}
          <span class="rd-price__num">{($i + 1) < 10 ? '0' ~ ($i + 1) : ($i + 1)}</span>
          <span class="rd-price__title">{$item.title | strip_tags : '<br>'}</span>
          <span class="rd-price__cost">
            {if $prefix}<span class="rd-price__from">{$prefix}</span>{/if}
            <span class="rd-price__value">{$price}</span>
          </span>
          {if $link}
            <span class="rd-price__arrow rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt=""></span>
          {/if}
        </{$tag}>
      {/foreach}
    </div>
  </div>
</section>
{/if}
