#!/usr/bin/env python3
"""
Nebula Loom — a generative space-art playground.

Paint glowing ribbons, drop gravity wells, and launch comets across a
living starfield. Built with Python's standard-library tkinter only.

If no desktop display is available (WSL, SSH, some IDEs), the app
automatically opens a browser version instead.

Run:
    python3 nebula_loom.py
    python3 nebula_loom.py --web
    py nebula_loom.py
"""

from __future__ import annotations

import argparse
import math
import os
import random
import sys
import traceback
import webbrowser
from dataclasses import dataclass
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import List, Optional, Tuple

# ---------------------------------------------------------------------------
# Shared look
# ---------------------------------------------------------------------------

PALETTES = {
    "Aurora": ["#1ee0b0", "#3ad4ff", "#7cffc4", "#a8fff0", "#5ce1e6"],
    "Ember": ["#ffb347", "#ff7a45", "#ffd166", "#ff9f68", "#ffe08a"],
    "Tide": ["#4fd1c5", "#38bdf8", "#67e8f9", "#99f6e4", "#22d3ee"],
    "Bloom": ["#f9a8d4", "#fda4af", "#fbcfe8", "#fb7185", "#fecdd3"],
}

BG = "#070b14"
PANEL = "#0e1524"
INK = "#d7e0ef"
MUTED = "#8a97ad"
ACCENT = "#3ad4ff"
WELL = "#ffb347"
BORDER = "#1c2740"


def _print_banner() -> None:
    print()
    print("  Nebula Loom")
    print("  -----------")
    print("  Starting… a window (or browser tab) should open shortly.")
    print("  Close that window/tab to quit.")
    print()


# ---------------------------------------------------------------------------
# Desktop (tkinter) app
# ---------------------------------------------------------------------------

@dataclass
class Particle:
    x: float
    y: float
    vx: float
    vy: float
    life: float
    color: str
    size: float
    kind: str = "dust"  # dust | ribbon | comet | spark


@dataclass
class GravityWell:
    x: float
    y: float
    strength: float = 420.0
    pulse: float = 0.0


@dataclass
class Star:
    x: float
    y: float
    size: float
    phase: float
    speed: float


def _import_tk():
    try:
        import tkinter as tk
        from tkinter import ttk
    except ModuleNotFoundError as exc:
        raise RuntimeError(
            "Python could not import tkinter.\n"
            "  Windows: reinstall Python from python.org and enable tcl/tk.\n"
            "  macOS:   brew install python-tk  (or use the python.org installer)\n"
            "  Linux:   sudo apt-get install python3-tk\n"
            "Or run the browser version:  python3 nebula_loom.py --web"
        ) from exc
    return tk, ttk


