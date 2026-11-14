{*
  Редизайн: прайс-лист раздела услуг (шаблон 20 «Услуги - Категория»: «Ціна на створення сайтів», «Просування сайтів»,
  «Додаткові послуги для сайту»). Заменяет старый список pdoResources + tpl.services.subcategory.list.item.
  Макета нет — язык сайта: заголовок «Вартість послуг» со счётчиком, справа — пояснение про цены «від»;
  строки-ссылки на страницы услуг: номер, название, коротко, цена «від …», стрелка в круге.
  Наведение — тёмная заливка слева направо, золотой свет за курсором, стрелка «пролетает»; «вау» — rd-wow.js
  (линии строк прорисовываются слева, строки всплывают, суммы «досчитываются»).
  Данные — дочерние ресурсы страницы: все опубликованные (и скрытые из меню — как в старом прайсе:
  «Сайт на MODX», «Сайт-каталог»…; старый список обрезался на 10 — лимит pdoResources по умолчанию), по порядку в дереве.
  Поля услуги: название — services-subcategory-title (пусто — menutitle / pagetitle), коротко — services-subcategory-text,
  цена — services-subcategory-price («<span>ціна від </span>$600», «<span>ціна від </span>2500 <span>грн</span>»:
  подпись в первом <span> заменяется на «від / от», сумма отдельно (её «досчитывает» rd-wow.js), единицы — мельче).
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $t = $isRu
  ? ['title' => 'Стоимость <span>услуг</span>', 'note' => 'Все цены указаны в формате «от»: точная стоимость зависит от задачи и объёма работ.', 'from' => 'от', 'n1' => 'услуга', 'n2' => 'услуги', 'n5' => 'услуг']
  : ['title' => 'Вартість <span>послуг</span>', 'note' => 'Усі ціни вказані у форматі «від»: точна вартість залежить від задачі та обсягу робіт.', 'from' => 'від', 'n1' => 'послуга', 'n2' => 'послуги', 'n5' => 'послуг']}
{set $items = $_modx->getResources(
  ['parent' => $r.id, 'published' => 1, 'deleted' => 0],
  ['sortby' => ['menuindex' => 'ASC', 'id' => 'ASC'], 'limit' => 0, 'select' => 'id,pagetitle,menutitle',
   'includeTVs' => 'services-subcategory-title,services-subcategory-text,services-subcategory-price', 'tvPrefix' => '']
)}
{set $n = $items | length}
{set $nWord = ($n % 10 == 1 && $n % 100 != 11) ? $t.n1 : (($n % 10 >= 2 && $n % 10 <= 4 && ($n % 100 < 10 || $n % 100 >= 20)) ? $t.n2 : $t.n5)}

{if $items}
<section class="rd-prl" id="prices">
  <div class="rd-container">
    <div class="rd-prl__head">
      <h2 class="rd-prl__title">{$t.title}</h2>
      <p class="rd-prl__count">{$n} {$nWord}</p>
      <p class="rd-prl__note">{$t.note}</p>
    </div>

    <ol class="rd-prl__list">
      {foreach $items as $i => $s}
        {set $sTitle = ($s['services-subcategory-title'] | strip_tags | trim) ?: ($s.menutitle ?: $s.pagetitle)}
        {set $sText = $s['services-subcategory-text'] | strip_tags | trim}
        {* цена: подпись в первом <span> срезаем; сумма — до следующего <span>, единицы — внутри него *}
        {set $price = $s['services-subcategory-price'] | preg_replace : '~^\s{0,9}<span[^>]*>[^<]*</span>\s{0,9}~u' : '' | trim}
        {set $sum = $price | preg_replace : '~<.*$~su' : '' | strip_tags | trim}
        {set $unit = $price | preg_replace : '~^[^<]*~u' : '' | strip_tags | trim}
        <li class="rd-prl__row" style="--i: {$i}">
          <a class="rd-prl__link" href="{$s.id | url}">
            <span class="rd-prl__num">{$i < 9 ? ('0' ~ ($i + 1)) : ($i + 1)}</span>
            <span class="rd-prl__name">{$sTitle}</span>
            {if $sText}<span class="rd-prl__text">{$sText}</span>{/if}
            {if $sum}
              <span class="rd-prl__price">
                <span class="rd-prl__from">{$t.from}</span>
                <span class="rd-prl__val"><span class="rd-prl__sum">{$sum}</span>{if $unit} <span class="rd-prl__unit">{$unit}</span>{/if}</span>
              </span>
            {/if}
            <span class="rd-prl__arrow rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="{$img}arrow-up-right-dark.svg" width="24" height="24" alt="" loading="lazy"><img class="rd-arrow__b" src="{$img}arrow-up-right-dark.svg" width="24" height="24" alt="" loading="lazy"></span>
          </a>
        </li>
      {/foreach}
    </ol>
  </div>
</section>
{/if}
