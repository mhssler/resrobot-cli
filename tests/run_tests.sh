#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "=== Unit Tests ==="
bats unit/

if [[ -n "${RESROBOT_KEY:-}" ]]; then
    echo "=== Integration Tests ==="
    bats integration/
else
    echo "ERROR: Integration tests require RESROBOT_KEY" >&2
    exit 1
fi
