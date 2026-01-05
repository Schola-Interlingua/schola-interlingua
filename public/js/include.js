document.addEventListener("DOMContentLoaded", () => {

  const path = location.pathname;
  const base =
    path.includes("/lection/") ||
      path.includes("/appendice/") ||
      path.includes("/lessons/") ||
      path.includes("/login/") ||
      path.includes("/games/") ||
      path.includes("/lecturas/")
      ? "/components/"
      : "components/";

  function include(selector, file, cb) {
    fetch(base + file)
      .then(r => r.text())
      .then(html => {
        document.querySelectorAll(selector).forEach(el => {
          el.innerHTML = html;
        });
        cb && cb();
      })
      .catch(err => console.error(`Error cargando ${file}`, err));
  }

  include("nav, #navbar-placeholder", "navbar.html", () => {
    document.dispatchEvent(new Event("navbar-ready"));
  });

  include("footer, #footer-placeholder", "footer.html");

});
