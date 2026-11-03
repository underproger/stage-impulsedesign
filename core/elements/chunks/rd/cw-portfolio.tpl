{*
  Редизайн: страница копирайтинга — «Наше портфоліо» (section 5 copywriting_1920.pdf).
  Поля (TV): cw_portfolio_title — заголовок (золото — в <span>; пусто — «Наше портфоліо»),
             cw_portfolio_text  — подзаголовок (жирный — <b>),
             cw_portfolio       — MIGX «rd_text_works»: image (превью документа 330×467; на наведении длинный
                                  скриншот «прокручивается»; по клику картинка открывается на всю ширину экрана —
                                  для чёткости грузите крупную, от 1600px по ширине), tag (без #), title,
                                  stats (по строке: «Унікальність: 100%» — после двоеточия жирным, числа «досчитываются»),
                                  link (необязательно: ID страницы, URL или файл — PDF/DOCX открываются в новой вкладке;
                                  со ссылкой лист ведёт по ней, без ссылки — открывает картинку).
  Просмотр картинок — .rd-lb (rd.js): на всю ширину, прокрутка вниз, листание ← → и свайпом, Esc — закрыть.
  Десктоп — 4 в ряд, планшет — 2; сначала видно 4, «Показати ще» открывает следующие 4 (rd.js; без скриптов видны все).
  Телефон — лента с прокруткой пальцем (видны все, кнопки нет).
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $items = $r['cw_portfolio'] | json_decode : true}
{set $title = $r['cw_portfolio_title'] | strip_tags : '<span><br>' | preg_replace : '~<span[^>]*>~iu' : '<span>' | trim}
{if !$title}{set $title = $isRu ? 'Наше портфолио' : 'Наше портфоліо'}{/if}
{set $text = $r['cw_portfolio_text'] | strip_tags : '<b><strong><br>' | trim}
{set $per = 4}
{set $t = $isRu ? ['show' => 'Показать ещё', 'read' => 'Читать текст', 'open' => 'Открыть на весь экран'] : ['show' => 'Показати ще', 'read' => 'Читати текст', 'open' => 'Відкрити на весь екран']}
{if $items}
<section class="rd-cwp" id="text-works" data-rd-cwp data-rd-read="{$isRu ? 'читать' : 'читати'}" data-rd-lb-close="{$isRu ? 'Закрыть' : 'Закрити'}" data-rd-lb-prev="{$isRu ? 'Предыдущая работа' : 'Попередня робота'}" data-rd-lb-next="{$isRu ? 'Следующая работа' : 'Наступна робота'}">
  <div class="rd-container">
    <div class="rd-cwp__head">
      <h2 class="rd-cwp__title" data-rd-fit>{$title}</h2>
      {if $text}<p class="rd-cwp__text">{$text}</p>{/if}
    </div>

    <ul class="rd-cwp__list" data-rd-cwp-list data-per="{$per}">
      {foreach $items as $i => $it}
        {set $img = $it.image | trim}
        {if $img && !($img | preg_match : '~^(https?:)?/~')}{set $img = '/' ~ $img}{/if}
        {set $link = $it.link | trim}
        {if $link && ($link | preg_match : '/^\d+$/')}{set $link = $link | url}{/if}
        {set $ext = $link && (($link | preg_match : '~^https?://~i') || ($link | preg_match : '~\.(pdf|docx?|rtf|odt)(\?.*)?$~i'))}
        {set $name = $it.title | strip_tags : '<br>' | trim}
        {set $tag = $it.tag | strip_tags | preg_replace : '/^[\s#]+/u' : '' | trim}
        <li class="rd-cwp__item" style="--i: {$i}"{if $i >= $per} data-rd-more{/if}>
          {if $link}<a class="rd-cwp__doc" href="{$link}"{if $ext} target="_blank" rel="noopener"{/if} aria-label="{$t.read}: {$name | strip_tags | escape}" draggable="false">{elseif $img}<button class="rd-cwp__doc" type="button" data-rd-zoom="{$img}" aria-haspopup="dialog" aria-label="{$t.open}: {$name | strip_tags | escape}">{else}<div class="rd-cwp__doc">{/if}
            <span class="rd-cwp__sheet" aria-hidden="true"></span>
            <span class="rd-cwp__sheet rd-cwp__sheet--2" aria-hidden="true"></span>
            <span class="rd-cwp__paper">
              {if $img}<img src="{$img}" width="330" height="467" alt="{$name | strip_tags | escape}" loading="lazy" decoding="async" draggable="false">{/if}
            </span>
          {if $link}</a>{elseif $img}</button>{else}</div>{/if}
          {if $tag}<p class="rd-cwp__tag"># {$tag}</p>{/if}
          {if $name}<h3 class="rd-cwp__name">{if $link}<a href="{$link}"{if $ext} target="_blank" rel="noopener"{/if} draggable="false">{$name}</a>{else}{$name}{/if}</h3>{/if}
          {if $it.stats}
            {set $lines = $it.stats | strip_tags | preg_split : '/\R+/u'}
            <ul class="rd-cwp__stats">
              {foreach $lines as $ln}
                {set $ln = $ln | trim}
                {if $ln}
                  {if ($ln | preg_match : '/^[^:]+:\s*\S/u')}
                    <li>{$ln | preg_replace : '/^([^:]+:)\s*(.+)$/u' : '$1'} <b>{$ln | preg_replace : '/^([^:]+:)\s*(.+)$/u' : '$2'}</b></li>
                  {else}
                    <li>{$ln}</li>
                  {/if}
                {/if}
              {/foreach}
            </ul>
          {/if}
        </li>
      {/foreach}
    </ul>

    {if ($items | length) > $per}
      <div class="rd-cwp__actions">
        <button class="rd-btn rd-btn--dark rd-cwp__more" type="button" data-rd-cwp-more>
          <span>{$t.show}</span>
          <svg class="rd-cwp__more-ic" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20.5 12a8.5 8.5 0 0 1-14.9 5.6M3.5 12a8.5 8.5 0 0 1 14.9-5.6"/><path d="M18.4 2.6v3.8h-3.8M5.6 21.4v-3.8h3.8"/></svg>
        </button>
      </div>
    {/if}
  </div>
</section>
{/if}
