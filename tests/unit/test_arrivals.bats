#!/usr/bin/env bats

setup() {
  load '../helpers'
  export RESROBOT_KEY="test-key-123"
  mock_api_get "arrivals-740000002.json"
}

@test "cmd_arrivals: by ID shows formatted output" {
  run cmd_arrivals 740000002
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"15:18"* ]]
  [[ "$output" == *"Regional Tåg 21"* ]]
  [[ "$output" == *"← Stockholm C"* ]]
}

@test "cmd_arrivals: --json returns raw JSON" {
  run cmd_arrivals --json 740000002
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.Arrival' >/dev/null
}

@test "cmd_arrivals: missing arg shows usage" {
  run cmd_arrivals
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "cmd_arrivals: no arrivals" {
  api_get() { echo '{"Arrival": []}'; }
  export -f api_get
  run cmd_arrivals 740000002
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"No arrivals found"* ]]
}
