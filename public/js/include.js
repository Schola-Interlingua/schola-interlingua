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

  function initChatina() {
    if (document.querySelector('.chatina-launcher')) return;

    loadChatinaBundle().catch((error) => console.error('No se pudo cargar Chatina:', error));

    const wrapper = document.createElement('div');
    wrapper.className = 'chatina-widget';
    wrapper.innerHTML = `
      <div class="chatina-launcher-wrapper">
        <button class="btn btn-primary chatina-launcher" type="button" aria-label="Abrir chat de IA Chatina">
          <i class="fa-solid fa-comments"></i>
          <span>Chatina</span>
        </button>
      </div>
      <div class="chatina-overlay" role="dialog" aria-modal="true" aria-label="Chat con Chatina" aria-hidden="true">
        <div class="chatina-modal-backdrop" data-action="close"></div>
        <div class="chatina-modal">
          <div class="chatina-modal__header">
            <div class="chatina-modal__title">
              <i class="fa-solid fa-bolt"></i>
              <span>Chatina</span>
            </div>
            <button class="chatina-close" type="button" aria-label="Cerrar chat">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="chatina-modal__body">
            <iframe src="https://chatina.interlingua.education/" title="Chat con Chatina" allow="microphone"></iframe>
          </div>
        </div>
      </div>
    `;

    document.body.appendChild(wrapper);

    const launcher = wrapper.querySelector('.chatina-launcher');
    const overlay = wrapper.querySelector('.chatina-overlay');
    const closeBtn = wrapper.querySelector('.chatina-close');
    const backdrop = wrapper.querySelector('.chatina-modal-backdrop');

    const openChat = () => {
      loadChatinaBundle().catch((error) => console.error('No se pudo cargar Chatina:', error));
      overlay.classList.add('is-open');
      overlay.setAttribute('aria-hidden', 'false');
      document.body.classList.add('chatina-open');
      closeBtn.focus({ preventScroll: true });
    };

    const closeChat = () => {
      overlay.classList.remove('is-open');
      overlay.setAttribute('aria-hidden', 'true');
      document.body.classList.remove('chatina-open');
      launcher.focus({ preventScroll: true });
    };

    launcher.addEventListener('click', openChat);
    closeBtn.addEventListener('click', closeChat);
    backdrop.addEventListener('click', closeChat);

    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && overlay.classList.contains('is-open')) {
        closeChat();
      }
    });
  }

  initChatina();
});
