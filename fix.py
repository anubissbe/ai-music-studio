#!/usr/bin/env python
import glob
import re

# Patterns for which the next single line needs indentation
INDENT_NEXT_SINGLE = [
    r"with torch\.cuda\.device\(device\):",
    r"if style_prompt:",
    r"if not has_vocals:",
    r"^if lyrics:$"
]

for path in glob.glob("models/*/app_impl.py"):
    with open(path, "r") as f:
        lines = f.readlines()

    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]
        # Normalize 'if MODEL is not None:' to no indent and indent its block
        if re.match(r"^\s*if MODEL is not None:\s*$", line):
            new_lines.append("if MODEL is not None:\n")
            # indent subsequent block lines until blank or dedent
            j = i + 1
            while j < len(lines) and lines[j].strip() != "" and not re.match(r"^\s*(def |@)", lines[j]):
                # indent this line
                new_lines.append("    " + lines[j].lstrip())
                j += 1
            i = j
            continue

        # Fix decorator + def indent
        if re.match(r"^\s*@", line):
            new_lines.append(line)  # decorator stays
            # next line should be def, unindent
            if i + 1 < len(lines) and re.match(r"^\s*def\s+", lines[i+1]):
                def_line = lines[i+1].lstrip()
                new_lines.append(def_line)
                i += 2
                # Now indent body of this function until next decorator or def or blank
                while i < len(lines) and lines[i].strip() != "" and not re.match(r"^\s*(@|def )", lines[i]):
                    new_lines.append("    " + lines[i].lstrip())
                    i += 1
                continue

        # Handle single-line indent patterns
        stripped = line.strip()
        matched = any(re.match(pat, stripped) for pat in INDENT_NEXT_SINGLE)
        if matched:
            new_lines.append(line)
            # indent only next line if not already
            if i + 1 < len(lines) and lines[i+1].startswith(stripped) or (lines[i+1].strip() != "" and not lines[i+1].startswith("    ")):
                new_lines.append("    " + lines[i+1])
                i += 2
                continue

        # Default: copy
        new_lines.append(line)
        i += 1

    # Write back
    with open(path, "w") as f:
        f.writelines(new_lines)

print("Repaired indent and function blocks in app_impl.py files")

