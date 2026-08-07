import { useEffect, useState } from "react";
import { Link, useSearchParams } from "react-router-dom";
import { api } from "@/lib/api";
import { Badge, Card } from "@/components/ui/primitives";
import { formatDate, severityClass } from "@/lib/utils";

export function DriftsPage() {
  const [params] = useSearchParams();
  const [drifts, setDrifts] = useState<any[]>([]);
  const [severity, setSeverity] = useState("");
  const [status, setStatus] = useState("open");

  useEffect(() => {
    const q: Record<string, string> = {};
    if (severity) q.severity = severity;
    if (status) q.status = status;
    const sid = params.get("system_id");
    if (sid) q.system_id = sid;
    api.drifts(q).then(setDrifts).catch(console.error);
  }, [severity, status, params]);

  return (
    <div className="space-y-6 animate-fade-up">
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="font-display text-3xl font-semibold text-white">Drift findings</h1>
          <p className="mt-1 text-sm text-ink-300">Side-by-side diffs with severity and suggested fixes.</p>
        </div>
        <div className="flex gap-2">
          <select className="input w-auto" value={status} onChange={(e) => setStatus(e.target.value)}>
            <option value="">All statuses</option>
            <option value="open">Open</option>
            <option value="acknowledged">Acknowledged</option>
            <option value="remediating">Remediating</option>
            <option value="resolved">Resolved</option>
            <option value="suppressed">Suppressed</option>
          </select>
          <select className="input w-auto" value={severity} onChange={(e) => setSeverity(e.target.value)}>
            <option value="">All severities</option>
            <option value="critical">Critical</option>
            <option value="high">High</option>
            <option value="medium">Medium</option>
            <option value="low">Low</option>
          </select>
        </div>
      </div>

      <Card className="overflow-hidden p-0">
        <div className="overflow-x-auto">
          <table className="min-w-full text-left text-sm">
            <thead className="border-b border-white/10 bg-white/[0.03] text-xs uppercase tracking-wide text-ink-400">
              <tr>
                <th className="px-4 py-3">Finding</th>
                <th className="px-4 py-3">Kind</th>
                <th className="px-4 py-3">Severity</th>
                <th className="px-4 py-3">Status</th>
                <th className="px-4 py-3">Detected</th>
              </tr>
            </thead>
            <tbody>
              {drifts.map((d) => (
                <tr key={d.id} className="border-b border-white/5 hover:bg-white/[0.03]">
                  <td className="px-4 py-3">
                    <Link to={`/app/drifts/${d.id}`} className="font-medium text-tide-300 hover:text-tide-200">
                      {d.title}
                    </Link>
                    <div className="font-mono text-xs text-ink-400">{d.resource_key}</div>
                  </td>
                  <td className="px-4 py-3 text-ink-200">{d.resource_kind}</td>
                  <td className="px-4 py-3">
                    <Badge className={severityClass(d.severity)}>{d.severity}</Badge>
                  </td>
                  <td className="px-4 py-3 text-ink-200">{d.status}</td>
                  <td className="px-4 py-3 text-ink-300">{formatDate(d.detected_at)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
