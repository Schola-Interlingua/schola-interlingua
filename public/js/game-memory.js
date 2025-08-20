// Memory (Parejas) game implementation
(function(){
  function init(){
    if (!window.VOCAB) return setTimeout(init, 100);
    const entries = Object.values(window.VOCAB).flat();
    const pairs = 6;
    const selected = window.sample(entries, pairs);
    const cards = [];
    selected.forEach((entry, idx) => {
      cards.push({ id: idx, text: entry.term });
      cards.push({ id: idx, text: entry[window.LANG] });
    });
    window.shuffle(cards);

    const container = document.getElementById('memory-game');
    container.style.display = 'grid';
    container.style.gridTemplateColumns = 'repeat(4, minmax(0,1fr))';
    container.style.gap = '1rem';

    let first = null;
    let lock = false;

    function reveal(btn){
      if (lock || btn.classList.contains('matched')) return;
      btn.textContent = btn.dataset.text;
      if (!first) {
        first = btn;
      } else {
        if (first.dataset.id === btn.dataset.id && first !== btn) {
          first.classList.add('matched');
          btn.classList.add('matched');
          first.disabled = true;
          btn.disabled = true;
        } else {
          lock = true;
          setTimeout(() => {
            first.textContent = '';
            btn.textContent = '';
            lock = false;
          }, 800);
        }
        first = null;
      }
    }

    cards.forEach(card => {
      const btn = document.createElement('button');
      btn.className = 'btn btn-primary memory-card';
      btn.setAttribute('data-id', card.id);
      btn.setAttribute('data-text', card.text);
      btn.addEventListener('click', () => reveal(btn));
      btn.addEventListener('keydown', e => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          reveal(btn);
        }
      });
      container.appendChild(btn);
    });
  }
  init();
})();
