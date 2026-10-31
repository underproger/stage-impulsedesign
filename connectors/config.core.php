<?php
/*
 * Путь к core вычисляется от расположения файла — работает и локально, и на хостинге
 * без правок под конкретный сервер.
 */
define('MODX_CORE_PATH', dirname(__DIR__) . '/core/');
define('MODX_CONFIG_KEY', 'config');
