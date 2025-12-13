document.addEventListener("DOMContentLoaded", function () {
  const path = location.pathname;

  // Determinar si estamos en una subcarpeta
  const base = path.includes("/lection/") ||
               path.includes("/appendice/") ||
               path.includes("/lessons/") ||
               path.includes("/games/") ||
               path.includes("/lecturas/")
    ? "../components/"
    : "components/";

  function include(selector, file, cb) {
    fetch(base + file)
      .then(res => res.text())
      .then(html => {
        const elements = document.querySelectorAll(selector);
        if (elements.length > 0) {
          elements.forEach(element => {
            element.innerHTML = html;
          });
          if (cb) cb();
        } else {
          console.warn(`No se encontraron elementos con el selector: ${selector}`);
        }
      })
      .catch(error => {
        console.error(`Error cargando ${file}:`, error);
      });
  }

  function initLang() {
    const current = localStorage.getItem('lang') || 'es';
    document.querySelectorAll('.lang-option').forEach(link => {
      if (link.dataset.lang === current) link.classList.add('active');
      link.addEventListener('click', (e) => {
        e.preventDefault();
        localStorage.setItem('lang', link.dataset.lang);
        location.reload();
      });
    });
  }

  include("#navbar-placeholder, nav", "navbar.html", initLang);
  include("#footer-placeholder, footer", "footer.html");

  // Cargar script de progreso en todas las páginas
  const progressScript = document.createElement('script');
  progressScript.src = "/js/progress.js";
  document.body.appendChild(progressScript);

  const CHATINA_JQUERY_SRC = "https://code.jquery.com/jquery-3.7.1.min.js";
  const CHATINA_SCRIPT_SRC = "https://ia.softwcloud.com/app/IA/chat_js/chat.js?type=mini&key=lnyghdrM5s7ixKFYr5q/u5FeWklsm25en5vAt5+fqknFt6Cnx1FYVlU=";

  function loadScriptOnce(src) {
    const existing = document.querySelector(`script[src="${src}"]`);
    if (existing) {
      return existing.dataset.loaded === "true"
        ? Promise.resolve()
        : new Promise((resolve, reject) => {
            existing.addEventListener('load', () => resolve());
            existing.addEventListener('error', reject);
          });
    }

    return new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = src;
      script.async = true;
      script.dataset.loaded = "false";

      script.addEventListener('load', () => {
        script.dataset.loaded = "true";
        resolve();
      });
      script.addEventListener('error', reject);

      document.head.appendChild(script);
    });
  }

  let chatinaLoader;
  function loadChatinaBundle() {
    if (!chatinaLoader) {
      const ensureJQuery = window.jQuery ? Promise.resolve() : loadScriptOnce(CHATINA_JQUERY_SRC);
      chatinaLoader = ensureJQuery.then(() => loadScriptOnce(CHATINA_SCRIPT_SRC));
    }
    return chatinaLoader;
  }

  function isDarkModeActive() {
    const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    const body = document.body;
    return body.classList.contains('dark-mode') || body.classList.contains('dark') || prefersDark;
  }

  const chatinaCandidatesSelector = [
    '[id*="chatina" i]',
    '[class*="chatina" i]',
    '[data-widget*="chatina" i]',
    '[class*="softwcloud" i]'
  ].join(',');

  function isChatinaRoot(node) {
    if (!(node instanceof Element)) return false;
    const datasetValue = node.getAttribute('data-widget') || '';
    const signature = `${node.id || ''} ${node.className || ''} ${datasetValue}`.toLowerCase();
    return signature.includes('chatina') || signature.includes('softwcloud');
  }

  function createDarkThemeStyle(target) {
    const style = document.createElement('style');
    style.dataset.chatinaTheme = 'true';
    style.textContent = `
      :host, :host *,
      .chatina-theme-scope, .chatina-theme-scope * {
        color: #eaeaea !important;
        opacity: 1 !important;
      }

      :host, :host *,
      .chatina-theme-scope, .chatina-theme-scope * {
        background-color: #1e293b !important;
      }

      :host a, :host a *,
      .chatina-theme-scope a {
        color: #93c5fd !important;
      }

      :host button, :host .btn,
      .chatina-theme-scope button,
      .chatina-theme-scope .btn {
        background-color: #334155 !important;
        color: #eaeaea !important;
      }
    `;
    (target || document.head).appendChild(style);
    return style;
  }

  function applyChatinaTheme(root) {
    const target = root.shadowRoot || root;
    const existingStyle = target.querySelector('style[data-chatina-theme]');

    if (!isDarkModeActive()) {
      if (existingStyle) existingStyle.remove();
      return;
    }

    if (!existingStyle) {
      root.classList.add('chatina-theme-scope');
      createDarkThemeStyle(target);
    }
  }

  const trackedChatinaRoots = new Set();

  function observeChatinaRoot(root) {
    if (trackedChatinaRoots.has(root)) return;
    trackedChatinaRoots.add(root);
    applyChatinaTheme(root);

    if (root.shadowRoot) {
      const shadowObserver = new MutationObserver(() => applyChatinaTheme(root));
      shadowObserver.observe(root.shadowRoot, { childList: true, subtree: true });
    }
  }

  function scanForChatina(node) {
    if (!(node instanceof Element)) return;
    if (isChatinaRoot(node)) observeChatinaRoot(node);
    node.querySelectorAll(chatinaCandidatesSelector).forEach(observeChatinaRoot);
  }

  const themeToggleObserver = new MutationObserver((mutations) => {
    let shouldReapply = false;
    mutations.forEach((mutation) => {
      if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
        shouldReapply = true;
      }
      mutation.addedNodes.forEach(scanForChatina);
    });

    if (shouldReapply) {
      trackedChatinaRoots.forEach(applyChatinaTheme);
    }
  });

  function setupChatinaThemeHook() {
    scanForChatina(document.body);
    themeToggleObserver.observe(document.body, { childList: true, subtree: true, attributes: true, attributeFilter: ['class'] });

    if (window.matchMedia) {
      const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
      mediaQuery.addEventListener('change', () => {
        trackedChatinaRoots.forEach(applyChatinaTheme);
      });
    }
  }

  loadChatinaBundle()
    .then(setupChatinaThemeHook)
    .catch((error) => console.error('No se pudo cargar Chatina:', error));
});
