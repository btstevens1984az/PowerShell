"""Configuration collectors — SSH, local, agent, WinRM stubs, cloud stubs."""

from __future__ import annotations

import hashlib
import json
import platform
import subprocess
from abc import ABC, abstractmethod
from datetime import datetime
from pathlib import Path
from typing import Any, Optional

from app.models import CollectorType, System, SystemOS


class BaseCollector(ABC):
    collector_type: CollectorType

    @abstractmethod
    def collect(self, system: System) -> dict[str, Any]:
        raise NotImplementedError


class LocalCollector(BaseCollector):
    """Collects from the host running DriftGuard (demo / self-check)."""

    collector_type = CollectorType.local

    def collect(self, system: System) -> dict[str, Any]:
        files: dict[str, Any] = {}
        watch = system.connection_config.get("watch_files", ["/etc/hostname", "/etc/os-release"])
        for path in watch:
            p = Path(path)
            if p.exists() and p.is_file():
                try:
                    files[path] = {
                        "exists": True,
                        "content": p.read_text(errors="replace")[:8000],
                        "mode": oct(p.stat().st_mode & 0o777),
                        "size": p.stat().st_size,
                    }
                except OSError as exc:
                    files[path] = {"exists": True, "error": str(exc)}
            else:
                files[path] = {"exists": False}

        packages: list[dict[str, str]] = []
        services: dict[str, Any] = {}

        # Best-effort package listing on Linux
        if platform.system() == "Linux":
            try:
                out = subprocess.run(
                    ["dpkg-query", "-W", "-f=${Package}\\t${Version}\\n"],
                    capture_output=True,
                    text=True,
                    timeout=15,
                    check=False,
                )
                if out.returncode == 0:
                    for line in out.stdout.splitlines()[:200]:
                        if "\t" in line:
                            name, ver = line.split("\t", 1)
                            packages.append({"name": name, "version": ver})
            except (FileNotFoundError, subprocess.TimeoutExpired):
                packages = [{"name": "demo-package", "version": "1.0.0"}]

            try:
                out = subprocess.run(
                    ["systemctl", "list-units", "--type=service", "--no-pager", "--plain"],
                    capture_output=True,
                    text=True,
                    timeout=15,
                    check=False,
                )
                if out.returncode == 0:
                    for line in out.stdout.splitlines()[1:80]:
                        parts = line.split()
                        if len(parts) >= 4:
                            services[parts[0]] = {"active": parts[2], "sub": parts[3]}
            except (FileNotFoundError, subprocess.TimeoutExpired):
                services = {"ssh.service": {"active": "active", "sub": "running"}}

        return {
            "collected_at": datetime.utcnow().isoformat() + "Z",
            "hostname": platform.node(),
            "os": platform.platform(),
            "files": files,
            "packages": packages,
            "services": services,
            "registry": {},
            "cloud": {},
        }


class SSHCollector(BaseCollector):
    """Paramiko-based SSH collector. Falls back to simulated payload when unreachable."""

    collector_type = CollectorType.ssh

    def collect(self, system: System) -> dict[str, Any]:
        cfg = system.connection_config or {}
        host = cfg.get("host") or system.hostname
        port = int(cfg.get("port", 22))
        username = cfg.get("username", "driftguard")
        watch_files = cfg.get("watch_files", ["/etc/ssh/sshd_config", "/etc/nginx/nginx.conf"])
        expected_packages = cfg.get("expected_packages", ["nginx", "openssh-server"])

        try:
            import paramiko

            client = paramiko.SSHClient()
            client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            connect_kwargs: dict[str, Any] = {
                "hostname": host,
                "port": port,
                "username": username,
                "timeout": 8,
                "allow_agent": True,
                "look_for_keys": True,
            }
            if cfg.get("password"):
                connect_kwargs["password"] = cfg["password"]
            if cfg.get("key_filename"):
                connect_kwargs["key_filename"] = cfg["key_filename"]

            client.connect(**connect_kwargs)
            files: dict[str, Any] = {}
            for path in watch_files:
                _stdin, stdout, _stderr = client.exec_command(f"cat {path} 2>/dev/null || echo '__MISSING__'")
                content = stdout.read().decode(errors="replace")
                files[path] = {
                    "exists": content.strip() != "__MISSING__",
                    "content": content if content.strip() != "__MISSING__" else None,
                }
            _stdin, stdout, _stderr = client.exec_command(
                "dpkg-query -W -f='${Package}\\t${Version}\\n' 2>/dev/null | head -n 100 || rpm -qa --qf '%{NAME}\\t%{VERSION}\\n' | head -n 100"
            )
            packages = []
            for line in stdout.read().decode(errors="replace").splitlines():
                if "\t" in line:
                    n, v = line.split("\t", 1)
                    packages.append({"name": n, "version": v})
            _stdin, stdout, _stderr = client.exec_command(
                "systemctl list-units --type=service --no-pager --plain 2>/dev/null | head -n 50"
            )
            services: dict[str, Any] = {}
            for line in stdout.read().decode(errors="replace").splitlines():
                parts = line.split()
                if len(parts) >= 4 and parts[0].endswith(".service"):
                    services[parts[0]] = {"active": parts[2], "sub": parts[3]}
            client.close()
            return {
                "collected_at": datetime.utcnow().isoformat() + "Z",
                "hostname": host,
                "files": files,
                "packages": packages,
                "services": services,
                "registry": {},
                "cloud": {},
                "mode": "live_ssh",
            }
        except Exception as exc:  # noqa: BLE001 — demo fallback
            return _simulate_payload(system, reason=f"ssh_unavailable: {exc}", watch_files=watch_files, packages=expected_packages)


