# GhostSeats — Microsoft Graph permissions

## Read-only discovery (recommended first)

| Permission | Type | Why |
|---|---|---|
| User.Read.All | Application or Delegated | Read users, assigned licenses |
| Directory.Read.All | Application or Delegated | Directory objects |
| Organization.Read.All | Application or Delegated | Subscribed SKUs |
| AuditLog.Read.All | Application or Delegated | `signInActivity` (requires Entra ID P1/P2 for full fidelity) |

## Reclaim (write)

| Permission | Type | Why |
|---|---|---|
| User.ReadWrite.All | Application or Delegated | `Set-MgUserLicense` |

Prefer a dedicated app registration + certificate for automation. Grant admin consent. Use an approval CSV before enabling write scopes in production.

## Demo mode

`Connect-GhostSeats -Demo` uses zero Graph permissions and never leaves the machine.
