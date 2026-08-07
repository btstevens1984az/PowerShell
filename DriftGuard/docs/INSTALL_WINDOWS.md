# Install DriftGuard on Windows

Supports **Windows 10/11** and **Windows Server 2019+**. Prefer **Docker Desktop** when available; otherwise use native Python + Node.

## Prerequisites

| Component | Notes |
|-----------|-------|
| Docker Desktop | WSL2 backend recommended |
| OR Python 3.12 | From python.org — check “Add to PATH” |
| OR Node.js 22 LTS | From nodejs.org |
| Git for Windows | Includes Git Bash |
| Optional | Windows Terminal, PowerShell 7 |

---

## Option A — Docker Desktop (recommended)

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) and enable WSL2.
2. Open **PowerShell**:

```powershell
git clone https://github.com/btstevens1984az/DriftGuard.git
cd DriftGuard
# If this folder lives inside the PowerShell monorepo:
# cd .\DriftGuard

docker compose up --build -d
```

3. Browse to http://localhost:5173  
4. Sign in: `admin@driftguard.example` / `DriftGuard!admin`

Stop:

```powershell
docker compose down
```

---

## Option B — Native Python + Node (no Docker)

### Backend

```powershell
cd DriftGuard\backend
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt

$env:DATABASE_URL = "sqlite:///./driftguard.db"
$env:SECRET_KEY = -join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Max 16) })
$env:SEED_DEMO_DATA = "true"
$env:CORS_ORIGINS = "http://localhost:5173"

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

If execution policy blocks venv activation:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Frontend (new PowerShell window)

```powershell
cd DriftGuard\frontend
npm install
npm run dev
```

Open http://localhost:5173

---

## WinRM collector notes

DriftGuard’s Windows collector is a **WinRM-ready stub** in the MVP (safe simulated inventory). To prepare real targets later:

```powershell
# On the managed Windows host (elevated)
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "driftguard-host" -Force
```

Store credentials via DriftGuard’s encrypted secret store (never commit passwords). Connection fields live on each system’s `connection_config` JSON (host, username, etc.).

---

## Run as a Windows Service (API)

Use [NSSM](https://nssm.cc/) or Task Scheduler:

```powershell
nssm install DriftGuardApi "C:\opt\driftguard\backend\.venv\Scripts\uvicorn.exe"
nssm set DriftGuardApi AppDirectory "C:\opt\driftguard\backend"
nssm set DriftGuardApi AppParameters "app.main:app --host 127.0.0.1 --port 8000"
nssm set DriftGuardApi AppEnvironmentExtra DATABASE_URL=sqlite:///./driftguard.db SECRET_KEY=...
nssm start DriftGuardApi
```

---

## Firewall

```powershell
New-NetFirewallRule -DisplayName "DriftGuard UI" -Direction Inbound -Protocol TCP -LocalPort 5173 -Action Allow
New-NetFirewallRule -DisplayName "DriftGuard API" -Direction Inbound -Protocol TCP -LocalPort 8000 -Action Allow
```

---

## Verify

```powershell
Invoke-RestMethod http://127.0.0.1:8000/health
cd DriftGuard\backend
.\.venv\Scripts\Activate.ps1
pytest -q
```

See also: [SETTINGS.md](./SETTINGS.md), [INSTALL_LINUX.md](./INSTALL_LINUX.md).
