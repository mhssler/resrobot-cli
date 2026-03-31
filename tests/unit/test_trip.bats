#!/usr/bin/env bats

setup() {
  load '../helpers'
  export RESROBOT_KEY="test-key-123"
}

@test "cmd_trip: normal trip formatted" {
  # Mock resolve_stop to pass through IDs, api_get returns trip fixture
  api_get() {
    if [[ "$1" == "/trip" ]]; then
      cat "$FIXTURES_DIR/trip-goteborg-malmo.json"
    else
      cat "$FIXTURES_DIR/search-goteborg.json"
    fi
  }
  export -f api_get
  run cmd_trip 740000002 740000003
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Trip 1"* ]]
  [[ "$output" == *"45min"* ]]
  [[ "$output" == *"1 transfer"* ]]
  [[ "$output" == *"Regional Tåg 43"* ]]
}

@test "cmd_trip: --json returns raw JSON" {
  mock_api_get "trip-goteborg-malmo.json"
  run cmd_trip --json 740000002 740000003
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.Trip' >/dev/null
}

@test "cmd_trip: missing args shows usage" {
  run cmd_trip 740000002
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "cmd_trip: no args shows usage" {
  run cmd_trip
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "cmd_trip: no trips found" {
  api_get() { echo '{"Trip": []}'; }
  export -f api_get
  run cmd_trip 740000002 740000003
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"No trips found"* ]]
}
