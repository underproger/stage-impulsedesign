{*
  Редизайн: страница 404 (шаблон 2 «404 eror page»; RU 20 /oshibka-404.html, UA — своя страница в контексте uk,
  её ID — в настройке контекста error_page). Макета нет — язык сайта: тёмный экран с движущейся сеткой и золотым
  свечением, огромное «404», где «0» — золотое 3D-кольцо (rd-blob.js → knot.js, data-rd-knot="ring"; без WebGL
  и при reduced motion — картинка ring.webp), ниже h1, пояснение, кнопки «На головну» и «Обговорити проект»
  (модалка, href="#discuss") и «таблетки» разделов верхнего уровня (как меню шапки). Тексты — здесь (RU / UA).
  Шапку подключает шаблон перед этим блоком; экран заезжает под неё (отрицательный отступ = высота полосы шапки).
  Анимации — rd-wow.js (цифры встают из размытия и тянутся за курсором, прожектор), стили — _e404.scss.
*}
{set $ctx = $_modx->context.key}
{set $isRu = $ctx == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $start = $_modx->config.site_start}
{set $t = $isRu
  ? ['title' => 'Страница <span>не найдена</span>', 'text' => 'Возможно, её перенесли или в адресе есть ошибка. Начните с главной или выберите нужный раздел.',
     'home' => 'На главную', 'talk' => 'Обсудить проект', 'nav' => 'Популярные разделы']
  : ['title' => 'Сторінку <span>не знайдено</span>', 'text' => 'Можливо, її перенесли або в адресі є помилка. Почніть із головної або оберіть потрібний розділ.',
     'home' => 'На головну', 'talk' => 'Обговорити проект', 'nav' => 'Популярні розділи']}
{set $navItems = $_modx->getResources(
  ['parent' => 0, 'context_key' => $ctx, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0, 'id:NOT IN' => [$start]],
  ['sortby' => 'menuindex', 'sortdir' => 'ASC', 'limit' => 0, 'select' => 'id,pagetitle,menutitle']
)}
{set $blob = '/assets/templates/rd/js/rd-blob.js?v=' ~ $.php.filemtime($.const.MODX_ASSETS_PATH ~ 'templates/rd/js/rd-blob.js')}

<section class="rd-e404" data-rd-e404>
  <span class="rd-e404__glow" aria-hidden="true"></span>
  <div class="rd-container rd-e404__in">
    <p class="rd-e404__code" aria-hidden="true">
      <span class="rd-e404__d rd-e404__d--1">4</span>
      <span class="rd-e404__zero" data-rd-knot="ring" data-src="{$blob}">
        <img class="rd-e404__ring" src="{$img}ring.webp" width="600" height="600" alt="" loading="eager">
      </span>
      <span class="rd-e404__d rd-e404__d--2">4</span>
    </p>
    <h1 class="rd-e404__title">{$t.title}</h1>
    <p class="rd-e404__text">{$t.text}</p>
    <div class="rd-e404__btns">
      <a class="rd-lead__send rd-e404__home" href="{$start | url}">
        <span class="rd-lead__send-fill" aria-hidden="true"><span></span></span>
        <span class="rd-lead__send-text">{$t.home}</span>
        <span class="rd-lead__send-arrow rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt=""></span>
      </a>
      <a class="rd-btn rd-e404__talk" href="#discuss" data-rd-discuss>
        {$t.talk}
        <span class="rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="{$img}arrow-up-right.svg" width="24" height="24" alt=""></span>
      </a>
    </div>
    {if $navItems}
      <nav class="rd-e404__nav" aria-label="{$t.nav}">
        <p class="rd-e404__nav-title">{$t.nav}</p>
        <ul class="rd-e404__links">
          {foreach $navItems as $n}
            <li><a class="rd-e404__link" href="{$n.id | url}">{$n.menutitle ?: $n.pagetitle}</a></li>
          {/foreach}
        </ul>
      </nav>
    {/if}
  </div>
</section>
