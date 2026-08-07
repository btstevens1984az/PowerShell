"""Seed demo users, systems, desired states, and drift findings."""

from __future__ import annotations

from datetime import datetime, timedelta

from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.models import (
    AppSetting,
    CollectorType,
    DesiredState,
    DriftFinding,
    DriftSeverity,
    DriftStatus,
    NotificationChannel,
    RemediationRequest,
    RemediationStatus,
    ResourceKind,
    RoleEnum,
    Snapshot,
    System,
    SystemOS,
    User,
)
from app.api.settings import DEFAULT_SETTINGS
from app.services.drift_engine import score_from_findings
from app.services.remediation import build_remediation_plan


LINUX_GOLDEN = {
    "files": {
        "/etc/ssh/sshd_config": {
            "content": "# DriftGuard golden\nPermitRootLogin no\nPasswordAuthentication no\nPort 22\n",
            "mode": "0o600",
        },
        "/etc/nginx/nginx.conf": {
            "content": "user www-data;\nworker_processes auto;\nevents { worker_connections 1024; }\n",
        },
    },
    "packages": {
        "required": [
            {"name": "openssh-server", "version": "1:9.6p1-3"},
            {"name": "nginx", "version": "1.24.0-2"},
        ]
    },
    "services": {
        "sshd.service": {"active": "active", "sub": "running"},
        "nginx.service": {"active": "active", "sub": "running"},
    },
}

WINDOWS_GOLDEN = {
    "files": {
        r"C:\Windows\System32\drivers\etc\hosts": {
            "exists": True,
            "content": "127.0.0.1 localhost\r\n",
        }
    },
    "packages": {
        "required": [
            {"name": "Microsoft.VCRedist.2015+", "version": "14.38.33130"},
            {"name": "Google.Chrome", "version": "120.0.6099.130"},
        ]
    },
    "services": {
        "Wuauserv": {"state": "Running", "start_type": "Automatic"},
        "Spooler": {"state": "Running", "start_type": "Automatic"},
    },
    "registry": {
        r"HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU\\NoAutoUpdate": {
            "type": "DWORD",
            "value": 0,
        }
    },
}

CLOUD_GOLDEN = {
    "cloud": {
        "provider": "aws",
        "resources": [
            {
                "type": "security_group",
                "id": "sg-0abc123",
                "ingress": [{"proto": "tcp", "port": 22, "cidr": "10.0.0.0/8"}],
            },
            {
                "type": "s3_bucket",
                "name": "company-logs",
                "encryption": "AES256",
                "public_access_block": True,
            },
        ],
    }
}


