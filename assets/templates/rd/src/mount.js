/*
 * Общий запуск 3D-модулей: все блоки модуля на странице (на «Послуги студії» их несколько).
 * Один блок — запускается сразу, как и раньше (первый экран, SEO-блок, спираль section 6);
 * несколько — каждый, когда подъезжает к экрану (за экран до него): лишние WebGL-контексты не создаются заранее.
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
    if (els.length === 1 || !('IntersectionObserver' in window)) {
      els.forEach(start);
      return;
    }
    const io = new IntersectionObserver((entries) => {
      entries.forEach((e) => {
        if (!e.isIntersecting) return;
        io.unobserve(e.target);
        start(e.target);
      });
    }, { rootMargin: '100% 0px' });
    els.forEach((el) => io.observe(el));
  };
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', run);
  else run();
}
