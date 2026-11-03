{*
  Редизайн: «Етапи розробки» — страница услуги (шаблон 21, section 8 макета).
  Поля (TV):
    title-bl8  — заголовок блока
    stages-bl8 — MIGX «stages»: title — название этапа (в «таблетке»), text — описание под ней.
                 Подпись «Етап 1», «Етап 2»… ставится сама, последний этап — тёмная «таблетка».
  Десктоп — «таблетки» в ряд внахлёст, под каждой скобка и описание; планшет — «таблетка» слева, описание справа;
  телефон — столбик. Ширины «таблеток» для пяти этапов — как в макете (280/350/360/300/300 на 1920).
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $items = $r['stages-bl8'] | json_decode : true}

{if $items}
{set $n = $items | length}
<section class="rd-stages" id="stages">
  <div class="rd-container rd-stages__wrap">
    {if $r['title-bl8']}
      <h2 class="rd-stages__title" data-rd-fit>{$r['title-bl8'] | strip_tags : '<span><br>'}</h2>
    {/if}
    <ol class="rd-stages__list{if $n == 5} rd-stages__list--5{/if}">
      {foreach $items as $i => $item}
        <li class="rd-stage{if $i == $n - 1} rd-stage--dark{/if}" style="--i: {$i}">
          <div class="rd-stage__pill">
            {if $i == $n - 1}<span class="rd-stage__glow" aria-hidden="true"></span>{/if}
            <span class="rd-stage__tag">{$isRu ? 'Этап' : 'Етап'} {$i + 1}</span>
            <h3 class="rd-stage__name">{$item.title | strip_tags : '<br>'}</h3>
          </div>
          {if $item.text}
            <div class="rd-stage__desc">
              <span class="rd-stage__brace" aria-hidden="true"></span>
              <p class="rd-stage__text">{$item.text | strip_tags : '<br><b><strong><a>'}</p>
            </div>
          {/if}
        </li>
      {/foreach}
    </ol>
  </div>
</section>
{/if}
