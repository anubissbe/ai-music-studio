import os
import soundfile as sf
import librosa
import numpy as np
import torch
from audiocraft.models import MusicGen
import gc

# Global model and device setup
model = None
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Constants
OUTPUT_FOLDER = '/app/output'
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

def load_musicgen_model():
    """Load the MusicGen model from Meta AI."""
    global model
    if model is not None:
        return True
    try:
        print("Loading MusicGen model...")
        model = MusicGen.get_pretrained('melody')
        model.set_generation_params(duration=30)  # Default to 30-second clips
        model.to(device)
        print("MusicGen model loaded successfully.")
        return True
    except Exception as e:
        print(f"Error loading MusicGen model: {str(e)}")
        return False

def unload_musicgen_model():
    """Unload the MusicGen model to free up GPU memory."""
    global model
    if model is None:
        return True
    try:
        print("Unloading MusicGen model...")
        model = None
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        print("MusicGen model unloaded successfully.")
        return True
    except Exception as e:
        print(f"Error unloading MusicGen model: {str(e)}")
        return False

def generate_music(content_prompt, style_prompt, has_vocals, output_path):
    """Generate music using the MusicGen model."""
    global model

    if model is None:
        load_musicgen_model()

    try:
        combined_prompt = content_prompt
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"

        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."

        print(f"Generating music with prompt: {combined_prompt}")
        audio_output = model.generate([combined_prompt])
        audio_numpy = audio_output.cpu().numpy()[0, 0]

        # Save to disk
        sf.write(output_path, audio_numpy, samplerate=32000)

        # Get the duration of the generated audio
        duration = librosa.get_duration(y=audio_numpy, sr=32000)

        return True, duration
    except Exception as e:
        print(f"Error generating music: {str(e)}")
        return False, 0

def extend_track(source_track_path, output_path, extend_duration, content_prompt, style_prompt, has_vocals):
    """Extend an existing track by generating more music and concatenating."""
    global model

    if model is None:
        load_musicgen_model()

    try:
        # Load the original track
        original_audio, sr = librosa.load(source_track_path, sr=32000)

        # Combine prompts
        combined_prompt = content_prompt
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"

        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."

        combined_prompt += " Continuation of the previous section, maintain the same style and theme."

        print(f"Extending track with prompt: {combined_prompt}")

        # Generate the additional audio
        model.set_generation_params(duration=extend_duration)
        audio_output = model.generate([combined_prompt])

        # Convert to numpy array
        extension_audio = audio_output.cpu().numpy()[0, 0]

        # Concatenate the original and extension
        extended_audio = np.concatenate([original_audio, extension_audio])

        # Save to disk
        sf.write(output_path, extended_audio, samplerate=32000)

        # Get the duration of the extended audio
        duration = librosa.get_duration(y=extended_audio, sr=32000)

        return True, duration
    except Exception as e:
        print(f"Error extending track: {str(e)}")
        return False, 0

def remix_track(source_track_path, output_path, content_prompt, style_prompt, has_vocals):
    """Remix an existing track using the style and content prompts."""
    global model

    if model is None:
        load_musicgen_model()

    try:
        # Load a small sample of the original track to get its style
        original_audio, sr = librosa.load(source_track_path, sr=32000, duration=10)

        # Combine prompts for the remix
        combined_prompt = f"Remix of: {content_prompt}"
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"

        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."

        print(f"Remixing track with prompt: {combined_prompt}")

        # Generate the remix audio
        model.set_generation_params(duration=30)
        audio_output = model.generate([combined_prompt])

        # Convert to numpy array
        remix_audio = audio_output.cpu().numpy()[0, 0]

        # Save to disk
        sf.write(output_path, remix_audio, samplerate=32000)

        # Get the duration of the remix
        duration = librosa.get_duration(y=remix_audio, sr=32000)

        return True, duration
    except Exception as e:
        print(f"Error remixing track: {str(e)}")
        return False, 0

