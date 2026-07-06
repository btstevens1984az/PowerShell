# Repository Structure Guide

This document describes the **software-first** organization of this PowerShell script library.

## Design Principles

1. **Software-first organization** — Folders are named after the platform they automate (`src/SCCM-ConfigMgr/`, `src/Azure/`, `src/McAfee-ePO/`), not abstract IT domains.
2. **Canonical copies with symlinks** — When the same script exists in multiple locations, one canonical copy is kept and duplicates are replaced with relative symlinks. See [`DEDUPLICATION-LOG.md`](DEDUPLICATION-LOG.md).
3. **Separation of concerns** — Reusable functions live in `Modules/`, GUI tools in `Tools/`, and cross-cutting utilities in `Shared/`.
4. **Preserved history** — All moves use `git mv` to retain file history.

## Directory Reference

### `src/` — Operational Scripts (by Software)

Each top-level folder under `src/` represents a software platform:

| Software Folder | Contents |
|---|---|
| `Active-Directory/` | Users, groups, OUs, ACLs, permissions |
| `Azure/` | Azure AD, VMs, automation, hybrid identity |
| `Microsoft-365/` | Office 365 tenant administration |
| `222.205.193.149-Online/` | Mailbox, mail flow, Outlook Online |
| `SCCM-ConfigMgr/` | Configuration Manager collections and deployments |
| `WSUS/` | Windows Server Update Services |
| `Windows-Updates/` | Patch compliance, hotfix reporting |
| `HP-Radia-HPCA/` | HP Radia satellite server operations |
| `McAfee-ePO/` | ePolicy Orchestrator reporting |
| `Networking/` | Ping, DNS, DHCP, port scanning |
| `Disk-Space/` | Storage monitoring and HTML reports |
| `SQL-Server/` | SQL queries, agent jobs, CSV import |
| `General/` | Uncategorized scripts — review and relocate |

Each software folder may contain subfolders such as `Scripts/`, `Scripts-Random/` (legacy staging), or technology-specific subdirectories.

### `Modules/` — Reusable Function Libraries (by Software)

| Module Folder | Contents |
|---|---|
| `Active-Directory/` | AD query and group management functions |
| `Azure/` | Azure automation functions |
| `Common/` | Cross-platform shared utilities |
| `HP-Radia-HPCA/` | Satellite server and patch functions |
| `Networking/` | Ping, DNS, port testing functions |
| `Security/` | Firewall, credential, scanning functions |
| `Storage/` | Disk space, folder size analysis |
| `Windows-Updates/` | Hotfix and patch reporting functions |

### `Tools/` — Standalone Applications

| Path | Contents |
|---|---|
| `GUI-Applications/` | PowerShell forms, WPF/XAML GUIs |
| `Ping-Tool/` | GUI ping utility |

### `Shared/` — Cross-Cutting Utilities

| Path | Contents |
|---|---|
| `Error-Handling/` | Try/catch patterns |
| `Logging/` | Debug logging helpers |
| `Parallel-Execution/` | Parallel job utilities |
| `PowerShell-Toolbag/` | CIM, WMI helpers |
| `Data-Export/` | XML and data export |
| `Testing/Pester/` | Pester test suites |

### `Snippets/` — Shell Customization

| Path | Contents |
|---|---|
| `PowerShell-Profiles/` | `$PROFILE` scripts |
| `ISE-Snippets/` | PowerShell ISE snippet templates |

### `Reference/` — Non-Operational Material

| Path | Contents |
|---|---|
| `Certification/` | Azure exam Q&A |
| `Learning/` | Book samples, PSRepository references |
| `DevOps/` | TeamCity and CI/CD references |

## Migration History

| Version | Change |
|---|---|
| v1 (legacy) | 50+ flat top-level folders, 2,400+ files in `Random/` |
| v2 (domain-first) | Reorganized into `src/<Domain>/<Technology>/` |
| v3 (current) | Flattened to `src/<Software>/` and `Modules/<Software>/` with symlink deduplication |

## Adding New Scripts

1. Identify the target **software platform** (e.g., SCCM, Azure, Active Directory).
2. Place the script in `src/<Software>/Scripts/`.
3. If the script is a reusable function, place it in `Modules/<Software>/`.
4. If a similar script already exists, create a **symlink** to the canonical copy instead of duplicating.
5. Use descriptive verb-noun PowerShell naming conventions.

## Maintenance Scripts

| Script | Purpose |
|---|---|
| `scripts/reorganize-by-software.sh` | Flatten domain layout to software-first folders |
| `scripts/reorganize-modules-by-software.py` | Categorize module functions by software |
| `scripts/deduplicate-symlinks.py` | Replace duplicate `.ps1` files with symlinks |
| `scripts/generate-software-readmes.py` | Regenerate per-folder README indexes |
| `scripts/categorize-random.py` | Auto-categorize uncategorized scripts |
