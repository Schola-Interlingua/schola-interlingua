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

  // Cargar el widget de Chatina una sola vez y añadir aviso sobre terceros
  const chatinaSrc = "https://ia.softwcloud.com/app/IA/chat_js/chat.js?type=mini&key=lnyghdrM5s7ixKFYr5q/u5FeWklsm25en5vAt5+fqknFt6Cnx1FYVlU=";
  const chatinaNoticeText = "Widget de terceros; puede usar cookies.";
  let chatinaNotice = null;
  let chatinaButton = null;
  let chatinaLoaded = false;
  let chatinaLoadingPromise = null;

  const chatinaSelectors = [
    'button[id*="chatina" i]',
    'button[class*="chatina" i]',
    'button[aria-label*="chat" i]',
    'button[aria-label*="soporte" i]',
    'button[aria-label*="support" i]'
  ];

  function findChatinaButton() {
    for (const selector of chatinaSelectors) {
      const found = document.querySelector(selector);
      if (found) return found;
    }

    const fixedButtons = Array.from(document.querySelectorAll('button')).filter(btn => {
      const styles = window.getComputedStyle(btn);
      return styles.position === 'fixed';
    });

    return fixedButtons.find(btn => {
      const rect = btn.getBoundingClientRect();
      return rect.right >= window.innerWidth - 200 && rect.bottom >= window.innerHeight - 200;
    }) || null;
  }

  function createChatinaNotice() {
    if (chatinaNotice) return chatinaNotice;

    chatinaNotice = document.createElement('span');
    chatinaNotice.className = 'chatina-privacy-notice';
    chatinaNotice.textContent = chatinaNoticeText;
    document.body.appendChild(chatinaNotice);
    return chatinaNotice;
  }

  function positionNotice(targetButton) {
    if (!chatinaNotice || !targetButton) return;

    const rect = targetButton.getBoundingClientRect();
    const noticeRect = chatinaNotice.getBoundingClientRect();
    const top = rect.top + window.scrollY - noticeRect.height - 10;
    const left = rect.left + window.scrollX + rect.width / 2 - noticeRect.width / 2;

    chatinaNotice.style.top = `${Math.max(10, top)}px`;
    chatinaNotice.style.left = `${Math.max(10, left)}px`;
  }

  function attachNoticeToButton(targetButton) {
    if (!targetButton || chatinaButton === targetButton) return;

    chatinaButton = targetButton;
    createChatinaNotice();

    if (!targetButton.dataset.chatinaOptInBound) {
      targetButton.dataset.chatinaOptInBound = "true";

      targetButton.addEventListener('click', (event) => {
        if (chatinaLoaded) return;

        event.preventDefault();
        event.stopPropagation();

        targetButton.setAttribute('aria-busy', 'true');

        loadChatina()
          .then(() => {
            targetButton.removeAttribute('aria-busy');
            targetButton.dispatchEvent(new Event('click', { bubbles: true }));
          })
          .catch(() => {
            targetButton.removeAttribute('aria-busy');
          });
      });
    }

    const showNotice = () => {
      positionNotice(targetButton);
      chatinaNotice.classList.add('chatina-privacy-notice--visible');
    };

    const hideNotice = () => {
      chatinaNotice.classList.remove('chatina-privacy-notice--visible');
    };

    ['mouseenter', 'focus'].forEach(evt => targetButton.addEventListener(evt, showNotice));
    ['mouseleave', 'blur'].forEach(evt => targetButton.addEventListener(evt, hideNotice));
    window.addEventListener('resize', () => positionNotice(targetButton));
    window.addEventListener('scroll', () => positionNotice(targetButton), { passive: true });

    positionNotice(targetButton);
  }

  function waitForChatinaButton() {
    const existing = findChatinaButton();
    if (existing) {
      attachNoticeToButton(existing);
      return;
    }

    const observer = new MutationObserver(() => {
      const found = findChatinaButton();
      if (found) {
        attachNoticeToButton(found);
        observer.disconnect();
      }
    });

    observer.observe(document.body, { childList: true, subtree: true });
  }

  function loadChatina() {
    if (chatinaLoaded) return Promise.resolve();

    if (document.querySelector(`script[src="${chatinaSrc}"]`)) {
      chatinaLoaded = true;
      return Promise.resolve();
    }

    if (chatinaLoadingPromise) return chatinaLoadingPromise;

    chatinaLoadingPromise = new Promise((resolve, reject) => {
      const chatinaScript = document.createElement('script');
      chatinaScript.src = chatinaSrc;
      chatinaScript.async = true;
      chatinaScript.defer = true;
      chatinaScript.addEventListener('load', () => {
        chatinaLoaded = true;
        chatinaLoadingPromise = null;
        waitForChatinaButton();
        resolve();
      });
      chatinaScript.addEventListener('error', () => {
        chatinaLoadingPromise = null;
        reject();
      });
      document.body.appendChild(chatinaScript);
      waitForChatinaButton();
    });

    return chatinaLoadingPromise;
  }

  include("#navbar-placeholder, nav", "navbar.html", () => {
    initLang();
  });

  include("#footer-placeholder, footer", "footer.html");

  waitForChatinaButton();
});
