# DayZ Server Configuration

This directory contains the configuration for a DayZ game server deployment.

## Components

- **configmap.yaml**: Server configuration settings
- **cronjob.yaml**: Scheduled tasks configuration
- **deployment.yaml**: Server deployment configuration
- **kustomization.yaml**: Kustomize configuration
- **pvc.yaml**: Persistent volume claim for server data
- **rbac.yaml**: Role-based access control configuration
- **secrets.yaml**: Sensitive configuration data
- **serviceaccount.yaml**: Service account configuration
- **svc.yaml**: Service configuration

## Features

The DayZ server deployment includes:
- Automated server management
- Persistent storage for game data
- Scheduled maintenance tasks
- Secure configuration management

## Usage

To modify the server configuration:
1. Update the relevant configuration files
2. Let ArgoCD sync the changes or apply manually:
```bash
kubectl apply -k .
```

## Steam Guard Authentication

To prevent manual Steam login prompts on pod startup, you need to configure a Steam Guard shared secret in your secrets.

### Steam Guard Shared Secret (Required)

The deployment uses a Steam Guard shared secret to generate authentication codes programmatically, eliminating the need for manual intervention. This is required for automated deployments.

#### Step 1: Extract Your Steam Guard Shared Secret

You have several options to extract your shared secret:

**Method A: Using Steam Desktop Authenticator (Easiest)**

1. **Download Steam Desktop Authenticator (SDA)**:
   - Visit: https://github.com/Jessecar96/SteamDesktopAuthenticator
   - Download and install the application
   - **Important**: During setup, do NOT set an encryption password (leave it blank)

2. **Link Your Steam Account**:
   - Run SDA and follow the setup wizard
   - Link your Steam account to SDA
   - This will disable your mobile authenticator (you can re-enable it later if needed)

3. **Extract the Shared Secret**:
   - Navigate to the SDA installation folder
   - Open the `maFiles` directory
   - Find the file named after your SteamID (e.g., `76561198012345678.maFile`)
   - Open this file in a text editor
   - Look for the line: `"shared_secret":"<your_shared_secret>"`
   - Copy the value (the string between the quotes, without the quotes themselves)
   - **Example**: If you see `"shared_secret":"ABC123XYZ456"`, copy `ABC123XYZ456`

**Method B: From Android Device (Rooted)**

If your Android device is rooted:
1. Navigate to `/data/data/com.valvesoftware.android.steam.community/files/`
2. Find the `Steamguard` file
3. Extract the `shared_secret` value from the JSON structure

**Method C: From iOS Device**

1. Create an unencrypted backup of your device using iTunes
2. Use a tool like iExplorer to navigate to the Steam app's data
3. Extract the shared secret from the app's data files

#### Step 2: Store the Shared Secret Securely

1. Add `STEAMGUARDSHAREDSECRET` to your `steamaccount` secret in your secret store
2. Store the shared secret value (the base64-encoded string you extracted)
3. **Security Warning**: Treat this secret like a password - anyone with it can generate codes for your account

#### Step 3: Configure the Deployment

The deployment is already configured to support shared secrets. The mod-downloader script will automatically:
- Detect if `STEAMGUARDSHAREDSECRET` is set
- Generate a current Steam Guard code from the shared secret
- Use that code for automated authentication

#### How It Works

The system uses a bash/openssl-based TOTP (Time-based One-Time Password) generator that implements Steam's specific algorithm:
- Codes are generated on-demand when needed using the shared secret
- Each code is valid for 30 seconds
- Codes are automatically regenerated if they expire during download retries

#### Verification

After setting up the shared secret:
1. Apply the updated configuration: `kubectl apply -k .`
2. Restart the pods: `kubectl rollout restart deployment/dayz -n dayz`
3. Check the logs: `kubectl logs -n dayz deployment/dayz -c mod-downloader`
4. You should see: `Using Steam Guard shared secret for automated authentication...` without any manual prompts

#### Troubleshooting

- **"Invalid code" errors**: Ensure the shared secret is correct and base64-encoded
- **Still prompting for code**: Verify `STEAMGUARDSHAREDSECRET` is set in your secret store
- **Codes expiring**: The script automatically generates fresh codes, but if downloads take >30 seconds, it will retry with a new code
- **"Two-factor code mismatch"**: See Testing section below

#### Testing Steam Guard Code Generation

