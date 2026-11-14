{*
  Редизайн: модалка «Обговорити проект» на всём сайте (подключается в конце chunks/rd/footer.tpl).
  Открывают кнопки с data-rd-discuss (первый экран главной/услуг/«Про нас», «Обговорити проект» в «Гарантіях»
  и «Про нас», карточка в статье блога) — если их ссылка ведёт на «Контакти» (или пустая / #discuss);
  ссылка, которую в админке поменяли на другую страницу, работает как обычно. В тексте страницы — ссылка «#discuss».
  Ctrl/⌘/средняя кнопка — открыть «Контакти» в новой вкладке, как обычную ссылку. Логика — rd.js, «вау» — rd-wow.js,
  стили — _dsc.scss. Форма — chunks/rd/discuss-form.tpl через AjaxForm (те же письма и хуки, что у формы заявки),
  после отправки — страница «Спасибо» (ID 40, переход делает rd.js по data-thanks).
  Данные: ClientConfig — phone-1, e-mail, telegram, viber, whatsapp.
*}
{set $isRu = $_modx->context.key == 'web'}
{set $img = '/assets/templates/rd/img/'}
{set $d = $isRu ? [
  'title' => 'Обсудить <span>проект</span>',
  'text' => 'Оставьте контакты и пару слов об идее — мы свяжемся с вами, чтобы обсудить детали.',
  'phone' => 'Телефон',
  'mail' => 'E-mail',
  'msg' => 'Мессенджеры',
  'close' => 'Закрыть'
] : [
  'title' => 'Обговорити <span>проект</span>',
  'text' => 'Залиште контакти та кілька слів про ідею — ми зв’яжемося з вами, щоб обговорити деталі.',
  'phone' => 'Телефон',
  'mail' => 'E-mail',
  'msg' => 'Месенджери',
  'close' => 'Закрити'
]}
{set $dPhone = ('phone-1' | option)}
{set $dPhoneHref = $dPhone | preg_replace : '/[^0-9+]/' : ''}
{set $dMail = ('e-mail' | option)}
{set $dCnt = $isRu ? 3 : 451}
{set $dMsgs = [
  ['url' => ('telegram' | option), 'icon' => 'soc-telegram.svg', 'label' => 'Telegram'],
  ['url' => ('viber' | option), 'icon' => 'soc-viber.svg', 'label' => 'Viber'],
  ['url' => ('whatsapp' | option), 'icon' => 'soc-whatsapp.svg', 'label' => 'WhatsApp']
]}
<div class="rd-dsc" id="rd-discuss" role="dialog" aria-modal="true" aria-labelledby="rd-dsc-title" hidden data-rd-dsc data-contacts="{$dCnt | url}" data-thanks="{40 | url}">
  <div class="rd-dsc__backdrop" data-rd-dsc-close aria-hidden="true"></div>
  <div class="rd-dsc__scroll" data-rd-no-smooth>
    <div class="rd-dsc__panel" tabindex="-1">
      <span class="rd-dsc__glow" aria-hidden="true"></span>
      <button class="rd-dsc__close" type="button" aria-label="{$d.close}" data-rd-dsc-close>
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>
      </button>
      <div class="rd-dsc__info">
        <p class="rd-dsc__title" id="rd-dsc-title">{$d.title}</p>
        <p class="rd-dsc__text">{$d.text}</p>
        <ul class="rd-dsc__contacts">
          {if $dPhone}
            <li class="rd-dsc__contact"><span class="rd-dsc__label">{$d.phone}</span><a class="rd-dsc__value" href="tel:{$dPhoneHref}">{$dPhone}</a></li>
          {/if}
          {if $dMail}
            <li class="rd-dsc__contact"><span class="rd-dsc__label">{$d.mail}</span><a class="rd-dsc__value" href="mailto:{$dMail}">{$dMail}</a></li>
          {/if}
          <li class="rd-dsc__contact">
            <span class="rd-dsc__label">{$d.msg}</span>
            <span class="rd-dsc__msgs">
              {foreach $dMsgs as $m}
                {if $m.url}
                  <a class="rd-dsc__msg" href="{$m.url}" rel="nofollow noopener"{if $m.url | preg_match : '~^https?:~'} target="_blank"{/if} aria-label="{$m.label}"><span style="--rd-icon: url({$img}{$m.icon})" aria-hidden="true"></span></a>
                {/if}
              {/foreach}
            </span>
          </li>
        </ul>
      </div>
      <div class="rd-dsc__form">
        [[!AjaxForm?
          &form=`@FILE chunks/rd/discuss-form.tpl`
          &snippet=`FormIt`
          &hooks=`spam,email,FormItSaveForm,GoogleSheetsSaveForm`
          &emailSubject=`Заявка "Обсудить проект"`
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
          &formFields=`name,phone,email,theme,title,link,first-name`
        ]]
      </div>
    </div>
  </div>
</div>
