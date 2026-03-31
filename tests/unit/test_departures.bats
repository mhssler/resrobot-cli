#!/usr/bin/env bats

setup() {
  load '../helpers'
  export RESROBOT_KEY="test-key-123"
  mock_api_get "departures-740000002.json"
}

@test "cmd_departures: by ID shows formatted output" {
  run cmd_departures 740000002
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"15:23"* ]]
  [[ "$output" == *"Buss 16"* ]]
  [[ "$output" == *"→ Eriksberg"* ]]
}

@test "cmd_departures: by name resolves stop" {
  # resolve_stop will call api_get for name lookup, then cmd_departures calls it again
  local call_count=0
  api_get() {
    call_count=$((call_count + 1))
    if [[ "$1" == "/location.name" ]]; then
      cat "$FIXTURES_DIR/search-goteborg.json"
    else
      cat "$FIXTURES_DIR/departures-740000002.json"
    fi
  }
  export -f api_get
  run cmd_departures "Göteborg Centralstation"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"15:23"* ]]
}

@test "cmd_departures: --json returns raw JSON" {
  run cmd_departures --json 740000002
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.Departure' >/dev/null
}

@test "cmd_departures: --date and --time passed through" {
  run cmd_departures --date 2026-04-01 --time 08:00 740000002
  [[ "$status" -eq 0 ]]
}

@test "cmd_departures: missing arg shows usage" {
  run cmd_departures
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "cmd_departures: no departures" {
  api_get() { echo '{"Departure": []}'; }
  export -f api_get
  run cmd_departures 740000002
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"No departures found"* ]]
}
