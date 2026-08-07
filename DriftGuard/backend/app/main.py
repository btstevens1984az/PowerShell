"""DriftGuard FastAPI application entrypoint."""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app import __version__
from app.api import audit, auth, collect, dashboard, desired_states, drifts, remediations, settings, systems
from app.config import get_settings
from app.database import SessionLocal, init_db
from app.seed.demo import seed_demo

cfg = get_settings()


@asynccontextmanager
async def lifespan(_app: FastAPI):
    init_db()
    if cfg.seed_demo_data:
        db = SessionLocal()
        try:
            seed_demo(db)
        finally:
            db.close()
    yield


app = FastAPI(
    title=cfg.app_name,
    version=__version__,
    description="Configuration drift detection & remediation assistant",
    lifespan=lifespan,
)

origins = list(cfg.cors_origin_list)
if cfg.debug and "*" not in origins:
    origins.append("http://localhost:5173")
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins or ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

prefix = cfg.api_prefix
app.include_router(auth.router, prefix=prefix)
app.include_router(systems.router, prefix=prefix)
app.include_router(desired_states.router, prefix=prefix)
app.include_router(drifts.router, prefix=prefix)
app.include_router(remediations.router, prefix=prefix)
app.include_router(dashboard.router, prefix=prefix)
app.include_router(settings.router, prefix=prefix)
app.include_router(audit.router, prefix=prefix)
app.include_router(collect.router, prefix=prefix)


@app.get("/health")
def health():
    return {"status": "ok", "version": __version__, "app": cfg.app_name}


@app.get("/")
def root():
    return {
        "name": cfg.app_name,
        "version": __version__,
        "docs": "/docs",
        "api": prefix,
        "message": "DriftGuard API — use the React UI or /docs",
    }
