from flask import Flask, request, jsonify
from flask_cors import CORS
from app_impl import load_musicgen_model, generate_music, extend_track, remix_track

app = Flask(__name__)
CORS(app)

@app.route('/load', methods=['POST'])
def load_model():
    success = load_musicgen_model()
    if success:
        return jsonify({'success': True, 'message': 'MusicGen model loaded successfully'})
    else:
        return jsonify({'success': False, 'error': 'Failed to load MusicGen model'}), 500

@app.route('/unload', methods=['POST'])
def unload_model():
    success = unload_musicgen_model()
    if success:
        return jsonify({'success': True, 'message': 'MusicGen model unloaded successfully'})
    else:
        return jsonify({'success': False, 'error': 'Failed to unload MusicGen model'}), 500

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    content_prompt = data.get('contentPrompt', '')
    style_prompt = data.get('stylePrompt', '')
    has_vocals = data.get('hasVocals', True)
    output_path = data.get('outputPath')

    if not output_path:
        return jsonify({'success': False, 'error': 'Output path is required'}), 400

    success, duration = generate_music(content_prompt, style_prompt, has_vocals, output_path)

    if success:
        return jsonify({'success': True, 'message': 'Music generated successfully', 'duration': duration})
    else:
        return jsonify({'success': False, 'error': 'Failed to generate music'}), 500

@app.route('/extend', methods=['POST'])
def extend():
    data = request.json
    source_track_path = data.get('sourceTrackPath')
    output_path = data.get('outputPath')
    extend_duration = data.get('extendDuration', 30)
    content_prompt = data.get('contentPrompt', '')
    style_prompt = data.get('stylePrompt', '')
    has_vocals = data.get('hasVocals', True)

    if not source_track_path or not output_path:
        return jsonify({'success': False, 'error': 'Source track path and output path are required'}), 400

    success, duration = extend_track(source_track_path, output_path, extend_duration, content_prompt, style_prompt, has_vocals)

    if success:
        return jsonify({'success': True, 'message': 'Track extended successfully', 'duration': duration})
    else:
        return jsonify({'success': False, 'error': 'Failed to extend track'}), 500

@app.route('/remix', methods=['POST'])
def remix():
    data = request.json
    source_track_path = data.get('sourceTrackPath')
    output_path = data.get('outputPath')
    content_prompt = data.get('contentPrompt', '')
    style_prompt = data.get('stylePrompt', '')
    has_vocals = data.get('hasVocals', True)

    if not source_track_path or not output_path:
        return jsonify({'success': False, 'error': 'Source track path and output path are required'}), 400

    success, duration = remix_track(source_track_path, output_path, content_prompt, style_prompt, has_vocals)

    if success:
        return jsonify({'success': True, 'message': 'Track remixed successfully', 'duration': duration})
    else:
        return jsonify({'success': False, 'error': 'Failed to remix track'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

