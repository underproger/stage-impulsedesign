{* Редизайн: стили и шрифт. Подключается в конце чанка head. Версия = время изменения файла. *}
{set $rdPath = $.const.MODX_ASSETS_PATH ~ 'templates/rd/'}
<link rel="preload" href="/assets/templates/rd/fonts/roboto-flex-wide-cyrillic.woff2" as="font" type="font/woff2" crossorigin>
<link rel="stylesheet" href="/assets/templates/rd/css/rd.css?v={$.php.filemtime($rdPath ~ 'css/rd.css')}">
{* Слой анимаций: включается до отрисовки, чтобы не мигало; если rd-wow.js не загрузился за 4 с — выключается.
   Переход между страницами: если предыдущая страница закрылась кругом (метка rd-pt в sessionStorage:
   «время|x|y», x и y — точка клика в долях окна), новая стартует закрытой (html.rd-pt-in) и открывается
   в rd-wow.js из той же точки (data-rd-pt на <html>); страховка — снять через 2.5 с.
   Важно: после каждой { в JS — пробел, иначе Fenom примет её за тег *}
<script>
  (function (d) { try { if (!matchMedia('(prefers-reduced-motion: reduce)').matches) { d.classList.add('rd-wow-js'); setTimeout(function () { if (!d.classList.contains('rd-wow-ready')) d.classList.remove('rd-wow-js'); }, 4000); var v = (sessionStorage.getItem('rd-pt') || '').split('|'); if (+v[0] && Date.now() - v[0] < 8000) { d.classList.add('rd-pt-in'); if (v.length > 2) d.setAttribute('data-rd-pt', v[1] + ' ' + v[2]); setTimeout(function () { d.classList.remove('rd-pt-in'); }, 2500); } sessionStorage.removeItem('rd-pt'); } } catch (e) { } })(document.documentElement);
</script>
