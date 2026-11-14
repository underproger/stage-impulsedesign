{*
  Редизайн: страница «Контакти» (шаблон 9; UA 451 /ua/kontakti.html, RU 3 /kontakty.html). Макета нет — язык сайта:
  светлая шапка (крошки, заголовок — pagetitle, справа — «сейчас работаем / не работаем» по графику и времени Киева),
  ниже тёмная карточка с движущейся сеткой (телефоны, e-mail с кнопкой «скопировать», адрес с «Прокласти маршрут»,
  график, мессенджеры, соцсети) и карта Google в скруглённой рамке (чёрно-белая, на наведении — цветная).
  Данные — настройки ClientConfig, как у старого шаблона: phone-1 / phone-2, e-mail, adress / adress-ua,
  grafik / grafik-weekend (+ -ua; подпись дня — в <span>), telegram, viber, whatsapp, facebook_messenger, facebook, insta,
  youtube, behance, google-map (из вставки берётся только src — карта грузится сама, loading="lazy").
  Статус и копирование — rd.js ([data-rd-hours], [data-rd-copy]); анимации — rd-wow.js.
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $home = $_modx->config.site_start}
{set $t = $isRu
  ? ['home' => 'Главная', 'crumbs' => 'Навигация по разделам', 'phone' => 'Телефон', 'mail' => 'E-mail', 'addr' => 'Адрес', 'hours' => 'График работы',
     'msg' => 'Мессенджеры', 'soc' => 'Мы в соцсетях', 'copy' => 'Скопировать', 'copied' => 'Скопировано', 'route' => 'Проложить маршрут',
     'open' => 'Сейчас работаем', 'closed' => 'Сейчас не работаем', 'map' => 'Карта: офис Impulse Design']
  : ['home' => 'Головна', 'crumbs' => 'Навігація по розділах', 'phone' => 'Телефон', 'mail' => 'E-mail', 'addr' => 'Адреса', 'hours' => 'Графік роботи',
     'msg' => 'Месенджери', 'soc' => 'Ми в соцмережах', 'copy' => 'Скопіювати', 'copied' => 'Скопійовано', 'route' => 'Прокласти маршрут',
     'open' => 'Зараз працюємо', 'closed' => 'Зараз не працюємо', 'map' => 'Мапа: офіс Impulse Design']}
{set $sfx = $isRu ? '' : '-ua'}
{set $phones = []}
{set $phoneKeys = ['phone-1', 'phone-2']}
{foreach $phoneKeys as $pk}
  {set $pv = ($pk | option) | trim}
  {if $pv}{set $phones = $.php.array_merge($phones, [$pv])}{/if}
{/foreach}
{set $email = ('e-mail' | option) | trim}
{set $addr = (('adress' ~ $sfx) | option) | strip_tags : '<span>' | trim}
{set $addrPlain = $addr | strip_tags | trim}
{set $hours = []}
{set $hourKeys = ['grafik', 'grafik-weekend']}
{foreach $hourKeys as $hk}
  {set $hv = (($hk ~ $sfx) | option) | strip_tags : '<span>' | trim}
  {if $hv}{set $hours = $.php.array_merge($hours, [$hv])}{/if}
{/foreach}
{set $msgs = [
  ['url' => ('telegram' | option), 'icon' => 'soc-telegram.svg', 'label' => 'Telegram'],
  ['url' => ('viber' | option), 'icon' => 'soc-viber.svg', 'label' => 'Viber'],
  ['url' => ('whatsapp' | option), 'icon' => 'soc-whatsapp.svg', 'label' => 'WhatsApp'],
  ['url' => ('facebook_messenger' | option), 'icon' => 'soc-messenger.svg', 'label' => 'Messenger']
]}
{set $socials = [
  ['url' => ('facebook' | option), 'icon' => 'soc-facebook.svg', 'label' => 'Facebook'],
  ['url' => ('insta' | option), 'icon' => 'soc-instagram.svg', 'label' => 'Instagram'],
  ['url' => ('youtube' | option), 'icon' => 'soc-youtube.svg', 'label' => 'YouTube'],
  ['url' => ('behance' | option), 'icon' => 'soc-behance.svg', 'label' => 'Behance']
]}
{set $mapSrc = ''}
{set $mapRaw = ('google-map' | option)}
{if $mapRaw | preg_match : '~src="([^"]+)"~'}{set $mapSrc = $mapRaw | preg_replace : '~^.*?src="([^"]+)".*$~s' : '$1'}{/if}

