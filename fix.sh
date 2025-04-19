#!/usr/bin/env bash
set -e

for file in models/*/app_impl.py; do
  echo "Fixing indentation in $file"
  # na “with torch.cuda.device(device):” indent de volgende regel
  sed -i '/with torch.cuda.device(device):/ {n;s/^/    /}' "$file"
  # na “if style_prompt:” indent de volgende regel
  sed -i '/if style_prompt:/ {n;s/^/    /}'       "$file"
  # na “if not has_vocals:” indent de volgende regel
  sed -i '/if not has_vocals:/ {n;s/^/    /}'     "$file"
done

echo "All indentations fixed!"

