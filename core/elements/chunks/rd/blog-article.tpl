{*
  Редизайн: статья блога (шаблон 5 «Блог - статья»). Заменяет чанк content-blog. Макета нет — язык сайта.
  Шапка: крошки (Головна / Блог / раздел), раздел «таблеткой», заголовок, описание (blog-item-description), строка
  мета: автор (как раньше — Ігор Кобилянський), дата, время чтения (по числу слов), просмотры ([[!HitsPage]] —
  счётчик, как раньше), отзывы ([[!ecMessagesCount]] — ссылка на форму); справа превью статьи (blog-item-image) —
  в своём размере (превью 400×222, растягивать нельзя).
  Текст: колонка для чтения + справа колонка: «Зміст» (rd.js собирает из <h2> текста; меньше трёх — нет),
  «Популярні публікації» (5 статей блога по просмотрам) и «Останні публікації» (3 по дате, как в старом сайдбаре —
  из всех разделов блога), ниже — липкая карточка «Обговорити проект». Сверху — золотая полоска прочитанного (rd.js).
  После текста: автор, «Попередня / Наступна» (в том же разделе по дате публикации), отзывы easyComm (ecForm +
  ecMessages — те же вызовы и шаблоны, что раньше), FAQ (faq.tpl, если есть migx_questions), «Читайте також» —
  3 статьи раздела по просмотрам (карточки списка блога).
  Видео в тексте ([[*video-1]] → <div class="youtube-player" data-id>) — старый main.js, оформление — _art.scss.
  Разметка schema.org Article сохранена (headline, author, datePublished, image, publisher, genre, articleBody).
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $home = $_modx->config.site_start}
{set $cat = $r.parent}
{set $root = $cat ? ($cat | resource : 'parent') : 0}
{set $t = $isRu
  ? ['home' => 'Главная', 'crumbs' => 'Навигация по разделам', 'author' => 'Игорь Кобылянский', 'pos' => 'Основатель студии', 'min' => 'мин чтения',
     'views' => 'Просмотры', 'reviews' => 'Отзывы', 'toc' => 'Содержание', 'cta' => 'Нужна помощь <span>с сайтом</span>?', 'ctaText' => 'Расскажите о задаче — обсудим решение и сроки',
     'ctaBtn' => 'Обсудить проект', 'prev' => 'Предыдущая статья', 'next' => 'Следующая статья', 'rev' => 'Отзывы <span>о статье</span>',
     'more' => 'Читайте <span>также</span>', 'read' => 'Читать', 'popular' => 'Популярные публикации', 'latest' => 'Последние публикации', 'aboutAuthor' => 'Автор статьи', 'authorText' => 'Основатель digital-агентства Impulse Design. Пишет о создании, продвижении и развитии сайтов.']
  : ['home' => 'Головна', 'crumbs' => 'Навігація по розділах', 'author' => 'Ігор Кобилянський', 'pos' => 'Засновник студії', 'min' => 'хв читання',
     'views' => 'Перегляди', 'reviews' => 'Відгуки', 'toc' => 'Зміст', 'cta' => 'Потрібна допомога <span>з сайтом</span>?', 'ctaText' => 'Розкажіть про задачу — обговоримо рішення та терміни',
     'ctaBtn' => 'Обговорити проект', 'prev' => 'Попередня стаття', 'next' => 'Наступна стаття', 'rev' => 'Відгуки <span>про статтю</span>',
     'more' => 'Читайте <span>також</span>', 'read' => 'Читати', 'popular' => 'Популярні публікації', 'latest' => 'Останні публікації', 'aboutAuthor' => 'Автор статті', 'authorText' => 'Засновник digital-агентства Impulse Design. Пише про створення, просування та розвиток сайтів.']}

