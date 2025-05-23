import os
import gc
import numpy as np
import soundfile as sf
import librosa
import torch
from pydub import AudioSegment
import logging
import sys

# Configureer logging
logging.basicConfig(level=logging.INFO, 
                    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
logger = logging.getLogger("mousai")
logger.addHandler(logging.StreamHandler(sys.stdout))

# Constanten
OUTPUT_FOLDER = "/app/output"
os.makedirs(OUTPUT_FOLDER, exist_ok=True)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
MODEL_PATH = "/app/models/musicgen-small"

# Global model variable
model = None

# Probeer de echte MusicGen te laden; als het faalt, gebruik de dummy
try:
    logger.info("Proberen AudioCraft te importeren...")
    from audiocraft.models import MusicGen
    USING_REAL_MODEL = True
    logger.info("AudioCraft succesvol geïmporteerd!")
except Exception as e:
    logger.warning(f"Kon AudioCraft niet importeren: {e}. Terugvallen op dummy implementatie.")
    from backup_model import DummyMusicGen as MusicGen
    USING_REAL_MODEL = False
    logger.info("Dummy model geïmporteerd als fallback.")

def load_model_impl():
    """Load Meta's MusicGen model."""
    global model
    if model is not None:
        return True
    try:
        logger.info("Loading MusicGen...")
        if os.path.exists(MODEL_PATH):
            logger.info(f"Gebruik lokaal model op {MODEL_PATH}")
            model = MusicGen.get_pretrained("small", MODEL_PATH)
        else:
            logger.info("Lokaal model niet gevonden, gebruik online model")
            model = MusicGen.get_pretrained("small")
            
        model.to(device)
        model.set_generation_params(duration=30)
        logger.info("MusicGen loaded.")
        return True
    except Exception as e:
        logger.error(f"Error loading MusicGen: {e}")
        import traceback
        logger.error(traceback.format_exc())
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
        logger.info("MusicGen unloaded.")
        return True
    except Exception as e:
        logger.error(f"Error unloading MusicGen: {e}")
        return False


def generate_impl(content_prompt: str, style_prompt: str, has_vocals: bool, output_path: str):
    """Generate new music with MusicGen."""
    global model
    if model is None and not load_model_impl():
        return False, 0.0
    try:
        prompt = content_prompt
        if style_prompt:
            prompt += f" in the style of {style_prompt}"
        if not has_vocals:
            prompt += ". Instrumental only, no vocals."
        logger.info(f"Generating: {prompt}")
        model.set_generation_params(duration=30)
        audio = model.generate([prompt])[0]
        if USING_REAL_MODEL:
            audio_np = audio.cpu().numpy()[0]
        else:
            audio_np = audio[0].numpy() if hasattr(audio[0], "numpy") else audio[0]
        
        sf.write(output_path, audio_np, samplerate=32000)
        try:
            convert_to_mp3(output_path, output_path.replace(".wav", ".mp3"))
        except Exception as mp3_err:
            logger.warning(f"MP3 conversie mislukt: {mp3_err}")
            
        duration = librosa.get_duration(y=audio_np, sr=32000)
        return True, duration
    except Exception as e:
        logger.error(f"Error generating music: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return False, 0.0


def extend_impl(source_path: str, output_path: str, extend_duration: float, content_prompt: str, style_prompt: str, has_vocals: bool):
    """Extend existing track by continuation."""
    global model
    if model is None and not load_model_impl():
        return False, 0.0
    try:
        original, sr = librosa.load(source_path, sr=32000)
        prompt = content_prompt
        if style_prompt:
            prompt += f" in the style of {style_prompt}"
        if not has_vocals:
            prompt += ". Instrumental only, no vocals."
        prompt += " Continuation."
        logger.info(f"Extending: {prompt}")
        model.set_generation_params(duration=extend_duration)
        extension = model.generate([prompt])[0]
        
        if USING_REAL_MODEL:
            extension_np = extension.cpu().numpy()[0]
        else:
            extension_np = extension[0].numpy() if hasattr(extension[0], "numpy") else extension[0]
            
        combined = np.concatenate([original, extension_np])
        sf.write(output_path, combined, samplerate=32000)
        try:
            convert_to_mp3(output_path, output_path.replace(".wav", ".mp3"))
        except Exception as mp3_err:
            logger.warning(f"MP3 conversie mislukt: {mp3_err}")
            
        duration = librosa.get_duration(y=combined, sr=32000)
        return True, duration
    except Exception as e:
        logger.error(f"Error extending: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return False, 0.0


def remix_impl(source_path: str, output_path: str, content_prompt: str, style_prompt: str, has_vocals: bool):
    """Remix by re-generating based on prompt."""
    prompt = f"Remix of: {content_prompt}"
    return generate_impl(prompt, style_prompt, has_vocals, output_path)


def convert_to_mp3(wav_path, mp3_path):
    try:
        sound = AudioSegment.from_wav(wav_path)
        sound.export(mp3_path, format="mp3")
        logger.info(f"Converted {wav_path} to {mp3_path}")
    except Exception as e:
        logger.error(f"❌ Fout bij conversie naar mp3: {e}")
