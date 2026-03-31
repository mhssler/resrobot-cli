#!/usr/bin/env bats

setup() {
  load '../helpers'
  export RESROBOT_KEY="test-key-123"
}

@test "resolve_stop: 9-digit number passes through" {
  run resolve_stop "740000002"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "740000002" ]]
}

@test "resolve_stop: 8-digit number triggers search" {
  mock_api_get "search-goteborg.json"
  run resolve_stop "74000000"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "740000002" ]]
}

@test "resolve_stop: name resolves to extId" {
  mock_api_get "search-goteborg.json"
  run resolve_stop "Göteborg Centralstation"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "740000002" ]]
}

@test "resolve_stop: no results returns error" {
  mock_api_get "error-no-results.json"
  run resolve_stop "Nonexistent Place"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"No stops found"* ]]
}