def run_desktop() -> None:
    tk, ttk = _import_tk()

    class NebulaLoom(tk.Tk):
        WIDTH = 980
        HEIGHT = 640
        MAX_PARTICLES = 2200

        def __init__(self) -> None:
            super().__init__()
            self.title("Nebula Loom")
            self.configure(bg=BG)
            self.minsize(860, 560)
            self.geometry(f"{self.WIDTH + 220}x{self.HEIGHT + 80}+80+60")

            self.palette_name = tk.StringVar(value="Aurora")
            self.tool = tk.StringVar(value="Weave")
            self.density = tk.DoubleVar(value=0.65)
            self.wind = tk.DoubleVar(value=0.15)
            self.paused = False
            self.painting = False
            self.last_paint: Optional[Tuple[float, float]] = None
            self.tick = 0
            self.status = tk.StringVar(
                value="Drag on the canvas to weave light. Tools are on the left."
            )

            self.particles: List[Particle] = []
            self.wells: List[GravityWell] = []
            self.stars: List[Star] = []

            self._build_style()
            self._build_ui()
            self._seed_stars()
            self._seed_welcome_scene()
            self.bind_all("<Key>", self._on_key)
            self._bring_to_front()
            self.after(16, self._animate)
            self.after(200, self._bring_to_front)

        def _bring_to_front(self) -> None:
            try:
                self.deiconify()
                self.lift()
                self.focus_force()
                # Flash topmost so the window is not buried under the IDE.
                self.attributes("-topmost", True)
                self.after(800, lambda: self.attributes("-topmost", False))
            except tk.TclError:
                pass

        def _build_style(self) -> None:
            style = ttk.Style(self)
            try:
                style.theme_use("clam")
            except tk.TclError:
                pass
            style.configure("Panel.TFrame", background=PANEL)
            style.configure("Root.TFrame", background=BG)
            style.configure(
                "Title.TLabel",
                background=PANEL,
                foreground=INK,
                font=("Segoe UI", 16, "bold"),
            )
            style.configure(
                "Body.TLabel",
                background=PANEL,
                foreground=MUTED,
                font=("Segoe UI", 10),
            )
            style.configure(
                "Hint.TLabel",
                background=BG,
                foreground=MUTED,
                font=("Segoe UI", 9),
            )
            style.configure(
                "Tool.TRadiobutton",
                background=PANEL,
                foreground=INK,
                font=("Segoe UI", 10),
                focuscolor=PANEL,
            )
            style.map(
                "Tool.TRadiobutton",
                background=[("active", PANEL)],
                foreground=[("selected", ACCENT)],
            )
            style.configure(
                "Accent.TButton",
                background=BORDER,
                foreground=INK,
                padding=(10, 6),
                font=("Segoe UI", 10),
            )
            style.map(
                "Accent.TButton",
                background=[("active", "#243352")],
                foreground=[("active", ACCENT)],
            )
            style.configure(
                "TScale",
                background=PANEL,
                troughcolor=BORDER,
                sliderthickness=14,
            )
            style.configure(
                "TCombobox",
                fieldbackground=BORDER,
                background=BORDER,
                foreground=INK,
                arrowcolor=ACCENT,
            )

        def _build_ui(self) -> None:
            root = ttk.Frame(self, style="Root.TFrame")
            root.pack(fill=tk.BOTH, expand=True, padx=12, pady=12)

            side = ttk.Frame(root, style="Panel.TFrame", width=200)
            side.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 12))
            side.pack_propagate(False)

            ttk.Label(side, text="Nebula Loom", style="Title.TLabel").pack(
                anchor="w", padx=16, pady=(18, 4)
            )
            ttk.Label(
                side,
                text="Weave aurora ribbons through a living starfield.",
                style="Body.TLabel",
                wraplength=168,
            ).pack(anchor="w", padx=16, pady=(0, 16))

            ttk.Label(side, text="TOOL", style="Body.TLabel").pack(anchor="w", padx=16)
            for name, tip in [
                ("Weave", "Drag to paint glowing ribbons"),
                ("Gravity", "Click to plant a gravity well"),
                ("Comet", "Click to launch a comet"),
                ("Scatter", "Click to burst star dust"),
            ]:
                ttk.Radiobutton(
                    side,
                    text=name,
                    value=name,
                    variable=self.tool,
                    style="Tool.TRadiobutton",
                    command=lambda t=tip: self.status.set(t),
                ).pack(anchor="w", padx=18, pady=2)

            ttk.Label(side, text="PALETTE", style="Body.TLabel").pack(
                anchor="w", padx=16, pady=(16, 4)
            )
            ttk.Combobox(
                side,
                textvariable=self.palette_name,
                values=list(PALETTES.keys()),
                state="readonly",
                width=16,
            ).pack(anchor="w", padx=16)

            ttk.Label(side, text="DENSITY", style="Body.TLabel").pack(
                anchor="w", padx=16, pady=(16, 2)
            )
            ttk.Scale(
                side, from_=0.15, to=1.0, variable=self.density, orient=tk.HORIZONTAL
            ).pack(fill=tk.X, padx=16)

            ttk.Label(side, text="SOLAR WIND", style="Body.TLabel").pack(
                anchor="w", padx=16, pady=(12, 2)
            )
            ttk.Scale(
                side, from_=-0.6, to=0.6, variable=self.wind, orient=tk.HORIZONTAL
            ).pack(fill=tk.X, padx=16)

            btn_wrap = ttk.Frame(side, style="Panel.TFrame")
            btn_wrap.pack(fill=tk.X, padx=16, pady=(22, 8))
            ttk.Button(
                btn_wrap, text="Clear Dust", style="Accent.TButton", command=self.clear_dust
            ).pack(fill=tk.X, pady=3)
            ttk.Button(
                btn_wrap, text="Clear Wells", style="Accent.TButton", command=self.clear_wells
            ).pack(fill=tk.X, pady=3)
            ttk.Button(
                btn_wrap,
                text="Shuffle Stars",
                style="Accent.TButton",
                command=self._seed_stars,
            ).pack(fill=tk.X, pady=3)
            ttk.Button(
                btn_wrap,
                text="Pause / Play  (Space)",
                style="Accent.TButton",
                command=self.toggle_pause,
            ).pack(fill=tk.X, pady=3)

            ttk.Label(
                side,
                text="Keys: 1–4 tools · C clear · Space pause",
                style="Body.TLabel",
                wraplength=168,
            ).pack(side=tk.BOTTOM, anchor="w", padx=16, pady=16)

            stage = ttk.Frame(root, style="Root.TFrame")
            stage.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

            self.canvas = tk.Canvas(
                stage,
                width=self.WIDTH,
                height=self.HEIGHT,
                bg=BG,
                highlightthickness=1,
                highlightbackground=BORDER,
                cursor="crosshair",
            )
            self.canvas.pack(fill=tk.BOTH, expand=True)
            self.canvas.bind("<ButtonPress-1>", self._on_press)
            self.canvas.bind("<B1-Motion>", self._on_drag)
            self.canvas.bind("<ButtonRelease-1>", self._on_release)
            self.canvas.bind("<Configure>", self._on_resize)

            ttk.Label(stage, textvariable=self.status, style="Hint.TLabel").pack(
                anchor="w", pady=(8, 0)
            )

        def _seed_stars(self) -> None:
            w = max(self.canvas.winfo_width(), self.WIDTH)
            h = max(self.canvas.winfo_height(), self.HEIGHT)
            self.stars = [
                Star(
                    x=random.uniform(0, w),
                    y=random.uniform(0, h),
                    size=random.choice([1, 1, 1, 2, 2, 3]),
                    phase=random.uniform(0, math.tau),
                    speed=random.uniform(0.02, 0.08),
                )
                for _ in range(160)
            ]

        def _seed_welcome_scene(self) -> None:
            """Put visible motion on screen immediately so launch isn't a blank void."""
            self.wells.append(GravityWell(self.WIDTH * 0.55, self.HEIGHT * 0.45, strength=520))
            self._spray_ribbon(90, 480, 420, 160)
            self._spray_ribbon(420, 160, 860, 390)
            self._scatter(self.WIDTH * 0.7, self.HEIGHT * 0.55)
            self.status.set("Welcome scene loaded — drag to weave more ribbons.")

        def _colors(self) -> List[str]:
            return PALETTES[self.palette_name.get()]

        def clear_dust(self) -> None:
            self.particles.clear()
            self.status.set("Dust cleared. The wells remain.")

        def clear_wells(self) -> None:
            self.wells.clear()
            self.status.set("Gravity wells dissolved.")

        def toggle_pause(self) -> None:
            self.paused = not self.paused
            self.status.set("Paused." if self.paused else "Flowing again.")

        def _on_key(self, event) -> None:
            key = event.keysym.lower()
            mapping = {"1": "Weave", "2": "Gravity", "3": "Comet", "4": "Scatter"}
            if key in mapping:
                self.tool.set(mapping[key])
                self.status.set(f"Tool: {mapping[key]}")
            elif key == "c":
                self.clear_dust()
            elif key == "space":
                self.toggle_pause()

        def _on_resize(self, _event) -> None:
            w = max(self.canvas.winfo_width(), 1)
            h = max(self.canvas.winfo_height(), 1)
            for star in self.stars:
                star.x = min(star.x, w - 1)
                star.y = min(star.y, h - 1)

        def _on_press(self, event) -> None:
            tool = self.tool.get()
            if tool == "Weave":
                self.painting = True
                self.last_paint = (event.x, event.y)
                self._spray_ribbon(event.x, event.y, event.x, event.y)
            elif tool == "Gravity":
                self.wells.append(GravityWell(event.x, event.y))
                self.status.set(f"Gravity well planted · {len(self.wells)} active")
            elif tool == "Comet":
                self._launch_comet(event.x, event.y)
            elif tool == "Scatter":
                self._scatter(event.x, event.y)

        def _on_drag(self, event) -> None:
            if not self.painting or self.tool.get() != "Weave":
                return
            lx, ly = self.last_paint or (event.x, event.y)
            self._spray_ribbon(lx, ly, event.x, event.y)
            self.last_paint = (event.x, event.y)

        def _on_release(self, _event) -> None:
            self.painting = False
            self.last_paint = None

        def _spray_ribbon(self, x0: float, y0: float, x1: float, y1: float) -> None:
            dx, dy = x1 - x0, y1 - y0
            dist = math.hypot(dx, dy) or 1.0
            nx, ny = -dy / dist, dx / dist
            count = int(4 + self.density.get() * 14)
            colors = self._colors()
            for _ in range(count):
                t = random.random()
                x = x0 + dx * t + nx * random.uniform(-6, 6)
                y = y0 + dy * t + ny * random.uniform(-6, 6)
                speed = 0.4 + random.random() * 1.8
                self.particles.append(
                    Particle(
                        x=x,
                        y=y,
                        vx=nx * speed * random.uniform(-1, 1) + self.wind.get() * 0.8,
                        vy=ny * speed * random.uniform(-1, 1) + random.uniform(-0.4, 0.2),
                        life=random.uniform(0.55, 1.0),
                        color=random.choice(colors),
                        size=random.uniform(1.5, 4.2),
                        kind="ribbon",
                    )
                )
            self._trim()

        def _launch_comet(self, x: float, y: float) -> None:
            angle = random.uniform(-0.7, 0.7) + (math.pi if self.wind.get() < 0 else 0)
            speed = random.uniform(4.5, 7.5)
            colors = self._colors()
            head = random.choice(colors)
            self.particles.append(
                Particle(
                    x, y, math.cos(angle) * speed, math.sin(angle) * speed, 1.0, head, 5.0, "comet"
                )
            )
            for i in range(18):
                self.particles.append(
                    Particle(
                        x=x - math.cos(angle) * i * 2,
                        y=y - math.sin(angle) * i * 2,
                        vx=math.cos(angle) * speed * 0.7 + random.uniform(-0.4, 0.4),
                        vy=math.sin(angle) * speed * 0.7 + random.uniform(-0.4, 0.4),
                        life=0.9 - i * 0.03,
                        color=random.choice(colors),
                        size=random.uniform(1.2, 3.0),
                        kind="comet",
                    )
                )
            self.status.set("Comet launched.")
            self._trim()

        def _scatter(self, x: float, y: float) -> None:
            colors = self._colors()
            burst = int(30 + self.density.get() * 70)
            for _ in range(burst):
                ang = random.uniform(0, math.tau)
                spd = random.uniform(0.5, 4.5)
                self.particles.append(
                    Particle(
                        x=x,
                        y=y,
                        vx=math.cos(ang) * spd + self.wind.get(),
                        vy=math.sin(ang) * spd,
                        life=random.uniform(0.4, 1.0),
                        color=random.choice(colors),
                        size=random.uniform(1.0, 3.5),
                        kind="spark",
                    )
                )
            self.status.set("Star dust scattered.")
            self._trim()

        def _trim(self) -> None:
            if len(self.particles) > self.MAX_PARTICLES:
                overflow = len(self.particles) - self.MAX_PARTICLES
                del self.particles[0:overflow]

        def _animate(self) -> None:
            self.tick += 1
            if not self.paused:
                self._step_physics()
            self._draw()
            self.after(16, self._animate)

        def _step_physics(self) -> None:
            wind = self.wind.get()
            alive: List[Particle] = []
            for p in self.particles:
                ax = wind * 0.04
                ay = 0.01
                for well in self.wells:
                    dx = well.x - p.x
                    dy = well.y - p.y
                    dist2 = dx * dx + dy * dy + 80.0
                    force = well.strength / dist2
                    ax += dx * force * 0.02
                    ay += dy * force * 0.02

                p.vx = (p.vx + ax) * 0.992
                p.vy = (p.vy + ay) * 0.992
                p.x += p.vx
                p.y += p.vy
                decay = 0.004 if p.kind == "ribbon" else 0.007
                if p.kind == "comet":
                    decay = 0.01
                p.life -= decay
                if p.life > 0.02:
                    alive.append(p)
                    if p.kind == "comet" and p.size > 4 and random.random() < 0.4:
                        alive.append(
                            Particle(
                                x=p.x,
                                y=p.y,
                                vx=p.vx * 0.2,
                                vy=p.vy * 0.2,
                                life=0.35,
                                color=p.color,
                                size=max(1.0, p.size * 0.35),
                                kind="dust",
                            )
                        )
            self.particles = alive[-self.MAX_PARTICLES :]
            for well in self.wells:
                well.pulse += 0.08

        def _draw(self) -> None:
            c = self.canvas
            c.delete("all")
            w = max(c.winfo_width(), 1)
            h = max(c.winfo_height(), 1)

            c.create_rectangle(0, 0, w, h, fill=BG, outline="")
            c.create_oval(-w * 0.2, -h * 0.3, w * 0.7, h * 0.6, fill="#0a1222", outline="")
            c.create_oval(w * 0.35, h * 0.25, w * 1.25, h * 1.2, fill="#090f1c", outline="")

            for star in self.stars:
                twinkle = 0.45 + 0.55 * abs(math.sin(self.tick * star.speed + star.phase))
                shade = int(160 + 95 * twinkle)
                color = f"#{shade:02x}{shade:02x}{min(255, shade + 20):02x}"
                r = star.size * (0.7 + 0.5 * twinkle)
                c.create_oval(
                    star.x - r, star.y - r, star.x + r, star.y + r, fill=color, outline=""
                )

            for well in self.wells:
                pulse = 10 + 6 * math.sin(well.pulse)
                for ring, alpha_hint in (
                    (pulse + 18, "#3a2a12"),
                    (pulse + 8, "#6a4a1a"),
                    (pulse, WELL),
                ):
                    c.create_oval(
                        well.x - ring,
                        well.y - ring,
                        well.x + ring,
                        well.y + ring,
                        outline=alpha_hint,
                        width=1,
                    )
                c.create_oval(
                    well.x - 3, well.y - 3, well.x + 3, well.y + 3, fill=WELL, outline=""
                )

            for p in self.particles:
                r = p.size * (0.5 + 0.5 * p.life)
                if p.size > 2.2 and p.life > 0.35:
                    glow = r * 2.1
                    c.create_oval(
                        p.x - glow,
                        p.y - glow,
                        p.x + glow,
                        p.y + glow,
                        fill="",
                        outline=p.color,
                        width=1,
                    )
                c.create_oval(
                    p.x - r, p.y - r, p.x + r, p.y + r, fill=p.color, outline=""
                )

            c.create_text(
                18,
                h - 18,
                anchor="sw",
                text="NEBULA LOOM",
                fill="#3a4a66",
                font=("Segoe UI", 11, "bold"),
            )

    app = NebulaLoom()
    print("  Desktop window opened. Look for 'Nebula Loom' in your taskbar.")
    app.mainloop()


