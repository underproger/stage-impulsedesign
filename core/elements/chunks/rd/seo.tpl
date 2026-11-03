{*
  Редизайн: SEO-текст главной «Створення сайтів у Києві та Україні» — section 9 макета.
  Заменяет старый чанк bl9-seo-hidden (выводится, как и он, когда у страницы заполнен «Содержимое»).
  Поля:
    title-bl9 — заголовок блока (золотое слово — в <span>; между короткими словами — &nbsp;).
                Пусто — заголовком станет первый заголовок из «Содержимого».
    content   — текст: первый абзац виден сразу, остальное раскрывается кнопкой «Розгорнути».
                Если текст начинается с заголовка, он уходит в раскрывающуюся часть (перед вторым абзацем).
  Страницы услуг без «Содержимого» (шаблон 21, чекбокс display_bl9): текст собирается из старых полей блока 9 —
  text_1-bl9 (вступление), title_2-bl9 + seo-bl9 (вкладки «Наша компанія пропонує»: заголовок вкладки — <h3>, если текст
  вкладки сам не начинается с заголовка), text_2-bl9 (окончание). Заголовка нет — заголовок страницы (pagetitle).
  Абзацы, где только картинка, в начале текста не становятся вступлением — уходят в раскрывающуюся часть.
  Справа (на мобайле — под текстом) — золотой икосаэдр: WebGL (src/ico.js в rd-blob.js), картинка — заглушка.
  img-seo — картинка справа вместо икосаэдра (страница портфолио); тогда абзацы-картинки в начале текста не выводятся
  (это старые картинки «справа от текста»). Заголовок из title-bl9 повторяется в тексте — повтор убирается.
  Параметры include: intro=2 — сколько абзацев видно до «Розгорнути» (по умолчанию 1), tone='gray' — светло-серый фон.
  Раскрытие — rd.js, анимации — rd-wow.js.
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $introN = $intro ?: 1}
{set $photo = $r['img-seo'] | trim}
{if $photo && !($photo | preg_match : '~^(https?:)?/~')}{set $photo = '/' ~ $photo}{/if}
{set $c = $r.content | trim}
{if !$c && $r['display_bl9']}
  {set $c = $r['text_1-bl9'] | trim}
  {set $tabs = $r['seo-bl9'] ? ($r['seo-bl9'] | json_decode : true) : []}
  {if $tabs}
    {set $t2 = $r['title_2-bl9'] | strip_tags | trim | preg_replace : '~\s*:$~u' : ''}
    {if $t2}{set $c = $c ~ '<h2>' ~ $t2 ~ '</h2>'}{/if}
    {foreach $tabs as $tab}
      {set $tt = $tab.text | trim}
      {if $tab.title && !($tt | preg_match : '~^<h[1-6]~iu')}{set $tt = '<h3>' ~ ($tab.title | strip_tags | trim) ~ '</h3>' ~ $tt}{/if}
      {set $c = $c ~ $tt}
    {/foreach}
  {/if}
  {set $c = ($c ~ ($r['text_2-bl9'] ?: '')) | trim}
{/if}
{set $title = $r['title-bl9'] | trim}
{set $head = ''}
{if $c | preg_match : '~^\s*<h[1-6][^>]*>.*?</h[1-6]>~isu'}
  {set $head = $c | preg_replace : '~^\s*(<h[1-6][^>]*>.*?</h[1-6]>).*$~isu' : '$1'}
  {set $c = $c | preg_replace : '~^\s*<h[1-6][^>]*>.*?</h[1-6]>~isu' : '' | trim}
  {if !$title}
    {set $title = $head | strip_tags | trim}
    {set $head = ''}
  {/if}
{/if}
{* абзацы только с картинкой в начале — в раскрывающуюся часть *}
{set $pics = ''}
{if $c | preg_match : '~^(<p[^>]*>\s*(<img[^>]*>\s*)+</p>\s*)+~isu'}
  {set $pics = $c | preg_replace : '~^((?:<p[^>]*>\s*(?:<img[^>]*>\s*)+</p>\s*)+).*$~isu' : '$1'}
  {set $c = $c | preg_replace : '~^(?:<p[^>]*>\s*(?:<img[^>]*>\s*)+</p>\s*)+~isu' : '' | trim}
{/if}
{if $photo}{set $pics = ''}{/if}
{if !$title}{set $title = $r.pagetitle}{/if}
{* заголовок блока, повторённый в тексте (<h2>5 причин…</h2> при title-bl9 «5 причин…»), — убираем повтор *}
{set $tplain = $title | strip_tags | preg_replace : '~&nbsp;|\s+~u' : ' ' | trim}
{if $tplain}
  {set $tq = $.php.preg_quote($tplain, '~') | preg_replace : '~ ~u' : '(?:\s|&nbsp;)+'}
  {set $c = $c | preg_replace : ('~<h[1-6][^>]*>\s*' ~ $tq ~ '\s*</h[1-6]>~iu') : '' | trim}
{/if}
{set $intro = ''}
{set $introP = []}
{for $k=1 to=$introN}
  {if $c | preg_match : '~^<p[^>]*>.*?</p>~isu'}
    {set $ip = $c | preg_replace : '~^<p[^>]*>(.*?)</p>.*$~isu' : '$1' | trim}
    {set $c = $c | preg_replace : '~^<p[^>]*>.*?</p>~isu' : '' | trim}
    {* однобуквенные предлоги и союзы не остаются в конце строки *}
    {set $ip = $ip | preg_replace : '~(^|[\s(«„“])([вуізаоксВУІЗАОКС])\s+~u' : '$1$2&nbsp;'}
    {set $introP = $.php.array_merge($introP, [$ip])}
  {/if}
{/for}
{set $intro = $introP[0] ?: ''}
{set $rest = $head ~ $pics ~ $c}
{set $rest = $rest | trim}

