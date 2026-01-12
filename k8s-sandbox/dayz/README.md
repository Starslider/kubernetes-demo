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

To prevent manual Steam login prompts on pod startup, you need to configure a Steam Guard code in your secrets.

### Option 1: Steam Guard Code (Temporary)
1. Get a Steam Guard code from your mobile authenticator app or email
2. Add `STEAMGUARD` to your `steamaccount` secret in your secret store with the current code
3. **Note**: Steam Guard codes expire, so you'll need to update this periodically

### Option 2: Steam Guard Shared Secret (Recommended for Automation)

Using a shared secret allows you to generate Steam Guard codes programmatically, eliminating the need for manual intervention. This is the recommended approach for automated deployments.

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

The system uses a Python-based TOTP (Time-based One-Time Password) generator that implements Steam's specific algorithm:
- Codes are generated on-demand when needed
- Each code is valid for 30 seconds
- Codes are automatically refreshed if they expire during download

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

### Setting up the Secret

The `steamaccount` ExternalSecret should include:
- `STEAMACCOUNT`: Your Steam username
- `STEAMPASSWORD`: Your Steam password
- `STEAMGUARD`: (Optional) Steam Guard code for automated authentication (temporary, expires)
- `STEAMGUARDSHAREDSECRET`: (Optional) Steam Guard shared secret for permanent automated authentication (recommended)

**Priority**: If both `STEAMGUARDSHAREDSECRET` and `STEAMGUARD` are provided, the shared secret will be used to generate codes automatically.

If neither is provided, SteamCMD will prompt for manual authentication.

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