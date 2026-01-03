import { supabase } from './supabase.js';

(function () {
  const TOTAL_LESSONS = 43;
  const LESSON_ORDER = Array.from({ length: 10 }, (_, i) => `lection${i + 1}`)
    .concat(window.cursoSlugs || []);

  let userProgress = { lessons: {}, streak: { current: 0, best: 0, last_study_date: null } };
  let currentUser = null;
  let isSaving = false;
  let saveTimeout = null;

  async function loadProgressFromDB(userId) {
    try {
      const { data, error } = await supabase
        .from('progress')
        .select('data')
        .eq('user_id', userId)
        .single();

      if (error && error.code !== 'PGRST116') { // PGRST116 = no rows found
        console.error('Error cargando el progreso:', error);
        return { lessons: {}, streak: {} };
      }
      return data ? data.data : { lessons: {}, streak: {} };
    } catch (e) {
      console.error('Error al obtener el progreso de la base de datos', e);
      return { lessons: {}, streak: {} };
    }
  }

  function saveProgressToDB() {
    if (!currentUser || isSaving) return;

    // Debounce saving to avoid rapid writes
    if (saveTimeout) clearTimeout(saveTimeout);

    saveTimeout = setTimeout(async () => {
      isSaving = true;
      try {
        const { error } = await supabase
          .from('progress')
          .upsert({ user_id: currentUser.id, data: userProgress }, { onConflict: 'user_id' });

        if (error) {
          console.error('Error guardando el progreso:', error);
        }
      } catch (e) {
        console.error('Error al guardar el progreso en la base de datos', e);
      } finally {
        isSaving = false;
        saveTimeout = null;
      }
    }, 1000); // Wait 1 second after the last change to save
  }

  function updateStreak(today) {
    const streak = userProgress.streak || { current: 0, best: 0, last_study_date: null };
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
    }
    streak.last_study_date = today;
    if (streak.current > (streak.best || 0)) streak.best = streak.current;
    userProgress.streak = streak;
    saveProgressToDB();
  }

  function formatLesson(id) {
    if (id.startsWith('lection')) return id.replace('lection', '');
    return id.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join(' ');
  }

  function renderIndexUI() {
    const section = document.getElementById('progress-section');
    if (!section) return;

    // Make the section visible now that we're ready to render
    section.style.visibility = 'visible';

    if (!currentUser) {
      section.innerHTML = `
        <h2>Tu progresso</h2>
        <p class="no-tooltip">Ingresar para desbloquear la función de progreso</p>
      `;
      return;
    }

    // Ensure buttons are hidden for logged-in users
    const backupDiv = section.querySelector('.backup');
    if (backupDiv) backupDiv.style.display = 'none';

    const lessons = userProgress.lessons || {};
    const completed = Object.values(lessons).filter(l => l.completed).length;
    const percent = TOTAL_LESSONS ? Math.round((completed / TOTAL_LESSONS) * 100) : 0;

    const noProgress = section.querySelector('#no-progress-msg');
    const details = section.querySelector('#progress-details');

    if (noProgress) noProgress.style.display = completed === 0 ? 'block' : 'none';
    if (details) details.style.display = completed > 0 ? 'block' : 'none';

    const completionText = section.querySelector('#completion-text');
    if (completionText) completionText.textContent = `${percent}% (${completed}/${TOTAL_LESSONS})`;

    const completionBar = section.querySelector('#completion-bar');
    if (completionBar) completionBar.style.width = percent + '%';

    const currentStreak = userProgress.streak?.current || 0;
    const bestStreak = userProgress.streak?.best || 0;

    const streakCurrentEl = section.querySelector('#streak-current');
    if (streakCurrentEl) streakCurrentEl.textContent = `${currentStreak} dies consecutive`;

    const streakBestEl = section.querySelector('#streak-best');
    if (streakBestEl) streakBestEl.textContent = `Melior serie: ${bestStreak} dies`;

    const next = LESSON_ORDER.find(id => !(lessons[id] && lessons[id].completed));
    const nextEl = section.querySelector('#next-lesson');
    if (nextEl) {
      nextEl.textContent = next ? `Continua con le lection ${formatLesson(next)}` : '';
    }
  }

  function setupLessonButton() {
    const container = document.getElementById('exercise-container');
    if (!container) return;

    const wrap = document.createElement('div');
    wrap.className = 'lesson-progress-wrapper';
    container.insertAdjacentElement('afterend', wrap);

    const lessonId = container.dataset.lesson || location.pathname.split('/').pop().replace('.html', '');

    const btn = document.createElement('button');
    btn.id = 'lesson-progress-btn';
    btn.className = 'btn btn-primary';
    const info = document.createElement('div');
    info.id = 'lesson-progress-info';
    wrap.appendChild(btn);
    wrap.appendChild(info);

    function refreshButton() {
      const data = userProgress.lessons[lessonId];
      if (data && data.completed) {
        btn.textContent = 'Refacer le lection';
        info.textContent = `Ultime vice: ${data.last_done}`;
      } else {
        btn.textContent = 'Marcar le lection como facte';
        info.textContent = '';
      }
    }

    btn.addEventListener('click', () => {
      const today = new Date().toISOString().slice(0, 10);
      const lessonData = userProgress.lessons[lessonId];

      if (lessonData && lessonData.completed) {
        delete userProgress.lessons[lessonId];
      } else {
        userProgress.lessons[lessonId] = { completed: true, last_done: today };
        updateStreak(today);
      }
      saveProgressToDB();
      refreshButton();
      renderIndexUI(); // Update index page if it's visible
    });

    refreshButton();
  }

  async function handleAuthStateChange(user) {
    currentUser = user;
    if (user) {
      userProgress = await loadProgressFromDB(user.id);
    } else {
      userProgress = { lessons: {}, streak: {} }; // Reset progress on logout
    }
    renderIndexUI();
    if (currentUser) {
        setupLessonButton();
    }
  }

  function init() {
    supabase.auth.onAuthStateChange((_event, session) => {
      handleAuthStateChange(session?.user || null);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
