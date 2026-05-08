@echo off
REM SHVAPE local launcher
REM Starts a static HTTP server in this folder, then opens the game.
cd /d "%~dp0"
echo.
echo  SHVAPE - Ein Mutschelbach-Abenteuer
echo  ====================================
echo  Server laeuft auf http://localhost:8000/
echo  Drueck Strg+C zum Beenden.
echo.
start "" "http://localhost:8000/"
python -m http.server 8000
