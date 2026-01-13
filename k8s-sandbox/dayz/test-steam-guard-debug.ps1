# Comprehensive debug script for Steam Guard code generation
# Usage: .\test-steam-guard-debug.ps1 -SharedSecret "YOUR_SHARED_SECRET"

param(
    [Parameter(Mandatory=$true)]
    [string]$SharedSecret
)

$ErrorActionPreference = "Stop"

$CHARS = "23456789BCDFGHJKMNPQRTVWXY"

Write-Host "=== Steam Guard Code Generation - Comprehensive Debug ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Shared Secret Format
Write-Host "TEST 1: Shared Secret Format" -ForegroundColor Yellow
Write-Host "  Length: $($SharedSecret.Length) characters"
Write-Host "  First 10 chars: $($SharedSecret.Substring(0, [Math]::Min(10, $SharedSecret.Length)))"
Write-Host "  Last 10 chars: $($SharedSecret.Substring([Math]::Max(0, $SharedSecret.Length - 10)))"
Write-Host "  Contains only base64 chars: $($SharedSecret -match '^[A-Za-z0-9+/=]+$')"
Write-Host ""

# Test 2: Decode shared secret
Write-Host "TEST 2: Decoding Shared Secret" -ForegroundColor Yellow
try {
    $SecretBytes = [Convert]::FromBase64String($SharedSecret)
    $SecretHex = ($SecretBytes | ForEach-Object { $_.ToString("x2") }) -join ""
    
    Write-Host "  [OK] Decoded successfully" -ForegroundColor Green
    Write-Host "  Secret length: $($SecretBytes.Length) bytes"
    Write-Host "  Secret hex (first 20): $($SecretHex.Substring(0, [Math]::Min(20, $SecretHex.Length)))"
    Write-Host "  Secret hex (last 20): $($SecretHex.Substring([Math]::Max(0, $SecretHex.Length - 20)))"
    Write-Host ""
} catch {
    Write-Host "  [ERROR] Failed to decode: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "  TROUBLESHOOTING:" -ForegroundColor Yellow
    Write-Host "  - Make sure the shared secret is base64-encoded"
    Write-Host "  - Check for extra spaces or newlines"
    Write-Host "  - Verify you copied the exact value from the maFile"
    exit 1
}

# Test 3: Time synchronization
Write-Host "TEST 3: Time Synchronization" -ForegroundColor Yellow
$LocalTime = Get-Date
$UtcTime = [DateTimeOffset]::UtcNow
$Timestamp = $UtcTime.ToUnixTimeSeconds()
$TimeBuffer = [Math]::Floor($Timestamp / 30)
$TimeRemainder = $Timestamp % 30

Write-Host "  Local time: $LocalTime"
Write-Host "  UTC time: $($UtcTime.DateTime)"
Write-Host "  Unix timestamp: $Timestamp"
Write-Host "  Time buffer: $TimeBuffer (timestamp / 30)"
Write-Host "  Seconds into current 30s window: $TimeRemainder"
    Write-Host "  [WARNING] If time is off by >15 seconds, codes won't match!" -ForegroundColor Yellow
Write-Host ""

# Test 4: Time buffer to bytes
Write-Host "TEST 4: Time Buffer to 8-byte Big-Endian" -ForegroundColor Yellow
$TimeBytes = [BitConverter]::GetBytes([long]$TimeBuffer)
[Array]::Reverse($TimeBytes)
$TimeHex = ($TimeBytes | ForEach-Object { $_.ToString("x2") }) -join ""

Write-Host "  Time buffer: $TimeBuffer"
Write-Host "  Time bytes (hex): $TimeHex"
Write-Host "  Expected length: 16 hex chars (8 bytes)"
Write-Host "  Actual length: $($TimeHex.Length)"
if ($TimeHex.Length -ne 16) {
    Write-Host "  [ERROR] Wrong length!" -ForegroundColor Red
} else {
    Write-Host "  [OK] Length correct" -ForegroundColor Green
}
Write-Host ""

# Test 5: HMAC computation
Write-Host "TEST 5: HMAC-SHA1 Computation" -ForegroundColor Yellow
try {
    $TimeBytesFromHex = for ($i = 0; $i -lt $TimeHex.Length; $i += 2) {
        [Convert]::ToByte($TimeHex.Substring($i, 2), 16)
    }
    
    $Hmac = New-Object System.Security.Cryptography.HMACSHA1
    $Hmac.Key = $SecretBytes
    $HmacHash = $Hmac.ComputeHash($TimeBytesFromHex)
    $HmacResult = ($HmacHash | ForEach-Object { $_.ToString("x2") }) -join ""
    
    Write-Host "  [OK] HMAC computed successfully" -ForegroundColor Green
    Write-Host "  HMAC result: $HmacResult"
    Write-Host "  HMAC length: $($HmacResult.Length) (should be 40)"
    
    if ($HmacResult.Length -ne 40) {
        Write-Host "  [ERROR] Wrong HMAC length!" -ForegroundColor Red
    }
    Write-Host ""
} catch {
    Write-Host "  [ERROR] HMAC computation failed: $_" -ForegroundColor Red
    exit 1
} finally {
    if ($Hmac) {
        $Hmac.Dispose()
    }
}

