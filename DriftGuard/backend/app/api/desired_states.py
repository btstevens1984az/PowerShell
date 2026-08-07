"""Desired state endpoints."""

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.audit import write_audit
from app.core.rbac import get_current_user, require_min_role
from app.database import get_db
from app.models import DesiredState, RoleEnum, User
from app.schemas import DesiredStateCreate, DesiredStateOut

router = APIRouter(prefix="/desired-states", tags=["desired-states"])


@router.get("", response_model=list[DesiredStateOut])
def list_desired(
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(get_current_user)],
):
    return db.query(DesiredState).order_by(DesiredState.name).all()


@router.post("", response_model=DesiredStateOut)
def create_desired(
    body: DesiredStateCreate,
    db: Annotated[Session, Depends(get_db)],
    user: Annotated[User, Depends(require_min_role(RoleEnum.operator))],
):
    row = DesiredState(**body.model_dump())
    db.add(row)
    db.commit()
    db.refresh(row)
    write_audit(db, action="desired_state.create", resource_type="desired_state", resource_id=str(row.id), actor=user)
    return row


@router.get("/{state_id}", response_model=DesiredStateOut)
def get_desired(
    state_id: int,
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(get_current_user)],
):
    row = db.query(DesiredState).filter(DesiredState.id == state_id).first()
    if not row:
        raise HTTPException(status_code=404, detail="Not found")
    return row


@router.put("/{state_id}", response_model=DesiredStateOut)
def update_desired(
    state_id: int,
    body: DesiredStateCreate,
    db: Annotated[Session, Depends(get_db)],
    user: Annotated[User, Depends(require_min_role(RoleEnum.operator))],
):
    row = db.query(DesiredState).filter(DesiredState.id == state_id).first()
    if not row:
        raise HTTPException(status_code=404, detail="Not found")
    for k, v in body.model_dump().items():
        setattr(row, k, v)
    db.commit()
    db.refresh(row)
    write_audit(db, action="desired_state.update", resource_type="desired_state", resource_id=str(row.id), actor=user)
    return row
