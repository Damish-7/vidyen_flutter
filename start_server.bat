@echo off
echo Starting VIDYEN PHP Backend Server...
echo.
echo Server will be accessible at:
echo - Local: http://localhost:8000
echo - Network: http://192.168.14.24:8000 (or your current IP)
echo.
echo Press Ctrl+C to stop the server
echo.
cd /d "%~dp0api"
php -S 0.0.0.0:8000 router.php
