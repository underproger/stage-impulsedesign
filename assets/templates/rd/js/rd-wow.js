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

  // Слова целиком (для подзаголовков): вложенные элементы (золотое слово и т.п.) — одним куском.
  // Делим только по обычным пробелам: неразрывный (&nbsp;) склеивает слова и здесь.
  function splitWords(el) {
    var items = [];
    Array.prototype.slice.call(el.childNodes).forEach(function (child) {
      if (child.nodeType === 3) {
        var frag = document.createDocumentFragment();
        child.textContent.split(/([ \t\r\n]+)/).forEach(function (t) {
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
    // слово с &nbsp; на конце не отрывается от следующего (например «для&nbsp;<span>бізнесу</span>»)
    items.forEach(function (w, i) {
      var next = items[i + 1];
      if (next && w.nextSibling === next && /\u00a0$/.test(w.textContent)) {
        var group = w.parentNode.classList.contains('rd-nw') ? w.parentNode : null; // цепочка слов через &nbsp;
        if (!group) {
          group = document.createElement('span');
          group.className = 'rd-nw';
          w.parentNode.insertBefore(group, w);
          group.appendChild(w);
        }
        group.appendChild(next);
      }
    });
    return items;
  }

  // Слова для «проявления» при прокрутке: обычные span.rd-qw (inline — переносы и отступ строки не меняются).
  // Вложенный <span> (золото) тоже делится на слова, каждое — золотое отдельно (rd-qw--gold).
  function splitFlow(el) {
    var words = [];
    var walk = function (node, gold) {
      Array.prototype.slice.call(node.childNodes).forEach(function (child) {
        if (child.nodeType === 3) {
          var frag = document.createDocumentFragment();
          child.textContent.split(/([ \t\r\n]+)/).forEach(function (t) {
            if (!t) return;
            if (/^[ \t\r\n]+$/.test(t)) { frag.appendChild(document.createTextNode(' ')); return; }
            var w = document.createElement('span');
            w.className = gold ? 'rd-qw rd-qw--gold' : 'rd-qw';
            w.textContent = t;
            frag.appendChild(w);
            words.push(w);
          });
          child.parentNode.replaceChild(frag, child);
        } else if (child.nodeType === 1 && child.tagName !== 'BR') {
          var isGold = gold || child.tagName === 'SPAN';
          if (child.tagName === 'SPAN') child.classList.add('is-split');
          walk(child, isGold);
        }
      });
    };
    walk(el, false);
    words.forEach(function (w, i) { w.style.setProperty('--i', i); });
    return words;
  }

  /* ================= Прожектор и свет за курсором ================= */
  // Всё двигается transform'ом (без перерисовки): раньше маска/градиент на весь блок
  // пересчитывались на каждое движение мыши — блок тормозил.

  // Золотая сетка под курсором: круг-«линза» с неподвижной маской едет за курсором,
  // сетка внутри едет обратно — остаётся на месте относительно блока.
  function makeSpot(box) {
    var spot = document.createElement('div');
    spot.className = 'rd-wow-spot';
    spot.setAttribute('aria-hidden', 'true');
    spot.innerHTML = '<div class="rd-wow-spot__lens"><div class="rd-wow-spot__in"><div class="rd-wow-spot__grid"></div></div></div>';
    var lens = spot.firstChild;
    var inner = lens.firstChild;
    var size = function () {
      inner.style.width = box.offsetWidth + 'px';
      inner.style.height = box.offsetHeight + 'px';
    };
    size();
    window.addEventListener('resize', size);
    return {
      el: spot,
      size: size,
      move: function (x, y) {
        lens.style.transform = 'translate3d(' + x.toFixed(1) + 'px,' + y.toFixed(1) + 'px,0)';
        inner.style.transform = 'translate3d(' + (-x).toFixed(1) + 'px,' + (-y).toFixed(1) + 'px,0)';
      }
    };
  }

  // Свет за курсором внутри элемента: круг с градиентом (.rd-light) двигается transform'ом.
  // wrapCls — обёртка-маска (если сам элемент не обрезает содержимое), cls — модификатор размера/цвета.
  function addLight(box, cls, before, wrapCls) {
    var light = document.createElement('span');
    light.className = 'rd-light ' + cls;
    var node = light;
    if (wrapCls) {
      node = document.createElement('span');
      node.className = wrapCls;
      node.appendChild(light);
    }
    node.setAttribute('aria-hidden', 'true');
    box.insertBefore(node, before || null);
    box.addEventListener('pointermove', function (e) {
      var r = box.getBoundingClientRect();
      light.style.transform = 'translate3d(' + (e.clientX - r.left).toFixed(1) + 'px,' + (e.clientY - r.top).toFixed(1) + 'px,0)';
    });
    return node;
  }

  /* ================= Плавная прокрутка колесом ================= */
  // Колесо мыши / тачпад: страница едет к цели с инерцией (тач и клавиатура — как обычно).
  // Не трогаем: Ctrl+колесо (зум), горизонтальную прокрутку, области со своей прокруткой
  // (пока им есть куда ехать), заблокированную страницу (открыто меню/модалка), [data-rd-no-smooth].
  // Если прокрутку сдвинул кто-то ещё (скроллбар, клавиши, якорь, лента портфолио) — подхватываем позицию.
  (function () {
    if (!fine) return;
    var cur = window.scrollY;
    var target = cur;
    var lastSet = cur;
    var last = 0;
    var running = false;
    var maxY = function () { return Math.max(0, document.documentElement.scrollHeight - window.innerHeight); };
    var locked = function () {
      if (root.classList.contains('rd-lock') || document.body.classList.contains('rd-lock')) return true;
      return getComputedStyle(document.body).overflowY === 'hidden' || getComputedStyle(root).overflowY === 'hidden';
    };
    var ownScroll = function (el, dy) {
      for (; el && el !== document.body && el !== root; el = el.parentElement) {
        if (el.hasAttribute('data-rd-no-smooth')) return true;
        var oy = getComputedStyle(el).overflowY;
        if ((oy === 'auto' || oy === 'scroll' || oy === 'overlay') && el.scrollHeight > el.clientHeight + 1) {
          if (dy > 0 ? el.scrollTop + el.clientHeight < el.scrollHeight - 1 : el.scrollTop > 0) return true;
        }
      }
      return false;
    };
    var tick = function (now) {
      var dt = Math.min(64, now - last) / 1000;
      last = now;
      if (Math.abs(window.scrollY - lastSet) > 2) { // сдвинули снаружи — отдаём управление
        cur = target = lastSet = window.scrollY;
        running = false;
        return;
      }
      cur += (target - cur) * (1 - Math.exp(-dt * 9)); // ≈ 0.14 за кадр при 60 Гц, не зависит от частоты
      if (Math.abs(target - cur) < 0.5) cur = target;
      window.scrollTo(0, cur);
      lastSet = window.scrollY;
      if (cur !== target) raf(tick); else running = false;
    };
    window.addEventListener('wheel', function (e) {
      if (e.ctrlKey || e.defaultPrevented) return;
      var dy = e.deltaY;
      if (!dy || Math.abs(e.deltaX) > Math.abs(dy)) return;
      if (locked() || ownScroll(e.target, dy)) return;
      e.preventDefault();
      if (!running) cur = target = lastSet = window.scrollY;
      var k = e.deltaMode === 1 ? 40 : (e.deltaMode === 2 ? window.innerHeight : 1);
      target = clamp(target + dy * k, 0, maxY());
      if (!running) {
        running = true;
        last = performance.now();
        raf(tick);
      }
    }, { passive: false });
  })();

  /* ================= Переходы между страницами ================= */
  // Клик по внутренней ссылке: золотой и тёмный круги расходятся из точки клика на весь экран,
  // затем переход. Новая страница открывается из центра (если пришли переходом — html.rd-pt-in).
  (function () {
    var pt = document.createElement('div');
    pt.className = 'rd-pt';
    pt.setAttribute('aria-hidden', 'true');
    pt.innerHTML = '<div class="rd-pt__gold"></div><div class="rd-pt__dark"><img class="rd-pt__logo" src="/assets/templates/rd/img/logo.svg" width="167" height="27" alt=""></div>';
    document.body.appendChild(pt);
    var gold = pt.firstChild;
    var dark = pt.lastChild;
    var busy = false;
    var ease = function (t) { return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2; };
    var radius = function (x, y) {
      var w = window.innerWidth, h = window.innerHeight;
      return Math.hypot(Math.max(x, w - x), Math.max(y, h - y)) + 2;
    };
    var setCircle = function (el, r, x, y) {
      el.style.clipPath = 'circle(' + r.toFixed(1) + 'px at ' + x.toFixed(0) + 'px ' + y.toFixed(0) + 'px)';
    };
    var setHole = function (el, r, x, y) {
      var m = r <= 0 ? 'none' : 'radial-gradient(circle at ' + x.toFixed(0) + 'px ' + y.toFixed(0) + 'px, transparent ' + r.toFixed(1) + 'px, #000 ' + (r + 1).toFixed(1) + 'px)';
      el.style.webkitMaskImage = m;
      el.style.maskImage = m;
    };
    var reset = function () {
      pt.classList.remove('is-on', 'is-logo');
      [gold, dark].forEach(function (el) {
        el.style.clipPath = '';
        el.style.webkitMaskImage = '';
        el.style.maskImage = '';
      });
      busy = false;
    };
    // анимация двух слоёв: draw(el, t) для каждого, второй стартует с задержкой
    var run = function (dur, lag, draw, done) {
      var t0 = performance.now(); // по часам, а не от первого кадра: при занятом потоке анимация не опаздывает
      var step = function (now) {
        var a = clamp((now - t0) / dur, 0, 1);
        var b = clamp((now - t0 - lag) / dur, 0, 1);
        draw(ease(a), ease(b));
        if (b < 1) raf(step); else if (done) done();
      };
      raf(step);
    };

    // закрытие: круги из точки клика
    var leave = function (url, x, y) {
      busy = true;
      var R = radius(x, y);
      setCircle(gold, 0, x, y);
      setCircle(dark, 0, x, y);
      pt.classList.add('is-on');
      run(560, 120, function (a, b) {
        setCircle(gold, R * a, x, y);
        setCircle(dark, R * b, x, y);
        if (b > 0.7) pt.classList.add('is-logo');
      }, function () {
        // метка для новой страницы: время и точка клика в долях окна — оттуда она и откроется
        var pos = (x / window.innerWidth).toFixed(4) + '|' + (y / window.innerHeight).toFixed(4);
        try { sessionStorage.setItem('rd-pt', Date.now() + '|' + pos); } catch (e) { /* без метки страница откроется как обычно */ }
        window.location.href = url;
        setTimeout(reset, 5000); // переход не случился (например, отдали файл) — открываем страницу обратно
      });
    };

    // открытие: тёмный слой «прорезается» из точки клика на прошлой странице (иначе из центра),
    // за ним — золотой (видна золотая кайма)
    var enter = function () {
      busy = true;
      var fx = 0.5;
      var fy = 0.5;
      var from = (root.getAttribute('data-rd-pt') || '').split(' ');
      if (from.length === 2 && !isNaN(+from[0]) && !isNaN(+from[1])) {
        fx = clamp(+from[0], 0, 1);
        fy = clamp(+from[1], 0, 1);
      }
      root.removeAttribute('data-rd-pt');
      var x = window.innerWidth * fx;
      var y = window.innerHeight * fy;
      var R = radius(x, y);
      pt.classList.add('is-on', 'is-logo');
      root.classList.remove('rd-pt-in');
      setTimeout(function () { pt.classList.remove('is-logo'); }, 60);
      run(720, 130, function (a, b) {
        setHole(dark, R * a, x, y);
        setHole(gold, R * b, x, y);
      }, reset);
    };

    if (root.classList.contains('rd-pt-in')) enter();

    // страница из кэша «назад/вперёд» — снять занавес
    window.addEventListener('pageshow', function (e) {
      if (e.persisted && pt.classList.contains('is-on')) reset();
    });

    // ссылка, которую можно открыть переходом (внутренняя страница, не файл, не якорь, не новая вкладка)
    var pageUrl = function (a) {
      if (!a || a.hasAttribute('download') || a.hasAttribute('data-rd-no-pt') || (a.target && a.target !== '_self')) return null;
      var href = a.getAttribute('href');
      if (!href || href.charAt(0) === '#' || /^(mailto|tel|javascript|viber|tg|skype):/i.test(href)) return null;
      var url;
      try { url = new URL(a.href, window.location.href); } catch (err) { return null; }
      if (url.origin !== window.location.origin) return null;
      if (url.pathname === window.location.pathname && url.search === window.location.search && url.hash) return null; // якорь на этой же странице
      if (/\.(pdf|zip|rar|docx?|xlsx?|pptx?|jpe?g|png|webp|gif|svg|mp4|mp3)$/i.test(url.pathname)) return null; // файлы
      if (/\/(impulsemanager|connectors|assets)\//.test(url.pathname)) return null;
      return url;
    };

    // предзагрузку (prefetch) не делаем: страницы отдаются с Cache-Control: no-store — браузер её не переиспользует

    document.addEventListener('click', function (e) {
      if (busy || e.defaultPrevented || e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
      var a = e.target.closest && e.target.closest('a[href]');
      var url = pageUrl(a);
      if (!url) return;
      e.preventDefault();
      var x = e.clientX, y = e.clientY;
      if (!e.detail || (!x && !y)) { // клавиатура — из центра ссылки
        var r = a.getBoundingClientRect();
        x = r.left + r.width / 2;
        y = r.top + r.height / 2;
      }
      leave(url.href, x, y);
    });
  })();

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
  var heroSpot = null;
  var heroGlow = null;
  if (hero) {
    heroSpot = makeSpot(hero);
    heroGlow = document.createElement('div');
    heroGlow.className = 'rd-wow-glow';
    hero.insertBefore(heroGlow, hero.firstChild);
    hero.insertBefore(heroSpot.el, hero.firstChild);
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

    var scopes = '.rd-header, .rd-hero, .rd-services, .rd-portfolio, .rd-mind, .rd-gar, .rd-prices, .rd-about';
    var pfSection = document.querySelector('[data-rd-portfolio]');
    var labels = { click: ringLabel.textContent, view: (pfSection && pfSection.getAttribute('data-rd-view')) || (isRu ? 'смотреть' : 'дивитись') };
    var labelNow = 'click';

    window.addEventListener('pointermove', function (e) {
      if (e.pointerType !== 'mouse') return;
      mouse.x = e.clientX;
      mouse.y = e.clientY;
      cur.x = e.clientX;
      cur.y = e.clientY;

      var t = e.target;
      if (!t.closest) return;
      var inScope = t.closest(scopes);
      var overCase = !!t.closest('.rd-case__media');
      root.classList.toggle('rd-cursor-on', !!inScope);
      ring.classList.toggle('is-view', overCase);
      root.classList.toggle('rd-cursor-view', overCase);
      ring.classList.toggle('is-link', !!t.closest('a, button') && !t.closest('.rd-works') && !overCase);
      ring.classList.toggle('is-hidden', !!t.closest('.rd-works'));
      var want = overCase ? 'view' : 'click';
      if (want !== labelNow) {
        labelNow = want;
        ringLabel.textContent = labels[want];
      }

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
      if (mouse.inHero) {
        heroSpot.move(lx, ly);
        heroGlow.style.transform = 'translate3d(' + light.x.toFixed(1) + 'px,' + light.y.toFixed(1) + 'px,0)';
      }

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

    if (pfTick) pfTick();
    if (mindTick) mindTick();
    if (garTick) garTick();
    if (priceTick) priceTick();
    if (aboutTick) aboutTick();

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
      if (fine) addLight(row, 'rd-light--srv', row.querySelector('.rd-service__row'), 'rd-service__glow');
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

  /* ================= Портфолио ================= */
  // Десктоп: блок закрепляется на экране, прокрутка страницы ведёт ленту кейсов вбок
  // (если блок по высоте не помещается в окно — остаётся обычная лента, её тянут мышью).
  // Внутри карточек — глубина: устройства и фоновая надпись смещаются с разной скоростью,
  // при наведении устройства в карточке приближаются и расходятся (CSS, настройки — в слоях кейса).

  var pfTick = null;
  var pf = document.querySelector('[data-rd-portfolio]');
  if (pf) {
    var pfPin = pf.querySelector('.rd-portfolio__pin');
    var pfHead = pf.querySelector('.rd-portfolio__head');
    var pfVp = pf.querySelector('[data-rd-pf-viewport]');
    var pfTrack = pf.querySelector('[data-rd-pf-track]');
    var pfActions = pf.querySelector('.rd-portfolio__actions');
    var pfDesktop = window.matchMedia('(min-width: 1200px)');
    var PF_K = 0.85; // пикселей прокрутки страницы на 1px сдвига ленты
    var pin = { on: false, dist: 0, x: 0 };

    var pfTitle = pf.querySelector('.rd-portfolio__title');
    if (pfTitle) splitWords(pfTitle);

    var pfCases = Array.prototype.map.call(pf.querySelectorAll('.rd-case'), function (el) {
      return {
        el: el,
        media: el.querySelector('.rd-case__media'),
        layer: el.querySelector('.rd-case__layer'),
        word: el.querySelector('.rd-case__word'),
        tx: 0, ty: 0, mx: 0, my: 0, sl: '', sw: ''
      };
    });

    // Закрепление: блок должен целиком помещаться по высоте окна. Если не помещается —
    // карточки пропорционально уменьшаются (до 62%), и только потом — обычная лента.
    var PF_MIN_K = 0.62;
    var pfMeasure = function () {
      pf.classList.remove('is-pinned');
      if (pfPin) pfPin.style.paddingTop = '';
      pf.style.height = '';
      pf.style.removeProperty('--rd-pf-k');
      pfTrack.style.transform = '';
      pin.on = false;
      if (!pfDesktop.matches || !pfPin || !pfVp || !pfTrack || !pfHead) return;
      var media = pfTrack.querySelector('.rd-case__media');
      if (!media) return;

      pf.classList.add('is-pinned'); // меряем уже в закреплённой раскладке
      var probe = document.querySelector('.rd-header__probe');
      var headH = probe ? probe.offsetHeight : 0; // закреплённая шапка (компактная) не должна закрывать ленту
      pfPin.style.paddingTop = headH + 'px';
      var vh = window.innerHeight;
      var avail = vh - headH - 2 * Math.max(40, vh * 0.06);
      var k = 1;
      var fits = false;
      for (var i = 0; i < 5; i++) {
        var need = pfVp.getBoundingClientRect().bottom - pfHead.getBoundingClientRect().top;
        if (need <= avail) { fits = true; break; }
        var mh = media.offsetHeight;
        var nk = k * (avail - (need - mh)) / mh;
        if (nk < PF_MIN_K) break;
        k = Math.min(k, nk) - 0.002;
        pf.style.setProperty('--rd-pf-k', k.toFixed(4));
      }
      var dist = pfTrack.scrollWidth - pfVp.clientWidth;
      if (!fits || dist < 40) {
        pf.classList.remove('is-pinned');
        pfPin.style.paddingTop = '';
        pf.style.removeProperty('--rd-pf-k');
        return;
      }
      pin.dist = dist;
      pin.on = true;
      pfVp.scrollLeft = 0;
      pf.style.height = Math.round(vh + dist * PF_K) + 'px';
      pin.x = Math.min(pin.x, dist);
    };
    pfMeasure();
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(pfMeasure);
    var pfTimer;
    window.addEventListener('resize', function () {
      clearTimeout(pfTimer);
      pfTimer = setTimeout(pfMeasure, 150);
    });

    var pfStart = function () { return pf.getBoundingClientRect().top + window.scrollY; };

    // клавиатура: фокус на кейсе за краем экрана — докручиваем страницу до него
    pf.addEventListener('focusin', function (e) {
      if (pfPin) pfPin.scrollLeft = 0;
      if (!pin.on) return;
      var card = e.target.closest && e.target.closest('.rd-case');
      if (!card) return;
      var first = pfTrack.firstElementChild;
      var x = clamp(card.offsetLeft - (first ? first.offsetLeft : 0), 0, pin.dist);
      window.scrollTo(0, pfStart() + x * PF_K);
    });

    // горизонтальный свайп тачпадом и перетаскивание мышью двигают ленту через прокрутку страницы
    pfVp.addEventListener('wheel', function (e) {
      if (!pin.on || Math.abs(e.deltaX) <= Math.abs(e.deltaY)) return;
      e.preventDefault();
      window.scrollBy(0, e.deltaX * PF_K);
    }, { passive: false });

    var pd = null;
    var pdMoved = false;
    pfVp.addEventListener('pointerdown', function (e) {
      if (!pin.on || e.pointerType !== 'mouse' || e.button !== 0) return;
      pd = { x: e.clientX, y: window.scrollY };
      pdMoved = false;
    });
    window.addEventListener('pointermove', function (e) {
      if (!pd) return;
      var dx = e.clientX - pd.x;
      if (!pdMoved && Math.abs(dx) > 6) {
        pdMoved = true;
        pfVp.classList.add('is-dragging');
      }
      if (pdMoved) window.scrollTo(0, pd.y - dx * PF_K);
    });
    window.addEventListener('pointerup', function () {
      if (!pd) return;
      pd = null;
      pfVp.classList.remove('is-dragging');
    });
    pfVp.addEventListener('click', function (e) {
      if (pdMoved) {
        e.preventDefault();
        e.stopPropagation();
        pdMoved = false;
      }
    }, true);

    // устройства чуть следуют за курсором
    if (fine) {
      pfCases.forEach(function (c) {
        if (!c.media) return;
        c.media.addEventListener('pointermove', function (e) {
          var r = c.media.getBoundingClientRect();
          c.tx = clamp(((e.clientX - r.left) / r.width) * 2 - 1, -1, 1);
          c.ty = clamp(((e.clientY - r.top) / r.height) * 2 - 1, -1, 1);
        });
        c.media.addEventListener('pointerleave', function () { c.tx = 0; c.ty = 0; });
      });
    }

    var pfRects = [];
    pfTick = function () {
      var vw = window.innerWidth;
      var vh = window.innerHeight;
      var desk = pfDesktop.matches;

      // сначала только чтение геометрии, потом запись стилей (без лишних пересчётов раскладки)
      var pr = pf.getBoundingClientRect();
      if (pr.bottom < -200 || pr.top > vh + 200) return; // блок далеко — ничего не считаем
      for (var k = 0; k < pfCases.length; k++) pfRects[k] = pfCases[k].media ? pfCases[k].media.getBoundingClientRect() : null;

      var shift = 0;
      if (pin.on) {
        var target = clamp(-pr.top / (pin.dist * PF_K), 0, 1) * pin.dist;
        var nx = lerp(pin.x, target, 0.14);
        if (Math.abs(nx - target) < 0.05) nx = target;
        shift = pin.x - nx; // на столько сдвинутся карточки в этом кадре
        pin.x = nx;
        var tr = 'translate3d(' + (-pin.x).toFixed(2) + 'px,0,0)';
        if (pfTrack.style.transform !== tr) pfTrack.style.transform = tr;
      }

      for (var i = 0; i < pfCases.length; i++) {
        var c = pfCases[i];
        var r = pfRects[i];
        if (!r) continue;
        var left = r.left + shift;
        if (left + r.width < -100 || left > vw + 100 || r.bottom < -100 || r.top > vh + 100) continue;
        // положение карточки относительно центра экрана: по горизонтали на десктопе, по вертикали на мобайле
        var n = desk ? (left + r.width / 2 - vw / 2) / vw : (r.top + r.height / 2 - vh / 2) / vh;
        c.mx = lerp(c.mx, c.tx, 0.08);
        c.my = lerp(c.my, c.ty, 0.08);
        if (Math.abs(c.mx) < 0.0005 && c.tx === 0) c.mx = 0;
        if (Math.abs(c.my) < 0.0005 && c.ty === 0) c.my = 0;

        if (c.layer) {
          var sl = desk ? (n * -60 + c.mx * 10).toFixed(1) + 'px ' + (c.my * 6).toFixed(1) + 'px' : '0px 0px';
          if (sl !== c.sl) { c.layer.style.translate = sl; c.sl = sl; }
        }
        if (c.word) {
          var sw = (n * (desk ? 160 : 70) - c.mx * 22).toFixed(1) + 'px 0px';
          if (sw !== c.sw) { c.word.style.translate = sw; c.sw = sw; }
        }
      }
    };

    // появление: заголовок, карточки (по мере въезда в кадр), кнопки внизу
    var pfReveal = function (el) { el.classList.add('is-in'); };
    var pfTargets = [pfHead, pfActions].concat(pfCases.map(function (c) { return c.el; })).filter(Boolean);
    if ('IntersectionObserver' in window) {
      var pfIo = new IntersectionObserver(function (entries) {
        entries.forEach(function (en) {
          if (en.isIntersecting) { pfReveal(en.target); pfIo.unobserve(en.target); }
        });
      }, { threshold: 0.12, rootMargin: '0px 0px -6% 0px' });
      pfTargets.forEach(function (t) { pfIo.observe(t); });
    } else {
      pfTargets.forEach(pfReveal);
    }
  }

  /* ================= «Сайти для бізнесу» (Mind Control 2.0) ================= */
  // Заголовок и карточки появляются по IntersectionObserver; цитата «проявляется» словами
  // по мере прокрутки; фото чуть смещается внутри капсулы; на плашке — золотой свет за курсором.

  var mindTick = null;
  var mind = document.querySelector('.rd-mind');
  if (mind) {
    var mTitle = mind.querySelector('.rd-mind__title');
    if (mTitle) splitWords(mTitle);

    var mQuote = mind.querySelector('.rd-mind__quote p');
    var mWords = mQuote ? splitFlow(mQuote) : [];
    var mPhoto = mind.querySelector('.rd-mind__photo');
    var mImg = mPhoto && mPhoto.querySelector('img');
    var mCards = mind.querySelector('.rd-mind__cards');
    var mq = { q: -1, t: -1, ty: 0, s: '' };

    Array.prototype.forEach.call(mind.querySelectorAll('.rd-mind-card'), function (c, i) { c.style.setProperty('--i', i); });

    if (mCards && fine) {
      addLight(mCards, 'rd-light--mind rd-mind__light', mCards.firstChild);
      mCards.addEventListener('pointerenter', function () { mCards.classList.add('is-lit'); });
      mCards.addEventListener('pointerleave', function () { mCards.classList.remove('is-lit'); });
    }

    mindTick = function () {
      var vh = window.innerHeight;
      var mr = mind.getBoundingClientRect();
      if (mr.bottom < -100 || mr.top > vh + 100) return;

      // цитата: от появления снизу (верх на 88% экрана) до низа цитаты на 55% экрана
      if (mWords.length) {
        var qr = mQuote.getBoundingClientRect();
        var p = clamp((vh * 0.88 - qr.top) / (qr.height + vh * 0.33), 0, 1);
        mq.t = p * (mWords.length + 1.5) - 0.5;
        mq.q = mq.q < -0.9 ? mq.t : lerp(mq.q, mq.t, 0.12);
        if (Math.abs(mq.q - mq.t) < 0.01) mq.q = mq.t;
        var qs = mq.q.toFixed(2);
        if (qs !== mq.s) { mQuote.style.setProperty('--q', qs); mq.s = qs; }
      }

      // фото: лёгкий параллакс внутри капсулы
      if (mImg) {
        var pr = mPhoto.getBoundingClientRect();
        var n = clamp((pr.top + pr.height / 2 - vh / 2) / vh, -1, 1);
        var ty = n * pr.height * -0.12;
        if (Math.abs(ty - mq.ty) > 0.05) { mImg.style.translate = '0 ' + ty.toFixed(2) + 'px'; mq.ty = ty; }
      }
    };

    var mReveal = function (el) { el.classList.add('is-in'); };
    var mTargets = Array.prototype.filter.call(mind.querySelectorAll('.rd-mind__heading, .rd-mind__person, .rd-mind__cards'), Boolean);
    if ('IntersectionObserver' in window) {
      var mIo = new IntersectionObserver(function (entries) {
        entries.forEach(function (en) {
          if (en.isIntersecting) { mReveal(en.target); mIo.unobserve(en.target); }
        });
      }, { threshold: 0.2, rootMargin: '0px 0px -8% 0px' });
      mTargets.forEach(function (t) { mIo.observe(t); });
    } else {
      mTargets.forEach(mReveal);
    }
  }

  /* ================= «4 унікальні гарантії» ================= */
  // Заголовок, кнопка и плашка появляются по IntersectionObserver; под курсором проступает
  // золотая сетка (общий слой .rd-wow-spot), свечение внизу тянется за курсором, на плашке — свет.

  var garTick = null;
  var gar = document.querySelector('.rd-gar');
  if (gar) {
    var gTitle = gar.querySelector('.rd-gar__title');
    if (gTitle) splitWords(gTitle);
    var gPanel = gar.querySelector('.rd-gar__panel');
    var gGlow = gar.querySelector('.rd-gar__glow');
    var gg = { x: 0, y: 0, s: '' };

    Array.prototype.forEach.call(gar.querySelectorAll('.rd-gar-card'), function (c, i) { c.style.setProperty('--i', i); });

    if (fine) {
      var gSpot = makeSpot(gar);
      gar.insertBefore(gSpot.el, gar.firstChild);
      gar.addEventListener('pointermove', function (e) {
        var r = gar.getBoundingClientRect();
        gSpot.move(e.clientX - r.left, e.clientY - r.top);
        if (!gar.classList.contains('is-lit')) gar.classList.add('is-lit');
      });
      gar.addEventListener('pointerleave', function () { gar.classList.remove('is-lit'); });
      if (document.fonts && document.fonts.ready) document.fonts.ready.then(gSpot.size);

      if (gPanel) {
        addLight(gPanel, 'rd-light--gar rd-gar__light', gPanel.firstChild);
        gPanel.addEventListener('pointerenter', function () { gPanel.classList.add('is-lit'); });
        gPanel.addEventListener('pointerleave', function () { gPanel.classList.remove('is-lit'); });
      }

      // свечение мягко смещается к курсору (только пока блок на экране)
      garTick = function () {
        if (!gGlow) return;
        var r = gar.getBoundingClientRect();
        if (r.bottom < -100 || r.top > window.innerHeight + 100) return;
        var inside = mouse.y >= r.top && mouse.y <= r.bottom;
        var tx = inside ? clamp((mouse.x - window.innerWidth / 2) / window.innerWidth, -0.5, 0.5) * 140 : 0;
        var ty = inside ? clamp((mouse.y - r.bottom) / r.height, -1, 0) * 50 : 0;
        gg.x = lerp(gg.x, tx, 0.05);
        gg.y = lerp(gg.y, ty, 0.05);
        var st = gg.x.toFixed(1) + 'px ' + gg.y.toFixed(1) + 'px';
        if (st !== gg.s) { gGlow.style.translate = st; gg.s = st; }
      };
    }

    var gReveal = function (el) { el.classList.add('is-in'); };
    var gTargets = Array.prototype.filter.call(gar.querySelectorAll('.rd-gar__title, .rd-gar__cta, .rd-gar__panel'), Boolean);
    if ('IntersectionObserver' in window) {
      var gIo = new IntersectionObserver(function (entries) {
        entries.forEach(function (en) {
          if (en.isIntersecting) { gReveal(en.target); gIo.unobserve(en.target); }
        });
      }, { threshold: 0.2, rootMargin: '0px 0px -8% 0px' });
      gTargets.forEach(function (t) { gIo.observe(t); });
    } else {
      gTargets.forEach(gReveal);
    }
  }

  /* ================= «Вартість розробки сайту» ================= */
  // Заголовок и карточки появляются по IntersectionObserver, цены «досчитываются» от нуля;
  // свет за курсором на карточке, свечение тёмной карточки плавно идёт за курсором.

  var priceTick = null;
  var prices = document.querySelector('.rd-prices');
  if (prices) {
    var prTitle = prices.querySelector('.rd-prices__title');
    if (prTitle) splitWords(prTitle);
    var prCards = Array.prototype.slice.call(prices.querySelectorAll('.rd-price'));

    // счётчик цены: «1300$» → от 0 до 1300, формат (префикс/суффикс) сохраняется
    var countUp = function (el, delay) {
      var m = (el.textContent || '').match(/^(\D*)(\d[\d\s]*)(.*)$/);
      if (!m) return;
      var to = parseInt(m[2].replace(/\s/g, ''), 10);
      if (!to) return;
      var final = el.textContent;
      el.setAttribute('aria-label', final);
      var t0 = null;
      var dur = 1400;
      var step = function (t) {
        if (t0 === null) t0 = t;
        var p = clamp((t - t0) / dur, 0, 1);
        var e = 1 - Math.pow(1 - p, 4);
        el.textContent = m[1] + Math.round(to * e) + m[3];
        if (p < 1) raf(step); else el.textContent = final;
      };
      el.textContent = m[1] + '0' + m[3];
      setTimeout(function () { raf(step); }, delay);
    };

    var accent = prices.querySelector('.rd-price--accent');
    var ag = { x: 0, y: 0, r: 300, tx: 0, ty: 0, on: false, s: '' };

    prCards.forEach(function (c, i) {
      c.style.setProperty('--i', i);
      if (!fine || !c.hasAttribute('href')) return;
      if (c !== accent) {
        var fill = c.querySelector('.rd-price__fill');
        addLight(c, 'rd-light--price rd-price__glow', fill ? fill.nextSibling : c.firstChild);
        return;
      }
      c.addEventListener('pointermove', function (e) {
        var r = c.getBoundingClientRect();
        ag.tx = e.clientX - r.left;
        ag.ty = e.clientY - r.top;
        ag.on = true;
      });
      c.addEventListener('pointerleave', function () { ag.on = false; });
    });

    // свечение тёмной карточки: по умолчанию — правый нижний угол (как в CSS), на наведении — к курсору
    var accentGlow = accent && accent.querySelector('.rd-price__aglow');
    if (accent && accentGlow && fine) {
      var home = function () {
        var r = accent.getBoundingClientRect();
        var g = window.innerWidth > 1920 ? window.innerWidth / 1920 : 1; // как fw(): шире 1920 — пропорционально
        return { x: r.width - 29 * g, y: 296 * g, r: 300 * g };
      };
      var h0 = home();
      ag.x = h0.x; ag.y = h0.y; ag.r = h0.r;
      priceTick = function () {
        var r = accent.getBoundingClientRect();
        if (r.bottom < -50 || r.top > window.innerHeight + 50) return;
        var h = home();
        var tx = ag.on ? ag.tx : h.x;
        var ty = ag.on ? ag.ty + 60 : h.y; // центр пятна чуть ниже курсора — золото «подсвечивает» снизу
        var tr = ag.on ? h.r * 1.3 : h.r;
        ag.x = lerp(ag.x, tx, 0.08);
        ag.y = lerp(ag.y, ty, 0.08);
        ag.r = lerp(ag.r, tr, 0.08);
        if (!ag.on && Math.abs(ag.x - h.x) < 0.5 && Math.abs(ag.y - h.y) < 0.5 && Math.abs(ag.r - h.r) < 0.5) {
          if (ag.s) { accentGlow.style.transform = ''; ag.s = ''; }
          ag.x = h.x; ag.y = h.y; ag.r = h.r;
          return;
        }
        // сдвиг и масштаб относительно места по умолчанию (как в CSS) — только transform
        var st = 'translate3d(' + (ag.x - h.x).toFixed(1) + 'px,' + (ag.y - h.y).toFixed(1) + 'px,0) scale(' + (ag.r / h.r).toFixed(3) + ')';
        if (st !== ag.s) {
          accentGlow.style.transform = st;
          ag.s = st;
        }
      };
    }

    var prReveal = function (el) {
      el.classList.add('is-in');
      if (el.classList.contains('rd-price')) {
        var v = el.querySelector('.rd-price__value');
        var i = prCards.indexOf(el);
        if (v) countUp(v, i * 90 + 150);
      }
    };
    var prTargets = [prices.querySelector('.rd-prices__heading')].concat(prCards).filter(Boolean);
    if ('IntersectionObserver' in window) {
      var prIo = new IntersectionObserver(function (entries) {
        entries.forEach(function (en) {
          if (en.isIntersecting) { prReveal(en.target); prIo.unobserve(en.target); }
        });
      }, { threshold: 0.2, rootMargin: '0px 0px -8% 0px' });
      prTargets.forEach(function (t) { prIo.observe(t); });
    } else {
      prTargets.forEach(prReveal);
    }
  }
  /* ================= «Digital агентство Impulse Design» ================= */
  // Объект парит и тянется за курсором/прокруткой, цифры «прокручиваются» как счётчик,
  // цитата проявляется словами при прокрутке, на графике рисуется линия и бежит огонёк.

  var aboutTick = null;
  var about = document.querySelector('.rd-about');
  if (about) {
    var abTitle = about.querySelector('.rd-about__title');
    if (abTitle) splitWords(abTitle);

    // счётчик-«одометр»: каждая цифра — лента 0…9, к нужной цифре докручивается (правые — больше оборотов)
    var odometer = function (el) {
      var text = (el.textContent || '').trim();
      if (!/\d/.test(text)) return;
      el.setAttribute('aria-label', text);
      el.textContent = '';
      var digits = text.replace(/\D/g, '').length;
      var di = 0;
      Array.prototype.forEach.call(text, function (ch) {
        if (!/\d/.test(ch)) { el.appendChild(document.createTextNode(ch)); return; }
        var d = +ch;
        var box = document.createElement('span');
        box.className = 'rd-odo';
        box.setAttribute('aria-hidden', 'true');
        var ph = document.createElement('span');
        ph.className = 'rd-odo__ph';
        ph.textContent = ch;
        var strip = document.createElement('span');
        strip.className = 'rd-odo__strip';
        var loops = 1 + di; // старшие разряды — один оборот, младшие — больше
        var seq = [];
        for (var l = 0; l < loops; l++) for (var k = 0; k < 10; k++) seq.push(k);
        for (var k2 = 0; k2 <= d; k2++) seq.push(k2);
        seq.forEach(function (n) {
          var s = document.createElement('span');
          s.textContent = n;
          strip.appendChild(s);
        });
        strip.style.setProperty('--to', -(seq.length - 1) + 'em');
        strip.style.setProperty('--d', di);
        box.appendChild(ph);
        box.appendChild(strip);
        el.appendChild(box);
        di++;
      });
      el.classList.add('is-odo');
      el.style.setProperty('--n', digits);
    };
    Array.prototype.forEach.call(about.querySelectorAll('.rd-stat__val'), odometer);

    // «20%» досчитывается от нуля
    var abPct = about.querySelector('.rd-about__pct');
    var countPct = function () {
      if (!abPct) return;
      var m = (abPct.textContent || '').match(/^(\D*)(\d+)(.*)$/);
      if (!m) return;
      var to = +m[2];
      var fin = abPct.textContent;
      var t0 = null;
      var step = function (t) {
        if (t0 === null) t0 = t;
        var p = clamp((t - t0) / 1500, 0, 1);
        abPct.textContent = m[1] + Math.round(to * (1 - Math.pow(1 - p, 4))) + m[3];
        if (p < 1) raf(step); else abPct.textContent = fin;
      };
      abPct.textContent = m[1] + '0' + m[3];
      setTimeout(function () { raf(step); }, 700);
    };

    // огонёк бежит по кривой графика (SVG animateMotion — масштабируется вместе с графиком)
    var abChart = about.querySelector('.rd-about__chart');
    var abLine = abChart && abChart.querySelector('.rd-about__line');
    var abMotion = null;
    if (abChart && abLine) {
      var NS = 'http://www.w3.org/2000/svg';
      var g = document.createElementNS(NS, 'g');
      g.setAttribute('class', 'rd-about__spark');
      g.innerHTML = '<circle r="9" class="rd-about__spark-halo"/><circle r="3.2" class="rd-about__spark-dot"/>';
      abMotion = document.createElementNS(NS, 'animateMotion');
      abMotion.setAttribute('dur', '4.2s');
      abMotion.setAttribute('repeatCount', 'indefinite');
      abMotion.setAttribute('begin', 'indefinite');
      abMotion.setAttribute('calcMode', 'spline');
      abMotion.setAttribute('keyTimes', '0;1');
      abMotion.setAttribute('keySplines', '0.45 0 0.55 1');
      abMotion.setAttribute('path', abLine.getAttribute('d'));
      g.appendChild(abMotion);
      abChart.appendChild(g);
    }

    var abQuote = about.querySelector('.rd-about__quote p');
    var abWords = abQuote ? splitFlow(abQuote) : [];
    var abObj = about.querySelector('.rd-about__spiral');
    var abPlate = about.querySelector('.rd-about__plate');
    var abCard = about.querySelector('.rd-about__card');
    var ab = { q: -1, s: '', mx: 0, my: 0, tx: 0, ty: 0, os: '' };

    if (fine) {
      [abPlate, abCard].forEach(function (box) {
        if (!box) return;
        addLight(box, 'rd-light--about rd-about__light', box.firstChild);
        box.addEventListener('pointerenter', function () { box.classList.add('is-lit'); });
        box.addEventListener('pointerleave', function () { box.classList.remove('is-lit'); });
      });
      // объект тянется к курсору, пока курсор в блоке
      about.addEventListener('pointermove', function (e) {
        var r = about.getBoundingClientRect();
        ab.tx = (e.clientX / window.innerWidth) * 2 - 1;
        ab.ty = ((e.clientY - r.top) / r.height) * 2 - 1;
      });
      about.addEventListener('pointerleave', function () { ab.tx = 0; ab.ty = 0; });
    }

    aboutTick = function () {
      var vh = window.innerHeight;
      var r = about.getBoundingClientRect();
      if (r.bottom < -100 || r.top > vh + 100) return;

      if (abWords.length) {
        var qr = abQuote.getBoundingClientRect();
        var p = clamp((vh * 0.88 - qr.top) / (qr.height + vh * 0.33), 0, 1);
        var t = p * (abWords.length + 1.5) - 0.5;
        ab.q = ab.q < -0.9 ? t : lerp(ab.q, t, 0.12);
        if (Math.abs(ab.q - t) < 0.01) ab.q = t;
        var qs = ab.q.toFixed(2);
        if (qs !== ab.s) { abQuote.style.setProperty('--q', qs); ab.s = qs; }
      }

      if (abObj) {
        // прокрутка: объект медленнее страницы (глубина); курсор: тянется за ним
        var n = clamp((r.top + 300 - vh / 2) / vh, -1.5, 1.5);
        ab.mx = lerp(ab.mx, ab.tx, 0.05);
        ab.my = lerp(ab.my, ab.ty, 0.05);
        var os = (ab.mx * 22).toFixed(1) + 'px ' + (n * 60 + ab.my * 16).toFixed(1) + 'px';
        if (os !== ab.os) { abObj.style.translate = os; ab.os = os; }
      }
    };

    var abReveal = function (el) {
      el.classList.add('is-in');
      if (el === abCard) {
        countPct();
        if (abMotion && abMotion.beginElement) setTimeout(function () { try { abMotion.beginElement(); } catch (e) { } }, 1900);
      }
    };
    var abTargets = [about.querySelector('.rd-about__head'), abPlate,
      about.querySelector('.rd-about__people'), about.querySelector('.rd-about__more'), abCard].filter(Boolean);
    if ('IntersectionObserver' in window) {
      var abIo = new IntersectionObserver(function (entries) {
        entries.forEach(function (en) {
          if (en.isIntersecting) { abReveal(en.target); abIo.unobserve(en.target); }
        });
      }, { threshold: 0.2, rootMargin: '0px 0px -8% 0px' });
      abTargets.forEach(function (el) { abIo.observe(el); });
    } else {
      abTargets.forEach(abReveal);
    }
  }
})();
