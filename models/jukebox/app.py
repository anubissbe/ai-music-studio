import os
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


# Flask API
app=Flask(__name__)
CORS(app)

    return jsonify(success=True)

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


# --- automatisch toegevoegd load/unload endpoints ---
    global model
    success = load_musicgen_model()
    if success:
        return jsonify({"success": True, "message": "Model loaded successfully"})
    else:
        return jsonify({"success": False, "error": "Failed to load model"}), 500

    global model
    if model is None:
        return jsonify({"success": False, "error": "No model loaded"}), 400
    model = None
    import gc; gc.collect()
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    return jsonify({"success": True, "message": "Model unloaded successfully"})

# --- automatisch toegevoegd: load/unload endpoints ---
    global model
    success = load_musicgen_model()
    if success:
        return jsonify({"success": True, "message": "Model loaded successfully"})
    else:
        return jsonify({"success": False, "error": "Failed to load model"}), 500

    global model
    if model is None:
        return jsonify({"success": False, "error": "No model loaded"}), 400
    model = None
    import gc; gc.collect()
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    return jsonify({"success": True, "message": "Model unloaded successfully"})

# --- automatisch toegevoegd: load/unload endpoints ---
from flask import jsonify
    global model
    success = load_musicgen_model()
    if success:
        return jsonify({"success": True, "message": "Model loaded successfully"})
    return jsonify({"success": False, "error": "Failed to load model"}), 500

    global model
    if model is None:
        return jsonify({"success": False, "error": "No model loaded"}), 400
    model = None
    import gc; gc.collect()
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    return jsonify({"success": True, "message": "Model unloaded successfully"})

# --- automatisch toegevoegd: load/unload endpoints ---
from flask import jsonify
def unload_model():
    global model
    if model is None:
        return jsonify({"success": False, "error": "No model loaded"}), 400
    model = None
    import gc; gc.collect()
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    return jsonify({"success": True, "message": "Model unloaded successfully"})

# --- automatisch toegevoegd: load/unload endpoints ---
from flask import jsonify

    success = load_musicgen_model()
    if success:
        return jsonify({"success": True, "message": "Model loaded successfully"})
    return jsonify({"success": False, "error": "Failed to load model"}), 500

    global model
    if model is None:
        return jsonify({"success": False, "error": "No model loaded"}), 400
    model = None
    import gc; gc.collect()
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    return jsonify({"success": True, "message": "Model unloaded successfully"})

# --- automatisch toegevoegd: load/unload endpoints ---

@app.route("/load", methods=["POST"])
def load_model_endpoint():
    """Laad het model in GPU geheugen."""
    success = load_musicgen_model()
    if success:
        return jsonify({"success": True, "message": "Model loaded successfully"})
    return jsonify({"success": False, "error": "Failed to load model"}), 500

@app.route("/unload", methods=["POST"])
def unload_model_endpoint():
    """Verwijder het model uit GPU geheugen."""
    global model
    if model is None:
        return jsonify({"success": False, "error": "No model loaded"}), 400
    model = None
    import gc; gc.collect()
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    return jsonify({"success": True, "message": "Model unloaded successfully"})
if __name__ == "__main__":
    app.run(host="0.0.0.0",port=5000)

