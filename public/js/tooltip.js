// Agrega tooltips de traducción a textos de la web y actualiza al cambiar el idioma

let cachedVocab = null;

function applyTooltips(lang) {
  const selector = '.text-block p, .text-block li, .grammar p, #home-section p, .grammar li, .card p, .vocab-table li';

  const loadVocab = cachedVocab
    ? Promise.resolve(cachedVocab)
    : fetch('/data/vocab.json').then(res => res.json()).then(data => {
        cachedVocab = data;
        return data;
      });

  loadVocab
    .then(data => {
      const vocab = {};
      // Unir todas las lecciones en un solo objeto de búsqueda
      Object.values(data).forEach(arr => {
        if (Array.isArray(arr)) {
          arr.forEach(item => {
            const translation = item[lang] || item.en || item.es || item.term;
            vocab[item.term.toLowerCase()] = translation;
          });
        }
      });

      document.querySelectorAll(selector).forEach(el => {
        const tokens = el.textContent.match(/\w+|\s+|[^\s\w]+/g) || [];
        const html = tokens
          .map(tok => {
            const clean = tok.replace(/[^\wáéíóúüñ]/gi, '').toLowerCase();
            const translation = vocab[clean];
            if (translation) {
              return `<span class="tooltip" aria-label="${translation}">${tok}<span class="tooltiptext">${translation}</span></span>`;
            }
            return tok;
          })
          .join('');
        el.innerHTML = html;
      });
    })
    .catch(err => console.error('No se pudo cargar el vocabulario:', err));
}

document.addEventListener('DOMContentLoaded', () => {
  const lang = localStorage.getItem('lang') || 'es';
  applyTooltips(lang);
});

// Actualizar tooltips cuando cambia el idioma
document.addEventListener('langChanged', e => {
  applyTooltips(e.detail.newLang);
});
