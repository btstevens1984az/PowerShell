import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { Card } from "@/components/ui/primitives";
import { formatDate } from "@/lib/utils";

export function AuditPage() {
  const [events, setEvents] = useState<any[]>([]);
  const [error, setError] = useState("");

  useEffect(() => {
    api
      .audit()
      .then(setEvents)
      .catch((e) => setError(e.message || "Auditor role required"));
  }, []);

  return (
    <div className="space-y-6 animate-fade-up">
      <div>
        <h1 className="font-display text-3xl font-semibold text-white">Audit trail</h1>
        <p className="mt-1 text-sm text-ink-300">Immutable history of logins, collects, approvals, and applies.</p>
      </div>
      {error ? <div className="rounded-xl bg-rose-500/10 px-4 py-3 text-sm text-rose-300">{error}</div> : null}
      <Card className="overflow-hidden p-0">
        <table className="min-w-full text-left text-sm">
          <thead className="border-b border-white/10 bg-white/[0.03] text-xs uppercase tracking-wide text-ink-400">
            <tr>
              <th className="px-4 py-3">When</th>
              <th className="px-4 py-3">Action</th>
              <th className="px-4 py-3">Resource</th>
              <th className="px-4 py-3">Actor</th>
            </tr>
          </thead>
          <tbody>
            {events.map((e) => (
              <tr key={e.id} className="border-b border-white/5">
                <td className="px-4 py-3 text-ink-300">{formatDate(e.created_at)}</td>
                <td className="px-4 py-3 font-medium text-ink-50">{e.action}</td>
                <td className="px-4 py-3 font-mono text-xs text-ink-300">
                  {e.resource_type}
                  {e.resource_id ? `#${e.resource_id}` : ""}
                </td>
                <td className="px-4 py-3 text-ink-300">{e.actor_id ?? "system"}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Card>
    </div>
  );
}
