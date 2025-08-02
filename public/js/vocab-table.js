document.addEventListener('DOMContentLoaded', async () => {
  const table = document.querySelector('.vocab-table');
  if (!table) return;
  const tbody = table.querySelector('tbody');
  if (!tbody) return;
  const lesson = document.getElementById('exercise-container');
  const lessonId = lesson ? lesson.dataset.lesson : null;
  if (!lessonId) return;
  const data = await fetch('/data/vocab.json').then(r => r.json());
  const items = data[lessonId] || [];
  window.items = items;
  const lang = localStorage.getItem('lang') || 'es';
  items.forEach(item => {
    const tr = document.createElement('tr');
    const tdTerm = document.createElement('td');
    tdTerm.textContent = item.term;
    const tdTrans = document.createElement('td');
    tdTrans.textContent = item[lang] || item.es;
    tr.appendChild(tdTerm);
    tr.appendChild(tdTrans);
    tbody.appendChild(tr);
  });
  const btn = document.createElement('button');
  btn.innerHTML = '<i class="fa-solid fa-book-open"></i> Monstrar vocabulario';
  btn.className = 'vocab-toggle';
  table.before(btn);
  table.style.display = 'none';
  btn.addEventListener('click', () => {
    const visible = table.style.display !== 'none';
    table.style.display = visible ? 'none' : 'block';
    btn.innerHTML = visible
      ? '<i class="fa-solid fa-book-open"></i> Monstrar vocabulario'
      : '<i class="fa-solid fa-eye-slash"></i> Celar vocabulario';
  });
});
