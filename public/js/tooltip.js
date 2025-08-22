// Agrega tooltips de traducción a todos los textos de las lecciones

let tooltipVocabCache = null;

async function applyTooltips() {
  const lang = localStorage.getItem('lang') || (window.GamesCommon && GamesCommon.getLang()) || 'es';

  try {
    if (!tooltipVocabCache) {
      const res = await fetch('/data/vocab.json');
      tooltipVocabCache = await res.json();
    }

    const vocab = {};
    // Unir todas las lecciones en un solo objeto de búsqueda
    Object.values(tooltipVocabCache).forEach(arr => {
      if (Array.isArray(arr)) {
        arr.forEach(item => {
          const translation = item[lang] || item.en || item.es || item.term;
          vocab[item.term.toLowerCase()] = translation;
        });
      }
    });

    const selector = '.text-block p, .text-block li, .grammar p, #home-section p, .grammar li, .card p, .vocab-table li';
    const elements = document.querySelectorAll(selector);
    elements.forEach(el => {
      const tokens = el.textContent.match(/\w+|\s+|[^\s\w]+/g) || [];
      const html = tokens.map(tok => {
        const clean = tok.replace(/[^\wáéíóúüñ]/gi, '').toLowerCase();
        if (vocab[clean]) {
          const translation = vocab[clean];
          return `<span class="tooltip" aria-label="${translation}">${tok}<span class="tooltiptext">${translation}</span></span>`;
        }
        return tok;
      }).join('');

      el.innerHTML = html;
    });
  } catch (err) {
    console.error('No se pudo cargar el vocabulario:', err);
  }
}

document.addEventListener('DOMContentLoaded', applyTooltips);
document.addEventListener('langChanged', applyTooltips);
