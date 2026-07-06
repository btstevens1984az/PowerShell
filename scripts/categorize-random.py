#!/usr/bin/env python3
"""Categorize and move root-level files from Random/ into IT infrastructure folders."""
import os
import re
import subprocess
from pathlib import Path

WORKSPACE = Path("/workspace")
RANDOM = WORKSPACE / "Random"
DEST_BASE = WORKSPACE / "src"
ROOT_DEST_PREFIXES = ("Snippets/", "Shared/", "Reference/")

# Order matters: first match wins
CATEGORY_RULES = [
    ("Identity-Access/Active-Directory/Scripts-Random", [
        r"^AD[-_]", r"^ADComputer", r"^Get-AD", r"^Set-AD", r"^New-AD", r"^Remove-AD",
        r"^Find-AD", r"^Disable-AD", r"^Enable-AD", r"ActiveDirectory", r"GroupPolicy",
        r"^GPUpdate", r"^GPO", r"HomeFolder", r"HomeDrive",
    ]),
    ("Cloud/Exchange-Online/Scripts-Random", [
        r"^EXO[-_]", r"Exchange", r"Mailbox", r"^OWA", r"Outlook", r"SMTP", r"MailFlow",
        r"CalendarPermission", r"AutoForward",
    ]),
    ("Cloud/Azure/Scripts-Random", [
        r"^Azure", r"^Az[-_]", r"RegisterNodesWithAzure", r"AzureAuto", r"AzureDSC",
        r"DeviceReg", r"HybridJoin", r"^DSReg",
    ]),
    ("Cloud/Microsoft-365/Scripts-Random", [
        r"^O365", r"Office365", r"M365", r"Microsoft365", r"Teams", r"SharePoint",
        r"OneDrive", r"Intune", r"^MSOL", r"GraphAPI",
    ]),
    ("Endpoint-Management/SCCM-ConfigMgr/Scripts-Random", [
        r"^SCCM", r"^CM[-_]", r"ConfigMgr", r"ConfigurationManager", r"Collection",
        r"DeploymentShare", r"OSDeploy",
    ]),
    ("Endpoint-Management/WSUS/Scripts-Random", [
        r"^WSUS", r"Wsus", r"WindowsUpdateServer",
    ]),
    ("Endpoint-Management/Windows-Updates/Scripts-Random", [
        r"WindowsUpdate", r"^WU[-_]", r"HotFix", r"^KB\d", r"Patch", r"CumulativeUpdate",
        r"Vulnerability", r"CVE[-_]", r"Spectre", r"Meltdown",
    ]),
    ("Endpoint-Management/HP-Radia-HPCA/Scripts-Random", [
        r"Radia", r"HPCA", r"Satellite", r"PatchFest", r"EDM",
    ]),
    ("Deployment/App-Deployment-Toolkit/Scripts-Random", [
        r"AppDeploy", r"Deploy-Application", r"PSAppDeploy", r"Chocolatey", r"^Install-",
        r"^Uninstall-", r"^Push-Software", r"MSI",
    ]),
    ("Security/Scripts-Random", [
        r"BitLocker", r"Encrypt", r"Firewall", r"Nexpose", r"Rapid7", r"Nmap",
        r"Antivirus", r"Defender", r"ePO", r"McAfee", r"Virus", r"Security",
        r"Credential", r"Password", r"MFA", r"Lockout", r"Audit",
    ]),
    ("Networking/Diagnostics/Scripts-Random", [
        r"^Ping", r"DNS", r"DHCP", r"^TCP", r"Port", r"Network", r"Subnet", r"NIC",
        r"IPRange", r"Traceroute", r"Resolve-DNS",
    ]),
    ("Storage-FileServices/Scripts-Random", [
        r"Disk", r"Folder", r"File", r"Storage", r"DFS", r"FSRM", r"Quota",
    ]),
    ("Monitoring-Reporting/Scripts-Random", [
        r"EventLog", r"SCOM", r"Report", r"HTML", r"Inventory", r"Monitor",
        r"HealthCheck", r"Alert",
    ]),
    ("Remote-Management/Scripts-Random", [
        r"PSRemot", r"WinRM", r"PSSession", r"RemotePS", r"PsExec", r"CredSSP",
        r"Invoke-Command", r"Enter-PSSession",
    ]),
    ("Infrastructure/SQL-Server/Scripts-Random", [
        r"^SQL", r"SqlQuery", r"Invoke-SQL", r"SQLAgent", r"SQLServer",
    ]),
    ("Infrastructure/Registry/Scripts-Random", [
        r"Registry", r"RegKey", r"^Reg[-_]", r"HKLM", r"HKCU",
    ]),
    ("Infrastructure/WMI/Scripts-Random", [
        r"^WMI", r"^CIM", r"Get-Wmi", r"Get-Cim", r"WmiObject",
    ]),
    ("Infrastructure/Scripts-Random", [
        r"Hyper-V", r"VMware", r"PowerCLI", r"Virtual", r"^VM[-_]", r"NanoServer",
        r"DSC", r"DesiredState", r"LCM", r"PullServer",
    ]),
    ("Desktop-OperatingSystem/Scripts-Random", [
        r"Windows10", r"Win10", r"Sophia", r"Computer", r"Desktop", r"Service",
        r"Process", r"Printer", r"ScheduledTask", r"UAC", r"PowerProfile",
    ]),
    ("Inventory-Discovery/Scripts-Random", [
        r"SystemInfo", r"ComputerInfo", r"Get-PC", r"InstalledSoftware", r"Hardware",
        r"BIOS", r"SerialNumber", r"Asset",
    ]),
    ("Tools/GUI-Applications/Scripts-Random", [
        r"GUI", r"XAML", r"WinForms", r"Show-UI", r"Initialize-UI", r"\.Export\.ps1$",
        r"Form", r"WPF",
    ]),
    ("Snippets/ISE-Snippets", [
        r"\.ps1xml$", r"\.snippets\.",
    ]),
    ("Reference/Learning/Book-Samples", [
        r"^listing", r"^Listing", r"^6[-_]", r"^9\.", r"^10_", r"cmdletbinding",
        r"shouldprocess", r"^Chapter",
    ]),
    ("Shared/Testing/Pester", [
        r"\.Tests\.ps1$", r"Pester", r"PowerShellGet",
    ]),
]

