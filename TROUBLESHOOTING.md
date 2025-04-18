# AI Music Generation Studio - Troubleshooting Guide

Dit document helpt bij het oplossen van veelvoorkomende problemen met de AI Music Generation Studio.

## Inhoudsopgave

1. [Docker-gerelateerde problemen](#docker-gerelateerde-problemen)
2. [GPU-gerelateerde problemen](#gpu-gerelateerde-problemen)
3. [Frontend problemen](#frontend-problemen)
4. [Backend problemen](#backend-problemen)
5. [Model-specifieke problemen](#model-specifieke-problemen)
6. [Performance problemen](#performance-problemen)
7. [Audio-gerelateerde problemen](#audio-gerelateerde-problemen)
8. [Dataverlies en herstel](#dataverlies-en-herstel)

## Docker-gerelateerde problemen

### Containers starten niet

**Symptomen**: Containers blijven steken in "Created" status of starten niet.

**Oplossingen**:

1. Controleer of Docker daemon draait:
   ```bash
   sudo systemctl status docker
   ```

2. Controleer Docker logs:
   ```bash
   docker-compose logs
   ```

3. Reset Docker omgeving:
   ```bash
   docker-compose down
   docker system prune -f
   ./start.sh
   ```

### Out of disk space

**Symptomen**: Foutmeldingen over "no space left on device".

**Oplossingen**:

1. Ruim ongebruikte Docker resources op:
   ```bash
   docker system prune -a
   ```

2. Maak ruimte vrij in de output/uploads mappen:
   ```bash
   rm -rf output/*
   rm -rf uploads/*
   ```

3. Vergroot schijfruimte of verplaats Docker naar een andere schijf.

## GPU-gerelateerde problemen

### CUDA-fouten

**Symptomen**: Foutmeldingen over CUDA, "NVIDIA driver not found", etc.

**Oplossingen**:

1. Controleer of NVIDIA drivers correct zijn geïnstalleerd:
   ```bash
   nvidia-smi
   ```

2. Controleer NVIDIA Docker runtime:
   ```bash
   sudo nvidia-ctk runtime configure --runtime=docker
   sudo systemctl restart docker
   ```

3. Controleer of CUDA versies compatibel zijn:
   ```bash
   docker run --rm --gpus all nvidia/cuda:11.7.1-base-ubuntu20.04 nvidia-smi
   ```

### Out of GPU memory

**Symptomen**: CUDA out of memory-fouten of crashes tijdens modelgeneratie.

**Oplossingen**:

1. Pas de configuratie aan om minder GPU-geheugen te gebruiken:
   - Verlaag `memory_percentage` in `config.yml`
   - Stel `memory_allocation` in op "dynamic"

2. Zorg ervoor dat modellen worden ontladen als ze niet worden gebruikt:
   ```bash
   curl -X POST http://localhost:5000/api/models/unload -H "Content-Type: application/json" -d '{"modelId": "NIET_GEBRUIKT_MODEL_ID"}'
   ```

3. Start de systeem opnieuw op om GPU-geheugen vrij te maken:
   ```bash
   docker-compose down
   ./start.sh
   ```

## Frontend problemen

### UI laadt niet

**Symptomen**: Lege pagina, 404-fout, of UI-elementen ontbreken.

**Oplossingen**:

1. Controleer of de frontend-container draait:
   ```bash
   docker-compose ps frontend
   ```

2. Bekijk frontend logs:
   ```bash
   docker-compose logs frontend
   ```

3. Herbouw de frontend-container:
   ```bash
   docker-compose build frontend
   docker-compose up -d frontend
   ```

4. Los cache-problemen op door de browser cache te wissen.

### Kan geen muziek genereren via frontend

**Symptomen**: Klikken op "Generate Music" heeft geen effect.

**Oplossingen**:

1. Controleer de browserconsole (F12) op JavaScript-fouten.

2. Controleer of de backend-API bereikbaar is:
   ```bash
   curl http://localhost:5000/api/models
   ```

3. Controleer of er een model is geselecteerd en geladen.

## Backend problemen

### API is niet bereikbaar

**Symptomen**: 502 Bad Gateway, Connection Refused, of API calls mislukken.

**Oplossingen**:

1. Controleer of de backend-container draait:
   ```bash
   docker-compose ps backend
   ```

2. Bekijk backend logs:
   ```bash
   docker-compose logs backend
   ```

3. Herstart de backend:
   ```bash
   docker-compose restart backend
   ```

### Database-fouten

**Symptomen**: Foutmeldingen over MongoDB-verbinding of -operaties.

**Oplossingen**:

1. Controleer MongoDB-container:
   ```bash
   docker-compose ps mongodb
   ```

2. Bekijk MongoDB logs:
   ```bash
   docker-compose logs mongodb
   ```

3. Reset de database (waarschuwing: dit verwijdert alle gegevens):
   ```bash
   docker-compose down -v
   docker-compose up -d mongodb
   docker-compose up -d
   ```

## Model-specifieke problemen

### MusicGen model laadt niet

**Symptomen**: Foutmeldingen bij laden van MusicGen, of generatie werkt niet.

**Oplossingen**:

1. Bekijk MusicGen logs:
   ```bash
   docker-compose logs musicgen
   ```

2. Herbouw MusicGen container:
   ```bash
   docker-compose build musicgen
   docker-compose up -d musicgen
   ```

3. Controleer of het model correct is gedownload in de container.

### Jukebox model is extreem traag

**Symptomen**: Generatie met Jukebox duurt onredelijk lang.

**Oplossingen**:

1. Dit is normaal gedrag voor Jukebox. Het is een zeer zwaar model.

2. Pas de configuratie aan in `config.yml` om kleinere samples te genereren.

3. Overweeg een ander model te gebruiken voor snellere resultaten.

## Performance problemen

### Trage generatie

**Symptomen**: Generatie van muziek duurt te lang.

**Oplossingen**:

1. Kies een lichter model (MusicGen is sneller dan Jukebox).

2. Verkort de uitgangsduur van gegenereerde muziek in `config.yml`.

3. Controleer GPU-gebruik en -temperatuur:
   ```bash
   ./monitor.sh
   ```

4. Sluit andere GPU-intensieve applicaties.

### Hoog CPU/geheugengebruik

**Symptomen**: Systeem wordt traag of reageert niet meer.

**Oplossingen**:

1. Pas het maximumaantal geladen modellen aan in `config.yml`.

2. Schakel automatisch ontladen van ongebruikte modellen in:
   ```yaml
   # In config.yml
   gpu:
     auto_unload: true
     unload_timeout: 120  # seconden
   ```

3. Herstart het systeem periodiek:
   ```bash
   docker-compose down
   ./start.sh
   ```

## Audio-gerelateerde problemen

### Slechte audiokwaliteit

**Symptomen**: Ruis, klikken, of slechte kwaliteit in gegenereerde audio.

**Oplossingen**:

1. Pas audio-instellingen aan in `config.yml`:
   - Verhoog `sample_rate`
   - Verhoog `output_quality`

2. Probeer andere modellen die bekend staan om betere audiokwaliteit.

3. Zorg ervoor dat normalisatie is ingeschakeld:
   ```yaml
   # In config.yml
   audio:
     normalize: true
     loudness_normalization: true
   ```

### Gegenereerde muziek is te kort

**Symptomen**: Muziek is korter dan verwacht.

**Oplossingen**:

1. Pas de standaardduur aan in model-specifieke instellingen:
   ```yaml
   # In config.yml
   models:
     musicgen:
       duration: 60  # seconden
   ```

2. Gebruik de "Extend" knop in de UI om bestaande tracks te verlengen.

## Dataverlies en herstel

### Gegenereerde muziek verdwijnt

**Symptomen**: Eerder gegenereerde muziek is niet meer beschikbaar.

**Oplossingen**:

1. Controleer de output directory voor bestanden:
   ```bash
   ls -la output/
   ```

2. Controleer de database voor track records:
   ```bash
   docker-compose exec mongodb mongosh music_generation --eval 'db.tracks.find()'
   ```

3. Herstel van de meest recente backup (indien beschikbaar).

### Containers herstartten en verwijderden data

**Symptomen**: Na systeemherstarts zijn gegevens verdwenen.

**Oplossingen**:

1. Zorg ervoor dat volumes correct zijn geconfigureerd in `docker-compose.yml`.

2. Voer regelmatig backups uit:
   ```bash
   ./backup.sh  # indien beschikbaar
   ```

3. In de toekomst, zorg ervoor dat volumes persistent zijn:
   ```yaml
   # In docker-compose.yml
   volumes:
     - ./output:/app/output
     - ./uploads:/app/uploads
     - mongodb-data:/data/db
   ```

## Algemene reset procedure

Als niets anders werkt, voer dan een volledige reset uit:

```bash
# Stop alles
docker-compose down

# Verwijder containers, netwerken, en volumes
docker-compose down -v

# Maak een backup van belangrijke gegevens
tar -czvf music_backup_$(date +%Y%m%d).tar.gz output uploads

# Verwijder alle gegenereerde inhoud
rm -rf output/* uploads/*

# Herbouw en start het systeem
docker-compose build
./start.sh
```
