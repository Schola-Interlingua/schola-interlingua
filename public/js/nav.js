import { supabase } from "./supabase.js";

/* ---------- ESPERA ROBUSTA DEL NAVBAR ---------- */
function waitForNavbar(callback) {
  const timer = setInterval(() => {
    const navLinks = document.querySelector('.nav-links');
    const auth = document.getElementById('auth-btn');

    if (navLinks && auth) {
      clearInterval(timer);
      callback();
    }
  }, 50);
}

/* ---------- DATOS DEL CURSO ---------- */

const cursoSlugs = [
  "basico1", "basico2", "phrases-quotidian", "alimentos", "animales",
  "adjectivos1", "plurales", "esser-haber", "vestimentos",
  "adjectivos-possessive", "colores", "presente1", "demonstrativos1",
  "conjunctiones", "questiones", "verbos2", "adjectivos2",
  "prepositiones", "numeros", "familia", "possessives2", "verbos3",
  "datas-tempore", "verbos4", "adverbios1", "verbos5", "adverbios2",
  "occupationes", "verbos6", "negativos", "adverbios3",
  "prender-casa", "technologia"
];

const iconMap = {
  basico1: 'fas fa-lightbulb',
  basico2: 'fas fa-lightbulb',
  'phrases-quotidian': 'fas fa-comment-dots',
  alimentos: 'fas fa-apple-alt',
  animales: 'fas fa-dog',
  adjectivos1: 'fas fa-font',
  plurales: 'fas fa-clone',
  'esser-haber': 'fas fa-check-double',
  vestimentos: 'fas fa-tshirt',
  'adjectivos-possessive': 'fas fa-hand-holding-heart',
  colores: 'fas fa-palette',
  presente1: 'fas fa-clock',
  demonstrativos1: 'fas fa-hand-point-up',
  conjunctiones: 'fas fa-link',
  questiones: 'fas fa-question-circle',
  verbos2: 'fas fa-running',
  adjectivos2: 'fas fa-font',
  prepositiones: 'fas fa-map-signs',
  numeros: 'fas fa-sort-numeric-up',
  familia: 'fas fa-users',
  possessives2: 'fas fa-hand-holding-heart',
  verbos3: 'fas fa-running',
  'datas-tempore': 'fas fa-calendar-alt',
  verbos4: 'fas fa-running',
  adverbios1: 'fas fa-rocket',
  verbos5: 'fas fa-running',
  adverbios2: 'fas fa-rocket',
  occupationes: 'fas fa-briefcase',
  verbos6: 'fas fa-running',
  negativos: 'fas fa-ban',
  adverbios3: 'fas fa-rocket',
  'prender-casa': 'fas fa-home',
  technologia: 'fas fa-microchip'
};

window.cursoSlugs = cursoSlugs;
window.iconMap = iconMap;

let authBtn = null;

/* ---------- UI AUTH ---------- */

function buildCursoLink() {
  if (document.querySelector('#curso-link-li')) return;

  const navLinks = document.querySelector('.nav-links');
  if (!navLinks) return;

  const li = document.createElement('li');
  li.id = 'curso-link-li';

  const a = document.createElement('a');
  a.href = '/curso.html';
  a.textContent = 'Curso';

  li.appendChild(a);
  navLinks.insertBefore(li, navLinks.firstElementChild);
}

function removeCursoLink() {
  const li = document.getElementById('curso-link-li');
  if (li) li.remove();
}

function setLoggedOutUI() {
  if (!authBtn) return;

  const li = authBtn.parentElement;
  li.classList.remove("dropdown", "open");

  authBtn.textContent = "Login";
  authBtn.href = "/login/login.html";
  authBtn.onclick = null;

  const menu = li.querySelector('.dropdown-menu');
  if (menu) menu.remove();

  removeCursoLink();
}

function setLoggedInUI(user) {
  if (!authBtn) return;

  buildCursoLink();

  const li = authBtn.parentElement;
  li.classList.add("dropdown");

  authBtn.innerHTML = `
    <i class="fas fa-user"></i>
    <span class="user-email">${user.email}</span>
    <i class="fas fa-caret-down"></i>
  `;

  authBtn.removeAttribute("href");
  authBtn.setAttribute("role", "button");
  authBtn.setAttribute("aria-haspopup", "true");
  authBtn.setAttribute("aria-expanded", "false");

  let menu = li.querySelector('.dropdown-menu');
  if (!menu) {
    menu = document.createElement('ul');
    menu.className = 'dropdown-menu';
    li.appendChild(menu);
  }

  menu.innerHTML = `<li><a href="#" id="logout-link">Salir</a></li>`;

  authBtn.onclick = (e) => {
    e.stopPropagation();
    const expanded = authBtn.getAttribute("aria-expanded") === "true";
    authBtn.setAttribute("aria-expanded", String(!expanded));
    li.classList.toggle("open", !expanded);
  };

  document.addEventListener("click", () => {
    authBtn.setAttribute("aria-expanded", "false");
    li.classList.remove("open");
  });

  document.getElementById('logout-link').onclick = async (e) => {
    e.preventDefault();
    await supabase.auth.signOut();
  };
}

/* ---------- EXTRAS ---------- */

function initThemeToggle() {
  const btn = document.getElementById('theme-toggle');
  if (!btn) return;

  const icon = btn.querySelector('i');

  function setTheme(mode) {
    document.body.classList.toggle('dark-mode', mode === 'dark');
    icon.className = mode === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
  }

  const saved = localStorage.getItem('theme') || 'light';
  setTheme(saved);

  btn.addEventListener('click', () => {
    const next = document.body.classList.contains('dark-mode') ? 'light' : 'dark';
    localStorage.setItem('theme', next);
    setTheme(next);
  });
}

function initDropdownAccessibility() {
  document.querySelectorAll('.dropdown > a').forEach(trigger => {
    trigger.addEventListener('click', e => e.preventDefault());
  });
}

/* ---------- INIT FINAL ---------- */

waitForNavbar(() => {
  authBtn = document.getElementById("auth-btn");

  supabase.auth.getSession().then(({ data }) => {
    data?.session?.user
      ? setLoggedInUI(data.session.user)
      : setLoggedOutUI();
  });

  supabase.auth.onAuthStateChange((_e, session) => {
    session?.user
      ? setLoggedInUI(session.user)
      : setLoggedOutUI();
  });

  initThemeToggle();
  initDropdownAccessibility();
});
