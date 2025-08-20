// Odd one out game implementation
(function(){
  function init(){
    if (!window.VOCAB) return setTimeout(init, 100);
    start();
  }

  function start(){
    const entries = Object.values(window.VOCAB).flat();
    const container = document.getElementById('odd-one-game');
    container.innerHTML = '';

    const groups = {};
    entries.forEach(e => {
      const l = e.term[0].toLowerCase();
      groups[l] = groups[l] || [];
      groups[l].push(e);
    });
    const letters = Object.keys(groups).filter(l=>groups[l].length >=3);
    const base = letters[Math.floor(Math.random()*letters.length)];
    const corrects = window.sample(groups[base], 3);
    let intruder;
    do {
      intruder = entries[Math.floor(Math.random()*entries.length)];
    } while (intruder.term[0].toLowerCase() === base);
    const options = window.shuffle([...corrects, intruder]);

    const question = document.createElement('p');
    question.textContent = `¿Cuál es el intruso? (no comienza con "${base}")`;
    container.appendChild(question);
    const list = document.createElement('div');
    list.style.display = 'flex';
    list.style.flexDirection = 'column';
    list.style.gap = '0.5rem';

    const feedback = document.createElement('div');
    feedback.setAttribute('aria-live', 'polite');

    options.forEach(opt => {
      const btn = document.createElement('button');
      btn.className = 'btn btn-primary';
      btn.textContent = `${opt.term} - ${opt[window.LANG]}`;
      btn.addEventListener('click', () => {
        if (opt === intruder){
          feedback.textContent = '¡Correcto!';
          setTimeout(start, 1000);
        } else {
          feedback.textContent = 'No. Intenta de nuevo.';
        }
      });
      btn.addEventListener('keydown', e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();btn.click();}});
      list.appendChild(btn);
    });
    container.appendChild(list);
    container.appendChild(feedback);
  }

  init();
})();
