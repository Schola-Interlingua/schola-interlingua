import { supabase } from './supabase.js';

(function () {
  const STORAGE_KEY = 'si_progress';
  const TOTAL_LESSONS = 43;
  const LESSON_ORDER = Array.from({ length: 10 }, (_, i) => `lection${i + 1}`)
    .concat(window.cursoSlugs || []);

  let currentUser = null;

  function storageAvailable() {
    try {
      const test = '__test__';
      localStorage.setItem(test, test);
      localStorage.removeItem(test);
      return true;
    } catch (e) {
      console.log('localStorage non disponibile');
      return false;
    }
  }

  function defaultProgress() {
    return { lessons: {}, streak: { current: 0, best: 0, last_study_date: null } };
  }

  async function loadProgressFromDB(userId) {
    const { data, error } = await supabase
      .from('progress')
      .select('data')
      .eq('user_id', userId)
      .single();

    if (error && error.code !== 'PGRST116') {
      console.error('❌ Error cargando progreso:', error);
      return defaultProgress();
    }

    return data?.data ?? defaultProgress();
  }

  async function saveProgressToDB(progress) {
    if (!currentUser) return;

    console.log('Guardando progreso:', progress);

    const { error } = await supabase
      .from('progress')
      .upsert(
        {
          user_id: currentUser.id,
          data: progress
        },
        { onConflict: 'user_id' }
      );

    if (error) {
      console.error('Error guardando:', error);
    } else {
      console.log('Progreso guardado exitosamente');
    }
  }


  async function loadProgress() {
    let progress;

    if (currentUser) {
      progress = await loadProgressFromDB(currentUser.id);
    } else {
      try {
        const data = localStorage.getItem(STORAGE_KEY);
        progress = data ? JSON.parse(data) : defaultProgress();
      } catch {
        progress = defaultProgress();
      }
    }

  }


  async function saveProgress(p) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(p));
    if (currentUser) {
      await saveProgressToDB(p);
    }
  }

  function updateStreak(progress, today) {
    const streak = progress.streak || { current: 0, best: 0, last_study_date: null };
    if (!streak.last_study_date) {
      streak.current = 1;
    } else {
      const last = new Date(streak.last_study_date);
      const curr = new Date(today);
      const diff = Math.floor((curr - last) / 86400000);
      if (diff === 1) {
        streak.current += 1;
      } else if (diff > 1) {
        streak.current = 1;
      }
      // diff === 0 => no cambio
    }
    streak.last_study_date = today;
    if (streak.current > (streak.best || 0)) streak.best = streak.current;
    progress.streak = streak;
  }

  function formatLesson(id) {
    if (id.startsWith('lection')) return id.replace('lection', '');
    return id.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join(' ');
  }

  // Index rendering
  async function renderIndex() {
    const section = document.getElementById('progress-section');
    if (!section) return;
    if (!storageAvailable()) {
      section.textContent = 'Le progresso non pote esser salvate';
      return;
    }
    if (!currentUser) {
      section.innerHTML = `
        <h2>Tu progresso</h2>
        <p>Aperi session pro salvar e vider tu progresso.</p>
      `;
      return;
    }
    const progress = await loadProgress();
    const lessons = progress.lessons || {};
    const completed = Object.values(lessons).filter(l => l.completed).length;
    const percent = TOTAL_LESSONS ? Math.round((completed / TOTAL_LESSONS) * 100) : 0;

    const noProgress = section.querySelector('#no-progress-msg');
    const details = section.querySelector('#progress-details');
    if (completed === 0) {
      noProgress.style.display = 'block';
    } else {
      noProgress.style.display = 'none';
    }
    details.style.display = 'block';

    section.querySelector('#completion-text').textContent = `${percent}% (${completed}/${TOTAL_LESSONS})`;
    section.querySelector('#completion-bar').style.width = percent + '%';

    const current = progress.streak?.current || 0;
    const best = progress.streak?.best || 0;
    section.querySelector('#streak-current').textContent = `${current} dies consecutive`;
    section.querySelector('#streak-best').textContent = `Melior serie: ${best} dies`;

    const next = LESSON_ORDER.find(id => !(lessons[id] && lessons[id].completed));
    const nextEl = section.querySelector('#next-lesson');
    if (next) {
      nextEl.textContent = `Continua con le lection ${formatLesson(next)}`;
    } else {
      nextEl.textContent = '';
    }
  }

  // Lesson page button
  function setupLesson() {
    const container = document.getElementById('exercise-container');
    if (!container) return;

    // Clean up previous elements to prevent duplicates from multiple calls
    const existingWrapper = document.querySelector('.lesson-progress-wrapper');
    if (existingWrapper) existingWrapper.remove();
    const existingMessage = document.getElementById('completion-message');
    if (existingMessage) existingMessage.remove();

    // Don't show button if logged out
    if (!currentUser) return;

    // Create completion message div and add it to the top of main content
    const completionMessage = document.createElement('div');
    completionMessage.id = 'completion-message';
    completionMessage.style.cssText = 'display:none; background-color: #d4edda; color: #155724; padding: 10px; text-align: center; font-weight: bold; margin-bottom: 1em;';
    completionMessage.textContent = 'Le lection es complete!';
    const main = document.querySelector('main');
    if (main) {
      main.prepend(completionMessage);
    }

    const wrap = document.createElement('div');
    wrap.className = 'lesson-progress-wrapper';
    container.insertAdjacentElement('afterend', wrap);

    if (!storageAvailable()) {
      wrap.textContent = 'Le progresso non pote esser salvate';
      return;
    }

    let rawId =
      container.dataset.lesson ||
      location.pathname.split('/').pop().replace('.html', '');

    const lessonId = rawId.startsWith('lection')
      ? rawId
      : `lection${rawId.replace(/\D/g, '')}`;

    const btn = document.createElement('button');
    btn.id = 'lesson-progress-btn';
    btn.className = 'btn btn-primary';
    const info = document.createElement('div');
    info.id = 'lesson-progress-info';
    wrap.appendChild(btn);
    wrap.appendChild(info);

    function refresh() {
      loadProgress().then(progress => {
        const data = progress.lessons[lessonId];
        const msg = document.getElementById('completion-message');
        if (data && data.completed) {
          btn.textContent = 'Refacer le lection';
          info.textContent = `Ultime vice: ${data.last_done}`;
          if (msg) msg.style.display = 'block';
        } else {
          btn.textContent = 'Marcar le lection como facte';
          info.textContent = '';
          if (msg) msg.style.display = 'none';
        }
      });
    }

    btn.addEventListener('click', async () => {
      const progress = await loadProgress();
      const today = new Date().toISOString().slice(0, 10);
      const data = progress.lessons[lessonId];
      if (data && data.completed) {
        delete progress.lessons[lessonId];
      } else {
        progress.lessons[lessonId] = { completed: true, last_done: today };
        updateStreak(progress, today);
      }
      await saveProgress(progress);
      refresh();
      renderIndex();
    });

    refresh();
  }

  function setupCurso() {
    if (!currentUser) return;
    const grid = document.getElementById('curso-grid');
    if (!grid) return;

    const wrap = document.createElement('div');
    wrap.className = 'lesson-progress-wrapper';
    grid.insertAdjacentElement('afterend', wrap);

    if (!storageAvailable()) {
      wrap.textContent = 'Le progresso non pote esser salvate';
      return;
    }

    const btn = document.createElement('button');
    btn.id = 'save-progress-btn';
    btn.className = 'btn btn-secondary';
    btn.textContent = 'Guardar progresso';
    wrap.appendChild(btn);

    btn.addEventListener('click', async () => {
      const progress = await loadProgress();
      await saveProgress(progress);
      alert('Progreso guardado');
    });
  }

  async function init() {
    if (!storageAvailable()) {
      const section = document.getElementById('progress-section');
      if (section) section.textContent = 'Le progresso non pote esser salvate';
      return;
    }

    supabase.auth.onAuthStateChange(async (_event, session) => {
      currentUser = session?.user ?? null;
      await renderIndex();
      setupLesson();
      setupCurso();
    });
  }


  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  window.addEventListener('storage', (e) => {
    if (e.key === STORAGE_KEY) renderIndex();
  });
})();