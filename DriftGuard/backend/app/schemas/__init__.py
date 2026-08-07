"""Pydantic schemas."""

from __future__ import annotations

from datetime import datetime
from typing import Any, Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field

from app.models import (
    CollectorType,
    DriftSeverity,
    DriftStatus,
    RemediationStatus,
    ResourceKind,
    RoleEnum,
    SystemOS,
)


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


# Auth
class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class UserCreate(BaseModel):
    email: EmailStr
    full_name: str
    password: str = Field(min_length=8)
    role: RoleEnum = RoleEnum.viewer


class UserOut(ORMModel):
    id: int
    email: str
    full_name: str
    role: RoleEnum
    is_active: bool
    created_at: datetime
    last_login: Optional[datetime] = None


# Auth token
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: RoleEnum
    email: str
    full_name: str


# Systems
class SystemCreate(BaseModel):
    name: str
    hostname: str
    os_type: SystemOS = SystemOS.linux
    environment: str = "production"
    tags: dict[str, Any] = Field(default_factory=dict)
    collector_type: CollectorType = CollectorType.ssh
    connection_config: dict[str, Any] = Field(default_factory=dict)
    desired_state_id: Optional[int] = None


class SystemUpdate(BaseModel):
    name: Optional[str] = None
    hostname: Optional[str] = None
    os_type: Optional[SystemOS] = None
    environment: Optional[str] = None
    tags: Optional[dict[str, Any]] = None
    collector_type: Optional[CollectorType] = None
    connection_config: Optional[dict[str, Any]] = None
    desired_state_id: Optional[int] = None
    is_online: Optional[bool] = None


class SystemOut(ORMModel):
    id: int
    name: str
    hostname: str
    os_type: SystemOS
    environment: str
    tags: dict[str, Any]
    collector_type: CollectorType
    connection_config: dict[str, Any]
    desired_state_id: Optional[int]
    last_seen_at: Optional[datetime]
    drift_score: float
    is_online: bool
    created_at: datetime
    updated_at: datetime


# Desired state
class DesiredStateCreate(BaseModel):
    name: str
    description: Optional[str] = None
    source: str = "inline"
    source_path: Optional[str] = None
    content: dict[str, Any] = Field(default_factory=dict)
    version: str = "1.0.0"
    is_golden: bool = False


class DesiredStateOut(ORMModel):
    id: int
    name: str
    description: Optional[str]
    source: str
    source_path: Optional[str]
    content: dict[str, Any]
    version: str
    is_golden: bool
    created_at: datetime
    updated_at: datetime


# Drift
class DriftOut(ORMModel):
    id: int
    system_id: int
    snapshot_id: Optional[int]
    resource_kind: ResourceKind
    resource_key: str
    title: str
    description: Optional[str]
    severity: DriftSeverity
    status: DriftStatus
    expected: Any = None
    actual: Any = None
    diff_summary: Optional[str]
    suggested_fix: Optional[str]
    detected_at: datetime
    resolved_at: Optional[datetime]


class DriftStatusUpdate(BaseModel):
    status: DriftStatus


# Remediation
class RemediationCreate(BaseModel):
    drift_id: int
    dry_run: bool = True
    notes: Optional[str] = None


class RemediationDecision(BaseModel):
    approve: bool
    notes: Optional[str] = None


class RemediationOut(ORMModel):
    id: int
    drift_id: int
    requested_by: int
    approved_by: Optional[int]
    status: RemediationStatus
    dry_run: bool
    plan: dict[str, Any]
    result: Optional[dict[str, Any]]
    notes: Optional[str]
    created_at: datetime
    updated_at: datetime
    applied_at: Optional[datetime]


# Snapshots
class SnapshotOut(ORMModel):
    id: int
    system_id: int
    collected_at: datetime
    collector_type: CollectorType
    payload: dict[str, Any]
    checksum: str
    is_baseline: bool


# Dashboard
class DashboardStats(BaseModel):
    total_systems: int
    online_systems: int
    open_drifts: int
    critical_drifts: int
    pending_approvals: int
    avg_drift_score: float
    drift_by_severity: dict[str, int]
    drift_by_os: dict[str, int]
    recent_drifts: list[DriftOut]
    timeline: list[dict[str, Any]]
    top_affected: list[dict[str, Any]]


# Settings
class SettingOut(ORMModel):
    id: int
    key: str
    value: Any
    description: Optional[str]
    updated_at: datetime


class SettingUpdate(BaseModel):
    value: Any


class AuditOut(ORMModel):
    id: int
    actor_id: Optional[int]
    action: str
    resource_type: str
    resource_id: Optional[str]
    detail: dict[str, Any]
    ip_address: Optional[str]
    created_at: datetime


class CollectRequest(BaseModel):
    system_ids: Optional[list[int]] = None
    set_baseline: bool = False
