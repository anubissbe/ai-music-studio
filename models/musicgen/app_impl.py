import os
import gc
import torch
import numpy as np
import soundfile as sf
import librosa
from flask import Flask, request, jsonify
from flask_cors import CORS
from audiocraft.models import MusicGen
from pydub import AudioSegment

app = Flask(__name__)
CORS(app)

model = None
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

OUTPUT_FOLDER = '/app/output'
os.makedirs(OUTPUT_FOLDER, exist_ok=True)


def load_model_impl():
    """Laad het MusicGen model."""
    global model
    try:
        if model is not None:
            return True
        print("Loading MusicGen model...")
        model = MusicGen.get_pretrained('melody')
        model.set_generation_params(duration=30)
        print("MusicGen model loaded successfully.")
        return True
    except Exception as e:
        print(f"Error loading MusicGen model: {e}")
        return False


def generate_impl(content_prompt, output_path):
    """Genereer muziek met MusicGen."""
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
            return 0
            
        print(f"Generating music with prompt: {content_prompt}")
        
        print("Generating audio with model...")
        audio_output = model.generate([content_prompt])
        print(f"Generated audio tensor shape: {audio_output.shape}")
        
        print("Converting to NumPy array...")
        audio_numpy = audio_output.cpu().numpy()[0, 0]
        print(f"NumPy array shape: {audio_numpy.shape}, dtype: {audio_numpy.dtype}")
        
        # Probeer verschillende manieren om het bestand op te slaan
        print(f"Writing to WAV file: {full_output_path}")
        try:
            # Methode 1: soundfile
            try:
                sf.write(full_output_path, audio_numpy, samplerate=32000)
                print("File written successfully using soundfile")
            except Exception as sf_error:
                print(f"Error with soundfile: {sf_error}")
                
                # Methode 2: scipy.io.wavfile als fallback
                try:
                    from scipy.io import wavfile
                    wavfile.write(full_output_path, 32000, audio_numpy)
                    print("File written successfully using scipy.io.wavfile")
                except Exception as scipy_error:
                    print(f"Error with scipy.io.wavfile: {scipy_error}")
                    
                    # Methode 3: directe schrijven als fallback
                    try:
                        # Converteer naar 16-bit integers als het samples zijn
                        if audio_numpy.dtype == np.float32 or audio_numpy.dtype == np.float64:
                            audio_numpy = (audio_numpy * 32767).astype(np.int16)
                        
                        with open(full_output_path, 'wb') as f:
                            # Eenvoudige WAV header
                            f.write(b'RIFF')
                            f.write((36 + len(audio_numpy) * 2).to_bytes(4, 'little'))
                            f.write(b'WAVE')
                            f.write(b'fmt ')
                            f.write((16).to_bytes(4, 'little'))
                            f.write((1).to_bytes(2, 'little'))  # PCM
                            f.write((1).to_bytes(2, 'little'))  # Mono
                            f.write((32000).to_bytes(4, 'little'))  # Sample rate
                            f.write((32000 * 2).to_bytes(4, 'little'))  # Byte rate
                            f.write((2).to_bytes(2, 'little'))  # Block align
                            f.write((16).to_bytes(2, 'little'))  # Bits per sample
                            f.write(b'data')
                            f.write((len(audio_numpy) * 2).to_bytes(4, 'little'))
                            # Schrijf audio data
                            f.write(audio_numpy.tobytes())
                        print("File written successfully using manual writing")
                    except Exception as manual_error:
                        print(f"Error with manual writing: {manual_error}")
        except Exception as write_error:
            print(f"Error writing file: {write_error}")
            import traceback
            traceback.print_exc()
        
        # Controleer of het bestand is opgeslagen
        if os.path.exists(full_output_path):
            file_size = os.path.getsize(full_output_path)
            print(f"Successfully saved file to {full_output_path}, size: {file_size} bytes")
            
            # Ook MP3 opslaan
            mp3_path = full_output_path.replace(".wav", ".mp3")
            try:
                convert_to_mp3(full_output_path, mp3_path)
                if os.path.exists(mp3_path):
                    print(f"Successfully converted to MP3: {mp3_path}")
                else:
                    print(f"Failed to convert to MP3")
            except Exception as mp3_error:
                print(f"Error converting to MP3: {mp3_error}")
        else:
            print(f"Failed to save file to {full_output_path}")
            
        # Lijst alle bestanden in de output directory
        print(f"Files in {OUTPUT_FOLDER}:")
        try:
            for file in os.listdir(OUTPUT_FOLDER):
                print(f" - {file}")
        except Exception as ls_error:
            print(f"Error listing files: {ls_error}")
            
        duration = librosa.get_duration(y=audio_numpy, sr=32000)
        return duration
    except Exception as e:
        print(f"Error generating music: {e}")
        import traceback
        traceback.print_exc()
        return 0


def remix_impl(source_track_path, output_path, content_prompt, style_prompt, has_vocals):
    """Maak een remix van een track."""
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
        
        sf.write(full_output_path, audio_numpy, samplerate=32000)
        convert_to_mp3(full_output_path, full_output_path.replace(".wav", ".mp3"))
        
        duration = librosa.get_duration(y=audio_numpy, sr=32000)
        return True, duration
    except Exception as e:
        print(f"Error remixing track: {e}")
        return False, 0

def unload_model_impl():
    """Unload het model en maak geheugen vrij."""
    global model
    try:
        if model is None:
            return True
        model = None
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        print("Model unloaded successfully.")
        return True
    except Exception as e:
        print(f"Error unloading model: {e}")
        return False

def extend_impl(source_track_path, output_path, extend_duration, content_prompt, style_prompt, has_vocals):
    """Verleng een track."""
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
        combined_prompt = f"{content_prompt} Continuation of the previous section, maintain the same style and theme."
        print(f"Extending track with prompt: {combined_prompt}")
        
        model.set_generation_params(duration=extend_duration)
        extension_audio = model.generate([combined_prompt]).cpu().numpy()[0, 0]
        extended_audio = np.concatenate([original_audio, extension_audio])
        
        sf.write(full_output_path, extended_audio, samplerate=32000)
        convert_to_mp3(full_output_path, full_output_path.replace(".wav", ".mp3"))
        
        duration = librosa.get_duration(y=extended_audio, sr=32000)
        return True, duration
    except Exception as e:
        print(f"Error extending track: {e}")
        return False, 0


def convert_to_mp3(wav_path, mp3_path):
    try:
        sound = AudioSegment.from_wav(wav_path)
        sound.export(mp3_path, format="mp3")
        print(f"Converted {wav_path} to {mp3_path}")
    except Exception as e:
        print(f"❌ Fout bij conversie naar mp3: {e}")
