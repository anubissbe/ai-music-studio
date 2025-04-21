import soundfile as sf
import librosa
import torch
import numpy as np
from audiocraft.models import MusicGen
import os
import gc
from pydub import AudioSegment

# Global model and device
model = None
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

OUTPUT_FOLDER = '/app/output'
os.makedirs(OUTPUT_FOLDER, exist_ok=True)


def load_model_impl():
    """Laad het MusicLM model."""
    global model
    try:
        if model is not None:
            return True
        print("Loading MusicLM model...")
        model = MusicGen.get_pretrained('melody')
        model.set_generation_params(duration=30)
        print("MusicLM model loaded successfully.")
        return True
    except Exception as e:
        print(f"Error loading MusicLM model: {str(e)}")
        return False


def unload_model_impl():
    """Unload het MusicLM model."""
    global model
    try:
        if model is None:
            return True
        print("Unloading MusicLM model...")
        model = None
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        print("MusicLM model unloaded successfully.")
        return True
    except Exception as e:
        print(f"Error unloading MusicLM model: {str(e)}")
        return False


def generate_impl(content_prompt, output_path):
    """Genereer muziek met MusicLM."""
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
        if model is None and not load_model_impl():
            return False, 0

        print(f"Generating music with prompt: {content_prompt}")
        audio_output = model.generate([content_prompt])
        audio_numpy = audio_output.cpu().numpy()[0, 0]
        sf.write(output_path, audio_numpy, samplerate=32000)
        convert_to_mp3(output_path, output_path.replace(".wav", ".mp3"))
        duration = librosa.get_duration(y=audio_numpy, sr=32000)
        return True, duration
    except Exception as e:
        print(f"Error generating music: {str(e)}")
        return False, 0


def extend_impl(source_track_path, output_path, extend_duration, content_prompt, style_prompt, has_vocals):
    """Verleng een track met MusicLM."""
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
        if model is None and not load_model_impl():
            return False, 0

        original_audio, sr = librosa.load(source_track_path, sr=32000)
        combined_prompt = content_prompt + " Continuation of the previous section, maintain the same style and theme."
        print(f"Extending track with prompt: {combined_prompt}")
        model.set_generation_params(duration=extend_duration)
        extension_audio = model.generate([combined_prompt]).cpu().numpy()[0, 0]
        extended_audio = np.concatenate([original_audio, extension_audio])
        sf.write(output_path, extended_audio, samplerate=32000)
        convert_to_mp3(output_path, output_path.replace(".wav", ".mp3"))
        duration = librosa.get_duration(y=extended_audio, sr=32000)
        return True, duration
    except Exception as e:
        print(f"Error extending track: {str(e)}")
        return False, 0


def remix_impl(source_track_path, output_path, content_prompt, style_prompt, has_vocals):
    """Maak een remix van een bestaande track met MusicLM."""
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
        if model is None and not load_model_impl():
            return False, 0

        combined_prompt = f"Remix of: {content_prompt}"
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"
        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."

        print(f"Remixing track with prompt: {combined_prompt}")
        audio_output = model.generate([combined_prompt])
        audio_numpy = audio_output.cpu().numpy()[0, 0]
        sf.write(output_path, audio_numpy, samplerate=32000)
        convert_to_mp3(output_path, output_path.replace(".wav", ".mp3"))
        duration = librosa.get_duration(y=audio_numpy, sr=32000)
        return True, duration
    except Exception as e:
        print(f"Error remixing track: {str(e)}")
        return False, 0


def convert_to_mp3(wav_path, mp3_path):
    try:
        sound = AudioSegment.from_wav(wav_path)
        sound.export(mp3_path, format="mp3")
        print(f"Converted {wav_path} to {mp3_path}")
    except Exception as e:
        print(f"❌ Fout bij conversie naar mp3: {e}")

