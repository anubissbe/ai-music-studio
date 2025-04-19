#!/usr/bin/env python
import glob

# Patronen waarbij de volgende regel 1 niveau (4 spaties) ingesprongen moet worden
PATTERNS = [
    "with torch.cuda.device(device):",
    "if style_prompt:",
    "if not has_vocals:"
]

for path in glob.glob("models/*/app_impl.py"):
    # lees alle regels
    with open(path, "r") as f:
        lines = f.readlines()

    # pas regels één voor één aan
    for i, line in enumerate(lines):
        stripped = line.strip()
        for pat in PATTERNS:
            if stripped.startswith(pat):
                # als de volgende regel niet al begint met 4 spaties, voeg ze toe
                if i + 1 < len(lines) and not lines[i+1].startswith("    "):
                    lines[i+1] = "    " + lines[i+1]
                break

    # overschrijf het bestand
    with open(path, "w") as f:
        f.writelines(lines)

print("Indentatie-fix toegepast op alle app_impl.py") 

