<form class="rd-lead__form" id="{$rdId ?: 'form-bl8'}" action="#" method="post"{if $rdFile} enctype="multipart/form-data"{/if} novalidate data-rd-lead>
{* Форма блока «Готові замовити створення сайту?» (lead.tpl). Выводится через AjaxForm (&form=`@FILE chunks/rd/lead-form.tpl`):
   AjaxForm сам добавит форме класс ajax_form и скрытое поле af_action, поэтому тег <form> — первой строкой и в одну строку.
   Имена полей — как у старой формы (письмо tpl.email, FormItSaveForm, Google-таблица). id form-bl8 — по нему
   скрипт сайта (чанк script, af_complete) уводит на «Спасибо». Поля .error_<имя> заполняет AjaxForm при ошибке,
   текст ошибки берётся из data-msg (rd.js). Проверка до отправки и плавающие подписи — rd.js.
   Параметры из вызова AjaxForm (lead.tpl): rdId — id формы, rdTv — префикс TV варианта «акция» (заголовок формы
   и надпись кнопки — rdTv_form_title / rdTv_btn; телефон и e-mail — в одну строку), rdFile — поле файла ТЗ (name="tz").
   id полей — от id формы (у основной — rd-lead-*): на странице может быть две формы. *}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $tv = $rdTv ?: ''}
{set $p = ($rdId && $rdId != 'form-bl8') ? ('rd-' ~ $rdId) : 'rd-lead'}
{if $tv}
  {set $ftitle = $r[$tv ~ '_form_title'] ?: ($isRu ? 'Заполните <span>заявку</span> и мы вам перезвоним' : 'Заповніть <span>заявку</span> і ми вам передзвонимо')}
{else}
  {set $ftitle = $r['form-title-bl10'] ?: ($isRu ? 'Заявка на онлайн или <span>офлайн</span> встречу' : 'Заявка на онлайн або <span>офлайн</span> зустріч')}
{/if}
{set $policy = $r['policy-link-bl10'] | trim}
{if !$policy}{set $policy = ($isRu ? ('policy-link' | option) : ('policy-link-ua' | option)) | trim}{/if}
{if $policy && ($policy | preg_match : '/^\d+$/')}{set $policy = $policy | url}{/if}
{set $btn = ($tv ? ($r[$tv ~ '_btn'] | strip_tags | trim) : '') ?: ($isRu ? 'Оставить заявку' : 'Залишити заявку')}
  <input class="rd-lead__hp" type="text" name="first-name" value="" tabindex="-1" autocomplete="off" aria-hidden="true">
  <p class="rd-lead__ftitle">{$ftitle | strip_tags : '<span><br>'}</p>
  <div class="rd-lead__fields">
    <div class="rd-field">
      <input class="rd-field__input" id="{$p}-name" name="name" type="text" value="" placeholder=" " autocomplete="name" required aria-describedby="{$p}-name-err">
      <label class="rd-field__label" for="{$p}-name">{$isRu ? 'Ваше имя' : "Ваше ім'я"}</label>
      <span class="rd-field__line" aria-hidden="true"></span>
      <span class="rd-field__err error_name" id="{$p}-name-err" data-msg="{$isRu ? 'Укажите, как к вам обращаться' : 'Вкажіть, як до вас звертатися'}"></span>
    </div>
    {if $tv}<div class="rd-lead__row">{/if}
    <div class="rd-field rd-field--tel">
      <input class="rd-field__input" id="{$p}-phone" name="phone" type="tel" value="" placeholder=" " autocomplete="tel" inputmode="tel" required aria-describedby="{$p}-phone-err">
      <label class="rd-field__label" for="{$p}-phone">{$isRu ? 'Ваш номер телефона' : 'Ваш номер телефону'}</label>
      <span class="rd-field__line" aria-hidden="true"></span>
      <span class="rd-field__err error_phone" id="{$p}-phone-err" data-msg="{$isRu ? 'Укажите номер телефона полностью' : 'Вкажіть номер телефону повністю'}"></span>
    </div>
    <div class="rd-field">
      <input class="rd-field__input" id="{$p}-email" name="email" type="email" value="" placeholder=" " autocomplete="email" aria-describedby="{$p}-email-err">
      <label class="rd-field__label" for="{$p}-email">{$isRu ? 'Ваш e-mail' : 'Ваш e-mail'}</label>
      <span class="rd-field__line" aria-hidden="true"></span>
      <span class="rd-field__err error_email" id="{$p}-email-err" data-msg="{$isRu ? 'Проверьте e-mail' : 'Перевірте e-mail'}"></span>
    </div>
    {if $tv}</div>{/if}
  </div>
  {if $rdFile}
    {* файл ТЗ: поле спрятано, кликается рамка-подпись; можно перетащить файл. Проверка типа и размера — rd.js *}
    <div class="rd-file" data-rd-file data-max="10" data-msg-size="{$isRu ? 'Файл больше 10 МБ — пришлите ссылку или сожмите' : 'Файл більше 10 МБ — надішліть посилання або стисніть'}" data-msg-type="{$isRu ? 'Подойдёт документ: DOC, DOCX, PDF, TXT, RTF, ODT, XLS(X), PPT(X)' : 'Підійде документ: DOC, DOCX, PDF, TXT, RTF, ODT, XLS(X), PPT(X)'}" data-drop="{$isRu ? 'Отпустите файл здесь' : 'Відпустіть файл тут'}">
      <input class="rd-file__input" id="{$p}-tz" type="file" name="tz" accept=".doc,.docx,.pdf,.txt,.rtf,.odt,.xls,.xlsx,.ppt,.pptx" aria-describedby="{$p}-tz-err">
      <label class="rd-file__box" for="{$p}-tz">
        <svg class="rd-file__frame" aria-hidden="true"><rect class="rd-file__dash" width="100%" height="100%" rx="8" ry="8"/><rect class="rd-file__solid" width="100%" height="100%" rx="8" ry="8" pathLength="1"/></svg>
        <svg class="rd-file__ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m21.15 10.9-9.02 9.02a5.25 5.25 0 0 1-7.43-7.43l9.02-9.02a3.5 3.5 0 0 1 4.95 4.95l-8.66 8.66a1.75 1.75 0 0 1-2.48-2.48l8-8"/></svg>
        <span class="rd-file__text" data-empty="{$isRu ? 'Прикрепить файл с ТЗ' : 'Прикріпити файл з ТЗ'}">{$isRu ? 'Прикрепить файл с ТЗ' : 'Прикріпити файл з ТЗ'}</span>
        <span class="rd-file__size"></span>
      </label>
      <button class="rd-file__clear" type="button" aria-label="{$isRu ? 'Убрать файл' : 'Прибрати файл'}" hidden><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg></button>
      <span class="rd-field__err rd-file__err error_tz" id="{$p}-tz-err"></span>
    </div>
  {/if}
  <input type="hidden" name="title" value="{$r.pagetitle | escape}{if $tv && ($r[$tv ~ '_badge'] | trim)} — {$r[$tv ~ '_badge'] | strip_tags | trim | escape}{/if}">
  <input type="hidden" name="link" value="{$r.uri | escape}">
  <input type="hidden" name="workemail" value="">
  <input type="hidden" name="nospam:blank" value="">
  <button class="rd-lead__send" type="submit">
    <span class="rd-lead__send-fill" aria-hidden="true"><span></span></span>
    <span class="rd-lead__send-text">{$btn}</span>
    <span class="rd-lead__send-arrow rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="/assets/templates/rd/img/arrow-up-right.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="/assets/templates/rd/img/arrow-up-right-gold.svg" width="24" height="24" alt=""></span>
  </button>
  <p class="rd-lead__agree">{$isRu ? 'Нажимая' : 'Натискаючи'} “{$btn}”, {$isRu ? 'я соглашаюсь с' : 'я погоджуюсь з'} {if $policy}<a href="{$policy}">{$isRu ? 'Политикой конфиденциальности' : 'Політикою конфіденційності'}</a>{else}<span>{$isRu ? 'Политикой конфиденциальности' : 'Політикою конфіденційності'}</span>{/if}</p>
  <p class="rd-lead__status" role="status" aria-live="polite" data-fail="{$isRu ? 'Не удалось отправить заявку. Попробуйте ещё раз или позвоните нам.' : 'Не вдалося надіслати заявку. Спробуйте ще раз або зателефонуйте нам.'}"></p>
</form>
