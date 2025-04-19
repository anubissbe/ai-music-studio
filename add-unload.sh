#!/usr/bin/env bash
set -e
for f in models/*/app.py; do
  echo "→ Patching $f"
  # insert unload_model() just before the final if __name__ block
  awk '
    /^if __name__ *== *["'\'']__main__["'\''] *:/ {
      print ""
      print "@app.route(\"/unload\", methods=[\"POST\"])"
      print "def unload_model():"
      print "    \"\"\"Unload the model from GPU and clear cache.\"\"\""
      print "    global MODEL"
      print "    if MODEL is None:"
      print "        return jsonify({\"success\": False, \"error\": \"No model loaded\"}), 400"
      print "    MODEL = None"
      print "    torch.cuda.empty_cache()"
      print "    return jsonify({\"success\": True, \"message\": \"Model unloaded successfully\"})"
    }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done
echo "✅ Done. Now re‑format and rebuild:"
echo "   black models/*/app.py"
echo "   docker-compose build && docker-compose up"

