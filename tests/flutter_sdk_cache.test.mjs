import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, mkdir, copyFile, writeFile, readFile, rm } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import os from 'node:os';
import path from 'node:path';

const revision = '84fc5cbb223bc12f83d65b647ff8a56caf779ffd';

for (const state of ['missing', 'valid', 'wrong revision', 'missing git metadata']) {
  test(`Flutter SDK cache: ${state}`, async t => {
    const root = await mkdtemp(path.join(os.tmpdir(), 'schola-sdk-cache-'));
    t.after(() => rm(root, { recursive: true, force: true }));
    await mkdir(path.join(root, 'scripts'));
    await copyFile(new URL('../scripts/build_web.sh', import.meta.url), path.join(root, 'scripts/build_web.sh'));
    const sdk = path.join(root, 'node_modules/.cache/schola-flutter-3.44.7');
    if (state !== 'missing') {
      await mkdir(path.join(sdk, 'bin'), { recursive: true });
      // Stop at SDK bootstrap; this test must never build or download Flutter.
      await writeFile(path.join(sdk, 'bin/flutter'), '#!/bin/sh\nexit 73\n', { mode: 0o755 });
      if (state !== 'missing git metadata') {
        await mkdir(path.join(sdk, '.git'));
        await writeFile(path.join(sdk, '.git/HEAD'), state === 'valid' ? revision : 'old-sdk');
      }
    }
    const bin = path.join(root, 'test-bin');
    await mkdir(bin);
    await writeFile(path.join(bin, 'git'), `#!/usr/bin/env node
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
if (args[0] === 'clone') {
  const sdk = args.at(-1);
  fs.mkdirSync(path.join(sdk, '.git'), {recursive:true});
  fs.mkdirSync(path.join(sdk, 'bin'), {recursive:true});
  fs.writeFileSync(path.join(sdk, '.git/HEAD'), '${revision}');
  fs.writeFileSync(path.join(sdk, 'bin/flutter'), '#!/bin/sh\\nexit 73\\n', {mode:0o755});
  fs.writeFileSync(path.join(sdk, 'installed-for-test'), 'yes');
} else if (args[0].startsWith('--git-dir=')) {
  process.stdout.write(fs.readFileSync(path.join(args[0].slice(10), 'HEAD')));
} else {
  // A parent app revision must never be accepted as the SDK's revision.
  process.stdout.write('application-commit');
}
`, { mode: 0o755 });
    const env = { ...process.env, PATH: `${bin}${path.delimiter}${process.env.PATH}` };
    delete env.SCHOLA_FLUTTER_BIN;
    const result = spawnSync('bash', [path.join(root, 'scripts/build_web.sh')], { env, encoding: 'utf8' });
    assert.equal(result.status, 73, result.stderr + result.stdout);
    assert.equal(await readFile(path.join(sdk, '.git/HEAD'), 'utf8'), revision);
    if (state === 'valid') {
      await assert.rejects(readFile(path.join(sdk, 'installed-for-test')), { code: 'ENOENT' });
    } else {
      assert.equal(await readFile(path.join(sdk, 'installed-for-test'), 'utf8'), 'yes');
    }
  });
}
