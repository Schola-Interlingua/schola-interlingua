// Utility functions and vocabulary loader for games
(function(){
  const LANG = localStorage.getItem('lang') || 'es';
  window.LANG = LANG;

  async function loadVocab() {
    try {
      const res = await fetch('/data/vocab.json');
      window.VOCAB = await res.json();
    } catch (err) {
      console.error('Error loading vocab:', err);
      window.VOCAB = [];
    }
  }
  loadVocab();

  function shuffle(array) {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
  }

  function sample(array, n) {
    return shuffle(array.slice()).slice(0, n);
  }

  window.shuffle = shuffle;
  window.sample = sample;
})();
