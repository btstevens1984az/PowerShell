import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { Badge, Card } from "@/components/ui/primitives";
import { formatDate } from "@/lib/utils";

export function RemediationsPage() {
  const [items, setItems] = useState<any[]>([]);
  const [msg, setMsg] = useState("");

  async function load() {
    setItems(await api.remediations());
  }

  useEffect(() => {
    load().catch(console.error);
  }, []);

  async function decide(id: number, approve: boolean) {
    try {
      await api.decideRemediation(id, approve, approve ? "Approved via UI" : "Rejected via UI");
      setMsg(approve ? `Approved #${id}` : `Rejected #${id}`);
      await load();
    } catch (e: any) {
      setMsg(e.message);
    }
  }

  async function apply(id: number) {
    try {
      await api.applyRemediation(id);
      setMsg(`Applied remediation #${id}`);
      await load();
    } catch (e: any) {
      setMsg(e.message);
    }
  }

  return (
    <div className="space-y-6 animate-fade-up">
      <div>
        <h1 className="font-display text-3xl font-semibold text-white">Remediation workflow</h1>
        <p className="mt-1 text-sm text-ink-300">
          Dry-run first, approve, then apply. Every action is audited.
        </p>
      </div>
      {msg ? <div className="rounded-xl bg-tide-600/15 px-4 py-3 text-sm text-tide-200">{msg}</div> : null}
      <div className="space-y-4">
        {items.map((r) => (
          <Card key={r.id}>
            <div className="flex flex-wrap items-start justify-between gap-4">
              <div>
                <div className="font-display text-lg text-white">
                  Remediation #{r.id} · drift {r.drift_id}
                </div>
                <div className="mt-1 flex flex-wrap gap-2">
                  <Badge className="sev-info">{r.status}</Badge>
                  <Badge className={r.dry_run ? "sev-medium" : "sev-high"}>
                    {r.dry_run ? "dry-run" : "live apply"}
                  </Badge>
                </div>
                <div className="mt-2 text-xs text-ink-400">Created {formatDate(r.created_at)}</div>
                {r.notes ? <div className="mt-2 text-sm text-ink-300">{r.notes}</div> : null}
              </div>
              <div className="flex flex-wrap gap-2">
                {r.status === "pending_approval" ? (
                  <>
                    <button className="btn-primary" onClick={() => decide(r.id, true)}>
                      Approve
                    </button>
                    <button className="btn-ghost" onClick={() => decide(r.id, false)}>
                      Reject
                    </button>
                  </>
                ) : null}
                {r.status === "dry_run" || r.status === "approved" ? (
                  <button className="btn-danger" onClick={() => apply(r.id)}>
                    Apply live
                  </button>
                ) : null}
              </div>
            </div>
            <div className="mt-4 grid gap-3 lg:grid-cols-2">
              <pre className="overflow-auto rounded-xl bg-ink-950/60 p-3 font-mono text-[11px] text-ink-200">
                {JSON.stringify(r.plan, null, 2)}
              </pre>
              <pre className="overflow-auto rounded-xl bg-ink-950/60 p-3 font-mono text-[11px] text-ink-200">
                {JSON.stringify(r.result || { waiting: true }, null, 2)}
              </pre>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
