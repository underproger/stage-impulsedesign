{* Отзыв отправлен — ecForm (reviews.tpl, &tplSuccess): easyComm кладёт это в #ec-form-success-… и прячет форму *}
{set $isRu = $_modx->context.key == 'web'}
<div class="rd-rev__ok">
  <span class="rd-rev__ok-ic" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg></span>
  <p class="rd-rev__ok-title">{$isRu ? 'Спасибо за отзыв!' : 'Дякуємо за відгук!'}</p>
  <p class="rd-rev__ok-text">{$isRu ? 'Он появится на странице после проверки модератором.' : 'Він з’явиться на сторінці після перевірки модератором.'}</p>
</div>