{* превью: значение — от папки источника «Blog» (images/blog/), бывает с «/» в начале *}
{set $pic = $r['blog-item-image'] | trim}
{if $pic && !($pic | preg_match : '~^(https?:)?//~')}
  {set $pic = $pic | preg_replace : '~^/+~' : ''}
  {if !($pic | preg_match : '~^(images|assets|img)/~')}{set $pic = 'images/blog/' ~ $pic}{/if}
  {set $pic = '/' ~ ($pic | preg_replace : '~/{2,}~' : '/')}
{/if}
{set $desc = $r['blog-item-description'] | strip_tags | trim}
{* дата публикации — метка времени (у ресурса бывает строкой «2022-08-29 15:00:00») *}
{set $pub = $r.publishedon}
{if !($pub | preg_match : '~^\d+$~')}{set $pub = $.php.strtotime($pub)}{/if}
{set $edit = $r.editedon}
{if $edit && !($edit | preg_match : '~^\d+$~')}{set $edit = $.php.strtotime($edit)}{/if}
{* время чтения: ~180 слов в минуту *}
{set $words = $r.content | strip_tags | preg_split : '~\s+~u' | length}
{set $mins = $.php.max(1, $.php.ceil($words / 180))}

{* кнопка «Обговорити проект» — как у первого экрана главной своего контекста *}
{set $ctaUrl = $home | resource : 'link-left-banner'}
{if $ctaUrl && ($ctaUrl | preg_match : '/^\d+$/')}{set $ctaUrl = $ctaUrl | url}{/if}

{* соседние статьи раздела по дате публикации *}
{set $prev = $_modx->getResources(['parent' => $cat, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0, 'publishedon:<' => $pub, 'id:!=' => $r.id],
  ['sortby' => ['publishedon' => 'DESC', 'id' => 'DESC'], 'limit' => 1, 'select' => 'id,pagetitle'])}
{set $next = $_modx->getResources(['parent' => $cat, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0, 'publishedon:>' => $pub, 'id:!=' => $r.id],
  ['sortby' => ['publishedon' => 'ASC', 'id' => 'ASC'], 'limit' => 1, 'select' => 'id,pagetitle'])}
{* сайдбар: популярные (по просмотрам) и последние (по дате) — из всех разделов блога (TV blog-category-list корня) *}
{set $blogCats = []}
{set $bcl = $root ? (($root | resource : 'blog-category-list') | trim) : ''}
{if $bcl}
  {set $bclParts = $bcl | preg_split : '~\s{0,9},\s{0,9}~'}
  {foreach $bclParts as $bc}{if $bc | preg_match : '~^\d+$~'}{set $blogCats = $.php.array_merge($blogCats, [$bc + 0])}{/if}{/foreach}
{/if}
{if !$blogCats}{set $blogCats = [$cat]}{/if}
{set $sideWhere = ['parent:IN' => $blogCats, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0, 'id:!=' => $r.id]}
{set $popular = $_modx->getResources($sideWhere, ['sortby' => ['publishedon' => 'DESC'], 'sortbyTV' => 'HitsPage', 'sortbyTVType' => 'integer', 'sortdirTV' => 'DESC',
  'limit' => 5, 'select' => 'id,pagetitle,publishedon', 'includeTVs' => 'blog-item-image,HitsPage', 'tvPrefix' => '', 'prepareTVs' => 0])}
{set $latest = $_modx->getResources($sideWhere, ['sortby' => ['publishedon' => 'DESC', 'id' => 'DESC'],
  'limit' => 3, 'select' => 'id,pagetitle,publishedon', 'includeTVs' => 'blog-item-image,HitsPage', 'tvPrefix' => '', 'prepareTVs' => 0])}

{* «Читайте також»: 3 статьи раздела по просмотрам *}
{set $more = $_modx->getResources(['parent' => $cat, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0, 'id:!=' => $r.id], [
  'sortby' => ['publishedon' => 'DESC'], 'sortbyTV' => 'HitsPage', 'sortbyTVType' => 'integer', 'sortdirTV' => 'DESC', 'limit' => 3,
  'select' => 'id,pagetitle,parent', 'includeTVs' => 'blog-item-image,blog-item-description,HitsPage', 'tvPrefix' => '', 'prepareTVs' => 0])}

