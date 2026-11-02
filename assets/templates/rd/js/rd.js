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

  /* ---------- 3D-объекты (первый экран, спираль section 6): один WebGL-модуль, грузится после загрузки страницы ---------- */
  var glob = document.querySelector('[data-rd-glob], [data-rd-3d]');
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

    form.addEventListener('submit', function (e) {
      if (status) status.textContent = '';
      var bad = [];
      var name = byName('name');
      var email = byName('email');
      if (name && !name.value.trim()) bad.push(name);
      if (phone && !phoneOk(phone)) bad.push(phone);
      if (email && !emailOk(email.value.trim())) bad.push(email);
      [name, phone, email].forEach(function (input) { if (input) setErr(input, bad.indexOf(input) > -1); });
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
})();
