import { Link } from "react-router-dom";
import { Activity, CheckCircle2, GitBranch, Lock, Play, Shield, Waves } from "lucide-react";

const videos = [
  {
    id: "01-dashboard",
    title: "Fleet drift posture",
    blurb: "Drift score, severity mix, and 14-day change timeline at a glance.",
    duration: "0:42",
    src: "/videos/01-dashboard.mp4",
  },
  {
    id: "02-collectors",
    title: "Run collectors",
    blurb: "SSH, WinRM, agent, local, and cloud collectors in one pass.",
    duration: "0:38",
    src: "/videos/02-collectors.mp4",
  },
  {
    id: "03-diff",
    title: "Side-by-side diff",
    blurb: "Expected vs actual for files, packages, services, and registry.",
    duration: "0:51",
    src: "/videos/03-diff.mp4",
  },
  {
    id: "04-severity",
    title: "Severity ranking",
    blurb: "Critical cloud exposure through info-level noise — prioritized.",
    duration: "0:29",
    src: "/videos/04-severity.mp4",
  },
  {
    id: "05-approval",
    title: "Approval workflow",
    blurb: "Operators request fixes; admins approve with an audit trail.",
    duration: "0:47",
    src: "/videos/05-approval.mp4",
  },
  {
    id: "06-dryrun",
    title: "Safe dry-run apply",
    blurb: "Simulate remediation steps before touching production.",
    duration: "0:36",
    src: "/videos/06-dryrun.mp4",
  },
  {
    id: "07-desired",
    title: "Desired-state baselines",
    blurb: "Golden JSON/YAML configs, ready for Git sync.",
    duration: "0:33",
    src: "/videos/07-desired.mp4",
  },
  {
    id: "08-settings",
    title: "Options & settings",
    blurb: "Collectors, notifications, Git, MFA gates, and session policy.",
    duration: "0:40",
    src: "/videos/08-settings.mp4",
  },
  {
    id: "09-rbac",
    title: "RBAC & audit",
    blurb: "Admin, operator, viewer, auditor — every action logged.",
    duration: "0:31",
    src: "/videos/09-rbac.mp4",
  },
  {
    id: "10-install",
    title: "Install on Win & Linux",
    blurb: "Docker Compose or local Python/Node — same demo fleet.",
    duration: "0:55",
    src: "/videos/10-install.mp4",
  },
];

const pillars = [
  {
    icon: Waves,
    title: "Continuous detection",
    body: "Snapshot files, systemd/Windows services, packages, registry stubs, and cloud resources — then score drift against golden state.",
  },
  {
    icon: GitBranch,
    title: "Git-ready baselines",
    body: "Define desired state as YAML/JSON today; flip on Git sync when your config repo is ready.",
  },
  {
    icon: Shield,
    title: "Safe remediation",
    body: "Dry-run first, human approval second, live apply third — with encrypted secrets and a full audit log.",
  },
];

