// Carga el vocabulario global y lo expone como window.VOCAB
// Emite el evento 'vocab-loaded' cuando está listo
(function() {
  function load() {
    fetch('/data/vocab.json')
      .then(res => res.json())
      .then(data => {
        const vocab = {};
        Object.values(data).forEach(arr => {
          if (Array.isArray(arr)) {
            arr.forEach(item => {
              vocab[item.term.toLowerCase()] = item;
            });
          }
        });
        window.VOCAB = vocab;
        window.VOCAB_DATA = data;
        document.dispatchEvent(new Event('vocab-loaded'));
      })
      .catch(err => console.error('No se pudo cargar el vocabulario:', err));
  }
  if (!window.VOCAB) {
    document.addEventListener('DOMContentLoaded', load);
  }
})();
