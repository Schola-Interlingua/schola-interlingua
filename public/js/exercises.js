document.addEventListener('DOMContentLoaded', async () => {
  const container = document.getElementById('exercise-container');
  if (!container) return;
  const lesson = container.dataset.lesson;

  const data = await fetch('/data/vocab.json').then(r => r.json());
  const items = data[lesson] || [];
  const lang = localStorage.getItem('lang') || 'es';

  const template = await fetch('/components/exercise.html').then(r => r.text());
  container.innerHTML = template;

  const form = container.querySelector('#exercise-form');
  items.forEach(vocab => {
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

  const btnCheck = container.querySelector('.btn-comprobar');
  const btnClear = container.querySelector('.btn-borrar');
  const feedback = container.querySelector('.feedback');

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
});