# models/mousai/Dockerfile
FROM pytorch/pytorch:2.1.0-cuda11.8-cudnn8-runtime

WORKDIR /app

# Voorkom interactieve prompts
ENV DEBIAN_FRONTEND=noninteractive

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ffmpeg \
    libsndfile1 \
    git \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Python dependencies
COPY requirements.txt .
# Install PyTorch & torchaudio with matching CUDA support
RUN pip install --no-cache-dir torch==2.1.0+cu118 torchaudio==2.1.0+cu118 --extra-index-url https://download.pytorch.org/whl/cu118
# Install remaining dependencies (which may include xformers transitively)
RUN pip install --no-cache-dir -r requirements.txt
# Uninstall xformers to silence warnings
RUN pip install -y xformers || true

# Copy application code
COPY . .

EXPOSE 5000 
CMD ["python", "app.py"]
