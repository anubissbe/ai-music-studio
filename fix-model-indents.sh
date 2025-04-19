#!/usr/bin/env bash
set -euo pipefail

# Installeer autopep8 indien nog niet aanwezig
if ! command -v autopep8 &> /dev/null; then
  echo "autopep8 niet gevonden, install... ⬇️"
  pip install --user autopep8
fi

# Vind en reformat alle app.py
while IFS= read -r -d '' file; do
  echo "Reformatting $file…"
  autopep8 --in-place --aggressive --aggressive --indent-size 4 "$file"
done < <(find . -type f -name app.py -print0)

echo "✅ Alle app.py’s opnieuw geïndenteerd. Nu opnieuw builden:"
echo "   docker-compose build && docker-compose up"

