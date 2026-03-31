#!/usr/bin/env bash
# Shared test helpers for resrobot bats tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../src" && pwd)"
FIXTURES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/fixtures" && pwd)"
export FIXTURES_DIR

# Source the script (functions only, main won't run due to source guard)
source "$SCRIPT_DIR/resrobot"

# Load a fixture file and return its contents
load_fixture() {
    cat "$FIXTURES_DIR/$1"
}

# Mock api_get to return fixture data instead of calling curl
# Usage: mock_api_get "fixture-file.json"
mock_api_get() {
    _MOCK_API_FIXTURE="$FIXTURES_DIR/$1"
    export _MOCK_API_FIXTURE
    api_get() {
        cat "$_MOCK_API_FIXTURE"
    }
    export -f api_get
}
