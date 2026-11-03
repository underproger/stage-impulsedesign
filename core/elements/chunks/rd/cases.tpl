{*
  Редизайн: страница «Портфоліо сайтів» (шаблон 10 «Портфолио»): крошки, заголовок, цитата и список кейсов.
  Поля (TV страницы):
    portfolio-list-title    — заголовок (h1)
    portfolio-list-subtitle — цитата справа (золото — в <span>; кавычки “ ” ставятся сами)
    rd_portfolio_list       — MIGX «rd_portfolio» (как кейсы блока «Портфоліо» главной): title, tags, text, link,
                              image / image_mob / layers — композиция или устройства слоями, screen — скриншот сайта
                              (кейсы без композиции: скриншот показывается в ноутбуке), bg — фон, word — надпись на фоне.
  Кейсы — «зигзагом»: картинка справа / слева. Сначала видно 6, «Показати ще» открывает следующие 6 (rd.js;
  без скриптов видны все). Картинка кейса — общий case-media.tpl.
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $items = $r['rd_portfolio_list'] | json_decode : true}
{set $title = ($r['portfolio-list-title'] | strip_tags : '<br>' | trim) ?: ($isRu ? 'Портфолио сайтов' : 'Портфоліо сайтів')}
{set $quote = $r['portfolio-list-subtitle'] | strip_tags : '<span><b><strong><br>' | preg_replace : '~<span[^>]*>~iu' : '<span>' | trim}
{if $quote && !($quote | preg_match : '~^[“"«„]~u')}{set $quote = '“' ~ $quote ~ '”'}{/if}
{set $per = 6}
{set $home = $_modx->config.site_start}
{set $t = $isRu ? ['more' => 'Посмотреть проект', 'show' => 'Показать ещё', 'crumbs' => 'Навигация по разделам'] : ['more' => 'Переглянути проект', 'show' => 'Показати ще', 'crumbs' => 'Навігація по розділах']}

<section class="rd-cases" data-rd-cases>
  <div class="rd-container">
    <div class="rd-cases__head">
      <nav class="rd-crumbs rd-crumbs--light rd-cases__crumbs" aria-label="{$t.crumbs}">
        <ol class="rd-crumbs__list" itemscope itemtype="https://schema.org/BreadcrumbList">
          <li class="rd-crumbs__item" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <a class="rd-crumbs__link" href="{$home | url}" itemprop="item"><span itemprop="name">{($home | resource : 'menutitle') ?: ($isRu ? 'Главная' : 'Головна')}</span></a>
            <meta itemprop="position" content="1">
          </li>
          <li class="rd-crumbs__item rd-crumbs__item--current" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <span itemprop="name" aria-current="page">{$r.menutitle ?: $r.pagetitle}</span>
            <meta itemprop="item" content="{$r.id | url : ['scheme' => 'full']}">
            <meta itemprop="position" content="2">
          </li>
        </ol>
      </nav>
      <h1 class="rd-cases__title">{$title}</h1>
      {if $quote}<p class="rd-cases__quote">{$quote}</p>{/if}
    </div>

    {if $items}
      <div class="rd-cases__list" data-rd-cases-list data-per="{$per}">
        {foreach $items as $i => $item}
          {set $link = $item.link}
          {if $link && ($link | preg_match : '/^\d+$/')}{set $link = $link | url}{/if}
          {if !$link}{set $link = $r.id | url}{/if}
          {set $tags = $item.tags | preg_replace : '/#|^\s+|\s+$/u' : '' | preg_split : '/\s*,\s{0,9}/u'}
          <article class="rd-case rd-case--row{if $i % 2} rd-case--flip{/if}"{if $item.bg} style="--rd-case-bg: {$item.bg | strip_tags | escape}"{/if}{if $i >= $per} data-rd-more{/if}>
            {include 'file:chunks/rd/case-media.tpl' item=$item link=$link}
            <div class="rd-case__desc">
              <div class="rd-case__heading">
                {if $item.tags}
                  <p class="rd-case__tags">
                    {foreach $tags as $tag}{if $tag}<span># {$tag}</span>{/if}{/foreach}
                  </p>
                {/if}
                <h2 class="rd-case__title"><a href="{$link}" draggable="false">{$item.title}</a></h2>
              </div>
              {if $item.text}
                <div class="rd-case__text">{$item.text}</div>
              {/if}
              <a class="rd-btn rd-btn--dark rd-case__btn" href="{$link}" aria-label="{$t.more}: {$item.title | strip_tags | escape}" draggable="false">
                <span>{$t.more}</span>
                <span class="rd-arrow"><img class="rd-arrow__a" src="{$img}arrow-up-right-dark.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="{$img}arrow-up-right-dark.svg" width="24" height="24" alt=""></span>
              </a>
            </div>
          </article>
        {/foreach}
      </div>

      {if ($items | length) > $per}
        <div class="rd-cases__actions">
          <button class="rd-btn rd-btn--dark rd-cases__more" type="button" data-rd-cases-more>
            <span>{$t.show}</span>
            <svg class="rd-cases__more-ic" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20.5 12a8.5 8.5 0 0 1-14.9 5.6M3.5 12a8.5 8.5 0 0 1 14.9-5.6"/><path d="M18.4 2.6v3.8h-3.8M5.6 21.4v-3.8h3.8"/></svg>
          </button>
        </div>
      {/if}
    {/if}
  </div>
</section>
