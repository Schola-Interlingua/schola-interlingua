// public/js/exercises.js
document.addEventListener('DOMContentLoaded', async () => {
  const container = document.getElementById('exercise-container');
  if (!container) return;

  /* 1. Obtener número de lección */
  const lesson = container.dataset.lesson;

  /* 2. Cargar vocabulario y plantilla */
  const data      = await fetch('/data/vocab.json').then(r => r.json());
  const items     = data[lesson] || [];
  const template  = await fetch('/components/exercise.html').then(r => r.text());
  container.innerHTML = template;

  /* 3. Preparar formulario como grid de 2 columnas */
  const form = container.querySelector('#exercise-form');
  form.classList.add('exercise-grid');         // <-- clave para el CSS

  /* 4. Insertar cada palabra */
  items.forEach(({ term, answer }) => {
    const row = document.createElement('div');
    row.className = 'exercise-item';
    row.innerHTML = `
      <label>${term}:</label>
      <input type="text" data-answer="${answer.trim().toLowerCase()}" class="exercise-input">
      <span class="feedback-icon"></span>
    `;
    form.appendChild(row);
  });

  /* 5. Botones */
  const btnCheck = container.querySelector('.btn-comprobar');
  const btnClear = container.querySelector('.btn-borrar');
  const feedback = container.querySelector('.feedback');

  /* 5a. Comprobar respuestas */
  btnCheck.addEventListener('click', (e) => {
    e.preventDefault();
    let correct = 0;
    const inputs = form.querySelectorAll('.exercise-input');

    inputs.forEach(input => {
      const expected = input.dataset.answer;
      const val      = input.value.trim().toLowerCase();
      const icon     = input.nextElementSibling;     /* <span> justo después */

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

  /* 5b. Borrar respuestas */
  btnClear.addEventListener('click', (e) => {
    e.preventDefault();
    const inputs = form.querySelectorAll('.exercise-input');

    inputs.forEach(input => {
      input.value = '';
      input.classList.remove('is-valid', 'is-invalid');
      const icon = input.nextElementSibling;
      icon.innerHTML = '';
    });

    feedback.textContent = '';
  });
});
