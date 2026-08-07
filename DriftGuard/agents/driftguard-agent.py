#!/usr/bin/env python3
"""Minimal DriftGuard agent — push local inventory to the API (stub)."""

from __future__ import annotations

import argparse
import json
import platform
from datetime import datetime, timezone
from pathlib import Path

try:
    import httpx
except ImportError:
    httpx = None  # type: ignore


def collect_local(watch_files: list[str]) -> dict:
    files = {}
    for path in watch_files:
        p = Path(path)
        if p.exists():
            files[path] = {"exists": True, "content": p.read_text(errors="replace")[:4000]}
        else:
            files[path] = {"exists": False}
    return {
        "collected_at": datetime.now(timezone.utc).isoformat(),
        "hostname": platform.node(),
        "os": platform.platform(),
        "files": files,
        "packages": [],
        "services": {},
        "registry": {},
        "cloud": {},
        "mode": "agent_cli",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="DriftGuard lightweight agent")
    parser.add_argument("--api", default="http://127.0.0.1:8000")
    parser.add_argument("--token", required=False, help="Bearer token")
    parser.add_argument("--system-id", type=int, required=False)
    parser.add_argument("--watch", action="append", default=["/etc/hostname"])
    parser.add_argument("--out", default="", help="Write payload JSON to file instead of posting")
    args = parser.parse_args()

    payload = collect_local(args.watch)
    if args.out:
        Path(args.out).write_text(json.dumps(payload, indent=2))
        print(f"Wrote {args.out}")
        return

    if not httpx or not args.token or not args.system_id:
        print(json.dumps(payload, indent=2))
        print("\n# Tip: pass --token and --system-id to POST, or --out file.json")
        return

    # MVP: print guidance — full agent registration endpoint can be extended
    print("Agent payload collected. Wire to /api/v1/systems/{id} connection_config.last_agent_payload")
    print(json.dumps(payload, indent=2)[:500], "...")


if __name__ == "__main__":
    main()
