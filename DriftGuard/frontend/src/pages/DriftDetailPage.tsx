import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { api } from "@/lib/api";
import { Badge, Card } from "@/components/ui/primitives";
import { formatDate, severityClass } from "@/lib/utils";

function DiffPane({ title, value }: { title: string; value: unknown }) {
  const text =
    typeof value === "string" ? value : value == null ? "—" : JSON.stringify(value, null, 2);
  return (
    <div className="rounded-xl border border-white/10 bg-ink-950/70">
      <div className="border-b border-white/10 px-3 py-2 text-xs uppercase tracking-wide text-ink-400">
        {title}
      </div>
      <pre className="max-h-[420px] overflow-auto p-3 font-mono text-xs leading-relaxed text-ink-100 whitespace-pre-wrap">
        {text}
      </pre>
    </div>
  );
}

export function DriftDetailPage() {
  const { id } = useParams();
  const [drift, setDrift] = useState<any>(null);
  const [msg, setMsg] = useState("");

  useEffect(() => {
    if (!id) return;
    api.drift(Number(id)).then(setDrift).catch(console.error);
  }, [id]);

  if (!drift) return <div className="text-ink-300">Loading finding…</div>;

  async function requestFix() {
    try {
      const rem = await api.createRemediation(drift.id, true);
      setMsg(`Remediation #${rem.id} created (pending approval, dry-run).`);
    } catch (e: any) {
      setMsg(e.message);
    }
  }

  return (
    <div className="space-y-6 animate-fade-up">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <Link to="/app/drifts" className="text-sm text-tide-400 hover:text-tide-300">
            ← Drift queue
          </Link>
          <h1 className="mt-2 font-display text-3xl font-semibold text-white">{drift.title}</h1>
          <div className="mt-2 flex flex-wrap gap-2">
            <Badge className={severityClass(drift.severity)}>{drift.severity}</Badge>
            <Badge className="sev-info">{drift.status}</Badge>
            <Badge className="sev-low">{drift.resource_kind}</Badge>
          </div>
        </div>
        <button className="btn-primary" onClick={requestFix}>
          Request remediation
        </button>
      </div>

      {msg ? <div className="rounded-xl bg-tide-600/15 px-4 py-3 text-sm text-tide-200">{msg}</div> : null}

      <div className="grid gap-4 lg:grid-cols-3">
        <Card className="lg:col-span-1 space-y-3 text-sm">
          <div>
            <div className="label">Resource</div>
            <div className="font-mono text-ink-100">{drift.resource_key}</div>
          </div>
          <div>
            <div className="label">Detected</div>
            <div>{formatDate(drift.detected_at)}</div>
          </div>
          <div>
            <div className="label">Description</div>
            <div className="text-ink-200">{drift.description || "—"}</div>
          </div>
          <div>
            <div className="label">Suggested fix</div>
            <div className="rounded-xl bg-ember-500/10 p-3 text-ember-400">{drift.suggested_fix}</div>
          </div>
          {drift.diff_summary ? (
            <div>
              <div className="label">Diff summary</div>
              <pre className="overflow-auto rounded-xl bg-ink-950/70 p-3 font-mono text-[11px] text-ink-200">
                {drift.diff_summary}
              </pre>
            </div>
          ) : null}
        </Card>
        <div className="diff-grid lg:col-span-2">
          <DiffPane title="Desired / expected" value={drift.expected} />
          <DiffPane title="Actual / observed" value={drift.actual} />
        </div>
      </div>
    </div>
  );
}
