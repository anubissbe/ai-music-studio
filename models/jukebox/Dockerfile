FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

WORKDIR /app

# Install system dependencies - using noninteractive to avoid timezone prompts
ENV DEBIAN_FRONTEND=noninteractive - using noninteractive to avoid timezone prompts
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
