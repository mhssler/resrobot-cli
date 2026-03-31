#!/usr/bin/env bats

setup() {
  load '../helpers'
  export RESROBOT_KEY="test-key-123"
}

# Mock curl -s -o <file> -w '%{http_code}' <url>
mock_curl_ok() {
  _MOCK_FIXTURE="$FIXTURES_DIR/$1"
  export _MOCK_FIXTURE
  curl() {
    local outfile=""
    local args=("$@")
    for ((i=0; i<${#args[@]}; i++)); do
      [[ "${args[$i]}" == "-o" ]] && outfile="${args[$((i+1))]}"
    done
    cp "$_MOCK_FIXTURE" "$outfile"
    printf '200'
  }
  export -f curl
}

mock_curl_status() {
  _MOCK_STATUS="$1"
  export _MOCK_STATUS
  curl() {
    local outfile=""
    local args=("$@")
    for ((i=0; i<${#args[@]}; i++)); do
      [[ "${args[$i]}" == "-o" ]] && outfile="${args[$((i+1))]}"
    done
    echo '{}' > "$outfile"
    printf '%s' "$_MOCK_STATUS"
  }
  export -f curl
}

mock_curl_fail() {
  curl() { return 1; }
  export -f curl
}

@test "api_get: successful response returns JSON body" {
  mock_curl_ok "search-goteborg.json"
  run api_get "/location.name" "input" "Göteborg"
  [[ "$status" -eq 0 ]]
  echo "$output" | jq -e '.stopLocationOrCoordLocation' >/dev/null
}

@test "api_get: HTTP 401 returns error" {
  mock_curl_status 401
  run api_get "/location.name" "input" "test"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"API returned HTTP 401"* ]]
}

@test "api_get: HTTP 500 returns error" {
  mock_curl_status 500
  run api_get "/location.name" "input" "test"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"API returned HTTP 500"* ]]
}

@test "api_get: API-level error (errorText) returns error" {
  mock_curl_ok "error-invalid-key.json"
  run api_get "/location.name" "input" "test"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Invalid or missing access id"* ]]
}

@test "api_get: network failure returns error" {
  mock_curl_fail
  run api_get "/location.name" "input" "test"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Network request failed"* ]]
}

@test "api_get: API key never appears in error output" {
  mock_curl_status 401
  run api_get "/location.name" "input" "test"
  [[ "$output" != *"test-key-123"* ]]
}
