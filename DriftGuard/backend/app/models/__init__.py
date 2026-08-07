"""ORM models for DriftGuard."""

from __future__ import annotations

import enum
from datetime import datetime
from typing import Any, Optional

from sqlalchemy import (
    JSON,
    Boolean,
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


def utcnow() -> datetime:
    return datetime.utcnow()


class RoleEnum(str, enum.Enum):
    admin = "admin"
    operator = "operator"
    viewer = "viewer"
    auditor = "auditor"


class SystemOS(str, enum.Enum):
    linux = "linux"
    windows = "windows"
    network = "network"
    cloud = "cloud"


class CollectorType(str, enum.Enum):
    agent = "agent"
    ssh = "ssh"
    winrm = "winrm"
    api = "api"
    local = "local"


class DriftSeverity(str, enum.Enum):
    critical = "critical"
    high = "high"
    medium = "medium"
    low = "low"
    info = "info"


class DriftStatus(str, enum.Enum):
    open = "open"
    acknowledged = "acknowledged"
    remediating = "remediating"
    resolved = "resolved"
    suppressed = "suppressed"


class RemediationStatus(str, enum.Enum):
    pending_approval = "pending_approval"
    approved = "approved"
    rejected = "rejected"
    dry_run = "dry_run"
    applying = "applying"
    succeeded = "succeeded"
    failed = "failed"
    cancelled = "cancelled"


class ResourceKind(str, enum.Enum):
    file = "file"
    package = "package"
    service = "service"
    registry = "registry"
    cloud = "cloud"
    network = "network"
    other = "other"


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    full_name: Mapped[str] = mapped_column(String(255))
    hashed_password: Mapped[str] = mapped_column(String(255))
    role: Mapped[RoleEnum] = mapped_column(Enum(RoleEnum), default=RoleEnum.viewer)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
    last_login: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)

    audit_events: Mapped[list["AuditEvent"]] = relationship(back_populates="actor")


class System(Base):
    __tablename__ = "systems"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    hostname: Mapped[str] = mapped_column(String(255))
    os_type: Mapped[SystemOS] = mapped_column(Enum(SystemOS), default=SystemOS.linux)
    environment: Mapped[str] = mapped_column(String(64), default="production")  # prod/stage/dev
    tags: Mapped[dict[str, Any]] = mapped_column(JSON, default=dict)
    collector_type: Mapped[CollectorType] = mapped_column(Enum(CollectorType), default=CollectorType.ssh)
    connection_config: Mapped[dict[str, Any]] = mapped_column(JSON, default=dict)  # host, port, etc.
    encrypted_secret_ref: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    desired_state_id: Mapped[Optional[int]] = mapped_column(ForeignKey("desired_states.id"), nullable=True)
    last_seen_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    drift_score: Mapped[float] = mapped_column(Float, default=0.0)
    is_online: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, onupdate=utcnow)

    desired_state: Mapped[Optional["DesiredState"]] = relationship(back_populates="systems")
    snapshots: Mapped[list["Snapshot"]] = relationship(back_populates="system", cascade="all, delete-orphan")
    drifts: Mapped[list["DriftFinding"]] = relationship(back_populates="system", cascade="all, delete-orphan")


class DesiredState(Base):
    __tablename__ = "desired_states"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(255), unique=True)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    source: Mapped[str] = mapped_column(String(64), default="inline")  # inline | git | file
    source_path: Mapped[Optional[str]] = mapped_column(String(512), nullable=True)
    content: Mapped[dict[str, Any]] = mapped_column(JSON, default=dict)
    version: Mapped[str] = mapped_column(String(64), default="1.0.0")
    is_golden: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, onupdate=utcnow)

    systems: Mapped[list[System]] = relationship(back_populates="desired_state")


