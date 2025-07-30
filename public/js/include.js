document.addEventListener("DOMContentLoaded", function () {
  const path = location.pathname;

  // Determinar si estamos en una subcarpeta
  const base = path.includes("/lection/") || path.includes("/appendice/")
    ? "../components/"
    : "./components/";

  function include(selector, file) {
    fetch(base + file)
      .then(res => res.text())
      .then(html => {
        document.querySelector(selector).innerHTML = html;
      });
  }

  include("nav", "navbar.html");
  include("footer", "footer.html");
});
