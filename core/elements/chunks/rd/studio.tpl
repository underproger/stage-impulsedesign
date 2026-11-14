{*
  Редизайн: блок «Студія веб-дизайну Impulse Design» страницы «Про нас» (шаблон 17). Заменяет «studio» старого
  чанка banner-about. Макета нет — язык сайта: заголовок (золото — «Impulse Design»), крупный вводный текст,
  справа фото в скруглённой «капсуле» (раскрывается слева, при прокрутке чуть едет — параллакс, на наведении приближается)
  и золотая «таблетка» с числом из текста («Це 12 осіб…» → «12 фахівців у штаті»; нет числа — нет таблетки).
  Поля (TV): text-banner-about — первый <strong> становится заголовком (<br> — пробел), остальные абзацы — текстом;
  img-banner-about — фото (пусто — блок без фото, текст во всю ширину).
  «Вау» — модуль «Про нас» в rd-wow.js.
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $raw = $r['text-banner-about'] | trim}
{set $title = ''}
{if $raw | preg_match : '~<(strong|b)>(.*?)</\1>~isu'}
  {set $title = $raw | preg_replace : '~^.*?<(strong|b)>(.*?)</\1>.*$~isu' : '$2' | preg_replace : '~<br\s{0,3}/?>~iu' : ' ' | strip_tags | preg_replace : '~\s+~u' : ' ' | trim}
  {set $raw = $raw | preg_replace : '~<(strong|b)>.*?</\1>~isu' : '' }
{/if}
{* пустые абзацы (<p> </p>) — прочь; остаются абзацы с текстом *}
{set $text = $raw | preg_replace : '~<p[^>]*>(\s|&nbsp;|\xC2\xA0)*</p>~iu' : '' | strip_tags : '<p><br><b><strong><a>' | trim}
{if !$title}{set $title = $isRu ? 'Студия веб-дизайна Impulse Design' : 'Студія веб-дизайну Impulse Design'}{/if}
{set $title = $title | preg_replace : '~(Impulse?\s+Design)~u' : '<span>$1</span>'}
{* число людей из текста: «Це 12 осіб», «Это 12 человек» *}
{set $team = ''}
{if $text | preg_match : '~(\d+)\s+(осіб|осiб|людей|чоловік|человек)~u'}
  {set $team = $text | strip_tags | preg_replace : '~^.*?(\d+)\s+(осіб|осiб|людей|чоловік|человек).*$~su' : '$1'}
{/if}
{set $photo = $r['img-banner-about'] | trim}
{if $photo && !($photo | preg_match : '~^(https?:)?/~')}{set $photo = '/' ~ $photo}{/if}

{if $text}
<section class="rd-studio{if !$photo} rd-studio--nophoto{/if}" data-rd-studio>
  <div class="rd-container rd-studio__wrap">
    <div class="rd-studio__body">
      <h2 class="rd-studio__title">{$title}</h2>
      <div class="rd-studio__text">{$text}</div>
    </div>
    {if $photo}
      <div class="rd-studio__media">
        <div class="rd-studio__frame">
          <img class="rd-studio__img" src="{$photo}" width="600" height="400" alt="Команда Impulse Design" loading="lazy" decoding="async">
        </div>
        {if $team}
          <p class="rd-studio__badge"><b>{$team}</b><span>{$isRu ? 'специалистов в штате' : 'фахівців у штаті'}</span></p>
        {/if}
      </div>
    {/if}
  </div>
</section>
{/if}
