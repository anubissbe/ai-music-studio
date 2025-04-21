from flask import Flask, request, jsonify, send_from_directory, abort
import os
import requests
import logging

# Configureer logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)

MODEL_PORTS = {
    "musicgen": 5000,
    "musicgpt": 5000,
    "jukebox": 5000,
    "audioldm": 5000,
    "riffusion": 5000,
    "bark": 5000,
    "musiclm": 5000,
    "mousai": 5000,
    "stable_audio": 5000,
    "dance_diffusion": 5000,
}

current_model = None

@app.route('/api/models', methods=['GET'])
def get_models():
    return jsonify(list(MODEL_PORTS.keys()))

@app.route('/api/models/load', methods=['POST'])
def load_model():
    global current_model
    model = request.json.get('id')
    if model not in MODEL_PORTS:
        return jsonify({"error": "Model niet gevonden"}), 400
    try:
        r = requests.post(f'http://{model}:{MODEL_PORTS[model]}/load', timeout=60)
        r.raise_for_status()
        current_model = model
        return jsonify({"status": "geladen", "model": model})
    except Exception as e:
        logger.error(f"Laden van model {model} gefaald:", exc_info=True)
        return jsonify({"error": str(e)}), 500

@app.route('/api/models/unload', methods=['POST'])
def unload_model():
    global current_model
    model = request.json.get('id')
    if model not in MODEL_PORTS:
        return jsonify({"error": "Model niet gevonden"}), 400
    try:
        r = requests.post(f'http://{model}:{MODEL_PORTS[model]}/unload', timeout=30)
        r.raise_for_status()
        current_model = None
        return jsonify({"status": "unloaded", "model": model})
    except Exception as e:
        logger.error(f"Unload van model {model} gefaald:", exc_info=True)
        return jsonify({"error": str(e)}), 500

@app.route('/api/generate', methods=['POST'])
def generate():
    if current_model not in MODEL_PORTS:
        return jsonify({"error": "Geen model geladen"}), 400
    
    data = request.json or {}
    logger.debug(f"Generate request data: {data}")
    
    if "outputPath" not in data:
        return jsonify({"error": "outputPath required"}), 400
    
    try:
        r = requests.post(
            f'http://{current_model}:{MODEL_PORTS[current_model]}/generate',
            json=data,
            timeout=180
        )
        r.raise_for_status()
        
        # Log de response van de model service
        response_data = r.json()
        logger.debug(f"Response from model service: {response_data}")
        
        # Voeg outputPath toe als deze niet aanwezig is in de response
        if "outputPath" not in response_data and "outputPath" in data:
            logger.warning("Adding missing outputPath to response")
            response_data["outputPath"] = data["outputPath"]
        
        return jsonify(response_data)
    except Exception as e:
        logger.error(f"Generatie gefaald voor {current_model}:", exc_info=True)
        return jsonify({"error": str(e)}), 500

@app.route('/api/remix', methods=['POST'])
def remix():
    if current_model not in MODEL_PORTS:
        return jsonify({"error": "Geen model geladen"}), 400
    files = {'file': request.files.get('file')}
    form = {
        "prompt": request.form.get("prompt", ""),
        "duration": request.form.get("duration", ""),
        "vocals": request.form.get("vocals", ""),
    }
    try:
        r = requests.post(
            f'http://{current_model}:{MODEL_PORTS[current_model]}/remix',
            files=files,
            data=form,
            timeout=180
        )
        r.raise_for_status()
        response_data = r.json()
        logger.debug(f"Response from remix service: {response_data}")
        return jsonify(response_data)
    except Exception as e:
        logger.error(f"Remix gefaald voor {current_model}:", exc_info=True)
        return jsonify({"error": str(e)}), 500

@app.route('/api/output/<filename>')
def api_output(filename):
    # Dit is het absolute pad naar de output directory
    output_dir = "/opt/ai-music-studio/output"
    logger.debug(f"Trying to serve file {filename} from {output_dir}")
    
    # Lijst alle bestanden in de output directory voor debugging
    try:
        files_in_dir = os.listdir(output_dir)
        logger.debug(f"Files in output directory: {files_in_dir}")
    except Exception as e:
        logger.error(f"Error listing output directory: {e}")
    
    try:
        return send_from_directory(output_dir, filename, conditional=True)
    except FileNotFoundError:
        logger.error(f"File {filename} not found in {output_dir}")
        abort(404)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
