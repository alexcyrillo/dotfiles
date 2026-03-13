#!/bin/bash

pkill -9 steam
flatpak kill com.valvesoftware.Steam

cosmic-randr enable HDMI-A-1
cosmic-randr disable DP-2 
cosmic-randr disable DP-3 

sleep 2

steam -gamepadui

GAME_PID=$!

wait $GAME_PID

sleep 0.2
cosmic-randr enable DP-2
sleep 0.2
cosmic-randr enable DP-3
sleep 0.2
cosmic-randr disable HDMI-A-1