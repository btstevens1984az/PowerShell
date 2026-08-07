import { useEffect, useState } from "react";
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { Play, RefreshCw } from "lucide-react";
import { api } from "@/lib/api";
import { Badge, Card, Stat } from "@/components/ui/primitives";
import { formatDate, severityClass } from "@/lib/utils";
import { Link } from "react-router-dom";

export function DashboardPage() {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [collecting, setCollecting] = useState(false);
  const [error, setError] = useState("");

  async function load() {
    setLoading(true);
    setError("");
    try {
      setStats(await api.dashboard());
    } catch (e: any) {
      setError(e.message || "Failed to load dashboard");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function runCollect() {
    setCollecting(true);
    try {
      await api.collect();
      await load();
    } catch (e: any) {
      setError(e.message);
    } finally {
      setCollecting(false);
    }
  }

  if (loading && !stats) {
    return <div className="text-ink-300">Loading fleet posture…</div>;
  }

  const sevData = Object.entries(stats?.drift_by_severity || {}).map(([name, value]) => ({
    name,
    value,
  }));

  return (
    <div className="space-y-6 animate-fade-up">
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="font-display text-3xl font-semibold text-white">Fleet drift posture</h1>
          <p className="mt-1 text-sm text-ink-300">
            Live score across Linux, Windows, network, and cloud inventories.
          </p>
        </div>
        <button className="btn-primary" onClick={runCollect} disabled={collecting}>
          {collecting ? <RefreshCw className="h-4 w-4 animate-spin" /> : <Play className="h-4 w-4" />}
          {collecting ? "Collecting…" : "Run collectors"}
        </button>
      </div>

      {error ? <div className="rounded-xl bg-rose-500/10 px-4 py-3 text-sm text-rose-300">{error}</div> : null}

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <Stat label="Systems" value={stats?.total_systems ?? 0} hint={`${stats?.online_systems ?? 0} online`} />
        <Stat
          label="Open drifts"
          value={stats?.open_drifts ?? 0}
          hint={`${stats?.critical_drifts ?? 0} critical`}
          accent="bg-ember-500"
        />
        <Stat
          label="Avg drift score"
          value={stats?.avg_drift_score ?? 0}
          hint="0 clean · 100 severe"
          accent="bg-tide-400"
        />
        <Stat
          label="Pending approvals"
          value={stats?.pending_approvals ?? 0}
          hint="Remediation queue"
          accent="bg-amber-400"
        />
      </div>

      <div className="grid gap-4 xl:grid-cols-3">
        <Card className="xl:col-span-2">
          <div className="mb-4 flex items-center justify-between">
            <h2 className="font-display text-lg text-white">Change timeline</h2>
            <span className="text-xs text-ink-400">Last 14 days</span>
          </div>
          <div className="h-56">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={stats?.timeline || []}>
                <defs>
                  <linearGradient id="driftFill" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#14b8a6" stopOpacity={0.45} />
                    <stop offset="100%" stopColor="#14b8a6" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid stroke="rgba(255,255,255,0.06)" vertical={false} />
                <XAxis dataKey="date" tick={{ fill: "#9bb3bd", fontSize: 11 }} tickFormatter={(v) => v.slice(5)} />
                <YAxis tick={{ fill: "#9bb3bd", fontSize: 11 }} allowDecimals={false} />
                <Tooltip
                  contentStyle={{ background: "#243038", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 12 }}
                />
                <Area type="monotone" dataKey="count" stroke="#2dd4bf" fill="url(#driftFill)" strokeWidth={2} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </Card>

        <Card>
          <h2 className="mb-4 font-display text-lg text-white">Severity mix</h2>
          <div className="h-56">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={sevData}>
                <CartesianGrid stroke="rgba(255,255,255,0.06)" vertical={false} />
                <XAxis dataKey="name" tick={{ fill: "#9bb3bd", fontSize: 11 }} />
                <YAxis tick={{ fill: "#9bb3bd", fontSize: 11 }} allowDecimals={false} />
                <Tooltip
                  contentStyle={{ background: "#243038", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 12 }}
                />
                <Bar dataKey="value" fill="#f97316" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <Card>
          <div className="mb-4 flex items-center justify-between">
            <h2 className="font-display text-lg text-white">Most affected systems</h2>
            <Link to="/app/systems" className="text-sm text-tide-400 hover:text-tide-300">
              View all
            </Link>
          </div>
          <div className="space-y-3">
            {(stats?.top_affected || []).map((s: any) => (
              <div key={s.system_id} className="flex items-center justify-between rounded-xl bg-white/[0.03] px-3 py-2.5">
                <div>
                  <div className="font-medium text-ink-50">{s.name}</div>
                  <div className="text-xs text-ink-400">
                    {s.os_type} · {s.environment} · {s.open_drifts} open
                  </div>
                </div>
                <div className="text-right">
                  <div className="font-mono text-sm text-ember-400">{s.drift_score}</div>
                  <div className="text-[10px] uppercase tracking-wide text-ink-400">score</div>
                </div>
              </div>
            ))}
          </div>
        </Card>

        <Card>
          <div className="mb-4 flex items-center justify-between">
            <h2 className="font-display text-lg text-white">Recent findings</h2>
            <Link to="/app/drifts" className="text-sm text-tide-400 hover:text-tide-300">
              Open queue
            </Link>
          </div>
          <div className="space-y-3">
            {(stats?.recent_drifts || []).map((d: any) => (
              <Link
                key={d.id}
                to={`/app/drifts/${d.id}`}
                className="block rounded-xl bg-white/[0.03] px-3 py-2.5 transition hover:bg-white/[0.06]"
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <div className="truncate font-medium text-ink-50">{d.title}</div>
                    <div className="text-xs text-ink-400">{formatDate(d.detected_at)}</div>
                  </div>
                  <Badge className={severityClass(d.severity)}>{d.severity}</Badge>
                </div>
              </Link>
            ))}
          </div>
        </Card>
      </div>
    </div>
  );
}
