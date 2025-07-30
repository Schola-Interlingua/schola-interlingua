document.addEventListener('DOMContentLoaded', async () => {
  const container = document.getElementById('exercise-container');
  if (!container) return;
  const lesson = container.dataset.lesson;

  const data = await fetch('/data/vocab.json').then(r => r.json());
  const items = data[lesson] || [];

  const template = await fetch('/components/exercise.html').then(r => r.text());
  container.innerHTML = template;

  const form = container.querySelector('#exercise-form');
  items.forEach(({ term, answer }) => {
    const row = document.createElement('div');
    row.className = 'row align-items-center mb-2';
    row.innerHTML = `
      <label class="col-sm-2 fw-bold text-end">${term}:</label>
      <div class="col-sm-8">
        <input type="text" data-answer="${answer}" class="form-control exercise-input">
      </div>
      <div class="col-sm-2 text-center"><span class="feedback-icon"></span></div>
    `;
    form.appendChild(row);
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
      const icon = input.parentElement.nextElementSibling.querySelector('.feedback-icon');
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
      const icon = input.parentElement.nextElementSibling.querySelector('.feedback-icon');
      if (icon) icon.innerHTML = '';
    });
    feedback.textContent = '';
  });
});
