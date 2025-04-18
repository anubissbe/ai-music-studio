#!/bin/bash

# Set color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Updating all model Dockerfiles to prevent interactive prompts...${NC}"

# Loop over all model directories
for model in musicgen musicgpt jukebox audioldm riffusion bark musiclm mousai stable_audio dance_diffusion; do
  if [ -f "models/$model/Dockerfile" ]; then
    echo -e "Updating ${GREEN}$model${NC} Dockerfile..."
    
    # Replace the RUN apt-get line with the one that includes DEBIAN_FRONTEND=noninteractive
    sed -i 's/# Install system dependencies/# Install system dependencies - using noninteractive to avoid timezone prompts\nENV DEBIAN_FRONTEND=noninteractive/g' "models/$model/Dockerfile"
  fi
done

echo -e "${GREEN}All Dockerfiles updated!${NC}"
echo -e "${YELLOW}Now run:${NC} docker-compose down && docker-compose build && ./start.sh"
