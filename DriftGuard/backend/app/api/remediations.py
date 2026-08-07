"""Remediation workflow endpoints."""

from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.audit import write_audit
from app.core.rbac import get_current_user, require_min_role
from app.database import get_db
from app.models import DriftFinding, RemediationRequest, RemediationStatus, RoleEnum, User
from app.schemas import RemediationCreate, RemediationDecision, RemediationOut
from app.services.remediation import build_remediation_plan, execute_remediation

router = APIRouter(prefix="/remediations", tags=["remediations"])


@router.get("", response_model=list[RemediationOut])
def list_remediations(
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(get_current_user)],
    status: Optional[str] = None,
):
    q = db.query(RemediationRequest)
    if status:
        q = q.filter(RemediationRequest.status == status)
    return q.order_by(RemediationRequest.created_at.desc()).all()


@router.post("", response_model=RemediationOut)
def create_remediation(
    body: RemediationCreate,
    db: Annotated[Session, Depends(get_db)],
    user: Annotated[User, Depends(require_min_role(RoleEnum.operator))],
):
    drift = db.query(DriftFinding).filter(DriftFinding.id == body.drift_id).first()
    if not drift:
        raise HTTPException(status_code=404, detail="Drift not found")
    plan = build_remediation_plan(drift)
    req = RemediationRequest(
        drift_id=body.drift_id,
        requested_by=user.id,
        dry_run=body.dry_run,
        plan=plan,
        notes=body.notes,
        status=RemediationStatus.pending_approval,
    )
    db.add(req)
    db.commit()
    db.refresh(req)
    write_audit(db, action="remediation.create", resource_type="remediation", resource_id=str(req.id), actor=user)
    return req


@router.post("/{rem_id}/decide", response_model=RemediationOut)
def decide(
    rem_id: int,
    body: RemediationDecision,
    db: Annotated[Session, Depends(get_db)],
    user: Annotated[User, Depends(require_min_role(RoleEnum.admin))],
):
    req = db.query(RemediationRequest).filter(RemediationRequest.id == rem_id).first()
    if not req:
        raise HTTPException(status_code=404, detail="Not found")
    if req.status != RemediationStatus.pending_approval:
        raise HTTPException(status_code=400, detail="Not pending approval")
    req.approved_by = user.id
    if body.notes:
        req.notes = (req.notes or "") + f"\nDecision: {body.notes}"
    if body.approve:
        req.status = RemediationStatus.approved
        write_audit(db, action="remediation.approve", resource_type="remediation", resource_id=str(req.id), actor=user)
        db.commit()
        # Auto dry-run first if flagged
        req = execute_remediation(db, req, force_apply=not req.dry_run)
    else:
        req.status = RemediationStatus.rejected
        write_audit(db, action="remediation.reject", resource_type="remediation", resource_id=str(req.id), actor=user)
        db.commit()
        db.refresh(req)
    return req


@router.post("/{rem_id}/apply", response_model=RemediationOut)
def apply(
    rem_id: int,
    db: Annotated[Session, Depends(get_db)],
    user: Annotated[User, Depends(require_min_role(RoleEnum.admin))],
):
    req = db.query(RemediationRequest).filter(RemediationRequest.id == rem_id).first()
    if not req:
        raise HTTPException(status_code=404, detail="Not found")
    if req.status not in (RemediationStatus.approved, RemediationStatus.dry_run):
        raise HTTPException(status_code=400, detail="Must be approved or dry-run completed")
    req.dry_run = False
    req.status = RemediationStatus.applying
    db.commit()
    req = execute_remediation(db, req, force_apply=True)
    write_audit(db, action="remediation.apply", resource_type="remediation", resource_id=str(req.id), actor=user)
    return req
