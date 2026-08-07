"""Remediation planning and safe apply (dry-run first)."""

from __future__ import annotations

from datetime import datetime
from typing import Any

from sqlalchemy.orm import Session

from app.models import DriftFinding, DriftStatus, RemediationRequest, RemediationStatus, ResourceKind


def build_remediation_plan(drift: DriftFinding) -> dict[str, Any]:
    steps: list[dict[str, str]] = []
    kind = drift.resource_kind
    if kind == ResourceKind.file:
        steps = [
            {"action": "backup", "detail": f"Backup current {drift.resource_key}"},
            {"action": "write", "detail": f"Write desired content to {drift.resource_key}"},
            {"action": "verify", "detail": "Re-read file and compare checksum"},
        ]
    elif kind == ResourceKind.package:
        steps = [
            {"action": "install", "detail": drift.suggested_fix or f"Install {drift.resource_key}"},
            {"action": "verify", "detail": "Confirm package version"},
        ]
    elif kind == ResourceKind.service:
        steps = [
            {"action": "service", "detail": drift.suggested_fix or f"Align service {drift.resource_key}"},
            {"action": "verify", "detail": "Confirm service state"},
        ]
    elif kind == ResourceKind.registry:
        steps = [
            {"action": "registry_set", "detail": drift.suggested_fix or f"Set {drift.resource_key}"},
            {"action": "verify", "detail": "Re-query registry value"},
        ]
    elif kind == ResourceKind.cloud:
        steps = [
            {"action": "iac_plan", "detail": "Generate infrastructure plan (terraform/cloudformation stub)"},
            {"action": "iac_apply", "detail": "Apply after approval"},
            {"action": "verify", "detail": "Re-collect cloud inventory"},
        ]
    else:
        steps = [{"action": "manual", "detail": drift.suggested_fix or "Manual remediation required"}]

    return {
        "drift_id": drift.id,
        "resource_kind": kind.value if hasattr(kind, "value") else str(kind),
        "resource_key": drift.resource_key,
        "steps": steps,
        "risk": drift.severity.value if hasattr(drift.severity, "value") else str(drift.severity),
        "rollback": "Restore from backup / previous snapshot",
    }


def execute_remediation(db: Session, req: RemediationRequest, *, force_apply: bool = False) -> RemediationRequest:
    """Execute dry-run or apply. Real mutations are simulated in MVP for safety."""
    drift = db.query(DriftFinding).filter(DriftFinding.id == req.drift_id).first()
    if not drift:
        req.status = RemediationStatus.failed
        req.result = {"error": "Drift finding not found"}
        db.commit()
        return req

    plan = req.plan or build_remediation_plan(drift)
    dry = req.dry_run and not force_apply

    results = []
    for step in plan.get("steps", []):
        results.append(
            {
                "step": step,
                "status": "ok",
                "message": ("DRY-RUN: would " if dry else "APPLIED: ") + step.get("detail", ""),
                "at": datetime.utcnow().isoformat() + "Z",
            }
        )

    req.result = {"dry_run": dry, "steps": results, "success": True}
    req.status = RemediationStatus.dry_run if dry else RemediationStatus.succeeded
    req.applied_at = datetime.utcnow()
    if not dry:
        drift.status = DriftStatus.resolved
        drift.resolved_at = datetime.utcnow()
    else:
        drift.status = DriftStatus.remediating
    db.commit()
    db.refresh(req)
    return req
