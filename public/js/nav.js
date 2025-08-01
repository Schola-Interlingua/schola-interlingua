const cursoSlugs = [
  "basico1","basico2","phrases-quotidian","alimentos","animales",
  "adjectivos1","plurales","esser-haber","vestimentos",
  "adjectivos-possessive","colores","presente1","demonstrativos1",
  "conjunctiones","questiones","verbos2","adjectivos2",
  "prepositiones","numeros","familia","possessives2","verbos3",
  "datas-tempore","verbos4","adverbios1","verbos5","adverbios2",
  "occupationes","verbos6","negativos","adverbios3",
  "prender-casa","technologia"
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

function toTitle(str) {
  return str.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join(' ');
}

function buildCursoMenu() {
  const navLinks = document.querySelector('.nav-links');
  if (!navLinks) return;
  const li = document.createElement('li');
  li.className = 'dropdown';
  li.innerHTML = '<a href="#">Curso ▼</a><ul class="dropdown-menu"></ul>';
  const menu = li.querySelector('.dropdown-menu');
  cursoSlugs.forEach(slug => {
    const icon = iconMap[slug] || 'fas fa-book';
    const a = document.createElement('a');
    a.href = `/lessons/${slug}.html`;
    a.innerHTML = `<i class="${icon}"></i> ${toTitle(slug)}`;
    const item = document.createElement('li');
    item.appendChild(a);
    menu.appendChild(item);
  });
  navLinks.appendChild(li);
}

document.addEventListener('DOMContentLoaded', () => {
  const timer = setInterval(() => {
    if (document.querySelector('.nav-links')) {
      clearInterval(timer);
      buildCursoMenu();
    }
  }, 50);
});
