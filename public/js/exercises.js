document.addEventListener('DOMContentLoaded', async () => {
  const container = document.getElementById('exercise-container');
  if (!container) return;
  const lesson = container.dataset.lesson;

  const data = await fetch('/data/vocab.json').then(r => r.json());
  const items = data[lesson] || [];
  const lang = localStorage.getItem('lang') || 'es';

  const BLOCK_SIZE = 5;
  const totalBlocks = Math.ceil(items.length / BLOCK_SIZE);

  // Clear container and build blocks
  container.innerHTML = '';

  for (let blockIndex = 0; blockIndex < totalBlocks; blockIndex++) {
    const start = blockIndex * BLOCK_SIZE;
    const end = start + BLOCK_SIZE;
    const blockItems = items.slice(start, end);
    const blockNumber = blockIndex + 1;

    // Create block container
    const blockSection = document.createElement('section');
    blockSection.className = 'card exercise-card mb-4';
    blockSection.innerHTML = `
      <h3>Traducer — Bloco ${blockNumber}</h3>
      <form class="exercise-grid block-form"></form>
      <div class="mt-3">
        <button class="btn btn-success btn-comprobar">Verificar</button>
        <button class="btn btn-danger btn-borrar">Rader</button>
      </div>
      <div class="feedback mt-2"></div>
    `;

    const form = blockSection.querySelector('.block-form');

    // Add exercise items to this block's form
    blockItems.forEach(vocab => {
      const answer = vocab[lang] || vocab.es;
      const term = vocab.term;
      const element = document.createElement('div');
      element.className = 'exercise-item';
      element.innerHTML = `
        <label class="term">${term}:</label>
        <div class="answer">
          <input type="text" data-answer="${answer}" class="exercise-input">
          <span class="feedback-icon"></span>
        </div>
      `;
      form.appendChild(element);
    });

    // Set up event listeners for this block
    const btnCheck = blockSection.querySelector('.btn-comprobar');
    const btnClear = blockSection.querySelector('.btn-borrar');
    const feedback = blockSection.querySelector('.feedback');

    btnCheck.addEventListener('click', (e) => {
      e.preventDefault();
      let correct = 0;
      const inputs = form.querySelectorAll('.exercise-input');
      inputs.forEach(input => {
        const expected = input.dataset.answer.trim().toLowerCase();
        const val = input.value.trim().toLowerCase();
        const icon = input.nextElementSibling;
        if (val === expected) {
          input.classList.add('is-valid');
          input.classList.remove('is-invalid');
          icon.innerHTML = '<i class="fa-solid fa-check text-success"></i>';
          correct++;
        } else {
          input.classList.add('is-invalid');
          input.classList.remove('is-valid');
          icon.innerHTML = '<i class="fa-solid fa-times text-danger"></i>';
        }
      });
      feedback.textContent = `✔️ ${correct}/${inputs.length}`;
    });

    btnClear.addEventListener('click', (e) => {
      e.preventDefault();
      const inputs = form.querySelectorAll('.exercise-input');
      inputs.forEach(input => {
        input.value = '';
        input.classList.remove('is-valid', 'is-invalid');
        const icon = input.nextElementSibling;
        if (icon) icon.innerHTML = '';
      });
      feedback.textContent = '';
    });

    container.appendChild(blockSection);
  }
});
