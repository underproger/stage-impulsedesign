<form class="rd-lead__form rd-dsc__f" id="form-discuss" action="#" method="post" novalidate data-rd-lead>
{* Форма модалки «Обговорити проект» (chunks/rd/discuss.tpl). Выводится через AjaxForm (&form=`@FILE chunks/rd/discuss-form.tpl`):
   AjaxForm сам добавит форме класс ajax_form и скрытое поле af_action, поэтому тег <form> — первой строкой и в одну строку.
   Поля и проверка — как у формы заявки (lead-form.tpl, rd.js: data-rd-lead), плюс «Розкажіть про свою ідею» (name="theme" —
   это поле уже есть в письме tpl.email). Имя, телефон — обязательные. id формы — form-discuss: на «Спасибо» уводит rd.js. *}
{set $r = $_modx->resource}
{set $isRu = $_modx->context.key == 'web'}
{set $p = 'rd-dsc'}
{set $policy = ($isRu ? ('policy-link' | option) : ('policy-link-ua' | option)) | trim}
{if $policy && ($policy | preg_match : '/^\d+$/')}{set $policy = $policy | url}{/if}
{set $btn = $isRu ? 'Отправить заявку' : 'Надіслати заявку'}
  <input class="rd-lead__hp" type="text" name="first-name" value="" tabindex="-1" autocomplete="off" aria-hidden="true">
  <div class="rd-dsc__fields">
    <div class="rd-field">
      <input class="rd-field__input" id="{$p}-name" name="name" type="text" value="" placeholder=" " autocomplete="name" required aria-describedby="{$p}-name-err">
      <label class="rd-field__label" for="{$p}-name">{$isRu ? 'Ваше имя' : "Ваше ім'я"}<i>*</i></label>
      <span class="rd-field__line" aria-hidden="true"></span>
      <span class="rd-field__err error_name" id="{$p}-name-err" data-msg="{$isRu ? 'Укажите, как к вам обращаться' : 'Вкажіть, як до вас звертатися'}"></span>
    </div>
    <div class="rd-field rd-field--tel">
      <input class="rd-field__input" id="{$p}-phone" name="phone" type="tel" value="" placeholder=" " autocomplete="tel" inputmode="tel" required aria-describedby="{$p}-phone-err">
      <label class="rd-field__label" for="{$p}-phone">{$isRu ? 'Ваш номер телефона' : 'Ваш номер телефону'}<i>*</i></label>
      <span class="rd-field__line" aria-hidden="true"></span>
      <span class="rd-field__err error_phone" id="{$p}-phone-err" data-msg="{$isRu ? 'Укажите номер телефона полностью' : 'Вкажіть номер телефону повністю'}"></span>
    </div>
    <div class="rd-field rd-dsc__wide">
      <input class="rd-field__input" id="{$p}-email" name="email" type="email" value="" placeholder=" " autocomplete="email" aria-describedby="{$p}-email-err">
      <label class="rd-field__label" for="{$p}-email">{$isRu ? 'Ваш e-mail' : 'Ваш e-mail'}</label>
      <span class="rd-field__line" aria-hidden="true"></span>
      <span class="rd-field__err error_email" id="{$p}-email-err" data-msg="{$isRu ? 'Проверьте e-mail' : 'Перевірте e-mail'}"></span>
    </div>
    <div class="rd-field rd-field--area rd-dsc__wide">
      <textarea class="rd-field__input" id="{$p}-theme" name="theme" rows="3" placeholder=" " maxlength="3000" aria-describedby="{$p}-theme-err"></textarea>
      <label class="rd-field__label" for="{$p}-theme">{$isRu ? 'Расскажите о своей идее' : 'Розкажіть про свою ідею'}</label>
      <span class="rd-field__line" aria-hidden="true"></span>
      <span class="rd-field__err error_theme" id="{$p}-theme-err"></span>
    </div>
  </div>
  <input type="hidden" name="title" value="{$r.pagetitle | escape} — {$isRu ? 'Обсудить проект' : 'Обговорити проект'}">
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
