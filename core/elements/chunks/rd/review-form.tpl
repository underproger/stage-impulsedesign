{* Форма «Залишити відгук» на странице «Відгуки» — ecForm (reviews.tpl, &tplForm=`@FILE chunks/rd/review-form.tpl`).
   Отправляет easyComm (custom.js: submit на form.ec-form, ошибки — в #ec-<поле>-error-<fid>, успех — в #ec-form-success-<fid>).
   Обязательные поля easyComm — имя и текст; e-mail не публикуется (письмо о публикации). Звёзды — .ec-rating (easyComm
   ставит классы active / active2 / active-disabled, значение — в скрытое rating). Проверка до отправки, подписи полей,
   клавиатура на звёздах и тексты ошибок — rd.js ([data-rd-rev-form]). Поле {$antispam_field} — ловушка для ботов. *}
{set $isRu = $_modx->context.key == 'web'}
{set $t = $isRu
  ? ['title' => 'Оставить <span>отзыв</span>', 'sub' => 'Расскажите, как вам работалось с нами. Отзыв появится на странице после проверки.',
     'name' => 'Ваше имя', 'mail' => 'Ваш e-mail', 'rate' => 'Ваша оценка', 'text' => 'Ваш отзыв', 'btn' => 'Отправить отзыв',
     'note' => 'E-mail не публикуется — на него придёт письмо, когда отзыв появится на сайте.',
     'eName' => 'Укажите, как к вам обращаться', 'eMail' => 'Проверьте e-mail', 'eText' => 'Напишите пару слов о работе с нами',
     'fail' => 'Не удалось отправить отзыв. Попробуйте ещё раз.',
     'r' => ['Плохо', 'Так себе', 'Нормально', 'Хорошо', 'Отлично'], 'of' => 'из 5']
  : ['title' => 'Залишити <span>відгук</span>', 'sub' => 'Розкажіть, як вам працювалося з нами. Відгук з’явиться на сторінці після перевірки.',
     'name' => "Ваше ім'я", 'mail' => 'Ваш e-mail', 'rate' => 'Ваша оцінка', 'text' => 'Ваш відгук', 'btn' => 'Надіслати відгук',
     'note' => 'E-mail не публікується — на нього прийде лист, коли відгук з’явиться на сайті.',
     'eName' => 'Вкажіть, як до вас звертатися', 'eMail' => 'Перевірте e-mail', 'eText' => 'Напишіть кілька слів про роботу з нами',
     'fail' => 'Не вдалося надіслати відгук. Спробуйте ще раз.',
     'r' => ['Погано', 'Так собі', 'Нормально', 'Добре', 'Чудово'], 'of' => 'з 5']}
{set $star = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2.2l2.95 6.6 7.2.66-5.45 4.78 1.63 7.06L12 17.6 5.67 21.3l1.63-7.06L1.85 9.46l7.2-.66z"/></svg>'}
{set $rates = $t.r}
<form class="ec-form rd-rev__f" method="post" id="ec-form-{$fid}" data-fid="{$fid}" action="" novalidate data-rd-rev-form data-fail="{$t.fail}">
  <input type="hidden" name="thread" value="{$thread}">
  <div class="ec-antispam" aria-hidden="true">
    <input type="text" name="{$antispam_field}" id="ec-{$antispam_field}-{$fid}" value="" tabindex="-1" autocomplete="off">
  </div>
  <p class="rd-rev__ftitle">{$t.title}</p>
  <p class="rd-rev__fsub">{$t.sub}</p>
  <div class="rd-rev__fields">
    <div class="rd-field form-group">
      <input class="rd-field__input" id="ec-user_name-{$fid}" name="user_name" type="text" value="{$user_name}" placeholder=" " autocomplete="name" required aria-describedby="ec-user_name-error-{$fid}">
      <label class="rd-field__label" for="ec-user_name-{$fid}">{$t.name}<i>*</i></label>
      <span class="rd-field__line" aria-hidden="true"></span>
      <span class="rd-field__err ec-error" id="ec-user_name-error-{$fid}" data-msg="{$t.eName}"></span>
    </div>
    <div class="rd-field form-group">
      <input class="rd-field__input" id="ec-user_email-{$fid}" name="user_email" type="email" value="{$user_email}" placeholder=" " autocomplete="email" aria-describedby="ec-user_email-error-{$fid}">
      <label class="rd-field__label" for="ec-user_email-{$fid}">{$t.mail}</label>
      <span class="rd-field__line" aria-hidden="true"></span>
      <span class="rd-field__err ec-error" id="ec-user_email-error-{$fid}" data-msg="{$t.eMail}"></span>
    </div>
  </div>
  <div class="rd-rev__rate form-group">
    <span class="rd-rev__rate-label" id="ec-rating-label-{$fid}">{$t.rate}</span>
    <input type="hidden" name="rating" id="ec-rating-{$fid}" value="0">
    <div class="ec-rating" data-storage-id="ec-rating-{$fid}">
      <div class="ec-rating-stars" role="radiogroup" aria-labelledby="ec-rating-label-{$fid}">
        {foreach $rates as $k => $rdesc}
          <span data-rating="{$k + 1}" data-description="{$rdesc}" role="radio" aria-checked="false" tabindex="{$k == 4 ? 0 : -1}" aria-label="{$k + 1} {$t.of} — {$rdesc}">{$star}</span>
        {/foreach}
      </div>
      <span class="ec-rating-description" aria-hidden="true"></span>
    </div>
    <span class="rd-field__err ec-error" id="ec-rating-error-{$fid}"></span>
  </div>
  <div class="rd-field rd-field--area form-group">
    <textarea class="rd-field__input" id="ec-text-{$fid}" name="text" rows="4" placeholder=" " maxlength="3000" required aria-describedby="ec-text-error-{$fid}"></textarea>
    <label class="rd-field__label" for="ec-text-{$fid}">{$t.text}<i>*</i></label>
    <span class="rd-field__line" aria-hidden="true"></span>
    <span class="rd-field__err ec-error" id="ec-text-error-{$fid}" data-msg="{$t.eText}"></span>
  </div>
  {$recaptcha}
  <button class="rd-lead__send rd-rev__send" type="submit">
    <span class="rd-lead__send-fill" aria-hidden="true"><span></span></span>
    <span class="rd-lead__send-text">{$t.btn}</span>
    <span class="rd-lead__send-arrow rd-arrow" aria-hidden="true"><img class="rd-arrow__a" src="/assets/templates/rd/img/arrow-up-right.svg" width="24" height="24" alt=""><img class="rd-arrow__b" src="/assets/templates/rd/img/arrow-up-right-gold.svg" width="24" height="24" alt=""></span>
  </button>
  <p class="rd-rev__note">{$t.note}</p>
  <p class="rd-lead__status" role="status" aria-live="polite" data-rd-rev-status></p>
</form>
<div class="rd-rev__success" id="ec-form-success-{$fid}" role="status" aria-live="polite"></div>
