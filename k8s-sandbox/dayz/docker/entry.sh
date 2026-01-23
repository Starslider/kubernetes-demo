#!/bin/bash

function updateGame() {
    # Check if DayZServer already exists - if so, skip update
    if [ -f ${HOME}/${GAME}/DayZServer ]; then
        echo "✅ DayZServer binary already exists, skipping update..."
        return 0
    fi
    
    # Clean up any stuck downloads from previous failed attempts
    if [ -d "${HOME}/${GAME}/steamapps/downloading" ]; then
        echo "⚠️  Found stuck downloads from previous attempt, cleaning up..."
        echo "   Directory size before cleanup:"
        du -sh "${HOME}/${GAME}/steamapps/downloading" 2>/dev/null || true
        rm -rf "${HOME}/${GAME}/steamapps/downloading" 2>/dev/null || true
        echo "   Cleanup complete"
    else
        echo "✅ No stuck downloads found"
    fi
    
    echo "=== Updating DayZ server via SteamCMD ==="
    echo "Current directory: $(pwd)"
    echo "Home directory: ${HOME}"
    echo "Game directory: ${HOME}/${GAME}"
    echo "Disk space:"
    df -h ${HOME}/${GAME} 2>/dev/null || df -h ${HOME} 2>/dev/null || true
    echo ""
    
    MAX_RETRIES=10
    RETRY_COUNT=0
    AUTH_NEEDED=false
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if [ $RETRY_COUNT -gt 0 ]; then
            echo ""
            echo "Retry attempt $RETRY_COUNT of $MAX_RETRIES..."
            if [ "$AUTH_NEEDED" = true ]; then
                echo ""
                echo "═══════════════════════════════════════════════════════════"
                echo "  MANUAL AUTHENTICATION REQUIRED"
                echo "═══════════════════════════════════════════════════════════"
                echo ""
                echo "SteamCMD requires Steam Guard authentication to complete the update."
                echo "The update has downloaded and verified, but needs authentication to finalize."
                echo ""
                echo "Steps to authenticate:"
                echo "  1. Open a new terminal and run:"
                echo "     kubectl exec -it -n dayz deployment/dayz -c dayz -- /bin/bash"
                echo ""
                echo "  2. Inside the container, run:"
                echo "     steamcmd +force_install_dir /home/steam/dayz +login \$STEAMACCOUNT \$STEAMPASSWORD +app_update ${APPID} +quit"
                echo ""
                echo "  3. When prompted, enter the Steam Guard code from your iOS app"
                echo "  4. Wait for SteamCMD to complete (it will finalize the update)"
                echo ""
                echo "After authentication, this script will automatically detect the DayZServer"
                echo "binary and continue. You can also restart the container."
                echo ""
                echo "Waiting 60 seconds for manual authentication..."
                echo "═══════════════════════════════════════════════════════════"
                sleep 60
            else
                sleep 10
            fi
        fi
        
        echo "Attempting update (attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)..."
        echo "  Steam account: ${STEAMACCOUNT}"
        echo "  App ID: ${APPID}"
        echo "  Install directory: ${HOME}/${GAME}"
        echo "  Starting SteamCMD..."
        echo ""
        
        # Run SteamCMD and sanitize password from logs
        # Use unbuffered output for real-time visibility (if stdbuf available)
        if command -v stdbuf >/dev/null 2>&1; then
            steamcmd \
	        +force_install_dir ${HOME}/${GAME} \
                +login ${STEAMACCOUNT} ${STEAMPASSWORD} \
                +app_update ${APPID} \
                +quit 2>&1 | stdbuf -oL -eL sed "s/${STEAMPASSWORD}/[REDACTED]/g" | tee /tmp/steamcmd_update.log
        else
            # Fallback: use script or just tee (which should be unbuffered by default)
            steamcmd \
	        +force_install_dir ${HOME}/${GAME} \
                +login ${STEAMACCOUNT} ${STEAMPASSWORD} \
                +app_update ${APPID} \
                +quit 2>&1 | sed "s/${STEAMPASSWORD}/[REDACTED]/g" | tee /tmp/steamcmd_update.log
        fi
        
        UPDATE_EXIT=${PIPESTATUS[0]}
        
        echo ""
        echo "SteamCMD exited with code: $UPDATE_EXIT"
        
        # Check if update was successful
        echo "Checking for DayZServer binary..."
        if [ -f ${HOME}/${GAME}/DayZServer ]; then
            echo "✅ DayZServer binary found at ${HOME}/${GAME}/DayZServer"
            ls -lh ${HOME}/${GAME}/DayZServer 2>/dev/null || true
            if [ $UPDATE_EXIT -eq 0 ]; then
                echo "✅ DayZ server updated successfully!"
                return 0
            else
                echo "⚠️  DayZServer exists but SteamCMD exited with code $UPDATE_EXIT"
                echo "   This might indicate a partial update - continuing anyway..."
                return 0
            fi
        else
            echo "❌ DayZServer binary not found at ${HOME}/${GAME}/DayZServer"
            echo "   Checking for files in install directory..."
            ls -la ${HOME}/${GAME}/ 2>/dev/null | head -20 || echo "   Directory listing failed"
            
            # Check if files are stuck in downloading directory
            if [ -f "${HOME}/${GAME}/steamapps/downloading/223350/DayZServer" ]; then
                echo ""
                echo "⚠️  Found DayZServer in downloading directory - update not finalized!"
                echo "   This means SteamCMD downloaded the files but couldn't complete the update."
                echo "   The files need to be finalized with proper authentication."
                echo "   Size of stuck download:"
                du -sh "${HOME}/${GAME}/steamapps/downloading/223350" 2>/dev/null || true
            fi
        fi
        
        # Check if authentication is needed
        # Error 0x602 typically indicates authentication/session issues
        echo "Analyzing SteamCMD output for errors..."
        AUTH_NEEDED=false
        
        if grep -qi "two-factor\|two factor\|Steam Guard\|code mismatch\|Invalid Password\|need two-factor" /tmp/steamcmd_update.log 2>/dev/null; then
            AUTH_NEEDED=true
            echo "⚠️  Steam Guard authentication required"
            grep -i "two-factor\|two factor\|Steam Guard\|code mismatch" /tmp/steamcmd_update.log 2>/dev/null | head -3 || true
        fi
        
        if grep -qi "0x602\|state is 0x602" /tmp/steamcmd_update.log 2>/dev/null; then
            AUTH_NEEDED=true
            echo "⚠️  Error 0x602 detected - SteamCMD session expired or authentication needed"
            grep -i "0x602\|state is 0x602" /tmp/steamcmd_update.log 2>/dev/null | head -3 || true
        fi
        
        if [ "$AUTH_NEEDED" = false ]; then
            echo "⚠️  Update failed (exit code: $UPDATE_EXIT)"
            echo "   Last 10 lines of SteamCMD output:"
            tail -10 /tmp/steamcmd_update.log 2>/dev/null | sed 's/^/   /' || true
            echo "   Checking for other error patterns..."
            if grep -qi "error\|failed\|timeout" /tmp/steamcmd_update.log 2>/dev/null; then
                echo "   Found error messages in log:"
                grep -i "error\|failed\|timeout" /tmp/steamcmd_update.log 2>/dev/null | tail -5 | sed 's/^/   /' || true
            fi
        fi
        
        RETRY_COUNT=$((RETRY_COUNT + 1))
    done
    
    # Final check
    if [ -f ${HOME}/${GAME}/DayZServer ]; then
        echo "✅ DayZServer binary found, continuing..."
        return 0
    else
        echo "❌ DayZServer binary not found after $MAX_RETRIES attempts"
        echo "Please authenticate manually by exec'ing into the container"
        return 1
    fi
}

