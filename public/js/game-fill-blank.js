// Fill-in-the-blank game implementation
(function(){
  function init(){
    if (!window.VOCAB) return setTimeout(init, 100);
    start();
  }

  function start(){
    const entries = Object.values(window.VOCAB).flat();
    const entry = window.sample(entries, 1)[0];
    const term = entry.term;
    const trans = entry[window.LANG];
    const container = document.getElementById('fill-blank-game');
    container.innerHTML = '';

    const letters = term.split('');
    const hideCount = Math.max(1, Math.floor(term.length/3));
    const hidden = new Set();
    while (hidden.size < hideCount) {
      const idx = Math.floor(Math.random()*letters.length);
      if (letters[idx] !== ' ') hidden.add(idx);
    }
    const masked = letters.map((ch,i)=> hidden.has(i)?'_':ch).join('');

    const prompt = document.createElement('p');
    prompt.textContent = `${masked} (${trans})`;
    const input = document.createElement('input');
    input.type = 'text';
    input.setAttribute('aria-label', 'Respuesta');
    const checkBtn = document.createElement('button');
    checkBtn.textContent = 'Comprobar';
    checkBtn.className = 'btn btn-primary';
    const feedback = document.createElement('div');
    feedback.setAttribute('aria-live', 'polite');

    function check(){
      if (input.value.trim().toLowerCase() === term.toLowerCase()) {
        feedback.textContent = '¡Correcto!';
        setTimeout(start, 1000);
      } else {
        feedback.textContent = 'Intenta de nuevo';
      }
    }

    checkBtn.addEventListener('click', check);
    input.addEventListener('keydown', e=>{ if (e.key === 'Enter') check(); });

    container.appendChild(prompt);
    container.appendChild(input);
    container.appendChild(checkBtn);
    container.appendChild(feedback);
  }

  init();
})();