def seed_demo(db: Session) -> None:
    if db.query(User).first():
        return

    admin = User(
        email="admin@driftguard.example",
        full_name="Alex Admin",
        hashed_password=hash_password("DriftGuard!admin"),
        role=RoleEnum.admin,
    )
    operator = User(
        email="ops@driftguard.example",
        full_name="Olivia Operator",
        hashed_password=hash_password("DriftGuard!ops"),
        role=RoleEnum.operator,
    )
    viewer = User(
        email="viewer@driftguard.example",
        full_name="Victor Viewer",
        hashed_password=hash_password("DriftGuard!view"),
        role=RoleEnum.viewer,
    )
    db.add_all([admin, operator, viewer])
    db.flush()

    linux_ds = DesiredState(
        name="linux-web-golden",
        description="Golden SSH + nginx baseline for Linux web tier",
        source="inline",
        content=LINUX_GOLDEN,
        version="1.2.0",
        is_golden=True,
    )
    win_ds = DesiredState(
        name="windows-member-golden",
        description="Windows member server baseline (services + registry)",
        source="inline",
        content=WINDOWS_GOLDEN,
        version="1.0.1",
        is_golden=True,
    )
    cloud_ds = DesiredState(
        name="aws-edge-golden",
        description="AWS security group + logging bucket baseline",
        source="git",
        source_path="desired-state/examples/aws-edge.yaml",
        content=CLOUD_GOLDEN,
        version="0.9.0",
        is_golden=True,
    )
    db.add_all([linux_ds, win_ds, cloud_ds])
    db.flush()

    systems_spec = [
        System(
            name="web-01.prod",
            hostname="web-01.prod.internal",
            os_type=SystemOS.linux,
            environment="production",
            tags={"tier": "web", "owner": "platform"},
            collector_type=CollectorType.ssh,
            connection_config={
                "host": "web-01.prod.internal",
                "watch_files": ["/etc/ssh/sshd_config", "/etc/nginx/nginx.conf"],
                "file_overrides": {
                    "/etc/ssh/sshd_config": "# drifted\nPermitRootLogin yes\nPasswordAuthentication yes\nPort 22\n",
                    "/etc/nginx/nginx.conf": "user www-data;\nworker_processes auto;\nevents { worker_connections 1024; }\n",
                },
                "nginx_active": "inactive",
                "package_versions": {"openssh-server": "1:9.6p1-3", "nginx": "1.18.0-1"},
                "expected_packages": ["openssh-server", "nginx"],
            },
            desired_state_id=linux_ds.id,
            is_online=True,
            last_seen_at=datetime.utcnow() - timedelta(minutes=8),
        ),
        System(
            name="web-02.prod",
            hostname="web-02.prod.internal",
            os_type=SystemOS.linux,
            environment="production",
            tags={"tier": "web", "owner": "platform"},
            collector_type=CollectorType.ssh,
            connection_config={
                "watch_files": ["/etc/ssh/sshd_config", "/etc/nginx/nginx.conf"],
                "package_versions": {"openssh-server": "1:9.6p1-3", "nginx": "1.24.0-2"},
            },
            desired_state_id=linux_ds.id,
            is_online=True,
            last_seen_at=datetime.utcnow() - timedelta(minutes=3),
            drift_score=0,
        ),
        System(
            name="db-01.prod",
            hostname="db-01.prod.internal",
            os_type=SystemOS.linux,
            environment="production",
            tags={"tier": "data"},
            collector_type=CollectorType.agent,
            connection_config={
                "watch_files": ["/etc/ssh/sshd_config"],
                "file_overrides": {
                    "/etc/ssh/sshd_config": "# DriftGuard golden\nPermitRootLogin no\nPasswordAuthentication no\nPort 22\n",
                },
                "last_agent_payload": {
                    "files": {
                        "/etc/ssh/sshd_config": {
                            "exists": True,
                            "content": "# DriftGuard golden\nPermitRootLogin no\nPasswordAuthentication no\nPort 22\n",
                        }
                    },
                    "packages": [{"name": "openssh-server", "version": "1:9.6p1-3"}],
                    "services": {"sshd.service": {"active": "active", "sub": "running"}},
                },
            },
            desired_state_id=linux_ds.id,
            is_online=True,
            last_seen_at=datetime.utcnow() - timedelta(minutes=1),
        ),
        System(
            name="app-win-01",
            hostname="app-win-01.corp.local",
            os_type=SystemOS.windows,
            environment="production",
            tags={"tier": "app"},
            collector_type=CollectorType.winrm,
            connection_config={"spooler_state": "Stopped", "no_auto_update": 1, "chrome_version": "119.0.6045.105"},
            desired_state_id=win_ds.id,
            is_online=True,
            last_seen_at=datetime.utcnow() - timedelta(minutes=12),
        ),
        System(
            name="jump-win-lab",
            hostname="jump-lab.corp.local",
            os_type=SystemOS.windows,
            environment="lab",
            tags={"tier": "jump"},
            collector_type=CollectorType.winrm,
            connection_config={},
            desired_state_id=win_ds.id,
            is_online=False,
            last_seen_at=datetime.utcnow() - timedelta(hours=6),
        ),
        System(
            name="aws-edge-sg",
            hostname="aws:us-east-1:edge",
            os_type=SystemOS.cloud,
            environment="production",
            tags={"provider": "aws", "region": "us-east-1"},
            collector_type=CollectorType.api,
            connection_config={
                "provider": "aws",
                "sg_id": "sg-0abc123",
                "ingress": [
                    {"proto": "tcp", "port": 22, "cidr": "0.0.0.0/0"},
                    {"proto": "tcp", "port": 443, "cidr": "0.0.0.0/0"},
                ],
                "encryption": "AES256",
                "public_access_block": True,
            },
            desired_state_id=cloud_ds.id,
            is_online=True,
            last_seen_at=datetime.utcnow() - timedelta(minutes=5),
        ),
        System(
            name="core-sw-01",
            hostname="core-sw-01.network",
            os_type=SystemOS.network,
            environment="production",
            tags={"role": "core-switch"},
            collector_type=CollectorType.ssh,
            connection_config={
                "watch_files": ["/etc/ssh/sshd_config"],
                "file_overrides": {
                    "/etc/ssh/sshd_config": "# NOS config extract\nPermitRootLogin no\nPasswordAuthentication no\nPort 22\n"
                },
            },
            desired_state_id=linux_ds.id,
            is_online=True,
            last_seen_at=datetime.utcnow() - timedelta(minutes=20),
        ),
        System(
            name="self-check",
            hostname="localhost",
            os_type=SystemOS.linux,
            environment="lab",
            tags={"role": "driftguard-host"},
            collector_type=CollectorType.local,
            connection_config={"watch_files": ["/etc/hostname", "/etc/os-release"]},
            desired_state_id=None,
            is_online=True,
            last_seen_at=datetime.utcnow(),
        ),
    ]
    db.add_all(systems_spec)
    db.flush()

    # Create snapshots + drifts for drifted systems via engine
    from app.services.collector_service import run_collection

    for system in systems_spec:
        if system.name == "self-check":
            continue
        run_collection(db, system, set_baseline=False)

    # Seed a pending remediation on first open critical/high
    drift = (
        db.query(DriftFinding)
        .filter(DriftFinding.status == DriftStatus.open)
        .order_by(DriftFinding.id)
        .first()
    )
    if drift:
        rem = RemediationRequest(
            drift_id=drift.id,
            requested_by=operator.id,
            status=RemediationStatus.pending_approval,
            dry_run=True,
            plan=build_remediation_plan(drift),
            notes="Demo remediation awaiting approval",
        )
        db.add(rem)

    # Historical drifts for timeline
    web = next(s for s in systems_spec if s.name == "web-01.prod")
    for days_ago in range(1, 10):
        db.add(
            DriftFinding(
                system_id=web.id,
                resource_kind=ResourceKind.file,
                resource_key="/etc/hosts",
                title="Historical hosts drift (resolved)",
                severity=DriftSeverity.low,
                status=DriftStatus.resolved,
                expected="127.0.0.1 localhost",
                actual="127.0.0.1 localhost\n10.0.0.5 old-host",
                diff_summary="extra host entry",
                suggested_fix="Remove stale host entry",
                detected_at=datetime.utcnow() - timedelta(days=days_ago),
                resolved_at=datetime.utcnow() - timedelta(days=days_ago - 1),
            )
        )

    for item in DEFAULT_SETTINGS:
        db.add(AppSetting(**item))

    db.add(
        NotificationChannel(
            name="Critical Slack",
            channel_type="webhook",
            config={"url": "https://hooks.example.com/driftguard"},
            enabled=True,
        )
    )
    db.add(
        NotificationChannel(
            name="Ops Email",
            channel_type="email",
            config={"to": ["ops@example.com"]},
            enabled=False,
        )
    )

    db.commit()