# ---------------------------------------------------------------------------
# Browser fallback (stdlib only) — works without a desktop display server
# ---------------------------------------------------------------------------

WEB_PAGE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>Nebula Loom</title>
<style>
  :root {
    --bg: #070b14;
    --panel: #0e1524;
    --ink: #d7e0ef;
    --muted: #8a97ad;
    --accent: #3ad4ff;
    --border: #1c2740;
    --well: #ffb347;
  }
  * { box-sizing: border-box; }
  html, body {
    margin: 0; height: 100%;
    background: var(--bg); color: var(--ink);
    font-family: "Segoe UI", "Trebuchet MS", sans-serif;
  }
  .layout {
    display: grid;
    grid-template-columns: 220px 1fr;
    height: 100%;
    gap: 12px;
    padding: 12px;
  }
  aside {
    background: var(--panel);
    border: 1px solid var(--border);
    padding: 18px 16px;
    display: flex; flex-direction: column; gap: 10px;
  }
  h1 { margin: 0; font-size: 1.35rem; }
  .blurb { color: var(--muted); font-size: 0.9rem; line-height: 1.35; margin: 0 0 8px; }
  .label { color: var(--muted); font-size: 0.75rem; letter-spacing: 0.06em; margin-top: 8px; }
  label.tool {
    display: flex; align-items: center; gap: 8px;
    cursor: pointer; color: var(--ink); font-size: 0.95rem;
  }
  label.tool:has(input:checked) { color: var(--accent); }
  select, button, input[type=range] { width: 100%; }
  select, button {
    background: var(--border); color: var(--ink);
    border: 1px solid #2a3a58; padding: 8px 10px; border-radius: 2px;
    font: inherit; cursor: pointer;
  }
  button:hover { color: var(--accent); }
  .stage { display: flex; flex-direction: column; gap: 8px; min-width: 0; }
  canvas {
    flex: 1; width: 100%; background: var(--bg);
    border: 1px solid var(--border); cursor: crosshair;
  }
  .status { color: var(--muted); font-size: 0.85rem; min-height: 1.2em; }
  @media (max-width: 720px) {
    .layout { grid-template-columns: 1fr; grid-template-rows: auto 1fr; }
  }