<div class="rd-art__progress" aria-hidden="true"><span data-rd-progress></span></div>

<article class="rd-art" itemscope itemtype="https://schema.org/Article">
  <meta itemprop="mainEntityOfPage" content="{$r.id | url : ['scheme' => 'full']}">
  <meta itemprop="inLanguage" content="{$isRu ? 'ru' : 'uk'}">
  <meta itemprop="datePublished" content="{$pub | date : 'c'}">
  <meta itemprop="dateModified" content="{($edit ?: $pub) | date : 'c'}">
  <div itemprop="publisher" itemscope itemtype="https://schema.org/Organization" hidden>
    <div itemprop="logo" itemscope itemtype="https://schema.org/ImageObject">
      <meta itemprop="url" content="{$_modx->config.site_url | replace : '/ua/' : '/'}images/design/logo-schema.jpg">
      <meta itemprop="width" content="190">
      <meta itemprop="height" content="36">
    </div>
    <meta itemprop="name" content="{$_modx->config.site_name}">
  </div>

  {* ----- шапка ----- *}
  <section class="rd-art__top">
    <div class="rd-container">
      <nav class="rd-crumbs rd-crumbs--light rd-art__crumbs" aria-label="{$t.crumbs}">
        <ol class="rd-crumbs__list" itemscope itemtype="https://schema.org/BreadcrumbList">
          <li class="rd-crumbs__item" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <a class="rd-crumbs__link" href="{$home | url}" itemprop="item"><span itemprop="name">{$t.home}</span></a>
            <meta itemprop="position" content="1">
          </li>
          {if $root}
            <li class="rd-crumbs__item" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
              <a class="rd-crumbs__link" href="{$root | url}" itemprop="item"><span itemprop="name">{($root | resource : 'menutitle') ?: ($root | resource : 'pagetitle')}</span></a>
              <meta itemprop="position" content="2">
            </li>
          {/if}
          {if $cat}
            <li class="rd-crumbs__item rd-crumbs__item--current" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
              <a class="rd-crumbs__link" href="{$cat | url}" itemprop="item"><span itemprop="name">{($cat | resource : 'menutitle') ?: ($cat | resource : 'pagetitle')}</span></a>
              <meta itemprop="position" content="{$root ? 3 : 2}">
            </li>
          {/if}
        </ol>
      </nav>

      <div class="rd-art__head{if !$pic} rd-art__head--nopic{/if}">
        <div class="rd-art__intro">
          {if $cat}<a class="rd-art__cat" href="{$cat | url}" itemprop="genre">{$cat | resource : 'pagetitle'}</a>{/if}
          <h1 class="rd-art__title" itemprop="headline">{$r.pagetitle}</h1>
          {if $desc}<p class="rd-art__lead" itemprop="description">{$desc}</p>{/if}
          <div class="rd-art__meta">
            <span class="rd-art__author" itemprop="author" itemscope itemtype="https://schema.org/Person">
              <img src="/img/article/igor2.png" width="44" height="44" alt="" loading="eager">
              <span><b itemprop="name">{$t.author}</b><span>{$t.pos}</span></span>
              <meta itemprop="url" content="{$_modx->config.site_url}">
            </span>
            <span class="rd-art__fact">
              <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3.5" y="5" width="17" height="15.5" rx="2.5"/><path d="M8 3v4M16 3v4M3.5 10h17"/></svg>
              <time datetime="{$pub | date : 'Y-m-d'}">{$pub | date : 'd.m.Y'}</time>
            </span>
            <span class="rd-art__fact">
              <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9.5"/><path d="M12 6.5V12l3.5 2"/></svg>
              {$mins} {$t.min}
            </span>
            <span class="rd-art__fact" title="{$t.views}">
              <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg>
              [[!HitsPage? &saveTv=`true`]]
            </span>
            <a class="rd-art__fact rd-art__fact--link" href="{$r.id | url}#rev" title="{$t.reviews}">
              <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20.5 14.5a2 2 0 0 1-2 2H8l-4.5 4V5.5a2 2 0 0 1 2-2h13a2 2 0 0 1 2 2z"/></svg>
              [[!ecMessagesCount]]
            </a>
          </div>
        </div>
        {if $pic}
          <div class="rd-art__cover" itemprop="image" itemscope itemtype="https://schema.org/ImageObject">
            <img src="{$pic}" width="400" height="222" alt="{$r.pagetitle | escape}" loading="eager" itemprop="url contentUrl">
          </div>
        {/if}
      </div>
    </div>
  </section>

  {* ----- текст и боковая колонка ----- *}
  <section class="rd-art__main">
    <div class="rd-container rd-art__wrap">
      <aside class="rd-art__aside">
        <details class="rd-art__toc" data-rd-toc hidden>
          <summary class="rd-art__toc-title">{$t.toc}</summary>
          <ol class="rd-art__toc-list"></ol>
        </details>
        {set $sides = [['list' => $popular, 'title' => $t.popular, 'mod' => 'popular'], ['list' => $latest, 'title' => $t.latest, 'mod' => 'latest']]}
        {foreach $sides as $side}
          {if $side.list}
            <div class="rd-art__side rd-art__side--{$side.mod}">
              <p class="rd-art__side-title">{$side.title}</p>
              <ul class="rd-art__side-list">
                {foreach $side.list as $sp}
                  {set $spi = $sp['blog-item-image'] | trim}
                  {if $spi && !($spi | preg_match : '~^(https?:)?//~')}
                    {set $spi = $spi | preg_replace : '~^/+~' : ''}
                    {if !($spi | preg_match : '~^(images|assets|img)/~')}{set $spi = 'images/blog/' ~ $spi}{/if}
                    {set $spi = '/' ~ ($spi | preg_replace : '~/{2,}~' : '/')}
                  {/if}
                  {set $spub = $sp.publishedon}
                  {if !($spub | preg_match : '~^\d+$~')}{set $spub = $.php.strtotime($spub)}{/if}
                  <li>
                    <a class="rd-art__side-link" href="{$sp.id | url}">
                      <span class="rd-art__side-img">{if $spi}<img src="{$spi}" width="400" height="222" alt="" loading="lazy" decoding="async">{/if}</span>
                      <span class="rd-art__side-text">
                        <span class="rd-art__side-name">{$sp.pagetitle}</span>
                        <span class="rd-art__side-meta">
                          {if $side.mod == 'popular'}
                            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg>{(($sp['HitsPage'] ?: 0) + 0) | number : 0 : ',' : ' '}
                          {else}
                            <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3.5" y="5" width="17" height="15.5" rx="2.5"/><path d="M8 3v4M16 3v4M3.5 10h17"/></svg>{$spub | date : 'd.m.Y'}
                          {/if}
                        </span>
                      </span>
                    </a>
                  </li>
                {/foreach}
              </ul>
            </div>
          {/if}
        {/foreach}
        <div class="rd-art__sticky">
          {if $ctaUrl}
            <div class="rd-art__cta">
              <p class="rd-art__cta-title">{$t.cta}</p>
              <p class="rd-art__cta-text">{$t.ctaText}</p>
              <a class="rd-btn rd-art__cta-btn" href="{$ctaUrl}" data-rd-discuss>
                {$t.ctaBtn}
                <span class="rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right.svg" width="24" height="24" alt="" loading="lazy"><img class="rd-arrow__b" src="{$img}arrow-up-right.svg" width="24" height="24" alt="" loading="lazy"></span>
              </a>
            </div>
          {/if}
        </div>
      </aside>

      <div class="rd-art__body">
        <div class="rd-art__content" itemprop="articleBody" data-rd-art>{$r.content}</div>

        {* автор *}
        <div class="rd-art__bio">
          <img class="rd-art__bio-photo" src="/img/article/igor2.png" width="120" height="120" alt="{$t.author}" loading="lazy">
          <div class="rd-art__bio-text">
            <p class="rd-art__bio-label">{$t.aboutAuthor}</p>
            <p class="rd-art__bio-name">{$t.author}</p>
            <p class="rd-art__bio-about">{$t.authorText}</p>
          </div>
        </div>

        {* соседние статьи *}
        {if $prev || $next}
          <nav class="rd-art__nav" aria-label="{$t.prev} / {$t.next}">
            {if $prev}
              <a class="rd-art__nav-link rd-art__nav-link--prev" href="{$prev[0].id | url}">
                <span class="rd-art__nav-label">← {$t.prev}</span>
                <span class="rd-art__nav-title">{$prev[0].pagetitle}</span>
              </a>
            {/if}
            {if $next}
              <a class="rd-art__nav-link rd-art__nav-link--next" href="{$next[0].id | url}">
                <span class="rd-art__nav-label">{$t.next} →</span>
                <span class="rd-art__nav-title">{$next[0].pagetitle}</span>
              </a>
            {/if}
          </nav>
        {/if}

        {* отзывы easyComm — те же вызовы, что у старой статьи *}
        <div class="rd-art__reviews" id="rev">
          <h2 class="rd-art__h">{$t.rev}</h2>
          [[!ecForm?
            &tplForm=`tpl.ecForm.Blog.2`
            &tplSuccess=`tpl.ecForm.Success.Blog`
            &tplNewEmailManager=`tpl.ecForm.New.Email.Manager.Blog`
            &tplUpdateEmailUser=`tpl.ecForm.Update.Email.User.Blog`
            &tplNewEmailUser=`tpl.ecForm.New.Email.User.Blog`
          ]]
          <div class="rd-art__messages">
            <div id="review"></div>
            [[!ecMessages? &limit=`80`]]
          </div>
        </div>
      </div>
    </div>
  </section>
