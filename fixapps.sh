#!/usr/bin/env bash
set -euo pipefail

# Root of your repo
ROOT="$(pwd)"

find "$ROOT/models" -type f -name app.py | while read -r FILE; do
  echo "Fixing $FILE…"

  # 1) Remove literal ellipsis lines
  sed -i '/^[[:space:]]*\.\.\.[[:space:]]*$/d' "$FILE"

  # 2) Remove any "global MODEL" lines
  sed -i '/^[[:space:]]*global MODEL[[:space:]]*$/d' "$FILE"

  # 3) Normalize all tabs/spaces to 4‑space indentation
  #    (Convert leading tabs to 4 spaces, then reduce any 8+ spaces to multiples of 4)
  expand -t 4 "$FILE" \
    | sed -E 's/ {8}/        /g; s/ {12}/            /g; s/ {16}/                /g' \
    > "${FILE}.tmp"
  mv "${FILE}.tmp" "$FILE"

  # 4) Make sure 'if X:' and 'with X:' lines are followed by a properly indented block
  #    This takes any non‑blank line immediately after an if/with and indents it 4 more spaces.
  awk '
    /^[[:space:]]*if .*:[[:space:]]*$/ || /^[[:space:]]*with .*:[[:space:]]*$/ {
      print; 
      getline nxt;
      # if the next line is not blank and not indented more than current+4, add 4 spaces
      indent = match($0, /[^ ]/) - 1 + 4;
      if (nxt ~ /^[[:space:]]*$/) {
        print nxt;
      } else {
        print sprintf("%*s%s", indent, "", nxt);
      }
      next;
    }
    { print }
  ' "$FILE" > "${FILE}.tmp"
  mv "${FILE}.tmp" "$FILE"
done

echo "All app.py files under models/ have been cleaned up. You can now rebuild."