</style>
</head>
<body>
<div class="layout">
  <aside>
    <h1>Nebula Loom</h1>
    <p class="blurb">Weave aurora ribbons through a living starfield.</p>
    <div class="label">TOOL</div>
    <label class="tool"><input type="radio" name="tool" value="Weave" checked/> Weave</label>
    <label class="tool"><input type="radio" name="tool" value="Gravity"/> Gravity</label>
    <label class="tool"><input type="radio" name="tool" value="Comet"/> Comet</label>
    <label class="tool"><input type="radio" name="tool" value="Scatter"/> Scatter</label>
    <div class="label">PALETTE</div>
    <select id="palette">
      <option>Aurora</option><option>Ember</option><option>Tide</option><option>Bloom</option>
    </select>
    <div class="label">DENSITY</div>
    <input id="density" type="range" min="0.15" max="1" step="0.01" value="0.65"/>
    <div class="label">SOLAR WIND</div>
    <input id="wind" type="range" min="-0.6" max="0.6" step="0.01" value="0.15"/>
    <button id="clearDust">Clear Dust</button>
    <button id="clearWells">Clear Wells</button>
    <button id="shuffle">Shuffle Stars</button>
    <button id="pause">Pause / Play</button>
    <p class="blurb" style="margin-top:auto">Keys: 1–4 tools · C clear · Space pause</p>
  </aside>
  <div class="stage">
    <canvas id="sky"></canvas>
    <div class="status" id="status">Drag on the canvas to weave light.</div>
  </div>