class WinRMCollector(BaseCollector):
    """WinRM stub — returns simulated Windows inventory for MVP."""

    collector_type = CollectorType.winrm

    def collect(self, system: System) -> dict[str, Any]:
        cfg = system.connection_config or {}
        return {
            "collected_at": datetime.utcnow().isoformat() + "Z",
            "hostname": system.hostname,
            "files": {
                r"C:\Windows\System32\drivers\etc\hosts": {
                    "exists": True,
                    "content": "127.0.0.1 localhost\r\n",
                }
            },
            "packages": [
                {"name": "Microsoft.VCRedist.2015+", "version": "14.38.33130"},
                {"name": "Google.Chrome", "version": cfg.get("chrome_version", "120.0.6099.130")},
            ],
            "services": {
                "Wuauserv": {"state": "Running", "start_type": "Automatic"},
                "Spooler": {"state": cfg.get("spooler_state", "Stopped"), "start_type": "Automatic"},
            },
            "registry": {
                r"HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU\\NoAutoUpdate": {
                    "type": "DWORD",
                    "value": cfg.get("no_auto_update", 0),
                }
            },
            "cloud": {},
            "mode": "winrm_stub",
        }


class AgentCollector(BaseCollector):
    """Agent push collector — uses last agent payload stored in connection_config."""

    collector_type = CollectorType.agent

    def collect(self, system: System) -> dict[str, Any]:
        payload = (system.connection_config or {}).get("last_agent_payload")
        if payload:
            payload = dict(payload)
            payload["mode"] = "agent"
            payload["collected_at"] = datetime.utcnow().isoformat() + "Z"
            return payload
        return _simulate_payload(system, reason="awaiting_agent")


class CloudCollector(BaseCollector):
    """Cloud SDK stub (AWS/Azure/GCP) — simulated resource inventory."""

    collector_type = CollectorType.api

    def collect(self, system: System) -> dict[str, Any]:
        cfg = system.connection_config or {}
        provider = cfg.get("provider", "aws")
        return {
            "collected_at": datetime.utcnow().isoformat() + "Z",
            "hostname": system.hostname,
            "files": {},
            "packages": [],
            "services": {},
            "registry": {},
            "cloud": {
                "provider": provider,
                "resources": [
                    {
                        "type": "security_group",
                        "id": cfg.get("sg_id", "sg-0abc123"),
                        "ingress": cfg.get(
                            "ingress",
                            [{"proto": "tcp", "port": 22, "cidr": "10.0.0.0/8"}],
                        ),
                    },
                    {
                        "type": "s3_bucket",
                        "name": cfg.get("bucket", "company-logs"),
                        "encryption": cfg.get("encryption", "AES256"),
                        "public_access_block": cfg.get("public_access_block", True),
                    },
                ],
            },
            "mode": "cloud_stub",
        }


def _simulate_payload(
    system: System,
    reason: str = "simulated",
    watch_files: Optional[list[str]] = None,
    packages: Optional[list[str]] = None,
) -> dict[str, Any]:
    cfg = system.connection_config or {}
    watch_files = watch_files or cfg.get("watch_files", ["/etc/ssh/sshd_config"])
    packages = packages or ["openssh-server", "nginx"]
    # Inject controlled drift via connection_config for demos
    files = {}
    for path in watch_files:
        content = cfg.get("file_overrides", {}).get(path)
        if content is None:
            content = "# managed by DriftGuard golden config\nPermitRootLogin no\nPasswordAuthentication no\n"
        files[path] = {"exists": True, "content": content}
    pkg_list = [{"name": p, "version": cfg.get("package_versions", {}).get(p, "1.0.0")} for p in packages]
    if cfg.get("extra_packages"):
        pkg_list.extend(cfg["extra_packages"])
    services = cfg.get(
        "services",
        {
            "sshd.service": {"active": "active", "sub": "running"},
            "nginx.service": {"active": cfg.get("nginx_active", "active"), "sub": "running"},
        },
    )
    return {
        "collected_at": datetime.utcnow().isoformat() + "Z",
        "hostname": system.hostname,
        "files": files,
        "packages": pkg_list,
        "services": services,
        "registry": {},
        "cloud": {},
        "mode": reason,
    }


COLLECTORS: dict[CollectorType, BaseCollector] = {
    CollectorType.local: LocalCollector(),
    CollectorType.ssh: SSHCollector(),
    CollectorType.winrm: WinRMCollector(),
    CollectorType.agent: AgentCollector(),
    CollectorType.api: CloudCollector(),
}


def collect_for_system(system: System) -> dict[str, Any]:
    collector = COLLECTORS.get(system.collector_type, SSHCollector())
    if system.os_type == SystemOS.cloud:
        collector = CloudCollector()
    elif system.os_type == SystemOS.windows and system.collector_type in (CollectorType.ssh, CollectorType.winrm):
        collector = WinRMCollector()
    return collector.collect(system)


def payload_checksum(payload: dict[str, Any]) -> str:
    blob = json.dumps(payload, sort_keys=True, default=str)
    return hashlib.sha256(blob.encode()).hexdigest()
