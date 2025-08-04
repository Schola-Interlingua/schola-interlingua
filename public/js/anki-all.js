(function() {
  document.addEventListener('DOMContentLoaded', () => {
    const btn = document.getElementById('download-anki-all');
    if (!btn) return;

    btn.addEventListener('click', async () => {
      const lang = localStorage.getItem('lang') || 'es';
      const sanitize = str => str.replace(/[\t\n,]/g, ' ');
      const data = await fetch('/data/vocab.json').then(r => r.json());
      const lines = [];

      Object.keys(data).forEach(lessonId => {
        (data[lessonId] || []).forEach(entry => {
          if (!entry.term) return;
          const trans = entry[lang];
          if (!trans) return;
          const term = sanitize(entry.term);
          const translation = sanitize(trans);
          lines.push(`${term},${translation},Lesson${lessonId}`);
        });
      });

      const blob = new Blob([lines.join('\n')], { type: 'text/plain;charset=utf-8' });
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = `anki_schola_interlingua_${lang}_all_lessons.txt`;
      a.click();
      URL.revokeObjectURL(a.href);
    });
  });
})();