</div>
<script>
const PALETTES = {
  Aurora: ["#1ee0b0","#3ad4ff","#7cffc4","#a8fff0","#5ce1e6"],
  Ember: ["#ffb347","#ff7a45","#ffd166","#ff9f68","#ffe08a"],
  Tide: ["#4fd1c5","#38bdf8","#67e8f9","#99f6e4","#22d3ee"],
  Bloom: ["#f9a8d4","#fda4af","#fbcfe8","#fb7185","#fecdd3"],
};
const canvas = document.getElementById("sky");
const ctx = canvas.getContext("2d");
const statusEl = document.getElementById("status");
let particles = [], wells = [], stars = [];
let painting = false, last = null, paused = false, tick = 0;
const MAX = 2200;

function tool() {
  return document.querySelector('input[name="tool"]:checked').value;
}
function colors() { return PALETTES[document.getElementById("palette").value]; }
function density() { return +document.getElementById("density").value; }
function wind() { return +document.getElementById("wind").value; }
function setStatus(t) { statusEl.textContent = t; }

function resize() {
  const rect = canvas.getBoundingClientRect();
  canvas.width = Math.max(320, Math.floor(rect.width * devicePixelRatio));
  canvas.height = Math.max(240, Math.floor(rect.height * devicePixelRatio));
  ctx.setTransform(devicePixelRatio, 0, 0, devicePixelRatio, 0, 0);
}
function seedStars() {
  const w = canvas.clientWidth, h = canvas.clientHeight;
  stars = Array.from({length: 160}, () => ({
    x: Math.random()*w, y: Math.random()*h,
    size: [1,1,1,2,2,3][(Math.random()*6)|0],
    phase: Math.random()*Math.PI*2,
    speed: 0.02 + Math.random()*0.06,
  }));
}
function trim() { if (particles.length > MAX) particles.splice(0, particles.length-MAX); }

