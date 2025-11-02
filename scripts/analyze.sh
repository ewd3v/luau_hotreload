#!/usr/bin/env bash
set -euo pipefail

lune setup

selene \
    --no-summary \
    src tests

luau-lsp analyze \
    --platform=standard \
    --settings=".vscode/settings.json" \
    src tests