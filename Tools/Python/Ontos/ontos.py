#!/usr/bin/env python3
"""
ONTOS — where language becomes living geometry.

Type a sentence. Nouns become bodies. Adjectives shape their nature.
Verbs give them laws of motion. Prepositions braid them together.
No AI model. No cloud. A hand-built linguistic physics compiler
that turns English into a world you can watch breathe.

Run (use forward slashes):
    python3 Tools/Python/Ontos/ontos.py
    python3 Tools/Python/Ontos/ontos.py --port 8844
"""

from __future__ import annotations

import argparse
import sys
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Optional
from urllib.parse import urlparse


PAGE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>ONTOS — language becomes geometry</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Syne:wght@500;700;800&family=IBM+Plex+Mono:wght@400;500&display=swap" rel="stylesheet"/>
<style>
  :root {
    --ink: #07090d;
    --ink-2: #0d1118;
    --fog: #9aa7b8;
    --paper: #e8eef6;
    --phosphor: #c6f34d;
    --candle: #efc27a;
    --ice: #7ec8e3;
    --rose: #f07870;
    --line: rgba(232,238,246,0.08);
  }
  * { box-sizing: border-box; }
  html, body {
    margin: 0; height: 100%;
    background: var(--ink);
    color: var(--paper);
    font-family: "Syne", system-ui, sans-serif;
    overflow: hidden;
  }
  body::before {
    content: "";
    position: fixed; inset: 0; pointer-events: none; z-index: 0;
    background:
      radial-gradient(ellipse 80% 55% at 70% -10%, rgba(126,200,227,0.14), transparent 55%),
      radial-gradient(ellipse 60% 50% at -10% 90%, rgba(198,243,77,0.08), transparent 50%),
      radial-gradient(ellipse 50% 40% at 90% 80%, rgba(239,194,122,0.07), transparent 45%),
      linear-gradient(180deg, #07090d 0%, #0a0e14 100%);
  }
  #world {
    position: fixed; inset: 0; width: 100%; height: 100%;
    display: block; z-index: 1;
  }
  .shell {
    position: fixed; inset: 0; z-index: 2;
    display: grid;
    grid-template-rows: auto 1fr auto;
    pointer-events: none;
    padding: clamp(1rem, 3vw, 2rem);
  }
  header {
    display: flex; align-items: flex-end; justify-content: space-between;
    gap: 1.5rem; max-width: 1400px; width: 100%; margin: 0 auto;
    animation: rise 1.1s cubic-bezier(.2,.8,.2,1) both;
  }
  .brand {
    font-family: "Syne", sans-serif;
    font-weight: 800;
    font-size: clamp(2.4rem, 6vw, 4.2rem);
    letter-spacing: -0.04em;
    line-height: 0.9;
    margin: 0;
    background: linear-gradient(120deg, var(--paper) 20%, var(--phosphor) 55%, var(--candle) 100%);
    -webkit-background-clip: text; background-clip: text;
    color: transparent;
  }
  .tag {
    font-family: "Instrument Serif", Georgia, serif;
    font-style: italic;
    font-size: clamp(1.05rem, 2.2vw, 1.45rem);
    color: var(--fog);
    max-width: 22rem;
    line-height: 1.25;
    margin: 0;
    text-align: right;
  }
  .stage-hint {
    place-self: center;
    text-align: center;
    pointer-events: none;
    transition: opacity 0.8s ease;
  }
  .stage-hint.hide { opacity: 0; }
  .stage-hint h2 {
    font-family: "Instrument Serif", Georgia, serif;
    font-weight: 400;
    font-size: clamp(1.6rem, 4vw, 2.6rem);
    margin: 0 0 0.6rem;
    color: var(--paper);
  }
  .stage-hint p {
    margin: 0;
    color: var(--fog);
    font-family: "IBM Plex Mono", monospace;
    font-size: 0.82rem;
    letter-spacing: 0.02em;
  }
  footer {
    max-width: 1400px; width: 100%; margin: 0 auto;
    pointer-events: auto;
    animation: rise 1.1s 0.15s cubic-bezier(.2,.8,.2,1) both;
  }
  .composer {
    display: grid;
    grid-template-columns: 1fr auto;
    gap: 0.65rem;
    background: rgba(13,17,24,0.72);
    border: 1px solid var(--line);
    backdrop-filter: blur(14px);
    padding: 0.65rem;
    border-radius: 2px;
    box-shadow: 0 20px 60px rgba(0,0,0,0.35);
  }
  #utterance {
    width: 100%;
    border: 0; outline: none;
    background: transparent;
    color: var(--paper);
    font-family: "IBM Plex Mono", monospace;
    font-size: clamp(0.95rem, 1.6vw, 1.1rem);
    padding: 0.85rem 1rem;
  }
  #utterance::placeholder { color: #5d6a7c; }
  #speak-btn {
    border: 0; cursor: pointer;
    background: var(--phosphor);
    color: #10140a;
    font-family: "Syne", sans-serif;
    font-weight: 700;
    font-size: 0.95rem;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    padding: 0 1.4rem;
    border-radius: 2px;
    transition: transform 0.15s ease, filter 0.15s ease;
  }
  #speak-btn:hover { filter: brightness(1.08); transform: translateY(-1px); }
  .meta {
    display: flex; flex-wrap: wrap; gap: 0.75rem 1.25rem;
    justify-content: space-between; align-items: center;
    margin-top: 0.75rem;
    font-family: "IBM Plex Mono", monospace;
    font-size: 0.72rem;
    color: var(--fog);
  }
  .chips { display: flex; flex-wrap: wrap; gap: 0.4rem; }
  .chip {
    pointer-events: auto; cursor: pointer;
    border: 1px solid var(--line);
    background: rgba(255,255,255,0.02);
    color: var(--fog);
    padding: 0.35rem 0.55rem;
    border-radius: 2px;
    font: inherit;
  }
  .chip:hover { color: var(--phosphor); border-color: rgba(198,243,77,0.35); }
  #compile-log {
    color: var(--candle);
    min-height: 1em;
    letter-spacing: 0.01em;
  }
  .hud {
    position: fixed; top: 50%; right: clamp(1rem, 3vw, 2rem);
    transform: translateY(-50%);
    z-index: 3; pointer-events: none;
    writing-mode: vertical-rl; text-orientation: mixed;
    font-family: "IBM Plex Mono", monospace;
    font-size: 0.68rem; letter-spacing: 0.18em;
    color: rgba(154,167,184,0.55);
    text-transform: uppercase;
  }
  @keyframes rise {
    from { opacity: 0; transform: translateY(18px); }
    to { opacity: 1; transform: translateY(0); }
  }
  @media (max-width: 720px) {
    header { flex-direction: column; align-items: flex-start; }
    .tag { text-align: left; max-width: none; }
    .composer { grid-template-columns: 1fr; }
    #speak-btn { padding: 0.9rem; }
    .hud { display: none; }
  }