If you're experiencing "Two-factor code mismatch" errors, you can test the code generation outside the pod:

**Option 1: PowerShell Test Script (Windows)**

```powershell
# Run the PowerShell test script
.\test-steam-guard.ps1 -SharedSecret "YOUR_SHARED_SECRET_HERE"

# Compare the generated code with your Steam authenticator app
# If they match, the algorithm is working correctly
```

**Option 2: Bash Test Script (Linux/WSL/Git Bash)**

```bash
# Run the test script with your shared secret
./test-steam-guard.sh "YOUR_SHARED_SECRET_HERE"

# Compare the generated code with your Steam authenticator app
# If they match, the algorithm is working correctly
```

**Option 3: Docker Container Test (matches pod environment)**

```bash
# Test in the same container image used by the pod
./test-steam-guard-docker.sh "YOUR_SHARED_SECRET_HERE"
```

**What to check:**
1. The generated code should match your Steam authenticator app code
2. If codes don't match, verify:
   - The shared secret is correct (exact value from SDA maFile)
   - The shared secret is base64-encoded (as stored in SDA)
   - Your system time is synchronized (codes are time-based)
3. If codes match but Steam still rejects them:
   - There may be a delay between code generation and use
   - Try regenerating the code right before use
   - Check if Steam has additional rate limiting

**Advanced Debugging:**

For more detailed diagnostics, use the comprehensive debug script:
```powershell
.\test-steam-guard-debug.ps1 -SharedSecret "YOUR_SHARED_SECRET"
```

This will show:
- Shared secret format validation
- Time synchronization status
- Step-by-step algorithm execution
- Codes for future time windows
- Detailed troubleshooting checklist

To compare with a reference Python implementation:
```powershell
.\test-steam-guard-compare.ps1 -SharedSecret "YOUR_SHARED_SECRET"
```

This compares the PowerShell implementation with a known-working Python version to identify algorithm issues.

### Setting up the Secret

The `steamaccount` ExternalSecret should include:
- `STEAMACCOUNT`: Your Steam username
- `STEAMPASSWORD`: Your Steam password
- `STEAMGUARDSHAREDSECRET`: (Required) Steam Guard shared secret for automated authentication

If `STEAMGUARDSHAREDSECRET` is not provided, the script will exit with an error.

### Quick Start: Setting Up Shared Secret

1. **Extract your shared secret** using Steam Desktop Authenticator (see Option 2 above)
2. **Add to your secret store**: Add `STEAMGUARDSHAREDSECRET` to your `steamaccount` secret with the base64-encoded shared secret value
3. **Apply configuration**: 
   ```bash
   kubectl apply -k .
   ```
4. **Restart pods**:
   ```bash
   kubectl rollout restart deployment/dayz -n dayz
   ```
5. **Verify**: Check logs to confirm automated authentication:
   ```bash
   kubectl logs -n dayz deployment/dayz -c mod-downloader -f
   ```

You should see: `Using Steam Guard shared secret for automated authentication...` without any manual prompts.

## Rate Limit Handling

The mod downloader includes built-in rate limit protection:

### Automatic Rate Limit Protection

- **Initial delay**: 5-second delay before starting downloads
- **Inter-mod delays**: Increasing delays between mod downloads (6s, 7s, 8s, etc.)
- **Exponential backoff**: Automatic retry with increasing delays (20s, 40s, 80s, 160s)
- **Rate limit detection**: Automatically detects rate limit errors and waits longer
- **Steam Guard code regeneration**: Automatically regenerates codes on retry if using shared secret

### If You Still Get Rate Limit Errors

1. **Wait and retry**: The script will automatically retry with exponential backoff
2. **Reduce mod count**: If you have many mods, consider reducing the number temporarily
3. **Check Steam status**: Steam may be experiencing issues - check https://steamstat.us
4. **Spread out updates**: If possible, update mods during off-peak hours
5. **Manual intervention**: If rate limits persist, you may need to wait 15-30 minutes before retrying

### Rate Limit Error Messages

If you see errors like:
- `RATE LIMIT EXCEEDED`
- `Too many requests`
- `429` errors

The script will automatically:
- Wait progressively longer between retries
- Regenerate Steam Guard codes if needed
- Continue processing remaining mods after delays

**Note**: Steam's rate limits are typically:
- Login attempts: ~5-10 per hour
- Workshop downloads: Varies based on mod size and Steam's current load