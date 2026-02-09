document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('classic-review-container');
  if (!container) return;

  const utils = window.ClassicReviewUtils;
  if (!utils) return;

  const uiText = {
    es: {
      sectionTitle: 'Repasar (Classic Review)',
      typingTitle: 'Escribe la traducción correcta',
      promptLabel: 'Traduce:',
      inputPlaceholder: 'Escribe tu respuesta',
      hint: 'Pista',
      giveUp: 'No lo sé',
      check: 'Comprobar',
      next: 'Siguiente',
      correct: 'Correcto',
      incorrect: 'Incorrecto',
      reveal: 'Respuesta:',
      progress: 'Tarjeta'
    },
    en: {
      sectionTitle: 'Review (Classic Review)',
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

  function getAnswerData(item, lang) {
    const answer = item[lang] || item.es || '';
    const alternatives = utils.splitAlternatives(answer);
    const primary = alternatives[0] || answer;
    return {
      prompt: item.term || '',
      answer,
      primary,
      alternatives
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

  function createKeyboard(targetInput, lang) {
    const keyboard = document.createElement('div');
    keyboard.className = 'on-screen-keyboard';

    const keys = 'abcdefghijklmnopqrstuvwxyz'.split('');
    const extraKeys = getExtraKeys(lang);
    const punctuationKeys = ['-', '\''];
    const fullKeys = [...keys, ...extraKeys, ...punctuationKeys];

    fullKeys.forEach(key => {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'key-btn';
      btn.textContent = key;
      btn.addEventListener('click', () => {
        const { value, cursor } = utils.insertAtCursor(
          targetInput.value,
          key,
          targetInput.selectionStart,
          targetInput.selectionEnd
        );
        targetInput.value = value;
        targetInput.focus();
        targetInput.setSelectionRange(cursor, cursor);
      });
      keyboard.appendChild(btn);
    });

    const spaceBtn = document.createElement('button');
    spaceBtn.type = 'button';
    spaceBtn.className = 'key-btn key-btn-wide';
    spaceBtn.textContent = '␣';
    spaceBtn.addEventListener('click', () => {
      const { value, cursor } = utils.insertAtCursor(
        targetInput.value,
        ' ',
        targetInput.selectionStart,
        targetInput.selectionEnd
      );
      targetInput.value = value;
      targetInput.focus();
      targetInput.setSelectionRange(cursor, cursor);
    });

    const backspaceBtn = document.createElement('button');
    backspaceBtn.type = 'button';
    backspaceBtn.className = 'key-btn key-btn-wide';
    backspaceBtn.textContent = '⌫';
    backspaceBtn.addEventListener('click', () => {
      const { value, cursor } = utils.backspaceAtCursor(
        targetInput.value,
        targetInput.selectionStart,
        targetInput.selectionEnd
      );
      targetInput.value = value;
      targetInput.focus();
      targetInput.setSelectionRange(cursor, cursor);
    });

    keyboard.appendChild(spaceBtn);
    keyboard.appendChild(backspaceBtn);
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

    const keyboard = createKeyboard(input, getLang());

    const controls = document.createElement('div');
    controls.className = 'classic-review-controls';

    const btnHint = document.createElement('button');
    btnHint.type = 'button';
    btnHint.className = 'btn btn-secondary';
    btnHint.textContent = t('hint');

    const btnGiveUp = document.createElement('button');
    btnGiveUp.type = 'button';
    btnGiveUp.className = 'btn btn-warning';
    btnGiveUp.textContent = t('giveUp');

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
    controls.appendChild(btnGiveUp);
    controls.appendChild(btnCheck);
    controls.appendChild(btnNext);

    const feedback = document.createElement('div');
    feedback.className = 'classic-review-feedback';

    const reveal = document.createElement('div');
    reveal.className = 'classic-review-reveal';

    card.appendChild(title);
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
      if (level === 1) {
        const nextLength = Math.min(input.value.length + 1, target.length);
        input.value = target.slice(0, nextLength);
      } else if (level === 2) {
        const words = target.split(' ');
        const currentWords = input.value.trim().split(' ').filter(Boolean).length;
        const nextWords = Math.min(currentWords + 1, words.length);
        input.value = words.slice(0, nextWords).join(' ');
        if (nextWords < words.length) {
          input.value += ' ';
        }
      } else if (level >= 3) {
        ghost.textContent = answerData.answer;
      }
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

  function createStubCard(titleText) {
    const card = document.createElement('section');
    card.className = 'card classic-review-card classic-review-stub';
    const title = document.createElement('h4');
    title.textContent = titleText;
    const message = document.createElement('p');
    message.textContent = '...';
    card.appendChild(title);
    card.appendChild(message);
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
    container.appendChild(createStubCard('Multiple Choice'));
    container.appendChild(createStubCard('Ordenar'));
    container.appendChild(createStubCard('Listening'));
  }

  init();
});
