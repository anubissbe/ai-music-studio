#!/usr/bin/env bash
set -euo pipefail

# 1) remove any stray "global MODEL" or literal "..." placeholder lines
find models -type f -name app.py \
  -exec sed -i '/^[[:space:]]*global MODEL[[:space:]]*$/d' {} \; \
  -exec sed -i '/^[[:space:]]*\.\.\.[[:space:]]*$/d' {} \;

# 2) format *every* app.py under models/ with Black (4‑space indent, fix up all blocks)
black --quiet models

