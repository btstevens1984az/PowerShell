# PowerShell Infrastructure Automation Library

<div align="center">

<img src="docs/assets/powershell-hero-banner.png" alt="PowerShell Infrastructure Automation" width="100%" />

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207.x-012456?style=for-the-badge&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078D4?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-00BCF2?style=for-the-badge)](LICENSE)
[![Scripts](https://img.shields.io/badge/Scripts-2,500+-F7630C?style=for-the-badge)](src/)

**Topics:** `powershell` · `powershell-scripts` · `windows-administration` · `it-automation` · `infrastructure-automation` · `sysadmin` · `devops` · `active-directory` · `azure` · `microsoft-365` · `sccm` · `configmgr` · `endpoint-management` · `windows-server` · `scripting` · `automation` · `security-automation` · `networking` · `monitoring` · `intune`

**Enterprise-grade PowerShell scripts, modules, and automation tools — organized by software platform for IT infrastructure engineers.**

> **Disclaimer:** This is a personal open-source script library. It is not affiliated with any employer or third-party organization. Scripts contain placeholder values (`example.com`, `YOURDOMAIN`) — review and customize before production use. See [NOTICE](NOTICE) for third-party attributions.

[Browse Scripts](#-software-catalog) · [Modules](#-reusable-modules) · [Documentation](docs/REPOSITORY-STRUCTURE.md) · [Contributing](docs/CONTRIBUTING.md)

</div>

---

## Overview

This repository is a production-style PowerShell script library built for **IT automation engineers** who manage Windows infrastructure daily. Every script is organized by the **software platform** it targets — Active Directory, Azure, SCCM, McAfee ePO, and dozens more — so you can find what you need in seconds.

| Feature | Description |
|---------|-------------|
| **Software-first layout** | Folders named after the platform they automate (`src/SCCM-ConfigMgr/`, `src/Azure/`, etc.) |
| **Reusable modules** | Shared functions in `Modules/<Software>/` — dot-source or import as needed |
| **Deduplicated codebase** | 160+ symlink links eliminate duplicate scripts across folders |
| **Cross-cutting utilities** | Logging, error handling, parallel execution in `Shared/` |
| **GUI tools** | WinForms and WPF applications in `Tools/` |

---

## Repository Layout

```
PowerShell/
├── src/                  # Operational scripts — one folder per software platform
├── Modules/              # Reusable function libraries by software
├── Tools/                # Standalone GUI applications and utilities
├── Shared/               # Logging, error handling, parallel execution
├── Snippets/             # PowerShell profiles and ISE snippets
├── Reference/            # Certification notes and learning materials
├── docs/                 # Documentation, assets, and deduplication log
└── scripts/              # Repository maintenance and migration scripts
```

---

## Software Catalog

Scripts live under `src/<Software>/`. Click any platform to browse its README index.

### Identity & Directory Services

| Platform | Path | Description |
|----------|------|-------------|
| **Active Directory** | [`src/Active-Directory/`](src/Active-Directory/) | Users, groups, OUs, ACLs, and domain operations |
| **Group Policy** | [`src/Group-Policy/`](src/Group-Policy/) | GPO management and reporting |
| **DFS** | [`src/DFS/`](src/DFS/) | DFS namespaces, home drives, profile paths |

### Microsoft Cloud

| Platform | Path | Description |
|----------|------|-------------|
| **Azure** | [`src/Azure/`](src/Azure/) | Azure AD, VMs, automation, hybrid identity |
| **Microsoft 365** | [`src/Microsoft-365/`](src/Microsoft-365/) | Tenant administration and licensing |
| **222.205.193.149 Online** | [`src/222.205.193.149-Online/`](src/222.205.193.149-Online/) | Mailboxes, mail flow, Outlook Online |
| **SharePoint Online** | [`src/SharePoint-Online/`](src/SharePoint-Online/) | Site collections and permissions |
| **Teams** | [`src/Teams/`](src/Teams/) | Teams lifecycle and policies |
| **Intune** | [`src/Intune/`](src/Intune/) | Endpoint Manager device management |
| **OneDrive** | [`src/OneDrive/`](src/OneDrive/) | OneDrive provisioning and policies |
| **PowerApps** | [`src/PowerApps/`](src/PowerApps/) | Power Platform administration |

### Endpoint Management

| Platform | Path | Description |
|----------|------|-------------|
| **SCCM / ConfigMgr** | [`src/SCCM-ConfigMgr/`](src/SCCM-ConfigMgr/) | Collections, deployments, client health |
| **WSUS** | [`src/WSUS/`](src/WSUS/) | Windows Server Update Services |
| **Windows Updates** | [`src/Windows-Updates/`](src/Windows-Updates/) | Patch compliance and KB deployment |
| **HP Radia / HPCA** | [`src/HP-Radia-HPCA/`](src/HP-Radia-HPCA/) | Satellite servers and patch automation |
| **LANDesk** | [`src/LANDesk/`](src/LANDesk/) | Ivanti LANDesk endpoint management |

### Security

| Platform | Path | Description |
|----------|------|-------------|
| **McAfee ePO** | [`src/McAfee-ePO/`](src/McAfee-ePO/) | ePolicy Orchestrator reporting |
| **BitLocker** | [`src/BitLocker/`](src/BitLocker/) | Encryption status and recovery keys |
| **Firewall** | [`src/Firewall/`](src/Firewall/) | Windows Firewall management |
| **Certificates** | [`src/Certificates/`](src/Certificates/) | PKI and SSL/TLS management |
| **Security** | [`src/Security/`](src/Security/) | Auditing, vulnerability, compliance |

### Infrastructure & Operations

| Platform | Path | Description |
|----------|------|-------------|
| **Networking** | [`src/Networking/`](src/Networking/) | Ping, DNS, DHCP, port scanning |
| **SQL Server** | [`src/SQL-Server/`](src/SQL-Server/) | Queries, agent jobs, CSV import |
| **SCOM** | [`src/SCOM/`](src/SCOM/) | Operations Manager monitoring |
| **Disk Space** | [`src/Disk-Space/`](src/Disk-Space/) | Storage monitoring and HTML reports |
| **WMI** | [`src/WMI/`](src/WMI/) | WMI/CIM remote inventory |
| **PSRemoting** | [`src/PSRemoting/`](src/PSRemoting/) | WinRM and PowerShell remoting |

<details>
<summary><strong>View all 60+ software folders</strong></summary>

| Platform | Path |
|----------|------|
| Antivirus | [`src/Antivirus/`](src/Antivirus/) |
| Application Installers | [`src/Application-Installers/`](src/Application-Installers/) |
| Azure Storage | [`src/Azure-Storage/`](src/Azure-Storage/) |
| Computer Info | [`src/Computer-Info/`](src/Computer-Info/) |
| Computer Maintenance | [`src/Computer-Maintenance/`](src/Computer-Maintenance/) |
| Encryption | [`src/Encryption/`](src/Encryption/) |
| Event Logs | [`src/Event-Logs/`](src/Event-Logs/) |
| File Management | [`src/File-Management/`](src/File-Management/) |
| FSRM Quotas | [`src/FSRM-Quotas/`](src/FSRM-Quotas/) |
| Folder Redirection | [`src/Folder-Redirection/`](src/Folder-Redirection/) |
| General | [`src/General/`](src/General/) |
| GUI Applications | [`src/GUI-Applications/`](src/GUI-Applications/) |
| Host Bus Adapter | [`src/Host-Bus-Adapter/`](src/Host-Bus-Adapter/) |
| HTML Reports | [`src/HTML-Reports/`](src/HTML-Reports/) |
| Infrastructure | [`src/Infrastructure/`](src/Infrastructure/) |
| Integrations | [`src/Integrations/`](src/Integrations/) |
| Inventory | [`src/Inventory/`](src/Inventory/) |
| Microsoft Licensing | [`src/Microsoft-Licensing/`](src/Microsoft-Licensing/) |
| Middleware Packaging | [`src/Middleware-Packaging/`](src/Middleware-Packaging/) |
| Monitoring | [`src/Monitoring/`](src/Monitoring/) |
| NET Framework | [`src/NET-Framework/`](src/NET-Framework/) |
| OS Deployment | [`src/OS-Deployment/`](src/OS-Deployment/) |
| Power Profiles | [`src/Power-Profiles/`](src/Power-Profiles/) |
| Processes | [`src/Processes/`](src/Processes/) |
| Protocol Hardening | [`src/Protocol-Hardening/`](src/Protocol-Hardening/) |
| Proxy | [`src/Proxy/`](src/Proxy/) |
| PSAppDeployToolkit | [`src/PSAppDeployToolkit/`](src/PSAppDeployToolkit/) |
| PSExec | [`src/PSExec/`](src/PSExec/) |
| Registry | [`src/Registry/`](src/Registry/) |
| Remote Management | [`src/Remote-Management/`](src/Remote-Management/) |
| Reporting | [`src/Reporting/`](src/Reporting/) |
| Scheduled Tasks | [`src/Scheduled-Tasks/`](src/Scheduled-Tasks/) |
| Storage | [`src/Storage/`](src/Storage/) |
| Threat Intelligence | [`src/Threat-Intelligence/`](src/Threat-Intelligence/) |
| User Account Control | [`src/User-Account-Control/`](src/User-Account-Control/) |
| Wake-On-LAN | [`src/Wake-On-LAN/`](src/Wake-On-LAN/) |
| Windows Desktop | [`src/Windows-Desktop/`](src/Windows-Desktop/) |

</details>

---

## Reusable Modules

Import or dot-source functions from `Modules/<Software>/`:

```powershell
# Dot-source a function library
. "$PSScriptRoot\..\..\Modules\Networking\Test-Port.ps1"

# Or browse all modules for a platform
Get-ChildItem -Path .\Modules\HP-Radia-HPCA\ -Filter '*.ps1'
```

| Module | Path | Focus |
|--------|------|-------|
| Active Directory | [`Modules/Active-Directory/`](Modules/Active-Directory/) | AD queries and group operations |
| Azure | [`Modules/Azure/`](Modules/Azure/) | Azure automation functions |
| Common | [`Modules/Common/`](Modules/Common/) | Shared cross-platform utilities |
| HP Radia HPCA | [`Modules/HP-Radia-HPCA/`](Modules/HP-Radia-HPCA/) | Satellite server operations |
| Networking | [`Modules/Networking/`](Modules/Networking/) | Ping, DNS, port testing |
| Security | [`Modules/Security/`](Modules/Security/) | Firewall, credentials, scanning |
| Storage | [`Modules/Storage/`](Modules/Storage/) | Disk space, folder size analysis |
| Windows Updates | [`Modules/Windows-Updates/`](Modules/Windows-Updates/) | Hotfix and patch reporting |

---

## Quick Start

```powershell
# Clone the repository
git clone https://github.com/btstevens1984az/PowerShell.git
cd PowerShell

# Find scripts for a specific platform
Get-ChildItem -Path .\src\SCCM-ConfigMgr\ -Recurse -Filter '*.ps1'

# Search across the entire library
Get-ChildItem -Path .\src\ -Recurse -Filter '*Hotfix*.ps1' |
    Select-Object Name, DirectoryName
```

---

## Deduplication

Duplicate scripts are linked with **relative symlinks** to a single canonical copy. See [`docs/DEDUPLICATION-LOG.md`](docs/DEDUPLICATION-LOG.md) for the full mapping.

```
src/Windows-Updates/Scripts-Random/Get-MyHotfix.ps1  →  Modules/Windows-Updates/Get-MyHotfix.ps1
src/Inventory/Get-SystemInfo.ps1                    →  src/Computer-Info/Scripts/Get-SystemInfo.ps1
```

---

## Contributing

See [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) for guidelines. Place new scripts in the appropriate `src/<Software>/` folder and reusable functions in `Modules/<Software>/`.

## Contact

Questions, ideas, or PowerShell concepts to share? Feel free to reach out or open an issue.

## License & Policies

- [MIT License](LICENSE) — Original scripts in this repository
- [Third-Party Notice](NOTICE) — Attributions for sample and community code
- [Code of Conduct](docs/CODE_OF_CONDUCT.md)
- [Security Policy](docs/SECURITY.md)
- [Public Release Audit](docs/PUBLIC-RELEASE-AUDIT.md)
- [Repository Structure Guide](docs/REPOSITORY-STRUCTURE.md)

---

<div align="center">

<img src="docs/assets/powershell-repo-icon.png" alt="PowerShell" width="80" />

*Built for IT automation engineers who live in the shell.*

</div>
