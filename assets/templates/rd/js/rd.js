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

  /* ---------- Золотой объект: WebGL-модуль грузится после загрузки страницы ---------- */
  var glob = document.querySelector('[data-rd-glob]');
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
  if (window.matchMedia('(hover: hover) and (pointer: fine)').matches &&
      !window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    Array.prototype.forEach.call(document.querySelectorAll('[data-rd-magnet]'), function (magnet) {
      var pos = { x: 0, y: 0 };
      var target = { x: 0, y: 0 };
      var running = false;
      var STRENGTH = 0.4; // доля расстояния до курсора
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
        var zone = r.width / 2 + 24; // притягивает только у самой кнопки (24px за краем)
        if (dx * dx + dy * dy < zone * zone) {
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
})();
