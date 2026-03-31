#!/usr/bin/env bats

setup() {
  load '../helpers'
  export RESROBOT_KEY="test-key-123"
}

# Helper: mock curl to return a Nominatim fixture when called with nominatim URL
mock_nominatim() {
  _NOMINATIM_FIXTURE="$FIXTURES_DIR/$1"
  export _NOMINATIM_FIXTURE
  curl() {
    # If it's a Nominatim call, return fixture; otherwise call real curl
    if [[ "$*" == *"nominatim"* ]]; then
      cat "$_NOMINATIM_FIXTURE"
    fi
  }
  export -f curl
}

# --- resolve_address ---

@test "resolve_address: found address returns coords and Resolved line" {
  mock_nominatim "nominatim-kungsgatan.json"
  run resolve_address "Kungsgatan 12, Malmö"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"55.604981:13.003822"* ]]
  [[ "$output" == *"Resolved:"* ]]
  [[ "$output" == *"Kungsgatan"* ]]
}

@test "resolve_address: no results returns error" {
  mock_nominatim "nominatim-empty.json"
  run resolve_address "Hittepågatan 99, Umeå"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"No address found"* ]]
}

@test "resolve_address: network failure returns error" {
  curl() { return 1; }
  export -f curl
  run resolve_address "Kungsgatan 12, Malmö"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"failed"* ]]
}

# --- resolve_location ---

@test "resolve_location: stop name returns stop:ID" {
  mock_api_get "search-goteborg.json"
  run resolve_location "Göteborg"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "stop:740000002" ]]
}

@test "resolve_location: 9-digit ID passes through" {
  run resolve_location "740000002"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "stop:740000002" ]]
}

@test "resolve_location: address falls through to Nominatim" {
  # resolve_stop fails (no StopLocation), then resolve_address via Nominatim
  mock_api_get "error-no-results.json"
  mock_nominatim "nominatim-kungsgatan.json"
  run resolve_location "Kungsgatan 12, Malmö"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"coord:55.604981:13.003822"* ]]
}

# --- cmd_nearby with address ---

@test "cmd_nearby: address resolves via Nominatim and finds stops" {
  mock_nominatim "nominatim-kungsgatan.json"
  # After Nominatim resolves, api_get is called for nearbystops
  local _orig_api_get
  _orig_api_get=$(declare -f api_get)
  api_get() { cat "$FIXTURES_DIR/nearby-57-11.json"; }
  export -f api_get
  run cmd_nearby "Kungsgatan 12, Malmö"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Göteborg Centralstation"* ]]
}

@test "cmd_nearby: address not found shows error" {
  mock_nominatim "nominatim-empty.json"
  run cmd_nearby "Hittepågatan 99"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"No address found"* ]]
}
