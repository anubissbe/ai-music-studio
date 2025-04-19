#!/usr/bin/env bash
set -euo pipefail

# Associatief array van model-naam → import‑lijn + pretrained‑key
declare -A CONFIG=(
  [musicgen]="from audiocraft.models import MusicGen; KEY=melody"
  [audioldm]="from audioldm import AudioLDM; KEY=default"
  [bark]="from bark import BarkModel; KEY=base"
  [dance_diffusion]="from dance_diffusion import DanceDiffusion; KEY=default"
  [riffusion]="from riffusion import Riffusion; KEY=default"
  [jukebox]="from jukebox import Jukebox; KEY=1b_lyrics"
  [musiclm]="from musiclm import MusicLM; KEY=default"
  [musicgpt]="from musicgpt import MusicGPT; KEY=default"
  [mousai]="from mousai import Mousai; KEY=default"
  [stable_audio]="from stable_audio import StableAudio; KEY=default"
)

TEMPLATE='import os
import gc
from flask import Flask, request, jsonify
from flask_cors import CORS
import torch
import numpy as np
import librosa
import soundfile as sf

# Config
OUTPUT_FOLDER = "/app/output"
os.makedirs(OUTPUT_FOLDER, exist_ok=True)
model = None
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Model load / unload
function load_model_impl() {
    global model
    if [[ $model != None ]]; then return 0; fi
    echo "Loading MODEL_NAME model…"
    __IMPORT_LINE__
    model=${CLASS_NAME}.get_pretrained("__PRETRAINED_KEY__")
    model.to(device)
    model.set_generation_params(duration=30)
    echo "Model loaded."
    return 0
}
function unload_model_impl() {
    global model
    if [[ $model == None ]]; then return 0; fi
    echo "Unloading model…"
    model=None
    gc.collect()
    if torch.cuda.is_available(); then
      with torch.cuda.device(device); torch.cuda.empty_cache(); fi
    echo "Model unloaded."
    return 0
}

function generate_impl() {
    prompt="$1"; out="$2"
    [[ $model == None ]] && load_model_impl
    echo "Generating audio: $prompt"
    model.set_generation_params(duration=30)
    audio=model.generate(["$prompt"])[0,0].cpu().numpy()
    sf.write(out, audio, samplerate=32000)
    dur=$(librosa.get_duration(y=audio, sr=32000))
    echo "$dur"
}

# Flask API
app=Flask(__name__)
CORS(app)

@app.route("/load", methods=["POST"])
def load_model():
    load_model_impl()
    return jsonify(success=True)

@app.route("/unload", methods=["POST"])
def unload_model():
    unload_model_impl()
    return jsonify(success=True)

@app.route("/generate", methods=["POST"])
def generate():
    data=request.json
    prompt=data.get("prompt","")
    out=data.get("outputPath")
    if not out:
        return jsonify(success=False, error="outputPath required"),400
    dur=generate_impl(prompt,out)
    return jsonify(success=True,duration=dur)

if __name__ == "__main__":
    app.run(host="0.0.0.0",port=5000)
'

for dir in models/*; do
  name=$(basename "$dir")
  cfg=${CONFIG[$name]:-}
  if [[ -z $cfg ]]; then
    echo "⚠️  Geen config voor '$name', sla over."
    continue
  fi
  # splitsen in import en key
  import_line=${cfg%;*}; key=${cfg#*KEY=}
  class_name=$(echo "$import_line" | sed -E 's/.* import ([A-Za-z0-9_]+)/\1/')
  # schrijf nieuw app.py
  cat > "$dir/app.py" << EOF
${TEMPLATE//__IMPORT_LINE__/$import_line}
EOF
  # vervang placeholders
  sed -i "s/MODEL_NAME/$name/"         "$dir/app.py"
  sed -i "s/__PRETRAINED_KEY__/$key/"  "$dir/app.py"
  sed -i "s/${class_name}\.get_pretrained/.get_pretrained/" "$dir/app.py"
  echo "✅ Gesynced $dir/app.py"
done

echo "🎉 Klaar! Nu nog even formatteren & rebuilden:"
echo "   black models/*/app.py"
echo "   docker-compose build && docker-compose up"

