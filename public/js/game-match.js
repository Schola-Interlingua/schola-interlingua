// Matching pairs game implementation
(function(){
  function init(){
    if (!window.VOCAB) return setTimeout(init, 100);
    start();
  }

  function start(){
    const entries = window.sample(Object.values(window.VOCAB).flat(), 5);
    const container = document.getElementById('match-game');
    container.innerHTML = '';
    container.style.display = 'flex';
    container.style.gap = '1rem';
    const left = document.createElement('div');
    const right = document.createElement('div');
    left.style.display = right.style.display = 'flex';
    left.style.flexDirection = right.style.flexDirection = 'column';
    left.style.gap = right.style.gap = '0.5rem';

    const pairs = entries.map((e,i)=>({id:i, term:e.term, trans:e[window.LANG]}));
    const terms = window.shuffle(pairs.slice());
    const trans = window.shuffle(pairs.slice());

    let selectedTerm = null;

    function selectTerm(btn){
      if (btn.disabled) return;
      if (selectedTerm) selectedTerm.classList.remove('active');
      selectedTerm = btn;
      btn.classList.add('active');
    }

    function selectTrans(btn){
      if (!selectedTerm || btn.disabled) return;
      if (btn.dataset.id === selectedTerm.dataset.id){
        btn.disabled = true;
        selectedTerm.disabled = true;
        btn.classList.add('matched');
        selectedTerm.classList.add('matched');
      }
      selectedTerm.classList.remove('active');
      selectedTerm = null;
    }

    terms.forEach(p=>{
      const b = document.createElement('button');
      b.className = 'btn btn-primary';
      b.textContent = p.term;
      b.dataset.id = p.id;
      b.addEventListener('click', ()=>selectTerm(b));
      b.addEventListener('keydown', e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();selectTerm(b);}});
      left.appendChild(b);
    });

    trans.forEach(p=>{
      const b = document.createElement('button');
      b.className = 'btn btn-secondary';
      b.textContent = p.trans;
      b.dataset.id = p.id;
      b.addEventListener('click', ()=>selectTrans(b));
      b.addEventListener('keydown', e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();selectTrans(b);}});
      right.appendChild(b);
    });

    container.appendChild(left);
    container.appendChild(right);
  }

  init();
})();
