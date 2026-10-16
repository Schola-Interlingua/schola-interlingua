import { createHash } from 'node:crypto';
import { cp, readFile, writeFile } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// Only static informational pages come from public/. Flutter runtime files and
// course assets always come from the fresh compiler output.
export const staticEntries = ['about', 'privacy', 'terms', 'delete-account', 'robots.txt', 'sitemap.xml'];

export async function finalizeWebBuild({ repoDir, buildDir, flutterVersion, commit }) {
  const main = await readFile(path.join(buildDir, 'main.dart.js'));
  const index = await readFile(path.join(buildDir, 'index.html'), 'utf8');
  const bootstrap = await readFile(path.join(buildDir, 'flutter_bootstrap.js'), 'utf8');
  // Fail closed if Flutter changes its bootstrap format rather than publishing
  // a partial or stale application.
  if (!index.includes('src="flutter_bootstrap.js"') || !bootstrap.includes('"main.dart.js"')) {
    throw new Error('Unexpected Flutter bootstrap format');
  }
  const hash = createHash('sha256').update(main).digest('hex').slice(0, 20);
  const mainFile = `main.${hash}.dart.js`;
  await writeFile(path.join(buildDir, mainFile), main);
  await writeFile(path.join(buildDir, 'flutter_bootstrap.js'), bootstrap.replaceAll('"main.dart.js"', JSON.stringify(mainFile)));
  await writeFile(path.join(buildDir, 'index.html'), index.replace('src="flutter_bootstrap.js"', `src="flutter_bootstrap.js?v=${hash}"`));
  for (const entry of staticEntries) {
    await cp(path.join(repoDir, 'public', entry), path.join(buildDir, entry), { recursive: true });
  }
  const info = { commit, flutterVersion, builtAt: new Date().toISOString(), mainFile, mainSha256: createHash('sha256').update(main).digest('hex') };
  await writeFile(path.join(buildDir, 'build-info.json'), `${JSON.stringify(info, null, 2)}\n`);
  console.log(`Web build ready: ${commit} (${mainFile})`);
  return info;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const repoDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
  const commit = process.env.VERCEL_GIT_COMMIT_SHA || execFileSync('git', ['rev-parse', 'HEAD'], { cwd: repoDir, encoding: 'utf8' }).trim();
  await finalizeWebBuild({ repoDir, buildDir: path.join(repoDir, 'flutter_app', 'build', 'web'), flutterVersion: process.argv[2], commit });
}
