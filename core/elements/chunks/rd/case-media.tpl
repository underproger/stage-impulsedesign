{*
  Картинка кейса портфолио (общая для блока «Портфоліо» главной/услуг и страницы портфолио):
  {include 'file:chunks/rd/case-media.tpl' item=$item link=$link}
  item — элемент MIGX «rd_portfolio»: image / image_mob — композиция, layers — устройства слоями, screen — скриншот
  сайта (показывается в ноутбуке, если нет ни слоёв, ни композиции), word — надпись на фоне, hover — фото при наведении.
*}
{set $src = $item.image}
{if $src && !($src | preg_match : '~^(https?:)?/~')}{set $src = '/' ~ $src}{/if}
{set $mob = $item.image_mob}
{if $mob && !($mob | preg_match : '~^(https?:)?/~')}{set $mob = '/' ~ $mob}{/if}
{set $photo = $item.hover}
{if $photo && !($photo | preg_match : '~^(https?:)?/~')}{set $photo = '/' ~ $photo}{/if}
{set $screen = $item.screen}
{if $screen && !($screen | preg_match : '~^(https?:)?/~')}{set $screen = '/' ~ $screen}{/if}
{set $word = $item.word | strip_tags}
{set $wl = $word | length}
<a class="rd-case__media" href="{$link}" tabindex="-1" aria-hidden="true" draggable="false">
  {if $photo}<img class="rd-case__photo" src="{$photo}" alt="" draggable="false">{/if}
  {if $word}<span class="rd-case__word"{if $wl > 14} style="--rd-wfs: {$.php.round(128 / $wl, 2)}"{/if}>{$word}</span>{/if}
  {set $layers = $item.layers ? ($item.layers | json_decode : true) : []}
  {if $layers}
    {* Устройства отдельными слоями: при наведении каждое смещается/увеличивается по своим настройкам *}
    <span class="rd-case__layer">
      <span class="rd-case__devices{if $mob} rd-case__devices--desk{/if}">
        {foreach $layers as $li => $l}
          {set $ls = $l.image}
          {if $ls && !($ls | preg_match : '~^(https?:)?/~')}{set $ls = '/' ~ $ls}{/if}
          {set $p = ($l.pos ~ '') | preg_replace : '/[^0-9.\-]+/' : ' ' | preg_replace : '/^ | $/' : '' | preg_split : '/ /'}
          {set $h = ($l.hover ~ '') | preg_replace : '/[^0-9.\-]+/' : ' ' | preg_replace : '/^ | $/' : '' | preg_split : '/ /'}
          {if $ls}
            <img class="rd-case__dev" src="{$ls}" alt="" decoding="async" draggable="false" style="--i: {$li}; --x: {$p[0] ?: 50}; --y: {$p[1] ?: 50}; --w: {$p[2] ?: 30}; --hx: {$h[0] ?: 0}; --hy: {$h[1] ?: 0}; --hs: {$h[2] ?: 1}; --hr: {$h[3] ?: 0}">
          {/if}
        {/foreach}
      </span>
      {if $mob}<img class="rd-case__img rd-case__img--mob" src="{$mob}" alt="{$item.title | strip_tags | escape}" width="320" height="220" decoding="async" draggable="false">{/if}
    </span>
  {elseif $screen && !$src}
    {* скриншот сайта в ноутбуке (кейсы без готовой композиции) *}
    <span class="rd-case__layer">
      <span class="rd-case__devices">
        <span class="rd-case__dev rd-case__mock" style="--i: 0; --x: 50; --y: 56; --w: 62; --hx: 0; --hy: -1.2; --hs: 1.06; --hr: 0">
          <span class="rd-case__mock-screen"><img src="{$screen}" alt="{$item.title | strip_tags | escape}" width="560" height="400" loading="lazy" decoding="async" draggable="false"></span>
          <span class="rd-case__mock-base"></span>
        </span>
      </span>
    </span>
  {elseif $src}
    <span class="rd-case__layer">
      <picture>
        {if $mob}<source media="(max-width: 599px)" srcset="{$mob}">{/if}
        <img class="rd-case__img" src="{$src}" alt="{$item.title | strip_tags | escape}" width="1240" height="487" decoding="async" draggable="false">
      </picture>
    </span>
  {/if}
</a>
