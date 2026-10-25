@echo off
title LA PAILA DEL ATRATO: CANDELA EN QUIBDO 3D
set "DIR=%~dp0"
set "G1=%DIR%index.html"
start msedge --app="file:///%G1:\=/%" --start-fullscreen 2>nul || start chrome --app="file:///%G1:\=/%" --start-fullscreen 2>nul || start "" "%G1%"
