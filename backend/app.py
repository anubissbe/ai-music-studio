# backend/app.py
import os
import io
import uuid
import requests
from flask import Flask, request, jsonify, send_file
from flask_pymongo import PyMongo
from pydub import AudioSegment

app = Flask(__name__)

# --- MongoDB configuratie (pas eventueel aan) ---
app.config["MONGO_URI"] = "mongodb://mongodb:27017/music_generation"
mongo = PyMongo(app)
tracks = mongo.db.tracks

# --- Beschikbare modellen en hun service‐urls ---
MODEL_SERVICES = {
    "musicgen":  {"name": "MusicGen (Meta AI)",   "url": "http://musicgen:5000"},
    "musicgpt":  {"name": "MusicGPT",             "url": "http://musicgpt:5000"},
    "jukebox":   {"name": "OpenAI Jukebox",       "url": "http://jukebox:5000"},
    "audioldm":  {"name": "AudioLDM",             "url": "http://audioldm:5000"},
    "riffusion": {"name": "Riffusion",            "url": "http://riffusion:5000"},
    "bark":      {"name": "Bark Audio",           "url": "http://bark:5000"},
    "musiclm":   {"name": "MusicLM",              "url": "http://musiclm:5000"},
    "mousai":    {"name": "Môûsai",               "url": "http://mousai:5000"},
    "stable":    {"name": "Stable Audio",         "url": "http://stable_audio:5000"},
    "dance":     {"name": "Dance Diffusion",      "url": "http://dance_diffusion:5000"},
}

OUTPUT_DIR = "output"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# --- 1) lijst van modellen ---
@app.route("/api/models", methods=["GET"])
def list_models():
    return jsonify([
        {"id": mid, "name": svc["name"]}
        for mid, svc in MODEL_SERVICES.items()
    ])

# --- 2) laad een model in de gekozen microservice ---
@app.route("/api/models/load", methods=["POST"])
def load_model():
    data = request.get_json() or {}
    model_id = data.get("id")
    if model_id not in MODEL_SERVICES:
        return jsonify({"error": "Unknown model id"}), 400

    svc_url = MODEL_SERVICES[model_id]["url"]
    r = requests.post(f"{svc_url}/load")
    if r.status_code != 200:
        return jsonify({"error": f"Failed to load {model_id}"}), 500

    return jsonify({"loaded": model_id})

# --- 3) ontlaad model (optioneel) ---
@app.route("/api/models/unload", methods=["POST"])
def unload_model():
    data = request.get_json() or {}
    model_id = data.get("id")
    if model_id not in MODEL_SERVICES:
        return jsonify({"error": "Unknown model id"}), 400

    svc_url = MODEL_SERVICES[model_id]["url"]
    r = requests.post(f"{svc_url}/unload")
    if r.status_code != 200:
        return jsonify({"error": f"Failed to unload {model_id}"}), 500

    return jsonify({"unloaded": model_id})

# --- 4) genereer muziek ---
@app.route("/api/generate", methods=["POST"])
def generate_music():
    data = request.get_json() or {}
    model_id = data.get("model")
    prompt   = data.get("prompt")
    if not model_id or not prompt:
        return jsonify({"error": "Missing 'model' or 'prompt'"}), 400
    if model_id not in MODEL_SERVICES:
        return jsonify({"error": "Unknown model"}), 400

    svc_url = MODEL_SERVICES[model_id]["url"]
    # voer generate-call uit
    r = requests.post(f"{svc_url}/generate", json={"prompt": prompt})
    if r.status_code != 200:
        return jsonify({"error": "Generation failed"}), 500

    # content is raw WAV‑bytes
    wav_bytes = r.content

    # sla op
    track_id = str(uuid.uuid4())
    wav_path = os.path.join(OUTPUT_DIR, f"{track_id}.wav")
    with open(wav_path, "wb") as f:
        f.write(wav_bytes)

    # converteer naar MP3
    mp3_path = os.path.join(OUTPUT_DIR, f"{track_id}.mp3")
    AudioSegment.from_wav(wav_path).export(mp3_path, format="mp3")

    # bewaar in Mongo
    tracks.insert_one({
        "_id": track_id,
        "model": model_id,
        "prompt": prompt,
        "wav": wav_path,
        "mp3": mp3_path
    })

    return jsonify({"id": track_id})

# --- 5) serveer audio (wav of mp3) en stel download in ---
@app.route("/api/tracks/<track_id>/audio", methods=["GET"])
def serve_audio(track_id):
    fmt = request.args.get("format", "wav").lower()
    if fmt not in ("wav", "mp3"):
        return jsonify({"error": "Invalid format"}), 400

    doc = tracks.find_one({"_id": track_id})
    if not doc:
        return jsonify({"error": "Not found"}), 404

    path = doc.get(fmt)
    if not path or not os.path.isfile(path):
        return jsonify({"error": "File missing"}), 404

    mimetype = "audio/wav" if fmt == "wav" else "audio/mpeg"
    return send_file(
        path,
        mimetype=mimetype,
        as_attachment=True,
        download_name=f"{track_id}.{fmt}"
    )

if __name__ == "__main__":
    # prod‐ready: run via uwsgi/gunicorn
    app.run(host="0.0.0.0", port=5000)

