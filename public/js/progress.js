import { supabase } from './supabase.js';

(function () {
  const STORAGE_KEY = 'si_progress';
  const TOTAL_LESSONS = 43;
  const LESSON_ORDER = Array.from({ length: 10 }, (_, i) => `lection${i + 1}`)
    .concat(window.cursoSlugs || []);

  let currentUser = null;

  let storageEnabled = false;

  function checkStorage() {
    storageEnabled = storageAvailable();
    if (!storageEnabled) {
      console.log('Storage not available');
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
    if (currentUser) {
      return await loadProgressFromDB(currentUser.id);
    }
    try {
      const data = localStorage.getItem(STORAGE_KEY);
      return data ? JSON.parse(data) : defaultProgress();
    } catch (e) {
      return defaultProgress();
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
    if (!storageEnabled) {
      section.textContent = 'Le progresso non pote esser salvate';
      return;
    }
    if (!currentUser) {
      section.innerHTML = `
        <h2>Tu progresso</h2>
        <p>Inicia sesión para guardar y ver tu progreso.</p>
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

  function exportProgress() {
    const data = localStorage.getItem(STORAGE_KEY);
    if (!data) { alert('Il non ha progresso pro exportar'); return; }
    const blob = new Blob([data], { type: 'application/json' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'si_progress.json';
    a.click();
    URL.revokeObjectURL(a.href);
  }

  function importProgress() {
    const json = prompt('Incolla tu progresso in formato JSON:');
    if (!json) return;
    try {
      const parsed = JSON.parse(json);
      localStorage.setItem(STORAGE_KEY, JSON.stringify(parsed));
      if (currentUser) {
        saveProgressToDB(parsed);
      }
      renderIndex();
    } catch (e) {
      alert('JSON invalide');
    }
  }

  // Lesson page button
  function setupLesson() {
    if (!currentUser) return;
    const container = document.getElementById('exercise-container');
    if (!container) return;

    // Create completion banner only if it doesn't exist
    let banner = document.getElementById('completion-banner');
    if (!banner) {
      banner = document.createElement('div');
      banner.id = 'completion-banner';
      banner.textContent = '¡Lección completada!';
      banner.style.display = 'none';
      banner.style.position = 'fixed';
      banner.style.top = '60px'; // Below navbar
      banner.style.left = '0';
      banner.style.right = '0';
      banner.style.backgroundColor = '#28a745';
      banner.style.color = 'white';
      banner.style.textAlign = 'center';
      banner.style.padding = '10px';
      banner.style.zIndex = '999';
      banner.style.fontSize = '18px';
      banner.style.fontWeight = 'bold';
      document.body.insertBefore(banner, document.body.firstChild);
    }

    const wrap = document.createElement('div');
    wrap.className = 'lesson-progress-wrapper';
    container.insertAdjacentElement('afterend', wrap);

    if (!storageEnabled) {
      wrap.textContent = 'Le progresso non pote esser salvate';
      return;
    }

    const lessonId = container.dataset.lesson || location.pathname.split('/').pop().replace('.html', '');

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
        const banner = document.getElementById('completion-banner');
        if (data && data.completed) {
          btn.textContent = 'Refacer le lection';
          info.textContent = `Ultime vice: ${data.last_done}`;
          if (banner) banner.style.display = 'block';
        } else {
          btn.textContent = 'Marcar le lection como facte';
          info.textContent = '';
          if (banner) banner.style.display = 'none';
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
    });

    refresh();
  }

  // Setup for curso page
  function setupCurso() {
    if (!currentUser) return;
    const grid = document.getElementById('curso-grid');
    if (!grid) return;

    const wrap = document.createElement('div');
    wrap.className = 'lesson-progress-wrapper';
    grid.insertAdjacentElement('afterend', wrap);

    if (!storageEnabled) {
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
    checkStorage();
    if (!storageEnabled) {
      const section = document.getElementById('progress-section');
      if (section) section.textContent = 'Le progresso non pote esser salvate';
      return;
    }
    const exportBtn = document.getElementById('export-progress');
    const importBtn = document.getElementById('import-progress');
    if (exportBtn) exportBtn.addEventListener('click', exportProgress);
    if (importBtn) importBtn.addEventListener('click', importProgress);

    // Auth listener
    supabase.auth.onAuthStateChange(async (_event, session) => {
      currentUser = session?.user ?? null;
      if (currentUser) {
        const dbProgress = await loadProgressFromDB(currentUser.id);
        localStorage.setItem(STORAGE_KEY, JSON.stringify(dbProgress));
      }
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
