#!/bin/bash

# Set color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}AI Music Studio - Model Dependencies Fix${NC}"
echo "========================================"

# Voeg pydub toe en fix Flask/Werkzeug versies voor alle modelcontainers
for model in models/*/requirements.txt; do
  echo -e "${GREEN}Updating $model...${NC}"
  
  # Voeg pydub toe als het ontbreekt
  if ! grep -q "pydub" "$model"; then
    echo "pydub==0.25.1" >> "$model"
    echo "  Added pydub==0.25.1"
  fi
  
  # Fix Flask versie
  if grep -q "flask==" "$model"; then
    sed -i 's/flask==.*/flask==2.0.1/' "$model"
    echo "  Updated to flask==2.0.1"
  else
    echo "flask==2.0.1" >> "$model"
    echo "  Added flask==2.0.1"
  fi
  
  # Fix Werkzeug versie
  if grep -q "werkzeug==" "$model"; then
    sed -i 's/werkzeug==.*/werkzeug==2.0.3/' "$model"
    echo "  Updated to werkzeug==2.0.3"
  else
    echo "werkzeug==2.0.3" >> "$model"
    echo "  Added werkzeug==2.0.3"
  fi
done

echo -e "\n${GREEN}All model requirements.txt files updated!${NC}"
echo -e "Now rebuild the containers with: docker-compose build"
echo -e "Then restart with: docker-compose up -d"
