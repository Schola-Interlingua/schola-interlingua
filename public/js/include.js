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
  const CHATINA_STYLE_ID = 'chatina-text-color';

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

  // Scoped text-only override so the Chatina widget stays legible without altering its layout.
  function ensureHeadStyle() {
    if (document.getElementById(CHATINA_STYLE_ID)) return;
    const style = document.createElement('style');
    style.id = CHATINA_STYLE_ID;
    style.textContent = `
      [${CHATINA_ROOT_ATTR}="true"],
      [${CHATINA_ROOT_ATTR}="true"] *,
      [${CHATINA_ROOT_ATTR}="true"] a {
        color: #111 !important;
      }
    `;
    document.head.appendChild(style);
  }

  function ensureShadowStyle(shadowRoot) {
    if (!shadowRoot || shadowRoot.getElementById(CHATINA_STYLE_ID)) return;
    const style = document.createElement('style');
    style.id = CHATINA_STYLE_ID;
    style.textContent = `
      :host, :host * {
        color: #111 !important;
      }
    `;
    shadowRoot.appendChild(style);
  }

  const trackedChatinaRoots = new Set();

  function applyChatinaTextFix(root) {
    if (!(root instanceof Element) || trackedChatinaRoots.has(root)) return;
    trackedChatinaRoots.add(root);
    root.setAttribute(CHATINA_ROOT_ATTR, 'true');
    ensureHeadStyle();
    ensureShadowStyle(root.shadowRoot);
  }

  function scanForChatina(node) {
    if (!(node instanceof Element)) return;
    if (isChatinaRoot(node)) applyChatinaTextFix(node);
    node.querySelectorAll(chatinaCandidatesSelector).forEach(applyChatinaTextFix);
  }

  function setupChatinaTextHook() {
    ensureHeadStyle();
    scanForChatina(document.body);

    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach(scanForChatina);
      });
    });

    observer.observe(document.body, { childList: true, subtree: true });
  }

  loadChatinaBundle()
    .then(setupChatinaTextHook)
    .catch((error) => console.error('No se pudo cargar Chatina:', error));
});
