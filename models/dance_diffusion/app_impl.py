import os
import gc
import torch
import numpy as np
import soundfile as sf
import librosa
from diffusers import DanceDiffusionPipeline
from pydub import AudioSegment

# Global pipeline instance
model = None

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
OUTPUT_FOLDER = '/app/output'
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

def load_model_impl():
    """Load the DanceDiffusion pipeline."""
    global model
    if model is not None:
        return True
    try:
        print('Loading DanceDiffusion pipeline...')
        model = DanceDiffusionPipeline.from_pretrained(
            'harmonai/unlocked-250k',
            torch_dtype=torch.float16,
        ).to(device)
        print('DanceDiffusion pipeline loaded.')
        return True
    except Exception as e:
        print(f'Error loading pipeline: {e}')
        return False

def unload_model_impl():
    """Unload the pipeline and clear GPU memory."""
    global model
    if model is None:
        return True
    try:
        model = None
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        print('DanceDiffusion pipeline unloaded.')
        return True
    except Exception as e:
        print(f'Error unloading pipeline: {e}')
        return False

def generate_impl(output_path: str) -> float:
    """Generate a new track."""
    global model
    if model is None:
        if not load_model_impl():
            return 0.0
    try:
        result = model(audio_length_in_s=30.0)
        audio = result.audios[0].cpu().numpy()
        sr = model.unet.sample_rate
        sf.write(output_path, audio, samplerate=sr)
        convert_to_mp3(output_path, output_path.replace(".wav", ".mp3"))
        duration = librosa.get_duration(y=audio, sr=sr)
        print(f'Saved {output_path}, duration={duration:.2f}s')
        return duration
    except Exception as e:
        print(f'Error generating audio: {e}')
        return 0.0

def extend_impl(source_path: str, output_path: str, extend_duration: float) -> float:
    """Extend an existing track by concatenating new audio."""
    global model
    if model is None:
        if not load_model_impl():
            return 0.0
    try:
        original, sr = librosa.load(source_path, sr=model.unet.sample_rate)
        result = model(audio_length_in_s=extend_duration)
        extension = result.audios[0].cpu().numpy()
        combined = np.concatenate([original, extension])
        sf.write(output_path, combined, samplerate=sr)
        convert_to_mp3(output_path, output_path.replace(".wav", ".mp3"))
        duration = librosa.get_duration(y=combined, sr=sr)
        print(f'Extended saved to {output_path}, duration={duration:.2f}s')
        return duration
    except Exception as e:
        print(f'Error extending audio: {e}')
        return 0.0

def remix_impl(source_path: str, output_path: str) -> float:
    """Remix by generating a fresh sample (unconditional)."""
    # Since DanceDiffusion is unconditional, remix == generate
    return generate_impl(output_path)

def convert_to_mp3(wav_path, mp3_path):
    """Converteer WAV-bestand naar MP3."""
    try:
        sound = AudioSegment.from_wav(wav_path)
        sound.export(mp3_path, format="mp3")
        print(f"Converted {wav_path} to {mp3_path}")
    except Exception as e:
        print(f"❌ Fout bij conversie naar mp3: {e}")

