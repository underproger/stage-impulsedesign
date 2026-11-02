{*
  Редизайн: SEO-текст главной «Створення сайтів у Києві та Україні» — section 9 макета.
  Заменяет старый чанк bl9-seo-hidden (выводится, как и он, когда у страницы заполнен «Содержимое»).
  Поля:
    title-bl9 — заголовок блока (золотое слово — в <span>; между короткими словами — &nbsp;).
                Пусто — заголовком станет первый заголовок из «Содержимого».
    content   — текст: первый абзац виден сразу, остальное раскрывается кнопкой «Розгорнути».
                Если текст начинается с заголовка, он уходит в раскрывающуюся часть (перед вторым абзацем).
  Справа (на мобайле — под текстом) — золотой икосаэдр: WebGL (src/ico.js в rd-blob.js), картинка — заглушка.
  Раскрытие — rd.js, анимации — rd-wow.js.
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $c = $r.content | trim}
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
{set $intro = ''}
{if $c | preg_match : '~^<p[^>]*>.*?</p>~isu'}
  {set $intro = $c | preg_replace : '~^<p[^>]*>(.*?)</p>.*$~isu' : '$1' | trim}
  {set $c = $c | preg_replace : '~^<p[^>]*>.*?</p>~isu' : '' | trim}
  {* однобуквенные предлоги и союзы не остаются в конце строки *}
  {set $intro = $intro | preg_replace : '~(^|[\s(«„“])([вуізаоксВУІЗАОКС])\s+~u' : '$1$2&nbsp;'}
{/if}
{set $rest = $head ~ $c}
{set $rest = $rest | trim}

<section class="rd-seo" id="seo-text" data-rd-seo>
  <div class="rd-container rd-seo__wrap">
    <div class="rd-seo__body">
      {if $title}<h2 class="rd-seo__title">{$title | strip_tags : '<span><br>'}</h2>{/if}
      {if $intro}<p class="rd-seo__intro">{$intro}</p>{/if}
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
    <div class="rd-seo__obj" data-rd-ico data-src="/assets/templates/rd/js/rd-blob.js?v={$.php.filemtime($.const.MODX_ASSETS_PATH ~ 'templates/rd/js/rd-blob.js')}" aria-hidden="true">
      <div class="rd-seo__float">
        <img class="rd-seo__img" src="/assets/templates/rd/img/ico.webp" width="600" height="600" alt="">
      </div>
    </div>
  </div>
</section>
