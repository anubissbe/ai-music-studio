#!/bin/bash

# AI Music Generation Web App Startup Script

# Set up required directories
mkdir -p uploads models output
mkdir -p models/musicgen models/musicgpt models/jukebox models/audioldm models/riffusion
mkdir -p models/bark models/musiclm models/mousai models/stable_audio models/dance_diffusion

# Copy model files if they don't exist
for model in musicgen musicgpt jukebox audioldm riffusion bark musiclm mousai stable_audio dance_diffusion; do
  if [ ! -f "models/$model/app.py" ]; then
    echo "Setting up $model container..."
    cp models/musicgen/app.py models/$model/app.py 2>/dev/null || :
    cp models/musicgen/requirements.txt models/$model/requirements.txt 2>/dev/null || :
    cp models/musicgen/Dockerfile models/$model/Dockerfile 2>/dev/null || :
  fi
done

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Please start Docker and try again."
  exit 1
fi

# Check if nvidia-docker is installed
if ! command -v nvidia-docker &> /dev/null && ! docker info | grep -q "Runtimes: nvidia"; then
  echo "NVIDIA Docker runtime not detected. Please make sure NVIDIA Docker is installed and configured."
  echo "See: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Check NVIDIA GPU availability
if ! nvidia-smi &> /dev/null; then
  echo "NVIDIA GPUs not detected. Make sure your drivers are installed correctly."
  read -p "Continue anyway (models will be slow without GPU acceleration)? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

echo "Starting AI Music Generation System..."

# Build and start the containers
echo "Building and starting containers (this may take a while for the first run)..."
docker-compose up -d

# Wait for all services to start
echo "Waiting for services to start..."
sleep 10

# Display the service status
docker-compose ps

# Display access information
echo
echo "==================================================================="
echo "  AI Music Generation System is now running!"
echo "==================================================================="
echo
echo "  Access the web interface at: http://localhost:8080"
echo
echo "  To stop the system, run: docker-compose down"
echo
echo "==================================================================="
