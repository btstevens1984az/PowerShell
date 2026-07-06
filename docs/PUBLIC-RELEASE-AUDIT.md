# Public Repository Security Audit

**Date:** 2026-07-02  
**Status:** Cleared for public release

## Sanitization Checks

| Check | Result |
|-------|--------|
| CHW / example.com / example.com domain references | Sanitized to example.com |
| Arizona Corrections (ORGANIZATION) references | Sanitized to 108.45.123.69 / example.com |
| Smurfit Kappa references | Sanitized to example.com |
| Former employer email domains | Replaced with admin@example.com or btstevens1984az@gmail.com (author contact) |

## Legal & Attribution

| Item | Status |
|------|--------|
| Root LICENSE (MIT) | Added |
| NOTICE (third-party attributions) | Added |
| Microsoft sample LICENSE | Present at src/PowerApps/Scripts/LICENSE |
| CODE_OF_CONDUCT contact | btstevens1984az@gmail.com |

## Credential Scan

Scripts may contain **placeholder** credential patterns for demonstration (e.g., `Get-Credential`, `password = ""`). No production API keys or live passwords were found in committed content. Users must supply their own credentials at runtime.

**Action required by users:** Replace all `example.com`, `YOURDOMAIN`, and `admin@example.com` placeholders before production use.

## Remaining Third-Party Author Credits

Some files retain attribution to community authors (e.g., Marc Carter in LazyWinAdmin, Microsoft sample usernames like `jsmith@contoso.onmicrosoft.com`). These are standard open-source/sample attributions and do not indicate proprietary code theft.

## Maintenance

Re-run before major releases:

```bash
python3 scripts/sanitize-org-references.py
```
