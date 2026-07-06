# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| PowerShell 7.x | Yes |
| PowerShell 5.1 | Yes |
| PowerShell 5.0 and earlier | No |

## Reporting a Vulnerability

If you discover a security issue in this repository, please report it responsibly:

**Email:** btstevens1984az@gmail.com

Please include:
- A description of the vulnerability
- Steps to reproduce
- Affected file paths (if known)
- Suggested remediation (optional)

Do not open public GitHub issues for undisclosed security vulnerabilities.

## Security Guidelines for Users

This repository contains IT administration scripts. Before running any script:

1. **Review the code** — Never execute scripts you have not read and understood.
2. **Test in non-production** — Validate behavior in a lab environment first.
3. **Replace placeholders** — Update `example.com`, `YOURDOMAIN`, `admin@example.com`, and server names for your environment.
4. **Protect credentials** — Use SecretManagement, Azure Key Vault, or environment variables instead of hardcoded passwords.
5. **Limit privileges** — Run scripts with the minimum permissions required.

## Repository Security Practices

- Organization-specific names, emails, and internal server references are sanitized to generic placeholders.
- No live API keys, passwords, or production credentials should be committed to this repository.
- Third-party sample code (Microsoft CDS/PowerApps samples) is included with original license terms.

## Pre-Publication Scan

A sanitization pass is maintained via `scripts/sanitize-org-references.py`. Re-run before publishing changes if scripts are imported from production environments.
