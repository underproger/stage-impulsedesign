{*
  Редизайн: блок «Сайти для бізнесу» (Mind Control 2.0) — section 10 макета.
  Поля (TV):
    title-bl3       — заголовок (золотое слово оберните в <span>)
    sub-title-bl3   — подзаголовок (можно <b>)
    img-bl3         — фото автора цитаты
    author-bl3      — имя автора, author-post-bl3 — должность
    quote-bl3       — цитата (золотые фрагменты оберните в <span>)
    text-bl3        — карточки на сером фоне: каждая начинается с заголовка <h3>, дальше абзацы.
                      Перенос в заголовке — <br>. Иконки идут по порядку: ступени, мишень (дальше повторяются).
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $photo = $r['img-bl3']}
{if $photo && !($photo | preg_match : '~^(https?:)?/~')}{set $photo = '/' ~ $photo}{/if}
{set $author = $r['author-bl3'] | strip_tags}
{set $post = $r['author-post-bl3'] | strip_tags}

{* Карточки из text-bl3: делим по <h3>, пустые абзацы выбрасываем *}
{set $cards = []}
{set $parts = ($r['text-bl3'] ?: '') | preg_split : '~<h3[^>]*>~iu'}
{foreach $parts as $part}
  {if $part | preg_match : '~</h3>~iu'}
    {set $cTitle = $part | preg_replace : '~</h3>.*$~isu' : '' | strip_tags : '<br><span>'}
    {set $cText = $part | preg_replace : '~^.*?</h3>~isu' : '' | preg_replace : '~<p[^>]*>(\s|&nbsp;|\xC2\xA0)*</p>~iu' : '' | strip_tags : '<p><br><b><strong><a><span>'}
    {set $cards = $.php.array_merge($cards, [['title' => $cTitle, 'text' => $cText | trim]])}
  {/if}
{/foreach}

<section class="rd-mind" id="development">
  <div class="rd-container rd-mind__wrap">
    <div class="rd-mind__top">
      <div class="rd-mind__heading">
        {if $r['title-bl3']}
          <h2 class="rd-mind__title">{$r['title-bl3'] | strip_tags : '<span><br>'}</h2>
        {/if}
        {if $r['sub-title-bl3']}
          <p class="rd-mind__sub">{$r['sub-title-bl3'] | strip_tags : '<b><strong><br><span>'}</p>
        {/if}
      </div>

      {if $r['quote-bl3']}
        <figure class="rd-mind__say">
          {if $photo || $author}
            <figcaption class="rd-mind__person">
              {if $photo}
                <span class="rd-mind__photo"><img src="{$photo}" width="992" height="535" alt="{$author}" loading="lazy" decoding="async"></span>
              {/if}
              {if $author || $post}
                <span class="rd-mind__who">
                  {if $author}<b class="rd-mind__name">{$author}</b>{/if}
                  {if $post}<span class="rd-mind__post">{$post}</span>{/if}
                </span>
              {/if}
            </figcaption>
          {/if}
          <blockquote class="rd-mind__quote"><p>{$r['quote-bl3'] | strip_tags : '<span><b><strong><br>'}</p></blockquote>
        </figure>
      {/if}
    </div>

    {if $cards}
      <div class="rd-mind__cards">
        {foreach $cards as $i => $c}
          <article class="rd-mind-card">
            <div class="rd-mind-card__head">
              <span class="rd-mind-card__icon" aria-hidden="true">
                <span class="rd-mind-card__fill"></span>
                {if $i % 2 == 0}
                  {* ступени: квадратики «поднимаются» по лестнице *}
                  <svg class="rd-mind-card__svg rd-mind-card__svg--steps" width="40" height="40" viewBox="0 0 24 24" fill="none">
                    <g stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
                      <path class="rd-mind-ic rd-mind-ic--a" pathLength="1" d="M2.8 2h2.4a.8.8 0 0 1 .8.8v2.4a.8.8 0 0 1-.8.8h-2.4a.8.8 0 0 1-.8-.8v-2.4a.8.8 0 0 1 .8-.8z"/>
                      <path class="rd-mind-ic rd-mind-ic--b" pathLength="1" d="M10.8 6h2.4a.8.8 0 0 1 .8.8v2.4a.8.8 0 0 1-.8.8h-2.4a.8.8 0 0 1-.8-.8v-2.4a.8.8 0 0 1 .8-.8z"/>
                      <path class="rd-mind-ic rd-mind-ic--c" pathLength="1" d="M3.8 12h2.4a.8.8 0 0 1 .8.8v2.4a.8.8 0 0 1-.8.8h-2.4a.8.8 0 0 1-.8-.8v-2.4a.8.8 0 0 1 .8-.8z"/>
                      <path class="rd-mind-ic rd-mind-ic--d" pathLength="1" d="M10 18h4v-4h4v-4h4v12H10z"/>
                    </g>
                  </svg>
                {else}
                  {* мишень: стрела влетает в центр *}
                  <svg class="rd-mind-card__svg rd-mind-card__svg--target" width="40" height="40" viewBox="0 0 24 24" fill="none">
                    <g stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
                      <path class="rd-mind-ic rd-mind-ic--a" pathLength="1" d="M22 12c0 5.523-4.477 10-10 10S2 17.523 2 12 6.477 2 12 2"/>
                      <path class="rd-mind-ic rd-mind-ic--b" pathLength="1" d="M17 12a5 5 0 1 1-5-5"/>
                      <g class="rd-mind-ic rd-mind-ic--arrow"><path d="M16 8V5l3-3 1 2 2 1-3 3h-3zm0 0-4 4"/></g>
                    </g>
                  </svg>
                {/if}
              </span>
              <h3 class="rd-mind-card__title">{$c.title}</h3>
            </div>
            {if $c.text}<div class="rd-mind-card__text">{$c.text}</div>{/if}
          </article>
        {/foreach}
      </div>
    {/if}
  </div>
</section>
