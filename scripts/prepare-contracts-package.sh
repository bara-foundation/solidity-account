#!/usr/bin/env bash

# cd to the root of the repo
cd "$(git rev-parse --show-toplevel)"

# avoids re-compilation during publishing of both packages
# if [ ! -z "${ALREADY_COMPILED}"]; then
#   echo "Compiled, skip do it again!"
# else
  # npm run clean
  # npm run prepare
  # npm run prepack
# fi

# Move artifacts
set -x;
cp README.md contracts/
mkdir -p contracts/build/{contracts,dist}
cp -r build/contracts/*.json contracts/build/contracts
set +x;
# cp -r dist/typechain/* contracts/build/typechain
