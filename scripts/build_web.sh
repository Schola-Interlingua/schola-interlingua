#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly flutter_version='3.44.7'
readonly flutter_revision='84fc5cbb223bc12f83d65b647ff8a56caf779ffd'
cd "$repo_dir"

# Vercel caches node_modules across builds. The SDK is a pinned tool dependency,
# never a source of prebuilt application files.
if [[ -n "${SCHOLA_FLUTTER_BIN:-}" ]]; then
  flutter_bin="$SCHOLA_FLUTTER_BIN"
else
  sdk_dir="$repo_dir/node_modules/.cache/schola-flutter-$flutter_version"
  # Restored caches can omit the SDK's .git directory. Never let Git walk up
  # and mistake the application's revision for the Flutter revision.
  cached_revision=''
  if [[ -d "$sdk_dir/.git" ]]; then
    cached_revision="$(git --git-dir="$sdk_dir/.git" rev-parse HEAD 2>/dev/null || true)"
  fi
  if [[ ! -x "$sdk_dir/bin/flutter" || "$cached_revision" != "$flutter_revision" ]]; then
    echo 'Installing the pinned Flutter SDK (cache missing or incompatible).'
    rm -rf -- "$sdk_dir"
    mkdir -p "$(dirname "$sdk_dir")"
    git clone --depth 1 --branch "$flutter_version" https://github.com/flutter/flutter.git "$sdk_dir"
  fi
  if [[ "$(git --git-dir="$sdk_dir/.git" rev-parse HEAD)" != "$flutter_revision" ]]; then
    echo 'Cached Flutter SDK does not match the pinned revision.' >&2
    exit 1
  fi
  flutter_bin="$sdk_dir/bin/flutter"
fi

export CI=true
export FLUTTER_SUPPRESS_ANALYTICS=true
# A fresh SDK prints download progress to stdout during its first invocation.
# Bootstrap separately so --machine below contains only JSON.
"$flutter_bin" --version
"$flutter_bin" --version --machine | node -e '
let input = "";
process.stdin.on("data", chunk => input += chunk);
process.stdin.on("end", () => {
  const sdk = JSON.parse(input);
  if (sdk.frameworkRevision !== process.argv[1]) {
    throw new Error("Use the pinned Flutter SDK for this build");
  }
  console.log(`Building with Flutter ${sdk.frameworkVersion}`);
});' "$flutter_revision"

cd "$repo_dir/flutter_app"
"$flutter_bin" pub get --enforce-lockfile
"$flutter_bin" analyze --no-pub
"$flutter_bin" test --no-pub
# Never fall back to the old checked-in public/ bundle on a failed compilation.
rm -rf -- "$repo_dir/flutter_app/build/web"
"$flutter_bin" build web --release --no-pub
cd "$repo_dir"
node --test tests/web_build.test.mjs tests/flutter_sdk_cache.test.mjs
node scripts/finalize_web_build.mjs "$flutter_version"
