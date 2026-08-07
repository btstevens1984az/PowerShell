"""Collection trigger endpoints."""

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.audit import write_audit
from app.core.rbac import require_min_role
from app.database import get_db
from app.models import RoleEnum, Snapshot, System, User
from app.schemas import CollectRequest, SnapshotOut
from app.services.collector_service import run_collection, run_collection_batch

router = APIRouter(prefix="/collect", tags=["collect"])


@router.post("/run")
def collect_run(
    body: CollectRequest,
    db: Annotated[Session, Depends(get_db)],
    user: Annotated[User, Depends(require_min_role(RoleEnum.operator))],
):
    result = run_collection_batch(db, body.system_ids, set_baseline=body.set_baseline)
    write_audit(
        db,
        action="collect.run",
        resource_type="collection",
        actor=user,
        detail=result,
    )
    return result


@router.post("/systems/{system_id}", response_model=SnapshotOut)
def collect_one(
    system_id: int,
    db: Annotated[Session, Depends(get_db)],
    user: Annotated[User, Depends(require_min_role(RoleEnum.operator))],
    set_baseline: bool = False,
):
    system = db.query(System).filter(System.id == system_id).first()
    if not system:
        raise HTTPException(status_code=404, detail="System not found")
    snap, _findings = run_collection(db, system, set_baseline=set_baseline)
    write_audit(
        db,
        action="collect.system",
        resource_type="system",
        resource_id=str(system_id),
        actor=user,
        detail={"snapshot_id": snap.id},
    )
    return snap


@router.get("/snapshots/{system_id}", response_model=list[SnapshotOut])
def list_snapshots(
    system_id: int,
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(require_min_role(RoleEnum.viewer))],
):
    return (
        db.query(Snapshot)
        .filter(Snapshot.system_id == system_id)
        .order_by(Snapshot.collected_at.desc())
        .limit(50)
        .all()
    )
