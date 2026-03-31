#!/usr/bin/env bats

setup() {
  load '../helpers'
}

@test "url_encode: plain ASCII unchanged" {
  run url_encode "hello"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "hello" ]]
}

@test "url_encode: spaces encoded" {
  run url_encode "hello world"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "hello%20world" ]]
}

@test "url_encode: Swedish characters" {
  run url_encode "Göteborg"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "G%C3%B6teborg" ]]
}

@test "url_encode: question mark" {
  run url_encode "Stockholm?"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "Stockholm%3F" ]]
}

@test "url_encode: ampersand" {
  run url_encode "a&b"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "a%26b" ]]
}

@test "url_encode: empty string" {
  run url_encode ""
  [[ "$status" -eq 0 ]]
  [[ "$output" == "" ]]
}

@test "url_encode: all Swedish vowels" {
  run url_encode "åäö"
  [[ "$status" -eq 0 ]]
  [[ "$output" == "%C3%A5%C3%A4%C3%B6" ]]
}
