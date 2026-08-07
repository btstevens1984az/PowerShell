"""Drift detection engine — compare actual snapshot vs desired state."""

from __future__ import annotations

from typing import Any, Optional

from deepdiff import DeepDiff

from app.models import DriftSeverity, ResourceKind


SEVERITY_RULES = {
    "service": DriftSeverity.high,
    "file": DriftSeverity.medium,
    "package": DriftSeverity.medium,
    "registry": DriftSeverity.high,
    "cloud": DriftSeverity.critical,
    "network": DriftSeverity.high,
}


def _file_diff(expected: dict[str, Any], actual: dict[str, Any]) -> list[dict[str, Any]]:
    findings = []
    for path, exp in (expected or {}).items():
        act = (actual or {}).get(path)
        if act is None or not act.get("exists", True):
            findings.append(
                {
                    "resource_kind": ResourceKind.file,
                    "resource_key": path,
                    "title": f"Missing file: {path}",
                    "description": "File defined in desired state is missing on the target.",
                    "severity": DriftSeverity.high,
                    "expected": exp,
                    "actual": act,
                    "diff_summary": "File missing",
                    "suggested_fix": f"Restore {path} from golden config / configuration management.",
                }
            )
            continue
        exp_content = exp.get("content") if isinstance(exp, dict) else exp
        act_content = act.get("content") if isinstance(act, dict) else act
        if exp_content is not None and act_content is not None and str(exp_content).strip() != str(act_content).strip():
            findings.append(
                {
                    "resource_kind": ResourceKind.file,
                    "resource_key": path,
                    "title": f"File content drift: {path}",
                    "description": "On-disk content differs from desired state.",
                    "severity": DriftSeverity.medium,
                    "expected": exp_content,
                    "actual": act_content,
                    "diff_summary": _side_by_side_summary(str(exp_content), str(act_content)),
                    "suggested_fix": f"Overwrite {path} with desired content after approval (dry-run first).",
                }
            )
        exp_mode = exp.get("mode") if isinstance(exp, dict) else None
        act_mode = act.get("mode") if isinstance(act, dict) else None
        if exp_mode and act_mode and exp_mode != act_mode:
            findings.append(
                {
                    "resource_kind": ResourceKind.file,
                    "resource_key": f"{path}#mode",
                    "title": f"File mode drift: {path}",
                    "description": f"Expected mode {exp_mode}, found {act_mode}.",
                    "severity": DriftSeverity.low,
                    "expected": exp_mode,
                    "actual": act_mode,
                    "diff_summary": f"mode {act_mode} → {exp_mode}",
                    "suggested_fix": f"chmod {exp_mode} {path}",
                }
            )
    return findings


def _package_diff(expected: list[Any], actual: list[Any]) -> list[dict[str, Any]]:
    findings = []
    act_map = {}
    for p in actual or []:
        if isinstance(p, dict):
            act_map[p.get("name")] = p.get("version")
        elif isinstance(p, str):
            act_map[p] = None
    for item in expected or []:
        if isinstance(item, dict):
            name, ver = item.get("name"), item.get("version")
        else:
            name, ver = str(item), None
        if name not in act_map:
            findings.append(
                {
                    "resource_kind": ResourceKind.package,
                    "resource_key": name,
                    "title": f"Missing package: {name}",
                    "description": "Required package is not installed.",
                    "severity": DriftSeverity.high,
                    "expected": item,
                    "actual": None,
                    "diff_summary": "package missing",
                    "suggested_fix": f"Install package {name}" + (f" version {ver}" if ver else ""),
                }
            )
        elif ver and act_map[name] and act_map[name] != ver:
            findings.append(
                {
                    "resource_kind": ResourceKind.package,
                    "resource_key": name,
                    "title": f"Package version drift: {name}",
                    "description": f"Expected {ver}, found {act_map[name]}.",
                    "severity": DriftSeverity.medium,
                    "expected": ver,
                    "actual": act_map[name],
                    "diff_summary": f"{act_map[name]} → {ver}",
                    "suggested_fix": f"Upgrade/downgrade {name} to {ver}",
                }
            )
    # Unexpected packages marked in desired state
    unexpected = []
    if isinstance(expected, dict):
        unexpected = expected.get("disallow", [])  # type: ignore[assignment]
    return findings


def _service_diff(expected: dict[str, Any], actual: dict[str, Any]) -> list[dict[str, Any]]:
    findings = []
    for name, exp in (expected or {}).items():
        act = (actual or {}).get(name)
        if act is None:
            findings.append(
                {
                    "resource_kind": ResourceKind.service,
                    "resource_key": name,
                    "title": f"Missing service: {name}",
                    "description": "Expected systemd/Windows service not found.",
                    "severity": DriftSeverity.high,
                    "expected": exp,
                    "actual": None,
                    "diff_summary": "service missing",
                    "suggested_fix": f"Enable and start {name}",
                }
            )
            continue
        exp_active = exp.get("active") or exp.get("state")
        act_active = act.get("active") or act.get("state")
        if exp_active and act_active and str(exp_active).lower() != str(act_active).lower():
            findings.append(
                {
                    "resource_kind": ResourceKind.service,
                    "resource_key": name,
                    "title": f"Service state drift: {name}",
                    "description": f"Expected {exp_active}, found {act_active}.",
                    "severity": DriftSeverity.high,
                    "expected": exp,
                    "actual": act,
                    "diff_summary": f"{act_active} → {exp_active}",
                    "suggested_fix": f"systemctl start {name}" if "active" in str(exp_active).lower() else f"Stop {name}",
                }
            )
    return findings


