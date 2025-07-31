@echo off
echo Building TremoMidi Installer...
echo.

REM Check if Inno Setup is installed
where iscc >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Inno Setup Compiler (iscc) not found in PATH
    echo Please install Inno Setup from: https://jrsoftware.org/isinfo.php
    echo After installation, make sure iscc.exe is in your PATH
    pause
    exit /b 1
)

REM Build Flutter app
echo Building Flutter application...
flutter build windows --release
if %errorlevel% neq 0 (
    echo Error: Flutter build failed
    pause
    exit /b 1
)

REM Build installer
echo Building installer...
iscc setup.iss
if %errorlevel% neq 0 (
    echo Error: Inno Setup compilation failed
    pause
    exit /b 1
)

echo.
echo Installer created successfully!
echo Location: installer\TremoMidi-Setup.exe
echo.
pause 