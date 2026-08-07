import { NavLink, useNavigate } from "react-router-dom";
import {
  Activity,
  ClipboardCheck,
  FileDiff,
  Gauge,
  LogOut,
  Server,
  Settings,
  Shield,
  Sparkles,
} from "lucide-react";
import { cn } from "@/lib/utils";

const links = [
  { to: "/app", label: "Dashboard", icon: Gauge, end: true },
  { to: "/app/systems", label: "Systems", icon: Server },
  { to: "/app/drifts", label: "Drift", icon: FileDiff },
  { to: "/app/remediations", label: "Remediation", icon: ClipboardCheck },
  { to: "/app/desired-state", label: "Desired State", icon: Sparkles },
  { to: "/app/audit", label: "Audit", icon: Shield },
  { to: "/app/settings", label: "Settings", icon: Settings },
];

export function AppShell({ children }: { children: React.ReactNode }) {
  const navigate = useNavigate();
  const user = JSON.parse(localStorage.getItem("dg_user") || "{}");

  function logout() {
    localStorage.removeItem("dg_token");
    localStorage.removeItem("dg_user");
    navigate("/login");
  }

  return (
    <div className="min-h-screen lg:grid lg:grid-cols-[240px_1fr]">
      <aside className="border-b border-white/10 bg-ink-950/80 lg:border-b-0 lg:border-r">
        <div className="flex items-center gap-3 px-5 py-5">
          <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-tide-600/20 ring-1 ring-tide-500/40">
            <Activity className="h-5 w-5 text-tide-400" />
          </div>
          <div>
            <div className="font-display text-lg font-semibold tracking-tight text-white">DriftGuard</div>
            <div className="text-[11px] uppercase tracking-[0.18em] text-ink-400">Config integrity</div>
          </div>
        </div>
        <nav className="flex gap-1 overflow-x-auto px-3 pb-3 lg:flex-col lg:overflow-visible">
          {links.map((l) => (
            <NavLink
              key={l.to}
              to={l.to}
              end={l.end}
              className={({ isActive }) =>
                cn(
                  "flex items-center gap-2.5 rounded-xl px-3 py-2 text-sm text-ink-300 transition hover:bg-white/5 hover:text-white",
                  isActive && "bg-tide-600/15 text-tide-300 ring-1 ring-tide-500/30"
                )
              }
            >
              <l.icon className="h-4 w-4 shrink-0" />
              {l.label}
            </NavLink>
          ))}
        </nav>
        <div className="mt-auto hidden border-t border-white/10 p-4 lg:block">
          <div className="mb-3 text-xs text-ink-400">
            Signed in as
            <div className="mt-0.5 truncate font-medium text-ink-100">{user.full_name || user.email}</div>
            <div className="uppercase tracking-wide text-tide-400/90">{user.role}</div>
          </div>
          <button className="btn-ghost w-full" onClick={logout}>
            <LogOut className="h-4 w-4" /> Sign out
          </button>
        </div>
      </aside>
      <main className="min-w-0 px-4 py-6 sm:px-6 lg:px-8">{children}</main>
    </div>
  );
}
