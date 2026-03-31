#!/usr/bin/env bats

setup() {
  load '../helpers'
}

@test "check_deps passes when curl and jq are available" {
  run check_deps
  [[ "$status" -eq 0 ]]
}

@test "check_deps fails when curl is missing" {
  # Override command to hide curl
  command() {
    [[ "$2" == "curl" ]] && return 1
    builtin command "$@"
  }
  export -f command
  run check_deps
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"curl is required"* ]]
}

@test "check_deps fails when jq is missing" {
  command() {
    [[ "$2" == "jq" ]] && return 1
    builtin command "$@"
  }
  export -f command
  run check_deps
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"jq is required"* ]]
}

@test "check_api_key passes when RESROBOT_KEY is set" {
  RESROBOT_KEY="test-key-123"
  run check_api_key
  [[ "$status" -eq 0 ]]
}

@test "check_api_key fails when RESROBOT_KEY is unset" {
  unset RESROBOT_KEY
  run check_api_key
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"RESROBOT_KEY not set"* ]]
  [[ "$output" == *"trafiklab.se"* ]]
}

@test "check_api_key fails when RESROBOT_KEY is empty" {
  RESROBOT_KEY=""
  run check_api_key
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"RESROBOT_KEY not set"* ]]
}

@test "check_api_key never echoes the key" {
  RESROBOT_KEY="secret-key-xyz"
  run check_api_key
  [[ "$output" != *"secret-key-xyz"* ]]
}