DEFAULT_DEST = "General/Scripts-Random"


def categorize(filename: str) -> str:
    for dest, patterns in CATEGORY_RULES:
        for pat in patterns:
            if re.search(pat, filename, re.IGNORECASE):
                return dest
    return DEFAULT_DEST


def git_mv(src: Path, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(["git", "mv", str(src), str(dest)], check=True, cwd=WORKSPACE)


def main():
    if not RANDOM.exists():
        print("Random folder already processed or missing.")
        return

    moved = {}
    skipped = []

    for item in sorted(RANDOM.iterdir()):
        if item.is_dir():
            skipped.append(f"DIR (should be empty): {item.name}")
            continue

        dest_sub = categorize(item.name)
        if dest_sub.startswith(ROOT_DEST_PREFIXES):
            dest_dir = WORKSPACE / dest_sub
        else:
            dest_dir = DEST_BASE / dest_sub
        dest_path = dest_dir / item.name

        # Handle name collisions
        if dest_path.exists():
            stem = item.stem
            suffix = item.suffix
            counter = 1
            while dest_path.exists():
                dest_path = dest_dir / f"{stem}-Random{counter}{suffix}"
                counter += 1

        git_mv(item, dest_path)
        moved.setdefault(dest_sub, 0)
        moved[dest_sub] += 1

    # Move any remaining subdirs in Random to General
    for item in list(RANDOM.iterdir()):
        if item.is_dir():
            dest = DEST_BASE / "General" / item.name
            git_mv(item, dest)
            moved.setdefault("General/" + item.name, 0)
            moved["General/" + item.name] += 1

    # Remove Random if empty
    try:
        RANDOM.rmdir()
        print("Removed empty Random/ directory.")
    except OSError:
        remaining = list(RANDOM.iterdir())
        print(f"Random/ not empty, {len(remaining)} items remain.")

    print("\n=== Migration Summary ===")
    for dest, count in sorted(moved.items(), key=lambda x: -x[1]):
        print(f"  {count:4d} -> src/{dest}")
    print(f"\nTotal files moved: {sum(moved.values())}")
    if skipped:
        print(f"\nSkipped: {len(skipped)}")


if __name__ == "__main__":
    main()
