# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 0.1.x   | Yes       |

## Design principles

- **Catalog allowlist only.** Stages must resolve to functions shipped under `src/SynapseFlow/Catalog/`. Arbitrary script injection via stage names is rejected.
- **Human review gate.** `Confirm-SynapsePlan` must mark a plan Reviewed before `Start-SynapseFlow`. Destructive catalog stages (for example `Restart-Spooler`) additionally require `-ApproveDestructive`.
- **Simulation mode.** Prefer `-Simulation` on `Start-SynapseFlow` during development and LLM-driven planning so catalog stages do not claim live side effects.
- **Redaction.** `Export-SynapseReport` runs artifacts through `Redact-Artifact` to strip emails, home paths, and common secret key patterns before write-out.
- **No telemetry.** SynapseFlow does not phone home, collect usage metrics, or upload plans.

## Reporting a vulnerability

Please open a **private** security advisory on the GitHub repository:

https://github.com/btstevens1984az/SynapseFlow/security/advisories/new

Do not file public issues for undisclosed vulnerabilities. Include reproduction steps using **fictional** hostnames only (for example `web-01`, `db-02`).

## Safe defaults

- Targets in examples and tests are fictional (`web-01`, `db-02`).
- Do not pass real inventory, usernames, emails, or machine metadata into plans or reports.
- Keep MaxParallelStages modest in shared environments.
