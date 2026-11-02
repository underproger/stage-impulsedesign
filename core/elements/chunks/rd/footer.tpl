{*
  Редизайн: футер на всём сайте (чанк [[$footer]] → {include 'file:chunks/rd/footer.tpl'}).
  Сверху — золотая бегущая строка «Пишіть нам → e-mail» (ссылка mailto), ниже — колонки: логотип и описание,
  «Послуги», «Навігація» (страницы верхнего уровня, как в шапке), «Контакти» (телефон, адрес, e-mail, бриф),
  внизу — копирайт, соцсети, «Політика конфіденційності».
  Данные: ClientConfig — phone-1, adress / adress-ua, e-mail, brief, copyright, соцсети,
  policy-link / policy-link-ua (ID или URL политики; пусто — текст без ссылки).
  Пункты «Послуги» — ниже в $services (ID страниц услуг для RU и UA и подписи из макета).
  Бегущая строка двигается CSS-анимацией, в слое «вау» — rd-wow.js (ровная скорость, на прокрутку не реагирует, под курсором медленнее).
  В конце — плавающие кнопки (весь сайт): звонок (phone-1) и «наверх» с прогрессом прокрутки по контуру; логика — rd.js, стили — _float.scss.
*}
{set $ctx = $_modx->context.key}
{set $isRu = $ctx == 'web'}
{set $start = $_modx->config.site_start}
{set $servicesRoot = $isRu ? 80 : 383}
{set $img = '/assets/templates/rd/img/'}
{set $t = $isRu ? [
  'write' => 'Пишите нам',
  'about' => 'Профессиональное создание и продвижение сайтов в&nbsp;Киеве и&nbsp;Украине',
  'services' => 'Услуги',
  'nav' => 'Навигация',
  'contacts' => 'Контакты',
  'brief' => 'Скачать бриф',
  'policy' => 'Политика конфиденциальности',
  'home' => 'Impulse Design — на главную',
  'call' => 'Позвонить',
  'up' => 'Наверх'
] : [
  'write' => 'Пишіть нам',
  'about' => 'Професійне створення та просування сайтів у&nbsp;Києві та&nbsp;Україні',
  'services' => 'Послуги',
  'nav' => 'Навігація',
  'contacts' => 'Контакти',
  'brief' => 'Завантажити бриф',
  'policy' => 'Політика конфіденційності',
  'home' => 'Impulse Design — на головну',
  'call' => 'Подзвонити',
  'up' => 'Нагору'
]}
{set $services = $isRu ? [
  [187, 'Разработка сайтов'], [189, 'Продвижение сайтов'], [262, 'Поддержка сайтов'], [260, 'Написание текстов'], [263, 'Разработка лого']
] : [
  [384, 'Розробка сайтів'], [394, 'Просування сайтів'], [400, 'Підтримка сайтів'], [401, 'Написання текстів'], [402, 'Розробка лого']
]}
{set $navItems = $_modx->getResources(
  ['parent' => 0, 'context_key' => $ctx, 'published' => 1, 'deleted' => 0, 'hidemenu' => 0, 'id:NOT IN' => [$start, $servicesRoot]],
  ['sortby' => 'menuindex', 'sortdir' => 'ASC', 'limit' => 0, 'select' => 'id,pagetitle,menutitle']
)}
{set $email = ('e-mail' | option)}
{set $phone = ('phone-1' | option)}
{set $phoneHref = $phone | preg_replace : '/[^0-9+]/' : ''}
{set $address = ($isRu ? ('adress' | option) : ('adress-ua' | option)) | strip_tags | trim}
{* «1-5(центр)» → «1-5 (центр)»; номер дома с дефисом не рвём («1-» / «5») *}
{set $address = $address | preg_replace : '~(\S)\(~u' : '$1 (' | preg_replace : '~(\d+-\d+)~u' : '<span class="rd-nowrap">$1</span>'}
{set $brief = ('brief' | option)}
{if $brief && !($brief | preg_match : '#^(https?:)?/#')}{set $brief = '/' ~ $brief}{/if}
{set $policy = ($isRu ? ('policy-link' | option) : ('policy-link-ua' | option)) | trim}
{if $policy && ($policy | preg_match : '/^\d+$/')}{set $policy = $policy | url}{/if}
{set $socials = [
  ['url' => ('facebook' | option), 'icon' => 'soc-facebook.svg', 'label' => 'Facebook'],
  ['url' => ('insta' | option), 'icon' => 'soc-instagram.svg', 'label' => 'Instagram'],
  ['url' => ('youtube' | option), 'icon' => 'soc-youtube.svg', 'label' => 'YouTube'],
  ['url' => ('behance' | option), 'icon' => 'soc-behance.svg', 'label' => 'Behance'],
  ['url' => ('facebook_messenger' | option), 'icon' => 'soc-messenger.svg', 'label' => 'Messenger']
]}

