#!/usr/bin/env bash
set -euo pipefail

pesde x ewdev/multitarget -- build --yes \
    --build-files src --output dist \
    --global RUNTIME --require-mode luau \
    --luau --roblox # Runtimes to build for

sed -i -e \
    "s/build_files = \[\"src\"\]/build_files = \[\"src\", \"fiu\/Source.lua\"\]/" \
    dist/roblox/pesde.toml