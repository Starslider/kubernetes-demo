#!/bin/bash

function updateGame() {
    # Check if DayZServer already exists - if so, skip update
    if [ -f ${HOME}/${GAME}/DayZServer ]; then
        echo "✅ DayZServer binary already exists, skipping update..."
        return 0
    fi
    
    echo "=== Updating DayZ server via SteamCMD ==="
    echo "Attempting automated update..."
    
    # Try automated update first
    steamcmd \
	+force_install_dir ${HOME}/${GAME} \
        +login ${STEAMACCOUNT} ${STEAMPASSWORD} \
        +app_update ${APPID} \
        +quit 2>&1 | tee /tmp/steamcmd_update.log
    
    UPDATE_EXIT=${PIPESTATUS[0]}
    
    # Check if update was successful
    if [ $UPDATE_EXIT -eq 0 ] && [ -f ${HOME}/${GAME}/DayZServer ]; then
        echo "✅ DayZ server updated successfully!"
        return 0
    fi
    
    # Check if authentication is needed
    if grep -qi "two-factor\|two factor\|Steam Guard\|code mismatch\|Invalid Password" /tmp/steamcmd_update.log 2>/dev/null; then
        echo ""
        echo "⚠️  SteamCMD requires Steam Guard authentication"
        echo ""
        echo "To authenticate manually, exec into the container and run:"
        echo "  kubectl exec -it -n dayz deployment/dayz -c dayz -- /bin/bash"
        echo ""
        echo "Then run SteamCMD interactively:"
        echo "  steamcmd +force_install_dir /home/steam/dayz +login ${STEAMACCOUNT} ${STEAMPASSWORD} +app_update ${APPID} +quit"
        echo ""
        echo "When prompted, enter the Steam Guard code from your iOS app."
        echo "After successful authentication, SteamCMD will cache the session."
        echo ""
        echo "Waiting 60 seconds for manual authentication..."
        echo "If you've already authenticated, the server will continue automatically."
        sleep 60
        
        # Retry after waiting (in case user authenticated in another session)
        echo ""
        echo "Retrying update after manual authentication window..."
        steamcmd \
	    +force_install_dir ${HOME}/${GAME} \
            +login ${STEAMACCOUNT} ${STEAMPASSWORD} \
            +app_update ${APPID} \
            +quit 2>&1 | tee /tmp/steamcmd_update_retry.log
        
        UPDATE_EXIT=${PIPESTATUS[0]}
    fi
    
    # Final check
    if [ -f ${HOME}/${GAME}/DayZServer ]; then
        echo "✅ DayZServer binary found, continuing..."
        return 0
    else
        echo "❌ DayZServer binary not found after update attempt"
        echo "Please authenticate manually by exec'ing into the container"
        echo "See instructions above for manual authentication steps"
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