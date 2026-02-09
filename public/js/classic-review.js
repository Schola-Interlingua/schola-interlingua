document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('classic-review-container');
  if (!container) return;

  const utils = window.ClassicReviewUtils;
  if (!utils) return;

  const uiText = {
    es: {
      sectionTitle: 'Revider',
      typingTitle: 'Scribe le traduction correcte',
      promptLabel: 'Traduce:',
      inputPlaceholder: 'Escribe tu respuesta',
      hint: 'Indicio',
      giveUp: 'Io non lo sape',
      check: 'Verificar',
      next: 'Sequente',
      correct: 'Correcte',
      incorrect: 'Incorrecte',
      reveal: 'Responsa:',
      progress: 'Carta'
    },
    en: {
      sectionTitle: 'Revider',
      typingTitle: 'Type the correct translation',
      promptLabel: 'Translate:',
      inputPlaceholder: 'Type your answer',
      hint: 'Hint',
      giveUp: "I don't know",
      check: 'Check',
      next: 'Next',
      correct: 'Correct',
      incorrect: 'Incorrect',
      reveal: 'Answer:',
      progress: 'Card'
    }
  };

  function getLang() {
    return localStorage.getItem('lang') || 'es';
  }

  function t(key) {
    const lang = getLang();
    return uiText[lang]?.[key] || uiText.es[key] || key;
  }

  function getExtraKeys(lang) {
    if (lang === 'es') {
      return ['á', 'é', 'í', 'ó', 'ú', 'ü', 'ñ'];
    }
    return [];
  }

  function getKeyboardKeys(answer, lang) {
    const lower = (answer || '').toLowerCase();
    const letters = new Set();
    for (const char of lower) {
      if (/[a-záéíóúüñ]/.test(char)) {
        letters.add(char);
      }
    }
    getExtraKeys(lang).forEach(key => letters.add(key));
    return Array.from(letters);
  }

  function getAnswerData(item, lang) {
    const answer = item[lang] || item.es || '';
    const alternatives = utils.splitAlternatives(answer);
    const cleanAnswer = (value) => {
      const withoutParen = value.split('(')[0];
      const beforeComma = withoutParen.split(',')[0];
      return beforeComma.trim();
    };
    const cleanedAlternatives = alternatives.map(cleanAnswer).filter(Boolean);
    const primary = cleanedAlternatives[0] || cleanAnswer(answer);
    return {
      prompt: item.term || '',
      answer: primary,
      fullAnswer: answer,
      primary,
      alternatives: cleanedAlternatives
    };
  }

  function mulberry32(seed) {
    let value = seed;
    return () => {
      value |= 0;
      value = (value + 0x6D2B79F5) | 0;
      let t = Math.imul(value ^ (value >>> 15), 1 | value);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }

  function buildSession(items, count = 10, seed = Date.now()) {
    const rng = mulberry32(seed);
    const shuffled = [...items].sort(() => rng() - 0.5);
    const limited = shuffled.slice(0, Math.min(count, shuffled.length));
    return {
      queue: limited,
      currentIndex: 0,
      events: []
    };
  }

  function createKeyboard(targetInput) {
    const keyboard = document.createElement('div');
    keyboard.className = 'on-screen-keyboard';
    const keyContainer = document.createElement('div');
    keyContainer.className = 'on-screen-keys';
    keyboard.appendChild(keyContainer);

    function addKey(label, value, className = 'key-btn') {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = className;
      btn.textContent = label;
      btn.addEventListener('click', () => {
        const { value: nextValue, cursor } = utils.insertAtCursor(
          targetInput.value,
          value,
          targetInput.selectionStart,
          targetInput.selectionEnd
        );
        targetInput.value = nextValue;
        targetInput.focus();
        targetInput.setSelectionRange(cursor, cursor);
      });
      keyContainer.appendChild(btn);
    }

    function addBackspace() {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'key-btn key-btn-wide';
      btn.textContent = '⌫';
      btn.addEventListener('click', () => {
        const { value, cursor } = utils.backspaceAtCursor(
          targetInput.value,
          targetInput.selectionStart,
          targetInput.selectionEnd
        );
        targetInput.value = value;
        targetInput.focus();
        targetInput.setSelectionRange(cursor, cursor);
      });
      keyContainer.appendChild(btn);
    }

    keyboard.render = (keys) => {
      keyContainer.innerHTML = '';
      keys.forEach(key => addKey(key, key));
      addKey('␣', ' ', 'key-btn key-btn-wide');
      addBackspace();
    };

    return keyboard;
  }

  function createTypingCard(session, items) {
    const card = document.createElement('section');
    card.className = 'card classic-review-card';

    const title = document.createElement('h3');
    title.textContent = t('typingTitle');

    const progress = document.createElement('div');
    progress.className = 'classic-review-progress';

    const promptLabel = document.createElement('div');
    promptLabel.className = 'classic-review-prompt-label';

    const promptText = document.createElement('div');
    promptText.className = 'classic-review-prompt';

    const inputWrapper = document.createElement('div');
    inputWrapper.className = 'classic-review-input-wrapper';

    const input = document.createElement('input');
    input.type = 'text';
    input.autocomplete = 'off';
    input.className = 'classic-review-input';
    input.placeholder = t('inputPlaceholder');

    const ghost = document.createElement('div');
    ghost.className = 'classic-review-ghost';

    inputWrapper.appendChild(input);
    inputWrapper.appendChild(ghost);

    const keyboard = createKeyboard(input);

    const controls = document.createElement('div');
    controls.className = 'classic-review-controls';

    const headerRow = document.createElement('div');
    headerRow.className = 'classic-review-header';

    const btnHint = document.createElement('button');
    btnHint.type = 'button';
    btnHint.className = 'btn btn-secondary';
    btnHint.textContent = t('hint');

    const btnGiveUp = document.createElement('button');
    btnGiveUp.type = 'button';
    btnGiveUp.className = 'btn btn-light classic-review-giveup';
    btnGiveUp.innerHTML = '<span class="classic-review-giveup-icon">?</span>' +
      `<span>${t('giveUp')}</span>`;

    const btnCheck = document.createElement('button');
    btnCheck.type = 'button';
    btnCheck.className = 'btn btn-success';
    btnCheck.textContent = t('check');

    const btnNext = document.createElement('button');
    btnNext.type = 'button';
    btnNext.className = 'btn btn-primary';
    btnNext.textContent = t('next');
    btnNext.disabled = true;

    controls.appendChild(btnHint);
    controls.appendChild(btnCheck);
    controls.appendChild(btnNext);

    const feedback = document.createElement('div');
    feedback.className = 'classic-review-feedback';

    const reveal = document.createElement('div');
    reveal.className = 'classic-review-reveal';

    headerRow.appendChild(title);
    headerRow.appendChild(btnGiveUp);
    card.appendChild(headerRow);
    card.appendChild(progress);
    card.appendChild(promptLabel);
    card.appendChild(promptText);
    card.appendChild(inputWrapper);
    card.appendChild(keyboard);
    card.appendChild(controls);
    card.appendChild(feedback);
    card.appendChild(reveal);

    let currentItem = null;
    let answerData = null;
    let usedHintLevel = 0;
    let gaveUp = false;
    let answered = false;

    function resetState() {
      input.value = '';
      feedback.textContent = '';
      feedback.className = 'classic-review-feedback';
      reveal.textContent = '';
      ghost.textContent = '';
      usedHintLevel = 0;
      gaveUp = false;
      answered = false;
      btnNext.disabled = true;
    }

    input.addEventListener('input', () => {
      if (input.value) {
        ghost.textContent = '';
      }
    });

    function updateProgress() {
      progress.textContent = `${t('progress')} ${session.currentIndex + 1} / ${session.queue.length}`;
    }

    function loadItem() {
      resetState();
      const lang = getLang();
      currentItem = session.queue[session.currentIndex];
      answerData = getAnswerData(currentItem, lang);
      const keySet = getKeyboardKeys(answerData.primary, lang);
      keyboard.render(keySet);
      promptLabel.textContent = t('promptLabel');
      promptText.textContent = answerData.prompt;
      updateProgress();
      input.focus();
    }

    function showReveal() {
      reveal.textContent = `${t('reveal')} ${answerData.answer}`;
    }

    function checkAnswer() {
      if (answered) return;
      const correct = utils.isCorrect(
        input.value,
        answerData.primary,
        answerData.alternatives
      );
      const isCountedCorrect = correct && usedHintLevel < 3 && !gaveUp;
      if (isCountedCorrect) {
        feedback.textContent = t('correct');
        feedback.classList.add('correct');
      } else {
        feedback.textContent = t('incorrect');
        feedback.classList.add('incorrect');
        showReveal();
      }
      btnNext.disabled = false;
      answered = true;
      session.events.push({
        itemId: currentItem.term,
        exerciseType: 'typing',
        shownAt: new Date().toISOString(),
        answeredAt: new Date().toISOString(),
        userAnswer: input.value,
        correct: isCountedCorrect,
        usedHintLevel,
        gaveUp
      });
    }

    function applyHint(level) {
      if (!answerData) return;
      const target = answerData.primary;
      const nextLength = Math.min(input.value.length + 1, target.length);
      input.value = target.slice(0, nextLength);
      input.focus();
    }

    btnHint.addEventListener('click', () => {
      usedHintLevel = Math.min(usedHintLevel + 1, 3);
      applyHint(usedHintLevel);
    });

    btnGiveUp.addEventListener('click', () => {
      if (answered) return;
      gaveUp = true;
      showReveal();
      feedback.textContent = t('incorrect');
      feedback.classList.add('incorrect');
      btnNext.disabled = false;
      answered = true;
      session.events.push({
        itemId: currentItem.term,
        exerciseType: 'typing',
        shownAt: new Date().toISOString(),
        answeredAt: new Date().toISOString(),
        userAnswer: input.value,
        correct: false,
        usedHintLevel,
        gaveUp
      });
    });

    btnCheck.addEventListener('click', () => {
      checkAnswer();
    });

    btnNext.addEventListener('click', () => {
      session.currentIndex = (session.currentIndex + 1) % session.queue.length;
      loadItem();
    });

    loadItem();
    return card;
  }

  function init() {
    if (!window.items || !window.items.length) {
      setTimeout(init, 100);
      return;
    }

    container.innerHTML = '';
    const heading = document.createElement('h2');
    heading.textContent = t('sectionTitle');
    container.appendChild(heading);

    const session = buildSession(window.items, 10);
    const typingCard = createTypingCard(session, window.items);
    container.appendChild(typingCard);
  }

  init();
});
