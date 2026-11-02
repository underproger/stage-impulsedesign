{*
  Редизайн: блок FAQ (FAQ 2 макета). Заменяет старый чанк bl-faq.
  Поля (категория «Faq»):
    display_bl_faq  — показывать блок
    title-bl-faq    — заголовок («FAQ<span>s</span>»: золотое — в <span>)
    migx_questions  — вопросы: questions-title, questions-text (richtext)
  Десктоп (≥1200): вопросы слева вкладками, ответ активного — справа (все ответы в одной ячейке сетки,
  высота блока не прыгает). Планшет и телефон: аккордеон. Переключение — rd.js, анимации — rd-wow.js.
  Разметка schema.org FAQPage сохранена (как у старого блока).
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $items = $r['migx_questions'] | json_decode : true}
{set $title = $r['title-bl-faq'] ?: 'FAQ<span>s</span>'}

{if $items}
<section class="rd-faq" id="faq">
  <div class="rd-container rd-faq__wrap" itemscope itemtype="https://schema.org/FAQPage" style="--n: {$items | length}" data-rd-faq>
    <h2 class="rd-faq__title">{$title | strip_tags : '<span><br>'}</h2>
    {foreach $items as $i => $it}
      {set $q = $it['questions-title'] | strip_tags | trim}
      <div class="rd-faq__item{if $i == 0} is-open{/if}" style="--i: {$i}" itemprop="mainEntity" itemscope itemtype="https://schema.org/Question">
        <button class="rd-faq__q" type="button" id="rd-faq-q{$i}" aria-expanded="{$i == 0 ? 'true' : 'false'}" aria-controls="rd-faq-a{$i}">
          <span class="rd-faq__q-text" itemprop="name">{$q}</span>
          <span class="rd-faq__icon" aria-hidden="true"></span>
        </button>
        <div class="rd-faq__a" id="rd-faq-a{$i}" role="region" aria-labelledby="rd-faq-q{$i}" itemprop="acceptedAnswer" itemscope itemtype="https://schema.org/Answer">
          <div class="rd-faq__a-in">
            <p class="rd-faq__a-title" aria-hidden="true">{$q}</p>
            <div class="rd-faq__a-text" itemprop="text">{$it['questions-text']}</div>
          </div>
        </div>
      </div>
    {/foreach}
  </div>
</section>
{/if}
