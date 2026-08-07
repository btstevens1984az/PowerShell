"""Pytest suite for DriftGuard MVP."""

import os

# Use isolated SQLite DB for tests
os.environ["DATABASE_URL"] = "sqlite:///./test_driftguard.db"
os.environ["SEED_DEMO_DATA"] = "false"
os.environ["SECRET_KEY"] = "test-secret-key"

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.security import hash_password
from app.database import Base, get_db
from app.main import app
from app.models import DesiredState, RoleEnum, System, SystemOS, CollectorType, User
from app.services.drift_engine import detect_drift, score_from_findings


engine = create_engine("sqlite:///./test_driftguard.db", connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(autouse=True)
def setup_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    admin = User(
        email="admin@test.example",
        full_name="Admin",
        hashed_password=hash_password("testpass123"),
        role=RoleEnum.admin,
    )
    db.add(admin)
    ds = DesiredState(
        name="test-golden",
        content={
            "files": {"/etc/ssh/sshd_config": {"content": "PermitRootLogin no\n"}},
            "services": {"sshd.service": {"active": "active"}},
            "packages": {"required": [{"name": "openssh-server", "version": "1.0"}]},
        },
        is_golden=True,
    )
    db.add(ds)
    db.flush()
    db.add(
        System(
            name="test-host",
            hostname="test-host",
            os_type=SystemOS.linux,
            collector_type=CollectorType.ssh,
            desired_state_id=ds.id,
            connection_config={
                "file_overrides": {"/etc/ssh/sshd_config": "PermitRootLogin yes\n"},
                "nginx_active": "inactive",
                "services": {"sshd.service": {"active": "inactive", "sub": "dead"}},
                "package_versions": {"openssh-server": "0.9"},
                "expected_packages": ["openssh-server"],
            },
        )
    )
    db.commit()
    db.close()

    def override_get_db():
        session = TestingSessionLocal()
        try:
            yield session
        finally:
            session.close()

    app.dependency_overrides[get_db] = override_get_db
    yield
    app.dependency_overrides.clear()
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def client():
    with TestClient(app) as c:
        yield c


@pytest.fixture
def auth_headers(client):
    r = client.post("/api/v1/auth/login/json", json={"email": "admin@test.example", "password": "testpass123"})
    assert r.status_code == 200, r.text
    token = r.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_login_and_me(client, auth_headers):
    r = client.get("/api/v1/auth/me", headers=auth_headers)
    assert r.status_code == 200
    assert r.json()["email"] == "admin@test.example"


def test_list_systems(client, auth_headers):
    r = client.get("/api/v1/systems", headers=auth_headers)
    assert r.status_code == 200
    assert len(r.json()) >= 1


def test_detect_drift_engine():
    desired = {
        "files": {"/tmp/a": {"content": "hello"}},
        "services": {"nginx.service": {"active": "active"}},
        "packages": {"required": [{"name": "nginx", "version": "1.24"}]},
    }
    actual = {
        "files": {"/tmp/a": {"exists": True, "content": "world"}},
        "services": {"nginx.service": {"active": "inactive"}},
        "packages": [{"name": "nginx", "version": "1.18"}],
    }
    findings = detect_drift(desired, actual)
    assert len(findings) >= 3
    assert score_from_findings(findings) > 0


def test_collect_and_dashboard(client, auth_headers):
    r = client.post("/api/v1/collect/run", headers=auth_headers, json={})
    assert r.status_code == 200
    assert r.json()["collected"] >= 1
    d = client.get("/api/v1/dashboard/stats", headers=auth_headers)
    assert d.status_code == 200
    body = d.json()
    assert "open_drifts" in body
    assert body["total_systems"] >= 1


def test_remediation_flow(client, auth_headers):
    client.post("/api/v1/collect/run", headers=auth_headers, json={})
    drifts = client.get("/api/v1/drifts", headers=auth_headers).json()
    assert len(drifts) >= 1
    rem = client.post(
        "/api/v1/remediations",
        headers=auth_headers,
        json={"drift_id": drifts[0]["id"], "dry_run": True},
    )
    assert rem.status_code == 200
    rem_id = rem.json()["id"]
    decided = client.post(
        f"/api/v1/remediations/{rem_id}/decide",
        headers=auth_headers,
        json={"approve": True, "notes": "ok"},
    )
    assert decided.status_code == 200
    assert decided.json()["status"] in ("dry_run", "succeeded", "approved")


def test_settings_list(client, auth_headers):
    r = client.get("/api/v1/settings", headers=auth_headers)
    assert r.status_code == 200
    assert len(r.json()) >= 5
