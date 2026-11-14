{*
  Редизайн: страница «Відгуки» (шаблон 16; UA 450 /ua/vidgukyi.html, RU 171 /otzyvy.html). Макета нет — язык сайта:
  1) светлый первый экран: крошки, h1, вступление; справа — средняя оценка и число отзывов (считает rd.js по карточкам
     на странице: оценки из кейсов и из формы) и кнопка «Залишити відгук» (к форме);
  2) тёмный блок видеоотзывов: MIGX reviews-bl6 (title — имя, position — кто, text — цитата, image — фото,
     video — вставка YouTube, из неё берётся только ID); заголовок — title-bl6 (золото — <span>). Видео открывается
     поверх страницы (rd.js, [data-rd-video]) — плеер YouTube грузится только по клику;
  3) «Відгуки про співпрацю»: карточки — отзывы из кейсов портфолио (шаблон 18, поля case_review_*: текст, имя, роль,
     фото, звёзды; ссылка на кейс) и отзывы посетителей easyComm (опубликованные, ветки обеих языковых версий
     страницы — по babelLanguageLinks; шаблон строки — chunks/rd/review-msg.tpl). Больше шести — «Показати ще» (rd.js).
     Справа (на мобайле — ниже) — тёмная форма «Залишити відгук» (ecForm: chunks/rd/review-form.tpl,
     успех — review-success.tpl; отзывы публикуются после проверки в админке, Компоненты → easyComm).
  Стили — _rev.scss, анимации — rd-wow.js. Форма заявки и SEO-текст подключает шаблон.