class Snapshot(Base):
    __tablename__ = "snapshots"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    system_id: Mapped[int] = mapped_column(ForeignKey("systems.id"), index=True)
    collected_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, index=True)
    collector_type: Mapped[CollectorType] = mapped_column(Enum(CollectorType))
    payload: Mapped[dict[str, Any]] = mapped_column(JSON, default=dict)
    checksum: Mapped[str] = mapped_column(String(128), default="")
    is_baseline: Mapped[bool] = mapped_column(Boolean, default=False)

    system: Mapped[System] = relationship(back_populates="snapshots")


class DriftFinding(Base):
    __tablename__ = "drift_findings"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    system_id: Mapped[int] = mapped_column(ForeignKey("systems.id"), index=True)
    snapshot_id: Mapped[Optional[int]] = mapped_column(ForeignKey("snapshots.id"), nullable=True)
    resource_kind: Mapped[ResourceKind] = mapped_column(Enum(ResourceKind), default=ResourceKind.other)
    resource_key: Mapped[str] = mapped_column(String(512), index=True)
    title: Mapped[str] = mapped_column(String(512))
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    severity: Mapped[DriftSeverity] = mapped_column(Enum(DriftSeverity), default=DriftSeverity.medium)
    status: Mapped[DriftStatus] = mapped_column(Enum(DriftStatus), default=DriftStatus.open, index=True)
    expected: Mapped[Any] = mapped_column(JSON, nullable=True)
    actual: Mapped[Any] = mapped_column(JSON, nullable=True)
    diff_summary: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    suggested_fix: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    detected_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, index=True)
    resolved_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)

    system: Mapped[System] = relationship(back_populates="drifts")
    remediations: Mapped[list["RemediationRequest"]] = relationship(
        back_populates="drift", cascade="all, delete-orphan"
    )


class RemediationRequest(Base):
    __tablename__ = "remediation_requests"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    drift_id: Mapped[int] = mapped_column(ForeignKey("drift_findings.id"), index=True)
    requested_by: Mapped[int] = mapped_column(ForeignKey("users.id"))
    approved_by: Mapped[Optional[int]] = mapped_column(ForeignKey("users.id"), nullable=True)
    status: Mapped[RemediationStatus] = mapped_column(
        Enum(RemediationStatus), default=RemediationStatus.pending_approval, index=True
    )
    dry_run: Mapped[bool] = mapped_column(Boolean, default=True)
    plan: Mapped[dict[str, Any]] = mapped_column(JSON, default=dict)
    result: Mapped[Optional[dict[str, Any]]] = mapped_column(JSON, nullable=True)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, onupdate=utcnow)
    applied_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)

    drift: Mapped[DriftFinding] = relationship(back_populates="remediations")


class SecretStore(Base):
    __tablename__ = "secret_store"
    __table_args__ = (UniqueConstraint("name", name="uq_secret_name"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(255), index=True)
    ciphertext: Mapped[str] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, onupdate=utcnow)


class AuditEvent(Base):
    __tablename__ = "audit_events"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    actor_id: Mapped[Optional[int]] = mapped_column(ForeignKey("users.id"), nullable=True)
    action: Mapped[str] = mapped_column(String(128), index=True)
    resource_type: Mapped[str] = mapped_column(String(64))
    resource_id: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)
    detail: Mapped[dict[str, Any]] = mapped_column(JSON, default=dict)
    ip_address: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, index=True)

    actor: Mapped[Optional[User]] = relationship(back_populates="audit_events")


class AppSetting(Base):
    __tablename__ = "app_settings"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    key: Mapped[str] = mapped_column(String(128), unique=True, index=True)
    value: Mapped[Any] = mapped_column(JSON, default=dict)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, onupdate=utcnow)


class NotificationChannel(Base):
    __tablename__ = "notification_channels"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(128), unique=True)
    channel_type: Mapped[str] = mapped_column(String(64))  # email | webhook | slack
    config: Mapped[dict[str, Any]] = mapped_column(JSON, default=dict)
    enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
