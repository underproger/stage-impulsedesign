{*
  Редизайн: блок-форма «Готові замовити створення сайту?» — section 8 макета. Заменяет старый чанк bl10-form,
  включается тем же чекбоксом display_bl10. Поля (категория «Блок 10 - Форма»):
    title-bl10        — заголовок (золотое слово — в <span>)
    sub-title-bl10    — текст; жирный фрагмент (<b>) выводится отдельной строкой под текстом
    form-title-bl10   — заголовок формы (золото — в <span>)
    policy-link-bl10  — ID или URL «Політики конфіденційності» (пусто — без ссылки)
  Форма — тот же AjaxForm + FormIt, что у старого блока (хуки, письма, Google-таблица, id form-bl8 —
  после успешной отправки скрипт сайта уводит на «Спасибо»). Разметка формы — lead-form.tpl.
*}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $title = $r['title-bl10'] ?: ($isRu ? 'Готовы заказать <span>создание</span> сайта?' : 'Готові замовити <span>створення</span> сайту?')}
{set $sub = $r['sub-title-bl10'] | strip_tags : '<b><strong><br>' | trim}
{* жирный фрагмент — отдельной строкой («Грошей за розмови не беремо») *}
{set $note = ''}
{if $sub | preg_match : '~<(b|strong)>~i'}
  {set $note = $sub | preg_replace : '~^.*?<(b|strong)>(.*?)</\1>.*$~isu' : '$2' | strip_tags | trim}
  {set $sub = $sub | preg_replace : '~<(b|strong)>.*?</\1>~isu' : '' | trim}
{/if}

<section class="rd-lead" id="order-form">
  <span class="rd-lead__glow" aria-hidden="true"></span>
  <div class="rd-container rd-lead__wrap">
    <div class="rd-lead__info">
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
        &formFields=`name,phone,email,title,link,first-name`
      ]]
    </div>
  </div>
</section>
