{*
  Редизайн: блок «Сайти для бізнесу» (Mind Control 2.0) — section 10 макета главной.
  Поля (TV):
    title-bl3       — заголовок (золотое слово оберните в <span>)
    sub-title-bl3   — подзаголовок (можно <b>)
    img-bl3         — фото автора цитаты
    author-bl3      — имя автора, author-post-bl3 — должность
    quote-bl3       — цитата (золотые фрагменты оберните в <span>)
    text-bl3        — карточки на сером фоне: каждая начинается с заголовка <h3>, дальше абзацы.
                      Перенос в заголовке — <br>. Иконки идут по порядку: ступени, мишень (дальше повторяются).

  src='notice' — блок «Ми завжди йдемо Вам на зустріч» страницы услуги (section 6b макета, после цен): та же
  вёрстка без карточек, поля «заметки» блока 7:
    notice_title_bl7 — заголовок (золото — <span>); пусто — «Ми завжди йдемо Вам <span>на зустріч</span>»
    notice_text_bl7  — текст (richtext, можно <b>): первый абзац — под заголовком, остальные — мелко рядом с «таблеткой»
                       со стрелкой; если абзац один — делится после первого предложения
    notice_quote_bl7 — цитата (золото — <span>; без кавычек — “ ” ставятся сами); пусто — блока нет
    notice_img_bl7   — фото; пусто — фото автора с главной (img-bl3). Имя и должность — с главной (author-bl3 / author-post-bl3).
*}
{set $res = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $cards = []}
{set $note = ''}
{if $src == 'notice'}
  {set $home = $_modx->getResource($_modx->config.site_start, ['includeTVs' => 'img-bl3,author-bl3,author-post-bl3', 'tvPrefix' => ''])}
  {set $sid = 'notice'}
  {set $title = ($res['notice_title_bl7'] | trim) ?: ($isRu ? 'Мы всегда идём Вам <span>навстречу</span>' : 'Ми завжди йдемо Вам <span>на зустріч</span>')}
  {* текст: первый абзац — под заголовком, остальные — мелко рядом с «таблеткой»;
     один абзац — делится после первого предложения *}
  {set $paras = ($res['notice_text_bl7'] ?: '') | preg_replace : '~<p[^>]*>(\s|&nbsp;|\xC2\xA0)*</p>~iu' : '' | strip_tags : '<p><br><b><strong><a>' | trim}
  {if $paras | preg_match : '~^\s*<p[^>]*>.*?</p>\s*<p~isu'}
    {set $subHtml = $paras | preg_replace : '~^\s*(<p[^>]*>.*?</p>).*$~isu' : '$1'}
    {set $note = $paras | preg_replace : '~^\s*<p[^>]*>.*?</p>\s*~isu' : ''}
  {else}
    {set $one = $paras | preg_replace : '~</?p[^>]*>~iu' : '' | trim}
    {set $first = $one | preg_replace : '~^(.+?[.!?])\s+(?=\p{Lu}).*$~su' : '$1'}
    {set $note = $first == $one ? '' : ($one | preg_replace : '~^.+?[.!?]\s+(?=\p{Lu})~su' : '')}
    {set $subHtml = $first ? ('<p>' ~ $first ~ '</p>') : ''}
    {if $note}{set $note = '<p>' ~ $note ~ '</p>'}{/if}
  {/if}
  {set $quote = $res['notice_quote_bl7'] | trim}
  {if $quote && !($quote | preg_match : '~^[“"«„]~u')}{set $quote = '“' ~ $quote ~ '”'}{/if}{* цитата в кавычках, как в макете *}
  {set $photo = $res['notice_img_bl7'] ?: $home['img-bl3']}
  {set $author = $home['author-bl3'] | strip_tags}
  {set $post = $home['author-post-bl3'] | strip_tags}
{else}
  {set $sid = 'development'}
  {set $title = $res['title-bl3']}
  {set $subHtml = $res['sub-title-bl3'] ? ('<p>' ~ ($res['sub-title-bl3'] | strip_tags : '<b><strong><br><span>') ~ '</p>') : ''}
  {set $quote = $res['quote-bl3']}
  {set $photo = $res['img-bl3']}
  {set $author = $res['author-bl3'] | strip_tags}
  {set $post = $res['author-post-bl3'] | strip_tags}

  {* Карточки из text-bl3: делим по <h3>, пустые абзацы выбрасываем *}
  {set $parts = ($res['text-bl3'] ?: '') | preg_split : '~<h3[^>]*>~iu'}
  {foreach $parts as $part}
    {if $part | preg_match : '~</h3>~iu'}
      {set $cTitle = $part | preg_replace : '~</h3>.*$~isu' : '' | strip_tags : '<br><span>'}
      {set $cText = $part | preg_replace : '~^.*?</h3>~isu' : '' | preg_replace : '~<p[^>]*>(\s|&nbsp;|\xC2\xA0)*</p>~iu' : '' | strip_tags : '<p><br><b><strong><a><span>'}
      {set $cards = $.php.array_merge($cards, [['title' => $cTitle, 'text' => $cText | trim]])}
    {/if}
  {/foreach}
{/if}
{if $photo && !($photo | preg_match : '~^(https?:)?/~')}{set $photo = '/' ~ $photo}{/if}

{if $src != 'notice' || $quote}
<section class="rd-mind{if $src == 'notice'} rd-mind--notice{/if}" id="{$sid}">
  <div class="rd-container rd-mind__wrap">
    <div class="rd-mind__top">
      <div class="rd-mind__heading">
        {if $title}
          <h2 class="rd-mind__title">{$title | strip_tags : '<span><br>'}</h2>
        {/if}
        {if $subHtml}
          <div class="rd-mind__sub">{$subHtml}</div>
        {/if}
        {if $note}
          {* «таблетка» со стрелкой: на наведении заливается золотом слева, стрелка вылетает вверх и приходит снизу *}
          <div class="rd-mind__note">
            <span class="rd-mind__pill" aria-hidden="true">
              <span class="rd-mind__pill-fill"></span>
              <svg class="rd-mind__pill-svg" width="40" height="40" viewBox="0 0 24 24" fill="none">
                <defs><clipPath id="rd-notice-clip"><circle cx="12" cy="12" r="11"/></clipPath></defs>
                <g stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
                  <path class="rd-mind__pill-ring" pathLength="1" d="M7 20.662A10 10 0 0 1 2 12C2 6.477 6.477 2 12 2s10 4.477 10 10a10 10 0 0 1-5 8.662"/>
                  <g clip-path="url(#rd-notice-clip)">
                    <path class="rd-mind__pill-arrow" d="M16 12l-4-4m0 0-4 4m4-4v14"/>
                    <path class="rd-mind__pill-arrow rd-mind__pill-arrow--b" d="M16 12l-4-4m0 0-4 4m4-4v14"/>
                  </g>
                </g>
              </svg>
            </span>
            <div class="rd-mind__note-text">{$note}</div>
          </div>
        {/if}
      </div>

      {if $quote}
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
          <blockquote class="rd-mind__quote"><p>{$quote | strip_tags : '<span><b><strong><br>'}</p></blockquote>
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
{/if}
