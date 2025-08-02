(function(){
  function createButton() {
    if (document.getElementById('download-anki')) return true;
    const vocabBtn = [...document.querySelectorAll('button')]
      .find(b => /(Mostrar|Monstrar|Ocultar|Celar) vocabulario/i.test(b.textContent));
    if (!vocabBtn) return false;

    const clone = vocabBtn.cloneNode(true);
    clone.id = 'download-anki';
    clone.textContent = 'ANKI';
    vocabBtn.after(clone);

    clone.addEventListener('click', () => {
      const lang = document.documentElement.dataset.lang || 'es';
      const lines = (window.items || [])
        .filter(it => it.term && it[lang])
        .map(it => `${it.term.replace(/\t|\n/g,' ')}\t${it[lang].replace(/\t|\n/g,' ')}`)
        .join('\n');

      const blob = new Blob([lines], {type:'text/plain;charset=utf-8'});
      const link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      const basename = location.pathname.split('/').pop().replace(/\.html$/,'');
      link.download = `${basename}-anki.txt`;
      link.click();
      URL.revokeObjectURL(link.href);
    });
    return true;
  }

  function init(){
    if (createButton()) return;
    const observer = new MutationObserver(() => {
      if (createButton()) observer.disconnect();
    });
    observer.observe(document.body, {childList: true, subtree: true});
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