</style>
</head>
<body>
<canvas id="world"></canvas>
<div class="shell">
  <header>
    <h1 class="brand">ONTOS</h1>
    <p class="tag">Where language becomes living geometry.</p>
  </header>
  <div class="stage-hint" id="hint">
    <h2>Speak a world into being</h2>
    <p>nouns become bodies · adjectives shape them · verbs give them laws</p>
  </div>
  <footer>
    <form class="composer" id="form" autocomplete="off" action="/" method="get" onsubmit="return submitUtterance(event);">
      <input id="utterance" name="q" maxlength="160" placeholder='try: lonely satellites broadcast warm static'/>
      <button id="speak-btn" type="button">Speak</button>
    </form>
    <div class="meta">
      <div class="chips" id="examples"></div>
      <div id="compile-log"></div>
    </div>
  </footer>
</div>
<div class="hud" id="hud">linguistic physics · session fossils retained</div>

<script>
"use strict";

/* =========================================================================
   ONTOS — Linguistic Physics Compiler
   A hand-built lexicon maps English → matter, manner, and motion.
   No neural net. Pure symbolic compilation into a particle world.
   ========================================================================= */

const canvas = document.getElementById("world");
const ctx = canvas.getContext("2d", { alpha: false });
const utterance = document.getElementById("utterance");
const compileLog = document.getElementById("compile-log");
const hint = document.getElementById("hint");
const examplesEl = document.getElementById("examples");

const EXAMPLES = [
  "lonely satellites broadcast warm static",
  "ancient moths chase a golden moon",
  "fragile glass gardens bloom then shatter",
  "restless wolves orbit a hollow cathedral",
  "electric seeds devour the silent ocean",
  "two mirrors weave luminous echoes",
];

EXAMPLES.forEach((text) => {
  const b = document.createElement("button");
  b.type = "button";
  b.className = "chip";
  b.textContent = text.split(" ").slice(0, 3).join(" ") + "…";
  b.title = text;
  b.addEventListener("click", () => {
    utterance.value = text;
    speakWorld(text);
  });
  examplesEl.appendChild(b);
});

// --- Lexicon ----------------------------------------------------------------
const ADJECTIVES = {
  lonely:   { hue: 210, glow: 0.4, mass: 0.8, social: -0.8, label: "solitude" },
  warm:     { hue: 28,  glow: 1.2, mass: 1.0, temp: 1.2, label: "heat" },
  cold:     { hue: 195, glow: 0.5, mass: 1.1, temp: -1, label: "frost" },
  ancient:  { hue: 42,  glow: 0.6, mass: 2.2, scale: 1.5, slow: 1.6, label: "age" },
  fragile:  { hue: 320, glow: 0.9, mass: 0.45, brittle: 1, label: "frailty" },
  electric: { hue: 165, glow: 1.6, mass: 0.7, spark: 1, label: "charge" },
  hollow:   { hue: 230, glow: 0.3, mass: 0.5, ring: 1, label: "void" },
  golden:   { hue: 45,  glow: 1.4, mass: 1.2, label: "gilt" },
  silent:   { hue: 250, glow: 0.25, mass: 1.0, hush: 1, label: "quiet" },
  restless: { hue: 10,  glow: 0.9, mass: 0.9, jitter: 1.4, label: "unrest" },
  luminous: { hue: 70,  glow: 2.0, mass: 0.8, label: "radiance" },
  broken:   { hue: 0,   glow: 0.7, mass: 0.7, shards: 1, label: "fracture" },
  vast:     { hue: 200, glow: 0.5, mass: 2.8, scale: 2.2, label: "expanse" },
  tiny:     { hue: 100, glow: 1.0, mass: 0.3, scale: 0.45, label: "minim" },
  fierce:   { hue: 5,   glow: 1.1, mass: 1.4, force: 1.5, label: "fury" },
  slow:     { hue: 90,  glow: 0.5, mass: 1.5, slow: 2.0, label: "lag" },
  rapid:    { hue: 140, glow: 1.0, mass: 0.6, slow: 0.45, label: "haste" },
  sacred:   { hue: 55,  glow: 1.3, mass: 1.6, scale: 1.3, label: "awe" },
  ghostly:  { hue: 180, glow: 0.8, mass: 0.35, alpha: 0.45, label: "specter" },
  molten:   { hue: 18,  glow: 1.7, mass: 1.8, temp: 1.5, label: "slag" },
  crystal:  { hue: 185, glow: 1.2, mass: 1.1, facets: 1, label: "facet" },
  soft:     { hue: 330, glow: 0.7, mass: 0.6, label: "down" },
  heavy:    { hue: 30,  glow: 0.4, mass: 2.5, label: "mass" },
  wild:     { hue: 120, glow: 1.0, mass: 1.0, jitter: 1.8, label: "feral" },
  pale:     { hue: 210, glow: 0.9, mass: 0.8, alpha: 0.7, label: "pallor" },
};

