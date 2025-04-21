# models/mousai/Dockerfile
FROM pytorch/pytorch:1.13.1-cuda11.6-cudnn8-runtime

WORKDIR /app
ENV DEBIAN_FRONTEND=noninteractive

# Systeem afhankelijkheden
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential ffmpeg libsndfile1 git vim \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Maak output directory
RUN mkdir -p /app/output && chmod 777 /app/output

# Upgrade pip
RUN pip install --upgrade pip setuptools wheel

# Installeer numpy 1.23.5 eerst om conflicten te voorkomen
RUN pip install numpy==1.23.5

# App afhankelijkheden
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Installeer specifieke versies van torch en torchaudio
RUN pip install --force-reinstall torch==1.13.1 torchaudio==0.13.1 --index-url https://download.pytorch.org/whl/cu116

# Installeer dependencies met compatibele versies
RUN pip install --no-cache-dir \
    einops==0.6.1 \
    transformers==4.30.2 \
    accelerate==0.20.3 \
    sentencepiece==0.1.99 \
    joblib==1.2.0 \
    numba==0.56.4 \
    packaging==23.1 \
    decorator==5.1.1 \
    av==10.0.0

# Maak models directory voor pre-trained modellen
RUN mkdir -p /app/models

# Installeer Audiocraft vanuit GitHub om zeker te zijn van compatibiliteit
RUN git clone --depth=1 https://github.com/facebookresearch/audiocraft.git /tmp/audiocraft && \
    cd /tmp/audiocraft && \
    pip install -e .

# Installeer huggingface_hub voor model downloads
RUN pip install huggingface_hub

# Download pre-trained MusicGen model (small, omdat het minder geheugen gebruikt)
RUN python -c "from huggingface_hub import snapshot_download; snapshot_download('facebook/musicgen-small', local_dir='/app/models/musicgen-small')"

# Kopieer app code
COPY . .

# Update app_impl.py om lokale modellen te gebruiken
RUN sed -i 's#MusicGen.get_pretrained("small")#MusicGen.get_pretrained("small", "/app/models/musicgen-small")#g' /app/app_impl.py

# Start direct de app
CMD ["python", "/app/app.py"]
