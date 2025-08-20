// Agrega tooltips de traducción a todos los textos de las lecciones

let cachedVocab = null;
let currentLang = null;

async function loadVocab() {
  if (cachedVocab) return cachedVocab;
  if (window.GamesCommon && typeof window.GamesCommon.loadVocab === 'function') {
    cachedVocab = await window.GamesCommon.loadVocab();
  } else {
    const res = await fetch('/data/vocab.json');
    cachedVocab = await res.json();
  }
  return cachedVocab;
}

function buildVocabMap(data, lang) {
  const map = {};
  Object.values(data).forEach(arr => {
    if (Array.isArray(arr)) {
      arr.forEach(item => {
        const translation = item[lang] || item.en || item.es;
        map[item.term.toLowerCase()] = translation;
      });
    }
  });
  return map;
}

function walkAndTranslate(node, vocab) {
  if (node.nodeType === Node.TEXT_NODE) {
    const tokens = node.textContent.match(/\w+|\s+|[^\s\w]+/g) || [];
    const frag = document.createDocumentFragment();
    tokens.forEach(tok => {
      const clean = tok.replace(/[^\wáéíóúüñ]/gi, '').toLowerCase();
      const translation = vocab[clean];
      if (translation) {
        const span = document.createElement('span');
        span.className = 'tooltip';
        span.setAttribute('aria-label', translation);
        span.textContent = tok;
        const tooltipText = document.createElement('span');
        tooltipText.className = 'tooltiptext';
        tooltipText.textContent = translation;
        span.appendChild(tooltipText);
        frag.appendChild(span);
      } else {
        frag.appendChild(document.createTextNode(tok));
      }
    });
    node.replaceWith(frag);
  } else if (node.nodeType === Node.ELEMENT_NODE && !node.classList.contains('tooltip')) {
    Array.from(node.childNodes).forEach(child => walkAndTranslate(child, vocab));
  }
}

async function applyTooltips(lang) {
  const data = await loadVocab();
  const vocab = buildVocabMap(data, lang);
  const selector = '.text-block p, .text-block li, .grammar p, #home-section p, .grammar li, .card p, .vocab-table li';
  document.querySelectorAll(selector).forEach(el => {
    // Limpiar tooltips existentes para re-aplicar en cambios de idioma
    el.querySelectorAll('.tooltip').forEach(span => {
      span.replaceWith(document.createTextNode(span.textContent));
    });
    walkAndTranslate(el, vocab);
  });
}

function initTooltips() {
  currentLang = (window.GamesCommon && typeof window.GamesCommon.getLang === 'function')
    ? window.GamesCommon.getLang()
    : (localStorage.getItem('lang') || 'es');
  applyTooltips(currentLang);
}

document.addEventListener('DOMContentLoaded', initTooltips);
document.addEventListener('langChanged', e => {
  const newLang = e.detail && e.detail.newLang;
  if (newLang && newLang !== currentLang) {
    currentLang = newLang;
    applyTooltips(newLang);
  }
});

