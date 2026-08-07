"""Application settings loaded from environment variables."""

from functools import lru_cache
from typing import List

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = "DriftGuard"
    app_version: str = "0.1.0"
    environment: str = "development"
    debug: bool = True
    api_prefix: str = "/api/v1"

    # Database — SQLite for local/dev, PostgreSQL via DATABASE_URL in Compose
    database_url: str = "sqlite:///./driftguard.db"

    # Auth / JWT
    secret_key: str = "change-me-in-production-use-openssl-rand-hex-32"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 8
    refresh_token_expire_days: int = 7

    # Encryption for stored secrets (Fernet key — 32 url-safe base64-encoded bytes)
    secrets_fernet_key: str = ""

    # CORS
    cors_origins: str = "http://localhost:5173,http://localhost:3000,http://127.0.0.1:5173"

    # Seed demo data on startup
    seed_demo_data: bool = True

    # Notifications (optional)
    smtp_host: str = ""
    smtp_port: int = 587
    smtp_user: str = ""
    smtp_password: str = ""
    notify_from: str = "driftguard@localhost"
    webhook_url: str = ""

    # Collector / remediation safety
    remediation_dry_run_default: bool = True
    max_parallel_collectors: int = 10
    collector_timeout_seconds: int = 120

    # Git sync for desired state
    desired_state_git_url: str = ""
    desired_state_git_branch: str = "main"
    desired_state_local_path: str = "./desired-state"

    @property
    def cors_origin_list(self) -> List[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
