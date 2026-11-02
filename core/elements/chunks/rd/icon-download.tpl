{*
  Иконка «скачать» (облако + стрелка): на наведении ссылки с классом .rd-dl стрелка «скачивается» —
  уходит вниз и снова выезжает из облака, облако чуть пружинит (стили — _layout.scss).
  Подключение: {include 'file:chunks/rd/icon-download.tpl' id='уникальный-id'} — id нужен для clipPath, на странице не повторять.
*}
<svg class="rd-dl__icon" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
  <defs><clipPath id="{$id}"><rect x="0" y="9.5" width="24" height="15"/></clipPath></defs>
  <path class="rd-dl__cloud" d="M20 16.743A5.5 5.5 0 0 0 16.5 7c-.218 0-.423-.114-.534-.302A7.5 7.5 0 1 0 4.187 15.794"/>
  <g clip-path="url(#{$id})"><path class="rd-dl__down" d="M8 17l4 4 4-4M12 21v-9"/></g>
</svg>
