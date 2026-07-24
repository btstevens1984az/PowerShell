# Nebula Loom

A small generative space-art playground written in Python.

Weave glowing aurora ribbons, plant gravity wells, and launch comets across a
living starfield. Uses only the Python standard library — no pip packages.

## How to run

From the repo root:

```bash
python3 Tools/Python/NebulaLoom/nebula_loom.py
```

Or from this folder:

```bash
python3 nebula_loom.py
```

On Windows, if `python3` is not found, try:

```powershell
py Tools\Python\NebulaLoom\nebula_loom.py
```

You can also double-click `Run Nebula Loom.bat`.

### If no window appears

Use the browser version (opens Chrome/Edge/Firefox automatically):

```bash
python3 Tools/Python/NebulaLoom/nebula_loom.py --web
```

This is the right choice for **WSL**, **SSH/remote**, or any environment without a
desktop GUI. The script also auto-falls back to `--web` when it cannot open a
desktop window.

### Linux Tk install (desktop mode only)

```bash
sudo apt-get install python3-tk
```

## Controls

| Action | How |
| --- | --- |
| Weave ribbons | Choose **Weave**, then drag on the canvas |
| Plant gravity | Choose **Gravity**, then click |
| Launch a comet | Choose **Comet**, then click |
| Scatter dust | Choose **Scatter**, then click |
| Switch tools | Keys `1`–`4` |
| Pause / play | `Space` |
| Clear dust | `C` or the **Clear Dust** button |

Use the **Palette**, **Density**, and **Solar Wind** controls on the left to
change the look and drift of the particles.
