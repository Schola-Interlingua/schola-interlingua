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
  const CHATINA_ROOT_ATTR = 'data-chatina-root';
  const CHATINA_STYLE_ID = 'chatina-dark-overrides';

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

  function ensureChatinaStyle() {
    if (document.getElementById(CHATINA_STYLE_ID)) return;
    const style = document.createElement('style');
    style.id = CHATINA_STYLE_ID;
    style.textContent = `
      @media (prefers-color-scheme: dark) {
        [${CHATINA_ROOT_ATTR}="true"] { color: #eaeaea; background-color: #0f172a; }
        [${CHATINA_ROOT_ATTR}="true"] a { color: #93c5fd; }
        [${CHATINA_ROOT_ATTR}="true"] [class*="panel" i],
        [${CHATINA_ROOT_ATTR}="true"] [class*="container" i],
        [${CHATINA_ROOT_ATTR}="true"] [class*="content" i] {
          background-color: #0f172a !important;
        }
        [${CHATINA_ROOT_ATTR}="true"] [class*="bubble" i],
        [${CHATINA_ROOT_ATTR}="true"] [class*="message" i],
        [${CHATINA_ROOT_ATTR}="true"] [class*="msg" i] {
          background-color: #1e293b !important;
        }
      }

      .dark-mode [${CHATINA_ROOT_ATTR}="true"],
      .dark [${CHATINA_ROOT_ATTR}="true"] {
        color: #eaeaea;
        background-color: #0f172a;
      }

      .dark-mode [${CHATINA_ROOT_ATTR}="true"] a,
      .dark [${CHATINA_ROOT_ATTR}="true"] a {
        color: #93c5fd;
      }

      .dark-mode [${CHATINA_ROOT_ATTR}="true"] [class*="panel" i],
      .dark [${CHATINA_ROOT_ATTR}="true"] [class*="panel" i],
      .dark-mode [${CHATINA_ROOT_ATTR}="true"] [class*="container" i],
      .dark [${CHATINA_ROOT_ATTR}="true"] [class*="container" i],
      .dark-mode [${CHATINA_ROOT_ATTR}="true"] [class*="content" i],
      .dark [${CHATINA_ROOT_ATTR}="true"] [class*="content" i] {
        background-color: #0f172a !important;
      }

      .dark-mode [${CHATINA_ROOT_ATTR}="true"] [class*="bubble" i],
      .dark [${CHATINA_ROOT_ATTR}="true"] [class*="bubble" i],
      .dark-mode [${CHATINA_ROOT_ATTR}="true"] [class*="message" i],
      .dark [${CHATINA_ROOT_ATTR}="true"] [class*="message" i],
      .dark-mode [${CHATINA_ROOT_ATTR}="true"] [class*="msg" i],
      .dark [${CHATINA_ROOT_ATTR}="true"] [class*="msg" i] {
        background-color: #1e293b !important;
      }
    `;
    document.head.appendChild(style);
  }

  function parseColor(colorString) {
    if (!colorString) return null;
    const match = colorString.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)/i);
    if (!match) return null;
    const [, r, g, b, a] = match;
    return { r: Number(r), g: Number(g), b: Number(b), a: a !== undefined ? Number(a) : 1 };
  }

  function getLuminance({ r, g, b }) {
    const channel = (value) => {
      const normalized = value / 255;
      return normalized <= 0.03928
        ? normalized / 12.92
        : Math.pow((normalized + 0.055) / 1.055, 2.4);
    };
    const [lr, lg, lb] = [channel(r), channel(g), channel(b)];
    return 0.2126 * lr + 0.7152 * lg + 0.0722 * lb;
  }

  function adjustMessageColors(root) {
    const isDark = isDarkModeActive();
    const target = root.shadowRoot || root;
    const candidates = target.querySelectorAll('[class*="message" i], [class*="msg" i], [class*="bubble" i]');

    candidates.forEach((el) => {
      if (!isDark) {
        if (el.dataset.chatinaAdjusted === 'true') {
          el.style.color = '';
          delete el.dataset.chatinaAdjusted;
        }
        return;
      }

      const bgColor = parseColor(getComputedStyle(el).backgroundColor);
      if (!bgColor || bgColor.a === 0) return;

      const luminance = getLuminance(bgColor);
      const textColor = luminance > 0.7 ? '#111111' : '#eaeaea';
      el.style.color = textColor;
      el.dataset.chatinaAdjusted = 'true';
    });
  }

  const trackedChatinaRoots = new Set();
  const CHATINA_ATTRIBUTES = ['class', 'data-widget', 'id'];

  function applyChatinaTheme(root) {
    if (!(root instanceof Element)) return;
    root.setAttribute(CHATINA_ROOT_ATTR, 'true');
    ensureChatinaStyle();
    adjustMessageColors(root);
  }

  function observeChatinaRoot(root) {
    if (trackedChatinaRoots.has(root)) return;
    trackedChatinaRoots.add(root);
    applyChatinaTheme(root);

    const target = root.shadowRoot || root;
    const observer = new MutationObserver(() => adjustMessageColors(root));
    observer.observe(target, { childList: true, subtree: true, attributes: true, attributeFilter: ['style', 'class'] });
  }

  function scanForChatina(node) {
    if (!(node instanceof Element)) return;
    if (isChatinaRoot(node)) observeChatinaRoot(node);
    node.querySelectorAll(chatinaCandidatesSelector).forEach(observeChatinaRoot);
  }

  const themeToggleObserver = new MutationObserver((mutations) => {
    let shouldReapply = false;
    mutations.forEach((mutation) => {
      if (mutation.type === 'attributes' && CHATINA_ATTRIBUTES.includes(mutation.attributeName)) {
        shouldReapply = true;
      }
      mutation.addedNodes.forEach(scanForChatina);
    });

    if (shouldReapply) {
      trackedChatinaRoots.forEach((root) => applyChatinaTheme(root));
    }
  });

  function setupChatinaThemeHook() {
    ensureChatinaStyle();
    scanForChatina(document.body);
    themeToggleObserver.observe(document.body, { childList: true, subtree: true, attributes: true, attributeFilter: ['class'] });

    if (window.matchMedia) {
      const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
      mediaQuery.addEventListener('change', () => {
        trackedChatinaRoots.forEach((root) => applyChatinaTheme(root));
      });
    }
  }

  loadChatinaBundle()
    .then(setupChatinaThemeHook)
    .catch((error) => console.error('No se pudo cargar Chatina:', error));
});
