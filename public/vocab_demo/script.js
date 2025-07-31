// Agrega tooltips de traducción al texto de la lección

document.addEventListener('DOMContentLoaded', () => {
  // Carga el vocabulario
  fetch('../data/vocab.json')
    .then(response => response.json())
    .then(data => {
      const vocab = {};
      // Combina todas las lecciones en un solo objeto para búsqueda rápida
      Object.values(data).forEach(arr => {
        arr.forEach(({ term, answer }) => {
          vocab[term.toLowerCase()] = answer;
        });
      });

      const lessonText = document.getElementById('lesson-text');
      if (!lessonText) return;

      const tokens = lessonText.textContent.match(/\w+|\s+|[^\s\w]+/g) || [];
      const processed = tokens.map(tok => {
        const clean = tok.replace(/[^\wáéíóúüñ]/gi, '').toLowerCase();
        if (vocab[clean]) {
          const translation = vocab[clean];
          return `<span class="tooltip" aria-label="${translation}">${tok}<span class="tooltiptext">${translation}</span></span>`;
        }
        return tok;
      });

      lessonText.innerHTML = processed.join('');
    })
    .catch(err => console.error('No se pudo cargar el vocabulario:', err));
});
