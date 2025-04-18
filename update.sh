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
cp config.yml "$BACKUP_DIR/" 2>/dev/null || true
echo -e "${GREEN}[SUCCESS] Backup created in ${BACKUP_DIR}${NC}"

# Pull latest changes if it's a git repository
if [ -d .git ]; then
  echo -e "${YELLOW}[INFO] Pulling latest changes from git repository...${NC}"
  git fetch

  LOCAL=$(git rev-parse HEAD)
  REMOTE=$(git rev-parse @{u})

  if [ "$LOCAL" != "$REMOTE" ]; then
    echo -e "${YELLOW}[INFO] Updates available. Pulling changes...${NC}"
    git pull

    # Check for merge conflicts
    if [ $? -ne 0 ]; then
      echo -e "${RED}[ERROR] Git pull failed. Please resolve conflicts manually.${NC}"
      exit 1
    fi

    echo -e "${GREEN}[SUCCESS] Code updated from repository.${NC}"
  else
    echo -e "${GREEN}[INFO] Already up-to-date with the repository.${NC}"
  fi
else
  echo -e "${YELLOW}[INFO] Not a git repository. Skipping code update.${NC}"
fi

# Rebuild containers
echo -e "${YELLOW}[INFO] Rebuilding Docker containers...${NC}"
docker-compose build

# Update model files
echo -e "${YELLOW}[INFO] Checking for model updates...${NC}"
for model in musicgen musicgpt jukebox audioldm riffusion bark musiclm mousai stable_audio dance_diffusion; do
  if [ -f "models/$model/update_model.sh" ]; then
    echo -e "${YELLOW}[INFO] Updating $model...${NC}"
    bash "models/$model/update_model.sh"
  fi
done

# Apply database migrations if needed
if [ -f "backend/migrations/run_migrations.py" ]; then
  echo -e "${YELLOW}[INFO] Applying database migrations...${NC}"
  docker-compose run --rm backend python migrations/run_migrations.py
fi

# Restore user configuration
if [ -f "$BACKUP_DIR/config.yml" ] && [ -f "config.yml" ]; then
  echo -e "${YELLOW}[INFO] Merging user configuration...${NC}"
  python3 -c "
import yaml, sys
try:
    with open('$BACKUP_DIR/config.yml', 'r') as f:
        user_config = yaml.safe_load(f)
    with open('config.yml', 'r') as f:
        new_config = yaml.safe_load(f)

    # Merge configurations while preserving user settings
    def merge_dicts(user_dict, new_dict):
        for k, v in new_dict.items():
            if k in user_dict and isinstance(user_dict[k], dict) and isinstance(v, dict):
                merge_dicts(user_dict[k], v)
            elif k not in user_dict:
                user_dict[k] = v
        return user_dict

    merged_config = merge_dicts(user_config, new_config)

    with open('config.yml', 'w') as f:
        yaml.dump(merged_config, f, default_flow_style=False)

    print('\033[0;32m[SUCCESS] Configuration merged successfully.\033[0m')
except Exception as e:
    print(f'\033[0;31m[ERROR] Failed to merge configurations: {str(e)}\033[0m')
  "
fi

echo -e "${GREEN}[SUCCESS] Update completed successfully.${NC}"

# Restart the system if it was running before
if [ $RUNNING -eq 1 ]; then
  read -p "Do you want to restart the AI Music Generation System now? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}[INFO] Starting AI Music Generation System...${NC}"
    ./start.sh
  else
    echo -e "${YELLOW}[INFO] Remember to start the system manually with ./start.sh${NC}"
  fi
fi

echo -e "\n${BLUE}============================================================${NC}"
echo -e "${GREEN}Update completed. System is now up-to-date.${NC}"
echo -e "${BLUE}============================================================${NC}"
