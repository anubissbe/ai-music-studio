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

OUTPUT_FOLDER = '/app/output'
if not os.path.isdir(OUTPUT_FOLDER):
    os.makedirs(OUTPUT_FOLDER)

@app.route('/load', methods=['POST'])
def load_route():
    if load_model_impl():
        return jsonify(success=True, message='Mousai model loaded')
    return jsonify(success=False, error='Failed to load Mousai model'), 500

@app.route('/unload', methods=['POST'])
def unload_route():
    if unload_model_impl():
        return jsonify(success=True, message='Mousai model unloaded')
    return jsonify(success=False, error='Failed to unload Mousai model'), 500

@app.route('/generate', methods=['POST'])
def generate_route():
    data = request.json or {}
    content = data.get('contentPrompt', '')
    style = data.get('stylePrompt', '')
    vocals = data.get('hasVocals', True)
    output = data.get('outputPath')
    if not output:
        return jsonify(success=False, error='outputPath required'), 400
    ok, duration = generate_impl(content, style, vocals, output)
    if ok:
        return jsonify(success=True, duration=duration, outputPath=output_path)
    return jsonify(success=False, error='Generation failed'), 500

@app.route('/generate/extend', methods=['POST'])
def extend_route():
    data = request.json or {}
    source = data.get('sourceTrackPath')
    output = data.get('outputPath')
    dur = data.get('extendDuration', 30.0)
    content = data.get('contentPrompt', '')
    style = data.get('stylePrompt', '')
    vocals = data.get('hasVocals', True)
    if not source or not output:
        return jsonify(success=False, error='sourceTrackPath and outputPath required'), 400
    ok, duration = extend_impl(source, output, dur, content, style, vocals)
    if ok:
        return jsonify(success=True, duration=duration, outputPath=output_path)
    return jsonify(success=False, error='Extension failed'), 500

@app.route('/generate/remix', methods=['POST'])
def remix_route():
    data = request.json or {}
    source = data.get('sourceTrackPath')
    output = data.get('outputPath')
    content = data.get('contentPrompt', '')
    style = data.get('stylePrompt', '')
    vocals = data.get('hasVocals', True)
    if not source or not output:
        return jsonify(success=False, error='sourceTrackPath and outputPath required'), 400
    ok, duration = remix_impl(source, output, content, style, vocals)
    if ok:
        return jsonify(success=True, duration=duration, outputPath=output_path)
    return jsonify(success=False, error='Remix failed'), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