# Test 6: Code extraction
Write-Host "TEST 6: Code Extraction" -ForegroundColor Yellow
$LastByteHex = $HmacResult.Substring(38, 2)
$Start = [Convert]::ToInt32($LastByteHex, 16) -band 0x0F
$CodeBytesHex = $HmacResult.Substring($Start * 2, 8)
$CodePoint = [Convert]::ToInt64($CodeBytesHex, 16) -band 0x7FFFFFFF

Write-Host "  Last byte (hex): $LastByteHex (decimal: $([Convert]::ToInt32($LastByteHex, 16)))"
Write-Host "  Start position: $Start"
Write-Host "  Code bytes (hex): $CodeBytesHex"
Write-Host "  Code point: $CodePoint"
Write-Host ""

# Test 7: Code generation
Write-Host "TEST 7: Code Generation" -ForegroundColor Yellow
$Code = ""
$TempPoint = $CodePoint
$Steps = @()

for ($i = 1; $i -le 5; $i++) {
    $Idx = $TempPoint % $CHARS.Length
    $Char = $CHARS[$Idx]
    $Code = $Code + $Char
    $Steps += "Step $i : Index=$Idx, Char='$Char', Code so far='$Code'"
    $TempPoint = [Math]::Floor($TempPoint / $CHARS.Length)
}

foreach ($step in $Steps) {
    Write-Host "  $step"
}
Write-Host ""

# Final result
Write-Host "=== FINAL RESULT ===" -ForegroundColor Cyan
Write-Host "Generated Code: $Code" -ForegroundColor Green -BackgroundColor Black
Write-Host ""

# Test 8: Generate multiple codes to check consistency
Write-Host "TEST 8: Generating codes for next 3 time windows" -ForegroundColor Yellow
for ($offset = 1; $offset -le 3; $offset++) {
    $FutureTimestamp = $Timestamp + ($offset * 30)
    $FutureTimeBuffer = [Math]::Floor($FutureTimestamp / 30)
    $FutureTimeBytes = [BitConverter]::GetBytes([long]$FutureTimeBuffer)
    [Array]::Reverse($FutureTimeBytes)
    $FutureTimeHex = ($FutureTimeBytes | ForEach-Object { $_.ToString("x2") }) -join ""
    $FutureTimeBytesFromHex = for ($i = 0; $i -lt $FutureTimeHex.Length; $i += 2) {
        [Convert]::ToByte($FutureTimeHex.Substring($i, 2), 16)
    }
    
    $FutureHmac = New-Object System.Security.Cryptography.HMACSHA1
    $FutureHmac.Key = $SecretBytes
    $FutureHmacHash = $FutureHmac.ComputeHash($FutureTimeBytesFromHex)
    $FutureHmacResult = ($FutureHmacHash | ForEach-Object { $_.ToString("x2") }) -join ""
    
    $FutureLastByteHex = $FutureHmacResult.Substring(38, 2)
    $FutureStart = [Convert]::ToInt32($FutureLastByteHex, 16) -band 0x0F
    $FutureCodeBytesHex = $FutureHmacResult.Substring($FutureStart * 2, 8)
    $FutureCodePoint = [Convert]::ToInt64($FutureCodeBytesHex, 16) -band 0x7FFFFFFF
    
    $FutureCode = ""
    $FutureTempPoint = $FutureCodePoint
    for ($i = 1; $i -le 5; $i++) {
        $FutureIdx = $FutureTempPoint % $CHARS.Length
        $FutureCode = $FutureCode + $CHARS[$FutureIdx]
        $FutureTempPoint = [Math]::Floor($FutureTempPoint / $CHARS.Length)
    }
    
    Write-Host "  +$($offset * 30)s: $FutureCode"
    $FutureHmac.Dispose()
}
Write-Host ""

# Recommendations
Write-Host "=== TROUBLESHOOTING CHECKLIST ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "If the code doesn't match your app:" -ForegroundColor Yellow
Write-Host "1. [OK] Verify shared secret is correct (exact value from maFile)"
Write-Host "2. [OK] Check system time is synchronized (within 15 seconds)"
Write-Host "3. [OK] Ensure shared secret is base64-encoded (as stored in SDA)"
Write-Host "4. [OK] Try waiting 10-15 seconds and run again (codes change every 30s)"
Write-Host "5. [OK] Compare with codes from next time windows above"
Write-Host ""
Write-Host "If still not matching:" -ForegroundColor Yellow
Write-Host "- The shared secret might be from a different account"
Write-Host "- The shared secret format might be different than expected"
Write-Host "- There might be an issue with the algorithm implementation"
Write-Host ""

