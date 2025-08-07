(function(){
  let cache = null;

  async function loadVocab(){
    if(cache) return cache;
    const res = await fetch('/data/vocab.json');
    const data = await res.json();
    const all=[];
    for(const [group,arr] of Object.entries(data)){
      arr.forEach(item=>all.push({...item, group}));
    }
    cache = all;
    return all;
  }

  async function getRandomEntries(count){
    const vocab = await loadVocab();
    const arr = [...vocab];
    shuffle(arr);
    return arr.slice(0,count);
  }

  function getLang(){
    return localStorage.getItem('lang') || 'es';
  }

  function shuffle(arr){
    for(let i=arr.length-1;i>0;i--){
      const j=Math.floor(Math.random()*(i+1));
      [arr[i],arr[j]]=[arr[j],arr[i]];
    }
    return arr;
  }

  window.gamesCommon = {loadVocab, getRandomEntries, getLang, shuffle};
})();