*}
{set $r = $_modx->resource}
{set $ctx = $_modx->context.key}
{set $isRu = $ctx == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $home = $_modx->config.site_start}
{set $t = $isRu
  ? ['home' => 'Главная', 'crumbs' => 'Навигация по разделам', 'h1' => 'Отзывы <span>клиентов</span>',
     'lead' => 'Главная награда для нас — слова людей, с которыми мы сделали сайт. Читайте, смотрите видео и оставляйте свой отзыв.',
     'avg' => 'средняя оценка', 'forms' => 'отзыв|отзыва|отзывов', 'leave' => 'Оставить отзыв',
     'vtitle' => '<span>Что</span> о нас говорят клиенты', 'watch' => 'Смотреть видео', 'close' => 'Закрыть',
     'ltitle' => 'Отзывы о <span>сотрудничестве</span>', 'case' => 'Смотреть кейс', 'more' => 'Показать ещё',
     'empty' => 'Отзывов здесь пока нет — станьте первым.', 'rate' => 'Оценка']
  : ['home' => 'Головна', 'crumbs' => 'Навігація по розділах', 'h1' => 'Відгуки <span>клієнтів</span>',
     'lead' => 'Головна нагорода для нас — слова людей, з якими ми зробили сайт. Читайте, дивіться відео та залишайте власний відгук.',
     'avg' => 'середня оцінка', 'forms' => 'відгук|відгуки|відгуків', 'leave' => 'Залишити відгук',
     'vtitle' => '<span>Що</span> про нас кажуть клієнти', 'watch' => 'Дивитися відео', 'close' => 'Закрити',
     'ltitle' => 'Відгуки про <span>співпрацю</span>', 'case' => 'Дивитися кейс', 'more' => 'Показати ще',
     'empty' => 'Відгуків тут поки немає — станьте першим.', 'rate' => 'Оцінка']}
{set $star = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2.2l2.95 6.6 7.2.66-5.45 4.78 1.63 7.06L12 17.6 5.67 21.3l1.63-7.06L1.85 9.46l7.2-.66z"/></svg>'}

{* видеоотзывы *}
{set $vRaw = $r['reviews-bl6'] | trim}
{set $vids = $vRaw ? ($vRaw | json_decode : true) : []}
{set $vTitle = ($r['title-bl6'] | strip_tags : '<span><br>' | trim) ?: $t.vtitle}

{* отзывы из кейсов портфолио своего контекста *}
{set $cases = $_modx->getResources(
  ['template' => 18, 'context_key' => $ctx, 'published' => 1, 'deleted' => 0],
  ['includeTVs' => 'case_review_text,case_review_name,case_review_role,case_review_photo,case_review_stars', 'tvPrefix' => '',
   'select' => 'id,pagetitle,menutitle', 'sortby' => 'menuindex', 'sortdir' => 'ASC', 'limit' => 0]
)}

{* ветки easyComm: эта страница и её перевод (babelLanguageLinks «web:171;uk:450») *}
{set $threads = ($r['babelLanguageLinks'] | trim) | preg_replace : '~[a-z]+:~' : '' | preg_replace : '~(\d+)~' : 'resource-$1' | replace : ';' : ','}
{* в регулярках без латинской «e»: проверка pdoTools на модификатор eval ошибается на таких шаблонах *}
{if !($threads | preg_match : '~\d~')}{set $threads = 'resource-' ~ $r.id}{/if}

<div class="rd-rev" data-rd-rev>
  {* ----- первый экран ----- *}
  <section class="rd-rev__top">
    <div class="rd-container">
      <nav class="rd-crumbs rd-rev__crumbs" aria-label="{$t.crumbs}">
        <ol class="rd-crumbs__list" itemscope itemtype="https://schema.org/BreadcrumbList">
          <li class="rd-crumbs__item" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <a class="rd-crumbs__link" href="{$home | url}" itemprop="item"><span itemprop="name">{$t.home}</span></a>
            <meta itemprop="position" content="1">
          </li>
          <li class="rd-crumbs__item rd-crumbs__item--current" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <span itemprop="name" aria-current="page">{$r.menutitle ?: $r.pagetitle}</span>
            <meta itemprop="item" content="{$r.id | url : ['scheme' => 'full']}">
            <meta itemprop="position" content="2">
          </li>
        </ol>
      </nav>
      <div class="rd-rev__head">
        <div class="rd-rev__intro">
          <h1 class="rd-rev__title" data-rd-fit>{$t.h1}</h1>
          <p class="rd-rev__lead">{$t.lead}</p>
        </div>
        <div class="rd-rev__sum">
          {* оценка и число — rd.js по карточкам на странице; без оценок блок оценки скрыт *}
          <div class="rd-rev__score" data-rd-rev-score hidden>
            <span class="rd-rev__num" data-rd-rev-avg>5.0</span>
            <span class="rd-rev__score-side">
              <span class="rd-rev__stars rd-rev__stars--big" role="img" data-rd-rev-stars style="--p: 100%">
                <span class="rd-rev__stars-bg">{for $s=1 to=5}{$star}{/for}</span>
                <span class="rd-rev__stars-fg">{for $s=1 to=5}{$star}{/for}</span>
              </span>
              <span class="rd-rev__cap">{$t.avg}</span>
            </span>
          </div>
          <div class="rd-rev__count" data-rd-rev-count data-forms="{$t.forms}" hidden>
            <span class="rd-rev__num" data-rd-rev-n>0</span>
            <span class="rd-rev__cap" data-rd-rev-word>{$t.forms | preg_replace : '~\|.*$~' : ''}</span>
          </div>
          <a class="rd-btn rd-btn--dark rd-rev__go" href="#rd-rev-form">
            {$t.leave}
            <span class="rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt=""></span>
          </a>
        </div>
      </div>
    </div>
  </section>

  {* ----- видеоотзывы ----- *}
  {if $vids}
    <section class="rd-rev__video" aria-labelledby="rd-rev-vtitle">
      <div class="rd-container">
        <h2 class="rd-rev__h2 rd-rev__h2--light" id="rd-rev-vtitle" data-rd-fit>{$vTitle}</h2>
        <ul class="rd-rev__vlist">
          {foreach $vids as $v index=$i}
            {* ID видео: 11 символов после «/» или «v=» (embed/ID, youtu.be/ID, watch?v=ID) *}
            {set $yt = $v.video | preg_get : '~[/=]([A-Za-z0-9_-]{11})(?:["?&]|$)~' : 1}
            {if !($yt | preg_match : '~^[A-Za-z0-9_-]{11}$~')}{set $yt = ''}{/if}
            {set $photo = $v.image | trim}
            {if $photo && !($photo | preg_match : '~^(https?:)?/~')}{set $photo = '/' ~ $photo}{/if}
            {set $name = $v.title | strip_tags | trim}
            <li class="rd-vrev" style="--i: {$i}" data-rating="0">
              <div class="rd-vrev__media">
                {if $photo}<img class="rd-vrev__photo" src="{$photo}" width="360" height="388" alt="{$name | escape}" loading="lazy">{/if}
                {if $yt}
                  <button class="rd-vrev__play" type="button" data-rd-video="{$yt}" aria-label="{$t.watch}: {$name | escape}" data-rd-magnet>
                    <span class="rd-vrev__wave" aria-hidden="true"></span>
                    <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.5v13l11-6.5z"/></svg>
                  </button>
                {/if}
              </div>
              <div class="rd-vrev__body">
                <svg class="rd-vrev__quote" viewBox="0 0 48 36" aria-hidden="true"><path d="M0 36V22.4C0 9.6 6.6 2.1 19.8 0l1.8 4.6C14.4 6.6 10.8 10.6 10.4 16.6H20V36H0zm28 0V22.4C28 9.6 34.6 2.1 47.8 0l1.8 4.6c-7.2 2-10.8 6-11.2 12H48V36H28z"/></svg>
                <blockquote class="rd-vrev__text"><p>{$v.text | strip_tags : '<br><b><strong>' | trim}</p></blockquote>
                <p class="rd-vrev__who">
                  <span class="rd-vrev__name">{$name}</span>
                  {if $v.position}<span class="rd-vrev__pos">{$v.position | strip_tags | trim}</span>{/if}
                </p>
                {if $yt}
                  <button class="rd-vrev__watch" type="button" data-rd-video="{$yt}">
                    <span class="rd-vrev__watch-ic" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M8 5.5v13l11-6.5z"/></svg></span>
                    {$t.watch}
                  </button>
                {/if}
              </div>
            </li>
          {/foreach}
        </ul>
      </div>
    </section>
  {/if}

  {* ----- отзывы о сотрудничестве + форма ----- *}
  <section class="rd-rev__main" aria-labelledby="rd-rev-ltitle">
    <div class="rd-container rd-rev__grid">
      <div class="rd-rev__col">
        <h2 class="rd-rev__h2" id="rd-rev-ltitle" data-rd-fit>{$t.ltitle}</h2>
        <div class="rd-rev__list" data-rd-rev-list>
          {foreach $cases as $c}
            {set $cText = $c.case_review_text | strip_tags : '<b><strong><br>' | trim}
            {if $cText}
              {set $cPhoto = $c.case_review_photo | trim}
              {if $cPhoto && !($cPhoto | preg_match : '~^(https?:)?/~')}{set $cPhoto = '/' ~ $cPhoto}{/if}
              {set $cStars = ($c.case_review_stars | trim) ?: 5}
              {set $cName = $c.case_review_name | strip_tags | trim}
              {set $cText = $cText | preg_replace : '~^[“"«„]+|[”"»“]+$~u' : ''}
              <article class="rd-rcard rd-rcard--case" data-rating="{$cStars}">
                <header class="rd-rcard__head">
                  {if $cPhoto}
                    <img class="rd-rcard__ava" src="{$cPhoto}" width="56" height="56" alt="{$cName | escape}" loading="lazy">
                  {else}
                    <span class="rd-rcard__ava rd-rcard__ava--letter" aria-hidden="true">{$.php.mb_substr($cName, 0, 1)}</span>
                  {/if}
                  <span class="rd-rcard__who">
                    <span class="rd-rcard__name">{$cName}</span>
                    {if $c.case_review_role}<span class="rd-rcard__role">{$c.case_review_role | strip_tags | trim}</span>{/if}
                  </span>
                  <span class="rd-rev__stars" role="img" aria-label="{$t.rate}: {$cStars} / 5" style="--p: {$cStars * 20}%">
                    <span class="rd-rev__stars-bg">{for $s=1 to=5}{$star}{/for}</span>
                    <span class="rd-rev__stars-fg">{for $s=1 to=5}{$star}{/for}</span>
                  </span>
                </header>
                <blockquote class="rd-rcard__text"><p>{$cText}</p></blockquote>
                <a class="rd-rcard__link" href="{$c.id | url}">
                  {$c.menutitle ?: $c.pagetitle}
                  <span class="rd-rcard__sep" aria-hidden="true">·</span>
                  {$t.case}
                  <span class="rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt="" loading="lazy"><img class="rd-arrow__b" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt="" loading="lazy"></span>
                </a>
              </article>
            {/if}
          {/foreach}
          [[!ecMessages?
            &threads=`{$threads}`
            &tpl=`@FILE chunks/rd/review-msg.tpl`
            &sortby=`date`
            &sortdir=`DESC`
            &limit=`0`
          ]]
        </div>
        <p class="rd-rev__empty">{$t.empty}</p>
        <button class="rd-btn rd-btn--dark rd-rev__more" type="button" data-rd-rev-more hidden>{$t.more} <span class="rd-rev__more-n"></span></button>
      </div>

      <aside class="rd-rev__aside" id="rd-rev-form">
        <div class="rd-rev__panel">
          [[!ecForm?
            &tplForm=`@FILE chunks/rd/review-form.tpl`
            &tplSuccess=`@FILE chunks/rd/review-success.tpl`
            &tplNewEmailManager=`tpl.ecForm.New.Email.Manager.Blog`
            &tplNewEmailUser=`tpl.ecForm.New.Email.User.Blog`
            &tplUpdateEmailUser=`tpl.ecForm.Update.Email.User.Blog`
          ]]
        </div>
      </aside>
    </div>
  </section>
</div>
