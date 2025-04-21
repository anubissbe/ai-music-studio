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

OUTPUT_FOLDER = "/app/output"
if not os.path.isdir(OUTPUT_FOLDER):
    os.makedirs(OUTPUT_FOLDER)

app = Flask(__name__)
CORS(app)

@app.route('/load', methods=['POST'])
def load_route():
    success = load_model_impl()
    if success:
        return jsonify(success=True, message='DanceDiffusion model loaded')
    return jsonify(success=False, error='Failed to load model'), 500

@app.route('/unload', methods=['POST'])
def unload_route():
    success = unload_model_impl()
    if success:
        return jsonify(success=True, message='DanceDiffusion model unloaded')
    return jsonify(success=False, error='Failed to unload model'), 500

@app.route('/generate', methods=['POST'])
def generate_route():
    data = request.json or {}
    # content_prompt and style_prompt are ignored by unconditional model
    output = data.get('outputPath')
    if not output:
        return jsonify(success=False, error='outputPath required'), 400
    duration = generate_impl(output)
    if duration > 0:
        return jsonify(success=True, duration=duration, outputPath=output_path)
    return jsonify(success=False, error='Generation failed'), 500

@app.route('/generate/extend', methods=['POST'])
def extend_route():
    data = request.json or {}
    source = data.get('sourcePath')
    output = data.get('outputPath')
    extend_duration = data.get('extendDuration', 30.0)
    if not source or not output:
        return jsonify(success=False, error='sourcePath and outputPath required'), 400
    duration = extend_impl(source, output, extend_duration)
    if duration > 0:
        return jsonify(success=True, duration=duration, outputPath=output_path)
    return jsonify(success=False, error='Extension failed'), 500

@app.route('/generate/remix', methods=['POST'])
def remix_route():
    data = request.json or {}
    source = data.get('sourcePath')
    output = data.get('outputPath')
    if not source or not output:
        return jsonify(success=False, error='sourcePath and outputPath required'), 400
    duration = remix_impl(source, output)
    if duration > 0:
        return jsonify(success=True, duration=duration, outputPath=output_path)
    return jsonify(success=False, error='Remix failed'), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
