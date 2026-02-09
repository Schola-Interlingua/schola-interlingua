(function (global) {
  function createSpeakButton(options = {}) {
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'speak-button';
    button.textContent = '🔊';
    button.setAttribute('aria-label', options.label || 'Reproducer audio');
    if (options.title) {
      button.title = options.title;
    }
    if (typeof options.onClick === 'function') {
      button.addEventListener('click', options.onClick);
    }
    return button;
  }

  global.SpeakButton = {
    create: createSpeakButton
  };
})(window);