export function LandingPage() {
  return (
    <div className="relative overflow-hidden">
      <div className="pointer-events-none absolute inset-0 bg-hero-glow" />
      <div className="pointer-events-none absolute inset-0 bg-grid-fade bg-[size:48px_48px] opacity-40" />

      <header className="relative z-10 mx-auto flex max-w-6xl items-center justify-between px-4 py-5 sm:px-6">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-tide-600/20 ring-1 ring-tide-500/40">
            <Activity className="h-5 w-5 text-tide-400" />
          </div>
          <div className="font-display text-2xl font-semibold tracking-tight text-white">DriftGuard</div>
        </div>
        <div className="flex items-center gap-2 sm:gap-3">
          <a href="#demos" className="btn-ghost hidden sm:inline-flex">
            Watch demos
          </a>
          <Link to="/login" className="btn-primary">
            Open console
          </Link>
        </div>
      </header>

      <section className="relative z-10 mx-auto grid max-w-6xl gap-10 px-4 pb-16 pt-8 sm:px-6 lg:grid-cols-[1.05fr_0.95fr] lg:items-center lg:pt-14">
        <div className="animate-fade-up">
          <div className="mb-4 inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs uppercase tracking-[0.2em] text-tide-300">
            Configuration integrity
          </div>
          <h1 className="font-display text-5xl font-semibold leading-[1.05] text-white sm:text-6xl">
            DriftGuard
          </h1>
          <p className="mt-5 max-w-xl text-lg text-ink-200">
            Detect, visualize, and safely remediate configuration drift across Linux, Windows, network
            devices, and cloud — with an enterprise console your ops team will actually enjoy using.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Link to="/login" className="btn-primary">
              Launch demo console
            </Link>
            <a href="#install" className="btn-ghost">
              Install guides
            </a>
          </div>
          <div className="mt-8 flex flex-wrap gap-4 text-sm text-ink-300">
            <span className="inline-flex items-center gap-1.5">
              <CheckCircle2 className="h-4 w-4 text-tide-400" /> FastAPI + PostgreSQL
            </span>
            <span className="inline-flex items-center gap-1.5">
              <Lock className="h-4 w-4 text-tide-400" /> RBAC & encrypted secrets
            </span>
            <span className="inline-flex items-center gap-1.5">
              <Shield className="h-4 w-4 text-tide-400" /> Dry-run remediation
            </span>
          </div>
        </div>

        <div className="relative animate-fade-up-delay">
          <div className="panel overflow-hidden p-0">
            <div className="flex items-center justify-between border-b border-white/10 px-4 py-3">
              <div className="text-xs uppercase tracking-wider text-ink-400">Live posture preview</div>
              <div className="h-2 w-2 animate-pulse-soft rounded-full bg-tide-400" />
            </div>
            <div className="relative aspect-[16/10] bg-ink-950">
              <div className="absolute inset-0 bg-[radial-gradient(circle_at_30%_20%,rgba(20,184,166,0.2),transparent_45%),radial-gradient(circle_at_80%_60%,rgba(249,115,22,0.15),transparent_40%)]" />
              <svg className="absolute inset-0 h-full w-full" viewBox="0 0 640 400" fill="none">
                <path
                  className="animate-drift-line"
                  d="M40 260 C 140 120, 240 320, 340 200 S 540 80, 600 180"
                  stroke="#14b8a6"
                  strokeWidth="3"
                  opacity="0.85"
                />
                <path
                  className="animate-drift-line"
                  style={{ animationDelay: "1.2s" }}
                  d="M40 300 C 160 220, 260 340, 380 240 S 520 160, 600 220"
                  stroke="#f97316"
                  strokeWidth="2"
                  opacity="0.7"
                />
                <rect x="48" y="48" width="160" height="72" rx="16" fill="rgba(255,255,255,0.04)" stroke="rgba(255,255,255,0.1)" />
                <text x="68" y="78" fill="#9bb3bd" fontSize="12" fontFamily="DM Sans">Open drifts</text>
                <text x="68" y="104" fill="#fff" fontSize="28" fontFamily="Fraunces">18</text>
                <rect x="232" y="48" width="160" height="72" rx="16" fill="rgba(255,255,255,0.04)" stroke="rgba(255,255,255,0.1)" />
                <text x="252" y="78" fill="#9bb3bd" fontSize="12" fontFamily="DM Sans">Avg score</text>
                <text x="252" y="104" fill="#fb923c" fontSize="28" fontFamily="Fraunces">42</text>
                <rect x="416" y="48" width="176" height="72" rx="16" fill="rgba(255,255,255,0.04)" stroke="rgba(255,255,255,0.1)" />
                <text x="436" y="78" fill="#9bb3bd" fontSize="12" fontFamily="DM Sans">Pending approvals</text>
                <text x="436" y="104" fill="#2dd4bf" fontSize="28" fontFamily="Fraunces">3</text>
              </svg>
            </div>
          </div>
        </div>
      </section>

      <section className="relative z-10 mx-auto max-w-6xl px-4 py-12 sm:px-6">
        <div className="grid gap-4 md:grid-cols-3">
          {pillars.map((p) => (
            <div key={p.title} className="panel p-5">
              <p.icon className="mb-3 h-5 w-5 text-tide-400" />
              <h2 className="font-display text-xl text-white">{p.title}</h2>
              <p className="mt-2 text-sm leading-relaxed text-ink-300">{p.body}</p>
            </div>
          ))}
        </div>
      </section>

      <section id="demos" className="relative z-10 mx-auto max-w-6xl px-4 py-12 sm:px-6">
        <div className="mb-8 max-w-2xl">
          <h2 className="font-display text-3xl font-semibold text-white">See DriftGuard in motion</h2>
          <p className="mt-2 text-ink-300">
            Ten short walkthroughs — from fleet posture to dry-run remediation and Windows/Linux install.
          </p>
        </div>
        <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {videos.map((v, idx) => (
            <article key={v.id} className="panel overflow-hidden">
              <div className="relative aspect-video bg-ink-950">
                <video
                  className="h-full w-full object-cover"
                  controls
                  preload="metadata"
                  poster=""
                  src={v.src}
                >
                  Your browser does not support video.
                </video>
                <div className="pointer-events-none absolute left-3 top-3 inline-flex items-center gap-1 rounded-full bg-ink-950/70 px-2 py-1 text-[11px] text-ink-200 ring-1 ring-white/10">
                  <Play className="h-3 w-3 text-tide-400" /> {v.duration}
                </div>
                <div className="pointer-events-none absolute bottom-3 right-3 rounded-full bg-ink-950/70 px-2 py-1 font-mono text-[11px] text-ink-300 ring-1 ring-white/10">
                  {String(idx + 1).padStart(2, "0")}
                </div>
              </div>
              <div className="p-4">
                <h3 className="font-display text-lg text-white">{v.title}</h3>
                <p className="mt-1 text-sm text-ink-300">{v.blurb}</p>
              </div>
            </article>
          ))}
        </div>
      </section>

      <section id="install" className="relative z-10 mx-auto max-w-6xl px-4 py-12 sm:px-6">
        <div className="panel p-6 sm:p-8">
          <h2 className="font-display text-3xl font-semibold text-white">Install on Linux & Windows</h2>
          <p className="mt-2 max-w-3xl text-ink-300">
            Full guides live in <code className="text-tide-300">docs/INSTALL_LINUX.md</code> and{" "}
            <code className="text-tide-300">docs/INSTALL_WINDOWS.md</code>. Quick path with Docker Compose:
          </p>
          <div className="mt-6 grid gap-4 lg:grid-cols-2">
            <pre className="overflow-auto rounded-2xl bg-ink-950/80 p-4 font-mono text-xs leading-relaxed text-ink-100">{`# Linux / macOS
git clone https://github.com/btstevens1984az/DriftGuard.git
cd DriftGuard
docker compose up --build
# UI http://localhost:5173  API http://localhost:8000/docs`}</pre>
            <pre className="overflow-auto rounded-2xl bg-ink-950/80 p-4 font-mono text-xs leading-relaxed text-ink-100">{`# Windows (PowerShell)
git clone https://github.com/btstevens1984az/DriftGuard.git
cd DriftGuard
docker compose up --build
# Open http://localhost:5173
# Demo: admin@driftguard.example / DriftGuard!admin`}</pre>
          </div>
        </div>
      </section>

      <footer className="relative z-10 border-t border-white/10 py-10 text-center text-sm text-ink-400">
        DriftGuard · Configuration drift detection & remediation assistant · MIT
      </footer>
    </div>
  );
}
