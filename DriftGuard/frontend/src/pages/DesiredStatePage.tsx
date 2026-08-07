import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { Badge, Card } from "@/components/ui/primitives";

export function DesiredStatePage() {
  const [states, setStates] = useState<any[]>([]);
  const [selected, setSelected] = useState<any>(null);

  useEffect(() => {
    api.desiredStates().then((rows) => {
      setStates(rows);
      setSelected(rows[0] || null);
    });
  }, []);

  return (
    <div className="space-y-6 animate-fade-up">
      <div>
        <h1 className="font-display text-3xl font-semibold text-white">Desired state</h1>
        <p className="mt-1 text-sm text-ink-300">
          Golden YAML/JSON baselines — inline today, Git-synced when enabled in Settings.
        </p>
      </div>
      <div className="grid gap-4 lg:grid-cols-[280px_1fr]">
        <Card className="space-y-2 p-3">
          {states.map((s) => (
            <button
              key={s.id}
              onClick={() => setSelected(s)}
              className={`w-full rounded-xl px-3 py-2.5 text-left transition ${
                selected?.id === s.id ? "bg-tide-600/20 ring-1 ring-tide-500/40" : "hover:bg-white/5"
              }`}
            >
              <div className="font-medium text-ink-50">{s.name}</div>
              <div className="text-xs text-ink-400">
                v{s.version} · {s.source}
              </div>
            </button>
          ))}
        </Card>
        {selected ? (
          <Card>
            <div className="mb-4 flex flex-wrap items-center gap-2">
              <h2 className="font-display text-2xl text-white">{selected.name}</h2>
              {selected.is_golden ? <Badge className="sev-low">golden</Badge> : null}
            </div>
            <p className="mb-4 text-sm text-ink-300">{selected.description}</p>
            <pre className="max-h-[560px] overflow-auto rounded-xl bg-ink-950/70 p-4 font-mono text-xs text-ink-100">
              {JSON.stringify(selected.content, null, 2)}
            </pre>
          </Card>
        ) : null}
      </div>
    </div>
  );
}
