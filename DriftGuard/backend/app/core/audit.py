"""Audit logging helper."""

from __future__ import annotations

from typing import Any, Optional

from sqlalchemy.orm import Session

from app.models import AuditEvent, User


def write_audit(
    db: Session,
    *,
    action: str,
    resource_type: str,
    resource_id: Optional[str] = None,
    actor: Optional[User] = None,
    detail: Optional[dict[str, Any]] = None,
    ip_address: Optional[str] = None,
) -> AuditEvent:
    event = AuditEvent(
        actor_id=actor.id if actor else None,
        action=action,
        resource_type=resource_type,
        resource_id=resource_id,
        detail=detail or {},
        ip_address=ip_address,
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return event
