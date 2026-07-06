# File-Management

> File and folder operations, ownership, and aging reports.

**Scripts & functions:** 11

## Subfolders

- [`Directories/`](Directories/) — 2 script(s)
- [`Scripts/`](Scripts/) — 9 script(s)

## Quick Start

```powershell
# Browse scripts in this folder
Get-ChildItem -Path $PSScriptRoot -Recurse -Filter '*.ps1' |
    Select-Object Name, DirectoryName
```

---
[← Back to repository root](../../README.md)
