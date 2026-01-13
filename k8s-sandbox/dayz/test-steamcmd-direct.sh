#!/bin/bash
# Test SteamCMD directly with a generated Steam Guard code

set -e

SHARED_SECRET="${1:-l5YJrYfIg5vog9O+4bFu+WWwD68=}"
STEAM_ACCOUNT="${2:-starslider85}"
STEAM_PASSWORD="${3:-Looping6285}"

echo "=== Testing SteamCMD Directly ==="
echo "Account: $STEAM_ACCOUNT"
echo "Shared Secret: $SHARED_SECRET"
echo ""

# Function to generate Steam Guard code (same as in mod-downloader)
generate_steam_guard_code_bash() {
  local shared_secret="$1"
  local chars="23456789BCDFGHJKMNPQRTVWXY"
  
  # Decode base64 shared secret to binary
  local secret_bin
  if command -v base64 &> /dev/null; then
    secret_bin=$(echo -n "$shared_secret" | base64 -d 2>/dev/null)
  elif command -v openssl &> /dev/null; then
    secret_bin=$(echo -n "$shared_secret" | openssl base64 -d -A 2>/dev/null)
  else
    echo "ERROR: Neither base64 nor openssl available" >&2
    return 1
  fi
  
  if [ -z "$secret_bin" ]; then
    echo "ERROR: Failed to decode shared secret" >&2
    return 1
  fi
  
  # Get current time in 30-second intervals
  local timestamp=$(date -u +%s)
  local time_buffer=$((timestamp / 30))
  
  # Convert time_buffer to 8-byte big-endian hex
  local time_hex=""
  for i in {7..0}; do
    local byte=$((time_buffer >> (i * 8) & 0xFF))
    time_hex=$(printf "%s%02x" "$time_hex" "$byte")
  done
  
  # Compute HMAC-SHA1 using openssl
  local hmac_result
  if command -v openssl &> /dev/null; then
    local secret_hex=$(printf "%s" "$secret_bin" | od -An -tx1 | tr -d ' \n')
    
    if command -v xxd &> /dev/null; then
      hmac_result=$(printf "%s" "$time_hex" | xxd -r -p 2>/dev/null | openssl dgst -sha1 -mac HMAC -macopt hexkey:"$secret_hex" -binary 2>/dev/null | od -An -tx1 2>/dev/null | tr -d ' \n')
    else
      local time_bin_hex=$(echo "$time_hex" | sed 's/\(..\)/\\x\1/g')
      hmac_result=$(printf "$time_bin_hex" 2>/dev/null | openssl dgst -sha1 -mac HMAC -macopt hexkey:"$secret_hex" -binary 2>/dev/null | od -An -tx1 2>/dev/null | tr -d ' \n')
    fi
  else
    echo "ERROR: openssl not available" >&2
    return 1
  fi
  
  if [ -z "$hmac_result" ] || [ ${#hmac_result} -lt 40 ]; then
    echo "ERROR: HMAC computation failed" >&2
    return 1
  fi
  
  # Extract last 4 bits to determine start position
  local last_byte_hex="${hmac_result:38:2}"
  local start=$((0x$last_byte_hex & 0x0F))
  
  # Extract 4 bytes starting at position 'start'
  local code_bytes_hex="${hmac_result:$((start * 2)):8}"
  local code_point=$((0x$code_bytes_hex & 0x7FFFFFFF))
  
  # Generate 5-character code
  local code=""
  local temp_point=$code_point
  for i in {1..5}; do
    local idx=$((temp_point % ${#chars}))
    code="$code${chars:$idx:1}"
    temp_point=$((temp_point / ${#chars}))
  done
  
  printf "%s\n" "$code" 2>/dev/null
}

# Generate fresh code
echo "Step 1: Generating fresh Steam Guard code..."
CURRENT_TIME=$(date -u +%s)
TIME_WINDOW=$((CURRENT_TIME / 30))
SECONDS_IN_WINDOW=$((CURRENT_TIME % 30))
echo "  Current time: $CURRENT_TIME (UTC)"
echo "  Time window: $TIME_WINDOW"
echo "  Seconds in window: $SECONDS_IN_WINDOW"

temp_file=$(mktemp)
generate_steam_guard_code_bash "$SHARED_SECRET" > "$temp_file" 2>/dev/null
bash_output=$(cat "$temp_file" 2>/dev/null)
rm -f "$temp_file" 2>/dev/null
STEAM_GUARD_CODE=$(echo "$bash_output" | grep -oE '[A-Z0-9]{5}' | head -1)
if [ -z "$STEAM_GUARD_CODE" ] || [ ${#STEAM_GUARD_CODE} -ne 5 ]; then
  last_line=$(echo "$bash_output" | tail -1 | tr -d '\n\r\t ')
  if [ ${#last_line} -eq 5 ] && [[ "$last_line" =~ ^[A-Z0-9]{5}$ ]]; then
    STEAM_GUARD_CODE="$last_line"
  fi
fi

if [ -z "$STEAM_GUARD_CODE" ] || [ ${#STEAM_GUARD_CODE} -ne 5 ]; then
  echo "ERROR: Failed to generate Steam Guard code"
  exit 1
fi

echo "  Generated code: $STEAM_GUARD_CODE"
echo "  Code valid for: $((30 - SECONDS_IN_WINDOW)) more seconds"
echo ""

# Test method 1: Command line with +set_steam_guard_code
echo "Step 2: Testing SteamCMD with command line method..."
echo "  Command: steamcmd +set_steam_guard_code $STEAM_GUARD_CODE +login $STEAM_ACCOUNT [PASSWORD] +quit"
echo ""

steamcmd +set_steam_guard_code "$STEAM_GUARD_CODE" +login "$STEAM_ACCOUNT" "$STEAM_PASSWORD" +quit 2>&1 | tee /tmp/steamcmd_test.log

EXIT_CODE=${PIPESTATUS[0]}
echo ""
echo "=== SteamCMD Exit Code: $EXIT_CODE ==="

# Check for specific errors
if grep -qi "two-factor\|two factor\|code mismatch\|invalid password" /tmp/steamcmd_test.log; then
  echo "ERROR: Authentication failed - code mismatch detected"
  echo "Output:"
  grep -i "two-factor\|two factor\|code mismatch\|invalid password\|error" /tmp/steamcmd_test.log | head -5
  exit 1
elif grep -qi "logged in\|login.*success" /tmp/steamcmd_test.log; then
  echo "SUCCESS: Login successful!"
  exit 0
else
  echo "UNKNOWN: Check the output above for details"
  exit $EXIT_CODE
fi

