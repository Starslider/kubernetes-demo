# Compare our implementation with a reference Python implementation
# This helps identify if the issue is in our algorithm or the shared secret

param(
    [Parameter(Mandatory=$true)]
    [string]$SharedSecret
)

$ErrorActionPreference = "Stop"

Write-Host "=== Steam Guard Code Comparison Test ===" -ForegroundColor Cyan
Write-Host ""

# Check if Python is available
$pythonCmd = $null
if (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonCmd = "python"
} elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
    $pythonCmd = "python3"
}

if (-not $pythonCmd) {
    Write-Host "Python not found. Installing test script inline..." -ForegroundColor Yellow
    Write-Host ""
}

# Create a Python test script inline
$pythonScript = @"
import hmac
import hashlib
import base64
import time
import sys

def generate_steam_guard_code(shared_secret):
    try:
        # Decode the base64 shared secret
        secret = base64.b64decode(shared_secret)
        
        # Get current time in 30-second intervals
        timestamp = int(time.time())
        time_buffer = timestamp // 30
        
        # Convert to bytes (big-endian)
        time_buffer_bytes = time_buffer.to_bytes(8, byteorder='big')
        
        # Generate HMAC-SHA1
        hmac_digest = hmac.new(secret, time_buffer_bytes, hashlib.sha1).digest()
        
        # Steam's code generation algorithm
        start = hmac_digest[19] & 0x0F
        code_point = int.from_bytes(hmac_digest[start:start+4], byteorder='big') & 0x7FFFFFFF
        
        # Steam's character set
        chars = '23456789BCDFGHJKMNPQRTVWXY'
        code = ''
        
        # Generate 5-character code
        for _ in range(5):
            code += chars[code_point % len(chars)]
            code_point //= len(chars)
        
        return code
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python script.py <shared_secret>", file=sys.stderr)
        sys.exit(1)
    
    shared_secret = sys.argv[1]
    code = generate_steam_guard_code(shared_secret)
    print(code)
"@

# Test with PowerShell implementation
Write-Host "1. Testing PowerShell Implementation" -ForegroundColor Yellow
$CHARS = "23456789BCDFGHJKMNPQRTVWXY"

try {
    $SecretBytes = [Convert]::FromBase64String($SharedSecret)
    $Timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $TimeBuffer = [Math]::Floor($Timestamp / 30)
    $TimeBytes = [BitConverter]::GetBytes([long]$TimeBuffer)
    [Array]::Reverse($TimeBytes)
    $TimeBytesFromHex = $TimeBytes
    
    $Hmac = New-Object System.Security.Cryptography.HMACSHA1
    $Hmac.Key = $SecretBytes
    $HmacHash = $Hmac.ComputeHash($TimeBytesFromHex)
    $HmacResult = ($HmacHash | ForEach-Object { $_.ToString("x2") }) -join ""
    
    $LastByteHex = $HmacResult.Substring(38, 2)
    $Start = [Convert]::ToInt32($LastByteHex, 16) -band 0x0F
    $CodeBytesHex = $HmacResult.Substring($Start * 2, 8)
    $CodePoint = [Convert]::ToInt64($CodeBytesHex, 16) -band 0x7FFFFFFF
    
    $PSCode = ""
    $TempPoint = $CodePoint
    for ($i = 1; $i -le 5; $i++) {
        $Idx = $TempPoint % $CHARS.Length
        $PSCode = $PSCode + $CHARS[$Idx]
        $TempPoint = [Math]::Floor($TempPoint / $CHARS.Length)
    }
    
    Write-Host "  PowerShell Code: $PSCode" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
    $PSCode = "ERROR"
}

# Test with Python implementation (if available)
if ($pythonCmd) {
    Write-Host "2. Testing Python Implementation (Reference)" -ForegroundColor Yellow
    try {
        $tempPyFile = [System.IO.Path]::GetTempFileName() + ".py"
        $pythonScript | Out-File -FilePath $tempPyFile -Encoding UTF8
        
        $PythonCode = & $pythonCmd $tempPyFile $SharedSecret 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            $PythonCode = $PythonCode.Trim()
            Write-Host "  Python Code: $PythonCode" -ForegroundColor Green
            Write-Host ""
            
            # Compare
            Write-Host "3. Comparison" -ForegroundColor Yellow
            if ($PSCode -eq $PythonCode) {
                Write-Host "  ✓ Codes MATCH!" -ForegroundColor Green
                Write-Host "  Both implementations produce the same code: $PSCode" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Codes DON'T MATCH!" -ForegroundColor Red
                Write-Host "  PowerShell: $PSCode" -ForegroundColor Red
                Write-Host "  Python:     $PythonCode" -ForegroundColor Red
                Write-Host ""
                Write-Host "  This indicates an issue with the PowerShell implementation." -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ERROR: Python script failed" -ForegroundColor Red
            Write-Host "  Output: $PythonCode" -ForegroundColor Red
        }
        
        Remove-Item $tempPyFile -ErrorAction SilentlyContinue
    } catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "2. Python not available - skipping reference comparison" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "3. Manual Comparison" -ForegroundColor Yellow
    Write-Host "  PowerShell Code: $PSCode" -ForegroundColor Green
    Write-Host "  Compare this with your Steam authenticator app" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Compare PowerShell code with your Steam app"
Write-Host "2. If they match: The algorithm is correct, issue is elsewhere"
Write-Host "3. If they don't match: Run test-steam-guard-debug.ps1 for detailed analysis"
Write-Host "4. If Python code matches app but PowerShell doesn't: Algorithm bug in PowerShell"
Write-Host ""

