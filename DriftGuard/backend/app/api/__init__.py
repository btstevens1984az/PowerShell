"""API routers."""

from app.api import auth, systems, desired_states, drifts, remediations, dashboard, settings, audit, collect

__all__ = [
    "auth",
    "systems",
    "desired_states",
    "drifts",
    "remediations",
    "dashboard",
    "settings",
    "audit",
    "collect",
]
