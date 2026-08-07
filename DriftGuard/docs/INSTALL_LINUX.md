# Install DriftGuard on Linux

This guide covers **Ubuntu/Debian**, **RHEL/Rocky**, and a **Docker Compose** path (recommended).

## Prerequisites

| Component | Version |
|-----------|---------|
| Docker Engine + Compose plugin | 24+ (recommended path) |
| OR Python | 3.12+ |
| OR Node.js | 20+ (22 recommended) |
| Git | any recent |
| Optional PostgreSQL | 15+ if not using Compose |

---

## Option A — Docker Compose (recommended)

```bash
# Install Docker (Ubuntu example)
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# …follow Docker's official install for your distro…
sudo usermod -aG docker "$USER"   # then log out/in

git clone https://github.com/btstevens1984az/DriftGuard.git
cd DriftGuard   # or: cd PowerShell/DriftGuard if cloned from the PowerShell monorepo

# Generate secrets
export SECRET_KEY=$(openssl rand -hex 32)

docker compose up --build -d
```

Open:

- **UI:** http://localhost:5173  
- **API docs:** http://localhost:8000/docs  
- **Health:** http://localhost:8000/health  

Demo login: `admin@driftguard.example` / `DriftGuard!admin`

Stop:

```bash
docker compose down
```

Persist DB volume:

```bash
docker compose down   # keeps pgdata volume
docker volume ls | grep driftguard
```

---

## Option B — Local Python + Node (no Docker)

### 1. Backend

```bash
cd DriftGuard/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# SQLite (simplest)
export DATABASE_URL=sqlite:///./driftguard.db
export SECRET_KEY=$(openssl rand -hex 32)
export SEED_DEMO_DATA=true
export CORS_ORIGINS=http://localhost:5173

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 2. Frontend (new terminal)

```bash
cd DriftGuard/frontend
npm install
npm run dev
```

Open http://localhost:5173

### 3. PostgreSQL instead of SQLite

```bash
sudo apt-get install -y postgresql postgresql-contrib
sudo -u postgres createuser driftguard
sudo -u postgres createdb -O driftguard driftguard
sudo -u postgres psql -c "ALTER USER driftguard PASSWORD 'driftguard';"

export DATABASE_URL=postgresql+psycopg2://driftguard:driftguard@127.0.0.1:5432/driftguard
```

---

## systemd unit (API)

`/etc/systemd/system/driftguard-api.service`:

```ini
[Unit]
Description=DriftGuard API
After=network.target postgresql.service

[Service]
User=driftguard
WorkingDirectory=/opt/driftguard/backend
Environment=DATABASE_URL=postgresql+psycopg2://driftguard:REDACTED@127.0.0.1:5432/driftguard
Environment=SECRET_KEY=REDACTED
Environment=SEED_DEMO_DATA=false
ExecStart=/opt/driftguard/backend/.venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now driftguard-api
```

Serve the frontend with nginx pointing at `frontend/dist` (see `frontend/nginx.conf`).

---

## Firewall notes

| Port | Service |
|------|---------|
| 5173 / 80 | Web UI |
| 8000 | API |
| 5432 | PostgreSQL (bind to localhost in production) |

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

---

## Verify

```bash
curl -s http://127.0.0.1:8000/health
cd DriftGuard/backend && source .venv/bin/activate && pytest -q
```

See also: [SETTINGS.md](./SETTINGS.md), [INSTALL_WINDOWS.md](./INSTALL_WINDOWS.md).
