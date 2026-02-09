document.addEventListener('DOMContentLoaded', () => {
  const panel = document.getElementById('course-practice-panel');
  if (!panel) return;

  const classic = panel.querySelector('#classic-review-container');
  const quiz = panel.querySelector('#quiz-container');
  const exercise = panel.querySelector('#exercise-container');

  panel.innerHTML = '';
  if (classic) panel.appendChild(classic);
  if (quiz) panel.appendChild(quiz);
  if (exercise) panel.appendChild(exercise);
});