const NOUNS = {
  satellite: { shape: "ring",   scale: 1.0, trail: 1,   tone: 220 },
  river:     { shape: "ribbon", scale: 1.4, fluid: 1,   tone: 110 },
  heart:     { shape: "pulse",  scale: 1.0, beat: 1,    tone: 90 },
  moth:      { shape: "wing",   scale: 0.7, flutter: 1, tone: 340 },
  tower:     { shape: "spire",  scale: 1.6, anchored: 1,tone: 60 },
  ocean:     { shape: "field",  scale: 2.4, fluid: 1,   tone: 80 },
  ember:     { shape: "coal",   scale: 0.6, emit: 1,    tone: 40 },
  ghost:     { shape: "wisp",   scale: 1.0, alpha: 0.4, tone: 180 },
  seed:      { shape: "dot",    scale: 0.45,grow: 1,    tone: 160 },
  moon:      { shape: "disk",   scale: 1.5, gravity: 1, tone: 200 },
  wolf:      { shape: "fang",   scale: 1.0, hunt: 1,    tone: 70 },
  cathedral: { shape: "spire",  scale: 2.0, sacred: 1,  tone: 55 },
  spark:     { shape: "star",   scale: 0.5, emit: 1,    tone: 400 },
  orchard:   { shape: "grove",  scale: 1.8, grow: 1,    tone: 130 },
  machine:   { shape: "gear",   scale: 1.2, tick: 1,    tone: 150 },
  whisper:   { shape: "wisp",   scale: 0.8, hush: 1,    tone: 260 },
  comet:     { shape: "bolt",   scale: 1.1, trail: 1,   tone: 300 },
  mirror:    { shape: "disk",   scale: 1.0, reflect: 1, tone: 240 },
  garden:    { shape: "grove",  scale: 1.5, grow: 1,    tone: 140 },
  static:    { shape: "noise",  scale: 1.2, emit: 1,    tone: 420 },
  crystal:   { shape: "prism",  scale: 1.0, facets: 1,  tone: 280 },
  glass:     { shape: "prism",  scale: 1.0, brittle: 1, tone: 310 },
  storm:     { shape: "field",  scale: 2.0, jitter: 1,  tone: 50 },
  lantern:   { shape: "coal",   scale: 0.8, glow: 1,    tone: 100 },
  serpent:   { shape: "ribbon", scale: 1.3, hunt: 1,    tone: 95 },
  star:      { shape: "star",   scale: 1.2, emit: 1,    tone: 360 },
  bell:      { shape: "disk",   scale: 1.0, beat: 1,    tone: 320 },
  root:      { shape: "ribbon", scale: 1.2, anchored: 1,tone: 75 },
  ash:       { shape: "noise",  scale: 1.0, alpha: 0.5, tone: 45 },
  child:     { shape: "dot",    scale: 0.7, jitter: 0.5,tone: 190 },
  king:      { shape: "spire",  scale: 1.4, gravity: 1, tone: 65 },
  void:      { shape: "ring",   scale: 1.8, gravity: 1.4,tone: 30 },
  flame:     { shape: "coal",   scale: 0.9, emit: 1,    tone: 35 },
  echo:      { shape: "ring",   scale: 1.1, trail: 1,   tone: 250 },
};

const VERBS = {
  broadcast: { mode: "emit",     rate: 1.2, label: "broadcast" },
  orbit:     { mode: "orbit",    rate: 1.0, label: "orbit" },
  chase:     { mode: "chase",    rate: 1.1, label: "chase" },
  bloom:     { mode: "bloom",    rate: 0.8, label: "bloom" },
  shatter:   { mode: "shatter",  rate: 1.0, label: "shatter" },
  drift:     { mode: "drift",    rate: 0.6, label: "drift" },
  pulse:     { mode: "pulse",    rate: 1.0, label: "pulse" },
  hunt:      { mode: "chase",    rate: 1.4, label: "hunt" },
  weave:     { mode: "weave",    rate: 1.0, label: "weave" },
  fall:      { mode: "fall",     rate: 1.0, label: "fall" },
  rise:      { mode: "rise",     rate: 1.0, label: "rise" },
  echo:      { mode: "echo",     rate: 1.0, label: "echo" },
  devour:    { mode: "devour",   rate: 1.2, label: "devour" },
  split:     { mode: "shatter",  rate: 0.9, label: "split" },
  dance:     { mode: "weave",    rate: 1.3, label: "dance" },
  freeze:    { mode: "freeze",   rate: 1.0, label: "freeze" },
  burn:      { mode: "emit",     rate: 1.5, label: "burn" },
  listen:    { mode: "pulse",    rate: 0.5, label: "listen" },
  remember:  { mode: "echo",     rate: 0.7, label: "remember" },
  forget:    { mode: "fade",     rate: 1.0, label: "forget" },
  guard:     { mode: "orbit",    rate: 0.7, label: "guard" },
  sing:      { mode: "pulse",    rate: 1.2, label: "sing" },
  open:      { mode: "bloom",    rate: 1.0, label: "open" },
  close:     { mode: "freeze",   rate: 0.8, label: "close" },
  become:    { mode: "bloom",    rate: 0.5, label: "become" },
};

