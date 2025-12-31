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

/* ---------- FUNCIONES DE UI (UNIFICADAS) ---------- */

function setLoggedOutUI() {
  // Buscamos el botón por cualquiera de sus IDs posibles
  const authBtn = document.getElementById("auth-btn") || document.getElementById("logout-btn");
  if (!authBtn) return;

  const li = authBtn.parentElement;
  li.classList.remove("dropdown"); // Quitamos la flechita si existe

  authBtn.innerHTML = 'Login';
  authBtn.id = "auth-btn";
  authBtn.href = "/login/login.html";

  // Borramos el menú desplegable si existía
  const menu = li.querySelector('.dropdown-menu');
  if (menu) menu.remove();
}

function setLoggedInUI(user) {
  const authBtn = document.getElementById("auth-btn") || document.getElementById("logout-btn");
  if (!authBtn) return;

  const li = authBtn.parentElement;
  li.classList.add("dropdown"); // Agregamos clase para que se vea el menú

  authBtn.id = "logout-btn";
  // Mostramos el icono de usuario y un pedacito del email
  authBtn.innerHTML = `<i class="fas fa-user"></i> ${user.email.split('@')[0]} ▼`;
  authBtn.href = "#";

  // Creamos el menú desplegable para el botón "Surtir" (Salir)
  let menu = li.querySelector('.dropdown-menu');
  if (!menu) {
    menu = document.createElement('ul');
    menu.className = 'dropdown-menu';
    li.appendChild(menu);
  }

  menu.innerHTML = '<li><a href="#" id="logout-link"><i class="fas fa-sign-out-alt"></i> Surtir (Salir)</a></li>';

  // EVENTO DE LOGOUT (Esto es lo que te fallaba)
  const logoutLink = document.getElementById('logout-link');
  if (logoutLink) {
    logoutLink.onclick = async (e) => {
      e.preventDefault();
      const { error } = await supabase.auth.signOut();
      if (error) {
        console.error("Error al salir:", error.message);
      } else {
        window.location.href = "/index.html"; // Redirigir al inicio al salir
      }
    };
  }
}

/* ---------- LÓGICA DE INICIALIZACIÓN ---------- */

async function checkAuth() {
  const { data } = await supabase.auth.getSession();
  if (data.session?.user) {
    setLoggedInUI(data.session.user);
  } else {
    setLoggedOutUI();
  }
}

// Escuchar cambios de sesión en tiempo real
supabase.auth.onAuthStateChange((event, session) => {
  if (session?.user) {
    setLoggedInUI(session.user);
  } else {
    setLoggedOutUI();
  }
});

// ESPERAR A QUE EL NAVBAR CARGUE PARA ACTIVAR TODO
document.addEventListener('navbar-loaded', () => {
  checkAuth();
  initThemeToggle();
  initDropdownAccessibility();
});


window.cursoSlugs = cursoSlugs;
window.iconMap = iconMap;

function toTitle(str) {
  return str.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join(' ');
}

function buildCursoLink() {
  if (location.pathname === '/curso.html') return;
  const navLinks = document.querySelector('.nav-links');
  if (!navLinks) return;
  const li = document.createElement('li');
  const a = document.createElement('a');
  a.href = '/curso.html';
  a.textContent = 'Curso';
  li.appendChild(a);
  const first = navLinks.firstElementChild;
  if (first) navLinks.insertBefore(li, first);
  else navLinks.appendChild(li);
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


document.addEventListener('DOMContentLoaded', () => {
  const timer = setInterval(() => {
    authBtn = document.getElementById("auth-btn");

    if (document.querySelector('.nav-links') && authBtn) {
      clearInterval(timer);

      buildCursoLink();
      initThemeToggle();
      initDropdownAccessibility();

      checkAuth();
    }
  }, 50);
});