document.addEventListener('DOMContentLoaded', () => {
  const card = document.querySelector('main .card');
  if (!card) return;
  const textBlock = card.querySelector('.text-block');
  if (!textBlock) return;
  if (!window.SpeakButton) return;

  const container = document.createElement('div');
  container.className = 'lesson-audio';

  const button = window.SpeakButton.create({
    label: 'Reproducer lection',
    title: 'Reproducer lection',
    onClick: async () => {
      if (!window.TTS) return;
      await window.TTS.speak(textBlock.textContent, { lang: 'ia' });
    }
  });

  container.appendChild(button);

  const heading = card.querySelector('h2');
  if (heading) {
    heading.insertAdjacentElement('afterend', container);
  } else {
    card.prepend(container);
  }
});
