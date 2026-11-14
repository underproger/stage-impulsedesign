{*
  Редизайн: страница «Спасибо» (шаблон 6 «Success-Page-RU»; ресурс 40 /thanx-you.html — одна на оба языка: на неё
  уводят формы заявки и модалка «Обговорити проект» с обеих версий сайта; адрес не меняли — на него могут быть завязаны
  цели / конверсии в GTM). Отдельный экран без меню (как и было): логотип и телефон сверху, по центру — золотая галочка
  рисуется, вокруг расходятся волны и разлетаются золотые искры (rd-wow.js), «Дякуємо!», текст, телефон «Терміново?»,
  кнопки «На головну» и «Дивитися портфоліо», соцсети. Внизу — копирайт.
  Язык — по странице, с которой отправили заявку: rd.js на каждой странице пишет язык в sessionStorage (rd-lang),
  здесь инлайн-скрипт до отрисовки ставит html[data-rd-lang] (запасной вариант — адрес предыдущей страницы /ua/…);
  без JS — по-русски (контекст страницы). Тексты обоих языков — в разметке ([lang]), лишний прячет CSS (_ty.scss).
  Ссылки: главная — RU 1 / UA 382, портфолио — RU 100 / UA 404. Данные — ClientConfig: phone-1, соцсети.
*}
{set $img = '/assets/templates/rd/img/'}
{set $phone = ('phone-1' | option) | trim}
{set $phoneHref = $phone | preg_replace : '/[^0-9+]/' : ''}
{set $socials = [
  ['url' => ('facebook' | option), 'icon' => 'soc-facebook.svg', 'label' => 'Facebook'],
  ['url' => ('insta' | option), 'icon' => 'soc-instagram.svg', 'label' => 'Instagram'],
  ['url' => ('youtube' | option), 'icon' => 'soc-youtube.svg', 'label' => 'YouTube'],
  ['url' => ('behance' | option), 'icon' => 'soc-behance.svg', 'label' => 'Behance'],
  ['url' => ('telegram' | option), 'icon' => 'soc-telegram.svg', 'label' => 'Telegram']
]}
{set $arrow = '<span class="rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="' ~ $img ~ 'arrow-up-right.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="' ~ $img ~ 'arrow-up-right-gold.svg" width="24" height="24" alt=""></span>'}
<script>
  (function (d) { try { var l = sessionStorage.getItem('rd-lang') || ''; if (!l && /\/ua(\/|$)/.test(document.referrer)) l = 'uk'; if (l === 'uk' || l === 'ru') { d.setAttribute('data-rd-lang', l); d.lang = l; if (l === 'uk') document.title = 'Дякуємо! Заявку надіслано — Impulse Design'; } } catch (e) { } })(document.documentElement);
</script>
<main class="rd-ty" data-rd-ty>
  <span class="rd-ty__glow" aria-hidden="true"></span>
  <header class="rd-ty__top rd-container">
    <a class="rd-ty__logo" href="{1 | url}" lang="ru" aria-label="Impulse Design — на главную"><img src="{$img}logo.svg" width="167" height="27" alt="Impulse Design"></a>
    <a class="rd-ty__logo" href="{382 | url}" lang="uk" aria-label="Impulse Design — на головну"><img src="{$img}logo.svg" width="167" height="27" alt="Impulse Design"></a>
    {if $phone}<a class="rd-ty__phone" href="tel:{$phoneHref}">{$phone}</a>{/if}
  </header>

  <div class="rd-container rd-ty__in">
    <div class="rd-ty__mark" aria-hidden="true">
      <span class="rd-ty__wave"></span>
      <span class="rd-ty__wave rd-ty__wave--2"></span>
      <span class="rd-ty__wave rd-ty__wave--3"></span>
      <span class="rd-ty__circle">
        <svg viewBox="0 0 52 52"><path class="rd-ty__check" d="M14 27.5l8.2 8.2L38.5 18"/></svg>
      </span>
    </div>
    <p class="rd-ty__eyebrow"><span lang="ru">Заявка отправлена</span><span lang="uk">Заявку надіслано</span></p>
    <h1 class="rd-ty__title" data-rd-fit><span lang="ru">Спасибо!</span><span lang="uk">Дякуємо!</span></h1>
    <p class="rd-ty__text">
      <span lang="ru">Мы получили вашу заявку и свяжемся с вами в ближайшее время.</span>
      <span lang="uk">Ми отримали вашу заявку і зв’яжемося з вами найближчим часом.</span>
    </p>
    {if $phone}
      <p class="rd-ty__call">
        <span lang="ru">Срочно? Позвоните нам:</span><span lang="uk">Терміново? Зателефонуйте нам:</span>
        <a href="tel:{$phoneHref}">{$phone}</a>
      </p>
    {/if}
    <div class="rd-ty__btns">
      <a class="rd-lead__send rd-ty__home" href="{1 | url}" lang="ru">
        <span class="rd-lead__send-fill" aria-hidden="true"><span></span></span>
        <span class="rd-lead__send-text">На главную</span>
        {$arrow}
      </a>
      <a class="rd-lead__send rd-ty__home" href="{382 | url}" lang="uk">
        <span class="rd-lead__send-fill" aria-hidden="true"><span></span></span>
        <span class="rd-lead__send-text">На головну</span>
        {$arrow}
      </a>
      <a class="rd-btn rd-ty__pf" href="{100 | url}" lang="ru">Смотреть портфолио {$arrow | replace : 'arrow-up-right-gold.svg' : 'arrow-up-right.svg'}</a>
      <a class="rd-btn rd-ty__pf" href="{404 | url}" lang="uk">Дивитися портфоліо {$arrow | replace : 'arrow-up-right-gold.svg' : 'arrow-up-right.svg'}</a>
    </div>
  </div>

  <footer class="rd-ty__foot rd-container">
    <p class="rd-ty__copy">© 2014-{$.php.date('Y')}, {'copyright' | option}</p>
    <ul class="rd-social rd-ty__social">
      {foreach $socials as $s}
        {if $s.url && $s.url != '#'}
          <li><a href="{$s.url}" target="_blank" rel="nofollow noopener" aria-label="{$s.label}" style="--rd-icon: url({$img}{$s.icon})"></a></li>
        {/if}
      {/foreach}
    </ul>
  </footer>
</main>