function setupBattleye() {
	if [ ! -f ${HOME}/battleye/beserver_x64.dll ] || [ ! -f ${HOME}/battleye/beserver_x64.so ];then
		if [ -f ${HOME}/${GAME}/battleye/beserver_x64.dll ] || [ -f ${HOME}/${GAME}/battleye/beserver_x64.so ];then
			cd ${HOME}/battleye
			ln -s ${HOME}/${GAME}/battleye/beserver_x64.dll
			ln -s ${HOME}/${GAME}/battleye/beserver_x64.so
		fi
	fi
}

function startGame() {
    # Verify DayZServer exists before trying to start
    if [ ! -f ${HOME}/${GAME}/DayZServer ]; then
        echo "❌ ERROR: DayZServer binary not found at ${HOME}/${GAME}/DayZServer"
        echo "The server files may not have been downloaded successfully."
        echo "Please check the logs and ensure SteamCMD authentication completed."
        exit 1
    fi
    
	cd ${HOME}/${GAME}
	${HOME}/${GAME}/DayZServer -config="${HOME}/serverDZ.cfg" -adminlog -netlog --dologs --freezeCheck -cpuCount=${CPUCOUNT} -port=${PORT} -profiles=${HOME}/profile -BEpath=${HOME}/battleye ${MODS:+-mod=$MODS}
}

updateGame
setupBattleye
startGame