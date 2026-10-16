import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, mkdir, readFile, writeFile, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { finalizeWebBuild, staticEntries } from '../scripts/finalize_web_build.mjs';

async function fixture(t) {
  const repoDir = await mkdtemp(path.join(os.tmpdir(), 'schola-web-build-'));
  t.after(() => rm(repoDir, { recursive: true, force: true }));
  const buildDir = path.join(repoDir, 'flutter_app/build/web');
  await mkdir(buildDir, { recursive: true });
  await mkdir(path.join(repoDir, 'public'), { recursive: true });
  for (const name of staticEntries) {
    if (name.includes('.')) await writeFile(path.join(repoDir, 'public', name), name);
    else {
      await mkdir(path.join(repoDir, 'public', name));
      await writeFile(path.join(repoDir, 'public', name, 'index.html'), name);
    }
  }
  await writeFile(path.join(repoDir, 'public/main.dart.js'), 'old app');
  await writeFile(path.join(buildDir, 'main.dart.js'), 'new compiled app');
  await writeFile(path.join(buildDir, 'flutter_bootstrap.js'), '_flutter.buildConfig = {"mainJsPath":"main.dart.js"};');
  await writeFile(path.join(buildDir, 'index.html'), '<script src="flutter_bootstrap.js" async></script>');
  return { repoDir, buildDir, commit: 'reviewed-commit', flutterVersion: '3.44.7' };
}

test('deploys the new bundle, preserves informational pages and versions bootstrap by content', async t => {
  const options = await fixture(t);
  const info = await finalizeWebBuild(options);
  assert.equal(await readFile(path.join(options.buildDir, info.mainFile), 'utf8'), 'new compiled app');
  assert.equal(info.mainSha256, createHash('sha256').update('new compiled app').digest('hex'));
  assert.ok((await readFile(path.join(options.buildDir, 'flutter_bootstrap.js'), 'utf8')).includes(info.mainFile));
  assert.match(await readFile(path.join(options.buildDir, 'index.html'), 'utf8'), /flutter_bootstrap\.js\?v=[a-f0-9]{20}/);
  for (const entry of staticEntries.filter(e => !e.includes('.'))) {
    assert.equal(await readFile(path.join(options.buildDir, entry, 'index.html'), 'utf8'), entry);
  }
  assert.equal(JSON.parse(await readFile(path.join(options.buildDir, 'build-info.json'))).commit, options.commit);
});

test('fails instead of deploying if compilation output is incomplete', async t => {
  const options = await fixture(t);
  await rm(path.join(options.buildDir, 'main.dart.js'));
  await assert.rejects(finalizeWebBuild(options), { code: 'ENOENT' });
});

test('fails if an SDK change breaks the bootstrap integration', async t => {
  const options = await fixture(t);
  await writeFile(path.join(options.buildDir, 'flutter_bootstrap.js'), 'unexpected format');
  await assert.rejects(finalizeWebBuild(options), /Unexpected Flutter bootstrap format/);
});
