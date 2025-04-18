#!/bin/bash

# AI Music Generation System Update Script

# Set color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}      AI Music Generation System - Update Tool              ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
  echo -e "${RED}[ERROR] Docker is not running. Please start Docker first.${NC}"
  exit 1
fi

# Check if the system is running
RUNNING=0
if docker-compose ps | grep -q Up; then
  RUNNING=1
  echo -e "${YELLOW}[INFO] AI Music Generation System is currently running.${NC}"
  read -p "Do you want to stop it for the update? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}[INFO] Stopping AI Music Generation System...${NC}"
    docker-compose down
  else
    echo -e "${RED}[ERROR] Update aborted. System must be stopped for updates.${NC}"
    exit 1
  fi
fi

# Back up user data
echo -e "${YELLOW}[INFO] Backing up user data...${NC}"
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r uploads "$BACKUP_DIR/" 2>/dev/null || true
cp -r output "$BACKUP_DIR/" 2>/dev/null || true
echo -e "${GREEN}[SUCCESS] Backup created in ${BACKUP_DIR}${NC}"

# Voeg DEBIAN_FRONTEND=noninteractive toe aan alle Dockerfiles
echo -e "${YELLOW}[INFO] Updating Dockerfiles with non-interactive mode...${NC}"
for dockerfile in $(find . -name "Dockerfile"); do
  if ! grep -q "DEBIAN_FRONTEND=noninteractive" "$dockerfile"; then
    # Insert after FROM line
    sed -i '/^FROM/a ENV DEBIAN_FRONTEND=noninteractive' "$dockerfile"
    echo -e "${GREEN}[SUCCESS] Updated $dockerfile${NC}"
  fi
done

# Fix torchaudio versie in requirements.txt bestanden
echo -e "${YELLOW}[INFO] Fixing torchaudio version in requirements.txt files...${NC}"
for reqfile in $(find . -name "requirements.txt"); do
  if grep -q "torchaudio" "$reqfile"; then
    sed -i 's/torchaudio==.*/torchaudio==2.0.1/' "$reqfile"
    echo -e "${GREEN}[SUCCESS] Updated torchaudio version in $reqfile${NC}"
  fi
done

# Rebuild containers
echo -e "${YELLOW}[INFO] Rebuilding Docker containers...${NC}"
# Set environment variable for non-interactive builds
export DEBIAN_FRONTEND=noninteractive
docker-compose build

# Restart the system if it was running before
if [ $RUNNING -eq 1 ]; then
  read -p "Do you want to restart the AI Music Generation System now? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}[INFO] Starting AI Music Generation System...${NC}"
    docker-compose up -d
  else
    echo -e "${YELLOW}[INFO] Remember to start the system manually with ./start.sh${NC}"
  fi
fi

echo -e "\n${BLUE}============================================================${NC}"
echo -e "${GREEN}Update completed. System is now up-to-date.${NC}"
echo -e "${BLUE}============================================================${NC}"
