#!/usr/bin/env python3
"""
Nebula Loom — a generative space-art playground.

Paint glowing ribbons, drop gravity wells, and launch comets across a
living starfield. Built with Python's standard-library tkinter only.

Run:
    python3 nebula_loom.py
"""

from __future__ import annotations

import math
import random
import tkinter as tk
from dataclasses import dataclass, field
from tkinter import ttk
from typing import List, Optional, Tuple


# --- Visual direction: midnight navy + teal aurora + amber embers ----------
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


class NebulaLoom(tk.Tk):
    WIDTH = 980
    HEIGHT = 640
    MAX_PARTICLES = 2200

    def __init__(self) -> None:
        super().__init__()
        self.title("Nebula Loom")
        self.configure(bg=BG)
        self.minsize(860, 560)
        self.geometry(f"{self.WIDTH + 220}x{self.HEIGHT + 48}")

        self.palette_name = tk.StringVar(value="Aurora")
        self.tool = tk.StringVar(value="Weave")
        self.density = tk.DoubleVar(value=0.65)
        self.wind = tk.DoubleVar(value=0.15)
        self.paused = False
        self.painting = False
        self.last_paint: Optional[Tuple[float, float]] = None
        self.tick = 0
        self.status = tk.StringVar(value="Drag to weave light across the void.")

        self.particles: List[Particle] = []
        self.wells: List[GravityWell] = []
        self.stars: List[Star] = []

        self._build_style()
        self._build_ui()
        self._seed_stars()
        self.bind_all("<Key>", self._on_key)
        self.after(16, self._animate)

    # ------------------------------------------------------------------ UI
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
        palette = ttk.Combobox(
            side,
            textvariable=self.palette_name,
            values=list(PALETTES.keys()),
            state="readonly",
            width=16,
        )
        palette.pack(anchor="w", padx=16)

        ttk.Label(side, text="DENSITY", style="Body.TLabel").pack(
            anchor="w", padx=16, pady=(16, 2)
        )
        ttk.Scale(side, from_=0.15, to=1.0, variable=self.density, orient=tk.HORIZONTAL).pack(
            fill=tk.X, padx=16
        )

        ttk.Label(side, text="SOLAR WIND", style="Body.TLabel").pack(
            anchor="w", padx=16, pady=(12, 2)
        )
        ttk.Scale(side, from_=-0.6, to=0.6, variable=self.wind, orient=tk.HORIZONTAL).pack(
            fill=tk.X, padx=16
        )

        btn_wrap = ttk.Frame(side, style="Panel.TFrame")
        btn_wrap.pack(fill=tk.X, padx=16, pady=(22, 8))
        ttk.Button(btn_wrap, text="Clear Dust", style="Accent.TButton", command=self.clear_dust).pack(
            fill=tk.X, pady=3
        )
        ttk.Button(btn_wrap, text="Clear Wells", style="Accent.TButton", command=self.clear_wells).pack(
            fill=tk.X, pady=3
        )
        ttk.Button(btn_wrap, text="Shuffle Stars", style="Accent.TButton", command=self._seed_stars).pack(
            fill=tk.X, pady=3
        )
        ttk.Button(btn_wrap, text="Pause / Play  (Space)", style="Accent.TButton", command=self.toggle_pause).pack(
            fill=tk.X, pady=3
        )

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

    # ------------------------------------------------------------- world
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
            for _ in range(140)
        ]
        self.status.set("Starfield reshuffled.")

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

    # ----------------------------------------------------------- input
    def _on_key(self, event: tk.Event) -> None:
        key = event.keysym.lower()
        mapping = {"1": "Weave", "2": "Gravity", "3": "Comet", "4": "Scatter"}
        if key in mapping:
            self.tool.set(mapping[key])
            self.status.set(f"Tool: {mapping[key]}")
        elif key == "c":
            self.clear_dust()
        elif key == "space":
            self.toggle_pause()

    def _on_resize(self, _event: tk.Event) -> None:
        # Keep stars roughly covering the visible area when resized.
        w = max(self.canvas.winfo_width(), 1)
        h = max(self.canvas.winfo_height(), 1)
        for star in self.stars:
            star.x = min(star.x, w - 1)
            star.y = min(star.y, h - 1)

    def _on_press(self, event: tk.Event) -> None:
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

    def _on_drag(self, event: tk.Event) -> None:
        if not self.painting or self.tool.get() != "Weave":
            return
        lx, ly = self.last_paint or (event.x, event.y)
        self._spray_ribbon(lx, ly, event.x, event.y)
        self.last_paint = (event.x, event.y)

    def _on_release(self, _event: tk.Event) -> None:
        self.painting = False
        self.last_paint = None

    # -------------------------------------------------------- emitters
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
            Particle(x, y, math.cos(angle) * speed, math.sin(angle) * speed, 1.0, head, 5.0, "comet")
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

    # --------------------------------------------------------- simulate
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
            ay = 0.01  # faint downward drift
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
                # Comet heads leave a faint trail
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

        # Soft vignette bands for depth without images
        c.create_rectangle(0, 0, w, h, fill=BG, outline="")
        c.create_oval(-w * 0.2, -h * 0.3, w * 0.7, h * 0.6, fill="#0a1222", outline="")
        c.create_oval(w * 0.35, h * 0.25, w * 1.25, h * 1.2, fill="#090f1c", outline="")

        for star in self.stars:
            twinkle = 0.45 + 0.55 * abs(math.sin(self.tick * star.speed + star.phase))
            shade = int(140 + 115 * twinkle)
            color = f"#{shade:02x}{shade:02x}{min(255, shade + 20):02x}"
            r = star.size * (0.7 + 0.5 * twinkle)
            c.create_oval(star.x - r, star.y - r, star.x + r, star.y + r, fill=color, outline="")

        for well in self.wells:
            pulse = 10 + 6 * math.sin(well.pulse)
            for ring, alpha_hint in ((pulse + 18, "#3a2a12"), (pulse + 8, "#6a4a1a"), (pulse, WELL)):
                c.create_oval(
                    well.x - ring,
                    well.y - ring,
                    well.x + ring,
                    well.y + ring,
                    outline=alpha_hint,
                    width=1,
                )
            c.create_oval(well.x - 3, well.y - 3, well.x + 3, well.y + 3, fill=WELL, outline="")

        for p in self.particles:
            r = p.size * (0.5 + 0.5 * p.life)
            # Cheap glow: larger dim oval under brighter core
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
            c.create_oval(p.x - r, p.y - r, p.x + r, p.y + r, fill=p.color, outline="")

        # Brand mark in the canvas corner — part of the composition
        c.create_text(
            18,
            h - 18,
            anchor="sw",
            text="NEBULA LOOM",
            fill="#243044",
            font=("Segoe UI", 11, "bold"),
        )


def main() -> None:
    app = NebulaLoom()
    app.mainloop()


if __name__ == "__main__":
    main()
