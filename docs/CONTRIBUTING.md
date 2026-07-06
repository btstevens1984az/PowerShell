
# Contributing

Thank you for contributing to the PowerShell Infrastructure Automation Library.

## Where to Place New Content

| Content Type | Location | Example |
|---|---|---|
| Operational script | `src/<Software>/Scripts/` | `src/SCCM-ConfigMgr/Scripts/Get-ClientHealth.ps1` |
| Reusable function | `Modules/<Software>/` | `Modules/Networking/Test-Port.ps1` |
| GUI application | `Tools/GUI-Applications/` | `Tools/GUI-Applications/Get-ServicesXAMLGUI.ps1` |
| Shared utility | `Shared/<Category>/` | `Shared/Logging/Scripts/Write-DebugLog.ps1` |
| Profile or snippet | `Snippets/` | `Snippets/PowerShell-Profiles/MyProfile.ps1` |

## Naming Conventions

- Use approved PowerShell verbs: `Get-`, `Set-`, `New-`, `Remove-`, `Test-`, `Invoke-`
- Use singular nouns where possible: `Get-ADUser`, not `Get-ADUsers`
- Avoid environment-specific hardcoding — use parameters for server names, domains, and paths

## Avoiding Duplicates

Before adding a script, search the repository:

```powershell
Get-ChildItem -Recurse -Filter 'Your-ScriptName.ps1'
```

If a similar script exists, **do not copy it**. Instead, create a relative symlink to the canonical copy:

```bash
ln -s ../../Modules/Networking/Test-Port.ps1 src/Networking/Scripts-Random/Test-Port.ps1
```

Document new symlinks by re-running `scripts/deduplicate-symlinks.py`.

## Pull Request Checklist

- [ ] Script placed in the correct `src/<Software>/` or `Modules/<Software>/` folder
- [ ] No duplicate copies — symlinks used where appropriate
- [ ] Verb-noun naming convention followed
- [ ] No hardcoded organization-specific server names or credentials
- [ ] README updated if adding a new software platform folder

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).
