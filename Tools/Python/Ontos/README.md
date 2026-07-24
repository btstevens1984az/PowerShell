# ONTOS

**Where language becomes living geometry.**

ONTOS is a linguistic physics engine. You type an English sentence. A hand-built
compiler turns **nouns into bodies**, **adjectives into traits**, and **verbs into
laws of motion**. No AI model. No cloud API. Pure symbolic compilation into a
living particle world — with sedimentary “fossils” from earlier sentences and a
soft sonic signature for each spoken phrase.

Try:

- `lonely satellites broadcast warm static`
- `ancient moths chase a golden moon`
- `fragile glass gardens bloom then shatter`

## How to run (Safari / Mac)

`127.0.0.1` only works if Python and Safari are on the **same computer**.
If you start ONTOS in a remote Cursor cloud `/workspace` terminal, Safari on
your Mac cannot connect to that server.

### Easiest: open the HTML file on your Mac

1. Make sure this repo (or at least `Tools/Python/Ontos/ontos.html`) is on your Mac.
2. In Finder, double-click `Tools/Python/Ontos/ontos.html`  
   — or in Safari use **File → Open File…**

No Python server required.

### Or run Python on your Mac

In Terminal **on your Mac** (not only in a remote cloud agent):

```bash
python3 Tools/Python/Ontos/ontos.py
```

That writes/refreshes `ontos.html` and opens it as a `file://` page in your
browser. You can close the terminal afterward.

### Optional local server

Only if you want `http://127.0.0.1` (same machine as the browser):

```bash
python3 Tools/Python/Ontos/ontos.py --serve
```

## How it works

1. Tokens are stemmed and tagged against a lexicon of adjectives, nouns, verbs,
   and relational words.
2. Unknown words are invented as nouns from their orthography (hash → shape/hue).
3. Each noun phrase becomes a body with mass, glow, scale, social charge, etc.
4. Verbs assign behaviors: `broadcast` emits, `orbit` curves, `chase` seeks,
   `shatter` explodes, `weave` braids, `devour` grows, …
5. Previous worlds leave **fossils** — translucent residues of prior speech.

## Requirements

Python 3 standard library only (optional launcher). A modern browser with canvas
support (Safari, Chrome, Edge, Firefox).
