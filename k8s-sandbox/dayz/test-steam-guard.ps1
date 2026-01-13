# Test script for Steam Guard code generation (PowerShell version)
# Usage: .\test-steam-guard.ps1 -SharedSecret "YOUR_SHARED_SECRET"

param(
    [Parameter(Mandatory=$true)]
    [string]$SharedSecret
)

$ErrorActionPreference = "Stop"

$CHARS = "23456789BCDFGHJKMNPQRTVWXY"

Write-Host "=== Steam Guard Code Generation Test ===" -ForegroundColor Cyan
Write-Host "Shared secret length: $($SharedSecret.Length)"
Write-Host ""

# Step 1: Decode base64 shared secret to binary
Write-Host "Step 1: Decoding shared secret..." -ForegroundColor Yellow
try {
    $SecretBytes = [Convert]::FromBase64String($SharedSecret)
    
    # Convert to hex for display and later use
    $SecretHex = ($SecretBytes | ForEach-Object { $_.ToString("x2") }) -join ""
    
    Write-Host "  Secret (hex): $($SecretHex.Substring(0, [Math]::Min(40, $SecretHex.Length)))... (length: $($SecretHex.Length))" -ForegroundColor Green
    Write-Host "  Secret (binary length): $($SecretBytes.Length) bytes" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Failed to decode shared secret: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Get current time in 30-second intervals
Write-Host "Step 2: Calculating time buffer..." -ForegroundColor Yellow
$Timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$TimeBuffer = [Math]::Floor($Timestamp / 30)
Write-Host "  Current timestamp: $Timestamp" -ForegroundColor Green
Write-Host "  Time buffer (timestamp / 30): $TimeBuffer" -ForegroundColor Green
Write-Host ""

# Step 3: Convert time_buffer to 8-byte big-endian hex
Write-Host "Step 3: Converting time buffer to 8-byte big-endian..." -ForegroundColor Yellow
$TimeBytes = [BitConverter]::GetBytes([long]$TimeBuffer)
# Reverse for big-endian
[Array]::Reverse($TimeBytes)
$TimeHex = ($TimeBytes | ForEach-Object { $_.ToString("x2") }) -join ""
Write-Host "  Time buffer (hex): $TimeHex" -ForegroundColor Green
Write-Host ""

# Step 4: Compute HMAC-SHA1
Write-Host "Step 4: Computing HMAC-SHA1..." -ForegroundColor Yellow
try {
    # Convert hex time back to bytes
    $TimeBytesFromHex = for ($i = 0; $i -lt $TimeHex.Length; $i += 2) {
        [Convert]::ToByte($TimeHex.Substring($i, 2), 16)
    }
    
    # Use the secret bytes directly (already decoded from base64)
    # Compute HMAC-SHA1 using .NET
    $Hmac = New-Object System.Security.Cryptography.HMACSHA1
    $Hmac.Key = $SecretBytes
    $HmacHash = $Hmac.ComputeHash($TimeBytesFromHex)
    $HmacResult = ($HmacHash | ForEach-Object { $_.ToString("x2") }) -join ""
    
    Write-Host "  HMAC-SHA1 (hex): $HmacResult" -ForegroundColor Green
    Write-Host "  HMAC length: $($HmacResult.Length) characters (should be 40)" -ForegroundColor Green
    Write-Host ""
    
    if ($HmacResult.Length -lt 40) {
        Write-Host "ERROR: HMAC computation failed - result too short" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: HMAC computation failed: $_" -ForegroundColor Red
    exit 1
} finally {
    if ($Hmac) {
        $Hmac.Dispose()
    }
}

# Step 5: Extract code
Write-Host "Step 5: Extracting code..." -ForegroundColor Yellow
$LastByteHex = $HmacResult.Substring(38, 2)
$Start = [Convert]::ToInt32($LastByteHex, 16) -band 0x0F
Write-Host "  Last byte (hex): $LastByteHex" -ForegroundColor Green
Write-Host "  Start position: $Start" -ForegroundColor Green

$CodeBytesHex = $HmacResult.Substring($Start * 2, 8)
$CodePoint = [Convert]::ToInt64($CodeBytesHex, 16) -band 0x7FFFFFFF
Write-Host "  Code bytes (hex): $CodeBytesHex" -ForegroundColor Green
Write-Host "  Code point: $CodePoint" -ForegroundColor Green
Write-Host ""

# Step 6: Generate 5-character code
Write-Host "Step 6: Generating 5-character code..." -ForegroundColor Yellow
$Code = ""
$TempPoint = $CodePoint
for ($i = 1; $i -le 5; $i++) {
    $Idx = $TempPoint % $CHARS.Length
    $Code = $Code + $CHARS[$Idx]
    $TempPoint = [Math]::Floor($TempPoint / $CHARS.Length)
}

Write-Host ""
Write-Host "=== RESULT ===" -ForegroundColor Cyan
Write-Host "Generated Steam Guard Code: $Code" -ForegroundColor Green -BackgroundColor Black
Write-Host ""
Write-Host "You can test this code by:" -ForegroundColor Yellow
Write-Host "1. Opening Steam Desktop Authenticator or your mobile app"
Write-Host "2. Comparing the code shown there with: $Code"
Write-Host "3. If they match, the algorithm is working correctly"
Write-Host "4. If they don't match, there may be an issue with:"
Write-Host "   - The shared secret format"
Write-Host "   - The HMAC computation"
Write-Host "   - The time synchronization"
Write-Host ""
Write-Host "Note: Codes are valid for 30 seconds. If the code doesn't match," -ForegroundColor Yellow
Write-Host "wait a few seconds and run the script again to get a new code." -ForegroundColor Yellow

