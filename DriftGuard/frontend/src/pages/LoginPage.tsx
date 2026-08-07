import { useState } from "react";
import { Link, Navigate, useNavigate } from "react-router-dom";
import { Activity } from "lucide-react";
import { api } from "@/lib/api";

export function LoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("admin@driftguard.example");
  const [password, setPassword] = useState("DriftGuard!admin");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  if (localStorage.getItem("dg_token")) {
    return <Navigate to="/app" replace />;
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError("");
    try {
      const tok = await api.login(email, password);
      localStorage.setItem("dg_token", tok.access_token);
      localStorage.setItem(
        "dg_user",
        JSON.stringify({ email: tok.email, full_name: tok.full_name, role: tok.role })
      );
      navigate("/app");
    } catch (err: any) {
      setError(err.message || "Login failed");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="relative flex min-h-screen items-center justify-center px-4">
      <div className="pointer-events-none absolute inset-0 bg-hero-glow" />
      <div className="panel relative w-full max-w-md p-8 animate-fade-up">
        <div className="mb-6 flex items-center gap-3">
          <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-tide-600/20 ring-1 ring-tide-500/40">
            <Activity className="h-5 w-5 text-tide-400" />
          </div>
          <div>
            <div className="font-display text-2xl font-semibold text-white">DriftGuard</div>
            <div className="text-sm text-ink-300">Sign in to the operations console</div>
          </div>
        </div>
        <form className="space-y-4" onSubmit={onSubmit}>
          <div>
            <label className="label">Email</label>
            <input className="input" value={email} onChange={(e) => setEmail(e.target.value)} />
          </div>
          <div>
            <label className="label">Password</label>
            <input
              className="input"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          {error ? <div className="rounded-xl bg-rose-500/10 px-3 py-2 text-sm text-rose-300">{error}</div> : null}
          <button className="btn-primary w-full" disabled={loading}>
            {loading ? "Signing in…" : "Sign in"}
          </button>
        </form>
        <div className="mt-6 rounded-xl border border-white/10 bg-ink-950/50 p-3 text-xs text-ink-300">
          <div className="mb-1 font-medium text-ink-100">Demo accounts</div>
          <div>admin@driftguard.example / DriftGuard!admin</div>
          <div>ops@driftguard.example / DriftGuard!ops</div>
          <div>viewer@driftguard.example / DriftGuard!view</div>
        </div>
        <div className="mt-4 text-center text-sm text-ink-400">
          <Link to="/" className="text-tide-400 hover:text-tide-300">
            ← Back to product site
          </Link>
        </div>
      </div>
    </div>
  );
}
