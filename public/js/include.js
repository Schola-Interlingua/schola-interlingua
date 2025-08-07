document.addEventListener("DOMContentLoaded", function () {
  const path = location.pathname;

  // Determinar si estamos en una subcarpeta
  const base = path.includes("/lection/") ||
               path.includes("/appendice/") ||
               path.includes("/lessons/") ||
               path.includes("/games/")
    ? "../components/"
    : "components/";

  function include(selector, file, cb) {
    fetch(base + file)
      .then(res => res.text())
      .then(html => {
        document.querySelector(selector).innerHTML = html;
        if (cb) cb();
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

  include("nav", "navbar.html", initLang);
  include("footer", "footer.html");

  // Cargar script de progreso en todas las páginas
  const progressScript = document.createElement('script');
  progressScript.src = "/js/progress.js";
  document.body.appendChild(progressScript);
});
