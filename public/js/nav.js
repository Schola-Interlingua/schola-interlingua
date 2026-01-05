import { supabase } from "./supabase.js";

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

let authBtn = null;

/* ---------- FUNCIONES DE UI ---------- */

function buildCursoLink() {
  // Check if the link already exists to prevent duplicates
  if (document.querySelector('.nav-links #curso-link-li')) return;

  const navLinks = document.querySelector('.nav-links');
  if (!navLinks) return;

  const li = document.createElement('li');
  li.id = 'curso-link-li'; // Add an ID to the <li> for easy removal

  const a = document.createElement('a');
  a.href = '/curso.html';
  a.textContent = 'Curso';
  li.appendChild(a);

  // Insert "Curso" as the first link
  const firstLink = navLinks.firstElementChild;
  if (firstLink) {
    navLinks.insertBefore(li, firstLink);
  } else {
    navLinks.appendChild(li);
  }
}

function removeCursoLink() {
  const cursoLi = document.getElementById('curso-link-li');
  if (cursoLi) cursoLi.remove();
}

function setLoggedOutUI() {
  if (!authBtn) return;
  const li = authBtn.parentElement;
  li.classList.remove("dropdown");
  authBtn.innerHTML = 'Login';
  authBtn.title = "";
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
  authBtn.innerHTML = '<i class="fas fa-user"></i> ▼';
  authBtn.title = user.email;
  authBtn.href = "#";
  authBtn.onclick = null;
  let menu = li.querySelector('.dropdown-menu');
  if (!menu) {
    menu = document.createElement('ul');
    menu.className = 'dropdown-menu';
    li.appendChild(menu);
  }
  menu.innerHTML = '<li><a href="#" id="logout-link">Salir</a></li>';

  const logoutLink = document.getElementById('logout-link');
  if (logoutLink) {
    logoutLink.addEventListener('click', async (e) => {
      e.preventDefault();
      if (confirm("¿Cerrar sesión?")) {
        await supabase.auth.signOut();
      }
    });
  }
}


/* ---------- LÓGICA DE AUTH ---------- */

window.cursoSlugs = cursoSlugs;
window.iconMap = iconMap;

function toTitle(str) {
  return str.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join(' ');
}

function initThemeToggle() {
  const btn = document.getElementById('theme-toggle');
  if (!btn) return;
  const icon = btn.querySelector('i');

  function setTheme(mode) {
    if (mode === 'dark') {
      document.body.classList.add('dark-mode');
      icon.classList.remove('fa-moon');
      icon.classList.add('fa-sun');
      btn.setAttribute('aria-label', 'Cambiar a modo claro');
    } else {
      document.body.classList.remove('dark-mode');
      icon.classList.remove('fa-sun');
      icon.classList.add('fa-moon');
      btn.setAttribute('aria-label', 'Cambiar a modo oscuro');
    }
  }

  const saved = localStorage.getItem('theme') || 'light';
  setTheme(saved);

  btn.addEventListener('click', () => {
    const newMode = document.body.classList.contains('dark-mode') ? 'light' : 'dark';
    localStorage.setItem('theme', newMode);
    setTheme(newMode);
  });
}

function initDropdownAccessibility() {
  document.querySelectorAll('.dropdown > a').forEach(trigger => {
    trigger.addEventListener('click', e => e.preventDefault());
    trigger.addEventListener('keydown', e => {
      if (e.key === 'Escape') {
        trigger.blur();
      }
    });
  });
  document.querySelectorAll('.dropdown-menu a').forEach(item => {
    item.addEventListener('keydown', e => {
      if (e.key === 'Escape') {
        const parent = item.closest('.dropdown');
        const link = parent && parent.querySelector('a');
        if (link) link.focus();
      }
    });
  });
}


document.addEventListener('navbar-loaded', () => {
  authBtn = document.getElementById("auth-btn");

  // Auth state listener is the single source of truth
  supabase.auth.onAuthStateChange((_event, session) => {
    if (session?.user) {
      setLoggedInUI(session.user);
    } else {
      setLoggedOutUI();
    }
  });

  initThemeToggle();
  initDropdownAccessibility();
});