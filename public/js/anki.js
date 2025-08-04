(function(){
  function createButton() {
    if (document.getElementById('download-anki')) return true;
    const vocabBtn = [...document.querySelectorAll('button')]
      .find(b => /(Mostrar|Monstrar|Ocultar|Celar) vocabulario/i.test(b.textContent));
    if (!vocabBtn) return false;

    const clone = vocabBtn.cloneNode(true);
    clone.id = 'download-anki';
    clone.innerHTML = '<i class="fa-solid fa-download"></i> ANKI';
    clone.style.marginLeft = '0.5rem';
    vocabBtn.after(clone);

    clone.addEventListener('click', () => {
      const lang = localStorage.getItem('lang') || 'es';
      const sanitize = str => str.replace(/[\t\n,]/g, ' ');
      const basename = location.pathname.split('/').pop().replace(/\.html$/,'');
      const deck = sanitize(
        basename.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join('')
      );
      const lines = (window.items || [])
        .filter(it => it.term && (it[lang] || it.es))
        .map(it => {
          const term = sanitize(it.term);
          const trans = sanitize(it[lang] || it.es);
          return `${term},${trans},${deck}`;
        })
        .join('\n');

      const blob = new Blob([lines], {type:'text/plain;charset=utf-8'});
      const link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
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
