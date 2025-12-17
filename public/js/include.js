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

  const courseMeta = {
    title: "Schola Interlingua - Curso gratuite de Interlingua",
    description: "Curso gratuite de Interlingua con lectiones, vocabulario e exercitios interactive",
    image: `${location.origin}/images/logo.png`,
    url: location.href
  };

  function setMeta(tagSelector, attributes) {
    const existing = document.querySelector(tagSelector);
    const element = existing || document.createElement("meta");
    Object.entries(attributes).forEach(([key, value]) => element.setAttribute(key, value));
    if (!existing) document.head.appendChild(element);
  }

  function ensureMetadata() {
    setMeta('meta[name="description"]', { name: "description", content: courseMeta.description });
    setMeta('meta[property="og:title"]', { property: "og:title", content: courseMeta.title });
    setMeta('meta[property="og:description"]', { property: "og:description", content: courseMeta.description });
    setMeta('meta[property="og:image"]', { property: "og:image", content: courseMeta.image });
    setMeta('meta[property="og:url"]', { property: "og:url", content: courseMeta.url });
    setMeta('meta[name="twitter:card"]', { name: "twitter:card", content: "summary_large_image" });
    setMeta('meta[name="twitter:title"]', { name: "twitter:title", content: courseMeta.title });
    setMeta('meta[name="twitter:description"]', { name: "twitter:description", content: courseMeta.description });
    setMeta('meta[name="twitter:image"]', { name: "twitter:image", content: courseMeta.image });
  }

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
          console.warn(`Nulle elementos esseva trovate con le selector: ${selector}`);
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

  ensureMetadata();

  // Cargar script de progreso en todas las páginas
  const progressScript = document.createElement('script');
  progressScript.src = "/js/progress.js";
  document.body.appendChild(progressScript);

  // Cargar jQuery solo si no existe
  if (!window.jQuery) {
    const jqueryScript = document.createElement('script');
    jqueryScript.src = "https://code.jquery.com/jquery-3.7.1.min.js";
    document.body.appendChild(jqueryScript);
  }

  // Configuración para activar Chatina manualmente
  const chatinaSrc = "https://ia.softwcloud.com/app/IA/chat_js/chat.js?type=mini&key=lnyghdrM5s7ixKFYr5q/u5FeWklsm25en5vAt5+fqknFt6Cnx1FYVlU=";
  const chatinaState = {
    loading: false,
    loaded: false,
    launcher: null
  };

  function loadChatinaScript(launcher) {
    if (chatinaState.loading || chatinaState.loaded || document.querySelector(`script[src="${chatinaSrc}"]`)) {
      if (chatinaState.loaded && launcher) launcher.remove();
      return;
    }

    const chatinaScript = document.createElement('script');
    chatinaScript.src = chatinaSrc;
    chatinaScript.async = true;
    chatinaScript.defer = true;

    chatinaState.loading = true;
    if (launcher) {
      launcher.classList.add("chatina-launcher--loading");
      launcher.querySelector('.chatina-launcher__bubble-label').textContent = "...";
      launcher.querySelector('button').setAttribute('aria-busy', 'true');
      launcher.querySelector('button').disabled = true;
    }

    chatinaScript.addEventListener('load', () => {
      chatinaState.loading = false;
      chatinaState.loaded = true;
      if (launcher) launcher.remove();
    });

    chatinaScript.addEventListener('error', () => {
      chatinaState.loading = false;
      chatinaState.loaded = false;
      if (launcher) {
        launcher.classList.remove("chatina-launcher--loading");
        launcher.querySelector('.chatina-launcher__bubble-label').textContent = "!";
        launcher.querySelector('button').removeAttribute('aria-busy');
        launcher.querySelector('button').disabled = false;
      }
    });

    document.body.appendChild(chatinaScript);
  }

  function createChatinaLauncher() {
    if (document.querySelector(`script[src="${chatinaSrc}"]`)) {
      chatinaState.loaded = true;
      return;
    }

    const launcher = document.createElement('div');
    launcher.className = "chatina-launcher";
    const noticeId = "chatina-privacy-notice";
    launcher.innerHTML = `
      <button type="button" class="chatina-launcher__bubble" aria-label="Abrir Chatina" aria-describedby="${noticeId}">
        <span class="chatina-launcher__bubble-label" aria-hidden="true">C</span>
      </button>
      <span class="chatina-launcher__notice" id="${noticeId}">Widget de terceros; puede usar cookies.</span>
    `;

    const button = launcher.querySelector('button');
    button.addEventListener('click', () => loadChatinaScript(launcher));

    chatinaState.launcher = launcher;
    document.body.appendChild(launcher);
  }

  include("#navbar-placeholder, nav", "navbar.html", () => {
    initLang();
    createChatinaLauncher();
  });

  include("#footer-placeholder, footer", "footer.html");
});
