<form class="rd-lead__form" id="form-bl8" action="#" method="post" novalidate data-rd-lead>
{* Форма блока «Готові замовити створення сайту?» (lead.tpl). Выводится через AjaxForm (&form=`@FILE chunks/rd/lead-form.tpl`):
   AjaxForm сам добавит форме класс ajax_form и скрытое поле af_action, поэтому тег <form> — первой строкой и в одну строку.
   Имена полей — как у старой формы (письмо tpl.email, FormItSaveForm, Google-таблица). id form-bl8 — по нему
   скрипт сайта (чанк script, af_complete) уводит на «Спасибо». Поля .error_<имя> заполняет AjaxForm при ошибке,
   текст ошибки берётся из data-msg (rd.js). Проверка до отправки и плавающие подписи — rd.js. *}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $ftitle = $r['form-title-bl10'] ?: ($isRu ? 'Заявка на онлайн или <span>офлайн</span> встречу' : 'Заявка на онлайн або <span>офлайн</span> зустріч')}
{set $policy = $r['policy-link-bl10'] | trim}
{if $policy && ($policy | preg_match : '/^\d+$/')}{set $policy = $policy | url}{/if}
{set $btn = $isRu ? 'Оставить заявку' : 'Залишити заявку'}
  <input class="rd-lead__hp" type="text" name="first-name" value="" tabindex="-1" autocomplete="off" aria-hidden="true">
  <p class="rd-lead__ftitle">{$ftitle | strip_tags : '<span><br>'}</p>
  <div class="rd-lead__fields">
    <div class="rd-field">
      <input class="rd-field__input" id="rd-lead-name" name="name" type="text" value="" placeholder=" " autocomplete="name" required aria-describedby="rd-lead-name-err">
      <label class="rd-field__label" for="rd-lead-name">{$isRu ? 'Ваше имя' : "Ваше ім'я"}</label>
      <span class="rd-field__line" aria-hidden="true"></span>
      <span class="rd-field__err error_name" id="rd-lead-name-err" data-msg="{$isRu ? 'Укажите, как к вам обращаться' : 'Вкажіть, як до вас звертатися'}"></span>
    </div>
    <div class="rd-field rd-field--tel">
      <input class="rd-field__input" id="rd-lead-phone" name="phone" type="tel" value="" placeholder=" " autocomplete="tel" inputmode="tel" required aria-describedby="rd-lead-phone-err">
      <label class="rd-field__label" for="rd-lead-phone">{$isRu ? 'Ваш номер телефона' : 'Ваш номер телефону'}</label>
      <span class="rd-field__line" aria-hidden="true"></span>
      <span class="rd-field__err error_phone" id="rd-lead-phone-err" data-msg="{$isRu ? 'Укажите номер телефона полностью' : 'Вкажіть номер телефону повністю'}"></span>
    </div>
    <div class="rd-field">
      <input class="rd-field__input" id="rd-lead-email" name="email" type="email" value="" placeholder=" " autocomplete="email" aria-describedby="rd-lead-email-err">
      <label class="rd-field__label" for="rd-lead-email">{$isRu ? 'Ваш e-mail' : 'Ваш e-mail'}</label>
      <span class="rd-field__line" aria-hidden="true"></span>
      <span class="rd-field__err error_email" id="rd-lead-email-err" data-msg="{$isRu ? 'Проверьте e-mail' : 'Перевірте e-mail'}"></span>
    </div>
  </div>
  <input type="hidden" name="title" value="{$r.pagetitle | escape}">
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
