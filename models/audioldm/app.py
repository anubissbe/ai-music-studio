import os
import gc
from flask import Flask, request, jsonify
from flask_cors import CORS

from app_impl import (
    load_model_impl,
    unload_model_impl,
    generate_impl,
    extend_impl,
    remix_impl,
)

app = Flask(__name__)
CORS(app)


@app.route("/load", methods=["POST"])
def load_route():
    success = load_model_impl()
    if success:
        return jsonify(success=True, message="AudioLDM loaded")
    else:
        return jsonify(success=False, error="Failed to load model"), 500


@app.route("/unload", methods=["POST"])
def unload_route():
    success = unload_model_impl()
    if success:
        return jsonify(success=True, message="AudioLDM unloaded")
    else:
        return jsonify(success=False, error="Failed to unload model"), 500


@app.route("/generate", methods=["POST"])
def generate_route():
    data = request.json or {}
    prompt = data.get("prompt", "")
    output_path = data.get("outputPath")
    if not output_path:
        return jsonify(success=False, error="outputPath required"), 400
    duration = generate_impl(prompt, output_path)
    if duration > 0:
        return jsonify(success=True, duration=duration, outputPath=output_path)
    return jsonify(success=False, error="Generation failed"), 500


@app.route("/generate/extend", methods=["POST"])
def extend_route():
    data = request.json or {}
    source = data.get("sourcePath")
    output = data.get("outputPath")
    dur = data.get("extendDuration", 30.0)
    prompt = data.get("prompt", "")
    if not source or not output:
        return jsonify(success=False, error="sourcePath and outputPath required"), 400
    duration = extend_impl(source, output, dur, prompt)
    if duration > 0:
        return jsonify(success=True, duration=duration, outputPath=output_path)
    return jsonify(success=False, error="Extension failed"), 500


@app.route("/generate/remix", methods=["POST"])
def remix_route():
    data = request.json or {}
    source = data.get("sourcePath")
    output = data.get("outputPath")
    prompt = data.get("prompt", "")
    if not source or not output:
        return jsonify(success=False, error="sourcePath and outputPath required"), 400
    duration = remix_impl(source, output, prompt)
    if duration > 0:
        return jsonify(success=True, duration=duration, outputPath=output_path)
    return jsonify(success=False, error="Remix failed"), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
