// Biblioteca de tooltips reutilizable
window.Tooltip = {
  init(selector, vocab, lang) {
    const current = lang || window.getSelectedLang?.() || localStorage.getItem('lang') || 'es';
    document.querySelectorAll(selector).forEach(el => {
      const key = (el.dataset.term || '').replace(/[^\wáéíóúüñ]/gi, '').toLowerCase();
      const item = vocab[key];
      if (!item) return;
      const translation = item[current];
      if (!translation) return;
      const span = document.createElement('span');
      span.className = 'tooltip';
      span.textContent = el.textContent;
      const tt = document.createElement('span');
      tt.className = 'tooltiptext';
      tt.textContent = translation;
      span.appendChild(tt);
      el.replaceWith(span);
    });
  }
};

// Agrega tooltips de traducción a textos existentes del sitio
document.addEventListener('DOMContentLoaded', () => {
  // Si la página usa el nuevo sistema de data-tooltips (lecturas),
  // evitamos reprocesar el contenido para no duplicar o esconder texto.
  if (document.querySelector('[data-tooltips]')) return;

  const lang = window.getSelectedLang?.() || localStorage.getItem('lang') || 'es';
  const buildVocab = (data) => {
    const vocab = {};
    Object.values(data).forEach(arr => {
      if (Array.isArray(arr)) {
        arr.forEach(item => {
          if (item?.term) {
            vocab[item.term.toLowerCase()] = item;
          }
        });
      }
    });
    return vocab;
  };

  const loadVocab = window.VOCAB && window.VOCAB_DATA
    ? Promise.resolve(window.VOCAB)
    : fetch('/data/vocab.json')
        .then(res => res.json())
        .then(data => {
          const vocab = buildVocab(data);
          window.VOCAB = vocab;
          window.VOCAB_DATA = data;
          document.dispatchEvent(new Event('vocab-loaded'));
          return vocab;
        });

  loadVocab
    .then(vocab => {
      const elements = document.querySelectorAll('.text-block p:not(.no-tooltip), .text-block li:not(.no-tooltip), .grammar p:not(.no-tooltip), #home-section p:not(.no-tooltip), .grammar li:not(.no-tooltip), .card p:not(.no-tooltip), .vocab-table li:not(.no-tooltip)');
      elements.forEach(el => {
        const tokens = el.textContent.match(/\w+|\s+|[^\s\w]+/g) || [];
        const html = tokens.map(tok => {
          const clean = tok.replace(/[^\wáéíóúüñ]/gi, '').toLowerCase();
          const item = vocab[clean];
          if (item && item[lang]) {
            const translation = item[lang];
            return `<span class="tooltip" aria-label="${translation}">${tok}<span class="tooltiptext">${translation}</span></span>`;
          }
          return tok;
        }).join('');

        el.innerHTML = html;
      });
    })
    .catch(err => console.error('No se pudo cargar el vocabulario:', err));
});
