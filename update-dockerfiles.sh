#!/bin/bash

# Set color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}      AI Music Studio - Update Dockerfiles                  ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo

# Find all Dockerfiles
echo -e "${YELLOW}[INFO] Scanning for Dockerfiles...${NC}"
FILES=$(find . -name "Dockerfile")

# Update Dockerfiles
echo -e "${YELLOW}[INFO] Adding DEBIAN_FRONTEND=noninteractive to Dockerfiles...${NC}"
for file in $FILES; do
    echo -e "${YELLOW}[INFO] Processing $file${NC}"

    # Check if DEBIAN_FRONTEND already exists
    if ! grep -q "DEBIAN_FRONTEND=noninteractive" "$file"; then
        # Add after FROM line
        sed -i '/^FROM/a ENV DEBIAN_FRONTEND=noninteractive' "$file"
        echo -e "${GREEN}[SUCCESS] Updated $file${NC}"
    else
        echo -e "${YELLOW}[INFO] DEBIAN_FRONTEND already exists in $file${NC}"
    fi
done

# Update docker-compose.yml
echo -e "${YELLOW}[INFO] Adding DEBIAN_FRONTEND=noninteractive to docker-compose.yml...${NC}"

if [ -f "docker-compose.yml" ]; then
    # Check each service entry and add environment if needed
    SERVICES=$(grep -E '^\s+[a-zA-Z_-]+:' docker-compose.yml | sed 's/://g' | tr -d ' ')

    for service in $SERVICES; do
        # Check if service already has DEBIAN_FRONTEND env var
        if ! grep -A 10 "^  $service:" docker-compose.yml | grep -q "DEBIAN_FRONTEND=noninteractive"; then
            # Check if service already has environment section
            if grep -A 10 "^  $service:" docker-compose.yml | grep -q "environment:"; then
                # Add to existing environment section
                sed -i "/^  $service:/,/^  [a-zA-Z_-]\+:/ s/environment:/environment:\n      - DEBIAN_FRONTEND=noninteractive/" docker-compose.yml
            else
                # Add new environment section
                sed -i "/^  $service:/a\\    environment:\\      - DEBIAN_FRONTEND=noninteractive" docker-compose.yml
            fi
            echo -e "${GREEN}[SUCCESS] Added DEBIAN_FRONTEND to $service in docker-compose.yml${NC}"
        else
            echo -e "${YELLOW}[INFO] $service already has DEBIAN_FRONTEND in docker-compose.yml${NC}"
        fi
    done
else
    echo -e "${RED}[ERROR] docker-compose.yml not found${NC}"
fi

echo -e "\n${BLUE}============================================================${NC}"
echo -e "${GREEN}Dockerfiles updated successfully!${NC}"
echo -e "${YELLOW}You should rebuild the containers with: docker-compose build${NC}"
echo -e "${BLUE}============================================================${NC}"
