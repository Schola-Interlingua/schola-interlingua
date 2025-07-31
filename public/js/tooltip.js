// Agrega tooltips de traducción a todos los textos de las lecciones

document.addEventListener('DOMContentLoaded', () => {
  const lang = localStorage.getItem('lang') || 'es';
  // Cargar vocabulario
  fetch('/data/vocab.json')
    .then(res => res.json())
    .then(data => {
      const vocab = {};
      // Unir todas las lecciones en un solo objeto de búsqueda
      Object.values(data).forEach(arr => {
        if (Array.isArray(arr)) {
          arr.forEach(item => {
            const translation = item[lang] || item.es;
            vocab[item.term.toLowerCase()] = translation;
          });
        }
      });

      const elements = document.querySelectorAll('.text-block p, .grammar p, #home-section p, .grammar li');
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
    })
    .catch(err => console.error('No se pudo cargar el vocabulario:', err));
});
