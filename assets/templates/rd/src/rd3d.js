/*
 * Общая сборка 3D-объектов редизайна (одна копия three.js на страницу):
 *   blob.js   — золотой объект первого экрана ([data-rd-glob]);
 *   spiral.js — золотая спираль блока «Digital агентство» ([data-rd-3d]);
 *   ico.js    — золотой икосаэдр SEO-блока главной ([data-rd-ico]).
 * Каждый модуль сам проверяет, есть ли его разметка на странице.
 *
 * Сборка (из каталога с node_modules three@0.158.0 и esbuild@0.19.12):
 *   npx esbuild assets/templates/rd/src/rd3d.js --bundle --minify --format=iife \
 *     --target=es2018 --outfile=assets/templates/rd/js/rd-blob.js
 * (имя файла rd-blob.js сохранено — на него ссылаются hero.tpl, about.tpl и seo.tpl)
 * Без npm: esbuild 0.19.12 собран из исходников (Go), three r158 — из git; см. local/build3d.sh (--preserve-symlinks)
 */
import './blob.js';
import './spiral.js';
import './ico.js';