<div class="rd-cnt">
  {* ----- шапка ----- *}
  <section class="rd-cnt__top">
    <div class="rd-container">
      <nav class="rd-crumbs rd-crumbs--light rd-cnt__crumbs" aria-label="{$t.crumbs}">
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
      <div class="rd-cnt__head">
        <h1 class="rd-cnt__title" data-rd-fit>{$r.pagetitle}</h1>
        {if $hours}
          {* статус по графику и времени Киева — rd.js; без JS не виден *}
          <p class="rd-cnt__status" data-rd-status data-open="{$t.open}" data-closed="{$t.closed}" hidden>
            <span class="rd-cnt__dot" aria-hidden="true"></span><span class="rd-cnt__status-text"></span>
          </p>
        {/if}
      </div>
    </div>
  </section>

  {* ----- карточка и карта ----- *}
  <section class="rd-cnt__main">
    <div class="rd-container rd-cnt__grid">
      <div class="rd-cnt__card">
        {if $phones}
          <div class="rd-cnt__row" style="--k: 0">
            <p class="rd-cnt__label"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>{$t.phone}</p>
            <div class="rd-cnt__values">
              {foreach $phones as $ph}
                <a class="rd-cnt__big" href="tel:{$ph | preg_replace : '/[^0-9+]/' : ''}">{$ph}</a>
              {/foreach}
            </div>
          </div>
        {/if}
        {if $email}
          <div class="rd-cnt__row" style="--k: 1">
            <p class="rd-cnt__label"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="2.5" y="4.5" width="19" height="15" rx="2.5"/><path d="m3.5 6.5 8.5 6.5 8.5-6.5"/></svg>{$t.mail}</p>
            <div class="rd-cnt__values rd-cnt__values--line">
              <a class="rd-cnt__big" href="mailto:{$email}">{$email}</a>
              <button class="rd-cnt__copy" type="button" data-rd-copy="{$email}" data-done="{$t.copied}">
                <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="8.5" y="8.5" width="12" height="12" rx="2.5"/><path d="M15.5 8.5v-2a2 2 0 0 0-2-2h-7a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h2"/></svg>
                <span>{$t.copy}</span>
              </button>
            </div>
          </div>
        {/if}
        {if $addr}
          <div class="rd-cnt__row" style="--k: 2">
            <p class="rd-cnt__label"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z"/><circle cx="12" cy="10" r="3"/></svg>{$t.addr}</p>
            <div class="rd-cnt__values">
              <p class="rd-cnt__text">{$addr}</p>
              <a class="rd-cnt__route" href="https://www.google.com/maps/dir/?api=1&amp;destination={$addrPlain | escape : 'url'}" target="_blank" rel="noopener">
                {$t.route}
                <span class="rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt="" loading="lazy"><img class="rd-arrow__b" src="{$img}arrow-up-right-gold.svg" width="24" height="24" alt="" loading="lazy"></span>
              </a>
            </div>
          </div>
        {/if}
        {if $hours}
          <div class="rd-cnt__row" style="--k: 3">
            <p class="rd-cnt__label"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9.5"/><path d="M12 6.5V12l3.5 2"/></svg>{$t.hours}</p>
            <ul class="rd-cnt__values rd-cnt__hours">
              {foreach $hours as $h}<li data-rd-hours>{$h}</li>{/foreach}
            </ul>
          </div>
        {/if}
        <div class="rd-cnt__row rd-cnt__row--links" style="--k: 4">
          <div>
            <p class="rd-cnt__label">{$t.msg}</p>
            <ul class="rd-cnt__msgs">
              {foreach $msgs as $m}
                {if $m.url}
                  <li><a class="rd-cnt__msg" href="{$m.url}" rel="nofollow noopener"{if $m.url | preg_match : '~^https?:~'} target="_blank"{/if}><span class="rd-cnt__ico" style="--rd-icon: url({$img}{$m.icon})" aria-hidden="true"></span>{$m.label}</a></li>
                {/if}
              {/foreach}
            </ul>
          </div>
          <div>
            <p class="rd-cnt__label">{$t.soc}</p>
            <ul class="rd-cnt__socs">
              {foreach $socials as $s}
                {if $s.url}
                  <li><a class="rd-cnt__soc" href="{$s.url}" target="_blank" rel="nofollow noopener" aria-label="{$s.label}"><span class="rd-cnt__ico" style="--rd-icon: url({$img}{$s.icon})" aria-hidden="true"></span></a></li>
                {/if}
              {/foreach}
            </ul>
          </div>
        </div>
      </div>

      {if $mapSrc}
        <div class="rd-cnt__map">
          <iframe class="rd-cnt__frame" src="{$mapSrc}" title="{$t.map}" loading="lazy" referrerpolicy="no-referrer-when-downgrade" allowfullscreen></iframe>
        </div>
      {/if}
    </div>
  </section>
</div>
