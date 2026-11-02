/*
 * Редизайн: анимации и интерактив (слой «вау»).
 * Работает поверх основной вёрстки: без этого файла сайт полностью рабочий, просто статичный.
 * Включается классом html.rd-wow-js (ставит инлайн-скрипт в head, если не включено «уменьшение движения»).
 */
(function () {
  'use strict';

  var root = document.documentElement;
  if (!root.classList.contains('rd-wow-js')) return;
  root.classList.add('rd-wow-ready');

  var fine = window.matchMedia('(hover: hover) and (pointer: fine)').matches;
  var isRu = (root.getAttribute('lang') || '').indexOf('ru') === 0;
  var raf = window.requestAnimationFrame.bind(window);
  var clamp = function (v, a, b) { return Math.max(a, Math.min(b, v)); };
  var lerp = function (a, b, t) { return a + (b - a) * t; };

  /* ================= Разбивка текста ================= */

  // Буквы: каждая — inline-block span.rd-ch (--i — порядковый номер), слова — span.rd-w без переносов.
  // Мягкий перенос (&shy;) остаётся текстом между кусками слова — браузер может перенести по нему.
  var charIndex = 0;
  function splitChars(el, opts) {
    opts = opts || {};
    var chars = [];
    var walk = function (node) {
      Array.prototype.slice.call(node.childNodes).forEach(function (child) {
        if (child.nodeType === 3) {
          var frag = document.createDocumentFragment();
          child.textContent.split(/(\s+)/).forEach(function (token) {
            if (!token) return;
            if (/^\s+$/.test(token)) {
              frag.appendChild(document.createTextNode(' '));
              return;
            }
            token.split('­').forEach(function (part, pi) {
              if (pi > 0) frag.appendChild(document.createTextNode('­'));
              if (!part) return;
              var w = document.createElement('span');
              w.className = 'rd-w';
              Array.prototype.forEach.call(part, function (c) {
                var s = document.createElement('span');
                s.className = 'rd-ch';
                s.textContent = c;
                s.style.setProperty('--i', opts.local ? chars.length : charIndex++);
                w.appendChild(s);
                chars.push(s);
              });
              frag.appendChild(w);
            });
          });
          child.parentNode.replaceChild(frag, child);
        } else if (child.nodeType === 1 && !child.hasAttribute('data-wow-skip')) {
          walk(child);
        }
      });
    };
    walk(el);
    return chars;
  }

  // Слова целиком (для подзаголовков): вложенные элементы (золотое слово и т.п.) — одним куском
  function splitWords(el) {
    var items = [];
    Array.prototype.slice.call(el.childNodes).forEach(function (child) {
      if (child.nodeType === 3) {
        var frag = document.createDocumentFragment();
        child.textContent.split(/(\s+)/).forEach(function (t) {
          if (!t) return;
          if (/^\s+$/.test(t)) { frag.appendChild(document.createTextNode(' ')); return; }
          var w = document.createElement('span');
          w.className = 'rd-wd';
          w.textContent = t;
          frag.appendChild(w);
          items.push(w);
        });
        child.parentNode.replaceChild(frag, child);
      } else if (child.nodeType === 1 && child.tagName !== 'BR') {
        child.classList.add('rd-wd', 'rd-wd--el');
        items.push(child);
      }
    });
    items.forEach(function (w, i) { w.style.setProperty('--i', i); });
    return items;
  }

  /* ================= Первый экран ================= */

  var hero = document.querySelector('.rd-hero');
  var title = hero && hero.querySelector('.rd-hero__title');
  var titleChars = [];

  if (title) {
    title.setAttribute('aria-label', title.textContent.replace(/­/g, '').replace(/\s+/g, ' ').trim());
    var pill = title.querySelector('.rd-hero__pill');
    if (pill) pill.setAttribute('data-wow-skip', '');
    titleChars = splitChars(title);
    titleChars.forEach(function (c) { c.setAttribute('aria-hidden', 'true'); });
    if (pill) pill.style.setProperty('--i', titleChars.length - 7);
    window.dispatchEvent(new Event('resize')); // перепроверка ширины заголовка (rd.js)
  }

  // шапка: пункты появляются каскадом
  Array.prototype.forEach.call(document.querySelectorAll('.rd-header__bar > *, .rd-nav__item, .rd-lang'), function (el, i) {
    el.style.setProperty('--h', i);
  });

  // слои прожектора: золотая сетка под курсором + мягкий свет
  if (hero) {
    var spot = document.createElement('div');
    spot.className = 'rd-wow-spot';
    spot.innerHTML = '<div class="rd-wow-spot__grid"></div>';
    var glow = document.createElement('div');
    glow.className = 'rd-wow-glow';
    hero.insertBefore(glow, hero.firstChild);
    hero.insertBefore(spot, hero.firstChild);
  }

  // объект: если WebGL так и не запустился — показываем PNG
  var glob = document.querySelector('[data-rd-glob]');
  if (glob) {
    setTimeout(function () {
      if (!glob.classList.contains('is-webgl')) glob.classList.add('is-fallback');
    }, 3000);
  }

  // старт хореографии — когда шрифт готов (но не дольше 800 мс)
  var started = false;
  var start = function () {
    if (started) return;
    started = true;
    raf(function () { raf(function () { root.classList.add('rd-wow-in'); }); });
    setTimeout(cacheChars, 2200);
  };
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(start);
  setTimeout(start, 800);

  /* ---------- Буквы заголовка тянутся к курсору ---------- */
  var charPos = [];
  function cacheChars() {
    charPos = titleChars.map(function (c) {
      var r = c.getBoundingClientRect();
      return { x: r.left + r.width / 2 + window.scrollX, y: r.top + r.height / 2 + window.scrollY, p: 0, t: 0 };
    });
  }
  var resizeTimer;
  window.addEventListener('resize', function () {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(cacheChars, 300);
  });

  /* ---------- Курсор, прожектор, параллакс (только мышь) ---------- */
  var mouse = { x: -9999, y: -9999, inHero: false };
  var heroContent = hero && hero.querySelector('.rd-hero__content');
  var heroVisual = hero && hero.querySelector('.rd-hero__visual');
  var px = { cx: 0, cy: 0, tx: 0, ty: 0 };
  var light = { x: 0, y: 0 };

  var cursor, ring, ringLabel;
  var cur = { x: -100, y: -100, rx: -100, ry: -100 };

  if (fine) {
    root.classList.add('rd-wow-cursor');
    cursor = document.createElement('div');
    cursor.className = 'rd-cursor';
    ring = document.createElement('div');
    ring.className = 'rd-cursor-ring';
    ringLabel = document.createElement('span');
    ringLabel.textContent = isRu ? 'клик' : 'клік';
    ring.appendChild(ringLabel);
    document.body.appendChild(ring);
    document.body.appendChild(cursor);

    var scopes = '.rd-header, .rd-hero, .rd-services';

    window.addEventListener('pointermove', function (e) {
      if (e.pointerType !== 'mouse') return;
      mouse.x = e.clientX;
      mouse.y = e.clientY;
      cur.x = e.clientX;
      cur.y = e.clientY;

      var t = e.target;
      var inScope = t.closest && t.closest(scopes);
      root.classList.toggle('rd-cursor-on', !!inScope);
      ring.classList.toggle('is-link', !!(t.closest && t.closest('a, button')) && !t.closest('.rd-works'));
      ring.classList.toggle('is-hidden', !!(t.closest && t.closest('.rd-works')));

      var overBlob = false;
      if (glob && !t.closest('a, button')) {
        var g = glob.getBoundingClientRect();
        var gx = e.clientX - (g.left + g.width / 2);
        var gy = e.clientY - (g.top + g.height / 2);
        overBlob = gx * gx + gy * gy < Math.pow(g.width * 0.36, 2);
      }
      ring.classList.toggle('is-blob', overBlob);

      if (hero) {
        var r = hero.getBoundingClientRect();
        mouse.inHero = e.clientY >= r.top && e.clientY <= r.bottom;
        if (mouse.inHero) {
          px.tx = (e.clientX / window.innerWidth) * 2 - 1;
          px.ty = ((e.clientY - r.top) / r.height) * 2 - 1;
        }
        hero.classList.toggle('is-lit', mouse.inHero);
      }
    }, { passive: true });

    document.addEventListener('mouseleave', function () {
      root.classList.remove('rd-cursor-on');
      if (hero) hero.classList.remove('is-lit');
      mouse.inHero = false;
    });
    document.addEventListener('pointerdown', function () { ring.classList.add('is-down'); });
    document.addEventListener('pointerup', function () { ring.classList.remove('is-down'); });
  }

  /* ---------- «Магниты»: кнопка и стрелки услуг ---------- */
  var magnets = [];
  if (fine) {
    Array.prototype.forEach.call(document.querySelectorAll('.rd-hero__btn, .rd-service__arrow, .rd-header__phone'), function (el) {
      magnets.push({ el: el, x: 0, y: 0, tx: 0, ty: 0, k: el.classList.contains('rd-header__phone') ? 0.2 : 0.35 });
    });
  }

  /* ---------- Главный цикл ---------- */
  function frame() {
    // курсор
    if (cursor) {
      cur.rx = lerp(cur.rx, cur.x, 0.2);
      cur.ry = lerp(cur.ry, cur.y, 0.2);
      cursor.style.transform = 'translate3d(' + cur.x + 'px,' + cur.y + 'px,0)';
      ring.style.transform = 'translate3d(' + cur.rx.toFixed(1) + 'px,' + cur.ry.toFixed(1) + 'px,0)';
    }

    if (hero && fine) {
      var hr = hero.getBoundingClientRect();
      // прожектор и свет догоняют курсор
      var lx = mouse.x - hr.left;
      var ly = mouse.y - hr.top;
      light.x = lerp(light.x, lx, 0.12);
      light.y = lerp(light.y, ly, 0.12);
      hero.style.setProperty('--mx', lx.toFixed(1) + 'px');
      hero.style.setProperty('--my', ly.toFixed(1) + 'px');
      hero.style.setProperty('--lx', light.x.toFixed(1) + 'px');
      hero.style.setProperty('--ly', light.y.toFixed(1) + 'px');

      // параллакс: текст — чуть против мыши, объект — за мышью
      var k = mouse.inHero ? 1 : 0;
      px.cx = lerp(px.cx, px.tx * k, 0.06);
      px.cy = lerp(px.cy, px.ty * k, 0.06);
      if (heroContent) heroContent.style.translate = (px.cx * -10).toFixed(2) + 'px ' + (px.cy * -8).toFixed(2) + 'px';
      if (heroVisual) heroVisual.style.translate = (px.cx * 22).toFixed(2) + 'px ' + (px.cy * 16).toFixed(2) + 'px';

      // буквы заголовка
      if (charPos.length && root.classList.contains('rd-wow-in')) {
        var mx = mouse.x + window.scrollX;
        var my = mouse.y + window.scrollY;
        for (var i = 0; i < charPos.length; i++) {
          var c = charPos[i];
          var d = Math.hypot(c.x - mx, c.y - my);
          c.t = mouse.inHero ? Math.pow(clamp(1 - d / 190, 0, 1), 1.6) : 0;
          var np = lerp(c.p, c.t, 0.14);
          if (Math.abs(np - c.p) > 0.001 || (c.p !== 0 && c.t === 0)) {
            c.p = Math.abs(np) < 0.002 ? 0 : np;
            titleChars[i].style.setProperty('--p', c.p.toFixed(3));
          }
        }
      }
    }

    // магниты
    for (var m = 0; m < magnets.length; m++) {
      var mg = magnets[m];
      var r = mg.el.getBoundingClientRect();
      var cx = r.left + r.width / 2 - mg.x;
      var cy = r.top + r.height / 2 - mg.y;
      var dx = mouse.x - cx;
      var dy = mouse.y - cy;
      var zone = Math.max(r.width, r.height) / 2 + 30;
      if (dx * dx + dy * dy < zone * zone) { mg.tx = dx * mg.k; mg.ty = dy * mg.k; } else { mg.tx = 0; mg.ty = 0; }
      mg.x = lerp(mg.x, mg.tx, 0.15);
      mg.y = lerp(mg.y, mg.ty, 0.15);
      mg.el.style.transform = 'translate3d(' + mg.x.toFixed(2) + 'px,' + mg.y.toFixed(2) + 'px,0)';
    }

    raf(frame);
  }
  raf(frame);

  /* ================= Меню ================= */

  // «перекатывание» букв в пунктах меню и телефоне
  Array.prototype.forEach.call(document.querySelectorAll('.rd-nav__link, .rd-header__phone'), function (link) {
    var text = link.textContent.trim();
    link.setAttribute('aria-label', text);
    link.textContent = '';
    var roll = document.createElement('span');
    roll.className = 'rd-roll';
    roll.setAttribute('aria-hidden', 'true');
    for (var n = 0; n < 2; n++) {
      var row = document.createElement('span');
      row.className = 'rd-roll__row';
      Array.prototype.forEach.call(text, function (ch, i) {
        var s = document.createElement('span');
        s.className = 'rd-ch';
        s.textContent = ch === ' ' ? ' ' : ch;
        s.style.setProperty('--i', i);
        row.appendChild(s);
      });
      roll.appendChild(row);
    }
    link.appendChild(roll);
  });

  // мега-меню: каскад колонок и ссылок
  Array.prototype.forEach.call(document.querySelectorAll('.rd-mega__col'), function (col, ci) {
    col.style.setProperty('--c', ci);
    Array.prototype.forEach.call(col.querySelectorAll('li'), function (li, li_i) { li.style.setProperty('--l', li_i); });
  });

  // бургер: круг раскрывается из кнопки, пункты — каскадом
  var burger = document.querySelector('[data-rd-burger]');
  var panel = document.querySelector('[data-rd-mobile]');
  if (burger && panel) {
    var setOrigin = function () {
      var b = burger.getBoundingClientRect();
      panel.style.setProperty('--bx', (b.left + b.width / 2) + 'px');
      panel.style.setProperty('--by', (b.top + b.height / 2) + 'px');
    };
    burger.addEventListener('click', setOrigin, true);
    setOrigin();
    Array.prototype.forEach.call(panel.querySelectorAll('.rd-mobile__nav > *, .rd-mobile__brief'), function (el, i) {
      el.style.setProperty('--i', i);
    });
  }

  /* ================= Блок услуг ================= */

  var services = document.querySelector('.rd-services');
  if (services) {
    var sTitle = services.querySelector('.rd-services__title');
    if (sTitle) splitWords(sTitle);
    Array.prototype.forEach.call(services.querySelectorAll('.rd-service'), function (row, i) {
      row.style.setProperty('--i', i);
      var g = document.createElement('span');
      g.className = 'rd-service__glow';
      g.setAttribute('aria-hidden', 'true');
      row.insertBefore(g, row.querySelector('.rd-service__row'));
      if (fine) {
        row.addEventListener('pointermove', function (e) {
          var r = row.getBoundingClientRect();
          row.style.setProperty('--gx', (e.clientX - r.left) + 'px');
          row.style.setProperty('--gy', (e.clientY - r.top) + 'px');
        });
      }
    });

    var reveal = function (el) { el.classList.add('is-in'); };
    var targets = services.querySelectorAll('.rd-services__heading, .rd-service');
    if ('IntersectionObserver' in window) {
      var io = new IntersectionObserver(function (entries) {
        entries.forEach(function (en) {
          if (en.isIntersecting) { reveal(en.target); io.unobserve(en.target); }
        });
      }, { threshold: 0.18, rootMargin: '0px 0px -8% 0px' });
      Array.prototype.forEach.call(targets, function (t) { io.observe(t); });
    } else {
      Array.prototype.forEach.call(targets, reveal);
    }
  }
})();
