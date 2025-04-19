#!/usr/bin/env bash
set -euo pipefail

# Loop over each service’s app.py
for f in models/*/app.py; do
  echo "→ fixing $f …"

  # 1) Remove any "if MODEL is not None:" plus its single-line body
  sed -i '/^[[:space:]]*if MODEL is not None:/{
    N
    d
  }' "$f"

  # 2) Remove stray "global MODEL"
  sed -i '/^[[:space:]]*global MODEL[[:space:]]*$/d' "$f"

  # 3) Remove orphaned empty_cache calls
  sed -i '/torch\.cuda\.empty_cache()/d' "$f"

  # 4) Remove tiny `if style_prompt:` blocks
  sed -i '/^[[:space:]]*if style_prompt:/{
    N
    d
  }' "$f"

  # 5) For any empty `with ...:` (no body), insert a pass
  sed -i '/^[[:space:]]*with .*:\s*$/{
    N
    /^[[:space:]]*with .*:\n[[:space:]]*$/{
      s/\(with .*:\)\n[[:space:]]*$/\1\n    pass/
    }
  }' "$f"

  # 6) Reformat with Black (ensure black is in your PATH)
  black --quiet "$f"
done

echo "✓ All app.py under models/ have been cleaned up."

