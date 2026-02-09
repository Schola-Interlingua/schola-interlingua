document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('quiz-container');
  if (!container) return;

  const lang = localStorage.getItem('lang') || 'es';

  function init() {
    if (!window.items || !window.items.length) {
      setTimeout(init, 100);
      return;
    }

    const card = document.createElement('section');
    card.className = 'card quiz-card';
    const questionEl = document.createElement('h3');
    const optionsEl = document.createElement('div');
    optionsEl.className = 'quiz-options';
    card.appendChild(questionEl);
    card.appendChild(optionsEl);
    container.appendChild(card);

    let remaining = [...items];

    function nextQuestion() {
      optionsEl.innerHTML = '';
      if (remaining.length === 0) remaining = [...items];
      const index = Math.floor(Math.random() * remaining.length);
      const item = remaining.splice(index, 1)[0];
      questionEl.textContent = item[lang] || item.es;

      const distractors = items.filter(i => i.term !== item.term);
      distractors.sort(() => Math.random() - 0.5);
      const choices = [item.term, ...distractors.slice(0, 3).map(i => i.term)];
      choices.sort(() => Math.random() - 0.5);

      choices.forEach(choice => {
        const btn = document.createElement('button');
        btn.className = 'quiz-option';
        btn.textContent = choice;
        btn.addEventListener('click', () => {
          if (window.TTS) {
            window.TTS.speak(choice, { lang: 'ia' });
          }
          optionsEl.querySelectorAll('button').forEach(b => (b.disabled = true));
          const correctBtn = [...optionsEl.children].find(
            b => b.textContent === item.term
          );
          if (choice === item.term) {
            btn.classList.add('correct');
          } else {
            btn.classList.add('incorrect');
            if (correctBtn) correctBtn.classList.add('correct');
          }
          setTimeout(nextQuestion, 1000);
        });
        optionsEl.appendChild(btn);
      });
    }

    nextQuestion();
  }

  init();
});
