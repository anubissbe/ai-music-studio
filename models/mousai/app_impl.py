import os
import gc
import numpy as np
import soundfile as sf
import librosa
import torch
from audiocraft.models import MusicGen

# Global MusicGen model
model = None

OUTPUT_FOLDER = '/app/output'
if not os.path.isdir(OUTPUT_FOLDER):
    os.makedirs(OUTPUT_FOLDER)

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')


def load_model_impl():
    """Load Meta's MusicGen model."""
    global model
    if model is not None:
        return True
    try:
        print('Loading MusicGen...')
        model = MusicGen.get_pretrained('melody')
        model.to(device)
        model.set_generation_params(duration=30)
        print('MusicGen loaded.')
        return True
    except Exception as e:
        print(f'Error loading MusicGen: {e}')
        return False


def unload_model_impl():
    """Unload MusicGen and clear GPU memory."""
    global model
    if model is None:
        return True
    try:
        model = None
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        print('MusicGen unloaded.')
        return True
    except Exception as e:
        print(f'Error unloading MusicGen: {e}')
        return False


def generate_impl(content_prompt: str, style_prompt: str, has_vocals: bool, output_path: str):
    """Generate new music with MusicGen."""
    global model
    if model is None:
        if not load_model_impl():
            return False, 0.0
    try:
        prompt = content_prompt
        if style_prompt:
            prompt += f' in the style of {style_prompt}'
        if not has_vocals:
            prompt += '. Instrumental only, no vocals.'
        print(f'Generating: {prompt}')
        model.set_generation_params(duration=30)
        audio = model.generate([prompt])[0]
        audio_np = audio.cpu().numpy()[0]
        sf.write(output_path, audio_np, samplerate=32000)
        duration = librosa.get_duration(y=audio_np, sr=32000)
        return True, duration
    except Exception as e:
        print(f'Error generating music: {e}')
        return False, 0.0


def extend_impl(source_path: str, output_path: str, extend_duration: float, content_prompt: str, style_prompt: str, has_vocals: bool):
    """Extend existing track by continuation."""
    if model is None:
        if not load_model_impl():
            return False, 0.0
    try:
        original, sr = librosa.load(source_path, sr=32000)
        prompt = content_prompt
        if style_prompt:
            prompt += f' in the style of {style_prompt}'
        if not has_vocals:
            prompt += '. Instrumental only, no vocals.'
        prompt += ' Continuation.'
        print(f'Extending: {prompt}')
        model.set_generation_params(duration=extend_duration)
        extension = model.generate([prompt])[0].cpu().numpy()[0]
        combined = np.concatenate([original, extension])
        sf.write(output_path, combined, samplerate=32000)
        duration = librosa.get_duration(y=combined, sr=32000)
        return True, duration
    except Exception as e:
        print(f'Error extending: {e}')
        return False, 0.0


def remix_impl(source_path: str, output_path: str, content_prompt: str, style_prompt: str, has_vocals: bool):
    """Remix by re-generating based on prompt."""
    prompt = f'Remix of: {content_prompt}'
    return generate_impl(prompt, style_prompt, has_vocals, output_path)

