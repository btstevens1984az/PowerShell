# AGENTS.md

## Cursor Cloud specific instructions

This repository is a **PowerShell Infrastructure Script Library** — a curated collection of
PowerShell scripts, modules, and GUI tools (plus a few Python/bash maintenance scripts). There is
no compiled application or long-running service to start; "running the code" means linting,
testing, or executing individual `.ps1`/`.psm1` files.

### Toolchain (installed by the update script / baked into the VM snapshot)
- **PowerShell 7 (`pwsh`)** — the core runtime for every `.ps1`/`.psm1` file. Installed from the
  Microsoft apt repo (`powershell` package).
- **PSScriptAnalyzer** module — the linter for PowerShell code.
- **Pester** (v5) module — the test framework.
- **Python 3** (pre-installed) — only used by `scripts/categorize-random.py`.

### Lint
```bash
pwsh -NoProfile -Command 'Invoke-ScriptAnalyzer -Path <file-or-dir> -Recurse'
```
Most library scripts are legacy/Windows-focused and intentionally produce many
`Information`/`Warning` findings (e.g. `PSAvoidUsingWriteHost`, trailing whitespace); these are
pre-existing and not build failures.

### Test
```bash
pwsh -NoProfile -Command 'Invoke-Pester -Path <path-to-*.Tests.ps1> -Output Detailed'
```
Caveat: the `.Tests.ps1` files under `Shared/Testing/Pester/` are **the upstream Pester project's
own test suite kept as reference material**, not tests of this library. Many use Pester v3/v4
syntax (`Should Be`) and/or reference source files that do not exist here, so they will NOT pass
under Pester v5 out of the box. Do not treat their failures as regressions. When you need to verify
the runner itself works, run a small self-contained `*.Tests.ps1` (Pester v5 `Should -Be` syntax).

### Run a script (gotchas)
- Scripts are authored for **Windows PowerShell**. Many use Windows-only cmdlets/COM
  (`Get-WmiObject`, `Get-Service`, `Scripting.FileSystemObject`, `robocopy`) or interactive
  `Read-Host` prompts and will error on Linux. This is expected — pick cross-platform scripts to
  demonstrate execution.
- Watch for **hard-coded Windows paths** (e.g. `C:\temp\...`). For example
  `Shared/Parallel-Execution/Scripts/Invoke-Parallel.ps1` defaults `-LogFile` to `C:\temp\log.log`;
  pass `-LogFile /tmp/<name>.log` on Linux.
- Dot-source a function file before calling it, e.g.
  `. ./Shared/Parallel-Execution/Scripts/Invoke-Parallel.ps1` then call `Invoke-Parallel`.

### Maintenance scripts
- `scripts/categorize-random.py` and `scripts/reorganize-repo.sh` are one-off repo-reorganization
  tools that operate on a legacy `Random/` folder. That folder no longer exists, so
  `categorize-random.py` prints "Random folder already processed or missing." and exits cleanly —
  do not re-run these to "fix" anything.
