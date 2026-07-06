#!/usr/bin/env python3
"""Repair accidental WSUS product-name replacements from cleanup script."""
from __future__ import annotations

import re
from pathlib import Path

WORKSPACE = Path(__file__).resolve().parent.parent
WSUS_IP = "31.39.1.252"

TEXT_REPLACEMENTS = [
    (re.compile(r"\$31\.39\.1\.252\b"), "$WSUS"),
    (re.compile(r"\[string\]\$31\.39\.1\.252\b"), "[string]$WSUS"),
    (re.compile(rf"\b{re.escape(WSUS_IP)} Server\b"), "WSUS Server"),
    (re.compile(rf"\b{re.escape(WSUS_IP)} Status Server\b"), "WSUS Status Server"),
    (re.compile(rf"\b{re.escape(WSUS_IP)} Report\b"), "WSUS Report"),
    (re.compile(rf"\b{re.escape(WSUS_IP)} cleanup\b", re.I), "WSUS cleanup"),
    (re.compile(rf"\b{re.escape(WSUS_IP)} client settings\b", re.I), "WSUS client settings"),
    (re.compile(rf"\b{re.escape(WSUS_IP)} cmdlets\b", re.I), "WSUS cmdlets"),
    (re.compile(rf"\b{re.escape(WSUS_IP)} Administrator Console\b", re.I), "WSUS Administrator Console"),
    (re.compile(rf"set to {re.escape(WSUS_IP)}\b", re.I), "set to WSUS"),
    (re.compile(rf"in {re.escape(WSUS_IP)} \(", re.I), "in WSUS ("),
    (re.compile(rf"#/{re.escape(WSUS_IP)}/", re.I), "#/WSUS/"),
    (re.compile(rf"src/{re.escape(WSUS_IP)}/", re.I), "src/WSUS/"),
    (re.compile(rf"\*\* {re.escape(WSUS_IP)} ", re.I), "** WSUS "),
    (re.compile(rf"Removing {re.escape(WSUS_IP)} client", re.I), "Removing WSUS client"),
    (re.compile(rf"companion {re.escape(WSUS_IP)} cleanup", re.I), "companion WSUS cleanup"),
    (re.compile(rf"Computers in Active Directory but not in {re.escape(WSUS_IP)}", re.I),
     "Computers in Active Directory but not in WSUS"),
    (re.compile(rf"User Specified {re.escape(WSUS_IP)} Information", re.I), "User Specified WSUS Information"),
    (re.compile(rf"Load {re.escape(WSUS_IP)} Required Assembly", re.I), "Load WSUS Required Assembly"),
    (re.compile(rf"Initial {re.escape(WSUS_IP)} Connection", re.I), "Initial WSUS Connection"),
    (re.compile(rf"{re.escape(WSUS_IP)} SERVER INFORMATION", re.I), "WSUS SERVER INFORMATION"),
    (re.compile(rf"{re.escape(WSUS_IP)} Version", re.I), "WSUS Version"),
    (re.compile(rf"{re.escape(WSUS_IP)} Information", re.I), "WSUS Information"),
    (re.compile(rf"{re.escape(WSUS_IP)} Child Servers", re.I), "WSUS Child Servers"),
    (re.compile(rf"{re.escape(WSUS_IP)} Database", re.I), "WSUS Database"),
    (re.compile(rf"{re.escape(WSUS_IP)} Client Information", re.I), "WSUS Client Information"),
    (re.compile(rf"{re.escape(WSUS_IP)} Update Information", re.I), "WSUS Update Information"),
    (re.compile(rf"{re.escape(WSUS_IP)} Target Group Information", re.I), "WSUS Target Group Information"),
    (re.compile(rf"{re.escape(WSUS_IP)} Update Groups", re.I), "WSUS Update Groups"),
    (re.compile(rf"{re.escape(WSUS_IP)} server info", re.I), "WSUS server info"),
    (re.compile(rf"#Get {re.escape(WSUS_IP)} Client", re.I), "#Get WSUS Client"),
    (re.compile(rf"or {re.escape(WSUS_IP)} not installed", re.I), "or WSUS not installed"),
    (re.compile(rf"for all {re.escape(WSUS_IP)} Update", re.I), "for all WSUS Update"),
    (re.compile(rf"function Validate-{re.escape(WSUS_IP)}"), "function Validate-WSUS"),
    (re.compile(rf"function Install-{re.escape(WSUS_IP)}"), "function Install-WSUS"),
    (re.compile(rf"\bInstall-{re.escape(WSUS_IP)}\b"), "Install-WSUS"),
    (re.compile(rf"-Module {re.escape(WSUS_IP)}\b"), "-Module WSUS"),
    (re.compile(rf'ValidateSet\("EAD","{re.escape(WSUS_IP)}"'), 'ValidateSet("EAD","WSUS"'),
    (re.compile(rf"Option Install {re.escape(WSUS_IP)}"), "Option Install WSUS"),
    (re.compile(rf"Install {re.escape(WSUS_IP)} selections"), "Install WSUS selections"),
    (re.compile(rf"install {re.escape(WSUS_IP)} features"), "install WSUS features"),
    (re.compile(rf"where {re.escape(WSUS_IP)} content"), "where WSUS content"),
    (re.compile(rf"C:\\{re.escape(WSUS_IP)}"), "C:\\\\WSUS"),
    (re.compile(rf"Starting {re.escape(WSUS_IP)} post install"), "Starting WSUS post install"),
    (re.compile(rf"configured {re.escape(WSUS_IP)}\b"), "configured WSUS"),
    (re.compile(rf'\.Name = "{re.escape(WSUS_IP)}"'), '.Name = "WSUS"'),
    (re.compile(rf'\.Text = "Install {re.escape(WSUS_IP)}"'), '.Text = "Install WSUS"'),
]

SKIP_DIRS = {".git", "node_modules"}


def repair_file(path: Path) -> bool:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return False
    if WSUS_IP not in text:
        return False
    original = text
    for pattern, repl in TEXT_REPLACEMENTS:
        text = pattern.sub(repl, text)
    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = []
    for path in WORKSPACE.rglob("*"):
        if not path.is_file() or ".git" in path.parts:
            continue
        if repair_file(path):
            changed.append(str(path.relative_to(WORKSPACE)))
    print(f"Repaired {len(changed)} files")
    for f in changed:
        print(f"  {f}")


if __name__ == "__main__":
    main()
