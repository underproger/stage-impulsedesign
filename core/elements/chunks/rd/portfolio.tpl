{*
  Редизайн: блок «Портфоліо».
  Поля (TV): title-bl2 — заголовок, sub-title-bl2 — подзаголовок (можно <b>),
  rd_portfolio_bl2 — MIGX, кейсы:
    tags      — хэштеги через запятую (building, e-commerce…)
    title     — название проекта
    text      — описание
    link      — ID ресурса или URL страницы кейса
    image     — композиция с устройствами 1240×487 (2480×974 для чётких экранов), фон прозрачный
    image_mob — то же для телефона 320×220 (640×440), необязательно
    layers    — устройства отдельными слоями (вложенный MIGX), тогда image используется только как превью:
                image — картинка устройства с прозрачным фоном,
                pos   — «x y w»: центр в % от ширины/высоты карточки и ширина в % от ширины карточки,
                hover — «dx dy масштаб поворот» при наведении: сдвиг в % ширины карточки, поворот в градусах
                На телефоне вместо слоёв показывается image_mob (если задан).
    bg        — фон карточки: цвет или градиент, например #16202e
    word      — крупная надпись на фоне карточки, необязательно
    hover     — фото, которое проявляется на фоне при наведении, необязательно
  «Всі проекти» ведёт на страницу портфолио (100 / 404), Behance — настройка behance.
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $items = $r['rd_portfolio_bl2'] | json_decode : true}
{set $allUrl = $_modx->makeUrl($isRu ? 100 : 404)}
{set $behance = 'behance' | option}
{set $t = $isRu ? [
  'title' => 'Портфолио',
  'all' => 'Все проекты',
  'more' => 'Посмотреть проект',
  'view' => 'смотреть'
] : [
  'title' => 'Портфоліо',
  'all' => 'Всі проекти',
  'more' => 'Переглянути проект',
  'view' => 'дивитись'
]}

{if $items}
<section class="rd-portfolio" id="portfolio" data-rd-portfolio data-rd-view="{$t.view}">
  <div class="rd-portfolio__pin">
    <div class="rd-container rd-portfolio__head">
      <div class="rd-portfolio__heading">
        {set $title = $r['title-bl2'] ?: $t.title}
        <h2 class="rd-portfolio__title">{$title | strip_tags : '<span><br>'}</h2>
        {if $r['sub-title-bl2']}
          <p class="rd-portfolio__text">{$r['sub-title-bl2'] | strip_tags : '<b><strong><br><a>'}</p>
        {/if}
      </div>
      <a class="rd-btn rd-btn--dark rd-portfolio__all" href="{$allUrl}">
        <span>{$t.all}</span>
        <span class="rd-arrow"><img class="rd-arrow__a" src="{$img}arrow-up-right-dark.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="{$img}arrow-up-right-dark.svg" width="24" height="24" alt=""></span>
      </a>
    </div>

    <div class="rd-portfolio__viewport" data-rd-pf-viewport>
      <div class="rd-portfolio__track" data-rd-pf-track>
        {foreach $items as $item}
          {set $link = $item.link}
          {if $link && ($link | preg_match : '/^\d+$/')}{set $link = $link | url}{/if}
          {if !$link}{set $link = $allUrl}{/if}
          {set $src = $item.image}
          {if $src && !($src | preg_match : '~^(https?:)?/~')}{set $src = '/' ~ $src}{/if}
          {set $mob = $item.image_mob}
          {if $mob && !($mob | preg_match : '~^(https?:)?/~')}{set $mob = '/' ~ $mob}{/if}
          {set $photo = $item.hover}
          {if $photo && !($photo | preg_match : '~^(https?:)?/~')}{set $photo = '/' ~ $photo}{/if}
          {set $word = $item.word | strip_tags}
          {set $wl = $word | length}
          {set $tags = $item.tags | preg_replace : '/#|^\s+|\s+$/u' : '' | preg_split : '/\s*,\s{0,9}/u'}
          <article class="rd-case"{if $item.bg} style="--rd-case-bg: {$item.bg | strip_tags | escape}"{/if}>
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
              {elseif $src}
                <span class="rd-case__layer">
                  <picture>
                    {if $mob}<source media="(max-width: 599px)" srcset="{$mob}">{/if}
                    <img class="rd-case__img" src="{$src}" alt="{$item.title | strip_tags | escape}" width="1240" height="487" decoding="async" draggable="false">
                  </picture>
                </span>
              {/if}
            </a>
            <div class="rd-case__desc">
              <div class="rd-case__heading">
                {if $item.tags}
                  <p class="rd-case__tags">
                    {foreach $tags as $tag}{if $tag}<span># {$tag}</span>{/if}{/foreach}
                  </p>
                {/if}
                <h3 class="rd-case__title"><a href="{$link}" draggable="false">{$item.title}</a></h3>
              </div>
              {if $item.text}
                <div class="rd-case__text">{$item.text}</div>
              {/if}
              <a class="rd-case__more" href="{$link}" aria-label="{$t.more}: {$item.title | strip_tags | escape}" draggable="false">
                <span class="rd-case__more-text">{$t.more}</span>
                <span class="rd-arrow"><img class="rd-arrow__a" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt=""></span>
              </a>
            </div>
          </article>
        {/foreach}
      </div>
    </div>

    <div class="rd-container rd-portfolio__actions">
      <a class="rd-btn rd-btn--dark rd-portfolio__all-m" href="{$allUrl}">
        <span>{$t.all}</span>
        <span class="rd-arrow"><img class="rd-arrow__a" src="{$img}arrow-up-right-dark.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="{$img}arrow-up-right-dark.svg" width="24" height="24" alt=""></span>
      </a>
      {if $behance}
        <a class="rd-behance" href="{$behance}" target="_blank" rel="noopener" aria-label="Behance">
          <span class="rd-behance__icon" style="--rd-icon: url({$img}soc-behance.svg)"></span>
          <span class="rd-behance__text">Behance</span>
        </a>
      {/if}
    </div>
  </div>
</section>
{/if}
