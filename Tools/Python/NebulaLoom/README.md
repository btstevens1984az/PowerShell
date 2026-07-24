# Nebula Loom

A small generative space-art playground written in Python.

Weave glowing aurora ribbons, plant gravity wells, and launch comets across a
living starfield. Uses only the Python standard library (`tkinter`) — no pip
packages required.

## How to run

1. Install **Python 3** if you do not have it yet.
2. On Linux you may also need the Tk bindings:

   ```bash
   # Debian / Ubuntu
   sudo apt-get install python3-tk
   ```

   On Windows and macOS, `tkinter` usually ships with the official Python installer.
3. From this folder, run:

   ```bash
   python3 nebula_loom.py
   ```

   On Windows you can also double-click the file, or run `py nebula_loom.py`.

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
