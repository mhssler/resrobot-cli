#!/usr/bin/env bats

@test "resrobot is on PATH" {
    run which resrobot
    [[ "$status" -eq 0 ]]
}

@test "resrobot help runs successfully" {
    run resrobot help
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Commands:"* ]]
    [[ "$output" == *"search"* ]]
    [[ "$output" == *"departures"* ]]
    [[ "$output" == *"trip"* ]]
}

@test "resrobot no args shows help" {
    run resrobot
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Commands:"* ]]
}
