@echo off
echo 🔧 Fixing Selene Configuration Issues
echo ====================================

echo.
echo Checking Selene configuration...

if exist "studio-plugin\selene.toml" (
    echo ✅ Studio plugin selene.toml found
) else (
    echo ❌ Studio plugin selene.toml missing
    goto :error
)

if exist "selene.toml" (
    echo ✅ Root selene.toml found
) else (
    echo ❌ Root selene.toml missing
    goto :error
)

echo.
echo Verifying Roblox standard library configuration...
findstr /C:"std = \"roblox\"" studio-plugin\selene.toml >nul
if %errorlevel%==0 (
    echo ✅ Studio plugin configured for Roblox
) else (
    echo ❌ Studio plugin not configured for Roblox
    goto :error
)

findstr /C:"std = \"roblox\"" selene.toml >nul
if %errorlevel%==0 (
    echo ✅ Root configuration set for Roblox
) else (
    echo ❌ Root configuration not set for Roblox
    goto :error
)

echo.
echo 🎉 Selene configuration is correct!
echo.
echo If you're still seeing errors in VS Code:
echo 1. Restart VS Code completely
echo 2. Press Ctrl+Shift+P and run "Developer: Reload Window"
echo 3. Ensure the Selene VS Code extension is installed
echo 4. Check VS Code settings for Selene configuration
echo.
pause
exit /b 0

:error
echo.
echo ❌ Configuration issues found!
echo Please check the Selene configuration files.
echo.
pause
exit /b 1