</article>

{* FAQ статьи (migx_questions), если есть *}
{include 'file:chunks/rd/faq.tpl'}

{* «Читайте також» — карточки списка блога *}
{if $more}
  <section class="rd-art__more">
    <div class="rd-container">
      <h2 class="rd-art__more-title">{$t.more}</h2>
      <ul class="rd-art__more-grid">
        {foreach $more as $i => $s}
          {set $mp = $s['blog-item-image'] | trim}
          {if $mp && !($mp | preg_match : '~^(https?:)?//~')}
            {set $mp = $mp | preg_replace : '~^/+~' : ''}
            {if !($mp | preg_match : '~^(images|assets|img)/~')}{set $mp = 'images/blog/' ~ $mp}{/if}
            {set $mp = '/' ~ ($mp | preg_replace : '~/{2,}~' : '/')}
          {/if}
          {set $hits = ($s['HitsPage'] ?: 0) + 0}
          <li class="rd-post" style="--i: {$i}">
            <a class="rd-post__link" href="{$s.id | url}">
              <span class="rd-post__img">{if $mp}<img src="{$mp}" width="400" height="222" alt="{$s.pagetitle | escape}" loading="lazy" decoding="async">{/if}</span>
              <span class="rd-post__body">
                <span class="rd-post__meta">
                  <span class="rd-post__cat">{$cat | resource : 'pagetitle'}</span>
                  <span class="rd-post__views"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg>{$hits | number : 0 : ',' : ' '}</span>
                </span>
                <span class="rd-post__title">{$s.pagetitle}</span>
                {if $s['blog-item-description']}<span class="rd-post__text">{$s['blog-item-description'] | strip_tags | trim}</span>{/if}
                <span class="rd-post__more">
                  {$t.read}
                  <span class="rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt="" loading="lazy"><img class="rd-arrow__b" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt="" loading="lazy"></span>
                </span>
              </span>
            </a>
          </li>
        {/foreach}
      </ul>
    </div>
  </section>
{/if}
