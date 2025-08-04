(function() {
  document.addEventListener('DOMContentLoaded', () => {
    const btn = document.getElementById('download-anki-all');
    if (!btn) return;

    btn.addEventListener('click', async () => {
      const original = btn.textContent;
      btn.textContent = 'Generando…';
      btn.disabled = true;
      btn.style.opacity = '0.7';

      try {
        const lang = localStorage.getItem('lang') || 'es';
        const sanitize = str => String(str || '').replace(/[\n\r,]/g, ' ').trim();
        const data = await fetch('/data/vocab.json').then(r => r.json());
        const order = Array.from({ length: 10 }, (_, i) => `lection${i + 1}`)
          .concat(window.cursoSlugs || []);
        const lines = [];
        const seen = new Set();

        order.forEach((lessonId, idx) => {
          const key = lessonId.startsWith('lection') ? lessonId.replace('lection', '') : lessonId;
          const items = data[key] || [];
          const title = (lessonId.startsWith('lection')
            ? `Lection ${lessonId.replace('lection', '')}`
            : lessonId.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join(' ')
          ).replace(/,/g, '');
          const deck = `Schola Interlingua::Lesson ${String(idx + 1).padStart(2, '0')} - ${title}`;

          items.forEach(entry => {
            if (!entry.term) return;
            const trans = sanitize(entry[lang]);
            if (!trans) return;
            const term = sanitize(entry.term);
            const line = `${term},${trans},${deck}`;
            if (!seen.has(line)) {
              lines.push(line);
              seen.add(line);
            }
          });
        });

        const blob = new Blob([lines.join('\n')], { type: 'text/plain;charset=utf-8' });
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = `anki_schola_interlingua_${lang}_all_lessons.txt`;
        a.click();
        URL.revokeObjectURL(a.href);
      } catch (e) {
        console.error('No se pudo generar el archivo Anki:', e);
      } finally {
        btn.disabled = false;
        btn.textContent = original;
        btn.style.opacity = '';
      }
    });
  });
})();
