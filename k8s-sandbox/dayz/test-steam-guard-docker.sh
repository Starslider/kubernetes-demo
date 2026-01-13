#!/bin/bash
# Test Steam Guard code generation in a Docker container (similar to the pod environment)
# Usage: ./test-steam-guard-docker.sh <shared_secret>

set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <shared_secret>"
  exit 1
fi

SHARED_SECRET="$1"

echo "=== Testing Steam Guard Code Generation in Docker Container ==="
echo "This will run the same algorithm used in the pod in a test container"
echo ""

# Use the same base image as the pod
IMAGE="ghcr.io/starslider/dayz-server:latest"

echo "Pulling image if needed..."
docker pull "$IMAGE" > /dev/null 2>&1 || true

echo "Running test in container..."
docker run --rm -i "$IMAGE" /bin/bash <<EOF
set -e

SHARED_SECRET="$SHARED_SECRET"
CHARS="23456789BCDFGHJKMNPQRTVWXY"

echo "=== Steam Guard Code Generation Test (in container) ==="
echo "Shared secret length: \${#SHARED_SECRET}"
echo ""

# Decode base64 shared secret
echo "Step 1: Decoding shared secret..."
SECRET_BIN=""
if command -v base64 &> /dev/null; then
  SECRET_BIN=\$(echo -n "\$SHARED_SECRET" | base64 -d 2>/dev/null)
elif command -v openssl &> /dev/null; then
  SECRET_BIN=\$(echo -n "\$SHARED_SECRET" | openssl base64 -d -A 2>/dev/null)
fi

if [ -z "\$SECRET_BIN" ]; then
  echo "ERROR: Failed to decode shared secret"
  exit 1
fi

SECRET_HEX=\$(printf "%s" "\$SECRET_BIN" | od -An -tx1 | tr -d ' \n')
echo "  Secret decoded successfully (length: \${#SECRET_BIN} bytes)"
echo ""

# Get current time
echo "Step 2: Calculating time buffer..."
TIMESTAMP=\$(date +%s)
TIME_BUFFER=\$((TIMESTAMP / 30))
echo "  Timestamp: \$TIMESTAMP"
echo "  Time buffer: \$TIME_BUFFER"
echo ""

# Convert to hex
echo "Step 3: Converting to hex..."
TIME_HEX=""
for i in {7..0}; do
  BYTE=\$((TIME_BUFFER >> (i * 8) & 0xFF))
  TIME_HEX=\$(printf "%s%02x" "\$TIME_HEX" "\$BYTE")
done
echo "  Time hex: \$TIME_HEX"
echo ""

# Compute HMAC
echo "Step 4: Computing HMAC-SHA1..."
HMAC_RESULT=""
if command -v openssl &> /dev/null; then
  if command -v xxd &> /dev/null; then
    HMAC_RESULT=\$(printf "%s" "\$TIME_HEX" | xxd -r -p 2>/dev/null | openssl dgst -sha1 -mac HMAC -macopt "hexkey:\$SECRET_HEX" -binary 2>/dev/null | od -An -tx1 2>/dev/null | tr -d ' \n')
  else
    TIME_PRINTF=\$(echo "\$TIME_HEX" | sed 's/\\(..\\)/\\\\x\\1/g')
    HMAC_RESULT=\$(printf "\$TIME_PRINTF" 2>/dev/null | openssl dgst -sha1 -mac HMAC -macopt "hexkey:\$SECRET_HEX" -binary 2>/dev/null | od -An -tx1 2>/dev/null | tr -d ' \n')
  fi
fi

if [ -z "\$HMAC_RESULT" ] || [ \${#HMAC_RESULT} -lt 40 ]; then
  echo "ERROR: HMAC computation failed"
  echo "  Result: '\$HMAC_RESULT' (length: \${#HMAC_RESULT})"
  exit 1
fi

echo "  HMAC computed successfully"
echo ""

# Extract code
echo "Step 5: Extracting code..."
LAST_BYTE_HEX="\${HMAC_RESULT:38:2}"
START=\$((0x\$LAST_BYTE_HEX & 0x0F))
CODE_BYTES_HEX="\${HMAC_RESULT:\$((START * 2)):8}"
CODE_POINT=\$((0x\$CODE_BYTES_HEX & 0x7FFFFFFF))

CODE=""
TEMP_POINT=\$CODE_POINT
for i in {1..5}; do
  IDX=\$((TEMP_POINT % \${#CHARS}))
  CODE="\${CHARS:\$IDX:1}\$CODE"
  TEMP_POINT=\$((TEMP_POINT / \${#CHARS}))
done

echo ""
echo "=== RESULT ==="
echo "Generated Code: \$CODE"
echo ""
echo "Compare this with your Steam authenticator app code"
EOF