<section class="rd-seo{if $photo} rd-seo--photo{/if}{if $tone == 'gray'} rd-seo--gray{/if}" id="seo-text" data-rd-seo>
  <div class="rd-container rd-seo__wrap">
    <div class="rd-seo__body">
      {if $title}<h2 class="rd-seo__title">{$title | strip_tags : '<span><br>'}</h2>{/if}
      {if $introP | length > 1}
        <div class="rd-seo__intro">{foreach $introP as $ip}<p>{$ip}</p>{/foreach}</div>
      {elseif $intro}
        <p class="rd-seo__intro">{$intro}</p>
      {/if}
      {if $rest}
        <div class="rd-seo__more" id="rd-seo-more">
          <div class="rd-seo__more-in">
            <div class="rd-seo__text">{$rest}</div>
          </div>
        </div>
        <button class="rd-seo__toggle" type="button" aria-expanded="false" aria-controls="rd-seo-more"
          data-open="{$isRu ? 'Свернуть' : 'Згорнути'}">
          <span class="rd-seo__toggle-text">{$isRu ? 'Развернуть' : 'Розгорнути'}</span>
          <span class="rd-seo__arrow rd-seo__arrow--down rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="/assets/templates/rd/img/arrow-down-right-gold.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="/assets/templates/rd/img/arrow-down-right-gold.svg" width="24" height="24" alt=""></span>
          <span class="rd-seo__arrow rd-seo__arrow--up rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="/assets/templates/rd/img/arrow-up-left-gold.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="/assets/templates/rd/img/arrow-up-left-gold.svg" width="24" height="24" alt=""></span>
        </button>
      {/if}
    </div>
    {if $photo}
      <div class="rd-seo__obj rd-seo__obj--photo" aria-hidden="true">
        <img class="rd-seo__photo" src="{$photo}" width="1000" height="1500" alt="" loading="lazy" decoding="async">
      </div>
    {else}
      <div class="rd-seo__obj" data-rd-ico data-src="/assets/templates/rd/js/rd-blob.js?v={$.php.filemtime($.const.MODX_ASSETS_PATH ~ 'templates/rd/js/rd-blob.js')}" aria-hidden="true">
        <div class="rd-seo__float">
          <img class="rd-seo__img" src="/assets/templates/rd/img/ico.webp" width="600" height="600" alt="">
        </div>
      </div>
    {/if}
  </div>
</section>
