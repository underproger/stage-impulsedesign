{*
  Редизайн: список статей блога (шаблон 4 «Блог - список статей»): корень блога (UA 448 /ua/blog-statti.html,
  RU 194 /blog.html) и разделы (UA 452–457, RU 195, 196, 241, 250, 280, 298). Заменяет чанк content-blog-list.
  Макета нет — язык сайта: баннер — тёмная карточка с движущейся сеткой (как первый экран страницы услуги),
  справа — фото офиса (img blog-hero.webp, старый фон блога), гаснущее к тексту, золотое свечение; в баннере
  крошки, заголовок, подводка и «таблетки» разделов со счётчиками (настоящие страницы разделов; «Усі статті» — корень).
  Ниже — «N статей», переключатель «Популярні / Нові» и сетка одинаковых карточек: превью, раздел, просмотры,
  заголовок, описание, «Читати».
  Данные: разделы — TV blog-category-list корня (ID через запятую; пусто — дочерние корня); статьи — дочерние
  разделов (на странице раздела — только его), опубликованные и видимые в меню (как раньше), по просмотрам (HitsPage).
  Поля статьи: blog-item-image (источник «Blog»: images/blog/), blog-item-description, HitsPage.
  Все карточки — в HTML (для поиска); rd.js показывает по 12 до конца ряда («Показати ще»: data-rd-blog-more) и сортирует
  (data-rd-sort: hits / date). Анимации — rd-wow.js.
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $home = $_modx->config.site_start}
{set $isCat = $r.parent > 0}
{set $rootId = $isCat ? $r.parent : $r.id}
{set $t = $isRu
  ? ['home' => 'Главная', 'crumbs' => 'Навигация по разделам', 'title' => 'Блог веб-студии <span>Impulse Design</span>', 'blog' => 'Блог Impulse Design',
     'sub' => 'Всё, что Вы хотели знать про <span>запуск и масштабирование</span> Ваших бизнес-проектов в интернете', 'all' => 'Все статьи',
     'sections' => 'Разделы блога', 'popular' => 'Популярные', 'new' => 'Новые', 'sort' => 'Сортировка', 'more' => 'Показать ещё', 'read' => 'Читать',
     'views' => 'просмотров', 'n1' => 'статья', 'n2' => 'статьи', 'n5' => 'статей']
  : ['home' => 'Головна', 'crumbs' => 'Навігація по розділах', 'title' => 'Блог веб-студії <span>Impulse Design</span>', 'blog' => 'Блог Impulse Design',
     'sub' => 'Все, що Ви хочете знати про <span>запуск і масштабування</span> Ваших бізнес-проєктів в інтернеті', 'all' => 'Усі статті',
     'sections' => 'Розділи блогу', 'popular' => 'Популярні', 'new' => 'Нові', 'sort' => 'Сортування', 'more' => 'Показати ще', 'read' => 'Читати',
     'views' => 'переглядів', 'n1' => 'стаття', 'n2' => 'статті', 'n5' => 'статей']}

{* разделы: TV корня (ID через запятую), пусто — дочерние корня *}
{set $catList = ($rootId | resource : 'blog-category-list') | trim}
{set $catIds = []}
{if $catList}
  {set $catParts = $catList | preg_split : '~\s{0,9},\s{0,9}~'}
  {foreach $catParts as $cid}{if $cid | preg_match : '~^\d+$~'}{set $catIds = $.php.array_merge($catIds, [$cid + 0])}{/if}{/foreach}
{/if}
{if !$catIds}
  {set $kids = $_modx->getResources(['parent' => $rootId, 'published' => 1, 'deleted' => 0], ['sortby' => ['menuindex' => 'ASC'], 'limit' => 0, 'select' => 'id'])}
  {foreach $kids as $k}{set $catIds = $.php.array_merge($catIds, [$k.id])}{/foreach}
{/if}
{set $cats = $catIds ? $_modx->getResources(['id:IN' => $catIds, 'published' => 1, 'deleted' => 0], ['sortby' => ['menuindex' => 'ASC', 'id' => 'ASC'], 'limit' => 0, 'select' => 'id,pagetitle,menutitle']) : []}
{set $catName = []}
{set $catCount = []}
{set $total = 0}
{foreach $cats as $c}
  {set $cc = $_modx->getResources(['parent' => $c.id, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0], ['limit' => 0, 'select' => 'id']) | length}
  {set $catName = $.php.array_replace($catName, [$c.id => $c.pagetitle])}
  {set $catCount = $.php.array_replace($catCount, [$c.id => $cc])}
  {set $total = $total + $cc}
{/foreach}

{if $isCat}
  {set $where = ['published' => 1, 'deleted' => 0, 'hidemenu' => 0, 'parent' => $r.id]}
{else}
  {set $where = ['published' => 1, 'deleted' => 0, 'hidemenu' => 0, 'parent:IN' => ($catIds ?: [0])]}
{/if}
{set $items = $_modx->getResources($where, [
  'sortby' => ['publishedon' => 'DESC', 'id' => 'DESC'], 'sortbyTV' => 'HitsPage', 'sortbyTVType' => 'integer', 'sortdirTV' => 'DESC',
  'limit' => 0, 'select' => 'id,pagetitle,parent,publishedon',
  'includeTVs' => 'blog-item-image,blog-item-description,HitsPage', 'tvPrefix' => '', 'prepareTVs' => 0
])}
{set $n = $items | length}
{set $nWord = ($n % 10 == 1 && $n % 100 != 11) ? $t.n1 : (($n % 10 >= 2 && $n % 10 <= 4 && ($n % 100 < 10 || $n % 100 >= 20)) ? $t.n2 : $t.n5)}

