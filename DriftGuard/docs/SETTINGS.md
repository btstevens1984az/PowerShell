# DriftGuard options & settings

Settings appear in the **Settings** console page and as environment variables. UI changes require the **admin** role and are written to the audit log.

## Console settings (persisted in DB)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `remediation.dry_run_default` | bool | `true` | Prefer dry-run before live apply |
| `collector.interval_minutes` | int | `15` | Suggested scheduler interval |
| `collector.timeout_seconds` | int | `120` | Per-system collector timeout |
| `notifications.critical_webhook` | string | `""` | Webhook for critical drifts |
| `notifications.email_enabled` | bool | `false` | Email digests |
| `git.desired_state_sync` | bool | `false` | Enable Git sync of baselines |
| `git.repo_url` | string | `""` | Git remote for desired state |
| `git.branch` | string | `main` | Branch to sync |
| `ui.theme` | string | `system` | `light` \| `dark` \| `system` |
| `security.session_hours` | int | `8` | Access token lifetime (hours) |
| `security.require_mfa_for_apply` | bool | `false` | Gate live apply behind MFA (flag) |
| `severity.auto_acknowledge_info` | bool | `true` | Auto-ack info findings |

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | yes | SQLAlchemy URL (`sqlite:///…` or `postgresql+psycopg2://…`) |
| `SECRET_KEY` | yes (prod) | JWT signing key — use `openssl rand -hex 32` |
| `SECRETS_FERNET_KEY` | recommended | Fernet key for credential encryption |
| `SEED_DEMO_DATA` | no | `true` loads demo fleet/users |
| `CORS_ORIGINS` | no | Comma-separated frontend origins |
| `API_PREFIX` | no | Default `/api/v1` |
| `REMEDIATION_DRY_RUN_DEFAULT` | no | Safety default |
| `MAX_PARALLEL_COLLECTORS` | no | Collector concurrency |
| `COLLECTOR_TIMEOUT_SECONDS` | no | Soft timeout guidance |
| `DESIRED_STATE_GIT_URL` | no | Git remote for baselines |
| `DESIRED_STATE_GIT_BRANCH` | no | Default `main` |
| `DESIRED_STATE_LOCAL_PATH` | no | Local checkout path |
| `SMTP_HOST` / `SMTP_PORT` / `SMTP_USER` / `SMTP_PASSWORD` | no | Email notifications |
| `NOTIFY_FROM` | no | From address |
| `WEBHOOK_URL` | no | Global webhook |

## Roles (RBAC)

| Role | Capabilities |
|------|----------------|
| **viewer** | Read dashboard, systems, drifts, desired state |
| **auditor** | viewer + audit trail |
| **operator** | auditor + collect, create remediations, edit systems/desired state |
| **admin** | operator + approve/apply remediations, manage users & settings |

## Collector types

| Type | Platforms | Notes |
|------|-----------|-------|
| `ssh` | Linux / network | Paramiko; falls back to simulated payload if unreachable |
| `winrm` | Windows | Stub inventory in MVP; ready for pywinrm wiring |
| `agent` | any | Push via `agents/driftguard-agent.py` |
| `local` | DriftGuard host | Self-check |
| `api` | cloud | AWS/Azure/GCP stub resources |

## Remediation safety model

1. Operator requests remediation (`dry_run=true` by default).  
2. Admin **approves** → executes dry-run plan.  
3. Admin **Apply live** → marks finding resolved (mutations simulated in MVP).  
4. Every step is audited.

## Demo accounts

| Email | Password | Role |
|-------|----------|------|
| `admin@driftguard.example` | `DriftGuard!admin` | admin |
| `ops@driftguard.example` | `DriftGuard!ops` | operator |
| `viewer@driftguard.example` | `DriftGuard!view` | viewer |

Change these before any shared deployment (`SEED_DEMO_DATA=false`).
