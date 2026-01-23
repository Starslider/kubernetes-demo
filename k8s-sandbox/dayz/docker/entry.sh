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
        rm -rf "${HOME}/${GAME}/steamapps/downloading" 2>/dev/null || true
        echo "   Cleanup complete"
    fi
    
    echo "=== Updating DayZ server via SteamCMD ==="
    
    MAX_RETRIES=10
    RETRY_COUNT=0
    AUTH_NEEDED=false
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if [ $RETRY_COUNT -gt 0 ]; then
            echo ""
            echo "Retry attempt $RETRY_COUNT of $MAX_RETRIES..."
            if [ "$AUTH_NEEDED" = true ]; then
                echo "Waiting 30 seconds for manual authentication..."
                echo "To authenticate, exec into the container:"
                echo "  kubectl exec -it -n dayz deployment/dayz -c dayz -- /bin/bash"
                echo "Then run: steamcmd +force_install_dir /home/steam/dayz +login [USERNAME] [PASSWORD] +app_update ${APPID} +quit"
                sleep 30
            else
                sleep 10
            fi
        fi
        
        echo "Attempting update (attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)..."
        
        # Run SteamCMD and sanitize password from logs
        steamcmd \
	    +force_install_dir ${HOME}/${GAME} \
            +login ${STEAMACCOUNT} ${STEAMPASSWORD} \
            +app_update ${APPID} \
            +quit 2>&1 | sed "s/${STEAMPASSWORD}/[REDACTED]/g" | tee /tmp/steamcmd_update.log
        
        UPDATE_EXIT=${PIPESTATUS[0]}
        
        # Check if update was successful
        if [ $UPDATE_EXIT -eq 0 ] && [ -f ${HOME}/${GAME}/DayZServer ]; then
            echo "✅ DayZ server updated successfully!"
            return 0
        fi
        
        # Check if authentication is needed
        # Error 0x602 typically indicates authentication/session issues
        if grep -qi "two-factor\|two factor\|Steam Guard\|code mismatch\|Invalid Password\|need two-factor\|0x602\|state is 0x602" /tmp/steamcmd_update.log 2>/dev/null; then
            AUTH_NEEDED=true
            echo "⚠️  Steam Guard authentication required"
            if grep -qi "0x602" /tmp/steamcmd_update.log 2>/dev/null; then
                echo "   Error 0x602 detected - SteamCMD session expired or authentication needed"
            fi
        else
            AUTH_NEEDED=false
            echo "⚠️  Update failed (exit code: $UPDATE_EXIT)"
            # Check for other common errors
            if grep -qi "0x602" /tmp/steamcmd_update.log 2>/dev/null; then
                echo "   Error 0x602: Authentication or session issue - will retry with authentication"
                AUTH_NEEDED=true
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