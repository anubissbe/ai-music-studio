#!/usr/bin/env python3
# fix_blocks.py

import os
import re

BLOCK_START = re.compile(r'^(\s*)(if|elif|else|for|while|with|def|class)\b.*:\s*(#.*)?$')

def fix_file(path):
    with open(path, 'r') as f:
        lines = f.readlines()

    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        out.append(line)

        m = BLOCK_START.match(line)
        if m and i + 1 < len(lines):
            base_indent = len(m.group(1))
            next_line = lines[i+1]
            # skip blank/comment lines
            if next_line.strip() and not next_line.lstrip().startswith('#'):
                cur_indent = len(next_line) - len(next_line.lstrip(' '))
                if cur_indent <= base_indent:
                    stripped = next_line.lstrip(' ')
                    new_indent = ' ' * (base_indent + 4)
                    out.append(new_indent + stripped)
                    i += 2
                    continue
        i += 1

    with open(path, 'w') as f:
        f.writelines(out)
    print(f"  ✓ {path}")

if __name__ == '__main__':
    for root, _, files in os.walk('.'):
        for fn in files:
            if fn == 'app.py':
                fix_file(os.path.join(root, fn))

