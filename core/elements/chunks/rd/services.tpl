{*
  Редизайн: блок «Як ми розвиваємо ваш бізнес».
  Поля (TV): title_bl1_services — заголовок (золотое слово оберните в <span>),
  text_bl1_services — подзаголовок (можно <b>), services_bl1_services — MIGX: title, text, link.
  Номера 01, 02, 03 ставятся автоматически по порядку.
*}
{set $r = $_modx->resource}
{set $img = '/assets/templates/rd/img/'}
{set $items = $r['services_bl1_services'] | json_decode : true}

<section class="rd-services" id="yak1">
  <div class="rd-container rd-services__wrap">
    <div class="rd-services__heading">
      {if $r['title_bl1_services']}
        <h2 class="rd-services__title">{$r['title_bl1_services'] | strip_tags : '<span><br>'}</h2>
      {/if}
      {if $r['text_bl1_services']}
        <p class="rd-services__text">{$r['text_bl1_services'] | strip_tags : '<b><strong><br><a>'}</p>
      {/if}
    </div>

    {if $items}
      <div class="rd-services__list">
        {foreach $items as $i => $item}
          {set $link = $item.link}
          {if $link && ($link | preg_match : '/^\d+$/')}{set $link = $link | url}{/if}
          <article class="rd-service">
            <span class="rd-service__fill" aria-hidden="true"><span></span></span>
            <div class="rd-service__row">
              <div class="rd-service__text">
                <div class="rd-service__head">
                  <span class="rd-service__num">{($i + 1) < 10 ? '0' ~ ($i + 1) : ($i + 1)}</span>
                  <h3 class="rd-service__title">
                    {if $link}<a href="{$link}">{$item.title}</a>{else}{$item.title}{/if}
                  </h3>
                </div>
                {if $item.text}
                  <div class="rd-service__desc">{$item.text}</div>
                {/if}
              </div>
              {if $link}
                <span class="rd-service__arrow" aria-hidden="true">
                  <span class="rd-arrow"><img class="rd-arrow__a" src="{$img}arrow-narrow-up-right-srv.svg" width="36" height="36" alt=""><img class="rd-arrow__b" src="{$img}arrow-narrow-up-right-srv.svg" width="36" height="36" alt=""></span>
                </span>
              {/if}
            </div>
          </article>
        {/foreach}
      </div>
    {/if}
  </div>
</section>
