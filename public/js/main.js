async function loadLessons(){
  const data = await fetch('/public/data/vocab.json').then(r=>r.json());
  const container = document.getElementById('home-lessons');

  const iconMap = {
    "basico1":"fas fa-lightbulb",
    "basico2":"fas fa-lightbulb",
    "phrases-quotidian":"fas fa-comment-dots",
    "alimentos":"fas fa-apple-alt",
    "animales":"fas fa-dog",
    "adjectivos1":"fas fa-adjust",
    "plurales":"fas fa-clone",
    "esser-haber":"fas fa-user-check",
    "vestimentos":"fas fa-tshirt",
    "adjectivos-possessive":"fas fa-hand-holding-heart",
    "colores":"fas fa-palette",
    "presente1":"fas fa-clock",
    "demonstrativos1":"fas fa-arrows-alt-h",
    "conjunctiones":"fas fa-link",
    "questiones":"fas fa-question",
    "verbos2":"fas fa-running",
    "adjectivos2":"fas fa-star-half-alt",
    "prepositiones":"fas fa-map-signs",
    "numeros":"fas fa-sort-numeric-up",
    "familia":"fas fa-users",
    "possessives2":"fas fa-handshake",
    "verbos3":"fas fa-swimmer",
    "datas-tempore":"fas fa-calendar-alt",
    "verbos4":"fas fa-plane",
    "adverbios1":"fas fa-angle-double-right",
    "verbos5":"fas fa-music",
    "adverbios2":"fas fa-bolt",
    "occupationes":"fas fa-briefcase",
    "verbos6":"fas fa-rocket",
    "negativos":"fas fa-minus-circle",
    "adverbios3":"fas fa-forward",
    "prender-casa":"fas fa-home",
    "technologia":"fas fa-microchip"
  };

  Object.keys(data).forEach(slug=>{
    const a=document.createElement('a');
    a.href=`/lesson.html?slug=${slug}`;
    a.className='lesson-circle';
    const iconClass=iconMap[slug]||'fas fa-book';
    a.innerHTML=`<i class="${iconClass}"></i><span>${displayName(slug)}</span>`;
    container.appendChild(a);
  });
}

function displayName(slug){
  return slug.replace(/-/g,' ').replace(/\b\w/g,c=>c.toUpperCase());
}

document.addEventListener('DOMContentLoaded',loadLessons);
