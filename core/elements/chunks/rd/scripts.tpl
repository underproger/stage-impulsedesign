{* Редизайн: скрипты. Подключается в конце чанка script. *}
{set $rdPath = $.const.MODX_ASSETS_PATH ~ 'templates/rd/'}
<script src="/assets/templates/rd/js/rd.js?v={$.php.filemtime($rdPath ~ 'js/rd.js')}" defer></script>
