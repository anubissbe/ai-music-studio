#!/bin/bash

# Set color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}      AI Music Studio - Fix torchaudio Compatibility        ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo

# Find all requirements.txt files with torchaudio
echo -e "${YELLOW}[INFO] Scanning requirements.txt files...${NC}"
FILES=$(find . -name "requirements.txt" -exec grep -l "torchaudio" {} \;)

# Update torchaudio version
echo -e "${YELLOW}[INFO] Updating torchaudio version to 2.0.1...${NC}"
for file in $FILES; do
    echo -e "${YELLOW}[INFO] Processing $file${NC}"
    # Replace torchaudio version with 2.0.1
    sed -i 's/torchaudio==[0-9]\+\.[0-9]\+\.[0-9]\+/torchaudio==2.0.1/g' "$file"
    echo -e "${GREEN}[SUCCESS] Updated $file${NC}"
done

# Add fallback code to model containers
echo -e "${YELLOW}[INFO] Adding torchaudio fallback code to model containers...${NC}"

# Function to add fallback code
add_fallback_code() {
    local file=$1
    if [ -f "$file" ]; then
        # Check if fallback code already exists
        if ! grep -q "# torchaudio fallback" "$file"; then
            # Add fallback code after imports
            sed -i '/^import torch/a\
# torchaudio fallback\
try:\
    import torchaudio\
except Exception as e:\
    print(f"Warning: torchaudio import failed: {e}")\
    print("Attempting to reinstall torchaudio...")\
    import os\
    os.system("pip uninstall -y torchaudio && pip install torchaudio==2.0.1")\
    import torchaudio' "$file"
            echo -e "${GREEN}[SUCCESS] Added torchaudio fallback to $file${NC}"
        else
            echo -e "${YELLOW}[INFO] Fallback code already exists in $file${NC}"
        fi
    else
        echo -e "${RED}[ERROR] File $file not found${NC}"
    fi
}

# Add fallback code to all model app.py files
for model in models/*/app.py; do
    add_fallback_code "$model"
done

# Update Dockerfiles to reinstall torchaudio
echo -e "${YELLOW}[INFO] Updating Dockerfiles to reinstall torchaudio...${NC}"

for dockerfile in $(find models -name "Dockerfile"); do
    # Check if torchaudio reinstall already exists
    if ! grep -q "pip install torchaudio==2.0.1" "$dockerfile"; then
        # Add torchaudio reinstall before the COPY command
        sed -i '/^COPY \. \./i\
# Explicitly reinstall torchaudio to ensure correct version\
RUN pip uninstall -y torchaudio && pip install torchaudio==2.0.1' "$dockerfile"
        echo -e "${GREEN}[SUCCESS] Updated $dockerfile to reinstall torchaudio${NC}"
    else
        echo -e "${YELLOW}[INFO] torchaudio reinstall already exists in $dockerfile${NC}"
    fi
done

echo -e "\n${BLUE}============================================================${NC}"
echo -e "${GREEN}torchaudio compatibility fixes applied successfully!${NC}"
echo -e "${YELLOW}You should rebuild the containers with: docker-compose build${NC}"
echo -e "${BLUE}============================================================${NC}"
