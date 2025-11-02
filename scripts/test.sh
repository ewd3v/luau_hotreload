#!/usr/bin/env bash
set -euo pipefail

pesde x ewdev/multitarget -- build --yes \
    --build-files src tests --output dist_test \
    --global RUNTIME --require-mode luau \
    --lune # Runtimes to run tests on

cd dist_test

# TODO: Move different runtime tests into different workflow jobs

if [ -d luau ]; then
    echo "Running Luau tests..."
    cd luau
    luau tests/init.luau
    cd ..
fi

if [ -d lune ]; then
    echo "Running Lune tests..."
    cd lune
    lune run tests/init.luau
    cd ..
fi

if [ -d roblox ]; then
    echo "Running Roblox tests..."
    echo "Tests currently don't run on Roblox"
    exit 1
fi

echo "All runtime tests finished without issues!"