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
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

app = Flask(__name__)
CORS(app)

@app.route('/load', methods=['POST'])
def load_route():
    success = load_model_impl()
    if success:
        return jsonify(success=True, message='Bark models loaded')
    return jsonify(success=False, error='Failed to load Bark models'), 500

@app.route('/unload', methods=['POST'])
def unload_route():
    success = unload_model_impl()
    if success:
        return jsonify(success=True, message='Bark models unloaded')
    return jsonify(success=False, error='Failed to unload Bark models'), 500

@app.route('/generate', methods=['POST'])
def generate_route():
    data = request.json or {}
    content = data.get('contentPrompt', '')
    style = data.get('stylePrompt', '')
    vocals = data.get('hasVocals', True)
    output = data.get('outputPath')
    is_remix = data.get('isRemix', False)
    source = data.get('sourcePath')

    if not output:
        return jsonify(success=False, error='outputPath required'), 400

    if is_remix and source:
        ok, duration = remix_impl(source, output, content, style, vocals)
    else:
        ok, duration = generate_impl(content, style, vocals, output)

    if ok:
        return jsonify(success=True, duration=duration)
    return jsonify(success=False, error='Generation failed'), 500

@app.route('/generate/extend', methods=['POST'])
def extend_route():
    data = request.json or {}
    source = data.get('sourcePath')
    output = data.get('outputPath')
    dur = data.get('extendDuration', 30.0)
    content = data.get('contentPrompt', '')
    style = data.get('stylePrompt', '')
    vocals = data.get('hasVocals', True)

    if not source or not output:
        return jsonify(success=False, error='sourcePath and outputPath required'), 400

    ok, duration = extend_impl(source, output, dur, content, style, vocals)
    if ok:
        return jsonify(success=True, duration=duration)
    return jsonify(success=False, error='Extension failed'), 500

@app.route('/generate/remix', methods=['POST'])
def remix_route():
    data = request.json or {}
    source = data.get('sourcePath')
    output = data.get('outputPath')
    content = data.get('contentPrompt', '')
    style = data.get('stylePrompt', '')
    vocals = data.get('hasVocals', True)

    if not source or not output:
        return jsonify(success=False, error='sourcePath and outputPath required'), 400

    ok, duration = remix_impl(source, output, content, style, vocals)
    if ok:
        return jsonify(success=True, duration=duration)
    return jsonify(success=False, error='Remix failed'), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
