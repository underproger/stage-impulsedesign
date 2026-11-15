/*
 * Общий запуск 3D-модулей: все блоки модуля на странице (на «Послуги студії» их несколько).
 * Каждый блок запускается, когда подъезжает к экрану (за полэкрана до него): объект первого экрана — сразу,
 * остальные — по мере прокрутки; лишние WebGL-контексты и шейдеры не собираются при загрузке страницы.
 * Грузит модуль rd.js — только при видеокарте (не программный рендер) и не на слабых устройствах.
 * Без WebGL / при reduced motion ничего не запускается — остаются картинки.
 */
let webgl;

function hasWebGL() {
  if (webgl === undefined) {
    try {
      const test = document.createElement('canvas');
      webgl = !!(test.getContext('webgl2') || test.getContext('webgl'));
    } catch (e) {
      webgl = false;
    }
  }
  return webgl;
}

export function mountAll(selector, make) {
  const run = () => {
    const els = Array.prototype.slice.call(document.querySelectorAll(selector));
    if (!els.length) return;
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    if (!hasWebGL()) return;
    const start = (el) => {
      try {
        make(el);
      } catch (e) {
        /* без WebGL остаётся картинка */
      }
    };
    if (!('IntersectionObserver' in window)) {
      els.forEach(start);
      return;
    }
    // каждый блок — когда подъезжает к экрану (за полэкрана до него): объект первого экрана стартует сразу,
    // спираль и икосаэдр внизу главной не собираются при загрузке страницы, пока до них не докрутили
    const io = new IntersectionObserver((entries) => {
      entries.forEach((e) => {
        if (!e.isIntersecting) return;
        io.unobserve(e.target);
        start(e.target);
      });
    }, { rootMargin: '50% 0px' });
    els.forEach((el) => io.observe(el));
  };
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', run);
  else run();
}
