# Start VIDYEN PHP Backend Server
Write-Host "Starting VIDYEN PHP Backend Server..." -ForegroundColor Green
Write-Host ""
Write-Host "Server will be accessible at:" -ForegroundColor Cyan
Write-Host "  - Local:   http://localhost:8000" -ForegroundColor White
Write-Host "  - Network: http://192.168.14.24:8000 (or your current IP)" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

Set-Location -Path "$PSScriptRoot\api"
php -S 0.0.0.0:8000 router.php
