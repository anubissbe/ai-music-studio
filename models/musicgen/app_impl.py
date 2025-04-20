import os
import gc
import torch
import numpy as np
import soundfile as sf
import librosa
from flask import Flask, request, jsonify
from flask_cors import CORS
from audiocraft.models import MusicGen  # Zorg ervoor dat je MusicGen hebt geïmporteerd

# Maak de Flask-app aan
app = Flask(__name__)
CORS(app)

# Global variable to hold the model
model = None
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

OUTPUT_FOLDER = '/app/output'
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

def load_model_impl():
    """Laad het MusicGen model."""
    global model
    if model is not None:
        return True
    try:
        print("Loading MusicGen model...")
        model = MusicGen.get_pretrained('melody')  # Zorg ervoor dat de juiste model wordt geladen
        model.set_generation_params(duration=30)
        print("MusicGen model loaded successfully.")
        return True
    except Exception as e:
        print(f"Error loading MusicGen model: {e}")
        return False

def generate_impl(content_prompt, output_path):
    """Genereer muziek met MusicGen."""
    if model is None:
        load_model_impl()
    try:
        print(f"Generating music with prompt: {content_prompt}")
        audio_output = model.generate([content_prompt])
        audio_numpy = audio_output.cpu().numpy()[0, 0]  # Haal de eerste sample
        sf.write(output_path, audio_numpy, samplerate=32000)
        duration = librosa.get_duration(y=audio_numpy, sr=32000)
        return duration
    except Exception as e:
        print(f"Error generating music: {e}")
        return 0

def remix_impl(source_track_path, output_path, content_prompt, style_prompt, has_vocals):
    """Maak een remix van een track."""
    if model is None:
        load_model_impl()
    try:
        combined_prompt = f"Remix of: {content_prompt}"
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"
        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."
        print(f"Remixing track with prompt: {combined_prompt}")
        audio_output = model.generate([combined_prompt])
        audio_numpy = audio_output.cpu().numpy()[0, 0]
        sf.write(output_path, audio_numpy, samplerate=32000)
        duration = librosa.get_duration(y=audio_numpy, sr=32000)
        return True, duration
    except Exception as e:
        print(f"Error remixing track: {e}")
        return False, 0

def extend_impl(source_track_path, output_path, extend_duration, content_prompt, style_prompt, has_vocals):
    """Verleng een track."""
    if model is None:
        load_model_impl()
    try:
        original_audio, sr = librosa.load(source_track_path, sr=32000)
        combined_prompt = f"{content_prompt} Continuation of the previous section, maintain the same style and theme."
        print(f"Extending track with prompt: {combined_prompt}")
        model.set_generation_params(duration=extend_duration)
        extension_audio = model.generate([combined_prompt]).cpu().numpy()[0, 0]
        extended_audio = np.concatenate([original_audio, extension_audio])
        sf.write(output_path, extended_audio, samplerate=32000)
        duration = librosa.get_duration(y=extended_audio, sr=32000)
        return True, duration
    except Exception as e:
        print(f"Error extending track: {e}")
        return False, 0

