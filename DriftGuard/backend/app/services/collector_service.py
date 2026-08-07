"""Collect + detect orchestration."""

from __future__ import annotations

from datetime import datetime
from typing import Optional

from sqlalchemy.orm import Session

from app.collectors import collect_for_system, payload_checksum
from app.models import DriftFinding, DriftStatus, Snapshot, System
from app.services.drift_engine import detect_drift, score_from_findings


def run_collection(
    db: Session,
    system: System,
    *,
    set_baseline: bool = False,
    clear_open_drifts: bool = True,
) -> tuple[Snapshot, list[DriftFinding]]:
    payload = collect_for_system(system)
    snap = Snapshot(
        system_id=system.id,
        collected_at=datetime.utcnow(),
        collector_type=system.collector_type,
        payload=payload,
        checksum=payload_checksum(payload),
        is_baseline=set_baseline,
    )
    db.add(snap)
    system.last_seen_at = datetime.utcnow()
    system.is_online = True
    db.flush()

    findings: list[DriftFinding] = []
    desired = {}
    if system.desired_state and system.desired_state.content:
        desired = system.desired_state.content
    elif set_baseline:
        # Baseline snapshot becomes golden desired for this system if none linked
        desired = payload

    if desired:
        raw = detect_drift(desired, payload)
        if clear_open_drifts:
            open_rows = (
                db.query(DriftFinding)
                .filter(
                    DriftFinding.system_id == system.id,
                    DriftFinding.status.in_([DriftStatus.open, DriftStatus.acknowledged, DriftStatus.remediating]),
                )
                .all()
            )
            for row in open_rows:
                row.status = DriftStatus.resolved
                row.resolved_at = datetime.utcnow()

        for item in raw:
            finding = DriftFinding(
                system_id=system.id,
                snapshot_id=snap.id,
                resource_kind=item["resource_kind"],
                resource_key=item["resource_key"],
                title=item["title"],
                description=item.get("description"),
                severity=item["severity"],
                status=DriftStatus.open,
                expected=item.get("expected"),
                actual=item.get("actual"),
                diff_summary=item.get("diff_summary"),
                suggested_fix=item.get("suggested_fix"),
            )
            db.add(finding)
            findings.append(finding)
        system.drift_score = score_from_findings(raw)
    else:
        system.drift_score = 0.0

    db.commit()
    db.refresh(snap)
    for f in findings:
        db.refresh(f)
    return snap, findings


def run_collection_batch(
    db: Session,
    system_ids: Optional[list[int]] = None,
    *,
    set_baseline: bool = False,
) -> dict:
    q = db.query(System)
    if system_ids:
        q = q.filter(System.id.in_(system_ids))
    systems = q.all()
    results = []
    for system in systems:
        snap, findings = run_collection(db, system, set_baseline=set_baseline)
        results.append(
            {
                "system_id": system.id,
                "system_name": system.name,
                "snapshot_id": snap.id,
                "drift_count": len(findings),
                "drift_score": system.drift_score,
            }
        )
    return {"collected": len(results), "results": results}
