"""Audit log endpoints."""

from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.rbac import require_min_role
from app.database import get_db
from app.models import AuditEvent, RoleEnum, User
from app.schemas import AuditOut

router = APIRouter(prefix="/audit", tags=["audit"])


@router.get("", response_model=list[AuditOut])
def list_audit(
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(require_min_role(RoleEnum.auditor))],
    limit: int = Query(100, le=500),
):
    return db.query(AuditEvent).order_by(AuditEvent.created_at.desc()).limit(limit).all()
