(async function(){
  const vocab = await loadVocab();
  const lang = getLang();
  const container = document.getElementById('match-game');
  const playAgain = document.getElementById('play-again');

  playAgain.addEventListener('click', () => nextRound(build));
  playAgain.addEventListener('keydown', e => {
    if(e.key === 'Enter' || e.key === ' '){
      e.preventDefault();
      nextRound(build);
    }
  });

  function build(){
    container.innerHTML = '';
    playAgain.style.display = 'none';
    const count = Math.floor(rand()*5) + 6; // 6-10
    const items = sample(vocab, count).map((it,i)=>{
      const {term, gloss} = pickTermAndGloss(it, lang);
      return {id:i, term, gloss};
    });
    const terms = shuffle(items.slice());
    const glosses = shuffle(items.slice());
    let selected = null;
    let solved = 0;

    const left = document.createElement('div');
    const right = document.createElement('div');
    left.className = right.className = 'match-col';

    function selectTerm(btn){
      if(btn.disabled) return;
      if(selected) selected.classList.remove('active');
      selected = btn;
      btn.classList.add('active');
    }

    function selectGloss(btn){
      if(btn.disabled || !selected) return;
      if(btn.dataset.id === selected.dataset.id){
        btn.disabled = true;
        selected.disabled = true;
        btn.classList.add('matched');
        selected.classList.add('matched');
        solved++;
        if(solved === items.length) endRound();
      }
      selected.classList.remove('active');
      selected = null;
    }

    terms.forEach(p=>{
      const b = document.createElement('button');
      b.className = 'btn btn-primary';
      b.textContent = p.term;
      b.dataset.id = p.id;
      b.addEventListener('click', () => selectTerm(b));
      b.addEventListener('keydown', e=>{ if(e.key==='Enter'||e.key===' '){ e.preventDefault(); selectTerm(b);} });
      left.appendChild(b);
    });

    glosses.forEach(p=>{
      const b = document.createElement('button');
      b.className = 'btn btn-secondary';
      b.textContent = p.gloss;
      b.dataset.id = p.id;
      b.addEventListener('click', () => selectGloss(b));
      b.addEventListener('keydown', e=>{
        if(e.key==='Enter'||e.key===' '){ e.preventDefault(); selectGloss(b);} 
        if(e.key==='Backspace'){ if(selected){ selected.classList.remove('active'); selected = null; }}
      });
      right.appendChild(b);
    });

    container.appendChild(left);
    container.appendChild(right);
  }

  function endRound(){
    announce('¡Felicitaciones! Nueva ronda…');
    playAgain.style.display = 'inline-block';
    setTimeout(()=> nextRound(build), 1200);
  }

  nextRound(build);
})();
