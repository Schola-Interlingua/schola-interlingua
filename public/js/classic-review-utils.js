(function (global) {
  function normalize(text, options = {}) {
    const ignoreDiacritics = Boolean(options.ignoreDiacritics);
    let result = (text || '').trim().toLowerCase();
    result = result.replace(/\s+/g, ' ');
    result = result.replace(/[.!?]+$/g, '');
    if (ignoreDiacritics) {
      result = result.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }
    return result;
  }

  function splitAlternatives(text) {
    if (!text) return [];
    const parts = text
      .split(/[\/;]+/)
      .map(part => part.trim())
      .filter(Boolean);
    return [...new Set(parts)];
  }

  function isCorrect(userAnswer, correctAnswer, alternatives = [], options = {}) {
    const normalizedUser = normalize(userAnswer, options);
    if (!normalizedUser) return false;
    const normalizedCorrect = normalize(correctAnswer, options);
    if (normalizedUser === normalizedCorrect) return true;
    return alternatives.some(
      alt => normalize(alt, options) === normalizedUser
    );
  }

  function insertAtCursor(value, insertText, cursorStart, cursorEnd) {
    const start = Math.max(0, cursorStart ?? value.length);
    const end = Math.max(0, cursorEnd ?? value.length);
    const newValue = value.slice(0, start) + insertText + value.slice(end);
    const newCursor = start + insertText.length;
    return { value: newValue, cursor: newCursor };
  }

  function backspaceAtCursor(value, cursorStart, cursorEnd) {
    const start = Math.max(0, cursorStart ?? value.length);
    const end = Math.max(0, cursorEnd ?? value.length);
    if (start !== end) {
      const newValue = value.slice(0, start) + value.slice(end);
      return { value: newValue, cursor: start };
    }
    if (start === 0) {
      return { value, cursor: 0 };
    }
    const newValue = value.slice(0, start - 1) + value.slice(end);
    return { value: newValue, cursor: start - 1 };
  }

  const utils = {
    normalize,
    splitAlternatives,
    isCorrect,
    insertAtCursor,
    backspaceAtCursor
  };

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = utils;
  } else {
    global.ClassicReviewUtils = utils;
  }
})(typeof window !== 'undefined' ? window : globalThis);
