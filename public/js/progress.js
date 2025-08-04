(function(){
  const STORAGE_KEY = 'si_progress';
  const TOTAL_LESSONS = 43;
  const LESSON_ORDER = Array.from({length:10}, (_,i)=>`lection${i+1}`)
    .concat(window.cursoSlugs || []);

  function storageAvailable(){
    try{
      const test='__test__';
      localStorage.setItem(test,test);
      localStorage.removeItem(test);
      return true;
    }catch(e){
      console.log('localStorage no disponible');
      return false;
    }
  }

  function defaultProgress(){
    return {lessons:{}, streak:{current:0,best:0,last_study_date:null}};
  }

  function loadProgress(){
    try{
      const data = localStorage.getItem(STORAGE_KEY);
      return data ? JSON.parse(data) : defaultProgress();
    }catch(e){
      return defaultProgress();
    }
  }

  function saveProgress(p){
    localStorage.setItem(STORAGE_KEY, JSON.stringify(p));
  }

  function updateStreak(progress, today){
    const streak = progress.streak || {current:0,best:0,last_study_date:null};
    if(!streak.last_study_date){
      streak.current = 1;
    }else{
      const last = new Date(streak.last_study_date);
      const curr = new Date(today);
      const diff = Math.floor((curr - last)/86400000);
      if(diff === 1){
        streak.current += 1;
      }else if(diff > 1){
        streak.current = 1;
      }
      // diff === 0 => no cambio
    }
    streak.last_study_date = today;
    if(streak.current > (streak.best||0)) streak.best = streak.current;
    progress.streak = streak;
  }

  function formatLesson(id){
    if(id.startsWith('lection')) return id.replace('lection','');
    return id.split('-').map(s=>s.charAt(0).toUpperCase()+s.slice(1)).join(' ');
  }

  // Index rendering
  function renderIndex(){
    const section = document.getElementById('progress-section');
    if(!section) return;
    if(!storageAvailable()){
      section.textContent = 'Progreso no se puede guardar';
      return;
    }
    const progress = loadProgress();
    const lessons = progress.lessons || {};
    const completed = Object.values(lessons).filter(l=>l.completed).length;
    const percent = TOTAL_LESSONS ? Math.round((completed/TOTAL_LESSONS)*100) : 0;

    const noProgress = section.querySelector('#no-progress-msg');
    const details = section.querySelector('#progress-details');
    if(completed === 0){
      noProgress.style.display = 'block';
    }else{
      noProgress.style.display = 'none';
    }
    details.style.display = 'block';

    section.querySelector('#completion-text').textContent = `${percent}% (${completed}/${TOTAL_LESSONS})`;
    section.querySelector('#completion-bar').style.width = percent + '%';

    const current = progress.streak?.current || 0;
    const best = progress.streak?.best || 0;
    section.querySelector('#streak-current').textContent = `${current} días seguidos`;
    section.querySelector('#streak-best').textContent = `Mejor racha: ${best} días`;

    const next = LESSON_ORDER.find(id => !(lessons[id] && lessons[id].completed));
    const nextEl = section.querySelector('#next-lesson');
    if(next){
      nextEl.textContent = `Seguí con la Lección ${formatLesson(next)}`;
    }else{
      nextEl.textContent = '';
    }
  }

  function exportProgress(){
    const data = localStorage.getItem(STORAGE_KEY);
    if(!data){ alert('No hay progreso para exportar'); return; }
    const blob = new Blob([data], {type:'application/json'});
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'si_progress.json';
    a.click();
    URL.revokeObjectURL(a.href);
  }

  function importProgress(){
    const json = prompt('Pegá tu progreso en JSON:');
    if(!json) return;
    try{
      const parsed = JSON.parse(json);
      localStorage.setItem(STORAGE_KEY, JSON.stringify(parsed));
      renderIndex();
    }catch(e){
      alert('JSON inválido');
    }
  }

  // Lesson page button
  function setupLesson(){
    const container = document.getElementById('exercise-container');
    if(!container) return;

    const wrap = document.createElement('div');
    wrap.className = 'lesson-progress-wrapper';
    container.insertAdjacentElement('afterend', wrap);

    if(!storageAvailable()){
      wrap.textContent = 'Progreso no se puede guardar';
      return;
    }

    const lessonId = container.dataset.lesson || location.pathname.split('/').pop().replace('.html','');

    const btn = document.createElement('button');
    btn.id = 'lesson-progress-btn';
    const info = document.createElement('div');
    info.id = 'lesson-progress-info';
    wrap.appendChild(btn);
    wrap.appendChild(info);

    function refresh(){
      const progress = loadProgress();
      const data = progress.lessons[lessonId];
      if(data && data.completed){
        btn.textContent = 'Rehacer lección';
        info.textContent = `Última vez: ${data.last_done}`;
      }else{
        btn.textContent = 'Marcar lección como hecha';
        info.textContent = '';
      }
    }

    btn.addEventListener('click', () => {
      const progress = loadProgress();
      const today = new Date().toISOString().slice(0,10);
      const data = progress.lessons[lessonId];
      if(data && data.completed){
        delete progress.lessons[lessonId];
      }else{
        progress.lessons[lessonId] = {completed:true, last_done: today};
        updateStreak(progress, today);
      }
      saveProgress(progress);
      refresh();
    });

    refresh();
  }

  function init(){
    if(!storageAvailable()){
      const section = document.getElementById('progress-section');
      if(section) section.textContent = 'Progreso no se puede guardar';
      return;
    }
    renderIndex();
    setupLesson();
    const exportBtn = document.getElementById('export-progress');
    const importBtn = document.getElementById('import-progress');
    if(exportBtn) exportBtn.addEventListener('click', exportProgress);
    if(importBtn) importBtn.addEventListener('click', importProgress);
  }

  if(document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', init);
  }else{
    init();
  }

  window.addEventListener('storage', (e) => {
    if(e.key === STORAGE_KEY) renderIndex();
  });
})();
