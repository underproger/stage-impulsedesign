{* Редизайн: стили и шрифт. Подключается в конце чанка head. Версия = время изменения файла. *}
{set $rdPath = $.const.MODX_ASSETS_PATH ~ 'templates/rd/'}
<link rel="preload" href="/assets/templates/rd/fonts/roboto-flex-wide-cyrillic.woff2" as="font" type="font/woff2" crossorigin>
<link rel="stylesheet" href="/assets/templates/rd/css/rd.css?v={$.php.filemtime($rdPath ~ 'css/rd.css')}">
{* Слой анимаций: включается до отрисовки, чтобы не мигало; если rd-wow.js не загрузился за 4 с — выключается.
   Важно: после каждой { в JS — пробел, иначе Fenom примет её за тег *}
<script>
  (function (d) { try { if (!matchMedia('(prefers-reduced-motion: reduce)').matches) { d.classList.add('rd-wow-js'); setTimeout(function () { if (!d.classList.contains('rd-wow-ready')) d.classList.remove('rd-wow-js'); }, 4000); } } catch (e) { } })(document.documentElement);
</script>
