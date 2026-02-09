const assert = require('assert');
const {
  normalize,
  splitAlternatives,
  isCorrect,
  insertAtCursor,
  backspaceAtCursor
} = require('../public/js/classic-review-utils.js');

assert.strictEqual(normalize(' Hola. '), 'hola');
assert.strictEqual(normalize('¿Qué tal?  '), '¿qué tal');
assert.strictEqual(normalize('Hola   mundo!!'), 'hola mundo');

assert.deepStrictEqual(splitAlternatives('ser / estar'), ['ser', 'estar']);
assert.deepStrictEqual(splitAlternatives('uno; dos; tres'), [
  'uno',
  'dos',
  'tres'
]);

assert.strictEqual(isCorrect('Ser', 'ser', []), true);
assert.strictEqual(isCorrect('estar', 'ser', ['estar']), true);
assert.strictEqual(isCorrect('otra', 'ser', ['estar']), false);

let result = insertAtCursor('hola', 'y', 2, 2);
assert.strictEqual(result.value, 'hoyla');
assert.strictEqual(result.cursor, 3);

result = insertAtCursor('hola', 'yo', 1, 3);
assert.strictEqual(result.value, 'hyoa');
assert.strictEqual(result.cursor, 3);

result = backspaceAtCursor('hola', 2, 2);
assert.strictEqual(result.value, 'hla');
assert.strictEqual(result.cursor, 1);

result = backspaceAtCursor('hola', 1, 3);
assert.strictEqual(result.value, 'ha');
assert.strictEqual(result.cursor, 1);

console.log('classic-review-utils tests passed');
