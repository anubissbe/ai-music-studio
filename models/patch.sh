#!/bin/bash

echo "🔧 Herstellen van app_impl.py-bestanden..."

# Basisdirectory
BASE_DIR="/opt/ai-music-studio/models"

# Loop door elke submap
for dir in "$BASE_DIR"/*; do
  file="$dir/app_impl.py"
  if [[ -f "$file" ]]; then
    echo "➡️  Herstellen van: $file"

    # Verwijder losse 'try:' regels zonder except of finally
    sed -i '/^\s*try:\s*$/d' "$file"

    # Voeg convert_to_mp3 functie toe als hij niet bestaat
    if ! grep -q "def convert_to_mp3(" "$file"; then
      cat << 'EOF' >> "$file"

# WAV naar MP3 conversie toevoegen
from pydub import AudioSegment

def convert_to_mp3(wav_path, mp3_path):
    try:
        sound = AudioSegment.from_wav(wav_path)
        sound.export(mp3_path, format="mp3")
        print(f"Converted {wav_path} to {mp3_path}")
    except Exception as e:
        print(f"❌ Fout bij conversie naar mp3: {e}")
EOF
    fi

    # Voeg MP3 export toe na elke regel met output_path = "...wav"
    sed -i '/output_path\s*=\s*.*\.wav.*/a \    convert_to_mp3(output_path, output_path.replace(".wav", ".mp3"))' "$file"
  fi
done

echo "✅ Alle bestanden zijn hersteld."

