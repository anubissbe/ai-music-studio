import os
import gc
from flask import Flask, request, jsonify
from flask_cors import CORS
import torch

# Import model-specific load and generate implementations
from app_impl import load_model_impl, generate_impl

OUTPUT_FOLDER = "/app/output"
os.makedirs(OUTPUT_FOLDER, exist_ok=True)
model = None
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

app = Flask(__name__)
CORS(app)


@app.route("/generate", methods=["POST"])
def generate_route():
    data = request.json
    prompt = data.get("prompt", "")
    output_path = data.get("outputPath")
    if not output_path:
        return jsonify(success=False, error="outputPath required"), 400
    duration = generate_impl(prompt, output_path)
    return jsonify(success=True, duration=duration)


@app.route("/load", methods=["POST"])
def load_route():
    global model
    success = load_model_impl()
    if success:
        return jsonify(success=True, message="Model loaded successfully")
    else:
        return jsonify(success=False, error="Failed to load model"), 500


@app.route("/unload", methods=["POST"])
def unload_route():
    global model
    if model is None:
        return jsonify(success=False, error="No model loaded"), 400
    model = None
    gc.collect()
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    return jsonify(success=True, message="Model unloaded successfully")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
