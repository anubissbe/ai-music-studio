import os
import gc
import torch
import numpy as np
import soundfile as sf
import librosa
from bark import generate_audio, preload_models, SAMPLE_RATE

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
OUTPUT_FOLDER = '/app/output'
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

models_loaded = False


def load_model_impl():
    """Preload Bark models."""
    global models_loaded
    if models_loaded:
        return True
    try:
        print('Preloading Bark models...')
        preload_models()
        models_loaded = True
        print('Bark models loaded.')
        return True
    except Exception as e:
        print(f'Error loading Bark models: {e}')
        return False


def unload_model_impl():
    """Unload Bark models and clear cache."""
    global models_loaded
    if not models_loaded:
        return True
    try:
        models_loaded = False
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        print('Bark models unloaded.')
        return True
    except Exception as e:
        print(f'Error unloading Bark models: {e}')
        return False


def generate_impl(content_prompt, style_prompt, has_vocals, output_path):
    """Generate audio with Bark."""
    if not models_loaded:
        if not load_model_impl():
            return False, 0.0
    try:
        prompt = content_prompt
        if style_prompt:
            prompt += f' in the style of {style_prompt}'
        if not has_vocals:
            prompt += '. Instrumental only, no vocals.'
        print(f'Generating with Bark: {prompt}')
        wav = generate_audio(prompt)
        sf.write(output_path, wav, samplerate=SAMPLE_RATE)
        duration = librosa.get_duration(y=wav, sr=SAMPLE_RATE)
        return True, duration
    except Exception as e:
        print(f'Error generating Bark audio: {e}')
        return False, 0.0


def extend_impl(source_path, output_path, extend_duration, content_prompt, style_prompt, has_vocals):
    """Extend audio using Bark history_prompt."""
    if not models_loaded:
        if not load_model_impl():
            return False, 0.0
    try:
        original, sr = librosa.load(source_path, sr=SAMPLE_RATE)
        prompt = content_prompt
        if style_prompt:
            prompt += f' in the style of {style_prompt}'
        if not has_vocals:
            prompt += '. Instrumental only, no vocals.'
        prompt += ' Continuation.'
        print(f'Extending with Bark: {prompt}')
        continuation = generate_audio(prompt, history_prompt=[original])
        extended = np.concatenate([original, continuation])
        sf.write(output_path, extended, samplerate=SAMPLE_RATE)
        duration = librosa.get_duration(y=extended, sr=SAMPLE_RATE)
        return True, duration
    except Exception as e:
        print(f'Error extending Bark audio: {e}')
        return False, 0.0


def remix_impl(source_path, output_path, content_prompt, style_prompt, has_vocals):
    """Remix audio with Bark (text-based remix)."""
    if not models_loaded:
        if not load_model_impl():
            return False, 0.0
    try:
        prompt = f'Remix of: {content_prompt}'
        if style_prompt:
            prompt += f' in the style of {style_prompt}'
        if not has_vocals:
            prompt += '. Instrumental only, no vocals.'
        print(f'Remixing with Bark: {prompt}')
        remix = generate_audio(prompt)
        sf.write(output_path, remix, samplerate=SAMPLE_RATE)
        duration = librosa.get_duration(y=remix, sr=SAMPLE_RATE)
        return True, duration
    except Exception as e:
        print(f'Error remixing Bark audio: {e}')
        return False, 0.0