function spray(x0,y0,x1,y1) {
  const dx=x1-x0, dy=y1-y0, dist=Math.hypot(dx,dy)||1;
  const nx=-dy/dist, ny=dx/dist, cols=colors(), count=(4+density()*14)|0;
  for (let i=0;i<count;i++) {
    const t=Math.random();
    const x=x0+dx*t+nx*(Math.random()*12-6);
    const y=y0+dy*t+ny*(Math.random()*12-6);
    const speed=0.4+Math.random()*1.8;
    particles.push({
      x,y,
      vx: nx*speed*(Math.random()*2-1)+wind()*0.8,
      vy: ny*speed*(Math.random()*2-1)+(Math.random()*0.6-0.4),
      life: 0.55+Math.random()*0.45,
      color: cols[(Math.random()*cols.length)|0],
      size: 1.5+Math.random()*2.7,
      kind: "ribbon",
    });
  }
  trim();
}
function comet(x,y) {
  const cols=colors(), angle=(Math.random()*1.4-0.7)+(wind()<0?Math.PI:0), speed=4.5+Math.random()*3;
  particles.push({x,y,vx:Math.cos(angle)*speed,vy:Math.sin(angle)*speed,life:1,color:cols[0],size:5,kind:"comet"});
  for (let i=0;i<18;i++) {
    particles.push({
      x:x-Math.cos(angle)*i*2, y:y-Math.sin(angle)*i*2,
      vx:Math.cos(angle)*speed*0.7+(Math.random()*0.8-0.4),
      vy:Math.sin(angle)*speed*0.7+(Math.random()*0.8-0.4),
      life:0.9-i*0.03, color:cols[(Math.random()*cols.length)|0],
      size:1.2+Math.random()*1.8, kind:"comet",
    });
  }
  setStatus("Comet launched."); trim();
}
function scatter(x,y) {
  const cols=colors(), burst=(30+density()*70)|0;
  for (let i=0;i<burst;i++) {
    const ang=Math.random()*Math.PI*2, spd=0.5+Math.random()*4;
    particles.push({
      x,y,vx:Math.cos(ang)*spd+wind(),vy:Math.sin(ang)*spd,
      life:0.4+Math.random()*0.6, color:cols[(Math.random()*cols.length)|0],
      size:1+Math.random()*2.5, kind:"spark",
    });
  }
  setStatus("Star dust scattered."); trim();
}
function welcome() {
  wells.push({x: canvas.clientWidth*0.55, y: canvas.clientHeight*0.45, strength:520, pulse:0});
  spray(90,480,420,160); spray(420,160,860,390);
  scatter(canvas.clientWidth*0.7, canvas.clientHeight*0.55);
  setStatus("Welcome scene loaded — drag to weave more ribbons.");
}

