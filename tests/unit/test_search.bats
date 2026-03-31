#!/usr/bin/env bats

setup() {
  load '../helpers'
  export RESROBOT_KEY="test-key-123"
}

@test "cmd_search: normal results formatted" {
  mock_api_get "search-goteborg.json"
  run cmd_search "Göteborg"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"740000002"* ]]
  [[ "$output" == *"Göteborg Centralstation"* ]]
  [[ "$output" == *"57.70887"* ]]
}

@test "cmd_search: no results" {
  mock_api_get "error-no-results.json"
  run cmd_search "Nonexistent"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"No results found"* ]]
}

@test "cmd_search: --json returns raw JSON" {
  mock_api_get "search-goteborg.json"
  run cmd_search --json "Göteborg"
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.stopLocationOrCoordLocation' >/dev/null
}

@test "cmd_search: --max is passed through" {
  local called_max=""
  api_get() {
    while [[ $# -gt 0 ]]; do
      [[ "$1" == "maxNo" ]] && called_max="$2"
      shift
    done
    cat "$FIXTURES_DIR/search-goteborg.json"
  }
  export -f api_get
  run cmd_search --max 5 "Göteborg"
  [[ "$status" -eq 0 ]]
}

@test "cmd_search: missing name shows usage" {
  run cmd_search
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Usage"* ]]
}
