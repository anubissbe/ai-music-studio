#!/bin/bash

# Maak de hoofdstructuur aan
mkdir -p frontend/src/components
mkdir -p frontend/public
mkdir -p backend
mkdir -p models/musicgen models/jukebox models/musicgpt models/audioldm models/riffusion
mkdir -p models/bark models/musiclm models/mousai models/stable_audio models/dance_diffusion
mkdir -p uploads
mkdir -p output

# Kopieer bestanden naar de juiste locaties
echo "Kopiëren van bestanden naar juiste directories..."

# Frontend bestanden
cp Dockerfile frontend/
cp nginx.conf frontend/
cp package.json frontend/
cp tailwind.config.js frontend/
cp -r src frontend/
cp -r public frontend/

# Backend bestanden
cp app.py backend/
cp requirements.txt backend/

# Kopieer model bestanden (als ze bestaan)
if [ -f "models/musicgen/app.py" ]; then
  echo "Model bestanden bestaan al, geen actie nodig."
else
  echo "Kopiëren van model bestanden..."
  for model in musicgen jukebox musicgpt audioldm riffusion bark musiclm mousai stable_audio dance_diffusion; do
    if [ -d "models/$model" ]; then
      # Kopieer Dockerfile, app.py en requirements.txt als ze bestaan
      [ -f "Dockerfile" ] && cp Dockerfile "models/$model/"
      [ -f "app.py" ] && cp app.py "models/$model/"
      [ -f "requirements.txt" ] && cp requirements.txt "models/$model/"
    fi
  done
fi

echo "Directory structuur succesvol opgezet!"