function pos(e) {
  const r = canvas.getBoundingClientRect();
  return {x: e.clientX - r.left, y: e.clientY - r.top};
}
canvas.addEventListener("pointerdown", e => {
  canvas.setPointerCapture(e.pointerId);
  const p = pos(e), t = tool();
  if (t === "Weave") { painting = true; last = p; spray(p.x,p.y,p.x,p.y); }
  else if (t === "Gravity") { wells.push({x:p.x,y:p.y,strength:420,pulse:0}); setStatus(`Gravity well planted · ${wells.length} active`); }
  else if (t === "Comet") comet(p.x,p.y);
  else if (t === "Scatter") scatter(p.x,p.y);
});
canvas.addEventListener("pointermove", e => {
  if (!painting || tool() !== "Weave") return;
  const p = pos(e); spray(last.x,last.y,p.x,p.y); last = p;
});
canvas.addEventListener("pointerup", () => { painting=false; last=null; });

document.getElementById("clearDust").onclick = () => { particles=[]; setStatus("Dust cleared."); };
document.getElementById("clearWells").onclick = () => { wells=[]; setStatus("Gravity wells dissolved."); };
document.getElementById("shuffle").onclick = () => { seedStars(); setStatus("Starfield reshuffled."); };
document.getElementById("pause").onclick = () => { paused=!paused; setStatus(paused?"Paused.":"Flowing again."); };
window.addEventListener("keydown", e => {
  const map = {Digit1:"Weave",Digit2:"Gravity",Digit3:"Comet",Digit4:"Scatter","1":"Weave","2":"Gravity","3":"Comet","4":"Scatter"};
  if (map[e.code] || map[e.key]) {
    const v = map[e.code]||map[e.key];
    document.querySelector(`input[name="tool"][value="${v}"]`).checked = true;
    setStatus("Tool: "+v);
  } else if (e.key === "c" || e.key === "C") { particles=[]; setStatus("Dust cleared."); }
  else if (e.key === " ") { e.preventDefault(); paused=!paused; setStatus(paused?"Paused.":"Flowing again."); }
});

