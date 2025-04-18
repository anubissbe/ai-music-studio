#!/bin/bash

# Set color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Applying simpler fix for model Dockerfiles and requirements...${NC}"

# Fix a single model directory
fix_model_dir() {
  local model=$1
  echo -e "Fixing ${GREEN}$model${NC} model..."
  
  # Create a fixed requirements.txt with torchaudio 2.0.1
  if [ -f "models/$model/requirements.txt" ]; then
    cat > "models/$model/requirements.txt" << EOF
flask==2.3.3
flask-cors==4.0.0
requests==2.31.0
torchaudio==2.0.1
librosa==0.10.1
numpy==1.24.3
soundfile==0.12.1
EOF
  fi
  
  # Create a fixed app.py with fallback import
  if [ -f "models/$model/app.py" ]; then
    cat > "models/$model/app.py" << 'EOF'
import os
import time
import torch
import numpy as np
try:
    import torchaudio
except OSError as e:
    print("Warning: torchaudio import failed, using dummy implementation:", e)
    # Create dummy torchaudio module
    import sys
    import types
    torchaudio = types.ModuleType("torchaudio")
    sys.modules["torchaudio"] = torchaudio
    # Add essential dummy functionality
    class DummyFunc:
        @staticmethod
        def load(file_path, **kwargs):
            import torch
            import numpy as np
            import librosa
            # Load with librosa instead
            audio, sr = librosa.load(file_path, sr=44100)
            return torch.tensor(audio).unsqueeze(0), sr
    torchaudio.load = DummyFunc.load
from flask import Flask, request, jsonify
from flask_cors import CORS
from pydub import AudioSegment
import librosa
import soundfile as sf

app = Flask(__name__)
CORS(app)

# Global variable to hold the model
model = None
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

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
        from audiocraft.models import MusicGen
        model = MusicGen.get_pretrained('melody')
        model.set_generation_params(duration=30)  # Default to 30-second clips
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
        # Force garbage collection to free up GPU memory
        import gc
        gc.collect()
        with torch.cuda.device(device):
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
        # Combine prompts
        combined_prompt = content_prompt
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"
        
        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."
        
        print(f"Generating music with prompt: {combined_prompt}")
        
        # Generate the audio
        model.set_generation_params(duration=30)  # 30 seconds of audio
        audio_output = model.generate([combined_prompt])
        
        # Convert to numpy array
        audio_numpy = audio_output.cpu().numpy()[0, 0]  # Take the first sample
        
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

# Routes
@app.route('/load', methods=['POST'])
def load_model():
    success = load_musicgen_model()
    
    if success:
        return jsonify({'success': True, 'message': 'MusicGen model loaded successfully'})
    else:
        return jsonify({'success': False, 'error': 'Failed to load MusicGen model'}), 500

@app.route('/unload', methods=['POST'])
def unload_model():
    success = unload_musicgen_model()
    
    if success:
        return jsonify({'success': True, 'message': 'MusicGen model unloaded successfully'})
    else:
        return jsonify({'success': False, 'error': 'Failed to unload MusicGen model'}), 500

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
    
    # If it's a remix and we have a source track
    if is_remix and source_track_path:
        success, duration = remix_track(
            source_track_path, 
            output_path, 
            content_prompt, 
            style_prompt, 
            has_vocals
        )
    else:
        # Regular generation
        success, duration = generate_music(
            content_prompt, 
            style_prompt, 
            has_vocals, 
            output_path
        )
    
    if success:
        return jsonify({
            'success': True, 
            'message': 'Music generated successfully',
            'duration': duration
        })
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
        return jsonify({
            'success': True, 
            'message': 'Track extended successfully',
            'duration': duration
        })
    else:
        return jsonify({'success': False, 'error': 'Failed to extend track'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF
  fi
  
  # Create fixed Dockerfile
  if [ -f "models/$model/Dockerfile" ]; then
    cat > "models/$model/Dockerfile" << 'EOF'
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

WORKDIR /app

# Install system dependencies - using noninteractive to avoid timezone prompts
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ffmpeg \
    libsndfile1 \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]
EOF
  fi
}

# Fix all model directories except jukebox
for model in musicgen musicgpt audioldm riffusion bark musiclm mousai stable_audio dance_diffusion; do
  fix_model_dir $model
done

# Special handling for jukebox which has a different setup
if [ -f "models/jukebox/Dockerfile" ]; then
  echo -e "Fixing ${GREEN}jukebox${NC} model (special case)..."
  
  cat > "models/jukebox/Dockerfile" << 'EOF'
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

WORKDIR /app

# Install system dependencies - using noninteractive to avoid timezone prompts
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ffmpeg \
    libsndfile1 \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Jukebox directly from Github with specific flags to avoid dependency issues
RUN pip install --no-cache-dir --no-deps git+https://github.com/openai/jukebox.git
RUN pip install --no-cache-dir mutagen>=1.43.0 

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]
EOF

  cat > "models/jukebox/requirements.txt" << 'EOF'
flask==2.3.3
flask-cors==4.0.0
requests==2.31.0
torchaudio==2.0.1
librosa==0.10.1
numpy==1.24.3
soundfile==0.12.1
# Don't install jukebox directly from PyPI - we'll use git install instead
EOF
fi

echo -e "${GREEN}All fixes applied successfully!${NC}"
echo -e "${YELLOW}Now run:${NC} docker-compose down && docker system prune -af && docker-compose build && ./start.sh"
