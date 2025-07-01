@echo off
echo 🔧 Fluxo Build Environment Setup
echo ===============================
echo.

echo Checking build environment...
echo.

REM Check if Visual Studio Build Tools are installed
where cl.exe >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ Visual Studio Build Tools: FOUND
    cl.exe 2>&1 | findstr "Microsoft" >nul
    if %errorlevel% equ 0 (
        echo ✅ C++ Compiler: WORKING
    ) else (
        echo ❌ C++ Compiler: NOT WORKING
        goto :missing_tools
    )
) else (
    echo ❌ Visual Studio Build Tools: NOT FOUND
    goto :missing_tools
)

REM Check Rust installation
where cargo >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ Rust/Cargo: FOUND
    cargo --version
) else (
    echo ❌ Rust/Cargo: NOT FOUND
    echo.
    echo Please install Rust from: https://rustup.rs/
    echo Then run this script again.
    pause
    exit /b 1
)

REM Check optional tools
echo.
echo Checking optional tools...

where rojo >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ Rojo: FOUND
    rojo --version
) else (
    echo ⚠️  Rojo: NOT FOUND ^(needed for Studio plugin building^)
    echo    Install with: cargo install rojo
)

where node >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ Node.js: FOUND
    node --version
) else (
    echo ⚠️  Node.js: NOT FOUND ^(needed for web dashboard^)
    echo    Install from: https://nodejs.org/
)

echo.
echo 🎉 Build environment ready!
echo.
echo Next steps:
echo 1. cargo build --release
echo 2. test-integration.bat
echo 3. Install FluxoPlugin.rbxmx in Studio
echo.
pause
exit /b 0

:missing_tools
echo.
echo 📥 Installing Visual Studio Build Tools...
echo.
echo Please download and install from:
echo https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
echo.
echo During installation, make sure to select:
echo ✅ C++ build tools
echo ✅ Windows 10/11 SDK
echo ✅ CMake tools for C++
echo.
echo After installation:
echo 1. Restart your terminal
echo 2. Run this script again
echo 3. Continue with Fluxo setup
echo.
pause
exit /b 1
