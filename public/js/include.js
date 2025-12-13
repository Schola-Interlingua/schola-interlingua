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

  loadChatinaBundle().catch((error) => console.error('No habeva possibile cargar Chatina:', error));
});
