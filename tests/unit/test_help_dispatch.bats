#!/usr/bin/env bats

setup() {
  load '../helpers'
}

@test "cmd_help: no args shows all commands" {
  run cmd_help
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"search"* ]]
  [[ "$output" == *"departures"* ]]
  [[ "$output" == *"trip"* ]]
}

@test "cmd_help: help search shows search usage" {
  run cmd_help search
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"search <name>"* ]]
}

@test "cmd_help: help trip shows trip usage" {
  run cmd_help trip
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"<origin>"* ]]
  [[ "$output" == *"<destination>"* ]]
}

@test "cmd_help: unknown command exits 1" {
  run cmd_help nonexistent
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Unknown command"* ]]
}

@test "main: no args shows help" {
  run main
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Commands:"* ]]
}

@test "main: unknown command shows help and exits 1" {
  run main badcommand
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Unknown command"* ]]
  [[ "$output" == *"Commands:"* ]]
}

@test "main: help command works without API key" {
  unset RESROBOT_KEY
  run main help
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Commands:"* ]]
}

@test "main: API command fails without API key" {
  unset RESROBOT_KEY
  run main search "test"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"RESROBOT_KEY not set"* ]]
}
