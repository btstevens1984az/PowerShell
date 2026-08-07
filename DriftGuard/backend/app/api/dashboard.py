"""Dashboard aggregation."""

from datetime import datetime, timedelta
from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.rbac import get_current_user
from app.database import get_db
from app.models import DriftFinding, DriftSeverity, DriftStatus, RemediationRequest, RemediationStatus, System, User
from app.schemas import DashboardStats, DriftOut

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("/stats", response_model=DashboardStats)
def dashboard_stats(
    db: Annotated[Session, Depends(get_db)],
    _: Annotated[User, Depends(get_current_user)],
):
    systems = db.query(System).all()
    open_drifts = (
        db.query(DriftFinding)
        .filter(DriftFinding.status.in_([DriftStatus.open, DriftStatus.acknowledged, DriftStatus.remediating]))
        .all()
    )
    critical = sum(1 for d in open_drifts if d.severity == DriftSeverity.critical)
    pending = (
        db.query(RemediationRequest)
        .filter(RemediationRequest.status == RemediationStatus.pending_approval)
        .count()
    )
    by_sev = {s.value: 0 for s in DriftSeverity}
    for d in open_drifts:
        by_sev[d.severity.value] += 1
    by_os: dict[str, int] = {}
    for s in systems:
        key = s.os_type.value
        by_os[key] = by_os.get(key, 0) + sum(1 for d in open_drifts if d.system_id == s.id)

    recent = (
        db.query(DriftFinding)
        .order_by(DriftFinding.detected_at.desc())
        .limit(8)
        .all()
    )

    # Timeline — last 14 days counts
    timeline = []
    for i in range(13, -1, -1):
        day = (datetime.utcnow() - timedelta(days=i)).date()
        count = (
            db.query(func.count(DriftFinding.id))
            .filter(func.date(DriftFinding.detected_at) == day)
            .scalar()
            or 0
        )
        timeline.append({"date": day.isoformat(), "count": count})

    top_affected = sorted(
        [
            {
                "system_id": s.id,
                "name": s.name,
                "drift_score": s.drift_score,
                "os_type": s.os_type.value,
                "environment": s.environment,
                "open_drifts": sum(1 for d in open_drifts if d.system_id == s.id),
            }
            for s in systems
        ],
        key=lambda x: x["drift_score"],
        reverse=True,
    )[:6]

    avg = (sum(s.drift_score for s in systems) / len(systems)) if systems else 0.0

    return DashboardStats(
        total_systems=len(systems),
        online_systems=sum(1 for s in systems if s.is_online),
        open_drifts=len(open_drifts),
        critical_drifts=critical,
        pending_approvals=pending,
        avg_drift_score=round(avg, 1),
        drift_by_severity=by_sev,
        drift_by_os=by_os,
        recent_drifts=[DriftOut.model_validate(d) for d in recent],
        timeline=timeline,
        top_affected=top_affected,
    )
