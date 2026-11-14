{* Отзыв посетителя на странице «Відгуки» — строка ecMessages (reviews.tpl, &tpl=`@FILE chunks/rd/review-msg.tpl`).
   Поля easyComm: user_name, text, rating (0 — без звёзд), date, reply_author / reply_text (ответ из админки). *}
{set $isRu = $_modx->context.key == 'web'}
{set $nm = $user_name | strip_tags | trim}
{set $rt = $rating | intval}
{set $star = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2.2l2.95 6.6 7.2.66-5.45 4.78 1.63 7.06L12 17.6 5.67 21.3l1.63-7.06L1.85 9.46l7.2-.66z"/></svg>'}
<article class="rd-rcard" id="message-{$id}" data-rating="{$rt}">
  <header class="rd-rcard__head">
    <span class="rd-rcard__ava rd-rcard__ava--letter" aria-hidden="true">{$.php.mb_strtoupper($.php.mb_substr($nm, 0, 1))}</span>
    <span class="rd-rcard__who">
      <span class="rd-rcard__name">{$nm}</span>
      <time class="rd-rcard__role" datetime="{$.php.date('Y-m-d', $.php.strtotime($date))}">{$.php.date('d.m.Y', $.php.strtotime($date))}</time>
    </span>
    {if $rt > 0}
      <span class="rd-rev__stars" role="img" aria-label="{$isRu ? 'Оценка' : 'Оцінка'}: {$rt} / 5" style="--p: {$rt * 20}%">
        <span class="rd-rev__stars-bg">{for $s=1 to=5}{$star}{/for}</span>
        <span class="rd-rev__stars-fg">{for $s=1 to=5}{$star}{/for}</span>
      </span>
    {/if}
  </header>
  <blockquote class="rd-rcard__text"><p>{$text | nl2br}</p></blockquote>
  {if $reply_text | trim}
    <div class="rd-rcard__reply">
      <p class="rd-rcard__reply-who">{($reply_author | strip_tags | trim) ?: ($isRu ? 'Ответ Impulse Design' : 'Відповідь Impulse Design')}</p>
      <p>{$reply_text | nl2br}</p>
    </div>
  {/if}
</article>
