(function(){
  const params = new URLSearchParams(location.search);
  let seed = params.get('seed');
  let rand;
  if(seed !== null){
    seed = parseInt(seed,10) || 0;
    rand = function(){
      seed = (seed * 1664525 + 1013904223) % 4294967296;
      return seed / 4294967296;
    };
  } else {
    rand = Math.random;
  }

  function shuffle(arr){
    for(let i = arr.length - 1; i > 0; i--){
      const j = Math.floor(rand() * (i + 1));
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
  }

  function sample(arr, n){
    return shuffle(arr.slice()).slice(0, n);
  }

  function normalize(str){
    return str.normalize('NFD').replace(/\p{Diacritic}/gu,'').toUpperCase();
  }

  let VOCAB_CACHE = null;
  async function loadVocab(){
    if(VOCAB_CACHE) return VOCAB_CACHE;
    try{
      const res = await fetch('/data/vocab.json');
      const data = await res.json();
      VOCAB_CACHE = Object.values(data).flat();
      return VOCAB_CACHE;
    }catch(err){
      announce('Error cargando vocabulario');
      const retry = document.createElement('button');
      retry.textContent = 'Reintentar';
      retry.className = 'btn btn-primary';
      retry.addEventListener('click', ()=>{ retry.remove(); loadVocab(); });
      document.body.appendChild(retry);
      VOCAB_CACHE = [];
      return VOCAB_CACHE;
    }
  }

  function getLang(){
    return localStorage.getItem('lang') || 'es';
  }

  function pickTermAndGloss(item, lang){
    const glosses = item.glosses || item;
    return {
      term: item.term,
      gloss: glosses[lang] || glosses.en || ''
    };
  }

  function announce(msg){
    const box = document.getElementById('announce');
    if(box) box.textContent = msg;
  }

  function nextRound(onBuild){
    announce('Nueva ronda…');
    setTimeout(()=>{
      onBuild();
      const focusable = document.querySelector('main button, main [tabindex]');
      if(focusable) focusable.focus();
    },0);
  }

  window.rand = rand;
  window.shuffle = shuffle;
  window.sample = sample;
  window.normalize = normalize;
  window.loadVocab = loadVocab;
  window.getLang = getLang;
  window.pickTermAndGloss = pickTermAndGloss;
  window.announce = announce;
  window.nextRound = nextRound;
})();
