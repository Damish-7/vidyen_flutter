@echo off
echo ============================================
echo FIXING NGINX PORT 80 CONFLICT
echo ============================================
echo.

echo Step 1: Killing all nginx processes...
taskkill /F /IM nginx.exe 2>nul
if %errorlevel%==0 (
    echo   - Successfully killed nginx processes
) else (
    echo   - No nginx processes found or already stopped
)

echo.
echo Step 2: Waiting 3 seconds...
timeout /t 3 >nul

echo.
echo Step 3: Checking if port 80 is free...
netstat -an | findstr ":80 " | findstr "LISTENING" >nul
if %errorlevel%==0 (
    echo   - WARNING: Port 80 still in use!
    echo   - Another program might be using it.
    echo.
    echo Programs that might use port 80:
    echo   - IIS (Internet Information Services)
    echo   - Skype
    echo   - VMware
    echo   - Other web servers
) else (
    echo   - Port 80 is now FREE!
)

echo.
echo ============================================
echo DONE! Now try starting MAMP again.
echo ============================================
echo.
pause
