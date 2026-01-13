#!/bin/bash
# Test script for Steam Guard code generation
# Usage: ./test-steam-guard.sh <shared_secret>

set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <shared_secret>"
  echo "Example: $0 'ABC123XYZ456...'"
  exit 1
fi

SHARED_SECRET="$1"
CHARS="23456789BCDFGHJKMNPQRTVWXY"

echo "=== Steam Guard Code Generation Test ==="
echo "Shared secret length: ${#SHARED_SECRET}"
echo ""

# Decode base64 shared secret to binary
echo "Step 1: Decoding shared secret..."
SECRET_BIN=""
if command -v base64 &> /dev/null; then
  SECRET_BIN=$(echo -n "$SHARED_SECRET" | base64 -d 2>/dev/null)
elif command -v openssl &> /dev/null; then
  SECRET_BIN=$(echo -n "$SHARED_SECRET" | openssl base64 -d -A 2>/dev/null)
else
  echo "ERROR: Neither base64 nor openssl available"
  exit 1
fi

if [ -z "$SECRET_BIN" ]; then
  echo "ERROR: Failed to decode shared secret"
  exit 1
fi

SECRET_HEX=$(printf "%s" "$SECRET_BIN" | od -An -tx1 | tr -d ' \n')
echo "  Secret (hex): ${SECRET_HEX:0:40}... (length: ${#SECRET_HEX})"
echo "  Secret (binary length): ${#SECRET_BIN} bytes"
echo ""

# Get current time in 30-second intervals
echo "Step 2: Calculating time buffer..."
TIMESTAMP=$(date +%s)
TIME_BUFFER=$((TIMESTAMP / 30))
echo "  Current timestamp: $TIMESTAMP"
echo "  Time buffer (timestamp / 30): $TIME_BUFFER"
echo ""

# Convert time_buffer to 8-byte big-endian hex
echo "Step 3: Converting time buffer to 8-byte big-endian..."
TIME_HEX=""
for i in {7..0}; do
  BYTE=$((TIME_BUFFER >> (i * 8) & 0xFF))
  TIME_HEX=$(printf "%s%02x" "$TIME_HEX" "$BYTE")
done
echo "  Time buffer (hex): $TIME_HEX"
echo ""

# Compute HMAC-SHA1
echo "Step 4: Computing HMAC-SHA1..."
HMAC_RESULT=""
if command -v openssl &> /dev/null; then
  if command -v xxd &> /dev/null; then
    echo "  Using xxd method..."
    HMAC_RESULT=$(printf "%s" "$TIME_HEX" | xxd -r -p 2>/dev/null | openssl dgst -sha1 -mac HMAC -macopt "hexkey:$SECRET_HEX" -binary 2>/dev/null | od -An -tx1 2>/dev/null | tr -d ' \n')
  else
    echo "  Using printf method..."
    TIME_PRINTF=$(echo "$TIME_HEX" | sed 's/\(..\)/\\x\1/g')
    HMAC_RESULT=$(printf "$TIME_PRINTF" 2>/dev/null | openssl dgst -sha1 -mac HMAC -macopt "hexkey:$SECRET_HEX" -binary 2>/dev/null | od -An -tx1 2>/dev/null | tr -d ' \n')
  fi
else
  echo "ERROR: openssl not available"
  exit 1
fi

if [ -z "$HMAC_RESULT" ] || [ ${#HMAC_RESULT} -lt 40 ]; then
  echo "ERROR: HMAC computation failed"
  echo "  HMAC result: '$HMAC_RESULT' (length: ${#HMAC_RESULT})"
  exit 1
fi

echo "  HMAC-SHA1 (hex): $HMAC_RESULT"
echo "  HMAC length: ${#HMAC_RESULT} characters (should be 40)"
echo ""

# Extract code
echo "Step 5: Extracting code..."
LAST_BYTE_HEX="${HMAC_RESULT:38:2}"
START=$((0x$LAST_BYTE_HEX & 0x0F))
echo "  Last byte (hex): $LAST_BYTE_HEX"
echo "  Start position: $START"

CODE_BYTES_HEX="${HMAC_RESULT:$((START * 2)):8}"
CODE_POINT=$((0x$CODE_BYTES_HEX & 0x7FFFFFFF))
echo "  Code bytes (hex): $CODE_BYTES_HEX"
echo "  Code point: $CODE_POINT"
echo ""

# Generate 5-character code
echo "Step 6: Generating 5-character code..."
CODE=""
TEMP_POINT=$CODE_POINT
for i in {1..5}; do
  IDX=$((TEMP_POINT % ${#CHARS}))
  CODE="$CODE${CHARS:$IDX:1}"
  TEMP_POINT=$((TEMP_POINT / ${#CHARS}))
done

echo ""
echo "=== RESULT ==="
echo "Generated Steam Guard Code: $CODE"
echo ""
echo "You can test this code by:"
echo "1. Opening Steam Desktop Authenticator or your mobile app"
echo "2. Comparing the code shown there with: $CODE"
echo "3. If they match, the algorithm is working correctly"
echo "4. If they don't match, there may be an issue with:"
echo "   - The shared secret format"
echo "   - The HMAC computation"
echo "   - The time synchronization"
echo ""
echo "Note: Codes are valid for 30 seconds. If the code doesn't match,"
echo "wait a few seconds and run the script again to get a new code."

