import { supabase } from './supabase.js';

(function () {

  /* ---------------- CONFIG ---------------- */

  const TOTAL_LESSONS = 43;

  const LESSON_ORDER = [
    ...Array.from({ length: 10 }, (_, i) => `lection${i + 1}`),
    ...(window.cursoSlugs ?? [])
  ];

  let currentUser = null;

  let userProgress = {
    lessons: {},
    streak: {
      current: 0,
      best: 0,
      last_study_date: null
    }
  };

  /* ---------------- DB ---------------- */

  async function loadProgressFromDB(userId) {
    const { data, error } = await supabase
      .from('progress')
      .select('data')
      .eq('user_id', userId)
      .single();

    if (error && error.code !== 'PGRST116') {
      console.error('❌ Error cargando progreso:', error);
      return emptyProgress();
    }

    return data?.data ?? emptyProgress();
  }

  async function saveProgressToDB() {
    if (!currentUser) return;

    const { error } = await supabase
      .from('progress')
      .upsert(
        {
          user_id: currentUser.id,
          data: userProgress
        },
        { onConflict: 'user_id' }
      );

    if (error) {
      console.error('❌ Error guardando progreso:', error);
    }
  }

  function emptyProgress() {
    return {
      lessons: {},
      streak: { current: 0, best: 0, last_study_date: null }
    };
  }

  /* ---------------- STREAK ---------------- */

  function updateStreak(today) {
    const streak = userProgress.streak ?? {
      current: 0,
      best: 0,
      last_study_date: null
    };

    if (!streak.last_study_date) {
      streak.current = 1;
    } else {
      const last = new Date(streak.last_study_date);
      const curr = new Date(today);
      const diff = Math.floor((curr - last) / 86400000);

      if (diff === 1) streak.current++;
      else if (diff > 1) streak.current = 1;
    }

    streak.last_study_date = today;
    streak.best = Math.max(streak.best, streak.current);

    userProgress.streak = streak;
  }

  /* ---------------- HELPERS ---------------- */

  function formatLesson(id) {
    if (!id) return '';
    if (id.startsWith('lection')) return id.replace('lection', '');
    return id
      .split('-')
      .map(s => s.charAt(0).toUpperCase() + s.slice(1))
      .join(' ');
  }

  /* ---------------- INDEX UI ---------------- */

  function renderIndexUI() {
    const section = document.getElementById('progress-section');
    if (!section) return;

    if (!currentUser) {
      section.innerHTML = `
        <h2>Tu progresso</h2>
        <p class="no-tooltip">
          Ingresar para guardar y visualizar tu progresso
        </p>
      `;
      return;
    }

    const lessons = userProgress.lessons ?? {};
    const completed = Object.values(lessons).filter(l => l.completed).length;
    const percent = Math.round((completed / TOTAL_LESSONS) * 100);

    const completionText = section.querySelector('#completion-text');
    const completionBar = section.querySelector('#completion-bar');
    const streakCurrent = section.querySelector('#streak-current');
    const streakBest = section.querySelector('#streak-best');
    const nextLesson = section.querySelector('#next-lesson');

    if (completionText) {
      completionText.textContent = `${percent}% (${completed}/${TOTAL_LESSONS})`;
    }

    if (completionBar) {
      completionBar.style.width = percent + '%';
    }

    if (streakCurrent) {
      streakCurrent.textContent = `${userProgress.streak.current} dies consecutive`;
    }

    if (streakBest) {
      streakBest.textContent = `Melior serie: ${userProgress.streak.best} dies`;
    }

    if (nextLesson) {
      const next = LESSON_ORDER.find(id => !lessons[id]?.completed);
      nextLesson.textContent = next
        ? `Continua con le lection ${formatLesson(next)}`
        : '';
    }
  }

  /* ---------------- LESSON PAGE ---------------- */

  function setupLessonButton() {
    const container = document.getElementById('exercise-container');
    if (!container || !currentUser) return;

    const lessonId =
      container.dataset.lesson ??
      location.pathname.split('/').pop().replace('.html', '');

    if (document.getElementById('lesson-progress-btn')) return;

    const wrap = document.createElement('div');
    wrap.className = 'lesson-progress-wrapper';
    container.insertAdjacentElement('afterend', wrap);

    const btn = document.createElement('button');
    btn.id = 'lesson-progress-btn';
    btn.className = 'btn btn-primary';

    const info = document.createElement('div');
    info.id = 'lesson-progress-info';

    wrap.append(btn, info);

    function refresh() {
      const data = userProgress.lessons[lessonId];
      if (data?.completed) {
        btn.textContent = 'Refacer le lection';
        info.textContent = `Ultime vice: ${data.last_done}`;
      } else {
        btn.textContent = 'Marcar le lection como facte';
        info.textContent = '';
      }
    }

    btn.addEventListener('click', async () => {
      const today = new Date().toISOString().slice(0, 10);

      if (userProgress.lessons[lessonId]?.completed) {
        delete userProgress.lessons[lessonId];
      } else {
        userProgress.lessons[lessonId] = {
          completed: true,
          last_done: today
        };
        updateStreak(today);
      }

      await saveProgressToDB();
      refresh();
      renderIndexUI();
    });

    refresh();
  }

  /* ---------------- AUTH ---------------- */

  function init() {
    supabase.auth.onAuthStateChange(async (_event, session) => {
      currentUser = session?.user ?? null;

      if (currentUser) {
        userProgress = await loadProgressFromDB(currentUser.id);
        setupLessonButton();
      } else {
        userProgress = emptyProgress();
      }

      renderIndexUI();
    });
  }

  document.readyState === 'loading'
    ? document.addEventListener('DOMContentLoaded', init)
    : init();

})();
