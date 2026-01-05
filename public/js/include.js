document.addEventListener("DOMContentLoaded", () => {

  const path = location.pathname;

  /* ---------------- BASE PATH ---------------- */

  const base =
    path.includes("/lection/") ||
      path.includes("/appendice/") ||
      path.includes("/lessons/") ||
      path.includes("/login/") ||
      path.includes("/games/") ||
      path.includes("/lecturas/")
      ? "../components/"
      : "components/";

  /* ---------------- METADATA ---------------- */

  const courseMeta = {
    title: "Schola Interlingua - Curso gratuite de Interlingua",
    description: "Curso gratuite de Interlingua con lectiones, vocabulario e exercitios interactive",
    image: `${location.origin}/images/logo.png`,
    url: location.href
  };

  function setMeta(selector, attrs) {
    let el = document.querySelector(selector);
    if (!el) {
      el = document.createElement("meta");
      document.head.appendChild(el);
    }
    Object.entries(attrs).forEach(([k, v]) => el.setAttribute(k, v));
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

  /* ---------------- INCLUDE ---------------- */

  function include(selector, file, cb) {
    fetch(base + file)
      .then(res => res.text())
      .then(html => {
        const targets = document.querySelectorAll(selector);
        if (!targets.length) {
          console.warn(`⚠️ No se encontraron elementos para ${selector}`);
          return;
        }
        targets.forEach(el => el.innerHTML = html);
        if (cb) cb();
      })
      .catch(err => console.error(`❌ Error cargando ${file}`, err));
  }

  /* ---------------- LANG ---------------- */

  function initLang() {
    const current = localStorage.getItem("lang") || "es";
    document.querySelectorAll(".lang-option").forEach(link => {
      if (link.dataset.lang === current) link.classList.add("active");
      link.addEventListener("click", e => {
        e.preventDefault();
        localStorage.setItem("lang", link.dataset.lang);
        location.reload();
      });
    });
  }

  /* ---------------- INIT ---------------- */

  ensureMetadata();

  include("nav, #navbar-placeholder", "navbar.html", () => {
    initLang();
    document.dispatchEvent(new Event("navbar-ready"));
  });

  include("footer, #footer-placeholder", "footer.html");

  /* ---------------- ANALYTICS ---------------- */

  if (!window.va) {
    window.va = function () {
      (window.vaq = window.vaq || []).push(arguments);
    };
    const s = document.createElement("script");
    s.src = "/_vercel/insights/script.js";
    s.defer = true;
    document.head.appendChild(s);
  }

});