<div class="rd-blog">
  {* ----- шапка ----- *}
  <section class="rd-blog__top">
    <div class="rd-blog__hero">
    <div class="rd-blog__bg" aria-hidden="true"><img src="{$img}blog-hero.webp" width="1920" height="915" alt="" fetchpriority="high" loading="eager"></div>
    <div class="rd-container rd-blog__hero-in">
      <nav class="rd-crumbs rd-blog__crumbs" aria-label="{$t.crumbs}">
        <ol class="rd-crumbs__list" itemscope itemtype="https://schema.org/BreadcrumbList">
          <li class="rd-crumbs__item" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <a class="rd-crumbs__link" href="{$home | url}" itemprop="item"><span itemprop="name">{$t.home}</span></a>
            <meta itemprop="position" content="1">
          </li>
          {if $isCat}
            <li class="rd-crumbs__item" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
              <a class="rd-crumbs__link" href="{$rootId | url}" itemprop="item"><span itemprop="name">{($rootId | resource : 'menutitle') ?: ($rootId | resource : 'pagetitle')}</span></a>
              <meta itemprop="position" content="2">
            </li>
          {/if}
          <li class="rd-crumbs__item rd-crumbs__item--current" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <span itemprop="name" aria-current="page">{$r.menutitle ?: $r.pagetitle}</span>
            <meta itemprop="item" content="{$r.id | url : ['scheme' => 'full']}">
            <meta itemprop="position" content="{$isCat ? 3 : 2}">
          </li>
        </ol>
      </nav>
      <div class="rd-blog__head">
        {if $isCat}<p class="rd-blog__eyebrow">{$t.blog}</p>{/if}
        <h1 class="rd-blog__title" data-rd-fit>{if $isCat}{$r.pagetitle}{else}{$t.title}{/if}</h1>
        <p class="rd-blog__sub">{$t.sub}</p>
      </div>

      {if $cats}
        <nav class="rd-blog__tabs" aria-label="{$t.sections}">
          <a class="rd-blog__tab{if !$isCat} is-active{/if}" href="{$rootId | url}"{if !$isCat} aria-current="page"{/if} style="--i: 0">
            <span>{$t.all}</span><sup class="rd-blog__tab-n">{$total}</sup>
          </a>
          {foreach $cats as $ci => $c}
            <a class="rd-blog__tab{if $c.id == $r.id} is-active{/if}" href="{$c.id | url}"{if $c.id == $r.id} aria-current="page"{/if} style="--i: {$ci + 1}">
              <span>{$c.pagetitle}</span><sup class="rd-blog__tab-n">{$catCount[$c.id]}</sup>
            </a>
          {/foreach}
        </nav>
      {/if}
    </div>
    </div>
  </section>

  {* ----- статьи ----- *}
  {if $items}
  <section class="rd-blog__list">
    <div class="rd-container">
      <div class="rd-blog__bar">
        <p class="rd-blog__count">{$n} {$nWord}</p>
        <div class="rd-blog__sort" role="group" aria-label="{$t.sort}" data-rd-blog-sort hidden>
          <button class="rd-blog__sort-btn is-active" type="button" data-rd-sort="hits" aria-pressed="true">{$t.popular}</button>
          <button class="rd-blog__sort-btn" type="button" data-rd-sort="date" aria-pressed="false">{$t.new}</button>
        </div>
      </div>

      <ul class="rd-blog__grid" data-rd-blog data-step="12">
        {foreach $items as $i => $s}
          {* превью: значение — от папки источника «Blog» (images/blog/), бывает с «/» в начале *}
          {set $pic = $s['blog-item-image'] | trim}
          {if $pic && !($pic | preg_match : '~^(https?:)?//~')}
            {set $pic = $pic | preg_replace : '~^/+~' : ''}
            {if !($pic | preg_match : '~^(images|assets|img)/~')}{set $pic = 'images/blog/' ~ $pic}{/if}
            {set $pic = '/' ~ ($pic | preg_replace : '~/{2,}~' : '/')}
          {/if}
          {set $hits = ($s['HitsPage'] ?: 0) + 0}
          {set $desc = $s['blog-item-description'] | strip_tags | trim}
          <li class="rd-post" data-hits="{$hits}" data-date="{$s.publishedon}" style="--i: {$i}">
            <a class="rd-post__link" href="{$s.id | url}">
              <span class="rd-post__img">{if $pic}<img src="{$pic}" width="400" height="222" alt="{$s.pagetitle | escape}" loading="{$i < 6 ? 'eager' : 'lazy'}" decoding="async">{/if}</span>
              <span class="rd-post__body">
                <span class="rd-post__meta">
                  {if $s.parent in list $catIds}<span class="rd-post__cat">{$catName[$s.parent]}</span>{/if}
                  <span class="rd-post__views"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg>{$hits | number : 0 : ',' : ' '}<span class="rd-sr"> {$t.views}</span></span>
                </span>
                <span class="rd-post__title">{$s.pagetitle}</span>
                {if $desc}<span class="rd-post__text">{$desc}</span>{/if}
                <span class="rd-post__more">
                  {$t.read}
                  <span class="rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt="" loading="lazy"><img class="rd-arrow__b" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt="" loading="lazy"></span>
                </span>
              </span>
            </a>
          </li>
        {/foreach}
      </ul>
      <div class="rd-blog__foot">
        <button class="rd-btn rd-btn--dark rd-blog__more" type="button" data-rd-blog-more hidden>
          {$t.more} <span class="rd-blog__more-n"></span>
        </button>
      </div>
    </div>
  </section>
  {/if}
</div>
