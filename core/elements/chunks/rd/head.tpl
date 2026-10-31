{* Редизайн: стили и шрифт. Подключается в конце чанка head. Версия = время изменения файла. *}
{set $rdPath = $.const.MODX_ASSETS_PATH ~ 'templates/rd/'}
<link rel="preload" href="/assets/templates/rd/fonts/roboto-flex-wide-cyrillic.woff2" as="font" type="font/woff2" crossorigin>
<link rel="stylesheet" href="/assets/templates/rd/css/rd.css?v={$.php.filemtime($rdPath ~ 'css/rd.css')}">
