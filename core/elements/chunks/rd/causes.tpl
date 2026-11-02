{*
  Редизайн: блок «… незамінний, якщо» страницы услуги (шаблон 21, section 4 макета). Заменяет старый чанк bl4-causes-services.
  Поля (категория блока 4):
    display_bl4      — показывать блок (как и раньше: выключен — «Переваги» идут после портфолио)
    title-bl4        — заголовок (золото — в <span>; двоеточие в конце не выводится)
    causes_list-bl4  — MIGX «causes»: title (жирная строка), text (продолжение). Номера 01, 02… — по порядку.
  Десктоп — 3 колонки, планшет — 2, телефон — столбик. Анимации — модуль «незамінний, якщо» в rd-wow.js.
*}
{set $r = $_modx->resource}
{set $items = $r['causes_list-bl4'] | json_decode : true}
{set $title = $r['title-bl4'] | strip_tags : '<span><br>' | trim | preg_replace : '~\s*:\s*$~u' : ''}

{if $items}
<section class="rd-cause" id="causes">
  <div class="rd-container">
    {if $title}
      <h2 class="rd-cause__title" data-rd-fit>{$title}</h2>
    {/if}
    <ol class="rd-cause__list">
      {foreach $items as $i => $it}
        {set $num = $i < 9 ? ('0' ~ ($i + 1)) : ($i + 1)}
        <li class="rd-cause__item" style="--i: {$i}">
          <span class="rd-cause__num" aria-hidden="true"><span class="rd-cause__num-in">{$num}</span></span>
          {if $it.title}<p class="rd-cause__name">{$it.title | strip_tags | trim}</p>{/if}
          {if $it.text}<p class="rd-cause__text">{$it.text | strip_tags : '<br><b><strong>' | trim}</p>{/if}
        </li>
      {/foreach}
    </ol>
  </div>
</section>
{/if}
