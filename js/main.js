/* ==========================================================================
   ACADEMIA PIMENTA FITNESS — main.js
   Menu mobile, animações de entrada, lightbox da galeria, formulário e eventos.
   ========================================================================== */
(function () {
  'use strict';

  /* ---------- Menu mobile ---------- */
  var toggle = document.querySelector('.nav-toggle');
  var nav = document.getElementById('site-nav');

  if (toggle && nav) {
    var closeNav = function () {
      toggle.setAttribute('aria-expanded', 'false');
      nav.classList.remove('is-open');
      toggle.querySelector('.visually-hidden').textContent = 'Abrir menu';
    };

    toggle.addEventListener('click', function () {
      var open = toggle.getAttribute('aria-expanded') === 'true';
      toggle.setAttribute('aria-expanded', String(!open));
      nav.classList.toggle('is-open', !open);
      toggle.querySelector('.visually-hidden').textContent = open ? 'Abrir menu' : 'Fechar menu';
    });

    nav.addEventListener('click', function (e) {
      if (e.target.closest('a')) closeNav();
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && nav.classList.contains('is-open')) {
        closeNav();
        toggle.focus();
      }
    });

    window.addEventListener('resize', function () {
      if (window.innerWidth > 900) closeNav();
    });
  }

  /* ---------- Animações de entrada ---------- */
  var revealItems = Array.prototype.slice.call(document.querySelectorAll('.reveal'));
  var reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  var showAll = function () {
    revealItems.forEach(function (el) { el.classList.add('is-visible'); });
  };

  if (reduced || !('IntersectionObserver' in window)) {
    showAll();
  } else {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          io.unobserve(entry.target);
        }
      });
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.08 });

    revealItems.forEach(function (el) { io.observe(el); });

    // Segurança: se algo falhar, o conteúdo aparece mesmo assim.
    window.setTimeout(showAll, 2500);
  }

  /* ---------- Lightbox da galeria ---------- */
  var lightbox = document.querySelector('.lightbox');
  var photoButtons = Array.prototype.slice.call(document.querySelectorAll('[data-lightbox]'));

  if (lightbox && photoButtons.length) {
    var lbImg = lightbox.querySelector('img');
    var lbCap = lightbox.querySelector('figcaption');
    var lbClose = lightbox.querySelector('.lb-close');
    var lbPrev = lightbox.querySelector('.lb-prev');
    var lbNext = lightbox.querySelector('.lb-next');
    var current = 0;
    var lastFocus = null;

    var render = function () {
      var btn = photoButtons[current];
      var img = btn.querySelector('img');
      lbImg.src = btn.getAttribute('data-full') || img.src;
      lbImg.alt = img.alt;
      lbCap.textContent = btn.getAttribute('data-caption') || img.alt;
    };

    var open = function (index) {
      current = index;
      lastFocus = document.activeElement;
      render();
      lightbox.classList.add('is-open');
      lightbox.setAttribute('aria-hidden', 'false');
      document.body.style.overflow = 'hidden';
      lbClose.focus();
    };

    var close = function () {
      lightbox.classList.remove('is-open');
      lightbox.setAttribute('aria-hidden', 'true');
      document.body.style.overflow = '';
      if (lastFocus) lastFocus.focus();
    };

    var step = function (delta) {
      current = (current + delta + photoButtons.length) % photoButtons.length;
      render();
    };

    photoButtons.forEach(function (btn, i) {
      btn.addEventListener('click', function () { open(i); });
    });

    lbClose.addEventListener('click', close);
    lbPrev.addEventListener('click', function () { step(-1); });
    lbNext.addEventListener('click', function () { step(1); });

    lightbox.addEventListener('click', function (e) {
      if (e.target === lightbox) close();
    });

    document.addEventListener('keydown', function (e) {
      if (!lightbox.classList.contains('is-open')) return;
      if (e.key === 'Escape') close();
      if (e.key === 'ArrowLeft') step(-1);
      if (e.key === 'ArrowRight') step(1);
      if (e.key === 'Tab') {
        // mantém o foco dentro do lightbox
        var focusables = lightbox.querySelectorAll('button');
        var first = focusables[0];
        var last = focusables[focusables.length - 1];
        if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
        else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
      }
    });
  }

  /* ---------- Formulário de contato ---------- */
  var form = document.querySelector('[data-contact-form]');

  if (form) {
    var status = form.querySelector('.form-status');

    var setError = function (field, message) {
      var wrap = field.closest('.field');
      var error = wrap.querySelector('.error');
      wrap.classList.toggle('has-error', Boolean(message));
      field.setAttribute('aria-invalid', message ? 'true' : 'false');
      if (error) error.textContent = message || '';
      return !message;
    };

    var validate = function () {
      var ok = true;
      var name = form.querySelector('#nome');
      var phone = form.querySelector('#telefone');
      var message = form.querySelector('#mensagem');

      ok = setError(name, name.value.trim().length < 2 ? 'Informe seu nome.' : '') && ok;

      var digits = phone.value.replace(/\D/g, '');
      ok = setError(phone, digits.length < 10 ? 'Informe um telefone com DDD.' : '') && ok;

      ok = setError(message, message.value.trim().length < 5 ? 'Escreva uma mensagem (mínimo 5 letras).' : '') && ok;

      return ok;
    };

    form.addEventListener('submit', function (e) {
      e.preventDefault();

      if (!validate()) {
        var firstInvalid = form.querySelector('.has-error input, .has-error textarea');
        if (firstInvalid) firstInvalid.focus();
        return;
      }

      // Sem backend: a confirmação é exibida na própria página.
      if (status) {
        status.classList.add('is-visible');
        status.setAttribute('role', 'status');
      }
      form.reset();

      track('formulario', 'envio');
    });

    form.querySelectorAll('input, textarea').forEach(function (field) {
      field.addEventListener('blur', function () {
        if (field.closest('.field').classList.contains('has-error')) validate();
      });
    });
  }

  /* ---------- Aviso de rodapé / ano dinâmico ---------- */
  var year = document.querySelector('[data-year]');
  if (year) year.textContent = String(new Date().getFullYear());

  /* ---------- Eventos (indicadores de sucesso do PRD) ---------- */
  function track(action, label) {
    if (typeof window.gtag === 'function') {
      window.gtag('event', action, { event_label: label });
    }
    if (window.dataLayer && window.dataLayer.push) {
      window.dataLayer.push({ event: action, label: label });
    }
  }

  document.querySelectorAll('[data-track]').forEach(function (el) {
    el.addEventListener('click', function () {
      track(el.getAttribute('data-track'), el.getAttribute('data-label') || '');
    });
  });
})();
