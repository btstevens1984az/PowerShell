# Purpose: renametxttops1 — General-purpose PowerShell utilities.
dir -Recurse -Include "[0-9]*.txt" | Rename-Item -NewName { $_.name -replace '\.txt','.ps1' }