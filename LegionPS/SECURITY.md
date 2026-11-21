# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 0.1.x   | Yes       |

## Reporting a vulnerability

Please open a **private** security advisory on the GitHub repository, or file an issue marked `security` without including exploit payloads or credentials.

Do **not** attach real host inventories, credentials, or personal machine metadata.

## Security model (built-in)

LegionPS is designed **secure-by-default** for AI-assisted and operator-driven remoting:

1. **Playbook allowlist** — only scripts under `src/LegionPS/Playbooks/` may run. Arbitrary paths are refused.
2. **Approval gates** — `ApprovalMode = Required` blocks execution until `Approve-LegionJob`.
3. **DryRun / Simulation** — plan and mock remoting offline before touching production.
4. **Signed job packs** — SHA256 of playbook content is stored on every job; optional HMAC uses an **ephemeral** key under the process temp directory (`…/LegionPS/keys`, via `[IO.Path]::GetTempPath()`) and is never committed.
5. **Redacted exports** — `Export-LegionSummary` partially masks hostnames and strips obvious secret patterns.
6. **No telemetry** — the module does not phone home.

## Operational guidance

- Prefer fictional lab hosts (`web-01`, `db-02`, `app-03`) in docs and demos.
- Review LLM-produced `New-LegionPlan` objects before `Invoke-LegionJob`.
- Rotate or delete the local `LegionPS/keys` folder under the process temp directory if a workstation is shared.
- Treat playbook changes as code: review diffs; the content hash will change.
