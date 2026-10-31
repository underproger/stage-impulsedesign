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
