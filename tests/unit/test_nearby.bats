#!/usr/bin/env bats

setup() {
  load '../helpers'
  export RESROBOT_KEY="test-key-123"
}

@test "cmd_nearby: normal results formatted" {
  mock_api_get "nearby-57-11.json"
  run cmd_nearby 57.7089 11.9733
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"740000002"* ]]
  [[ "$output" == *"Göteborg Centralstation"* ]]
  [[ "$output" == *"120m"* ]]
}

@test "cmd_nearby: --json returns raw JSON" {
  mock_api_get "nearby-57-11.json"
  run cmd_nearby --json 57.7089 11.9733
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.stopLocationOrCoordLocation' >/dev/null
}

@test "cmd_nearby: no results" {
  mock_api_get "error-no-results.json"
  run cmd_nearby 0.0 0.0
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"No stops found nearby"* ]]
}

@test "cmd_nearby: missing args shows usage" {
  run cmd_nearby 57.7089
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "cmd_nearby: no args shows usage" {
  run cmd_nearby
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Usage"* ]]
}

@test "cmd_nearby: --help shows GDPR note" {
  run cmd_nearby --help
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"GDPR"* ]]
}
