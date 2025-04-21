import soundfile as sf
import librosa
from pydub import AudioSegment
from flask_cors import CORS
from flask import Flask, request, jsonify
import numpy as np
import torchaudio
import torch
import os
import gc

app = Flask(__name__)
CORS(app)

model = None
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

OUTPUT_FOLDER = '/app/output'
os.makedirs(OUTPUT_FOLDER, exist_ok=True)


def load_musicgen_model():
    global model
    try:
        if model is not None:
            return True
        print("Loading MusicGen model...")
        from audiocraft.models import MusicGen
        model = MusicGen.get_pretrained('melody')
        model.set_generation_params(duration=30)
        print("MusicGen model loaded successfully.")
        return True
    except Exception as e:
        print(f"Error loading MusicGen model: {str(e)}")
        return False


def unload_musicgen_model():
    global model
    try:
        if model is None:
            return True
        print("Unloading MusicGen model...")
        model = None
        gc.collect()
        with torch.cuda.device(device):
            torch.cuda.empty_cache()
        print("MusicGen model unloaded successfully.")
        return True
    except Exception as e:
        print(f"Error unloading MusicGen model: {str(e)}")
        return False


def generate_music(content_prompt, style_prompt, has_vocals, output_path):
    global model
    try:
        # Maak absoluut pad
        if not os.path.isabs(output_path):
            full_output_path = os.path.join(OUTPUT_FOLDER, output_path)
        else:
            full_output_path = output_path
            
        print(f"Will save to: {full_output_path}")
        
        # Zorg dat de output directory bestaat
        os.makedirs(OUTPUT_FOLDER, exist_ok=True)

        if model is None and not load_musicgen_model():
            return False, 0

        combined_prompt = content_prompt
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"
        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."

        print(f"Generating music with prompt: {combined_prompt}")

        model.set_generation_params(duration=30)
        audio_output = model.generate([combined_prompt])
        audio_numpy = audio_output.cpu().numpy()[0, 0]
        sf.write(output_path, audio_numpy, samplerate=32000)
        convert_to_mp3(output_path, output_path.replace(".wav", ".mp3"))
        duration = librosa.get_duration(y=audio_numpy, sr=32000)
        return True, duration
    except Exception as e:
        print(f"Error generating music: {str(e)}")
        return False, 0


def extend_track(source_track_path, output_path, extend_duration, content_prompt, style_prompt, has_vocals):
    global model
    try:
        if model is None and not load_musicgen_model():
            return False, 0

        original_audio, sr = librosa.load(source_track_path, sr=32000)

        combined_prompt = content_prompt
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"
        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."
        combined_prompt += " Continuation of the previous section, maintain the same style and theme."

        print(f"Extending track with prompt: {combined_prompt}")

        model.set_generation_params(duration=extend_duration)
        audio_output = model.generate([combined_prompt])
        extension_audio = audio_output.cpu().numpy()[0, 0]
        extended_audio = np.concatenate([original_audio, extension_audio])
        sf.write(output_path, extended_audio, samplerate=32000)
        convert_to_mp3(output_path, output_path.replace(".wav", ".mp3"))
        duration = librosa.get_duration(y=extended_audio, sr=32000)
        return True, duration
    except Exception as e:
        print(f"Error extending track: {str(e)}")
        return False, 0


def remix_track(source_track_path, output_path, content_prompt, style_prompt, has_vocals):
    global model
    try:
        if model is None and not load_musicgen_model():
            return False, 0

        original_audio, sr = librosa.load(source_track_path, sr=32000, duration=10)

        combined_prompt = f"Remix of: {content_prompt}"
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"
        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."

        print(f"Remixing track with prompt: {combined_prompt}")

        model.set_generation_params(duration=30)
        audio_output = model.generate([combined_prompt])
        remix_audio = audio_output.cpu().numpy()[0, 0]
        sf.write(output_path, remix_audio, samplerate=32000)
        convert_to_mp3(output_path, output_path.replace(".wav", ".mp3"))
        duration = librosa.get_duration(y=remix_audio, sr=32000)
        return True, duration
    except Exception as e:
        print(f"Error remixing track: {str(e)}")
        return False, 0


@app.route('/load', methods=['POST'])
def load_model():
    success = load_musicgen_model()
    if success:
        return jsonify({'success': True, 'message': 'MusicGen model loaded successfully'})
    else:
        return jsonify({'success': False, 'error': 'Failed to load MusicGen model'}), 500


@app.route("/unload", methods=["POST"])
def unload_route():
    """Een vereenvoudigde unload functie die niet afhankelijk is van app_impl."""
    try:
        # Probeer globale variabelen op te ruimen
        global model
        model = None
        
        # Ruim torch geheugen op
        import gc
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
            
        print("Unload routine completed")
        return jsonify(success=True, message="Model unloaded successfully")
    except Exception as e:
        print(f"Error in unload route: {str(e)}")
        return jsonify(success=False, error=f"Error: {str(e)}"), 500

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    content_prompt = data.get('contentPrompt', '')
    style_prompt = data.get('stylePrompt', '')
    has_vocals = data.get('hasVocals', True)
    output_path = data.get('outputPath')
    is_remix = data.get('isRemix', False)
    source_track_path = data.get('sourceTrackPath')

    if not output_path:
        return jsonify({'success': False, 'error': 'Output path is required'}), 400

    if is_remix and source_track_path:
        success, duration = remix_track(source_track_path, output_path, content_prompt, style_prompt, has_vocals)
    else:
        success, duration = generate_music(content_prompt, style_prompt, has_vocals, output_path)

    if success:
        return jsonify({'success': True, 'message': 'Music generated successfully', 'duration': duration})
    else:
        return jsonify({'success': False, 'error': 'Failed to generate music'}), 500


@app.route('/generate/extend', methods=['POST'])
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

    success, duration = extend_track(
        source_track_path,
        output_path,
        extend_duration,
        content_prompt,
        style_prompt,
        has_vocals
    )

    if success:
        return jsonify({'success': True, 'message': 'Track extended successfully', 'duration': duration})
    else:
        return jsonify({'success': False, 'error': 'Failed to extend track'}), 500


def convert_to_mp3(wav_path, mp3_path):
    try:
        sound = AudioSegment.from_wav(wav_path)
        sound.export(mp3_path, format="mp3")
        print(f"Converted {wav_path} to {mp3_path}")
    except Exception as e:
        print(f"❌ Fout bij conversie naar mp3: {e}")


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

