# AI Music Generation Studio

Een lokale webapplicatie voor het genereren van muziek met verschillende AI-modellen op je Ubuntu 22.04 server met NVIDIA V100 GPU's.

## Functionaliteiten

- 10 verschillende AI-muziekgeneratiemodellen
- Gebruiksvriendelijke web interface
- Intelligent modelbeheer (laden/ontladen naar behoefte)
- Muziekgeneratie op basis van tekstprompts
- Keuze tussen instrumentaal of muziek met zang
- Verlengen van gegenereerde tracks
- Remixen van bestaande muziek
- MP3-upload voor remixen

## Systeemvereisten

- Ubuntu 22.04 of nieuwer
- NVIDIA GPU's met CUDA-ondersteuning (getest op 2x V100 16GB)
- Docker en Docker Compose
- NVIDIA Container Runtime voor Docker
- Minstens 50GB vrije schijfruimte

## Inbegrepen AI-modellen

1. **MusicGen (Meta AI)** - Text-to-music model dat hoogwaardige muziek kan genereren vanuit tekstbeschrijvingen
2. **MusicGPT** - GPT-gebaseerd muziekgeneratiemodel met sterke melodiecompositie
3. **OpenAI Jukebox** - Neuraal netwerk dat muziek genereert met zang in verschillende genres en stijlen
4. **AudioLDM** - Latent diffusion model voor hoogwaardige audiogeneratie vanuit tekst
5. **Riffusion** - Diffusiegebaseerd model dat muziek maakt van tekstprompts met behulp van spectrogrammen
6. **Bark Audio** - Tekstgestuurd audiogeneratiemodel met veelzijdige geluidsproductie
7. **MusicLM** - Genereert hoogwaardige muziek op basis van tekstbeschrijvingen
8. **Moûsai** - Text-to-music model met expressieve geluidssynthesemogelijkheden
9. **Stable Audio** - Hoogwaardige audiogeneratie met precieze stijlbesturing
10. **Dance Diffusion** - Gespecialiseerde elektronische muziekgeneratie met diffusietechnieken

## Installatie

1. Zorg ervoor dat Docker en NVIDIA Container Runtime zijn geïnstalleerd op je systeem:

```bash
# Docker installeren
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# NVIDIA Container Runtime installeren
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

2. Clone deze repository naar je server:

```bash
git clone https://github.com/yourusername/ai-music-studio.git
cd ai-music-studio
```

3. Start het systeem met het meegeleverde script:

```bash
chmod +x start.sh
./start.sh
```

4. Open je webbrowser en ga naar `http://localhost:8080` om de web-interface te gebruiken.

## Gebruik

1. **Selecteer een AI-model** in het zijpaneel. Het model wordt automatisch geladen.
2. **Maak muziek**:
   - Beschrijf waar je muziek over moet gaan
   - Geef de muziekstijl op
   - Kies tussen instrumentaal of met zang
   - Klik op "Generate Music"
3. **Beluister je gegenereerde muziek** in de muziekspeler
4. **Verleng je muziek** door op de "Extend" knop te klikken
5. **Remix bestaande muziek**:
   - Schakel naar "Remix Mode"
   - Upload een MP3-bestand
   - Geef stijlaanwijzingen
   - Klik op "Create Remix"

## Project Structuur

```
ai-music-studio/
│
├── docker-compose.yml       # Docker Compose configuratie
├── start.sh                 # Opstartscript
├── frontend/                # React frontend
├── backend/                 # Flask backend API
│   └── app.py               # Backend code
├── models/                  # AI model containers
│   ├── musicgen/            # MusicGen model
│   ├── musicgpt/            # MusicGPT model
│   └── ...                  # Andere modellen
├── uploads/                 # Map voor geüploade bestanden
└── output/                  # Map voor gegenereerde muziek
```

## Problemen Oplossen

Als je problemen ondervindt met de applicatie, probeer dan het volgende:

- **Controleer of Docker correct draait**: `docker ps` zou alle containers moeten tonen
- **Controleer logs voor fouten**: `docker-compose logs -f`
- **Controleer GPU-gebruik**: `nvidia-smi` geeft GPU-gebruik weer
- **Herstart het systeem**: `docker-compose down && ./start.sh`
- **Verwijder oude data**: `docker-compose down -v && ./start.sh` (waarschuwing: dit verwijdert alle gegenereerde muziek)

## Licentie

Dit project gebruikt verschillende open-source AI-modellen, elk met hun eigen licenties. Zie de respectievelijke model repositories voor details over hun licenties.

De code in deze repository is gelicenseerd onder de MIT-licentie.
