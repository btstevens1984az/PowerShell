import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "@/lib/api";
import { Badge, Card } from "@/components/ui/primitives";
import { formatDate } from "@/lib/utils";
import { RefreshCw } from "lucide-react";

export function SystemsPage() {
  const [systems, setSystems] = useState<any[]>([]);
  const [busy, setBusy] = useState<number | null>(null);

  async function load() {
    setSystems(await api.systems());
  }

  useEffect(() => {
    load().catch(console.error);
  }, []);

  async function collectOne(id: number) {
    setBusy(id);
    try {
      await api.collectOne(id);
      await load();
    } finally {
      setBusy(null);
    }
  }

  return (
    <div className="space-y-6 animate-fade-up">
      <div>
        <h1 className="font-display text-3xl font-semibold text-white">Systems</h1>
        <p className="mt-1 text-sm text-ink-300">Inventoried hosts, agents, and cloud scopes under watch.</p>
      </div>
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {systems.map((s) => (
          <Card key={s.id} className="flex flex-col gap-4">
            <div className="flex items-start justify-between gap-3">
              <div>
                <div className="font-display text-xl text-white">{s.name}</div>
                <div className="font-mono text-xs text-ink-400">{s.hostname}</div>
              </div>
              <Badge className={s.is_online ? "sev-low" : "sev-critical"}>
                {s.is_online ? "online" : "offline"}
              </Badge>
            </div>
            <div className="grid grid-cols-2 gap-2 text-xs text-ink-300">
              <div>
                OS <span className="text-ink-100">{s.os_type}</span>
              </div>
              <div>
                Env <span className="text-ink-100">{s.environment}</span>
              </div>
              <div>
                Collector <span className="text-ink-100">{s.collector_type}</span>
              </div>
              <div>
                Last seen <span className="text-ink-100">{formatDate(s.last_seen_at)}</span>
              </div>
            </div>
            <div className="mt-auto flex items-center justify-between border-t border-white/10 pt-3">
              <div>
                <div className="text-[10px] uppercase tracking-wide text-ink-400">Drift score</div>
                <div className="font-mono text-lg text-ember-400">{s.drift_score}</div>
              </div>
              <div className="flex gap-2">
                <button className="btn-ghost" onClick={() => collectOne(s.id)} disabled={busy === s.id}>
                  <RefreshCw className={`h-4 w-4 ${busy === s.id ? "animate-spin" : ""}`} />
                </button>
                <Link className="btn-primary" to={`/app/drifts?system_id=${s.id}`}>
                  View drifts
                </Link>
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