<footer class="rd-footer" data-rd-footer>
  {if $email}
    <a class="rd-ticker" href="mailto:{$email}" aria-label="{$t.write}: {$email}" data-rd-ticker>
      <span class="rd-ticker__track" aria-hidden="true">
        {for $g=0 to=1}
          <span class="rd-ticker__group">
            {for $k=1 to=4}
              <span class="rd-ticker__item">
                <span class="rd-ticker__label">{$t.write}</span>
                <svg class="rd-ticker__arrow" width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M5 12h14M12 5l7 7-7 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                <span class="rd-ticker__mail">{$email}</span>
              </span>
            {/for}
          </span>
        {/for}
      </span>
    </a>
  {/if}

  <div class="rd-footer__main">
    <div class="rd-container rd-footer__grid">
      <div class="rd-footer__brand">
        <a class="rd-footer__logo" href="{$start | url}" aria-label="{$t.home}">
          <img src="{$img}logo.svg" width="167" height="27" alt="Impulse Design">
        </a>
        <p class="rd-footer__about">{$t.about}</p>
      </div>

      <nav class="rd-footer__col rd-footer__col--services" aria-label="{$t.services}">
        <p class="rd-footer__title">{$t.services}</p>
        <ul class="rd-footer__list">
          {foreach $services as $s}
            <li><a class="rd-footer__link" href="{$s[0] | url}">{$s[1]}</a></li>
          {/foreach}
        </ul>
      </nav>

      <nav class="rd-footer__col rd-footer__col--nav" aria-label="{$t.nav}">
        <p class="rd-footer__title">{$t.nav}</p>
        <ul class="rd-footer__list">
          {foreach $navItems as $n}
            <li><a class="rd-footer__link" href="{$n.id | url}">{$n.menutitle ?: $n.pagetitle}</a></li>
          {/foreach}
        </ul>
      </nav>

      <div class="rd-footer__col rd-footer__contacts">
        <p class="rd-footer__title">{$t.contacts}</p>
        <ul class="rd-footer__list">
          {if $phone}<li><a class="rd-footer__link" href="tel:{$phoneHref}">{$phone}</a></li>{/if}
          {if $address}<li class="rd-footer__addr">{$address}</li>{/if}
          {if $email}<li><a class="rd-footer__link rd-footer__mail" href="mailto:{$email}">{$email}</a></li>{/if}
        </ul>
        {if $brief}
          <a class="rd-footer__brief" href="{$brief}" download>
            <img src="{$img}download-cloud.svg" width="24" height="24" alt="">
            <span>{$t.brief}</span>
          </a>
        {/if}
      </div>

      {* на телефоне бриф — отдельной строкой под колонками (в макете слева), в колонке «Контакти» он скрыт *}
      {if $brief}
        <a class="rd-footer__brief rd-footer__brief--solo" href="{$brief}" download>
          <img src="{$img}download-cloud.svg" width="24" height="24" alt="">
          <span>{$t.brief}</span>
        </a>
      {/if}

      <div class="rd-footer__bottom">
        <p class="rd-footer__copy">© 2014-{$.php.date('Y')}, {'copyright' | option}</p>
        <ul class="rd-social rd-footer__social">
          {foreach $socials as $s}
            {if $s.url && $s.url != '#'}
              <li><a href="{$s.url}" target="_blank" rel="nofollow noopener" aria-label="{$s.label}" style="--rd-icon: url({$img}{$s.icon})"></a></li>
            {/if}
          {/foreach}
        </ul>
        {if $policy}
          <a class="rd-footer__policy" href="{$policy}">{$t.policy}</a>
        {else}
          <span class="rd-footer__policy">{$t.policy}</span>
        {/if}
      </div>
    </div>
  </div>
</footer>

{* Плавающие кнопки: звонок + «наверх» (по контуру — сколько страницы прокручено). Показ после первого экрана — rd.js *}
<div class="rd-float" data-rd-float>
  {if $phone}
    <a class="rd-float__btn rd-float__call" href="tel:{$phoneHref}" aria-label="{$t.call}: {$phone}" data-rd-magnet>
      <span class="rd-float__wave" aria-hidden="true"></span>
      <span class="rd-float__wave rd-float__wave--2" aria-hidden="true"></span>
      <span class="rd-float__num" aria-hidden="true">{$phone}</span>
      <svg class="rd-float__phone" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
    </a>
  {/if}
  <button class="rd-float__btn rd-float__up" type="button" aria-label="{$t.up}" data-rd-up data-rd-magnet>
    <span class="rd-float__fill" aria-hidden="true"></span>
    <svg class="rd-float__ring" viewBox="0 0 56 56" aria-hidden="true"><circle class="rd-float__track" cx="28" cy="28" r="27"/><circle class="rd-float__bar" cx="28" cy="28" r="27" pathLength="1"/></svg>
    <span class="rd-float__arrow" aria-hidden="true">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19V5M5 12l7-7 7 7"/></svg>
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19V5M5 12l7-7 7 7"/></svg>
    </span>
  </button>
</div>
