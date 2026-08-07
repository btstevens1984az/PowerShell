import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { Card } from "@/components/ui/primitives";

export function SettingsPage() {
  const [settings, setSettings] = useState<any[]>([]);
  const [msg, setMsg] = useState("");

  useEffect(() => {
    api.settings().then(setSettings).catch(console.error);
  }, []);

  async function save(key: string, value: unknown) {
    try {
      const updated = await api.updateSetting(key, value);
      setSettings((prev) => prev.map((s) => (s.key === key ? updated : s)));
      setMsg(`Saved ${key}`);
    } catch (e: any) {
      setMsg(e.message);
    }
  }

  const groups: Record<string, any[]> = {};
  for (const s of settings) {
    const g = s.key.split(".")[0];
    groups[g] = groups[g] || [];
    groups[g].push(s);
  }

  return (
    <div className="space-y-6 animate-fade-up">
      <div>
        <h1 className="font-display text-3xl font-semibold text-white">Options & settings</h1>
        <p className="mt-1 max-w-2xl text-sm text-ink-300">
          Tune collectors, remediation safety, notifications, Git sync, and security. Changes are audited.
        </p>
      </div>
      {msg ? <div className="rounded-xl bg-tide-600/15 px-4 py-3 text-sm text-tide-200">{msg}</div> : null}

      {Object.entries(groups).map(([group, rows]) => (
        <Card key={group}>
          <h2 className="mb-4 font-display text-xl capitalize text-white">{group.replace(/_/g, " ")}</h2>
          <div className="space-y-4">
            {rows.map((s) => (
              <SettingRow key={s.key} setting={s} onSave={save} />
            ))}
          </div>
        </Card>
      ))}

      <Card>
        <h2 className="mb-2 font-display text-xl text-white">Environment variables</h2>
        <p className="mb-4 text-sm text-ink-300">
          These are set outside the UI (Docker Compose / systemd / PowerShell). See docs for Windows and Linux.
        </p>
        <div className="overflow-x-auto">
          <table className="min-w-full text-left text-sm">
            <thead className="text-xs uppercase tracking-wide text-ink-400">
              <tr>
                <th className="py-2 pr-4">Variable</th>
                <th className="py-2 pr-4">Purpose</th>
                <th className="py-2">Example</th>
              </tr>
            </thead>
            <tbody className="text-ink-200">
              {[
                ["DATABASE_URL", "PostgreSQL or SQLite DSN", "postgresql+psycopg2://driftguard:…@db:5432/driftguard"],
                ["SECRET_KEY", "JWT signing secret", "openssl rand -hex 32"],
                ["SECRETS_FERNET_KEY", "Encrypt stored credentials", "Fernet.generate_key()"],
                ["SEED_DEMO_DATA", "Load demo fleet on boot", "true"],
                ["CORS_ORIGINS", "Allowed frontend origins", "http://localhost:5173"],
                ["REMEDIATION_DRY_RUN_DEFAULT", "Force dry-run first", "true"],
                ["DESIRED_STATE_GIT_URL", "Git source for baselines", "git@github.com:org/baselines.git"],
                ["WEBHOOK_URL", "Critical alert webhook", "https://hooks.slack.com/..."],
              ].map(([k, p, e]) => (
                <tr key={k} className="border-t border-white/5">
                  <td className="py-2 pr-4 font-mono text-tide-300">{k}</td>
                  <td className="py-2 pr-4">{p}</td>
                  <td className="py-2 font-mono text-xs text-ink-400">{e}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}

function SettingRow({
  setting,
  onSave,
}: {
  setting: any;
  onSave: (key: string, value: unknown) => void;
}) {
  const [value, setValue] = useState(setting.value);

  useEffect(() => setValue(setting.value), [setting.value]);

  const isBool = typeof setting.value === "boolean";
  const isNumber = typeof setting.value === "number";

  return (
    <div className="grid gap-3 rounded-xl bg-white/[0.03] p-3 md:grid-cols-[1fr_220px_auto] md:items-center">
      <div>
        <div className="font-mono text-sm text-tide-300">{setting.key}</div>
        <div className="text-xs text-ink-400">{setting.description}</div>
      </div>
      {isBool ? (
        <label className="flex items-center gap-2 text-sm text-ink-200">
          <input
            type="checkbox"
            checked={!!value}
            onChange={(e) => setValue(e.target.checked)}
            className="h-4 w-4 accent-tide-500"
          />
          {value ? "Enabled" : "Disabled"}
        </label>
      ) : (
        <input
          className="input"
          type={isNumber ? "number" : "text"}
          value={value ?? ""}
          onChange={(e) => setValue(isNumber ? Number(e.target.value) : e.target.value)}
        />
      )}
      <button className="btn-ghost" onClick={() => onSave(setting.key, value)}>
        Save
      </button>
    </div>
  );
}