def _registry_diff(expected: dict[str, Any], actual: dict[str, Any]) -> list[dict[str, Any]]:
    findings = []
    for key, exp in (expected or {}).items():
        act = (actual or {}).get(key)
        if act != exp and (act or {}).get("value") != (exp or {}).get("value"):
            findings.append(
                {
                    "resource_kind": ResourceKind.registry,
                    "resource_key": key,
                    "title": f"Registry drift: {key}",
                    "description": "Windows registry value differs from desired state.",
                    "severity": DriftSeverity.high,
                    "expected": exp,
                    "actual": act,
                    "diff_summary": f"{act} → {exp}",
                    "suggested_fix": f"Set registry value {key} to desired state",
                }
            )
    return findings


def _cloud_diff(expected: dict[str, Any], actual: dict[str, Any]) -> list[dict[str, Any]]:
    findings = []
    if not expected:
        return findings
    diff = DeepDiff(expected, actual or {}, ignore_order=True, view="tree")
    if not diff:
        return findings
    findings.append(
        {
            "resource_kind": ResourceKind.cloud,
            "resource_key": expected.get("provider", "cloud") + "/resources",
            "title": "Cloud resource drift",
            "description": "Cloud inventory differs from desired state.",
            "severity": DriftSeverity.critical,
            "expected": expected,
            "actual": actual,
            "diff_summary": str(diff)[:2000],
            "suggested_fix": "Review security group / bucket policy and apply IaC module after approval.",
        }
    )
    # Specific SG open-to-world check
    for res in (actual or {}).get("resources", []) or []:
        if res.get("type") == "security_group":
            for rule in res.get("ingress", []) or []:
                if rule.get("cidr") in ("0.0.0.0/0", "::/0") and rule.get("port") not in (80, 443):
                    findings.append(
                        {
                            "resource_kind": ResourceKind.cloud,
                            "resource_key": f"{res.get('id')}:{rule.get('port')}",
                            "title": f"Overly permissive SG rule on port {rule.get('port')}",
                            "description": "Ingress allows the public internet on a sensitive port.",
                            "severity": DriftSeverity.critical,
                            "expected": {"cidr": "10.0.0.0/8"},
                            "actual": rule,
                            "diff_summary": f"cidr {rule.get('cidr')} on port {rule.get('port')}",
                            "suggested_fix": "Restrict CIDR to corporate ranges and require approval before apply.",
                        }
                    )
    return findings


def _side_by_side_summary(expected: str, actual: str, max_lines: int = 12) -> str:
    exp_lines = expected.splitlines()
    act_lines = actual.splitlines()
    rows = []
    for i in range(min(max(len(exp_lines), len(act_lines)), max_lines)):
        e = exp_lines[i] if i < len(exp_lines) else ""
        a = act_lines[i] if i < len(act_lines) else ""
        mark = " " if e == a else "≠"
        rows.append(f"{mark} | {e[:80]:<80} | {a[:80]}")
    return "\n".join(rows)


def detect_drift(desired: dict[str, Any], actual: dict[str, Any]) -> list[dict[str, Any]]:
    """Return list of drift finding dicts ready for ORM insert."""
    findings: list[dict[str, Any]] = []
    findings.extend(_file_diff(desired.get("files", {}), actual.get("files", {})))
    exp_pkgs = desired.get("packages", [])
    if isinstance(exp_pkgs, dict):
        findings.extend(_package_diff(exp_pkgs.get("required", []), actual.get("packages", [])))
    else:
        findings.extend(_package_diff(exp_pkgs, actual.get("packages", [])))
    findings.extend(_service_diff(desired.get("services", {}), actual.get("services", {})))
    findings.extend(_registry_diff(desired.get("registry", {}), actual.get("registry", {})))
    findings.extend(_cloud_diff(desired.get("cloud", {}), actual.get("cloud", {})))
    return findings


def score_from_findings(findings: list[dict[str, Any]]) -> float:
    """0 = clean, 100 = severely drifted."""
    weights = {
        DriftSeverity.critical: 25,
        DriftSeverity.high: 15,
        DriftSeverity.medium: 8,
        DriftSeverity.low: 3,
        DriftSeverity.info: 1,
    }
    total = 0.0
    for f in findings:
        sev = f.get("severity", DriftSeverity.medium)
        if isinstance(sev, str):
            sev = DriftSeverity(sev)
        total += weights.get(sev, 5)
    return float(min(100.0, total))
