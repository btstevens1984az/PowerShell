#!/usr/bin/env python3
"""Reorganize Modules/Common-Functions into software-labeled folders."""
from __future__ import annotations

import re
import subprocess
from pathlib import Path

WORKSPACE = Path("/workspace")
SRC_MODULES = WORKSPACE / "Modules" / "Common-Functions"
DEST_BASE = WORKSPACE / "Modules"

RULES: list[tuple[str, list[str]]] = [
  ("Active-Directory", [r"^AD[-_]", r"^Get-AD", r"^Set-AD", r"^New-AD", r"^Remove-AD", r"Group", r"HPCAAD", r"HomeFolder", r"HomeDrive"]),
  ("Azure", [r"^Azure", r"^Az[-_]", r"AzureAD", r"HybridJoin", r"DSReg"]),
  ("Microsoft-365", [r"^O365", r"Office365", r"M365", r"^MSOL", r"GraphAPI", r"Teams", r"SharePoint", r"OneDrive"]),
  ("Exchange-Online", [r"Exchange", r"Mailbox", r"^EXO", r"Outlook", r"SMTP"]),
  ("SCCM-ConfigMgr", [r"^SCCM", r"ConfigMgr", r"Collection", r"OSDeploy"]),
  ("WSUS", [r"^WSUS", r"Wsus"]),
  ("Windows-Updates", [r"HotFix", r"Hotfix", r"^KB", r"Patch", r"WindowsUpdate", r"Meltdown", r"Spectre", r"Cumulative"]),
  ("HP-Radia-HPCA", [r"HPCA", r"Radia", r"Satellite", r"PatchFest", r"EDM"]),
  ("McAfee-ePO", [r"ePO", r"McAfee", r"Bulletin", r"DeviceStatus"]),
  ("Security", [r"Firewall", r"Nmap", r"Nexpose", r"Password", r"Credential", r"Security", r"Encrypt", r"BitLocker", r"Antivirus", r"Defender"]),
  ("Networking", [r"^Ping", r"DNS", r"DHCP", r"Port", r"Network", r"IPRange", r"Subnet", r"NIC", r"WinRM", r"Test-Port"]),
  ("Storage", [r"Disk", r"Folder", r"File", r"FSRM", r"Quota", r"DFS"]),
  ("SQL-Server", [r"^SQL", r"SqlQuery", r"Invoke-SQL"]),
  ("WMI", [r"^WMI", r"^CIM", r"Get-Wmi", r"Get-Cim"]),
  ("Remote-Management", [r"PSRemot", r"PSSession", r"Invoke-Command", r"Remote", r"PsExec", r"CredSSP"]),
  ("Reporting", [r"Report", r"HTML", r"GridView", r"Excel"]),
  ("Deployment", [r"^Install-", r"^Uninstall-", r"Push-Software", r"MSI", r"Deploy", r"AppDeploy", r"Chocolatey"]),
  ("Windows-Desktop", [r"Computer", r"Process", r"Service", r"Registry", r"Scheduled", r"Bios", r"Boot", r"Uptime", r"Recycle"]),
]

COMPILED = [(name, [re.compile(p, re.I) for p in patterns]) for name, patterns in RULES]


def categorize(filename: str) -> str:
  for name, patterns in COMPILED:
    if any(p.search(filename) for p in patterns):
      return name
  return "Common"


def git_mv(src: Path, dest: Path) -> None:
  dest.parent.mkdir(parents=True, exist_ok=True)
  if dest.exists():
    return
  subprocess.run(["git", "mv", str(src), str(dest)], check=True, cwd=WORKSPACE)


def main() -> None:
  if not SRC_MODULES.exists():
    print("Source Modules/Common-Functions not found; skipping.")
    return

  moved = 0
  for folder in ["Enterprise-Functions", "Folder-and-File"]:
    src_dir = SRC_MODULES / folder
    if not src_dir.exists():
      continue
    for item in sorted(src_dir.iterdir()):
      if item.name in ("blank.txt",):
        continue
      software = categorize(item.name)
      dest = DEST_BASE / software / item.name
      git_mv(item, dest)
      moved += 1

  # Remove empty legacy folders
  for folder in ["Enterprise-Functions", "Folder-and-File"]:
    legacy = SRC_MODULES / folder
    if legacy.exists() and not any(legacy.iterdir()):
      legacy.rmdir()

  if SRC_MODULES.exists() and not any(SRC_MODULES.iterdir()):
    SRC_MODULES.rmdir()

  print(f"Moved {moved} module files into software-labeled folders.")


if __name__ == "__main__":
  main()
