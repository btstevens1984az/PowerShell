"""App settings endpoints."""

from typing import Annotated, Any

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.audit import write_audit
from app.core.rbac import get_current_user, require_min_role
from app.database import get_db
from app.models import AppSetting, NotificationChannel, RoleEnum, User
from app.schemas import SettingOut, SettingUpdate

router = APIRouter(prefix="/settings", tags=["settings"])


DEFAULT_SETTINGS: list[dict[str, Any]] = [
    {
        "key": "remediation.dry_run_default",
        "value": True,
        "description": "Always require a dry-run before live apply.",
    },
    {
        "key": "collector.interval_minutes",
        "value": 15,
        "description": "How often scheduled collectors run (minutes).",
    },
    {
        "key": "collector.timeout_seconds",
        "value": 120,
        "description": "Per-system collector timeout.",
    },
    {
        "key": "notifications.critical_webhook",
        "value": "",
        "description": "Webhook URL for critical drift alerts.",
    },
    {
        "key": "notifications.email_enabled",
        "value": False,
        "description": "Send email digests for open drifts.",
    },
    {
        "key": "git.desired_state_sync",
        "value": False,
        "description": "Sync desired-state YAML from a Git repository.",
    },
    {
        "key": "git.repo_url",
        "value": "",
        "description": "Git URL for desired-state definitions.",
    },
    {
        "key": "git.branch",
        "value": "main",
        "description": "Git branch to sync.",
    },
    {
        "key": "ui.theme",
        "value": "system",
        "description": "Default UI theme: light | dark | system.",
    },
    {
        "key": "security.session_hours",
        "value": 8,
        "description": "JWT access token lifetime in hours.",
    },
    {
        "key": "security.require_mfa_for_apply",
        "value": False,
        "description": "Require MFA challenge before live remediation apply.",
    },
    {
        "key": "severity.auto_acknowledge_info",
        "value": True,
        "description": "Auto-acknowledge info-level findings.",
    },
]


@router.get("", response_model=list[SettingOut])
def list_settings(
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(get_current_user)],
):
    rows = db.query(AppSetting).order_by(AppSetting.key).all()
    if not rows:
        for item in DEFAULT_SETTINGS:
            db.add(AppSetting(**item))
        db.commit()
        rows = db.query(AppSetting).order_by(AppSetting.key).all()
    return rows


@router.patch("/{key}", response_model=SettingOut)
def update_setting(
    key: str,
    body: SettingUpdate,
    db: Annotated[Session, Depends(get_db)],
    user: Annotated[User, Depends(require_min_role(RoleEnum.admin))],
):
    row = db.query(AppSetting).filter(AppSetting.key == key).first()
    if not row:
        raise HTTPException(status_code=404, detail="Setting not found")
    row.value = body.value
    db.commit()
    db.refresh(row)
    write_audit(
        db,
        action="settings.update",
        resource_type="setting",
        resource_id=key,
        actor=user,
        detail={"value": body.value},
    )
    return row


@router.get("/notifications/channels")
def list_channels(
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(get_current_user)],
):
    return db.query(NotificationChannel).all()
