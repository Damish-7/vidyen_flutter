# VIDYEN Server Quick Start Guide

## The Problem
Every morning when you start work, the PHP backend server is not running because it stops when you shut down your computer.

## Quick Solutions

### Method 1: Double-Click Batch File (Easiest)
1. Double-click `start_server.bat` in the project root
2. Keep the window open while working
3. Server will run on `http://192.168.14.24:8000`

### Method 2: VS Code Task (Recommended)
1. Press `Ctrl+Shift+P`
2. Type "Run Task"
3. Select "Start PHP Server"
4. The server starts in a VS Code terminal

### Method 3: Manual Command
Open PowerShell/Terminal in project folder:
```powershell
cd api
php -S 0.0.0.0:8000 router.php
```

## How to Verify Server is Running

### Check 1: Look for PHP process
```powershell
Get-Process php -ErrorAction SilentlyContinue
```
If you see a result, server is running.

### Check 2: Test in browser
Open: http://localhost:8000/auth/login
Should show a JSON response.

### Check 3: Check port 8000
```powershell
netstat -an | Select-String ":8000"
```
Should show "LISTENING"

## Troubleshooting

### If login still fails:
1. ✅ Check server is running (see above)
2. ✅ Check MySQL is running (MAMP)
3. ✅ Phone and PC on same WiFi
4. ✅ Use correct IP in app config

### Current Configuration
- **Server IP:** 192.168.14.24:8000
- **Database:** vidyen (MySQL)
- **Config file:** lib/config/api_config.dart

### Valid Login Credentials
- Admin: `sivapriyavn` / `admin`
- User: `trina@gmail.com` / `12345`
- Reviewer: `revi12@gmail.com` / `123456789`

## Note
The server must stay running while you test the app. Don't close the terminal/window!
