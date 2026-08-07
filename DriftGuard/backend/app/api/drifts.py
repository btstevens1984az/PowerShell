"""Drift findings endpoints."""

from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.core.audit import write_audit
from app.core.rbac import get_current_user, require_min_role
from app.database import get_db
from app.models import DriftFinding, RoleEnum, User
from app.schemas import DriftOut, DriftStatusUpdate

router = APIRouter(prefix="/drifts", tags=["drifts"])


@router.get("", response_model=list[DriftOut])
def list_drifts(
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(get_current_user)],
    status: Optional[str] = None,
    severity: Optional[str] = None,
    system_id: Optional[int] = None,
    limit: int = Query(100, le=500),
):
    q = db.query(DriftFinding)
    if status:
        q = q.filter(DriftFinding.status == status)
    if severity:
        q = q.filter(DriftFinding.severity == severity)
    if system_id:
        q = q.filter(DriftFinding.system_id == system_id)
    return q.order_by(DriftFinding.detected_at.desc()).limit(limit).all()


@router.get("/{drift_id}", response_model=DriftOut)
def get_drift(
    drift_id: int,
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(get_current_user)],
):
    row = db.query(DriftFinding).filter(DriftFinding.id == drift_id).first()
    if not row:
        raise HTTPException(status_code=404, detail="Not found")
    return row


@router.patch("/{drift_id}", response_model=DriftOut)
def update_drift_status(
    drift_id: int,
    body: DriftStatusUpdate,
    db: Annotated[Session, Depends(get_db)],
    user: Annotated[User, Depends(require_min_role(RoleEnum.operator))],
):
    row = db.query(DriftFinding).filter(DriftFinding.id == drift_id).first()
    if not row:
        raise HTTPException(status_code=404, detail="Not found")
    row.status = body.status
    db.commit()
    db.refresh(row)
    write_audit(
        db,
        action="drift.status_update",
        resource_type="drift",
        resource_id=str(row.id),
        actor=user,
        detail={"status": body.status.value},
    )
    return row
