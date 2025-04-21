#!/bin/bash

# Script om alle app_impl.py bestanden aan te passen voor correct paden
# Uitvoeren vanuit /opt/ai-music-studio/

# Kleuren voor output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Start aanpassing van alle model implementaties...${NC}"

# Zorg ervoor dat we in de juiste directory staan
cd /opt/ai-music-studio/

# Array met alle modelnamen
MODELS=("audioldm" "bark" "dance_diffusion" "jukebox" "mousai" "musicgen" "musicgpt" "musiclm" "riffusion" "stable_audio")

# Loop door elk model
for MODEL in "${MODELS[@]}"
do
    echo -e "${YELLOW}Verwerken van model: $MODEL${NC}"
    MODEL_PATH="models/$MODEL/app_impl.py"
    
    # Controleer of het bestand bestaat
    if [ ! -f "$MODEL_PATH" ]; then
        echo -e "${RED}Bestand niet gevonden: $MODEL_PATH${NC}"
        continue
    fi
    
    # Maak een backup
    cp "$MODEL_PATH" "$MODEL_PATH.bak"
    echo "Backup gemaakt: $MODEL_PATH.bak"
    
    # Controleer of OUTPUT_FOLDER al is gedefinieerd
    if ! grep -q "OUTPUT_FOLDER" "$MODEL_PATH"; then
        # Voeg OUTPUT_FOLDER toe na de imports
        sed -i '/^import/,/^$/ s/^\(.*\)$/\1\nOUTPUT_FOLDER = "\/app\/output"\nos.makedirs(OUTPUT_FOLDER, exist_ok=True)\n/1' "$MODEL_PATH"
        echo "OUTPUT_FOLDER toegevoegd aan $MODEL_PATH"
    fi
    
    # Vervang generate_impl functie met het absolute pad patroon
    # Eerst zoeken we naar de functiedefinitie
    if grep -q "def generate_impl" "$MODEL_PATH"; then
        # Voeg code toe om absoluut pad te garanderen
        sed -i '/def generate_impl/,/return/ {
            /def generate_impl/b
            /return/b
            /try:/a\
        # Maak absoluut pad\
        if not os.path.isabs(output_path):\
            full_output_path = os.path.join(OUTPUT_FOLDER, output_path)\
        else:\
            full_output_path = output_path\
        \
        print(f"Will save to: {full_output_path}")\
        \
        # Zorg dat de output directory bestaat\
        os.makedirs(OUTPUT_FOLDER, exist_ok=True)
            s/sf.write(output_path,/sf.write(full_output_path,/g
            s/convert_to_mp3(output_path,/convert_to_mp3(full_output_path,/g
        }' "$MODEL_PATH"
        echo "generate_impl functie aangepast in $MODEL_PATH"
    fi
    
    # Vervang remix_impl functie als die bestaat
    if grep -q "def remix_impl" "$MODEL_PATH"; then
        # Voeg code toe om absoluut pad te garanderen
        sed -i '/def remix_impl/,/return/ {
            /def remix_impl/b
            /return/b
            /try:/a\
        # Maak absoluut pad\
        if not os.path.isabs(output_path):\
            full_output_path = os.path.join(OUTPUT_FOLDER, output_path)\
        else:\
            full_output_path = output_path\
        \
        print(f"Will save to: {full_output_path}")\
        \
        # Zorg dat de output directory bestaat\
        os.makedirs(OUTPUT_FOLDER, exist_ok=True)
            s/sf.write(output_path,/sf.write(full_output_path,/g
            s/convert_to_mp3(output_path,/convert_to_mp3(full_output_path,/g
        }' "$MODEL_PATH"
        echo "remix_impl functie aangepast in $MODEL_PATH"
    fi
    
    # Vervang extend_impl functie als die bestaat
    if grep -q "def extend_impl" "$MODEL_PATH"; then
        # Voeg code toe om absoluut pad te garanderen
        sed -i '/def extend_impl/,/return/ {
            /def extend_impl/b
            /return/b
            /try:/a\
        # Maak absoluut pad\
        if not os.path.isabs(output_path):\
            full_output_path = os.path.join(OUTPUT_FOLDER, output_path)\
        else:\
            full_output_path = output_path\
        \
        print(f"Will save to: {full_output_path}")\
        \
        # Zorg dat de output directory bestaat\
        os.makedirs(OUTPUT_FOLDER, exist_ok=True)
            s/sf.write(output_path,/sf.write(full_output_path,/g
            s/convert_to_mp3(output_path,/convert_to_mp3(full_output_path,/g
        }' "$MODEL_PATH"
        echo "extend_impl functie aangepast in $MODEL_PATH"
    fi
    
    echo -e "${GREEN}Voltooide aanpassing van $MODEL${NC}"
done

# Pas alle app.py bestanden aan om outputPath terug te geven
echo -e "${YELLOW}Nu app.py bestanden aanpassen om outputPath terug te geven...${NC}"

for MODEL in "${MODELS[@]}"
do
    APP_PATH="models/$MODEL/app.py"
    
    # Controleer of het bestand bestaat
    if [ ! -f "$APP_PATH" ]; then
        echo -e "${RED}Bestand niet gevonden: $APP_PATH${NC}"
        continue
    fi
    
    # Maak een backup
    cp "$APP_PATH" "$APP_PATH.bak"
    echo "Backup gemaakt: $APP_PATH.bak"
    
    # Voeg outputPath toe aan de generate route response
    sed -i '/success=True/s/duration=duration)/duration=duration, outputPath=output_path)/g' "$APP_PATH"
    
    echo -e "${GREEN}Voltooide aanpassing van app.py voor $MODEL${NC}"
done

# Pas de backend/app.py aan om het correcte pad te gebruiken
echo -e "${YELLOW}Backend app.py aanpassen...${NC}"
BACKEND_PATH="backend/app.py"

# Controleer of het bestand bestaat
if [ -f "$BACKEND_PATH" ]; then
    # Maak een backup
    cp "$BACKEND_PATH" "$BACKEND_PATH.bak"
    echo "Backup gemaakt: $BACKEND_PATH.bak"
    
    # Vervang het pad in de api_output functie
    sed -i '/def api_output/,/abort(404)/ s/output_dir = .*/output_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..\/output"))/g' "$BACKEND_PATH"
    
    # Voeg outputPath toe aan de response als die niet aanwezig is
    if ! grep -q "if \"outputPath\" not in response_data" "$BACKEND_PATH"; then
        sed -i '/response_data = r.json()/a\
        # Voeg outputPath toe als deze niet aanwezig is in de response\
        if "outputPath" not in response_data and "outputPath" in data:\
            print("Adding missing outputPath to response")\
            response_data["outputPath"] = data["outputPath"]' "$BACKEND_PATH"
    fi
    
    echo -e "${GREEN}Backend app.py aangepast${NC}"
else
    echo -e "${RED}Backend app.py niet gevonden${NC}"
fi

echo -e "${GREEN}Alle aanpassingen voltooid!${NC}"
echo -e "${YELLOW}Vergeet niet de containers opnieuw te starten:${NC}"
echo -e "  docker-compose restart"
