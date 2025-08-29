// Procesa textos de lecturas para agregar tooltips por palabra
(function() {
  function wrapWords() {
    document.querySelectorAll('[data-tooltips]').forEach(node => {
      const tokens = node.textContent.match(/\w+|\s+|[^\s\w]+/g) || [];
      node.innerHTML = tokens.map(tok => {
        return /\w+/.test(tok)
          ? `<span class="tiw" data-term="${tok}">${tok}</span>`
          : tok;
      }).join('');
    });
    const lang = window.getSelectedLang?.();
    if (window.Tooltip && window.VOCAB) {
      window.Tooltip.init('.tiw', window.VOCAB, lang);
    }
  }
  document.addEventListener('DOMContentLoaded', () => {
    if (window.VOCAB) {
      wrapWords();
    } else {
      document.addEventListener('vocab-loaded', wrapWords, { once: true });
    }
  });
})();
