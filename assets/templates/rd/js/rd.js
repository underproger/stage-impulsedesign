/* Редизайн Impulse Design: шапка, мега-меню, мобильное меню */
(function () {
  'use strict';

  /* ---------- Заголовок первого экрана: длинное слово не должно вылезать за край ---------- */
  var title = document.querySelector('.rd-hero__title');
  var fitTitle = function () {
    if (!title) return;
    title.style.fontSize = '';
    var over = title.scrollWidth - title.clientWidth;
    if (over > 1) {
      var size = parseFloat(getComputedStyle(title).fontSize);
      title.style.fontSize = Math.floor(size * title.clientWidth / title.scrollWidth) + 'px';
    }
  };
  if (title) {
    fitTitle();
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(fitTitle);
    var fitTimer;
    window.addEventListener('resize', function () {
      clearTimeout(fitTimer);
      fitTimer = setTimeout(fitTitle, 100);
    });
  }

  /* ---------- Сетки фона (первый экран, гарантии, плашки section 6, форма, футер) едут в такт ---------- */
  // У каждой сетки своя CSS-анимация rd-grid-move, и стартуют они в разное время (золотые «линзы» под курсором —
  // ещё и после загрузки rd-wow.js). Ставим начало всех на ноль таймлайна — фаза везде одна, линии совпадают.
  var syncGrids = function () {
    if (!document.getAnimations) return;
    document.getAnimations().forEach(function (a) {
      if (a.animationName === 'rd-grid-move' && a.startTime !== 0) {
        try { a.startTime = 0; } catch (e) { /* старый браузер — пусть идут как идут */ }
      }
    });
  };
  window.rdSyncGrids = syncGrids;
  syncGrids();
  window.addEventListener('load', syncGrids);

  /* ---------- Заголовки [data-rd-fit]: длинное слово не вылезает за край — кегль уменьшается (только если вылезает) ---------- */
  var fitEls = document.querySelectorAll('[data-rd-fit]');
  if (fitEls.length) {
    var fitAll = function () {
      Array.prototype.forEach.call(fitEls, function (t) {
        t.style.fontSize = '';
        // до трёх проходов: у «таблеток» поля не уменьшаются вместе с кеглем — с одного раза чуть не хватает
        for (var k = 0; k < 3 && t.scrollWidth - t.clientWidth > 1; k++) {
          var size = parseFloat(getComputedStyle(t).fontSize);
          t.style.fontSize = (Math.floor(size * t.clientWidth / t.scrollWidth * 10) / 10) + 'px';
        }
      });
    };
    fitAll();
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(fitAll);
    var fitAllT;
    window.addEventListener('resize', function () {
      clearTimeout(fitAllT);
      fitAllT = setTimeout(fitAll, 100);
    });
  }

  /* ---------- 3D-объекты (первый экран главной, узел услуги, спираль section 6, икосаэдр section 9): один WebGL-модуль, грузится после загрузки страницы ---------- */
  var glob = document.querySelector('[data-rd-glob], [data-rd-knot], [data-rd-3d], [data-rd-ico]');
  if (glob && glob.dataset.src && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    var loadBlob = function () {
      var s = document.createElement('script');
      s.src = glob.dataset.src;
      s.async = true;
      document.body.appendChild(s);
    };
    var whenIdle = function () {
      if ('requestIdleCallback' in window) window.requestIdleCallback(loadBlob, { timeout: 1500 });
      else setTimeout(loadBlob, 200);
    };
    if (document.readyState === 'complete') whenIdle();
    else window.addEventListener('load', whenIdle);
  }

  /* ---------- Круглые кнопки («Останні роботи», «Обговорити проект»): плавают за курсором ---------- */
  // Тянутся, только когда курсор над своим блоком: через раскрытое меню, другую кнопку или соседний блок — нет.
  // Плавающие кнопки («звонок», «наверх») — только когда курсор над самой кнопкой и слабее (не наезжают друг на друга).
  if (window.matchMedia('(hover: hover) and (pointer: fine)').matches &&
      !window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    Array.prototype.forEach.call(document.querySelectorAll('[data-rd-magnet]'), function (magnet) {
      var pos = { x: 0, y: 0 };
      var target = { x: 0, y: 0 };
      var running = false;
      var isFloat = magnet.classList.contains('rd-float__btn');
      var STRENGTH = isFloat ? 0.2 : 0.4; // доля расстояния до курсора
      var scope = isFloat ? magnet : magnet.closest('.rd-mega, .rd-mobile, .rd-header, section, footer');
      var tick = function () {
        pos.x += (target.x - pos.x) * 0.12;
        pos.y += (target.y - pos.y) * 0.12;
        if (Math.abs(target.x - pos.x) < 0.1 && Math.abs(target.y - pos.y) < 0.1) {
          pos.x = target.x;
          pos.y = target.y;
          running = false;
        }
        magnet.style.transform = 'translate3d(' + pos.x.toFixed(2) + 'px,' + pos.y.toFixed(2) + 'px,0)';
        if (running) requestAnimationFrame(tick);
      };
      var kick = function () {
        if (!running) {
          running = true;
          requestAnimationFrame(tick);
        }
      };
      window.addEventListener('pointermove', function (e) {
        var r = magnet.getBoundingClientRect();
        if (r.bottom < -100 || r.top > window.innerHeight + 100) return; // кнопка далеко за экраном
        // центр без текущего смещения
        var cx = r.left + r.width / 2 - pos.x;
        var cy = r.top + r.height / 2 - pos.y;
        var dx = e.clientX - cx;
        var dy = e.clientY - cy;
        var zone = r.width / 2 + (isFloat ? 0 : 24); // притягивает только у самой кнопки (24px за краем)
        var own = !scope || (e.target && scope.contains(e.target)); // курсор над своим блоком, а не над меню поверх него
        if (own && dx * dx + dy * dy < zone * zone) {
          target.x = dx * STRENGTH;
          target.y = dy * STRENGTH;
        } else {
          target.x = 0;
          target.y = 0;
        }
        kick();
      }, { passive: true });
      document.addEventListener('mouseleave', function () {
        target.x = 0;
        target.y = 0;
        kick();
      });
    });
  }

  /* ---------- Страница портфолио: надписи на фоне карточек, «Показати ще» ---------- */
  var cases = document.querySelector('[data-rd-cases]');
  if (cases) {
    // надпись ≈ 89.7% ширины карточки (как в блоке «Портфоліо»); размер в cqw — подгонка один раз
    var fitCaseWords = function () {
      cases.querySelectorAll('.rd-case__word').forEach(function (word) {
        var mw = word.parentNode.clientWidth;
        if (!mw) return; // спрятанный кейс — подгоним, когда откроется
        var rg = document.createRange();
        rg.selectNodeContents(word);
        var tw = rg.getBoundingClientRect().width;
        if (!tw || word.getAttribute('data-fit')) return;
        var fs = parseFloat(getComputedStyle(word).getPropertyValue('--rd-wfs')) || 9.16;
        word.style.setProperty('--rd-wfs', (fs * 0.897 * mw / tw).toFixed(3));
        word.setAttribute('data-fit', '1');
      });
    };
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(fitCaseWords);
    else fitCaseWords();

    var list = cases.querySelector('[data-rd-cases-list]');
    var more = cases.querySelector('[data-rd-cases-more]');
    if (list && more) {
      var per = parseInt(list.getAttribute('data-per'), 10) || 6;
      list.classList.add('is-limited');
      more.addEventListener('click', function () {
        var next = Array.prototype.slice.call(list.querySelectorAll('[data-rd-more]:not(.is-shown)'), 0, per);
        next.forEach(function (el) { el.classList.add('is-shown'); });
        fitCaseWords();
        more.classList.remove('is-busy');
        void more.offsetWidth; // перезапуск оборота значка
        more.classList.add('is-busy');
        if (!list.querySelector('[data-rd-more]:not(.is-shown)')) {
          var wrap = more.parentNode;
          setTimeout(function () { wrap.hidden = true; }, 500);
        }
        // фокус — на первый открывшийся кейс (клавиатура)
        var first = next[0] && next[0].querySelector('.rd-case__title a');
        if (first && !more.matches(':hover')) first.focus({ preventScroll: true });
      });
    }
  }

  /* ---------- Копирайтинг, «Наше портфоліо»: «Показати ще» открывает следующие работы ---------- */
  var cwpBox = document.querySelector('[data-rd-cwp]');
  if (cwpBox) {
    var cwpList = cwpBox.querySelector('[data-rd-cwp-list]');
    var cwpMore = cwpBox.querySelector('[data-rd-cwp-more]');
    if (cwpList && cwpMore) {
      var cwpPer = parseInt(cwpList.getAttribute('data-per'), 10) || 4;
      cwpList.classList.add('is-limited');
      cwpMore.addEventListener('click', function () {
        var next = Array.prototype.slice.call(cwpList.querySelectorAll('[data-rd-more]:not(.is-shown)'), 0, cwpPer);
        next.forEach(function (el) { el.classList.add('is-shown'); });
        cwpBox.dispatchEvent(new CustomEvent('rd:more')); // rd-wow.js: очередь появления в ряду
        cwpMore.classList.remove('is-busy');
        void cwpMore.offsetWidth; // перезапуск оборота значка
        cwpMore.classList.add('is-busy');
        if (!cwpList.querySelector('[data-rd-more]:not(.is-shown)')) {
          var wrap = cwpMore.parentNode;
          setTimeout(function () { wrap.hidden = true; }, 500);
        }
        var first = next[0] && next[0].querySelector('a');
        if (first && !cwpMore.matches(':hover')) first.focus({ preventScroll: true });
      });
    }
  }

  /* ---------- Просмотр картинок на всю ширину ([data-rd-zoom], «Наше портфоліо» копирайтинга) ---------- */
  // Картинка — во всю ширину экрана (поля 12–40px), длинная прокручивается вниз; листание кнопками, ← → и свайпом;
  // Esc / крестик — закрыть. Открывается из листа и закрывается в него (FLIP: transform), при reduced motion — сразу.
  var zoomers = Array.prototype.slice.call(document.querySelectorAll('[data-rd-zoom]'));
  if (zoomers.length) {
    var lbHost = zoomers[0].closest('[data-rd-lb-close]') || document.body;
    var lbText = function (k, d) { return lbHost.getAttribute('data-rd-lb-' + k) || d; };
    var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var ico = {
      prev: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 12H5m6-6-6 6 6 6"/></svg>',
      next: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14m-6-6 6 6-6 6"/></svg>',
      close: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>'
    };
    var lb = document.createElement('div');
    lb.className = 'rd-lb';
    lb.setAttribute('role', 'dialog');
    lb.setAttribute('aria-modal', 'true');
    lb.setAttribute('data-rd-no-smooth', '');
    lb.hidden = true;
    lb.innerHTML =
      '<div class="rd-lb__scroll"><img class="rd-lb__img" alt="" draggable="false"></div>' +
      '<div class="rd-lb__bar">' +
        '<span class="rd-lb__count" aria-live="polite"></span>' +
        '<span class="rd-lb__nav">' +
          '<button class="rd-lb__btn rd-lb__btn--prev" type="button" aria-label="' + lbText('prev', 'Previous') + '"><span class="rd-lb__fly">' + ico.prev + ico.prev + '</span></button>' +
          '<button class="rd-lb__btn rd-lb__btn--next" type="button" aria-label="' + lbText('next', 'Next') + '"><span class="rd-lb__fly">' + ico.next + ico.next + '</span></button>' +
        '</span>' +
        '<button class="rd-lb__btn rd-lb__btn--close" type="button" aria-label="' + lbText('close', 'Close') + '">' + ico.close + '</button>' +
      '</div>';
    document.body.appendChild(lb);
    var lbScroll = lb.querySelector('.rd-lb__scroll');
    var lbImg = lb.querySelector('.rd-lb__img');
    var lbCount = lb.querySelector('.rd-lb__count');
    var lbPrev = lb.querySelector('.rd-lb__btn--prev');
    var lbNext = lb.querySelector('.rd-lb__btn--next');
    var lbClose = lb.querySelector('.rd-lb__btn--close');
    if (zoomers.length < 2) lb.classList.add('is-single');
    var lbIdx = -1;
    var lbBusy = false;
    var pad2 = function (n) { return (n < 10 ? '0' : '') + n; };
    var paperOf = function (z) { return z.querySelector('.rd-cwp__paper') || z; };
    var ready = function (cb) {
      if (lbImg.complete && lbImg.naturalWidth) { cb(); return; }
      var done = function () { lbImg.removeEventListener('load', done); lbImg.removeEventListener('error', done); cb(); };
      lbImg.addEventListener('load', done);
      lbImg.addEventListener('error', done);
    };
    var setImage = function (i) {
      lbIdx = i;
      var z = zoomers[i];
      lbImg.src = z.getAttribute('data-rd-zoom');
      var pic = z.querySelector('img');
      lbImg.alt = pic ? pic.alt : '';
      lb.setAttribute('aria-label', lbImg.alt);
      lbCount.textContent = pad2(i + 1) + ' / ' + pad2(zoomers.length);
      lbScroll.scrollTop = 0;
    };
    // лист → полная ширина: картинка стартует с места и размера листа
    var flipFrom = function (rect) {
      var to = lbImg.getBoundingClientRect();
      if (!to.width) return;
      lbImg.style.transition = 'none';
      lbImg.style.transform = 'translate(' + (rect.left - to.left) + 'px,' + (rect.top - to.top) + 'px) scale(' + (rect.width / to.width) + ')';
      void lbImg.offsetWidth;
      lbImg.style.transition = '';
      lbImg.style.transform = '';
    };
    var open = function (i) {
      if (lbBusy) return;
      lbBusy = true;
      setImage(i);
      lb.hidden = false;
      document.documentElement.classList.add('rd-lock', 'rd-lb-open');
      document.body.classList.add('rd-lock');
      var z = zoomers[i];
      ready(function () {
        var rect = paperOf(z).getBoundingClientRect();
        if (!reduce && rect.width) {
          z.classList.add('is-zoomed');
          flipFrom(rect);
        }
        requestAnimationFrame(function () { lb.classList.add('is-open'); });
        lbClose.focus({ preventScroll: true });
        setTimeout(function () { lbBusy = false; }, reduce ? 0 : 650);
      });
    };
    var close = function () {
      if (lb.hidden || lbBusy) return;
      lbBusy = true;
      var z = zoomers[lbIdx];
      var finish = function () {
        lb.hidden = true;
        lb.classList.remove('is-open', 'is-closing');
        lbImg.style.transition = '';
        lbImg.style.transform = '';
        zoomers.forEach(function (el) { el.classList.remove('is-zoomed'); });
        document.documentElement.classList.remove('rd-lock', 'rd-lb-open');
        document.body.classList.remove('rd-lock');
        lbBusy = false;
        if (z) z.focus({ preventScroll: true });
      };
      lb.classList.remove('is-open');
      lb.classList.add('is-closing');
      if (reduce || !z) { finish(); return; }
      var rect = paperOf(z).getBoundingClientRect();
      var cur = lbImg.getBoundingClientRect();
      var visible = rect.bottom > 0 && rect.top < window.innerHeight && rect.width > 0;
      if (visible && cur.width) {
        // обратно в лист: от текущего места (с учётом прокрутки) — в прямоугольник листа
        zoomers.forEach(function (el) { if (el !== z) el.classList.remove('is-zoomed'); });
        z.classList.add('is-zoomed');
        lbImg.style.transform = 'translate(' + (rect.left - cur.left) + 'px,' + (rect.top - cur.top) + 'px) scale(' + (rect.width / cur.width) + ')';
      }
      setTimeout(finish, 620);
    };
    var go = function (dir) {
      if (lbBusy || zoomers.length < 2) return;
      lbBusy = true;
      var next = (lbIdx + dir + zoomers.length) % zoomers.length;
      lb.style.setProperty('--dir', dir);
      lb.classList.add('is-swap');
      zoomers.forEach(function (el) { el.classList.remove('is-zoomed'); });
      setTimeout(function () {
        setImage(next);
        ready(function () {
          lb.classList.remove('is-swap');
          lb.classList.add('is-swap-in');
          void lbImg.offsetWidth;
          lb.classList.remove('is-swap-in');
          setTimeout(function () { lbBusy = false; }, 380);
        });
      }, reduce ? 0 : 260);
    };
    zoomers.forEach(function (z, i) {
      z.addEventListener('click', function () { open(i); });
    });
    lbClose.addEventListener('click', close);
    lbPrev.addEventListener('click', function () { go(-1); });
    lbNext.addEventListener('click', function () { go(1); });
    // клик мимо картинки (по полям) — закрыть
    lbScroll.addEventListener('click', function (e) { if (e.target === lbScroll) close(); });
    document.addEventListener('keydown', function (e) {
      if (lb.hidden) return;
      if (e.key === 'Escape') { e.preventDefault(); close(); }
      else if (e.key === 'ArrowLeft') { e.preventDefault(); go(-1); }
      else if (e.key === 'ArrowRight') { e.preventDefault(); go(1); }
      else if (e.key === 'Tab') {
        // фокус — только по кнопкам просмотра
        var f = Array.prototype.filter.call(lb.querySelectorAll('button'), function (b) { return b.offsetParent; });
        var k = f.indexOf(document.activeElement);
        e.preventDefault();
        f[(k + (e.shiftKey ? -1 : 1) + f.length) % f.length].focus();
      }
    });
    // свайп по горизонтали — листать (вертикаль остаётся прокрутке)
    var sw = null;
    lbScroll.addEventListener('touchstart', function (e) {
      var t = e.touches[0];
      sw = { x: t.clientX, y: t.clientY };
    }, { passive: true });
    lbScroll.addEventListener('touchend', function (e) {
      if (!sw) return;
      var t = e.changedTouches[0];
      var dx = t.clientX - sw.x;
      var dy = t.clientY - sw.y;
      sw = null;
      if (Math.abs(dx) > 60 && Math.abs(dx) > Math.abs(dy) * 1.5) go(dx < 0 ? 1 : -1);
    }, { passive: true });
  }

  /* ---------- Портфолио ---------- */
  var pf = document.querySelector('[data-rd-portfolio]');
  if (pf) {
    // Крупная надпись на фоне карточки: ширина ≈ 89.7% карточки (как в макете).
    // Размер задан в cqw — после одной подгонки он сам масштабируется вместе с карточкой.
    var fitWords = function () {
      pf.querySelectorAll('.rd-case__word').forEach(function (word) {
        var media = word.parentNode;
        var mw = media.clientWidth;
        if (!mw) return;
        var rg = document.createRange();
        rg.selectNodeContents(word);
        var tw = rg.getBoundingClientRect().width;
        if (!tw) return;
        var fs = parseFloat(getComputedStyle(word).getPropertyValue('--rd-wfs')) || 9.16;
        word.style.setProperty('--rd-wfs', (fs * 0.897 * mw / tw).toFixed(3));
      });
    };
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(fitWords);
    else fitWords();

    // Десктоп: ленту можно тянуть мышью (если слой «вау» не закрепил блок — тогда двигает прокрутка)
    var vp = pf.querySelector('[data-rd-pf-viewport]');
    if (vp) {
      var drag = null;
      var moved = false;
      vp.addEventListener('pointerdown', function (e) {
        if (e.pointerType !== 'mouse' || e.button !== 0 || pf.classList.contains('is-pinned')) return;
        if (vp.scrollWidth <= vp.clientWidth) return;
        drag = { x: e.clientX, left: vp.scrollLeft };
        moved = false;
      });
      window.addEventListener('pointermove', function (e) {
        if (!drag) return;
        var dx = e.clientX - drag.x;
        if (!moved && Math.abs(dx) > 6) {
          moved = true;
          vp.classList.add('is-dragging');
        }
        if (moved) vp.scrollLeft = drag.left - dx;
      });
      window.addEventListener('pointerup', function () {
        if (!drag) return;
        drag = null;
        vp.classList.remove('is-dragging');
      });
      // после перетаскивания клик по карточке не открывает проект
      vp.addEventListener('click', function (e) {
        if (moved) {
          e.preventDefault();
          e.stopPropagation();
          moved = false;
        }
      }, true);
    }
  }

  var header = document.querySelector('[data-rd-header]');

  /* ---------- Закреплённая шапка: после прокрутки — компактная, на тёмном «стекле» ---------- */
  if (header) {
    var scrolled = null;
    var scrollTick = false;
    var onScroll = function () {
      scrollTick = false;
      var s = window.scrollY > 8;
      if (s !== scrolled) {
        scrolled = s;
        header.classList.toggle('is-scrolled', s);
      }
    };
    window.addEventListener('scroll', function () {
      if (!scrollTick) {
        scrollTick = true;
        requestAnimationFrame(onScroll);
      }
    }, { passive: true });
    onScroll();
  }
  if (!header) return;

  var desktop = window.matchMedia('(min-width: 1200px)');

  /* ---------- Мега-меню «Послуги» (десктоп) ---------- */
  var megaItem = header.querySelector('[data-rd-mega-trigger]');
  var mega = header.querySelector('[data-rd-mega]');

  if (megaItem && mega) {
    var megaLink = megaItem.querySelector('a');
    var closeTimer = null;

    var openMega = function () {
      clearTimeout(closeTimer);
      header.classList.add('is-mega-open');
      megaItem.classList.add('is-open');
      megaLink.setAttribute('aria-expanded', 'true');
      mega.removeAttribute('inert');
    };
    var closeMega = function () {
      clearTimeout(closeTimer);
      header.classList.remove('is-mega-open');
      megaItem.classList.remove('is-open');
      megaLink.setAttribute('aria-expanded', 'false');
      mega.setAttribute('inert', '');
    };
    var closeLater = function () {
      clearTimeout(closeTimer);
      closeTimer = setTimeout(closeMega, 180);
    };

    [megaItem, mega].forEach(function (el) {
      el.addEventListener('mouseenter', function () { if (desktop.matches) openMega(); });
      el.addEventListener('mouseleave', function () { if (desktop.matches) closeLater(); });
    });

    // Тач-экраны с десктопной шириной: первый тап открывает, второй — переход
    megaLink.addEventListener('click', function (e) {
      if (!desktop.matches) return;
      if (window.matchMedia('(hover: none)').matches && !header.classList.contains('is-mega-open')) {
        e.preventDefault();
        openMega();
      }
    });

    // Клавиатура
    megaLink.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowDown' || e.key === ' ') {
        e.preventDefault();
        openMega();
        var first = mega.querySelector('a');
        if (first) first.focus();
      }
    });
    header.addEventListener('focusin', function (e) {
      if (!desktop.matches) return;
      if (megaItem.contains(e.target) || mega.contains(e.target)) openMega();
      else closeMega();
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && header.classList.contains('is-mega-open')) {
        closeMega();
        megaLink.focus();
      }
    });
    document.addEventListener('click', function (e) {
      if (!header.contains(e.target)) closeMega();
    });

    mega.setAttribute('inert', '');
  }

  /* ---------- Мобильное меню ---------- */
  var burger = header.querySelector('[data-rd-burger]');
  var panel = header.querySelector('[data-rd-mobile]');

  if (burger && panel) {
    var setMenu = function (open) {
      header.classList.toggle('is-menu-open', open);
      burger.setAttribute('aria-expanded', open ? 'true' : 'false');
      burger.setAttribute('aria-label', open ? burger.dataset.labelClose : burger.dataset.labelOpen);
      document.documentElement.classList.toggle('rd-lock', open);
      document.body.classList.toggle('rd-lock', open);
      if (open) panel.removeAttribute('inert');
      else panel.setAttribute('inert', '');
    };

    burger.addEventListener('click', function () {
      setMenu(!header.classList.contains('is-menu-open'));
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && header.classList.contains('is-menu-open')) {
        setMenu(false);
        burger.focus();
      }
    });
    desktop.addEventListener('change', function (e) {
      if (e.matches) setMenu(false);
    });

    // Аккордеон групп услуг
    panel.querySelectorAll('[data-rd-group]').forEach(function (group) {
      var btn = group.querySelector('button');
      if (!btn) return;
      btn.addEventListener('click', function () {
        var open = !group.classList.contains('is-open');
        group.classList.toggle('is-open', open);
        btn.setAttribute('aria-expanded', open ? 'true' : 'false');
      });
    });

    panel.setAttribute('inert', '');
  }
  /* ---------- FAQ: десктоп — вкладки (активный вопрос не закрывается), мобайл — аккордеон (открыт максимум один) ---------- */
  Array.prototype.forEach.call(document.querySelectorAll('[data-rd-faq]'), function (faq) {
    var items = Array.prototype.slice.call(faq.querySelectorAll('.rd-faq__item'));
    var wide = window.matchMedia('(min-width: 1200px)');
    var set = function (item, open) {
      item.classList.toggle('is-open', open);
      var btn = item.querySelector('.rd-faq__q');
      if (btn) btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    };
    var open = function (item) {
      items.forEach(function (it) { if (it !== item) set(it, false); });
      set(item, true);
      faq.dispatchEvent(new CustomEvent('rd-faq', { detail: item }));
    };
    items.forEach(function (item) {
      var btn = item.querySelector('.rd-faq__q');
      if (!btn) return;
      btn.addEventListener('click', function () {
        if (item.classList.contains('is-open')) {
          if (!wide.matches) {
            set(item, false);
            faq.dispatchEvent(new CustomEvent('rd-faq', { detail: null }));
          }
        } else {
          open(item);
          // мобайл: если над вопросом свернулся длинный ответ и вопрос уехал под шапку — докручиваем к нему
          if (!wide.matches) {
            var anim = document.documentElement.classList.contains('rd-wow-js');
            setTimeout(function () {
              var top = btn.getBoundingClientRect().top;
              if (top < 80) window.scrollTo({ top: window.scrollY + top - 80, behavior: anim ? 'smooth' : 'auto' });
            }, anim ? 650 : 0);
          }
        }
      });
    });
    // на десктопе ответ виден всегда: если на мобайле всё закрыли — открываем первый
    var ensure = function () {
      if (wide.matches && items.length && !items.some(function (it) { return it.classList.contains('is-open'); })) open(items[0]);
    };
    if (wide.addEventListener) wide.addEventListener('change', ensure);
    else if (wide.addListener) wide.addListener(ensure);
  });

  /* ---------- Блог: «Популярні / Нові» и «Показати ще» ---------- */
  // Все карточки уже в HTML (по просмотрам); видны первые step (до конца ряда), кнопка открывает ещё step.
  // Сортировка переставляет карточки по data-hits / data-date (по убыванию). Без JS — видны все, без сортировки.
  /* ---------- Статья блога: «Зміст», текущий раздел, полоска прочитанного ---------- */
  // «Зміст» собирается из <h2> текста (меньше трёх — не показываем); заголовкам — id (rd-s1, rd-s2…, если своего нет).
  // На десктопе <details> открыт, на телефоне — свёрнут. Текущий раздел — последний <h2> выше трети экрана.
  var art = document.querySelector('[data-rd-art]');
  if (art) {
    var toc = document.querySelector('[data-rd-toc]');
    var heads = Array.prototype.slice.call(art.querySelectorAll('h2')).filter(function (h) { return h.textContent.trim(); });
    var tocLinks = [];
    if (toc && heads.length >= 3) {
      var tocList = toc.querySelector('ol');
      heads.forEach(function (h, k) {
        if (!h.id) h.id = 'rd-s' + (k + 1);
        var li = document.createElement('li');
        var a = document.createElement('a');
        a.href = location.pathname + location.search + '#' + h.id;
        a.textContent = h.textContent.replace(/\s+/g, ' ').trim();
        a.addEventListener('click', function (e) {
          e.preventDefault();
          h.scrollIntoView({ behavior: 'smooth', block: 'start' });
          if (history.replaceState) history.replaceState(null, '', '#' + h.id);
          if (window.innerWidth < 1200) toc.open = false;
        });
        li.appendChild(a);
        tocList.appendChild(li);
        tocLinks.push(a);
      });
      toc.hidden = false;
      toc.open = window.innerWidth >= 1200;
    }
    var bar = document.querySelector('[data-rd-progress]');
    var artQueued = false;
    var artTick = function () {
      artQueued = false;
      var b = art.getBoundingClientRect();
      if (bar) {
        var total = b.height - window.innerHeight * 0.6;
        var pr = total > 0 ? Math.min(1, Math.max(0, -b.top / total)) : 1;
        bar.style.transform = 'scaleX(' + pr.toFixed(4) + ')';
      }
      if (tocLinks.length) {
        var cur = -1;
        var line = window.innerHeight / 3;
        heads.forEach(function (h, k) { if (h.getBoundingClientRect().top <= line) cur = k; });
        tocLinks.forEach(function (a, k) { a.classList.toggle('is-current', k === cur); });
      }
    };
    window.addEventListener('scroll', function () {
      if (!artQueued) { artQueued = true; requestAnimationFrame(artTick); }
    }, { passive: true });
    window.addEventListener('resize', artTick);
    artTick();
  }

  // текущий раздел в ленте «таблеток» на телефоне — в поле зрения (лента прокручивается, страница — нет)
  var blogTabs = document.querySelector('.rd-blog__tabs');
  var blogActive = blogTabs && blogTabs.querySelector('.rd-blog__tab.is-active');
  if (blogActive && blogTabs.scrollWidth > blogTabs.clientWidth) {
    blogTabs.scrollLeft = blogActive.offsetLeft - (blogTabs.clientWidth - blogActive.offsetWidth) / 2;
  }
  var blogGrid = document.querySelector('[data-rd-blog]');
  if (blogGrid) {
    var bItems = Array.prototype.slice.call(blogGrid.children);
    var bStep = parseInt(blogGrid.getAttribute('data-step'), 10) || 12;
    var bShown = bStep;
    var bMore = document.querySelector('[data-rd-blog-more]');
    var bMoreN = bMore && bMore.querySelector('.rd-blog__more-n');
    // сколько видно — до конца ряда (по числу колонок сетки)
    var bFill = function (n) {
      var cols = getComputedStyle(blogGrid).gridTemplateColumns.split(' ').filter(Boolean).length || 1;
      return Math.ceil(n / cols) * cols;
    };
    var bApply = function () {
      var vis = bFill(bShown);
      if (bItems.length - vis <= 3) vis = bItems.length; // кнопка ради 1–3 карточек не нужна — показываем все
      bItems.forEach(function (li, k) { li.classList.toggle('is-off', k >= vis); });
      var rest = bItems.length - vis;
      if (bMore) {
        bMore.hidden = rest <= 0;
        if (bMoreN) bMoreN.textContent = '(' + rest + ')';
      }
    };
    if (bMore) {
      bMore.addEventListener('click', function () {
        bShown = bFill(bShown) + bStep;
        bApply();
      });
    }
    var bResize;
    window.addEventListener('resize', function () {
      clearTimeout(bResize);
      bResize = setTimeout(bApply, 150);
    });
    var bSort = document.querySelector('[data-rd-blog-sort]');
    if (bSort && bItems.length > 1) {
      bSort.hidden = false;
      bSort.addEventListener('click', function (e) {
        var btn = e.target.closest('[data-rd-sort]');
        if (!btn || btn.classList.contains('is-active')) return;
        var key = 'data-' + btn.getAttribute('data-rd-sort');
        Array.prototype.forEach.call(bSort.querySelectorAll('[data-rd-sort]'), function (x) {
          x.classList.toggle('is-active', x === btn);
          x.setAttribute('aria-pressed', x === btn ? 'true' : 'false');
        });
        bItems.sort(function (a, b) { return (+b.getAttribute(key) || 0) - (+a.getAttribute(key) || 0); });
        bItems.forEach(function (li) { blogGrid.appendChild(li); });
        bApply();
      });
    }
    bApply();
  }

  /* ---------- Контакти: «Зараз працюємо» по графику и времени Киева, копирование e-mail ---------- */
  // График — строки [data-rd-hours] («<span>Пн-Пт:</span> з 10.00 - 19.00», «Сб: …»): дни (диапазон или один) и часы.
  // Сегодняшняя строка — .is-today; статус ([data-rd-status]) — .is-open и текст из data-open / data-closed;
  // не разобралось ни одной строки — статус остаётся скрытым. Пересчёт раз в минуту.
  var cntStatus = document.querySelector('[data-rd-status]');
  var cntRows = document.querySelectorAll('[data-rd-hours]');
  if (cntStatus && cntRows.length) {
    var dayNum = { 'пн': 1, 'вт': 2, 'ср': 3, 'чт': 4, 'пт': 5, 'сб': 6, 'нд': 0, 'вс': 0 };
    var week = {};
    Array.prototype.forEach.call(cntRows, function (li) {
      var txt = li.textContent.toLowerCase();
      var dm = txt.match(/(пн|вт|ср|чт|пт|сб|нд|вс)(?:\s*[-\u2013\u2014]\s*(пн|вт|ср|чт|пт|сб|нд|вс))?/);
      var tm = txt.match(/(\d{1,2})[.:](\d{2})\s*[-\u2013\u2014]\s*(\d{1,2})[.:](\d{2})/);
      if (!dm || !tm) return;
      var a = dayNum[dm[1]] || 7;
      var b = dm[2] ? (dayNum[dm[2]] || 7) : a;
      for (var d = a; d <= b; d++) {
        week[d % 7] = { from: +tm[1] * 60 + +tm[2], to: +tm[3] * 60 + +tm[4], li: li };
      }
    });
    var kyivNow = function () {
      var fmt;
      try {
        fmt = new Intl.DateTimeFormat('en-US', { timeZone: 'Europe/Kyiv', weekday: 'short', hour: 'numeric', minute: 'numeric', hourCycle: 'h23' });
      } catch (e) {
        try {
          fmt = new Intl.DateTimeFormat('en-US', { timeZone: 'Europe/Kiev', weekday: 'short', hour: 'numeric', minute: 'numeric', hourCycle: 'h23' });
        } catch (e2) {
          return null;
        }
      }
      var p = {};
      fmt.formatToParts(new Date()).forEach(function (x) { p[x.type] = x.value; });
      var wd = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].indexOf(p.weekday);
      return wd < 0 ? null : { day: wd, min: (+p.hour % 24) * 60 + +p.minute };
    };
    var cntText = cntStatus.querySelector('.rd-cnt__status-text');
    var cntUpdate = function () {
      var now = kyivNow();
      if (!now || !Object.keys(week).length) return;
      var today = week[now.day];
      var open = !!today && now.min >= today.from && now.min < today.to;
      Array.prototype.forEach.call(cntRows, function (li) { li.classList.toggle('is-today', !!today && today.li === li); });
      cntStatus.classList.toggle('is-open', open);
      if (cntText) cntText.textContent = cntStatus.getAttribute(open ? 'data-open' : 'data-closed');
      cntStatus.hidden = false;
    };
    cntUpdate();
    setInterval(cntUpdate, 60000);
  }

  Array.prototype.forEach.call(document.querySelectorAll('[data-rd-copy]'), function (btn) {
    var label = btn.querySelector('span');
    var initial = label ? label.textContent : '';
    var timer;
    var done = function () {
      if (label) label.textContent = btn.getAttribute('data-done') || initial;
      btn.classList.add('is-done');
      clearTimeout(timer);
      timer = setTimeout(function () {
        btn.classList.remove('is-done');
        if (label) label.textContent = initial;
      }, 1800);
    };
    var fallback = function (v) {
      var ta = document.createElement('textarea');
      ta.value = v;
      ta.setAttribute('readonly', '');
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      try { if (document.execCommand('copy')) done(); } catch (e) { /* не вышло — ничего */ }
      document.body.removeChild(ta);
    };
    btn.addEventListener('click', function () {
      var v = btn.getAttribute('data-rd-copy');
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(v).then(done, function () { fallback(v); });
      } else {
        fallback(v);
      }
    });
  });

  // таблица с данными в SEO-тексте (есть ячейки без ссылок: «Веб-візитка | від 1000$») — строками, а не сеткой
  // «таблеток» (_seo.scss, table.is-data). В CSS так не определить: :has() нельзя вкладывать в :has()
  Array.prototype.forEach.call(document.querySelectorAll('.rd-seo__text table'), function (t) {
    var cells = t.querySelectorAll('td, th');
    for (var i = 0; i < cells.length; i++) {
      if (!cells[i].querySelector('a')) {
        t.classList.add('is-data');
        break;
      }
    }
  });

  /* ---------- SEO-текст (section 9): «Розгорнути» / «Згорнути» ---------- */
  // Раскрывается остальной текст (на всю ширину, икосаэдр убирается); кнопка уезжает в конец текста. При сворачивании, если блок ушёл вверх
  // за край экрана, — плавно возвращаемся к нему. Событие rd-seo на секции (detail — открыт ли).
  Array.prototype.forEach.call(document.querySelectorAll('[data-rd-seo]'), function (seo) {
    var btn = seo.querySelector('.rd-seo__toggle');
    if (!btn) return;
    var label = btn.querySelector('.rd-seo__toggle-text');
    var closedText = label.textContent;
    btn.addEventListener('click', function () {
      var open = !seo.classList.contains('is-open');
      seo.classList.toggle('is-open', open);
      // без «вау» текст сразу на всю ширину; со слоем «вау» ширину меняет rd-wow.js после ухода икосаэдра
      if (!document.documentElement.classList.contains('rd-wow-js')) seo.classList.toggle('is-wide', open);
      btn.setAttribute('aria-expanded', open ? 'true' : 'false');
      label.textContent = open ? (btn.getAttribute('data-open') || closedText) : closedText;
      seo.dispatchEvent(new CustomEvent('rd-seo', { detail: open }));
      if (!open) {
        var anim = document.documentElement.classList.contains('rd-wow-js');
        var top = seo.getBoundingClientRect().top;
        if (top < 0) window.scrollTo({ top: window.scrollY + top - 80, behavior: anim ? 'smooth' : 'auto' });
      }
    });
  });

  /* ---------- Форма заявки (section 8): подписи полей, проверка до отправки, ошибки AjaxForm ---------- */
  // Отправляет AjaxForm (jQuery, обработчик на document): наша проверка висит на самой форме и при ошибке
  // не пускает событие дальше. Тексты ошибок — из data-msg (FormIt отвечает по-русски/английски).
  // События для слоя «вау»: rd-lead-invalid (detail — поля с ошибкой), rd-lead-sent (заявка принята).
  Array.prototype.forEach.call(document.querySelectorAll('[data-rd-lead]'), function (form) {
    var status = form.querySelector('.rd-lead__status');
    var inputs = Array.prototype.slice.call(form.querySelectorAll('.rd-field__input'));
    var byName = function (name) { return form.querySelector('.rd-field__input[name="' + name + '"]'); };
    var fieldOf = function (input) { return input && input.closest('.rd-field'); };
    var sync = function (input) {
      var f = fieldOf(input);
      if (f) f.classList.toggle('is-filled', input.value.trim() !== '');
    };
    var setErr = function (input, on) {
      var f = fieldOf(input);
      if (!f) return;
      var err = f.querySelector('.rd-field__err');
      f.classList.toggle('is-error', on);
      input.classList.toggle('error', on);
      if (on) input.setAttribute('aria-invalid', 'true'); else input.removeAttribute('aria-invalid');
      if (err) {
        err.classList.toggle('error', on);
        err.textContent = on ? (err.getAttribute('data-msg') || '') : '';
      }
    };

    inputs.forEach(function (input) {
      sync(input);
      input.addEventListener('input', function () {
        sync(input);
        if (fieldOf(input).classList.contains('is-error')) setErr(input, false);
      });
      input.addEventListener('change', function () { sync(input); });
      input.addEventListener('blur', function () { sync(input); });
    });
    // после успешной отправки AjaxForm сбрасывает форму
    form.addEventListener('reset', function () { setTimeout(function () { inputs.forEach(sync); }, 0); });

    // телефон с intl-tel-input: код страны введён отдельно, цифр в поле меньше
    var itiOf = function (input) {
      var g = window.intlTelInputGlobals;
      return g && g.getInstance ? g.getInstance(input) : null;
    };
    var phoneOk = function (input) {
      var digits = input.value.replace(/\D/g, '').length;
      return digits >= (itiOf(input) ? 7 : 10);
    };
    var emailOk = function (v) { return !v || /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(v); };

    // флаг с кодом страны: отступ текста = его ширина (библиотека пишет свой инлайн — CSS его перебивает)
    var phone = byName('phone');
    var setPad = function () {
      var flag = form.querySelector('.iti__selected-flag');
      if (flag && flag.offsetWidth) fieldOf(phone).style.setProperty('--rd-iti-pl', (flag.offsetWidth + 10) + 'px');
    };
    if (phone) {
      phone.addEventListener('countrychange', setPad);
      phone.addEventListener('focus', setPad);
      window.addEventListener('load', setPad);
      setTimeout(setPad, 0);
    }

    // файл ТЗ: имя и размер в рамке, перетаскивание, проверка типа и размера; «×» убирает файл
    var fileBox = form.querySelector('[data-rd-file]');
    var fileIn = fileBox && fileBox.querySelector('.rd-file__input');
    var fileOk = true;
    if (fileBox && fileIn) {
      var fText = fileBox.querySelector('.rd-file__text');
      var fSize = fileBox.querySelector('.rd-file__size');
      var fClear = fileBox.querySelector('.rd-file__clear');
      var fErr = fileBox.querySelector('.rd-file__err');
      var fEmpty = fText.getAttribute('data-empty') || fText.textContent;
      var maxMb = parseFloat(fileBox.getAttribute('data-max')) || 10;
      var exts = (fileIn.getAttribute('accept') || '').toLowerCase().split(',').map(function (x) { return x.trim(); });
      var human = function (b) { return b < 1048576 ? Math.max(1, Math.round(b / 1024)) + ' KB' : (b / 1048576).toFixed(1).replace('.0', '') + ' MB'; };
      var fileErr = function (msg) {
        fileOk = !msg;
        fileBox.classList.toggle('is-error', !!msg);
        fErr.textContent = msg || '';
        fErr.classList.toggle('error', !!msg);
        if (msg) fileIn.setAttribute('aria-invalid', 'true'); else fileIn.removeAttribute('aria-invalid');
      };
      var showFile = function () {
        var f = fileIn.files && fileIn.files[0];
        fileBox.classList.toggle('is-filled', !!f);
        fClear.hidden = !f;
        fText.textContent = f ? f.name : fEmpty;
        fSize.textContent = f ? human(f.size) : '';
        if (!f) { fileErr(''); return; }
        var ext = '.' + (f.name.split('.').pop() || '').toLowerCase();
        if (exts.length && exts[0] && exts.indexOf(ext) === -1) fileErr(fileBox.getAttribute('data-msg-type'));
        else if (f.size > maxMb * 1048576) fileErr(fileBox.getAttribute('data-msg-size'));
        else fileErr('');
      };
      fileIn.addEventListener('change', showFile);
      fClear.addEventListener('click', function () {
        fileIn.value = '';
        showFile();
        fileIn.focus();
      });
      // перетаскивание файла на рамку
      var dragN = 0;
      fileBox.addEventListener('dragenter', function (e) { e.preventDefault(); dragN++; fileBox.classList.add('is-drag'); });
      fileBox.addEventListener('dragover', function (e) { e.preventDefault(); });
      fileBox.addEventListener('dragleave', function () { if (--dragN <= 0) { dragN = 0; fileBox.classList.remove('is-drag'); } });
      fileBox.addEventListener('drop', function (e) {
        e.preventDefault();
        dragN = 0;
        fileBox.classList.remove('is-drag');
        var dt = e.dataTransfer;
        if (!dt || !dt.files || !dt.files.length) return;
        try {
          fileIn.files = dt.files;
        } catch (er) {
          return;
        }
        showFile();
      });
      form.addEventListener('reset', function () { setTimeout(showFile, 0); });
    }

    form.addEventListener('submit', function (e) {
      if (status) status.textContent = '';
      var bad = [];
      var name = byName('name');
      var email = byName('email');
      if (name && !name.value.trim()) bad.push(name);
      if (phone && !phoneOk(phone)) bad.push(phone);
      if (email && !emailOk(email.value.trim())) bad.push(email);
      [name, phone, email].forEach(function (input) { if (input) setErr(input, bad.indexOf(input) > -1); });
      if (fileIn && !fileOk) bad.push(fileIn);
      if (bad.length) {
        e.preventDefault();
        e.stopPropagation(); // AjaxForm (обработчик на document) не отправит
        bad[0].focus();
        form.dispatchEvent(new CustomEvent('rd-lead-invalid', { detail: bad }));
        return;
      }
      form.classList.add('is-sending');
    });

    var $ = window.jQuery;
    if (!$) return;
    // ответ сервера: af_complete приходит до того, как AjaxForm расставит ошибки — подменяем тексты на свои
    $(document).on('af_complete', function (ev, res) {
      if (!res || !res.form || res.form[0] !== form) return;
      form.classList.remove('is-sending');
      if (res.success) {
        form.classList.add('is-sent');
        form.dispatchEvent(new CustomEvent('rd-lead-sent'));
        return;
      }
      // чанк inttelinput перед отправкой записал в поле полный номер (+380…) — возвращаем его в виджет, иначе код страны задвоится
      var iti = phone && itiOf(phone);
      if (iti && /^\+/.test(phone.value)) iti.setNumber(phone.value);
      var shown = false;
      if (res.data && typeof res.data === 'object') {
        Object.keys(res.data).forEach(function (key) {
          var input = byName(key);
          if (!input) return;
          var err = fieldOf(input).querySelector('.rd-field__err');
          if (err && err.getAttribute('data-msg')) res.data[key] = err.getAttribute('data-msg');
          fieldOf(input).classList.add('is-error');
          input.setAttribute('aria-invalid', 'true');
          shown = true;
        });
      }
      if (!shown && status) status.textContent = status.getAttribute('data-fail') || '';
    });
    // сервер не ответил (AjaxForm в этом случае оставляет форму заблокированной) — разблокируем и пишем об ошибке
    $(document).on('ajaxError', function (ev, xhr, settings) {
      if (!form.classList.contains('is-sending')) return;
      if (settings && settings.url && settings.url.indexOf('ajaxform') === -1) return;
      form.classList.remove('is-sending');
      Array.prototype.forEach.call(form.querySelectorAll('input, button'), function (el) { el.disabled = false; });
      if (status) status.textContent = status.getAttribute('data-fail') || '';
    });
  });

  /* ---------- Модалка «Обговорити проект» (chunks/rd/discuss.tpl, весь сайт) ---------- */
  // Открывают ссылки data-rd-discuss, если ведут на «Контакти» (data-contacts), пустые или «#discuss», и любые
  // ссылки на «#discuss» (в тексте страницы). Ctrl/⌘/Shift/средняя кнопка — обычный переход по ссылке.
  // Фон проявляется, плашка поднимается, строки появляются по очереди (--i). Esc, крестик,
  // клик по фону — закрыть; Tab ходит по кругу внутри, после закрытия фокус — на кнопке. Адрес с #discuss
  // открывает модалку сразу. Заявка принята — переход на «Спасибо» (data-thanks); событие для «вау» — rd-lead-sent.
  var dsc = document.querySelector('[data-rd-dsc]');
  if (dsc) {
    var dscHtml = document.documentElement;
    var dscForm = dsc.querySelector('form');
    var dscScroll = dsc.querySelector('.rd-dsc__scroll');
    var dscClose = dsc.querySelector('.rd-dsc__close');
    var dscReduce = window.matchMedia('(prefers-reduced-motion: reduce)');
    var dscPath = function (href) {
      try {
        return new URL(href, document.baseURI).pathname.replace(/\/+$/, '');
      } catch (er) {
        return null;
      }
    };
    var dscContacts = dscPath(dsc.getAttribute('data-contacts') || '');
    var dscOpener = null;
    var dscTimer = 0;
    Array.prototype.forEach.call(dsc.querySelectorAll('.rd-dsc__title, .rd-dsc__text, .rd-dsc__form .rd-field, .rd-dsc__form .rd-lead__send, .rd-dsc__form .rd-lead__agree, .rd-dsc__contact'), function (el, i) {
      el.setAttribute('data-rd-dsc-i', '');
      el.style.setProperty('--i', i);
    });
    var dscFocusables = function () {
      return Array.prototype.filter.call(dsc.querySelectorAll('a[href], button:not([disabled]), input:not([type="hidden"]):not([disabled]), textarea:not([disabled]), [tabindex]'), function (el) {
        return el.tabIndex >= 0 && el.getClientRects().length > 0;
      });
    };
    var dscUnlock = function () {
      dsc.hidden = true;
      dsc.classList.remove('is-open', 'is-closing');
      dscHtml.classList.remove('rd-lock', 'rd-dsc-open');
      document.body.classList.remove('rd-lock');
    };
    var dscShow = function (opener) {
      if (!dsc.hidden && !dsc.classList.contains('is-closing')) return;
      clearTimeout(dscTimer);
      dscOpener = opener && opener.nodeType === 1 ? opener : null;
      dscHtml.style.setProperty('--rd-sbw', Math.max(0, window.innerWidth - dscHtml.clientWidth) + 'px');
      dsc.classList.remove('is-open', 'is-closing');
      dsc.hidden = false;
      dscScroll.scrollTop = 0;
      dscHtml.classList.add('rd-lock', 'rd-dsc-open');
      document.body.classList.add('rd-lock');
      void dsc.offsetWidth; // старт анимации с закрытого состояния
      requestAnimationFrame(function () { dsc.classList.add('is-open'); });
      // фокус: на сенсорных экранах — сама плашка (без клавиатуры поверх формы), иначе — первое поле
      var first = window.matchMedia('(pointer: coarse)').matches ? dsc.querySelector('.rd-dsc__panel') : (dsc.querySelector('.rd-field__input') || dscClose);
      setTimeout(function () { if (!dsc.hidden) first.focus({ preventScroll: true }); }, dscReduce.matches ? 0 : 320);
      dsc.dispatchEvent(new CustomEvent('rd-dsc-open'));
    };
    var dscHide = function () {
      if (dsc.hidden || dsc.classList.contains('is-closing')) return;
      dsc.classList.remove('is-open');
      dsc.classList.add('is-closing');
      dscTimer = setTimeout(function () {
        dscUnlock();
        if (dscOpener && document.contains(dscOpener)) dscOpener.focus({ preventScroll: true });
        dscOpener = null;
      }, dscReduce.matches ? 0 : 450);
    };
    window.rdDiscuss = { open: dscShow, close: dscHide };

    document.addEventListener('click', function (e) {
      if (e.defaultPrevented || e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
      var a = e.target.closest && e.target.closest('a[data-rd-discuss], a[href$="#discuss"]');
      if (!a || dsc.contains(a)) return;
      var href = (a.getAttribute('href') || '').trim();
      if (!/#discuss$/.test(href) && href && href !== '#' && dscPath(href) !== dscContacts) return; // ссылку поменяли на другую страницу
      e.preventDefault();
      dscShow(a);
    });
    Array.prototype.forEach.call(dsc.querySelectorAll('[data-rd-dsc-close]'), function (el) {
      el.addEventListener('click', dscHide);
    });
    // клик по фону вокруг плашки (слой прокрутки лежит поверх фона); выделение текста, отпущенное за плашкой, — не закрывает
    var dscDownOut = false;
    dscScroll.addEventListener('pointerdown', function (e) { dscDownOut = e.target === dscScroll; });
    dscScroll.addEventListener('click', function (e) {
      if (e.target === dscScroll && dscDownOut) dscHide();
      dscDownOut = false;
    });
    document.addEventListener('keydown', function (e) {
      if (dsc.hidden || dsc.classList.contains('is-closing')) return;
      if (e.key === 'Escape') {
        // открыт список стран у телефона — Esc закрывает сначала его
        if (dsc.querySelector('.iti__country-list:not(.iti__hide)')) return;
        e.preventDefault();
        dscHide();
        return;
      }
      if (e.key !== 'Tab') return;
      var f = dscFocusables();
      if (!f.length) return;
      var i = f.indexOf(document.activeElement);
      if (e.shiftKey && i <= 0) { e.preventDefault(); f[f.length - 1].focus(); }
      else if (!e.shiftKey && (i === -1 || i === f.length - 1)) { e.preventDefault(); f[0].focus(); }
    });
    // вернулись кнопкой «назад» со «Спасибо» — модалка закрыта
    window.addEventListener('pageshow', function (e) {
      if (e.persisted && !dsc.hidden) { clearTimeout(dscTimer); dscUnlock(); }
    });
    if (/^#discuss$/.test(location.hash)) {
      setTimeout(function () { dscShow(null); }, 400);
    }
    if (window.jQuery && dscForm) {
      window.jQuery(document).on('af_complete', function (ev, res) {
        if (!res || !res.success || !res.form || res.form[0] !== dscForm) return;
        var thanks = dsc.getAttribute('data-thanks');
        if (thanks) window.location.href = thanks;
      });
    }
  }

  /* ---------- Видео поверх страницы ([data-rd-video] — ID YouTube; страница «Відгуки») ---------- */
  // Плеер создаётся по клику (youtube-nocookie, автозапуск) и удаляется при закрытии — до клика YouTube не грузится.
  // Esc / крестик / клик мимо видео — закрыть, фокус возвращается на кнопку; страница не прокручивается.
  var vidBtns = document.querySelectorAll('[data-rd-video]');
  if (vidBtns.length) {
    var vidRoot = document.documentElement;
    var vidRu = (vidRoot.getAttribute('lang') || '') === 'ru';
    var vid = document.createElement('div');
    vid.className = 'rd-vid';
    vid.hidden = true;
    vid.setAttribute('role', 'dialog');
    vid.setAttribute('aria-modal', 'true');
    vid.setAttribute('aria-label', vidRu ? 'Видео' : 'Відео');
    vid.innerHTML = '<div class="rd-vid__frame"></div><button class="rd-vid__close" type="button" aria-label="' + (vidRu ? 'Закрыть' : 'Закрити') +
      '"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg></button>';
    document.body.appendChild(vid);
    var vidFrame = vid.querySelector('.rd-vid__frame');
    var vidClose = vid.querySelector('.rd-vid__close');
    var vidOpener = null;
    var vidTimer = 0;
    var vidReduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var vidShow = function (id, opener) {
      clearTimeout(vidTimer);
      vidOpener = opener;
      vidFrame.innerHTML = '<iframe src="https://www.youtube-nocookie.com/embed/' + encodeURIComponent(id) +
        '?autoplay=1&rel=0&modestbranding=1&playsinline=1" title="YouTube" allow="autoplay; encrypted-media; picture-in-picture; fullscreen" allowfullscreen></iframe>';
      vidRoot.style.setProperty('--rd-sbw', Math.max(0, window.innerWidth - vidRoot.clientWidth) + 'px');
      vid.hidden = false;
      vidRoot.classList.add('rd-lock', 'rd-vid-open');
      document.body.classList.add('rd-lock');
      void vid.offsetWidth;
      requestAnimationFrame(function () { vid.classList.add('is-open'); });
      vidClose.focus({ preventScroll: true });
    };
    var vidHide = function () {
      if (vid.hidden) return;
      vid.classList.remove('is-open');
      vidTimer = setTimeout(function () {
        vid.hidden = true;
        vidFrame.innerHTML = '';
        vidRoot.classList.remove('rd-lock', 'rd-vid-open');
        document.body.classList.remove('rd-lock');
        if (vidOpener) vidOpener.focus({ preventScroll: true });
      }, vidReduce ? 0 : 400);
    };
    Array.prototype.forEach.call(vidBtns, function (b) {
      b.addEventListener('click', function () { vidShow(b.getAttribute('data-rd-video'), b); });
    });
    vidClose.addEventListener('click', vidHide);
    vid.addEventListener('click', function (e) { if (e.target === vid) vidHide(); });
    document.addEventListener('keydown', function (e) {
      if (vid.hidden) return;
      if (e.key === 'Escape') { e.preventDefault(); vidHide(); }
      if (e.key === 'Tab') { e.preventDefault(); vidClose.focus(); } // внутри — только крестик (iframe держит фокус сам)
    });
  }

  /* ---------- Страница «Відгуки» (reviews.tpl) ---------- */
  // Средняя оценка и число отзывов — по карточкам на странице (data-rating > 0 — оценённые); «Показати ще» по 6;
  // форма easyComm ([data-rd-rev-form]): подписи полей, проверка до отправки (имя, текст, e-mail), звёзды с клавиатуры,
  // «отправляем…», тексты ошибок — свои (data-msg); сообщения easyComm без поля — в строку статуса, а не alert().
  var rev = document.querySelector('[data-rd-rev]');
  if (rev) {
    var revCards = Array.prototype.slice.call(rev.querySelectorAll('.rd-vrev, .rd-rcard'));
    var revRated = revCards.map(function (c) { return parseFloat(c.getAttribute('data-rating')) || 0; }).filter(function (v) { return v > 0; });
    var revScore = rev.querySelector('[data-rd-rev-score]');
    var revCount = rev.querySelector('[data-rd-rev-count]');
    if (revScore && revRated.length) {
      var avg = revRated.reduce(function (a, b) { return a + b; }, 0) / revRated.length;
      var avgTxt = (Math.round(avg * 10) / 10).toFixed(1);
      revScore.querySelector('[data-rd-rev-avg]').textContent = avgTxt;
      var stars = revScore.querySelector('[data-rd-rev-stars]');
      stars.style.setProperty('--p', (avg / 5 * 100).toFixed(1) + '%');
      stars.setAttribute('aria-label', avgTxt + ' / 5');
      revScore.hidden = false;
    }
    if (revCount && revCards.length) {
      var n = revCards.length;
      var forms = (revCount.getAttribute('data-forms') || '').split('|');
      var n10 = n % 10;
      var n100 = n % 100;
      var form = (n10 === 1 && n100 !== 11) ? 0 : (n10 >= 2 && n10 <= 4 && (n100 < 12 || n100 > 14)) ? 1 : 2;
      revCount.querySelector('[data-rd-rev-n]').textContent = n;
      revCount.querySelector('[data-rd-rev-word]').textContent = forms[form] || forms[0] || '';
      revCount.hidden = false;
    }

    // «Показати ще»: видно 6 карточек, дальше — по 6
    var revList = rev.querySelector('[data-rd-rev-list]');
    var revMore = rev.querySelector('[data-rd-rev-more]');
    if (revList && revMore) {
      var rCards = Array.prototype.slice.call(revList.querySelectorAll('.rd-rcard'));
      var rShown = 6;
      var rApply = function () {
        rCards.forEach(function (c, i) { c.hidden = i >= rShown; });
        var left = rCards.length - rShown;
        revMore.hidden = left <= 0;
        var nEl = revMore.querySelector('.rd-rev__more-n');
        if (nEl) nEl.textContent = left > 0 ? '(' + left + ')' : '';
      };
      revMore.addEventListener('click', function () {
        var first = rCards[rShown];
        rShown += 6;
        rApply();
        if (first) first.focus({ preventScroll: true });
      });
      rCards.forEach(function (c) { c.setAttribute('tabindex', '-1'); });
      rApply();
    }

    var revForm = rev.querySelector('[data-rd-rev-form]');
    if (revForm) {
      var rfStatus = revForm.querySelector('[data-rd-rev-status]');
      var rfInputs = Array.prototype.slice.call(revForm.querySelectorAll('.rd-field__input'));
      var rfField = function (input) { return input.closest('.rd-field'); };
      var rfSync = function (input) { rfField(input).classList.toggle('is-filled', input.value.trim() !== ''); };
      var rfErr = function (input, on, msg) {
        var f = rfField(input);
        var err = f.querySelector('.rd-field__err');
        f.classList.toggle('has-error', on);
        if (on) input.setAttribute('aria-invalid', 'true'); else input.removeAttribute('aria-invalid');
        if (err) {
          err.textContent = on ? (msg || err.getAttribute('data-msg') || '') : '';
          err.style.display = '';
        }
      };
      rfInputs.forEach(function (input) {
        rfSync(input);
        input.addEventListener('input', function () {
          rfSync(input);
          if (rfField(input).classList.contains('has-error')) rfErr(input, false);
        });
        input.addEventListener('blur', function () { rfSync(input); });
      });
      revForm.addEventListener('reset', function () { setTimeout(function () { rfInputs.forEach(rfSync); }, 0); });

      // звёзды: клавиатура (стрелки, Enter / пробел), aria-checked; клик — easyComm (custom.js)
      var rfStars = Array.prototype.slice.call(revForm.querySelectorAll('.ec-rating-stars > span'));
      rfStars.forEach(function (s, i) { s.style.setProperty('--s', i); });
      var rfMark = function () {
        var val = parseInt((revForm.querySelector('input[name="rating"]') || {}).value, 10) || 0;
        rfStars.forEach(function (s, i) {
          var on = i + 1 === val;
          s.setAttribute('aria-checked', on ? 'true' : 'false');
          s.tabIndex = (val ? on : i === rfStars.length - 1) ? 0 : -1;
        });
      };
      rfStars.forEach(function (s, i) {
        s.addEventListener('click', function () { setTimeout(rfMark, 0); });
        s.addEventListener('keydown', function (e) {
          var to = null;
          if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); s.click(); return; }
          if (e.key === 'ArrowRight' || e.key === 'ArrowUp') to = Math.min(rfStars.length - 1, i + 1);
          if (e.key === 'ArrowLeft' || e.key === 'ArrowDown') to = Math.max(0, i - 1);
          if (to === null) return;
          e.preventDefault();
          rfStars[to].click();
          rfStars[to].focus();
        });
      });
      revForm.addEventListener('reset', function () {
        setTimeout(function () {
          rfStars.forEach(function (s) { s.classList.remove('active', 'active2', 'active-disabled'); });
          var d = revForm.querySelector('.ec-rating-description');
          if (d) d.textContent = '';
          rfMark();
        }, 0);
      });

      // проверка до отправки: имя и текст обязательны, e-mail — если указан
      var rfByName = function (nm) { return revForm.querySelector('[name="' + nm + '"]'); };
      revForm.addEventListener('submit', function (e) {
        if (rfStatus) rfStatus.textContent = '';
        var bad = [];
        var nm = rfByName('user_name');
        var tx = rfByName('text');
        var em = rfByName('user_email');
        [nm, tx, em].forEach(function (inp) { if (inp) rfErr(inp, false); });
        if (nm && !nm.value.trim()) bad.push(nm);
        if (em && em.value.trim() && !/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(em.value.trim())) bad.push(em);
        if (tx && !tx.value.trim()) bad.push(tx);
        if (bad.length) {
          e.preventDefault();
          e.stopPropagation(); // easyComm (обработчик на document) не отправит
          bad.forEach(function (inp) { rfErr(inp, true); });
          bad[0].focus();
          revForm.dispatchEvent(new CustomEvent('rd-lead-invalid', { detail: bad }));
          return;
        }
        revForm.classList.add('is-sending');
        var btn = revForm.querySelector('[type="submit"]');
        if (btn) btn.disabled = true;
      });

      var $r = window.jQuery;
      var rfDone = function () {
        revForm.classList.remove('is-sending');
        var btn = revForm.querySelector('[type="submit"]');
        if (btn) btn.disabled = false;
      };
      if ($r) {
        $r(document).on('ajaxComplete', function (ev, xhr, settings) {
          if (!revForm.classList.contains('is-sending')) return;
          if (!settings || !settings.url || settings.url.indexOf('easycomm') === -1) return;
          rfDone();
          var res = xhr && xhr.responseJSON;
          if (!res) {
            try { res = JSON.parse(xhr.responseText); } catch (er) { res = null; }
          }
          if (!res) { if (rfStatus) rfStatus.textContent = revForm.getAttribute('data-fail') || ''; return; }
          if (res.success) {
            revForm.dispatchEvent(new CustomEvent('rd-rev-sent'));
            return;
          }
          // ошибки по полям — свои тексты
          (res.data || []).forEach(function (er2) {
            var inp = er2 && rfByName(er2.field);
            if (inp && inp.classList.contains('rd-field__input')) rfErr(inp, true);
          });
        });
        $r(document).on('ajaxError', function (ev, xhr, settings) {
          if (!revForm.classList.contains('is-sending')) return;
          if (settings && settings.url && settings.url.indexOf('easycomm') === -1) return;
          rfDone();
          if (rfStatus) rfStatus.textContent = revForm.getAttribute('data-fail') || '';
        });
      }
      // easyComm показывает общие ошибки через alert() — пишем в строку статуса формы
      var rfPatch = function () {
        var ec = window.easyComm;
        if (!ec || !ec.notice || ec.notice.rdPatched) return;
        var orig = ec.notice.error;
        ec.notice.error = function (text) {
          if (rfStatus && document.body.contains(revForm) && revForm.offsetParent !== null) {
            rfStatus.textContent = text === 'Submit error' ? (revForm.getAttribute('data-fail') || text) : text;
          } else if (orig) {
            orig(text);
          }
        };
        ec.notice.rdPatched = true;
      };
      rfPatch();
      window.addEventListener('load', rfPatch);
    }
  }

  /* ---------- Плавающие кнопки (весь сайт): звонок + «наверх» с прогрессом прокрутки по контуру ---------- */
  // .is-on — после половины первого экрана; прогресс — stroke-dashoffset кольца (длина пути = 1).
  var flt = document.querySelector('[data-rd-float]');
  if (flt) {
    var fltBar = flt.querySelector('.rd-float__bar');
    var fltUp = flt.querySelector('[data-rd-up]');
    var fltQueued = false;
    var fltUpdate = function () {
      fltQueued = false;
      var de = document.documentElement;
      var y = window.pageYOffset || de.scrollTop;
      var max = de.scrollHeight - window.innerHeight;
      var p = max > 0 ? Math.min(1, Math.max(0, y / max)) : 0;
      if (fltBar) fltBar.style.strokeDashoffset = (1 - p).toFixed(4);
      flt.classList.toggle('is-on', y > window.innerHeight * 0.5);
    };
    var fltQueue = function () {
      if (fltQueued) return;
      fltQueued = true;
      requestAnimationFrame(fltUpdate);
    };
    window.addEventListener('scroll', fltQueue, { passive: true });
    window.addEventListener('resize', fltQueue);
    window.addEventListener('load', fltQueue);
    fltUpdate();
    if (fltUp) {
      fltUp.addEventListener('click', function () {
        var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        window.scrollTo({ top: 0, behavior: reduce ? 'auto' : 'smooth' });
      });
    }
  }

  /* ---------- Копирайтинг, «Корисні СЕО-тексти» / «Вартість СЕО-текстів»: тёмной становится карточка под курсором ---------- */
  // Держится, пока курсор не дошёл до другой карточки (на промежутке 20px ничего не мигает); ушёл со списка — снова исходная.
  if (window.matchMedia('(hover: hover) and (pointer: fine)').matches) {
    Array.prototype.forEach.call(document.querySelectorAll('.rd-cws__list'), function (cwsList) {
      var cwsCur = null;
      Array.prototype.forEach.call(cwsList.querySelectorAll('.rd-cws__card'), function (card) {
        card.addEventListener('pointerenter', function (e) {
          if (e.pointerType !== 'mouse' || cwsCur === card) return;
          if (cwsCur) cwsCur.classList.remove('is-dark');
          cwsCur = card;
          card.classList.add('is-dark');
          cwsList.classList.add('is-hovering');
        });
      });
      cwsList.addEventListener('pointerleave', function () {
        if (cwsCur) cwsCur.classList.remove('is-dark');
        cwsCur = null;
        cwsList.classList.remove('is-hovering');
      });
    });
  }

  /* ---------- Копирайтинг, «Чому ми»: кольца картинки «Не використовуємо AI» ([data-rd-rings]) ---------- */
  // 15 «волнистых» колец — плавный переход от внутренней формы A к внешней B, как blend в макете. Форма — радиус
  // по углу рядом Фурье: r(θ) = c0 + Σ (a_k cos kθ + b_k sin kθ), k ≤ 14 (снято с растра copywriting_1920.pdf;
  // единицы — пиксели макета, от центра колец). Здесь рисуется статичная картинка; rd-wow.js оживляет те же кольца
  // через window.rdRings(g, { a, b, amp, pull, pullAng }): a / b — поворот внутренней / внешней формы (рад),
  // amp — множитель «волн», pull — выпуклость колец к курсору (пикс.) в сторону pullAng.
  var ringSvgs = document.querySelectorAll('[data-rd-rings]');
  if (ringSvgs.length) {
    var RA = [33.35, 1.58, -4.83, 1.23, -0.14, 0.46, 0.32, -0.13, -0.51, 0.44, 0.83, -0.84, 0.96, 0.03, -0.2, -0.23, 0.95, -0.05, 0.03, 1.45, 0.39, -0.45, -1.38, -0.78, -0.08, -0.71, -0.03, 0.11, 0.1];
    var RB = [88.87, 2.26, -0.49, 0.54, 2.7, -1.1, 0.94, 0.46, 0.38, 0.33, -2.52, 3.68, 1.59, -3.1, 1.26, -0.25, 1.12, -1.75, 1.25, 0.9, 3.37, 3.16, -1.29, 0.74, -0.12, 1.67, -0.52, -0.78, 0.44];
    var RN = 15;
    var RP = 96;
    var RK = (RA.length - 1) / 2;
    var rCos = new Float64Array(RP * RK);
    var rSin = new Float64Array(RP * RK);
    var pCos = new Float64Array(RP);
    var pSin = new Float64Array(RP);
    for (var rj = 0; rj < RP; rj++) {
      var rth = 2 * Math.PI * rj / RP;
      pCos[rj] = Math.cos(rth);
      pSin[rj] = Math.sin(rth);
      for (var rk = 1; rk <= RK; rk++) {
        rCos[rj * RK + rk - 1] = Math.cos(rk * rth);
        rSin[rj * RK + rk - 1] = Math.sin(rk * rth);
      }
    }
    // поворот формы на угол al: r(θ − al)
    var ringRot = function (c, al, out) {
      out[0] = c[0];
      for (var k = 1; k <= RK; k++) {
        var ca = Math.cos(k * al);
        var sa = Math.sin(k * al);
        out[2 * k - 1] = c[2 * k - 1] * ca - c[2 * k] * sa;
        out[2 * k] = c[2 * k - 1] * sa + c[2 * k] * ca;
      }
      return out;
    };
    var cA = new Float64Array(RA.length);
    var cB = new Float64Array(RB.length);
    var px = new Float64Array(RP);
    var py = new Float64Array(RP);
    var f1 = function (v) { return (Math.round(v * 10) / 10).toString(); };
    window.rdRings = function (g, o) {
      o = o || {};
      ringRot(RA, o.a || 0, cA);
      ringRot(RB, o.b || 0, cB);
      var amp = o.amp == null ? 1 : o.amp;
      var pull = o.pull || 0;
      var pullAng = o.pullAng || 0;
      var paths = g.children;
      for (var i = 0; i < RN; i++) {
        var s = i / (RN - 1);
        var j;
        for (j = 0; j < RP; j++) {
          var r = cA[0] + (cB[0] - cA[0]) * s;
          var h = 0;
          for (var k = 1; k <= RK; k++) {
            var n = j * RK + k - 1;
            h += (cA[2 * k - 1] + (cB[2 * k - 1] - cA[2 * k - 1]) * s) * rCos[n] + (cA[2 * k] + (cB[2 * k] - cA[2 * k]) * s) * rSin[n];
          }
          r += h * amp;
          if (pull) {
            var dAng = Math.atan2(Math.sin(2 * Math.PI * j / RP - pullAng), Math.cos(2 * Math.PI * j / RP - pullAng));
            r += pull * (0.35 + 0.65 * s) * Math.exp(-dAng * dAng / 0.32);
          }
          px[j] = r * pCos[j];
          py[j] = r * pSin[j];
        }
        // замкнутый сплайн Catmull-Rom → кубические Безье
        var d = 'M' + f1(px[0]) + ' ' + f1(py[0]);
        for (j = 0; j < RP; j++) {
          var j0 = (j + RP - 1) % RP;
          var j2 = (j + 1) % RP;
          var j3 = (j + 2) % RP;
          d += 'C' + f1(px[j] + (px[j2] - px[j0]) / 6) + ' ' + f1(py[j] + (py[j2] - py[j0]) / 6) + ' ' +
            f1(px[j2] - (px[j3] - px[j]) / 6) + ' ' + f1(py[j2] - (py[j3] - py[j]) / 6) + ' ' + f1(px[j2]) + ' ' + f1(py[j2]);
        }
        paths[i].setAttribute('d', d + 'Z');
      }
    };
    Array.prototype.forEach.call(ringSvgs, function (svg) {
      var g = svg.querySelector('.rd-why__rings');
      if (!g) return;
      // снаружи внутрь: --k — очередь прорисовки в «вау»
      for (var i = 0; i < RN; i++) {
        var p = document.createElementNS('http://www.w3.org/2000/svg', 'path');
        p.setAttribute('pathLength', '1');
        p.style.setProperty('--k', RN - 1 - i);
        g.appendChild(p);
      }
      window.rdRings(g);
    });
  }
})();
