{*
  Редизайн: блок «Що таке …» страницы услуги (шаблон 21, чекбокс display_bl11). Макет — section 2 service_*.pdf.
  Поля (TV, категория «Блок 11 - Что такое услуга»):
    what_title      — заголовок, золото — в <span> («Що таке <span>Landing page</span>»);
    what_sub  — подзаголовок, жирный — <b>;
    text-bl11       — richtext: пункты справа по <h3> (заголовок пункта) + текст под ним (жирный — <b>);
                      <h2> — запасной заголовок, если what_title пуст: «Що таке X - подзаголовок?» → «Що таке <span>X</span>» + «Подзаголовок»;
    what_card       — текст тёмной карточки (абзацы <p>, золото — <b>/<span>); пусто — карточки нет;
    what_stat_label / what_stat_value — подпись и число в кольцах карточки («Продажів», «786+»).
  Иконки пунктов по порядку: монитор, мишень (дальше по кругу).
*}
{set $r = $_modx->resource}
{set $raw = $r['text-bl11'] | replace : '&nbsp;' : ' '}

{* --- заголовок и подзаголовок: свои поля или из <h2> --- *}
{set $title = $r['what_title'] | strip_tags : '<span><br>' | trim}
{set $sub = $r['what_sub'] | strip_tags : '<b><strong><span><br>' | trim}
{if (!$title || !$sub) && ($raw | preg_match : '~<h2[^>]*>~iu')}
  {set $h = $raw | preg_replace : '~^.*?<h2[^>]*>(.*?)</h2>.*$~isu' : '$1' | preg_replace : '~<br\s{0,3}/?>~iu' : ' ' | strip_tags | preg_replace : '~\s+~u' : ' ' | trim}
  {set $hTitle = $h | preg_replace : '~\s+[-–—]\s.*$~u' : '' | preg_replace : '~[\s?:–—-]+$~u' : '' | trim}
  {set $hSub = ($h | preg_match : '~\s[-–—]\s+\S~u') ? ($h | preg_replace : '~^.*?\s[-–—]\s+~u' : '' | preg_replace : '~[\s?]+$~u' : '' | trim) : ''}
  {if !$title}{set $title = $hTitle | preg_replace : '~^(Що таке|Что такое)\s+(.+)$~iu' : '$1 <span>$2</span>'}{/if}
  {if !$sub && $hSub}{set $sub = $.php.mb_strtoupper($.php.mb_substr($hSub, 0, 1)) ~ $.php.mb_substr($hSub, 1)}{/if}
{/if}

{* длина самого длинного слова заголовка — для уменьшения кегля (CSS) *}
{set $longest = 0}
{foreach ($title | strip_tags | preg_split : '/\s+/u') as $w}
  {set $len = $w | length}
  {if $len > $longest}{set $longest = $len}{/if}
{/foreach}

{set $card = $r['what_card'] | strip_tags : '<p><b><strong><span><br>' | trim}
{set $statLabel = $r['what_stat_label'] | strip_tags | trim}
{set $statValue = $r['what_stat_value'] | strip_tags | trim}

{* --- пункты: куски text-bl11 после каждого <h3> --- *}
{set $parts = $raw | preg_split : '~<h3[^>]*>~iu'}
{set $icons = [
  '<rect x="2.5" y="3.5" width="19" height="13" rx="3" pathLength="1"/><path d="M7.5 20.6c1.4-.6 2.9-.9 4.5-.9s3.1.3 4.5.9" pathLength="1"/>',
  '<circle cx="12" cy="12" r="6.5" pathLength="1"/><circle cx="12" cy="12" r="2.3" pathLength="1"/><path d="M12 2.5v3.2M12 18.3v3.2M2.5 12h3.2M18.3 12h3.2" pathLength="1"/>'
]}

<section class="rd-what" id="what" data-rd-what>
  <div class="rd-container rd-what__grid">
    <div class="rd-what__main">
      {if $title}<h2 class="rd-what__title" style="--rd-longest: {$longest ?: 8}">{$title}</h2>{/if}
      {if $sub}<p class="rd-what__sub">{$sub}</p>{/if}

      {if $card}
        <div class="rd-what__card">
          <div class="rd-what__chart"{if $statValue} role="img" aria-label="{$statLabel} {$statValue}"{/if}>
            <svg class="rd-what__rings" viewBox="0 0 200 200" aria-hidden="true">
              <defs>
                <linearGradient id="rd-what-g" x1="0" y1="0" x2="1" y2="1">
                  <stop offset="0" stop-color="#bfa660"/><stop offset="1" stop-color="#bfab73"/>
                </linearGradient>
              </defs>
              <circle class="rd-what__track" cx="100" cy="100" r="93"/>
              <circle class="rd-what__track" cx="100" cy="100" r="77"/>
              <circle class="rd-what__track" cx="100" cy="100" r="60"/>
              <circle class="rd-what__arc rd-what__arc--1" cx="100" cy="100" r="93" pathLength="1" style="--v: .83"/>
              <circle class="rd-what__arc rd-what__arc--2" cx="100" cy="100" r="77" pathLength="1" style="--v: .7"/>
              <circle class="rd-what__arc rd-what__arc--3" cx="100" cy="100" r="60" pathLength="1" style="--v: .62"/>
            </svg>
            {if $statValue}
              <span class="rd-what__stat" aria-hidden="true">
                {if $statLabel}<span class="rd-what__stat-label">{$statLabel}</span>{/if}
                <span class="rd-what__stat-value">{$statValue}</span>
              </span>
            {/if}
          </div>
          <div class="rd-what__card-text">{$card}</div>
        </div>
      {/if}
    </div>

    <div class="rd-what__items">
      {set $n = 0}
      {foreach $parts as $i => $part}
        {if $i > 0}
          {set $itTitle = $part | preg_replace : '~</h3>.*$~isu' : '' | strip_tags : '<br>' | trim}
          {set $itText = $part | preg_replace : '~^.*?</h3>~isu' : '' | strip_tags : '<p><b><strong><br><ul><ol><li><a>' | preg_replace : '~<p>\s{0,9}</p>~u' : '' | trim}
          {if $itTitle || $itText}
            <div class="rd-what__item" style="--i: {$n}">
              <div class="rd-what__head">
                <span class="rd-what__pill" aria-hidden="true">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round">{$icons[$n % 2]}</svg>
                </span>
                {if $itTitle}<h3 class="rd-what__item-title">{$itTitle}</h3>{/if}
              </div>
              {if $itText}<div class="rd-what__item-text">{$itText}</div>{/if}
            </div>
            {set $n = $n + 1}
          {/if}
        {/if}
      {/foreach}
    </div>
  </div>
</section>
