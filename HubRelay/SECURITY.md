# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 0.1.x   | Yes       |

## Threat model (short)

HubRelay is a **localhost control-plane** for LLM tool calls. It is designed to:

- Bind **127.0.0.1 / localhost only** by default
- Require a **shared bearer token** (`HUBRELAY_TOKEN` or `-Token`)
- Execute **allowlisted playbooks only**
- Apply a simple **in-memory rate limit**
- **Redact** secrets from job summaries before returning them to LLM clients
- Support **DryRun** and **Simulation** modes for offline demos

HubRelay does **not** emit telemetry and does **not** phone home.

## Reporting a vulnerability

Please open a GitHub Security Advisory on this repository, or file a private security report via the repository’s security tab. Do not include real tokens, host inventories, or personal data in public issues.

## Operational guidance

1. **Never commit tokens.** Keep `HUBRELAY_TOKEN` in your environment or a secret store.
2. Keep the default **loopback bind**. Do not expose HubRelay on public interfaces.
3. Prefer **DryRun** when validating new playbook parameters.
4. Treat HTTP summaries as untrusted LLM context: redaction is best-effort, not a guarantee against every secret shape.
5. Extend the allowlist only after code review of the playbook script.
6. Use fictional host names in demos (e.g. `relay-alpha`). Do not paste real inventory into examples or issues.

## Secrets handling

- Tokens are hashed (SHA-256) in memory for comparison; the cleartext token is not stored in the module state after startup.
- Result summaries run through `Redact-Summary` before `/v1/jobs/{id}/summary`.
- Generated demo tokens are session-scoped and not written to disk by HubRelay.
