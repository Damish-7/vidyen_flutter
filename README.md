# VIDYEN Flutter App

A Flutter mobile application that replicates the VIDYEN Conference Management System with a fully token-based JSON REST API backend.

---

## Quick Start (Every Morning) 🚀

**The PHP server must be running for the app to work!**

### Option 1: Double-click `start_server.bat`
Just double-click the file in the project root folder.

### Option 2: VS Code Task
1. Press `Ctrl+Shift+P`
2. Type "Run Task"
3. Select "Start PHP Server"

### Option 3: Command Line
```bash
cd api
php -S 0.0.0.0:8000 router.php
```

📚 **See [README_SERVER.md](README_SERVER.md) for detailed troubleshooting**

---

## Project Layout

```
vidyen_flutter/          ← Flutter app + PHP REST API (this folder)
vidyen_flutter/api/      ← New PHP REST API (token-based, JSON)
vidyen/decyen/           ← Original PHP web panel (unchanged)
```

---

## PHP API

**Base URL:** `http://localhost/vidyen_flutter/api/`

### Authentication (no token needed)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Login → returns JWT token |
| POST | `/registration` | Public conference registration |

### Authenticated (Bearer token required)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/auth/me` | Get current user |
| POST | `/auth/change-password` | Change password |
| GET | `/registration/me` | My registration |
| POST | `/abstracts` | Submit abstract |
| GET | `/abstracts/my` | My abstracts |
| GET | `/abstracts/{id}` | View abstract |
| POST | `/preconference` | Submit pre-conference |
| GET | `/preconference/my` | My pre-conference |
| GET | `/preconference/{id}` | View pre-conference |
| POST | `/workshop` | Submit workshop |
| GET | `/workshop/my` | My workshops |
| GET | `/workshop/{id}` | View workshop |
| GET | `/certificates/my` | My certificates |
| GET | `/certificates/{type}/{regCode}` | Certificate download URL |

### Admin (admin token required)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/dashboard` | Stats summary |
| GET | `/admin/registrations` | All registrations |
| GET | `/admin/registrations/{code}` | One registration |
| PUT | `/admin/registrations/{code}/activate` | Activate participant |
| GET | `/admin/abstracts` | All abstracts |
| PUT | `/admin/abstracts/{id}/status` | Update abstract status |
| GET | `/admin/preconference` | All pre-conference submissions |
| PUT | `/admin/preconference/{id}/status` | Update status |
| GET | `/admin/workshop` | All workshop submissions |
| PUT | `/admin/workshop/{id}/status` | Update status |
| GET | `/admin/certificates` | All certificates |
| GET | `/admin/users` | All users |
| PUT | `/admin/users/{id}/toggle-status` | Activate/deactivate user |
| GET | `/admin/messages` | Contact messages |
| GET | `/admin/reviewers` | All reviewers |

---

## Login Request / Response

```json
// POST /vidyen_flutter/api/auth/login
// Body:
{ "username": "user@email.com", "password": "secret" }

// Response:
{
  "status": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1Ni...",
    "usertype": "admin",
    "user_id": "1",
    "name": "Dr. John",
    "email": "user@email.com",
    "expires_in": 86400
  }
}
```

Use the token in all subsequent requests:
```
Authorization: Bearer <token>
```

---

## Flutter App Setup

### Prerequisites
- Flutter SDK >= 3.0
- MAMP (MySQL + Apache) running

### Run
```bash
cd vidyen_flutter
flutter pub get
flutter run
```

### Configuration
Edit `lib/config/api_config.dart`:
- **Android emulator:**  `http://10.0.2.2/vidyen_flutter/api`
- **Physical device:**   `http://YOUR_MACHINE_IP/vidyen_flutter/api`
- **Web / iOS simulator:** `http://localhost/vidyen_flutter/api`

---

## User Roles
| Role | Access |
|------|--------|
| `participant` | Register, submit abstracts/preconf/workshop, view certificates |
| `admin` | Full dashboard, activate participants, manage submissions |
| `reviewer` | View and evaluate assigned abstracts |
