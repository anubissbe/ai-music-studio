#!/usr/bin/env bash
set -euo pipefail

for file in models/*/app.py; do
  echo "⟳ Patching $file …"

  # 1) Verwijder álle oude @app.route("/load" t/m de bijbehorende def
  sed -i '/^@app\.route.*\/load/,/^def /d' "$file"

  # 2) Verwijder álle oude @app.route("/unload" t/m de bijbehorende def
  sed -i '/^@app\.route.*\/unload/,/^def /d' "$file"

  # 3) Verwijder rogue shell‑achtige regels
  sed -i '/^function /d; /_impl()/d; /^if MODEL is not None:/d' "$file"

  # 4) Voeg onderaan, vlak vóór de "if __name__ == '__main__':" je nieuwe handlers toe
  awk '
    BEGIN { injected=0 }
    /^if __name__ == .*__main__.*$/ && injected==0 {
      print ""
      print "# --- automatisch toegevoegd: load/unload endpoints ---"
      print ""
      print "@app.route(\"/load\", methods=[\"POST\"])"
      print "def load_model_endpoint():"
      print "    \"\"\"Laad het model in GPU geheugen.\"\"\""
      print "    success = load_musicgen_model()"
      print "    if success:"
      print "        return jsonify({\"success\": True, \"message\": \"Model loaded successfully\"})"
      print "    return jsonify({\"success\": False, \"error\": \"Failed to load model\"}), 500"
      print ""
      print "@app.route(\"/unload\", methods=[\"POST\"])"
      print "def unload_model_endpoint():"
      print "    \"\"\"Verwijder het model uit GPU geheugen.\"\"\""
      print "    global model"
      print "    if model is None:"
      print "        return jsonify({\"success\": False, \"error\": \"No model loaded\"}), 400"
      print "    model = None"
      print "    import gc; gc.collect()"
      print "    if torch.cuda.is_available():"
      print "        torch.cuda.empty_cache()"
      print "    return jsonify({\"success\": True, \"message\": \"Model unloaded successfully\"})"
      injected=1
    }
    { print }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

  echo "✅ $file gepatcht."
done

echo
echo "🎉 Klaar met patchen! Voer nu:"
echo "   black models/*/app.py"
echo "   docker-compose build && docker-compose up"

