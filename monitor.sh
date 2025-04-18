#!/bin/bash

# AI Music Generation System Monitor Script

# Set color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}      AI Music Generation System - Monitoring Tool          ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
  echo -e "${RED}[ERROR] Docker is not running. Please start Docker first.${NC}"
  exit 1
fi

# Check if the docker-compose project is running
if ! docker-compose ps | grep -q Up; then
  echo -e "${RED}[ERROR] AI Music Generation System is not running. Start it with ./start.sh${NC}"
  exit 1
fi

# Display container status
echo -e "${BLUE}Container Status:${NC}"
echo -e "-------------------"
docker-compose ps

# Check GPU status
echo -e "\n${BLUE}GPU Status:${NC}"
echo -e "------------"
if command -v nvidia-smi &> /dev/null; then
  nvidia-smi --query-gpu=index,name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader
else
  echo -e "${YELLOW}[WARNING] nvidia-smi not found. Cannot display GPU status.${NC}"
fi

# Get loaded models
echo -e "\n${BLUE}Loaded AI Models:${NC}"
echo -e "----------------"
MODELS_STATUS=$(curl -s http://localhost:5000/api/models)

if [[ $? -eq 0 && ! -z "$MODELS_STATUS" ]]; then
  # Parse JSON output to display loaded models
  echo "$MODELS_STATUS" | python3 -c "
import json, sys
data = json.load(sys.stdin)
loaded_models = [model for model in data.get('models', []) if model.get('loaded', False)]
if loaded_models:
    for model in loaded_models:
        print(f\"\033[0;32m✓ {model['name']} (ID: {model['id']})\033[0m\")
else:
    print('\033[0;33mNo models are currently loaded\033[0m')
  "
else
  echo -e "${YELLOW}[WARNING] Could not retrieve model status. Backend may not be ready.${NC}"
fi

# Check disk space
echo -e "\n${BLUE}Disk Space:${NC}"
echo -e "-----------"
echo -e "Total Space Used by Docker: $(docker system df --format '{{.Size}}' | head -n 1)"
echo -e "Output Directory: $(du -sh output | cut -f1) ($(find output -type f | wc -l) files)"
echo -e "Uploads Directory: $(du -sh uploads | cut -f1) ($(find uploads -type f | wc -l) files)"

# Get system stats
echo -e "\n${BLUE}System Stats:${NC}"
echo -e "-------------"
echo -e "CPU Usage:
echo -e "CPU Usage: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')%"
echo -e "Memory Usage: $(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')"
echo -e "Swap Usage: $(free -m | awk 'NR==3{printf "%.2f%%", $3*100/$2}')"

# Display API endpoint status
echo -e "\n${BLUE}API Status:${NC}"
echo -e "-----------"
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/models)
if [ "$BACKEND_STATUS" == "200" ]; then
  echo -e "${GREEN}Backend API: OK (${BACKEND_STATUS})${NC}"
else
  echo -e "${RED}Backend API: Error (${BACKEND_STATUS})${NC}"
fi

# Check frontend
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
if [ "$FRONTEND_STATUS" == "200" ]; then
  echo -e "${GREEN}Frontend: OK (${FRONTEND_STATUS})${NC}"
else
  echo -e "${RED}Frontend: Error (${FRONTEND_STATUS})${NC}"
fi

echo -e "\n${BLUE}Last Generated Tracks:${NC}"
echo -e "----------------------"
ls -lt output | head -n 6 | tail -n 5 | awk '{print $9, $6, $7, $8}'

echo -e "\n${BLUE}============================================================${NC}"
echo -e "${GREEN}Monitor completed. System appears to be operational.${NC}"
echo -e "${BLUE}============================================================${NC}"
echo -e "Access the web interface at: ${GREEN}http://localhost:8080${NC}"
echo
