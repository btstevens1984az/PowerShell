#!/usr/bin/env python3
"""Generate README.md index files for each software folder under src/ and Modules/."""
from __future__ import annotations

from pathlib import Path

WORKSPACE = Path("/workspace")

SOFTWARE_DESCRIPTIONS = {
  "Active-Directory": "User, group, and OU management; ACL auditing; domain controller operations.",
  "Azure": "Azure AD, VMs, automation, DSC, and hybrid identity scripts.",
  "Azure-Storage": "Azure Storage account management and blob operations.",
  "Microsoft-365": "Office 365 tenant administration and PowerShell automation.",
  "Exchange-Online": "Mailbox, mail flow, and Outlook Online administration.",
  "SharePoint-Online": "SharePoint site collections, permissions, and content management.",
  "OneDrive": "OneDrive for Business provisioning and policy scripts.",
  "Teams": "Microsoft Teams lifecycle and policy management.",
  "Intune": "Endpoint Manager / Intune device and app management.",
  "PowerApps": "Power Platform and PowerApps administration samples.",
  "Microsoft-Licensing": "M365 and Azure license reporting and assignment.",
  "Integrations": "Jira, Web API, and third-party integration scripts.",
  "SCCM-ConfigMgr": "Configuration Manager collections, deployments, and client health.",
  "WSUS": "Windows Server Update Services administration.",
  "Windows-Updates": "Patch compliance, hotfix reporting, and KB deployment.",
  "HP-Radia-HPCA": "HP Radia / HPCA satellite server and patch automation.",
  "LANDesk": "Ivanti LANDesk endpoint management scripts.",
  "PSAppDeployToolkit": "PSAppDeployToolkit deployment wrappers and examples.",
  "Application-Installers": "Silent application installers (Firefox, Java, Chrome, etc.).",
  "Middleware-Packaging": "Middleware and browser packaging automation.",
  "OS-Deployment": "Windows 10/11 imaging and MDT/OS deployment utilities.",
  "McAfee-ePO": "McAfee ePolicy Orchestrator reporting and host management.",
  "BitLocker": "BitLocker encryption status and recovery key scripts.",
  "Encryption": "Data encryption and credential protection utilities.",
  "Certificates": "PKI, certificate enrollment, and SSL/TLS management.",
  "Firewall": "Windows Firewall rules and remote status checks.",
  "Antivirus": "Antivirus status, definition updates, and compliance.",
  "Security": "General security auditing, vulnerability, and compliance scripts.",
  "Threat-Intelligence": "VirusTotal API and threat intelligence integrations.",
  "Protocol-Hardening": "TLS, SMB, and protocol security hardening.",
  "User-Account-Control": "UAC configuration and elevation management.",
  "Networking": "Ping, DNS, DHCP, port scanning, and network diagnostics.",
  "Proxy": "Internet proxy configuration and PAC file management.",
  "Wake-On-LAN": "Wake-on-LAN magic packet utilities.",
  "Disk-Space": "Disk space monitoring, alerts, and HTML reports.",
  "File-Management": "File and folder operations, ownership, and aging reports.",
  "FSRM-Quotas": "File Server Resource Manager quota management.",
  "Folder-Redirection": "Folder redirection GPO and profile path scripts.",
  "Storage": "General storage and file share utilities.",
  "SCOM": "System Center Operations Manager monitoring scripts.",
  "Event-Logs": "Windows event log collection, filtering, and export.",
  "Reporting": "Excel, CSV, and custom report generation.",
  "HTML-Reports": "HTML dashboard and status report builders.",
  "Monitoring": "Health checks, inventory dashboards, and alerting.",
  "PSRemoting": "PowerShell remoting, WinRM, and CredSSP configuration.",
  "PSExec": "Remote command execution via PsExec.",
  "Remote-Management": "General remote administration utilities.",
  "SQL-Server": "SQL Server queries, agent jobs, and CSV import.",
  "Registry": "Registry search, export, and bulk modification.",
  "WMI": "WMI/CIM queries and remote inventory.",
  "Scheduled-Tasks": "Task Scheduler creation and management.",
  "Host-Bus-Adapter": "HBA and SAN fabric management.",
  "Power-Profiles": "Windows power plan configuration.",
  "Infrastructure": "Hyper-V, VMware, and general infrastructure scripts.",
  "Computer-Maintenance": "Routine desktop/server maintenance chores.",
  "Computer-Info": "System information collection and HTA tools.",
  "Inventory": "Hardware and software inventory discovery.",
  "Processes": "Process monitoring and management.",
  "NET-Framework": ".NET Framework detection and installation.",
  "Windows-Desktop": "Windows desktop tuning and utility scripts.",
  "DFS": "DFS namespaces, home drives, and profile path management.",
  "Group-Policy": "Group Policy Object management and reporting.",
  "General": "Uncategorized utility scripts — review and relocate as needed.",
  "GUI-Applications": "PowerShell WinForms and WPF/XAML GUI tools.",
  # Modules
  "Common": "Shared utility functions used across multiple platforms.",
  "Deployment": "Software deployment and packaging functions.",
}


def count_scripts(folder: Path) -> int:
  count = 0
  for ext in ("*.ps1", "*.PS1", "*.psm1"):
    count += len(list(folder.rglob(ext)))
  return count


def list_subfolders(folder: Path) -> list[str]:
  subs = sorted(
    d.name for d in folder.iterdir()
    if d.is_dir() and not d.name.startswith(".")
  )
  return subs


def generate_readme(folder: Path, label: str) -> None:
  desc = SOFTWARE_DESCRIPTIONS.get(label, f"PowerShell scripts and functions for {label}.")
  script_count = count_scripts(folder)
  subs = list_subfolders(folder)

  lines = [
    f"# {label}",
    "",
    f"> {desc}",
    "",
    f"**Scripts & functions:** {script_count}",
    "",
  ]

  if subs:
    lines += ["## Subfolders", ""]
    for sub in subs:
      sub_path = folder / sub
      sub_count = count_scripts(sub_path)
      lines.append(f"- [`{sub}/`]({sub}/) — {sub_count} script(s)")
    lines.append("")

  lines += [
    "## Quick Start",
    "",
    "```powershell",
    f"# Browse scripts in this folder",
    f"Get-ChildItem -Path $PSScriptRoot -Recurse -Filter '*.ps1' |",
    f"    Select-Object Name, DirectoryName",
    "```",
    "",
    "---",
    f"[← Back to repository root](../../README.md)",
    "",
  ]

  readme = folder / "README.md"
  readme.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
  for base in [WORKSPACE / "src", WORKSPACE / "Modules"]:
    if not base.exists():
      continue
    for folder in sorted(base.iterdir()):
      if folder.is_dir() and not folder.name.startswith("."):
        generate_readme(folder, folder.name)
  print("Generated software index README files.")


if __name__ == "__main__":
  main()
