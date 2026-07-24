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

## How to run

Use **forward slashes** (this works in PowerShell on Linux too):

```powershell
python3 Tools/Python/Ontos/ontos.py
```

On Windows:

```powershell
py Tools/Python/Ontos/ontos.py
```

Your browser should open to `http://127.0.0.1:8844/`. If it doesn’t, paste that
URL manually. Press `Ctrl+C` in the terminal to stop.

## How it works

1. Tokens are stemmed and tagged against a lexicon of adjectives, nouns, verbs,
   and relational words.
2. Unknown words are invented as nouns from their orthography (hash → shape/hue).
3. Each noun phrase becomes a body with mass, glow, scale, social charge, etc.
4. Verbs assign behaviors: `broadcast` emits, `orbit` curves, `chase` seeks,
   `shatter` explodes, `weave` braids, `devour` grows, …
5. Previous worlds leave **fossils** — translucent residues of prior speech.

## Requirements

Python 3 standard library only (`http.server`, `webbrowser`). A modern browser
with canvas support.