function step() {
  const w = wind();
  const next = [];
  for (const p of particles) {
    let ax=w*0.04, ay=0.01;
    for (const well of wells) {
      const dx=well.x-p.x, dy=well.y-p.y, dist2=dx*dx+dy*dy+80;
      const force=well.strength/dist2; ax+=dx*force*0.02; ay+=dy*force*0.02;
    }
    p.vx=(p.vx+ax)*0.992; p.vy=(p.vy+ay)*0.992; p.x+=p.vx; p.y+=p.vy;
    let decay = p.kind==="ribbon"?0.004:0.007; if (p.kind==="comet") decay=0.01;
    p.life-=decay;
    if (p.life>0.02) {
      next.push(p);
      if (p.kind==="comet" && p.size>4 && Math.random()<0.4) {
        next.push({x:p.x,y:p.y,vx:p.vx*0.2,vy:p.vy*0.2,life:0.35,color:p.color,size:Math.max(1,p.size*0.35),kind:"dust"});
      }
    }
  }
  particles = next.slice(-MAX);
  for (const well of wells) well.pulse += 0.08;
}
function draw() {
  const w = canvas.clientWidth, h = canvas.clientHeight;
  ctx.fillStyle = "#070b14"; ctx.fillRect(0,0,w,h);
  ctx.fillStyle = "#0a1222"; ctx.beginPath(); ctx.ellipse(w*0.25,h*0.15,w*0.45,h*0.45,0,0,Math.PI*2); ctx.fill();
  ctx.fillStyle = "#090f1c"; ctx.beginPath(); ctx.ellipse(w*0.8,h*0.75,w*0.45,h*0.5,0,0,Math.PI*2); ctx.fill();
  for (const s of stars) {
    const tw=0.45+0.55*Math.abs(Math.sin(tick*s.speed+s.phase));
    const shade=(160+95*tw)|0;
    ctx.fillStyle = `rgb(${shade},${shade},${Math.min(255,shade+20)})`;
    ctx.beginPath(); ctx.arc(s.x,s.y,s.size*(0.7+0.5*tw),0,Math.PI*2); ctx.fill();
  }
  for (const well of wells) {
    const pulse=10+6*Math.sin(well.pulse);
    for (const [ring,col] of [[pulse+18,"#3a2a12"],[pulse+8,"#6a4a1a"],[pulse,"#ffb347"]]) {
      ctx.strokeStyle=col; ctx.beginPath(); ctx.arc(well.x,well.y,ring,0,Math.PI*2); ctx.stroke();
    }
    ctx.fillStyle="#ffb347"; ctx.beginPath(); ctx.arc(well.x,well.y,3,0,Math.PI*2); ctx.fill();
  }
  for (const p of particles) {
    const r=p.size*(0.5+0.5*p.life);
    if (p.size>2.2 && p.life>0.35) {
      ctx.strokeStyle=p.color; ctx.beginPath(); ctx.arc(p.x,p.y,r*2.1,0,Math.PI*2); ctx.stroke();
    }
    ctx.fillStyle=p.color; ctx.beginPath(); ctx.arc(p.x,p.y,r,0,Math.PI*2); ctx.fill();
  }
  ctx.fillStyle="#3a4a66"; ctx.font="bold 14px Segoe UI, sans-serif";
  ctx.fillText("NEBULA LOOM", 14, h-14);
}
function frame() {
  tick++;
  if (!paused) step();
  draw();
  requestAnimationFrame(frame);
}
window.addEventListener("resize", () => { resize(); });
resize(); seedStars(); welcome(); frame();
</script>
</body>
</html>
"""


def run_web(port: int = 8765) -> None:
    html = WEB_PAGE.encode("utf-8")

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):  # noqa: N802
            if self.path not in ("/", "/index.html"):
                self.send_error(404)
                return
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(html)))
            self.end_headers()
            self.wfile.write(html)

        def log_message(self, fmt: str, *args) -> None:
            # Keep the terminal quiet except for our own banner.
            return

    # Bind localhost only; try nearby ports if busy.
    server = None
    last_err: Optional[BaseException] = None
    for candidate in range(port, port + 20):
        try:
            server = ThreadingHTTPServer(("127.0.0.1", candidate), Handler)
            port = candidate
            break
        except OSError as exc:
            last_err = exc
    if server is None:
        raise RuntimeError(f"Could not start local server: {last_err}")

    url = f"http://127.0.0.1:{port}/"
    print(f"  Browser UI: {url}")
    print("  Press Ctrl+C in this terminal to stop.")
    # Prefer opening a real browser window.
    opened = webbrowser.open(url)
    if not opened:
        print("  Could not auto-open a browser — paste the URL above into Chrome/Edge/Firefox.")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n  Stopped.")
    finally:
        server.server_close()


def _display_available() -> bool:
    """Best-effort check before constructing a Tk root (avoids ugly tracebacks)."""
    if sys.platform.startswith("linux"):
        display = os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY")
        if not display:
            return False
    # On Windows/macOS, a normal desktop session usually has a display.
    # Still attempt Tk and catch TclError if something is wrong.
    return True


def _explain_display_failure(exc: BaseException) -> None:
    print("  Desktop window could not open:", file=sys.stderr)
    print(f"    {exc}", file=sys.stderr)
    print(file=sys.stderr)
    if sys.platform.startswith("linux"):
        print("  Common fixes:", file=sys.stderr)
        print("    • WSL: use Windows Terminal with WSLg, or run with --web", file=sys.stderr)
        print("    • SSH/remote: use --web (no GUI display on the server)", file=sys.stderr)
        print("    • Missing Tk: sudo apt-get install python3-tk", file=sys.stderr)
    elif sys.platform == "darwin":
        print("  Try: brew install python-tk   or use the python.org installer.", file=sys.stderr)
    elif os.name == "nt":
        print("  Reinstall Python from python.org and enable tcl/tk.", file=sys.stderr)
        print("  Or run:  py nebula_loom.py --web", file=sys.stderr)
    print(file=sys.stderr)


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Nebula Loom — generative space-art playground")
    parser.add_argument(
        "--web",
        action="store_true",
        help="Open the browser version (works without a desktop GUI)",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8765,
        help="Port for --web mode (default 8765)",
    )
    args = parser.parse_args(argv)

    _print_banner()

    if args.web:
        run_web(args.port)
        return 0

    # Prefer desktop GUI; fall back to browser if the display is missing.
    if not _display_available():
        print("  No desktop display detected — opening the browser version instead.")
        print("  Tip: you can also force this with  python3 nebula_loom.py --web")
        print()
        run_web(args.port)
        return 0

    try:
        run_desktop()
        return 0
    except Exception as exc:  # noqa: BLE001 - show friendly guidance to beginners
        # Import / Tcl display failures land here.
        name = type(exc).__name__
        if name in {"TclError", "RuntimeError"} or "tkinter" in str(exc).lower():
            _explain_display_failure(exc)
            print("  Falling back to the browser version…")
            print()
            try:
                run_web(args.port)
                return 0
            except Exception as web_exc:  # noqa: BLE001
                print(f"  Browser fallback also failed: {web_exc}", file=sys.stderr)
                return 1
        print("  Unexpected error:", file=sys.stderr)
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    # On Windows, keep the console open when launched by double-click.
    code = main()
    if os.name == "nt" and code != 0:
        try:
            input("\nPress Enter to close…")
        except EOFError:
            pass
    raise SystemExit(code)
