{*
  Редизайн: блок-форма «Готові замовити створення сайту?» — section 8 макета. Заменяет старый чанк bl10-form,
  включается тем же чекбоксом display_bl10. Поля (категория «Блок 10 - Форма»):
    title-bl10        — заголовок (золотое слово — в <span>)
    sub-title-bl10    — текст; жирный фрагмент (<b>) выводится отдельной строкой под текстом
    form-title-bl10   — заголовок формы (золото — в <span>)
    policy-link-bl10  — ID или URL «Політики конфіденційності» (пусто — без ссылки)
  Форма — тот же AjaxForm + FormIt, что у старого блока (хуки, письма, Google-таблица, id form-bl8 —
  после успешной отправки скрипт сайта уводит на «Спасибо»). Разметка формы — lead-form.tpl.

  Вариант «акция» (страница копирайтинга, «Знижка 10% / Замовте написання текстів вже зараз»):
    {include 'file:chunks/rd/lead.tpl' tv='cw_order' fid='form-bl4' file=1}
  поля — TV с префиксом tv: _badge (золотая «таблетка» над заголовком, пусто — без неё), _title (золото — <span>),
  _text (жирный — <b>, остаётся в строке), _form_title, _btn (надпись кнопки). Телефон и e-mail — в одну строку,
  file=1 — поле «Прикріпити файл з ТЗ» (FormIt прикладывает файл к письму; на сервере не сохраняется).
  fid — id формы: form-bl4 / form-bl8 после отправки уводят на «Спасибо» (чанк script); на одной странице — разные.
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $tv = $tv ?: ''}
{set $badge = ''}
{set $note = ''}
{if $tv}
  {set $title = $r[$tv ~ '_title'] ?: ($isRu ? 'Закажите <span>написание</span> текстов уже сейчас' : 'Замовте <span>написання</span> текстів вже зараз')}
  {set $sub = $r[$tv ~ '_text'] | strip_tags : '<b><strong><br>' | trim}
  {set $badge = $r[$tv ~ '_badge'] | strip_tags | trim}
{else}
  {set $title = $r['title-bl10'] ?: ($isRu ? 'Готовы заказать <span>создание</span> сайта?' : 'Готові замовити <span>створення</span> сайту?')}
  {set $sub = $r['sub-title-bl10'] | strip_tags : '<b><strong><br>' | trim}
  {* жирный фрагмент — отдельной строкой («Грошей за розмови не беремо») *}
  {if $sub | preg_match : '~<(b|strong)>~i'}
    {set $note = $sub | preg_replace : '~^.*?<(b|strong)>(.*?)</\1>.*$~isu' : '$2' | strip_tags | trim}
    {set $sub = $sub | preg_replace : '~<(b|strong)>.*?</\1>~isu' : '' | trim}
  {/if}
{/if}
{set $fid = $fid ?: 'form-bl8'}

<section class="rd-lead{if $tv} rd-lead--promo{/if}" id="{$tv ? ($tv | replace : '_' : '-') : 'order-form'}">
  <span class="rd-lead__glow" aria-hidden="true"></span>
  <div class="rd-container rd-lead__wrap">
    <div class="rd-lead__info">
      {if $badge}
        {* «таблетка» со стопкой за ней; число в ней «досчитывается» (rd-wow.js) *}
        <p class="rd-lead__badge"><span class="rd-lead__badge-back" aria-hidden="true"></span><span class="rd-lead__badge-back rd-lead__badge-back--2" aria-hidden="true"></span><span class="rd-lead__badge-text">{$badge}</span></p>
      {/if}
      <h2 class="rd-lead__title">{$title | strip_tags : '<span><br>'}</h2>
      {if $sub}<p class="rd-lead__text">{$sub}</p>{/if}
      {if $note}<p class="rd-lead__note">{$note}</p>{/if}
    </div>
    <div class="rd-lead__panel">
      [[!AjaxForm?
        &form=`@FILE chunks/rd/lead-form.tpl`
        &snippet=`FormIt`
        &hooks=`spam,email,FormItSaveForm,GoogleSheetsSaveForm`
        &emailSubject=`Заявка "[[++tema.form]]"`
        &emailTo=`[[++form-mail]]`
        &emailFrom=`[[++form-mail]]`
        &emailFromName=`[[++site_name]]`
        &emailTpl=`tpl.email`
        &fiarSubject=`Спасибо за Ваше сообщение!`
        &fiarTpl=`tpl.email.client`
        &fiarFromName=`[[++site_name]]`
        &fiarFrom=`[[++form-mail]]`
        &spamCheckIp=`true`
        &validate=`name:required,phone:minLength=^10^:required,workemail:blank,first-name:blank`
        &validationErrorMessage=`Пожалуйста, заполните обязательные поля*`
        &successMessage=`Ваше сообщение было успешно отправлено!`
        &frontend_css=``
        &frontend_js=``
        &formFields=`name,phone,email,title,link,first-name{if $file},tz{/if}`
        &rdTv=`{$tv}`
        &rdId=`{$fid}`
        &rdFile=`{$file ? 1 : ''}`
      ]]
    </div>
  </div>
</section>
