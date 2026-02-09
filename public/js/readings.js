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

  function addSpeakButton() {
    const container = document.querySelector('.reading-container');
    if (!container || !window.SpeakButton) return;
    const body = container.querySelector('.reading-body');
    if (!body) return;
    const toolbar = document.createElement('div');
    toolbar.className = 'reading-audio';
    const button = window.SpeakButton.create({
      label: 'Reproducer lectura',
      title: 'Reproducer lectura',
      onClick: async () => {
        if (!window.TTS) return;
        await window.TTS.speak(body.textContent, { lang: 'ia' });
      }
    });
    toolbar.appendChild(button);
    const title = container.querySelector('.reading-title');
    if (title) {
      title.insertAdjacentElement('afterend', toolbar);
    } else {
      container.prepend(toolbar);
    }
  }
  document.addEventListener('DOMContentLoaded', () => {
    addSpeakButton();
    if (window.VOCAB) {
      wrapWords();
    } else {
      document.addEventListener('vocab-loaded', wrapWords, { once: true });
    }
  });
})();
