@echo off
cd /d "%~dp0"
set "GODOT=C:\Users\cuong\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (
    echo Godot executable not found at %GODOT%
    pause
    exit /b 1
)
start "" "%GODOT%" --editor --path "%~dp0."
exit /b 0
