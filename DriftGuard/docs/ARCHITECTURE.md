# Architecture

```
┌─────────────┐     HTTPS      ┌──────────────┐
│ React / TS  │ ─────────────► │ FastAPI API  │
│ Tailwind UI │ ◄───────────── │ /api/v1/*    │
└─────────────┘                └──────┬───────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                 ▼
              PostgreSQL         Collectors        Remediation
              + audit log     SSH/WinRM/Agent      dry-run → apply
                              Cloud SDK stubs      approval queue
```

## Packages

- `backend/app/collectors` — inventory collectors  
- `backend/app/services/drift_engine.py` — desired vs actual  
- `backend/app/services/remediation.py` — plans & safe apply  
- `frontend/src/pages` — console + marketing landing with demo videos  

## Desired state

Examples live in `desired-state/examples/`. Systems link via `desired_state_id`.