const STOP = new Set([
  "a","an","the","and","or","then","of","to","into","onto","from","with","toward",
  "towards","through","over","under","in","on","at","by","as","is","are","was","be",
  "their","its","his","her","our","my","two","three","some","many","this","that",
]);

const RELATORS = {
  toward: "attract", towards: "attract", to: "attract", into: "attract",
  from: "repel", with: "bond", and: "bond", through: "weave",
  over: "orbit", under: "fall", around: "orbit",
};

function hashWord(s) {
  let h = 2166136261;
  for (let i = 0; i < s.length; i++) {
    h ^= s.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return h >>> 0;
}

function stem(raw) {
  let w = raw.toLowerCase().replace(/[^a-z\-]/g, "");
  if (w.endsWith("ies") && w.length > 4) w = w.slice(0, -3) + "y";
  else if (w.endsWith("ses") || w.endsWith("zes") || w.endsWith("xes")) w = w.slice(0, -2);
  else if (w.endsWith("s") && !w.endsWith("ss") && w.length > 3) w = w.slice(0, -1);
  else if (w.endsWith("ing") && w.length > 5) w = w.slice(0, -3);
  else if (w.endsWith("ed") && w.length > 4) w = w.slice(0, -2);
  return w;
}

function guessNoun(word) {
  const h = hashWord(word);
  const shapes = ["disk","ring","dot","wisp","star","prism","coal"];
  return {
    shape: shapes[h % shapes.length],
    scale: 0.7 + (h % 100) / 120,
    tone: 60 + (h % 320),
    invented: 1,
  };
}

function compile(sentence) {
  const tokens = sentence.trim().split(/\s+/).filter(Boolean);
  const tagged = tokens.map((raw) => {
    const w = stem(raw);
    if (ADJECTIVES[w]) return { raw, w, pos: "adj", data: ADJECTIVES[w] };
    if (VERBS[w]) return { raw, w, pos: "verb", data: VERBS[w] };
    if (NOUNS[w]) return { raw, w, pos: "noun", data: NOUNS[w] };
    if (RELATORS[w]) return { raw, w, pos: "rel", data: { rel: RELATORS[w] } };
    if (STOP.has(w) || STOP.has(raw.toLowerCase())) return { raw, w, pos: "stop", data: {} };
    // Unknown content word → invent a noun from its orthography
    return { raw, w, pos: "noun", data: guessNoun(w) };
  });

  const entities = [];
  let pendingAdj = [];
  let lastEntity = null;
  let pendingVerb = null;
  let pendingRel = null;
  const links = [];
  const notes = [];

  function flushNoun(tok) {
    const e = {
      id: entities.length,
      word: tok.raw,
      lemma: tok.w,
      noun: { ...tok.data },
      adjs: pendingAdj.map((a) => ({ word: a.raw, ...a.data })),
      verb: pendingVerb ? { ...pendingVerb.data, word: pendingVerb.raw } : { mode: "drift", rate: 0.5, word: "drift" },
      x: 0, y: 0, vx: 0, vy: 0,
      age: 0, life: 1,
      phase: Math.random() * Math.PI * 2,
      children: [],
      memory: [],
    };
    // Derive physical traits from adjectives
    let hue = (hashWord(tok.w) % 360);
    let mass = 1, scale = e.noun.scale || 1, glow = 0.8, slow = 1, alpha = 1;
    let social = 0, jitter = 0, temp = 0, force = 1;
    for (const a of e.adjs) {
      if (a.hue != null) hue = (hue * 0.35 + a.hue * 0.65);
      if (a.mass) mass *= a.mass;
      if (a.scale) scale *= a.scale;
      if (a.glow) glow *= a.glow;
      if (a.slow) slow *= a.slow;
      if (a.alpha) alpha *= a.alpha;
      if (a.social) social += a.social;
      if (a.jitter) jitter += a.jitter;
      if (a.temp) temp += a.temp;
      if (a.force) force *= a.force;
      notes.push(`${a.word}→${a.label}`);
    }
    e.hue = hue; e.mass = mass; e.scale = scale; e.glow = glow;
    e.slow = slow; e.alpha = alpha; e.social = social; e.jitter = jitter;
    e.temp = temp; e.force = force;
    e.r = 10 * scale * Math.sqrt(mass);
    entities.push(e);
    notes.push(`${tok.raw}∶${e.verb.mode}`);
    if (pendingRel && lastEntity != null) {
      links.push({ a: lastEntity, b: e.id, kind: pendingRel });
      pendingRel = null;
    }
    lastEntity = e.id;
    pendingAdj = [];
    // verb applies to this noun if it preceded; keep for subsequent nouns too
  }

  for (const tok of tagged) {
    if (tok.pos === "adj") pendingAdj.push(tok);
    else if (tok.pos === "verb") pendingVerb = tok;
    else if (tok.pos === "rel") pendingRel = tok.data.rel;
    else if (tok.pos === "noun") flushNoun(tok);
  }

  // If a verb appears after subjects ("moths chase moon"), link chase from prior to next
  // Already handled by pendingVerb carrying forward.

  // Default link: consecutive entities bonded lightly if verb is relational
  if (entities.length >= 2) {
    const mode = entities[0].verb.mode;
    if (["chase", "orbit", "weave", "devour", "echo"].includes(mode)) {
      for (let i = 0; i < entities.length - 1; i++) {
        if (!links.some((l) => l.a === i && l.b === i + 1)) {
          links.push({
            a: i, b: i + 1,
            kind: mode === "chase" || mode === "devour" ? "attract"
                : mode === "orbit" ? "orbit"
                : mode === "weave" ? "weave" : "bond",
          });
        }
      }
    }
  }

  return { entities, links, notes, tagged };
}

// --- World state ------------------------------------------------------------
let bodies = [];
let fossils = [];
let sparks = [];
let ripples = [];
let tick = 0;
let W = 0, H = 0, DPR = 1;
let audioCtx = null;

function resize() {
  DPR = Math.min(devicePixelRatio || 1, 2);
  W = canvas.clientWidth = window.innerWidth;
  H = canvas.clientHeight = window.innerHeight;
  canvas.width = Math.floor(W * DPR);
  canvas.height = Math.floor(H * DPR);
  ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
}
window.addEventListener("resize", resize);
resize();

function color(h, s, l, a = 1) {
  return `hsla(${h}, ${s}%, ${l}%, ${a})`;
}

function ensureAudio() {
  if (!audioCtx) {
    try { audioCtx = new (window.AudioContext || window.webkitAudioContext)(); }
    catch { audioCtx = null; }
  }
  if (audioCtx && audioCtx.state === "suspended") audioCtx.resume();
}

function chime(freq, dur = 0.25, type = "sine", gain = 0.03) {
  if (!audioCtx) return;
  const t = audioCtx.currentTime;
  const o = audioCtx.createOscillator();
  const g = audioCtx.createGain();
  o.type = type;
  o.frequency.setValueAtTime(freq, t);
  o.frequency.exponentialRampToValueAtTime(Math.max(40, freq * 0.7), t + dur);
  g.gain.setValueAtTime(gain, t);
  g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
  o.connect(g); g.connect(audioCtx.destination);
  o.start(t); o.stop(t + dur + 0.02);
}

function placeEntities(entities) {
  const cx = W * 0.5, cy = H * 0.52;
  const n = entities.length;
  entities.forEach((e, i) => {
    const ang = -Math.PI / 2 + (i / Math.max(1, n)) * Math.PI * 2;
    const rad = Math.min(W, H) * (0.12 + 0.08 * n);
    e.x = cx + Math.cos(ang) * rad * (0.7 + Math.random() * 0.4);
    e.y = cy + Math.sin(ang) * rad * 0.55;
    e.vx = (Math.random() - 0.5) * 0.4;
    e.vy = (Math.random() - 0.5) * 0.4;
  });
}

function speakWorld(sentence) {
  const text = (sentence || "").trim();
  if (!text) return;
  ensureAudio();
  hint.classList.add("hide");

  // Fossils: previous bodies leave sedimentary ghosts
  for (const b of bodies) {
    fossils.push({
      x: b.x, y: b.y, r: b.r, hue: b.hue, alpha: 0.18, life: 1,
      word: b.word,
    });
  }
  if (fossils.length > 80) fossils.splice(0, fossils.length - 80);

  const program = compile(text);
  placeEntities(program.entities);
  bodies = program.entities.map((e) => ({ ...e, links: program.links }));
  // Attach world links reference
  bodies._links = program.links;

  ripples.push({ x: W * 0.5, y: H * 0.52, r: 10, life: 1, hue: 70 });
  compileLog.textContent = program.notes.slice(0, 8).join(" · ") || "compiled.";

  // Sonic signature of the sentence
  program.entities.forEach((e, i) => {
    setTimeout(() => chime((e.noun.tone || 200) * (0.8 + e.glow * 0.2), 0.35, i % 2 ? "triangle" : "sine", 0.025), i * 90);
  });
}

function submitUtterance(ev) {
  if (ev) ev.preventDefault();
  speakWorld(utterance.value);
  return false;
}
document.getElementById("form").addEventListener("submit", submitUtterance);
document.getElementById("speak-btn").addEventListener("click", submitUtterance);
utterance.addEventListener("keydown", (ev) => {
  if (ev.key === "Enter") {
    ev.preventDefault();
    submitUtterance(ev);
  }
});

// --- Simulation -------------------------------------------------------------
function emitSparks(b, n, spread = 1) {
  for (let i = 0; i < n; i++) {
    const ang = Math.random() * Math.PI * 2;
    const spd = (0.4 + Math.random() * 2.2) * spread;
    sparks.push({
      x: b.x, y: b.y,
      vx: Math.cos(ang) * spd + b.vx * 0.2,
      vy: Math.sin(ang) * spd + b.vy * 0.2,
      life: 0.5 + Math.random() * 0.7,
      hue: b.hue + (Math.random() * 30 - 15),
      r: 1 + Math.random() * 2.5 * b.glow,
    });
  }
  if (sparks.length > 2500) sparks.splice(0, sparks.length - 2500);
}

function step() {
  tick++;
  const links = bodies._links || [];

  for (const b of bodies) {
    b.age += 1;
    let ax = 0, ay = 0;

    // Soft centering gravity so worlds don't fly away
    ax += (W * 0.5 - b.x) * 0.00002 * b.mass;
    ay += (H * 0.52 - b.y) * 0.00002 * b.mass;

    // Links
    for (const L of links) {
      if (L.a !== b.id && L.b !== b.id) continue;
      const other = bodies[L.a === b.id ? L.b : L.a];
      if (!other) continue;
      const dx = other.x - b.x, dy = other.y - b.y;
      const d = Math.hypot(dx, dy) + 0.001;
      const nx = dx / d, ny = dy / d;
      if (L.kind === "attract") {
        const pull = 0.02 * b.force * other.mass / (d * 0.02 + 1);
        ax += nx * pull; ay += ny * pull;
      } else if (L.kind === "repel") {
        const push = 0.04 / (d * 0.01 + 0.2);
        ax -= nx * push; ay -= ny * push;
      } else if (L.kind === "orbit") {
        ax += -ny * 0.03 * b.force + nx * 0.004;
        ay += nx * 0.03 * b.force + ny * 0.004;
      } else if (L.kind === "weave") {
        ax += -ny * 0.02 + Math.sin(tick * 0.02 + b.phase) * 0.02;
        ay += nx * 0.02 + Math.cos(tick * 0.02 + b.phase) * 0.02;
      } else if (L.kind === "bond") {
        const ideal = 80 + b.r + other.r;
        ax += nx * (d - ideal) * 0.0004;
        ay += ny * (d - ideal) * 0.0004;
      }
    }

    // Verb laws
    const mode = b.verb.mode;
    const rate = (b.verb.rate || 1) / b.slow;
    if (mode === "emit" || mode === "bloom") {
      if (tick % Math.max(2, Math.floor(8 / rate)) === 0) emitSparks(b, mode === "bloom" ? 3 : 2, mode === "bloom" ? 0.6 : 1);
      if (mode === "bloom") b.r = Math.min(b.r * 1.0007, 10 * b.scale * 3);
    }
    if (mode === "pulse") {
      b._pulse = 1 + 0.25 * Math.sin(tick * 0.12 * rate + b.phase);
    } else b._pulse = 1;
    if (mode === "drift") {
      ax += Math.sin(tick * 0.01 + b.phase) * 0.01;
      ay += Math.cos(tick * 0.013 + b.phase) * 0.008;
    }
    if (mode === "fall") ay += 0.03 * rate;
    if (mode === "rise") ay -= 0.03 * rate;
    if (mode === "chase" && bodies.length > 1) {
      const target = bodies[(b.id + 1) % bodies.length];
      const dx = target.x - b.x, dy = target.y - b.y;
      const d = Math.hypot(dx, dy) + 1;
      ax += dx / d * 0.05 * rate * b.force;
      ay += dy / d * 0.05 * rate * b.force;
    }
    if (mode === "devour" && bodies.length > 1) {
      const target = bodies[(b.id + 1) % bodies.length];
      const dx = target.x - b.x, dy = target.y - b.y;
      const d = Math.hypot(dx, dy) + 1;
      ax += dx / d * 0.06 * rate;
      ay += dy / d * 0.06 * rate;
      if (d < b.r + target.r) {
        b.r = Math.min(b.r + 0.04, 80);
        emitSparks(target, 2, 0.5);
      }
    }
    if (mode === "shatter") {
      if (b.age === 90) {
        emitSparks(b, 40, 2.2);
        chime(b.noun.tone || 200, 0.5, "square", 0.02);
      }
      if (b.age > 90) { b.alpha *= 0.985; ax += (Math.random() - 0.5) * 0.2; ay += (Math.random() - 0.5) * 0.2; }
    }
    if (mode === "echo") {
      if (tick % 40 === b.id % 40) {
        ripples.push({ x: b.x, y: b.y, r: b.r, life: 1, hue: b.hue });
        b.memory.push({ x: b.x, y: b.y, age: 0 });
        if (b.memory.length > 12) b.memory.shift();
      }
    }
    if (mode === "freeze") {
      b.vx *= 0.9; b.vy *= 0.9;
    }
    if (mode === "fade") {
      b.alpha *= 0.997;
    }
    if (mode === "weave") {
      ax += Math.sin(tick * 0.05 * rate + b.phase) * 0.04;
      ay += Math.cos(tick * 0.04 * rate + b.phase * 1.3) * 0.04;
    }

    if (b.jitter) {
      ax += (Math.random() - 0.5) * 0.05 * b.jitter;
      ay += (Math.random() - 0.5) * 0.05 * b.jitter;
    }

    // Social: lonely drifts outward
    if (b.social < 0) {
      ax += (b.x - W * 0.5) * 0.00004 * (-b.social);
      ay += (b.y - H * 0.52) * 0.00004 * (-b.social);
    }

    b.vx = (b.vx + ax) * 0.992;
    b.vy = (b.vy + ay) * 0.992;
    const vmax = 4.5 / b.slow;
    const sp = Math.hypot(b.vx, b.vy);
    if (sp > vmax) { b.vx *= vmax / sp; b.vy *= vmax / sp; }
    b.x += b.vx; b.y += b.vy;

    // Soft walls
    const m = 40;
    if (b.x < m) b.vx += 0.05;
    if (b.x > W - m) b.vx -= 0.05;
    if (b.y < m) b.vy += 0.05;
    if (b.y > H - m) b.vy -= 0.05;

    // Trail memory for ring/bolt shapes
    if (b.noun.trail || b.verb.mode === "orbit") {
      b.memory.push({ x: b.x, y: b.y, age: 0 });
      if (b.memory.length > 28) b.memory.shift();
    }
    for (const m of b.memory) m.age++;
  }

  // Sparks
  for (const s of sparks) {
    s.x += s.vx; s.y += s.vy;
    s.vx *= 0.99; s.vy *= 0.99;
    s.life -= 0.012;
  }
  sparks = sparks.filter((s) => s.life > 0);

  for (const f of fossils) f.life -= 0.0015;
  fossils = fossils.filter((f) => f.life > 0);

  for (const r of ripples) { r.r += 2.5; r.life -= 0.012; }
  ripples = ripples.filter((r) => r.life > 0);
}

// --- Rendering --------------------------------------------------------------
function drawBody(b) {
  const pulse = b._pulse || 1;
  const R = b.r * pulse;
  const a = Math.max(0.05, b.alpha);
  const g = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, R * 3.2 * b.glow);
  g.addColorStop(0, color(b.hue, 70, 72, 0.55 * a * b.glow));
  g.addColorStop(0.35, color(b.hue, 65, 50, 0.22 * a));
  g.addColorStop(1, color(b.hue, 60, 40, 0));
  ctx.fillStyle = g;
  ctx.beginPath(); ctx.arc(b.x, b.y, R * 3.2 * b.glow, 0, Math.PI * 2); ctx.fill();

  // Memory trails
  if (b.memory.length > 1) {
    ctx.beginPath();
    b.memory.forEach((m, i) => {
      if (i === 0) ctx.moveTo(m.x, m.y); else ctx.lineTo(m.x, m.y);
    });
    ctx.strokeStyle = color(b.hue, 60, 65, 0.25 * a);
    ctx.lineWidth = Math.max(1, R * 0.15);
    ctx.stroke();
  }

  ctx.save();
  ctx.translate(b.x, b.y);
  ctx.rotate(b.phase + tick * 0.01 / b.slow);
  ctx.globalAlpha = a;
  ctx.fillStyle = color(b.hue, 75, 68, 0.95);
  ctx.strokeStyle = color(b.hue, 50, 80, 0.8);
  ctx.lineWidth = 1.5;

  const sh = b.noun.shape;
  if (sh === "ring" || b.adjs.some((x) => x.ring)) {
    ctx.beginPath(); ctx.arc(0, 0, R * 1.1, 0, Math.PI * 2); ctx.stroke();
    ctx.beginPath(); ctx.arc(0, 0, R * 0.35, 0, Math.PI * 2); ctx.fill();
  } else if (sh === "spire") {
    ctx.beginPath();
    ctx.moveTo(0, -R * 1.6); ctx.lineTo(R * 0.55, R); ctx.lineTo(-R * 0.55, R);
    ctx.closePath(); ctx.fill();
  } else if (sh === "prism" || b.noun.facets || b.adjs.some((x) => x.facets)) {
    ctx.beginPath();
    for (let i = 0; i < 6; i++) {
      const ang = (i / 6) * Math.PI * 2;
      const x = Math.cos(ang) * R, y = Math.sin(ang) * R;
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.closePath(); ctx.fill(); ctx.stroke();
  } else if (sh === "star") {
    ctx.beginPath();
    for (let i = 0; i < 10; i++) {
      const ang = (i / 10) * Math.PI * 2 - Math.PI / 2;
      const rad = i % 2 === 0 ? R * 1.3 : R * 0.5;
      const x = Math.cos(ang) * rad, y = Math.sin(ang) * rad;
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.closePath(); ctx.fill();
  } else if (sh === "wing") {
    ctx.beginPath();
    ctx.ellipse(-R * 0.6, 0, R * 0.9, R * 0.45, -0.4, 0, Math.PI * 2);
    ctx.ellipse(R * 0.6, 0, R * 0.9, R * 0.45, 0.4, 0, Math.PI * 2);
    ctx.fill();
  } else if (sh === "ribbon" || sh === "field") {
    ctx.beginPath();
    for (let i = 0; i <= 16; i++) {
      const t = i / 16;
      const x = (t - 0.5) * R * 3;
      const y = Math.sin(t * Math.PI * 2 + tick * 0.05 + b.phase) * R * 0.45;
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.lineWidth = R * 0.35; ctx.stroke();
  } else if (sh === "fang") {
    ctx.beginPath();
    ctx.moveTo(-R, R * 0.6); ctx.quadraticCurveTo(0, -R * 1.4, R, R * 0.6);
    ctx.quadraticCurveTo(0, R * 0.2, -R, R * 0.6);
    ctx.fill();
  } else if (sh === "gear") {
    ctx.beginPath();
    for (let i = 0; i < 12; i++) {
      const ang = (i / 12) * Math.PI * 2;
      const rad = i % 2 === 0 ? R * 1.2 : R * 0.75;
      const x = Math.cos(ang) * rad, y = Math.sin(ang) * rad;
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.closePath(); ctx.fill(); ctx.stroke();
  } else if (sh === "noise") {
    for (let i = 0; i < 14; i++) {
      const ang = hashWord(b.word + i) % 360 * Math.PI / 180;
      const rad = (0.3 + (hashWord(b.lemma + i) % 100) / 100) * R * 1.4;
      ctx.fillRect(Math.cos(ang) * rad, Math.sin(ang) * rad, 2, 2);
    }
  } else if (sh === "wisp") {
    ctx.beginPath();
    ctx.moveTo(0, R);
    ctx.bezierCurveTo(R, 0, R * 0.5, -R, 0, -R * 0.6);
    ctx.bezierCurveTo(-R * 0.5, -R, -R, 0, 0, R);
    ctx.fill();
  } else if (sh === "bolt") {
    ctx.beginPath();
    ctx.moveTo(-R * 0.2, -R); ctx.lineTo(R * 0.4, -R * 0.1);
    ctx.lineTo(0, -R * 0.1); ctx.lineTo(R * 0.2, R);
    ctx.lineTo(-R * 0.4, R * 0.1); ctx.lineTo(0, R * 0.1);
    ctx.closePath(); ctx.fill();
  } else if (sh === "pulse" || sh === "coal" || sh === "disk" || sh === "dot" || sh === "grove") {
    ctx.beginPath(); ctx.arc(0, 0, R, 0, Math.PI * 2); ctx.fill();
    if (sh === "grove") {
      for (let i = 0; i < 5; i++) {
        const ang = (i / 5) * Math.PI * 2 + tick * 0.01;
        ctx.beginPath();
        ctx.arc(Math.cos(ang) * R * 0.7, Math.sin(ang) * R * 0.7, R * 0.28, 0, Math.PI * 2);
        ctx.fill();
      }
    }
  } else {
    ctx.beginPath(); ctx.arc(0, 0, R, 0, Math.PI * 2); ctx.fill();
  }
  ctx.restore();

  // Label
  ctx.font = "500 11px 'IBM Plex Mono', monospace";
  ctx.fillStyle = color(b.hue, 20, 85, 0.7 * a);
  ctx.textAlign = "center";
  ctx.fillText(b.word, b.x, b.y + R * 1.8 + 10);
}

function frame() {
  step();

  // Backdrop
  ctx.fillStyle = "#07090d";
  ctx.fillRect(0, 0, W, H);
  const bg = ctx.createRadialGradient(W * 0.7, H * 0.05, 0, W * 0.5, H * 0.5, Math.max(W, H) * 0.75);
  bg.addColorStop(0, "rgba(126,200,227,0.07)");
  bg.addColorStop(0.45, "rgba(7,9,13,0)");
  bg.addColorStop(1, "rgba(198,243,77,0.04)");
  ctx.fillStyle = bg;
  ctx.fillRect(0, 0, W, H);

  // Star dust field
  ctx.fillStyle = "rgba(232,238,246,0.35)";
  for (let i = 0; i < 60; i++) {
    const x = (hashWord("sky" + i) % 1000) / 1000 * W;
    const y = (hashWord("deep" + i) % 1000) / 1000 * H;
    const tw = 0.3 + 0.7 * Math.abs(Math.sin(tick * 0.02 + i));
    ctx.globalAlpha = 0.15 + 0.35 * tw;
    ctx.fillRect(x, y, 1.5, 1.5);
  }
  ctx.globalAlpha = 1;

  // Fossils (sedimentary past sentences)
  for (const f of fossils) {
    ctx.beginPath();
    ctx.arc(f.x, f.y, f.r * 1.2, 0, Math.PI * 2);
    ctx.strokeStyle = color(f.hue, 30, 50, 0.15 * f.life);
    ctx.lineWidth = 1;
    ctx.stroke();
    ctx.font = "10px 'IBM Plex Mono', monospace";
    ctx.fillStyle = color(f.hue, 20, 70, 0.2 * f.life);
    ctx.textAlign = "center";
    ctx.fillText(f.word, f.x, f.y + 3);
  }

  for (const r of ripples) {
    ctx.beginPath();
    ctx.arc(r.x, r.y, r.r, 0, Math.PI * 2);
    ctx.strokeStyle = color(r.hue, 60, 70, 0.35 * r.life);
    ctx.lineWidth = 2;
    ctx.stroke();
  }

  // Bonds
  const links = bodies._links || [];
  for (const L of links) {
    const a = bodies[L.a], b = bodies[L.b];
    if (!a || !b) continue;
    ctx.beginPath();
    ctx.moveTo(a.x, a.y); ctx.lineTo(b.x, b.y);
    ctx.strokeStyle = "rgba(198,243,77,0.18)";
    ctx.lineWidth = 1;
    ctx.stroke();
  }

  for (const s of sparks) {
    ctx.fillStyle = color(s.hue, 80, 65, Math.max(0, s.life));
    ctx.beginPath(); ctx.arc(s.x, s.y, s.r * s.life, 0, Math.PI * 2); ctx.fill();
  }

  for (const b of bodies) drawBody(b);

  requestAnimationFrame(frame);
}

frame();
utterance.focus();
</script>
</body>
</html>
"""


def run(port: int = 8844) -> int:
    html = PAGE.encode("utf-8")

    class Handler(BaseHTTPRequestHandler):
        def _serve_app(self) -> None:
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(html)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(html)

        def do_GET(self):  # noqa: N802
            path = urlparse(self.path).path.rstrip("/") or "/"
            # Ignore query strings (native form GETs used to 404 here).
            if path in ("/", "/index.html", "/ontos"):
                self._serve_app()
                return
            if path == "/favicon.ico":
                self.send_response(204)
                self.end_headers()
                return
            self.send_error(404)

        def do_POST(self):  # noqa: N802
            # If a form ever posts, re-show the app instead of erroring.
            self._serve_app()

        def log_message(self, fmt: str, *args) -> None:
            return

    server = None
    last_err: Optional[BaseException] = None
    for candidate in range(port, port + 30):
        try:
            server = ThreadingHTTPServer(("127.0.0.1", candidate), Handler)
            port = candidate
            break
        except OSError as exc:
            last_err = exc
    if server is None:
        print(f"Could not bind a local port: {last_err}", file=sys.stderr)
        return 1

    url = f"http://127.0.0.1:{port}/"
    print()
    print("  ONTOS")
    print("  -----")
    print("  Where language becomes living geometry.")
    print()
    print(f"  Open: {url}")
    print("  Type a sentence. Nouns become bodies. Verbs become laws.")
    print("  Press Ctrl+C here to stop.")
    print()
    if not webbrowser.open(url):
        print("  (Could not auto-open a browser — paste the URL above.)")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n  Stopped.")
    finally:
        server.server_close()
    return 0


def main(argv: Optional[list] = None) -> int:
    parser = argparse.ArgumentParser(description="ONTOS — linguistic physics engine")
    parser.add_argument("--port", type=int, default=8844, help="local port (default 8844)")
    args = parser.parse_args(argv)
    return run(args.port)


if __name__ == "__main__":
    raise SystemExit(main())
