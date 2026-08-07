"""Systems CRUD."""

from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.core.audit import write_audit
from app.core.rbac import get_current_user, require_min_role
from app.database import get_db
from app.models import RoleEnum, System, User
from app.schemas import SystemCreate, SystemOut, SystemUpdate

router = APIRouter(prefix="/systems", tags=["systems"])


@router.get("", response_model=list[SystemOut])
def list_systems(
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(get_current_user)],
    environment: Optional[str] = None,
    os_type: Optional[str] = None,
):
    q = db.query(System)
    if environment:
        q = q.filter(System.environment == environment)
    if os_type:
        q = q.filter(System.os_type == os_type)
    return q.order_by(System.drift_score.desc()).all()


@router.post("", response_model=SystemOut)
def create_system(
    body: SystemCreate,
    db: Annotated[Session, Depends(get_db)],
    user: Annotated[User, Depends(require_min_role(RoleEnum.operator))],
):
    if db.query(System).filter(System.name == body.name).first():
        raise HTTPException(status_code=400, detail="System name already exists")
    system = System(**body.model_dump())
    db.add(system)
    db.commit()
    db.refresh(system)
    write_audit(db, action="system.create", resource_type="system", resource_id=str(system.id), actor=user)
    return system


@router.get("/{system_id}", response_model=SystemOut)
def get_system(
    system_id: int,
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(get_current_user)],
):
    system = db.query(System).filter(System.id == system_id).first()
    if not system:
        raise HTTPException(status_code=404, detail="System not found")
    return system


@router.patch("/{system_id}", response_model=SystemOut)
def update_system(
    system_id: int,
    body: SystemUpdate,
    db: Annotated[Session, Depends(get_db)],
    user: Annotated[User, Depends(require_min_role(RoleEnum.operator))],
):
    system = db.query(System).filter(System.id == system_id).first()
    if not system:
        raise HTTPException(status_code=404, detail="System not found")
    for k, v in body.model_dump(exclude_unset=True).items():
        setattr(system, k, v)
    db.commit()
    db.refresh(system)
    write_audit(db, action="system.update", resource_type="system", resource_id=str(system.id), actor=user)
    return system


@router.delete("/{system_id}")
def delete_system(
    system_id: int,
    db: Annotated[Session, Depends(get_db)],
    user: Annotated[User, Depends(require_min_role(RoleEnum.admin))],
):
    system = db.query(System).filter(System.id == system_id).first()
    if not system:
        raise HTTPException(status_code=404, detail="System not found")
    db.delete(system)
    db.commit()
    write_audit(db, action="system.delete", resource_type="system", resource_id=str(system_id), actor=user)
    return {"ok": True}
