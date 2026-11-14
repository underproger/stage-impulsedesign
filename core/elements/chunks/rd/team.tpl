{*
  Редизайн: блок «Ключові особи нашої команди» страницы «Про нас» (шаблон 17). Заменяет team_list-about
  (карусель Owl со сниппетом getTeamList). Макета нет — язык сайта: тёмная плашка с движущейся сеткой, заголовок
  (золото — <span>), карточки в ряд (на телефоне — по две): чёрно-белое фото 3:4, должность золотом, имя.
  Наведение: фото приближается и теплеет, снизу поднимается золотое свечение, имя золотится.
  Поля (TV): title-team-about — заголовок; team_list-team-about — MIGX: image (фото), title (имя), position (должность).
  «Вау» — модуль «Про нас» в rd-wow.js (карточки раскрываются снизу по очереди, фото «отъезжает»).
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $items = ($r['team_list-team-about'] ?: '[]') | json_decode : true}
{set $title = ($r['title-team-about'] | strip_tags : '<span><br>' | trim) ?: ($isRu ? 'Ключевые лица <span>нашей команды</span>' : 'Ключові особи <span>нашої команди</span>')}

{if $items}
<section class="rd-team" id="team">
  <div class="rd-container">
    <h2 class="rd-team__title">{$title}</h2>
    <ul class="rd-team__list" style="--n: {$items | length}">
      {foreach $items as $i => $it}
        {set $photo = $it.image | trim}
        {if $photo && !($photo | preg_match : '~^(https?:)?/~')}{set $photo = '/' ~ $photo}{/if}
        <li class="rd-team__card" style="--i: {$i}">
          <div class="rd-team__photo">
            {if $photo}<img src="{$photo}" width="573" height="800" alt="{$it.title | strip_tags | escape}" loading="lazy" decoding="async">{/if}
          </div>
          {if $it.position}<p class="rd-team__pos">{$it.position | strip_tags}</p>{/if}
          <p class="rd-team__name">{$it.title | strip_tags}</p>
        </li>
      {/foreach}
    </ul>
  </div>
</section>
{/if}
