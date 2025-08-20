(async function(){
  const vocab = await loadVocab();
  const lang = getLang();
  const container = document.getElementById('wordsearch-game');
  const listEl = document.getElementById('word-list');
  const counterEl = document.getElementById('counter');
  const playAgain = document.getElementById('play-again');

  playAgain.addEventListener('click', () => nextRound(build));
  playAgain.addEventListener('keydown', e=>{
    if(e.key==='Enter'||e.key===' '){ e.preventDefault(); nextRound(build); }
  });

  function build(){
    container.innerHTML = '';
    listEl.innerHTML = '';
    counterEl.textContent = '';
    playAgain.style.display = 'none';
    const total = Math.floor(rand()*3) + 6; //6-8
    const items = sample(vocab, total).map(it => normalize(pickTermAndGloss(it, lang).term));
    let remaining = items.length;
    counterEl.textContent = `0 / ${items.length}`;

    const size = 10;
    const grid = Array.from({length:size}, () => Array(size).fill(''));
    items.forEach(word => placeWord(grid, word));
    fillRandom(grid);

    const table = document.createElement('div');
    table.className = 'word-grid';
    table.style.display = 'grid';
    table.style.gridTemplateColumns = `repeat(${size}, 2rem)`;
    table.style.gap = '2px';

    const frag = document.createDocumentFragment();
    let selecting = false; let selCells = [];

    function startSelect(e){ selecting = true; selCells=[e.target]; e.target.classList.add('selected'); }
    function extendSelect(e){ if(selecting){ const prev=selCells[selCells.length-1]; if(isAdjacent(prev,e.target)){ selCells.push(e.target); e.target.classList.add('selected'); }} }
    function endSelect(){ if(selecting){ selecting=false; checkSelection(); } }
    function handleKey(e){
      if(e.shiftKey && ['ArrowUp','ArrowDown','ArrowLeft','ArrowRight'].includes(e.key)){
        e.preventDefault();
        if(selCells.length===0){ selCells=[e.target]; e.target.classList.add('selected'); }
        const last = selCells[selCells.length-1];
        const dir = keyDir(e.key);
        const r = parseInt(last.dataset.r)+dir.r;
        const c = parseInt(last.dataset.c)+dir.c;
        const next = table.querySelector(`button[data-r='${r}'][data-c='${c}']`);
        if(next){ selCells.push(next); next.classList.add('selected'); next.focus(); }
      } else if(e.key==='Enter'){
        e.preventDefault();
        checkSelection();
      } else if(e.key==='Escape'){
        resetSelection();
      }
    }

    function checkSelection(){
      if(selCells.length===0) return;
      const letters = selCells.map(b=>b.textContent).join('');
      const rev = letters.split('').reverse().join('');
      const li = listEl.querySelector(`li[data-word='${letters}'], li[data-word='${rev}']`);
      if(li){
        li.classList.add('found');
        selCells.forEach(b=>b.classList.add('found'));
        remaining--;
        counterEl.textContent = `${items.length-remaining} / ${items.length}`;
        if(remaining===0) endRound();
      }
      resetSelection();
    }

    function resetSelection(){ selCells.forEach(b=>b.classList.remove('selected')); selCells=[]; selecting=false; }

    for(let r=0;r<size;r++){
      for(let c=0;c<size;c++){
        const btn = document.createElement('button');
        btn.className = 'btn btn-secondary cell';
        btn.textContent = grid[r][c];
        btn.dataset.r=r; btn.dataset.c=c;
        btn.addEventListener('mousedown', startSelect);
        btn.addEventListener('mouseenter', extendSelect);
        btn.addEventListener('mouseup', endSelect);
        btn.addEventListener('mouseleave', e=>{ if(!selecting) btn.classList.remove('selected'); });
        btn.addEventListener('keydown', handleKey);
        table.appendChild(btn);
      }
    }

    frag.appendChild(table);
    container.appendChild(frag);

    items.forEach(w=>{
      const li=document.createElement('li');
      li.textContent=w;
      li.dataset.word=w;
      listEl.appendChild(li);
    });

    function endRound(){
      announce('¡Felicitaciones! Nueva ronda…');
      playAgain.style.display = 'inline-block';
      setTimeout(()=> nextRound(build), 1200);
    }

    const first = table.querySelector('button');
    if(first) first.focus();
  }

  function placeWord(grid, word){
    const size = grid.length;
    const dirs = [{r:0,c:1},{r:1,c:0},{r:1,c:1},{r:-1,c:1}];
    let placed=false;
    for(let attempt=0; attempt<100 && !placed; attempt++){
      const dir = dirs[Math.floor(rand()*dirs.length)];
      const maxR = dir.r === -1 ? size-1 : size - (dir.r? word.length:0);
      const maxC = size - (dir.c? word.length:0);
      const startR = Math.floor(rand()* (dir.r===-1 ? maxR - word.length +1 : maxR));
      const startC = Math.floor(rand()* maxC);
      let fits=true;
      for(let i=0;i<word.length;i++){
        const r = startR + dir.r*i;
        const c = startC + dir.c*i;
        const ch = grid[r][c];
        if(ch && ch !== word[i]){ fits=false; break; }
      }
      if(fits){
        for(let i=0;i<word.length;i++){
          const r=startR+dir.r*i;
          const c=startC+dir.c*i;
          grid[r][c]=word[i];
        }
        placed=true;
      }
    }
  }

  function fillRandom(grid){
    const letters='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for(let r=0;r<grid.length;r++){
      for(let c=0;c<grid[r].length;c++){
        if(!grid[r][c]) grid[r][c] = letters[Math.floor(rand()*letters.length)];
      }
    }
  }

  function isAdjacent(a,b){
    const ar=+a.dataset.r, ac=+a.dataset.c, br=+b.dataset.r, bc=+b.dataset.c;
    const dr=Math.abs(ar-br), dc=Math.abs(ac-bc);
    return dr<=1 && dc<=1 && (dr||dc);
  }
  function keyDir(key){
    return {ArrowUp:{r:-1,c:0}, ArrowDown:{r:1,c:0}, ArrowLeft:{r:0,c:-1}, ArrowRight:{r:0,c:1}}[key];
  }

  nextRound(build);
})();
