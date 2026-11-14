/*
 * Общая сборка 3D-объектов редизайна (одна копия three.js на страницу):
 *   liquid.js — жидкое золото с орбитой первого экрана главной ([data-rd-glob]; свой WebGL1, three.js не нужен);
 *   knot.js   — золотой узел / пирамида первого экрана страницы услуги ([data-rd-knot], [data-rd-knot="pyramid"]),
 *               кольцо «0» страницы 404 ([data-rd-knot="ring"]);
 *   spiral.js — золотая спираль блока «Digital агентство» ([data-rd-3d]);
 *   ico.js    — золотой икосаэдр SEO-блока главной ([data-rd-ico]).
 * Каждый модуль сам проверяет, есть ли его разметка на странице; блоков одного вида может быть несколько —
 * общий запуск в mount.js (один блок — сразу, несколько — каждый на подъезде к экрану).
 * Страница «Послуги студії» (svc-list.tpl): узел, икосаэдр, пирамида, спираль — по кругу в карточках разделов.
 *
 * Сборка (из каталога с node_modules three@0.158.0 и esbuild@0.19.12):
 *   npx esbuild assets/templates/rd/src/rd3d.js --bundle --minify --format=iife \
 *     --target=es2018 --outfile=assets/templates/rd/js/rd-blob.js
 * (имя файла rd-blob.js сохранено — на него ссылаются hero.tpl, svc-hero.tpl, about.tpl и seo.tpl)
 * Без npm: esbuild 0.19.12 собран из исходников (Go), three r158 — из git; см. local/build3d.sh (--preserve-symlinks)
 */
import './liquid.js';
import './knot.js';
import './spiral.js';
import './ico.js';
