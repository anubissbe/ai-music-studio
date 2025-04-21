import os
import sys
import importlib.util

print("=" * 50)
print("MOUSAI CONTAINER TEST SETUP")
print("=" * 50)
print(f"Python version: {sys.version}")

# Controleer CUDA
try:
    import torch
    print(f"\nPyTorch versie: {torch.__version__}")
    print(f"CUDA beschikbaar: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        print(f"CUDA versie: {torch.version.cuda}")
        print(f"CUDA device: {torch.cuda.get_device_name(0)}")
except Exception as e:
    print(f"Fout bij PyTorch check: {e}")

# Controleer torchaudio
try:
    import torchaudio
    print(f"\nTorchaudio versie: {torchaudio.__version__}")
except Exception as e:
    print(f"Fout bij torchaudio check: {e}")

# Controleer numpy
try:
    import numpy
    print(f"\nNumpy versie: {numpy.__version__}")
except Exception as e:
    print(f"Fout bij numpy check: {e}")

# Controleer of audiocraft bestaat
print("\nAudioCraft check:")
try:
    spec = importlib.util.find_spec("audiocraft")
    if spec is not None:
        import audiocraft
        if hasattr(audiocraft, "__version__"):
            print(f"AudioCraft versie: {audiocraft.__version__}")
        else:
            print("AudioCraft geïmporteerd maar geen versie gevonden")
        
        # Probeer MusicGen te importeren
        try:
            from audiocraft.models import MusicGen
            print("MusicGen class succesvol geïmporteerd")
        except Exception as e:
            print(f"Fout bij MusicGen import: {e}")
    else:
        print("AudioCraft module niet gevonden")
except Exception as e:
    print(f"Fout bij AudioCraft check: {e}")

# Controleer backup model
print("\nBackup model check:")
try:
    from backup_model import DummyMusicGen
    print("Backup model succesvol geïmporteerd")
except Exception as e:
    print(f"Fout bij backup model check: {e}")

# Controleer app_impl
print("\napp_impl check:")
try:
    import app_impl
    print("app_impl succesvol geïmporteerd")
    print(f"Wordt de echte MusicGen gebruikt? {app_impl.USING_REAL_MODEL}")
except Exception as e:
    print(f"Fout bij app_impl check: {e}")

print("\nTest voltooid!")
print("=" * 50)
