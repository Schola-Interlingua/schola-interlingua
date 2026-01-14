import { supabase } from './supabase.js';

(function () {
  const STORAGE_KEY = 'si_progress';
  const TOTAL_LESSONS = 43;
  const LESSON_ORDER = Array.from({ length: 10 }, (_, i) => `lection${i + 1}`)
    .concat(window.cursoSlugs || []);

  let currentUser = null;

  /* ---------------- Utils ---------------- */

  function storageAvailable() {
    try {
      const test = '__test__';
      localStorage.setItem(test, test);
      localStorage.removeItem(test);
      return true;
    } catch {
      return false;
    }
  }

  function defaultProgress() {
    return { lessons: {}, streak: { current: 0, best: 0, last_study_date: null } };
  }

  /* ---------------- DB ---------------- */

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

    await supabase
      .from('progress')
      .upsert(
        { user_id: currentUser.id, data: progress },
        { onConflict: 'user_id' }
      );
  }

  /* ---------------- Storage ---------------- */

  async function loadProgress() {
    if (currentUser) return await loadProgressFromDB(currentUser.id);

    try {
      const data = localStorage.getItem(STORAGE_KEY);
      return data ? JSON.parse(data) : defaultProgress();
    } catch {
      return defaultProgress();
    }
  }

  async function saveProgress(progress) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
    if (currentUser) await saveProgressToDB(progress);
  }

  /* ---------------- Streak ---------------- */

  function updateStreak(progress, today) {
    const streak = progress.streak || { current: 0, best: 0, last_study_date: null };

    if (!streak.last_study_date) {
      streak.current = 1;
    } else {
      const diff =
        (new Date(today) - new Date(streak.last_study_date)) / 86400000;

      if (diff === 1) streak.current++;
      else if (diff > 1) streak.current = 1;
    }

    streak.last_study_date = today;
    streak.best = Math.max(streak.best || 0, streak.current);
    progress.streak = streak;
  }

  function formatLesson(id) {
    if (id.startsWith('lection')) return id.replace('lection', '');
    return id.replace(/-/g, ' ');
  }

  /* ---------------- Index ---------------- */

  async function renderIndex() {
    const section = document.getElementById('progress-section');
    if (!section) return;

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
    const percent = Math.round((completed / TOTAL_LESSONS) * 100);

    section.querySelector('#completion-text').textContent =
      `${percent}% (${completed}/${TOTAL_LESSONS})`;
    section.querySelector('#completion-bar').style.width = percent + '%';

    section.querySelector('#streak-current').textContent =
      `${progress.streak.current} dies consecutive`;
    section.querySelector('#streak-best').textContent =
      `Melior serie: ${progress.streak.best} dies`;

    const next = LESSON_ORDER.find(id => !lessons[id]?.completed);
    const nextEl = section.querySelector('#next-lesson');
    nextEl.textContent = next
      ? `Continua con le lection ${formatLesson(next)}`
      : '';
  }

  /* ---------------- Lesson ---------------- */

  function setupLesson() {
    if (!currentUser) return;
    if (document.querySelector('.lesson-progress-wrapper')) return;

    const container = document.getElementById('exercise-container');
    if (!container) return;

    const lessonId =
      container.dataset.lesson ||
      location.pathname.split('/').pop().replace('.html', '');

    /* Message */
    let completionMessage = document.getElementById('completion-message');
    if (!completionMessage) {
      completionMessage = document.createElement('div');
      completionMessage.id = 'completion-message';
      completionMessage.textContent = 'Le lection es complete!';
      completionMessage.style.cssText =
        'display:none;background:#d4edda;color:#155724;padding:10px;text-align:center;font-weight:bold;';

      const nav = document.querySelector('nav');
      if (nav) nav.after(completionMessage);
    }

    /* Button */
    const wrap = document.createElement('div');
    wrap.className = 'lesson-progress-wrapper';

    const btn = document.createElement('button');
    btn.id = 'lesson-progress-btn';
    btn.className = 'btn btn-primary';

    const info = document.createElement('div');
    info.id = 'lesson-progress-info';

    wrap.append(btn, info);
    container.after(wrap);

    async function refresh() {
      const progress = await loadProgress();
      const data = progress.lessons[lessonId];

      if (data?.completed) {
        btn.textContent = 'Refacer le lection';
        info.textContent = `Ultime vice: ${data.last_done}`;
        completionMessage.style.display = 'block';
      } else {
        btn.textContent = 'Marcar le lection como facte';
        info.textContent = '';
        completionMessage.style.display = 'none';
      }
    }

    btn.onclick = async () => {
      const progress = await loadProgress();
      const today = new Date().toISOString().slice(0, 10);

      if (progress.lessons[lessonId]?.completed) {
        delete progress.lessons[lessonId];
      } else {
        progress.lessons[lessonId] = { completed: true, last_done: today };
        updateStreak(progress, today);
      }

      await saveProgress(progress);
      refresh();
    };

    refresh();
  }

  /* ---------------- Init ---------------- */

  async function init() {
    if (!storageAvailable()) return;

    const { data: { session } } = await supabase.auth.getSession();
    currentUser = session?.user ?? null;

    if (currentUser) {
      const dbProgress = await loadProgressFromDB(currentUser.id);
      localStorage.setItem(STORAGE_KEY, JSON.stringify(dbProgress));
    }

    await renderIndex();
    setupLesson();

    supabase.auth.onAuthStateChange(async (_e, session) => {
      currentUser = session?.user ?? null;

      if (currentUser) {
        const dbProgress = await loadProgressFromDB(currentUser.id);
        localStorage.setItem(STORAGE_KEY, JSON.stringify(dbProgress));
      }

      await renderIndex();
      setupLesson();
    });
  }

  document.readyState === 'loading'
    ? document.addEventListener('DOMContentLoaded', init)
    : init();

})();
