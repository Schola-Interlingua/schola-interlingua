// Simple word search game implementation
(function(){
  function init(){
    if (!window.VOCAB) return setTimeout(init, 100);
    start();
  }

  function start(){
    const entries = Object.values(window.VOCAB).flat();
    const entry = window.sample(entries,1)[0];
    const word = entry.term.toUpperCase();
    const translation = entry[window.LANG];
    const size = 10;
    const grid = Array.from({length:size}, () => Array(size).fill(null));
    const row = Math.floor(Math.random()*size);
    const col = Math.floor(Math.random()*(size - word.length));
    for (let i=0;i<word.length;i++) grid[row][col+i] = word[i];
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (let r=0;r<size;r++){
      for (let c=0;c<size;c++){
        if (!grid[r][c]) grid[r][c] = letters[Math.floor(Math.random()*letters.length)];
      }
    }
    const container = document.getElementById('wordsearch-game');
    container.innerHTML = '';
    const clue = document.createElement('p');
    clue.textContent = `Busca: ${translation}`;
    container.appendChild(clue);

    const table = document.createElement('div');
    table.style.display = 'grid';
    table.style.gridTemplateColumns = `repeat(${size}, 1fr)`;
    table.style.gap = '2px';

    let current = '';
    const feedback = document.createElement('div');
    feedback.setAttribute('aria-live', 'polite');

    function reset(){
      current = '';
      table.querySelectorAll('.selected').forEach(b=>b.classList.remove('selected'));
    }

    grid.forEach(rowArr => {
      rowArr.forEach(ch => {
        const btn = document.createElement('button');
        btn.textContent = ch;
        btn.className = 'btn btn-secondary';
        btn.style.width = '30px';
        btn.style.height = '30px';
        btn.style.padding = '0';
        btn.addEventListener('click', () => {
          btn.classList.add('selected');
          current += ch;
          if (word.startsWith(current)) {
            if (current === word) {
              feedback.textContent = '¡Encontrado!';
              setTimeout(start, 1000);
            }
          } else {
            feedback.textContent = 'No coincide';
            setTimeout(reset, 500);
          }
        });
        btn.addEventListener('keydown', e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();btn.click();}});
        table.appendChild(btn);
      });
    });

    container.appendChild(table);
    container.appendChild(feedback);
  }

  init();
})();
