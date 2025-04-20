FROM pytorch/pytorch:2.1.0-cuda11.8-cudnn8-runtime

WORKDIR /app

# Voorkom interactieve prompts
ENV DEBIAN_FRONTEND=noninteractive

# System‑dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ffmpeg \
    libsndfile1 \
    git \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Python‑dependencies
COPY requirements.txt .
# Force upgrade torch for float8 and compatibility
RUN pip install --no-cache-dir torch==2.1.0+cu118 torchaudio==2.1.0 --extra-index-url https://download.pytorch.org/whl/cu118
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

EXPOSE 5000
CMD ["python", "app.py"]

