#!/bin/bash

function updateGame() {
    # Check if DayZServer already exists - if so, skip update
    if [ -f ${HOME}/${GAME}/DayZServer ]; then
        echo "DayZServer binary already exists, skipping update..."
        return 0
    fi
    
    echo "Updating DayZ server via SteamCMD..."
    echo "Note: If SteamCMD prompts for Steam Guard code, you'll need to authenticate manually"
    
    steamcmd \
	+force_install_dir ${HOME}/${GAME} \
        +login ${STEAMACCOUNT} ${STEAMPASSWORD} \
        +app_update ${APPID} \
        +quit
    
    UPDATE_EXIT=$?
    
    # Check if update was successful or if server files exist anyway
    if [ $UPDATE_EXIT -ne 0 ]; then
        echo "⚠️  SteamCMD update returned exit code $UPDATE_EXIT"
        if [ -f ${HOME}/${GAME}/DayZServer ]; then
            echo "✅ DayZServer binary exists despite update error, continuing..."
            return 0
        else
            echo "❌ DayZServer binary not found after update attempt"
            echo "You may need to manually authenticate with SteamCMD first"
            return 1
        fi
    fi
    
    return 0
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