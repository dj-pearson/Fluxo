@echo off
REM Build script for Fluxo Studio Plugin

echo Building Fluxo Studio Plugin...

REM Check if rojo is installed
where rojo >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Rojo is not installed. Please install it first:
    echo   cargo install rojo
    exit /b 1
)

REM Build the plugin
rojo build studio-plugin --output Fluxo.rbxmx

if %errorlevel% equ 0 (
    echo ✅ Plugin built successfully: Fluxo.rbxmx
    echo.
    echo To install in Studio:
    echo 1. Open Roblox Studio
    echo 2. Go to Plugins → Manage Plugins
    echo 3. Click "Install from file..."
    echo 4. Select Fluxo.rbxmx
) else (
    echo ❌ Build failed
    exit /b 1
)
