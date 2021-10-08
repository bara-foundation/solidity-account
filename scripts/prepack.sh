#!/usr/bin/env bash

set -euo pipefail
# shopt -s globstar

# cross platform `mkdir -p`
node -e 'fs.mkdirSync("build/contracts", { recursive: true })'

set -x;
find artifacts/contracts/ -type f -name '*.json' | xargs -I % sh -c 'cp % build/contracts'
rm build/contracts/*.dbg.json
set +x;

node scripts/remove-ignored-artifacts.js
