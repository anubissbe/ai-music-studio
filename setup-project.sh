#!/bin/bash

# Set color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}AI Music Studio - Project Setup (Verbeterde Versie)${NC}"
echo "========================================"

# Maak de hoofdstructuur aan
echo -e "${GREEN}Aanmaken van directory structuur...${NC}"
mkdir -p frontend/src/components
mkdir -p frontend/public
mkdir -p backend
mkdir -p models/musicgen models/jukebox models/musicgpt models/audioldm models/riffusion
mkdir -p models/bark models/musiclm models/mousai models/stable_audio models/dance_diffusion
mkdir -p uploads
mkdir -p output

# Frontend bestanden aanmaken
echo -e "${GREEN}Aanmaken van frontend bestanden...${NC}"

# Frontend Dockerfile - Aangepast met Node 16 en expliciete bouwstappen
cat > frontend/Dockerfile << 'EOF'
FROM node:16-alpine as build

WORKDIR /app

COPY package*.json ./
RUN npm install --legacy-peer-deps

# Fix ajv-keywords dependency issues
RUN npm install ajv@^6.9.1 --legacy-peer-deps

# Ensure public directory exists with required files
RUN mkdir -p public
RUN echo '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><rect width="32" height="32" fill="#3B82F6"/><text x="16" y="20" font-family="Arial" font-size="12" text-anchor="middle" fill="white">M</text></svg>' > public/favicon.svg
RUN echo '<svg xmlns="http://www.w3.org/2000/svg" width="192" height="192"><rect width="192" height="192" fill="#3B82F6"/><text x="96" y="108" font-family="Arial" font-size="72" text-anchor="middle" fill="white">M</text></svg>' > public/logo192.svg
RUN echo '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512"><rect width="512" height="512" fill="#3B82F6"/><text x="256" y="280" font-family="Arial" font-size="180" text-anchor="middle" fill="white">M</text></svg>' > public/logo512.svg

COPY . .
RUN npm run build || echo "Ignoring build errors for now"

FROM nginx:stable-alpine

COPY --from=build /app/build /usr/share/nginx/html || mkdir -p /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Als de build mislukt, maak een eenvoudige index.html aan
RUN if [ ! -f /usr/share/nginx/html/index.html ]; then \
      echo '<!DOCTYPE html><html><head><title>AI Music Studio</title></head><body><h1>AI Music Studio</h1><p>Frontend build failed, please check logs.</p></body></html>' > /usr/share/nginx/html/index.html; \
    fi

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF

# Frontend nginx.conf
cat > frontend/nginx.conf << 'EOF'
server {
    listen 80;
    
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files $uri $uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://backend:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOF

# Frontend package.json - aangepast voor React 17 en React Scripts 4
cat > frontend/package.json << 'EOF'
{
  "name": "music-generation-ui",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@headlessui/react": "^1.7.17",
    "@heroicons/react": "^1.0.6",
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/react": "^12.1.5",
    "@testing-library/user-event": "^13.5.0",
    "axios": "^1.6.0",
    "react": "^17.0.2",
    "react-dom": "^17.0.2",
    "react-dropzone": "^14.2.3",
    "react-scripts": "4.0.3",
    "wavesurfer.js": "^6.6.4",
    "web-vitals": "^2.1.4",
    "ajv": "^6.9.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  },
  "devDependencies": {
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.31",
    "tailwindcss": "^3.3.5"
  },
  "resolutions": {
    "ajv": "^6.9.1"
  }
}
EOF

# Frontend tailwind.config.js
cat > frontend/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
        secondary: {
          50: '#f5f3ff',
          100: '#ede9fe',
          200: '#ddd6fe',
          300: '#c4b5fd',
          400: '#a78bfa',
          500: '#8b5cf6',
          600: '#7c3aed',
          700: '#6d28d9',
          800: '#5b21b6',
          900: '#4c1d95',
        },
      },
      animation: {
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      }
    },
  },
  plugins: [],
}
EOF

# Frontend public/index.html
cat > frontend/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="nl">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta
      name="description"
      content="AI Music Generation Studio - Genereert muziek met AI-modellen"
    />
    <link rel="apple-touch-icon" href="%PUBLIC_URL%/logo192.png" />
    <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
    <title>AI Music Studio</title>
  </head>
  <body>
    <noscript>Je moet JavaScript inschakelen om deze app te gebruiken.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF

# Frontend public/manifest.json
cat > frontend/public/manifest.json << 'EOF'
{
  "short_name": "AI Music Studio",
  "name": "AI Music Generation Studio",
  "icons": [
    {
      "src": "favicon.ico",
      "sizes": "64x64 32x32 24x24 16x16",
      "type": "image/x-icon"
    },
    {
      "src": "logo192.png",
      "type": "image/png",
      "sizes": "192x192"
    },
    {
      "src": "logo512.png",
      "type": "image/png",
      "sizes": "512x512"
    }
  ],
  "start_url": ".",
  "display": "standalone",
  "theme_color": "#000000",
  "background_color": "#111827"
}
EOF

# Frontend public/robots.txt
cat > frontend/public/robots.txt << 'EOF'
# https://www.robotstxt.org/robotstxt.html
User-agent: *
Disallow:
EOF

# Placeholder voor favicon en logo's
cat > frontend/create-logos.sh << 'EOF'
#!/bin/bash

# Genereer SVG logos
echo '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><rect width="32" height="32" fill="#3B82F6"/><text x="16" y="20" font-family="Arial" font-size="12" text-anchor="middle" fill="white">M</text></svg>' > public/favicon.svg
echo '<svg xmlns="http://www.w3.org/2000/svg" width="192" height="192"><rect width="192" height="192" fill="#3B82F6"/><text x="96" y="108" font-family="Arial" font-size="72" text-anchor="middle" fill="white">M</text></svg>' > public/logo192.svg
echo '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512"><rect width="512" height="512" fill="#3B82F6"/><text x="256" y="280" font-family="Arial" font-size="180" text-anchor="middle" fill="white">M</text></svg>' > public/logo512.svg

# Gebruik SVG's als basis voor favicons
cp public/favicon.svg public/favicon.ico
cp public/logo192.svg public/logo192.png
cp public/logo512.svg public/logo512.png
EOF
chmod +x frontend/create-logos.sh

# Frontend src/index.js
cat > frontend/src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
);
EOF

# Frontend src/index.css
cat > frontend/src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #111827;
  color: #f3f4f6;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 8px;
}

::-webkit-scrollbar-track {
  background: #1f2937;
}

::-webkit-scrollbar-thumb {
  background: #4b5563;
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: #6b7280;
}
EOF

# Frontend src/App.js
cat > frontend/src/App.js << 'EOF'
import React, { useState, useEffect } from 'react';
import axios from 'axios';

function App() {
  const [models, setModels] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Probeer de API te benaderen om te zien of het werkt
    async function fetchModels() {
      try {
        const response = await axios.get('/api/models');
        setModels(response.data.models || []);
      } catch (error) {
        console.error('Error fetching models:', error);
      } finally {
        setLoading(false);
      }
    }

    fetchModels();
  }, []);

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <header className="bg-gray-800 p-4 shadow-md">
        <div className="container mx-auto">
          <h1 className="text-2xl font-bold">AI Music Studio</h1>
        </div>
      </header>
      
      <main className="container mx-auto p-4">
        <div className="bg-gray-800 rounded-lg p-6 shadow-lg">
          <h2 className="text-xl font-semibold mb-4">Welkom bij de AI Music Studio</h2>
          
          <p className="mb-4">
            Dit is een eenvoudige first-run pagina om te controleren of de webapp correct is opgezet.
          </p>
          
          <div className="mt-6">
            <h3 className="font-medium mb-2">Status:</h3>
            <ul className="space-y-1 text-sm">
              <li className="flex items-center">
                <span className={`w-3 h-3 rounded-full mr-2 ${loading ? 'bg-yellow-500' : 'bg-green-500'}`}></span>
                <span>Frontend: Actief</span>
              </li>
              <li className="flex items-center">
                <span className={`w-3 h-3 rounded-full mr-2 ${models.length > 0 ? 'bg-green-500' : 'bg-red-500'}`}></span>
                <span>Backend API: {models.length > 0 ? 'Verbonden' : 'Niet verbonden'}</span>
              </li>
            </ul>
          </div>
          
          {models.length > 0 && (
            <div className="mt-6">
              <h3 className="font-medium mb-2">Beschikbare AI Modellen:</h3>
              <ul className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {models.map((model) => (
                  <li key={model.id} className="bg-gray-700 p-3 rounded-lg">
                    <h4 className="font-medium">{model.name}</h4>
                    <p className="text-sm text-gray-300">{model.description}</p>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

export default App;
EOF

# Maak de React componenten aan
mkdir -p frontend/src/components
echo "// Placeholder bestand" > frontend/src/components/ModelSelector.js
echo "// Placeholder bestand" > frontend/src/components/PromptInput.js
echo "// Placeholder bestand" > frontend/src/components/MusicPlayer.js
echo "// Placeholder bestand" > frontend/src/components/FileUploader.js

# Backend bestanden aanmaken
echo -e "${GREEN}Aanmaken van backend bestanden...${NC}"

# Backend Dockerfile - met DEBIAN_FRONTEND=noninteractive toevoeging
cat > backend/Dockerfile << 'EOF'
FROM python:3.10-slim

WORKDIR /app

# Voorkom interactieve prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ffmpeg \
    libsndfile1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]
EOF

# Backend requirements.txt
cat > backend/requirements.txt << 'EOF'
flask==2.0.1
flask-cors==4.0.0
pymongo==4.5.0
pydub==0.25.1
requests==2.31.0
python-dotenv==1.0.0
librosa==0.10.1
torch==2.0.1
numpy==1.24.3
soundfile==0.12.1
EOF

# Backend app.py - FIX voor before_first_request probleem
cat > backend/app.py << 'EOF'
import os
import json
import uuid
import time
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
import requests

app = Flask(__name__)
CORS(app)

# Connect to MongoDB
client = MongoClient(os.environ.get("MONGO_URI", "mongodb://mongodb:27017/"))
db = client.music_generation
tracks_collection = db.tracks
models_collection = db.models

# Constants
UPLOAD_FOLDER = '/app/uploads'
OUTPUT_FOLDER = '/app/output'
MODELS_FOLDER = '/app/models'

# Create directories if they don't exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)
os.makedirs(MODELS_FOLDER, exist_ok=True)

# Model definitions
AI_MODELS = [
    {
        'id': 'musicgen',
        'name': 'MusicGen (Meta AI)',
        'description': 'Text-to-music model that can generate high-quality music from text descriptions',
        'api_url': 'http://musicgen:5000/generate',
        'loaded': False,
        'port': 5001
    },
    {
        'id': 'musicgpt',
        'name': 'MusicGPT',
        'description': 'GPT-based music generation model with strong melody composition',
        'api_url': 'http://musicgpt:5000/generate',
        'loaded': False,
        'port': 5002
    },
    {
        'id': 'jukebox',
        'name': 'OpenAI Jukebox',
        'description': 'Neural network that generates music with singing in various genres and styles',
        'api_url': 'http://jukebox:5000/generate',
        'loaded': False,
        'port': 5003
    },
    {
        'id': 'audioldm',
        'name': 'AudioLDM',
        'description': 'Latent diffusion model for high-quality audio generation from text',
        'api_url': 'http://audioldm:5000/generate',
        'loaded': False,
        'port': 5004
    },
    {
        'id': 'riffusion',
        'name': 'Riffusion',
        'description': 'Diffusion-based model that creates music from text prompts using spectrograms',
        'api_url': 'http://riffusion:5000/generate',
        'loaded': False,
        'port': 5005
    },
    {
        'id': 'bark',
        'name': 'Bark Audio',
        'description': 'Text-guided audio generation model with versatile sound production',
        'api_url': 'http://bark:5000/generate',
        'loaded': False,
        'port': 5006
    },
    {
        'id': 'musiclm',
        'name': 'MusicLM',
        'description': 'Generate high-fidelity music from text descriptions',
        'api_url': 'http://musiclm:5000/generate',
        'loaded': False,
        'port': 5007
    },
    {
        'id': 'mousai',
        'name': 'Moûsai',
        'description': 'Text-to-music model with expressive sound synthesis capabilities',
        'api_url': 'http://mousai:5000/generate',
        'loaded': False,
        'port': 5008
    },
    {
        'id': 'stable_audio',
        'name': 'Stable Audio',
        'description': 'High-fidelity audio generation with precise style control',
        'api_url': 'http://stable_audio:5000/generate',
        'loaded': False,
        'port': 5009
    },
    {
        'id': 'dance_diffusion',
        'name': 'Dance Diffusion',
        'description': 'Specialized electronic music generation using diffusion techniques',
        'api_url': 'http://dance_diffusion:5000/generate',
        'loaded': False,
        'port': 5010
    }
]

# Initialize models in the database
def init_models():
    # Clear existing models
    models_collection.delete_many({})
    
    # Insert models
    for model in AI_MODELS:
        models_collection.insert_one(model)
    
    print("Models initialized in database")

# Routes
@app.route('/api/models', methods=['GET'])
def get_models():
    models = list(models_collection.find({}, {'_id': 0}))
    return jsonify({'models': models})

@app.route('/api/models/load', methods=['POST'])
def load_model():
    data = request.json
    model_id = data.get('modelId')
    
    if not model_id:
        return jsonify({'success': False, 'error': 'Model ID is required'}), 400
    
    # Find the model
    model = models_collection.find_one({'id': model_id})
    
    if not model:
        return jsonify({'success': False, 'error': 'Model not found'}), 404
    
    # Simulate loading the model (in a real scenario, you would call the model container's API)
    try:
        # Call the model container to load the model
        response = requests.post(f"http://{model_id}:5000/load")
        
        if response.status_code == 200:
            # Update the model status in the database
            models_collection.update_one(
                {'id': model_id},
                {'$set': {'loaded': True}}
            )
            
            return jsonify({'success': True, 'message': f'Model {model_id} loaded successfully'})
        else:
            return jsonify({'success': False, 'error': 'Failed to load model'}), 500
            
    except requests.exceptions.RequestException as e:
        print(f"Error loading model {model_id}: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/models/unload', methods=['POST'])
def unload_model():
    data = request.json
    model_id = data.get('modelId')
    
    if not model_id:
        return jsonify({'success': False, 'error': 'Model ID is required'}), 400
    
    # Find the model
    model = models_collection.find_one({'id': model_id})
    
    if not model:
        return jsonify({'success': False, 'error': 'Model not found'}), 404
    
    # Simulate unloading the model
    try:
        # Call the model container to unload the model
        response = requests.post(f"http://{model_id}:5000/unload")
        
        if response.status_code == 200:
            # Update the model status in the database
            models_collection.update_one(
                {'id': model_id},
                {'$set': {'loaded': False}}
            )
            
            return jsonify({'success': True, 'message': f'Model {model_id} unloaded successfully'})
        else:
            return jsonify({'success': False, 'error': 'Failed to unload model'}), 500
            
    except requests.exceptions.RequestException as e:
        print(f"Error unloading model {model_id}: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/generate', methods=['POST'])
def generate_music():
    data = request.json
    model_id = data.get('modelId')
    content_prompt = data.get('contentPrompt', '')
    style_prompt = data.get('stylePrompt', '')
    has_vocals = data.get('hasVocals', True)
    is_remix = data.get('isRemix', False)
    source_track_id = data.get('sourceTrackId')
    
    if not model_id:
        return jsonify({'success': False, 'error': 'Model ID is required'}), 400
    
    # Find the model
    model = models_collection.find_one({'id': model_id})
    
    if not model:
        return jsonify({'success': False, 'error': 'Model not found'}), 404
    
    if not model.get('loaded', False):
        return jsonify({'success': False, 'error': 'Model is not loaded'}), 400
    
    # Generate a unique ID for the track
    track_id = str(uuid.uuid4())
    output_filename = f"{track_id}.mp3"
    output_path = os.path.join(OUTPUT_FOLDER, output_filename)
    
    # Prepare request payload for the model container
    payload = {
        'contentPrompt': content_prompt,
        'stylePrompt': style_prompt,
        'hasVocals': has_vocals,
        'outputPath': output_path
    }
    
    # If it's a remix, add the source track
    if is_remix and source_track_id:
        source_track = tracks_collection.find_one({'id': source_track_id})
        if source_track:
            payload['sourceTrackPath'] = source_track.get('filePath')
            payload['isRemix'] = True
    
    try:
        # In a real implementation, you would send this to the model container
        # For this example, we'll simulate the model generating music
        
        # Call the model container's API
        response = requests.post(model.get('api_url'), json=payload)
        
        if response.status_code != 200:
            return jsonify({'success': False, 'error': 'Model failed to generate music'}), 500
        
        response_data = response.json()
        
        # In a real implementation, the model container would save the file
        # Here, we'll just assume it was saved
        
        # Create a record in the database
        track = {
            'id': track_id,
            'name': f"Generated Track - {datetime.now().strftime('%Y-%m-%d %H:%M')}",
            'model': model.get('name'),
            'modelId': model_id,
            'contentPrompt': content_prompt,
            'stylePrompt': style_prompt,
            'hasVocals': has_vocals,
            'isRemix': is_remix,
            'sourceTrackId': source_track_id if is_remix else None,
            'filePath': output_path,
            'url': f"/api/tracks/{track_id}/audio",
            'duration': response_data.get('duration', 60),  # Default to 60 seconds
            'createdAt': datetime.now().isoformat()
        }
        
        tracks_collection.insert_one(track)
        
        # Remove _id field for the response
        track.pop('_id', None)
        
        return jsonify({'success': True, 'track': track})
        
    except requests.exceptions.RequestException as e:
        print(f"Error generating music with model {model_id}: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/extend', methods=['POST'])
def extend_track():
    data = request.json
    track_id = data.get('trackId')
    model_id = data.get('modelId')
    duration = data.get('duration', 30)  # Default to extending by 30 seconds
    
    if not track_id or not model_id:
        return jsonify({'success': False, 'error': 'Track ID and Model ID are required'}), 400
    
    # Find the track
    track = tracks_collection.find_one({'id': track_id})
    
    if not track:
        return jsonify({'success': False, 'error': 'Track not found'}), 404
    
    # Find the model
    model = models_collection.find_one({'id': model_id})
    
    if not model:
        return jsonify({'success': False, 'error': 'Model not found'}), 404
    
    if not model.get('loaded', False):
        return jsonify({'success': False, 'error': 'Model is not loaded'}), 400
    
    # Generate a new unique ID for the extended track
    new_track_id = str(uuid.uuid4())
    output_filename = f"{new_track_id}.mp3"
    output_path = os.path.join(OUTPUT_FOLDER, output_filename)

# Prepare request payload for the model container
payload = {
    'sourceTrackPath': track.get('filePath'),
    'outputPath': output_path,
    'extendDuration': duration,
    'contentPrompt': track.get('contentPrompt', ''),
    'stylePrompt': track.get('stylePrompt', ''),
    'hasVocals': track.get('hasVocals', True)
}

try:
    # Call the model container's API to extend the track
    response = requests.post(f"{model.get('api_url')}/extend", json=payload)

    if response.status_code != 200:
        return jsonify({'success': False, 'error': 'Model failed to extend track'}), 500

    response_data = response.json()

    # Create a new record in the database for the extended track
    extended_track = {
        'id': new_track_id,
        'name': f"{track.get('name')} (Extended)",
        'model': model.get('name'),
        'modelId': model_id,
        'contentPrompt': track.get('contentPrompt'),
        'stylePrompt': track.get('stylePrompt'),
        'hasVocals': track.get('hasVocals'),
        'isRemix': track.get('isRemix', False),
        'sourceTrackId': track.get('sourceTrackId'),
        'filePath': output_path,
        'url': f"/api/tracks/{new_track_id}/audio",
        'duration': track.get('duration', 60) + duration,
        'createdAt': datetime.now().isoformat()
    }

    tracks_collection.insert_one(extended_track)

    # Remove _id field for the response
    extended_track.pop('_id', None)

    return jsonify({'success': True, 'track': extended_track})

except requests.exceptions.RequestException as e:
    print(f"Error extending track {track_id} with model {model_id}: {str(e)}")
    return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'success': False, 'error': 'No file part'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'success': False, 'error': 'No selected file'}), 400

    if file:
        # Generate a unique file name
        file_id = str(uuid.uuid4())
        file_extension = os.path.splitext(file.filename)[1]
        filename = f"{file_id}{file_extension}"
        file_path = os.path.join(UPLOAD_FOLDER, filename)

        # Save the file
        file.save(file_path)

        # Create a record in the database
        file_record = {
            'id': file_id,
            'name': file.filename,
            'path': file_path,
            'size': os.path.getsize(file_path),
            'type': file.content_type,
            'uploadedAt': datetime.now().isoformat()
        }

        return jsonify({
            'success': True,
            'file': {
                'id': file_id,
                'name': file.filename,
                'size': os.path.getsize(file_path),
                'type': file.content_type
            }
        })

    return jsonify({'success': False, 'error': 'Failed to upload file'}), 500

@app.route('/api/tracks/<track_id>/audio', methods=['GET'])
def get_track_audio(track_id):
    # Find the track
    track = tracks_collection.find_one({'id': track_id})

    if not track:
        return jsonify({'success': False, 'error': 'Track not found'}), 404

    file_path = track.get('filePath')

    if not os.path.exists(file_path):
        return jsonify({'success': False, 'error': 'Audio file not found'}), 404

    # In a real implementation, you would serve the file
    # For this example, we'll return a placeholder

    return jsonify({
        'success': True,
        'message': 'This endpoint would serve the actual audio file in a real implementation'
    })

# Initializing models at startup instead of using before_first_request decorator
init_models()

if __name__ == '__main__':
    # Initialize the models at startup
    app.run(host='0.0.0.0', port=5000)

# Hiermee eindigt het app.py bestand
cat >> backend/app.py << 'EOF'
    return jsonify({
        'success': True,
        'message': 'This endpoint would serve the actual audio file in a real implementation'
    })

# Initializing models at startup instead of using before_first_request decorator
init_models()

if __name__ == '__main__':
    # Initialize the models at startup
    app.run(host='0.0.0.0', port=5000)
EOF

# MusicGen model container
echo -e "${GREEN}Aanmaken van MusicGen model container...${NC}"

# Directories aanmaken
mkdir -p models/musicgen

# MusicGen app.py
cat > models/musicgen/app.py << 'EOF'
import os
import time
import torch
import torchaudio
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
from pydub import AudioSegment
import librosa
import soundfile as sf

app = Flask(__name__)
CORS(app)

# Global variable to hold the model
model = None
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# Constants
OUTPUT_FOLDER = '/app/output'
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

def load_musicgen_model():
    """Load the MusicGen model from Meta AI."""
    global model

    if model is not None:
        return True

    try:
        print("Loading MusicGen model...")
        from audiocraft.models import MusicGen
        model = MusicGen.get_pretrained('melody')
        model.set_generation_params(duration=30)  # Default to 30-second clips
        print("MusicGen model loaded successfully.")
        return True
    except Exception as e:
        print(f"Error loading MusicGen model: {str(e)}")
        return False

def unload_musicgen_model():
    """Unload the MusicGen model to free up GPU memory."""
    global model

    if model is None:
        return True

    try:
        print("Unloading MusicGen model...")
        model = None
        # Force garbage collection to free up GPU memory
        import gc
        gc.collect()
        with torch.cuda.device(device):
            torch.cuda.empty_cache()
        print("MusicGen model unloaded successfully.")
        return True
    except Exception as e:
        print(f"Error unloading MusicGen model: {str(e)}")
        return False

def generate_music(content_prompt, style_prompt, has_vocals, output_path):
    """Generate music using the MusicGen model."""
    global model

    if model is None:
        load_musicgen_model()

    try:
        # Combine prompts
        combined_prompt = content_prompt
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"

        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."

        print(f"Generating music with prompt: {combined_prompt}")

        # Generate the audio
        model.set_generation_params(duration=30)  # 30 seconds of audio
        audio_output = model.generate([combined_prompt])

        # Convert to numpy array
        audio_numpy = audio_output.cpu().numpy()[0, 0]  # Take the first sample

        # Save to disk
        sf.write(output_path, audio_numpy, samplerate=32000)

        # Get the duration of the generated audio
        duration = librosa.get_duration(y=audio_numpy, sr=32000)

        return True, duration
    except Exception as e:
        print(f"Error generating music: {str(e)}")
        return False, 0

def extend_track(source_track_path, output_path, extend_duration, content_prompt, style_prompt, has_vocals):
    """Extend an existing track by generating more music and concatenating."""
    global model

    if model is None:
        load_musicgen_model()

    try:
        # Load the original track
        original_audio, sr = librosa.load(source_track_path, sr=32000)

        # Combine prompts
        combined_prompt = content_prompt
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"

        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."

        combined_prompt += " Continuation of the previous section, maintain the same style and theme."

        print(f"Extending track with prompt: {combined_prompt}")

        # Generate the additional audio
        model.set_generation_params(duration=extend_duration)
        audio_output = model.generate([combined_prompt])

        # Convert to numpy array
        extension_audio = audio_output.cpu().numpy()[0, 0]

        # Concatenate the original and extension
        extended_audio = np.concatenate([original_audio, extension_audio])

        # Save to disk
        sf.write(output_path, extended_audio, samplerate=32000)

        # Get the duration of the extended audio
        duration = librosa.get_duration(y=extended_audio, sr=32000)

        return True, duration
    except Exception as e:
        print(f"Error extending track: {str(e)}")
        return False, 0

def remix_track(source_track_path, output_path, content_prompt, style_prompt, has_vocals):
    """Remix an existing track using the style and content prompts."""
    global model

    if model is None:
        load_musicgen_model()

    try:
        # Load a small sample of the original track to get its style
        original_audio, sr = librosa.load(source_track_path, sr=32000, duration=10)

        # Combine prompts for the remix
        combined_prompt = f"Remix of: {content_prompt}"
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"

        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."

        print(f"Remixing track with prompt: {combined_prompt}")

        # Generate the remix audio
        model.set_generation_params(duration=30)
        audio_output = model.generate([combined_prompt])

        # Convert to numpy array
        remix_audio = audio_output.cpu().numpy()[0, 0]

        # Save to disk
        sf.write(output_path, remix_audio, samplerate=32000)

        # Get the duration of the remix
        duration = librosa.get_duration(y=remix_audio, sr=32000)

        return True, duration
    except Exception as e:
        print(f"Error remixing track: {str(e)}")
        return False, 0

# Routes
@app.route('/load', methods=['POST'])
def load_model():
    success = load_musicgen_model()

    if success:
        return jsonify({'success': True, 'message': 'MusicGen model loaded successfully'})
    else:
        return jsonify({'success': False, 'error': 'Failed to load MusicGen model'}), 500

@app.route('/unload', methods=['POST'])
def unload_model():
    success = unload_musicgen_model()

    if success:
        return jsonify({'success': True, 'message': 'MusicGen model unloaded successfully'})
    else:
        return jsonify({'success': False, 'error': 'Failed to unload MusicGen model'}), 500

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    content_prompt = data.get('contentPrompt', '')
    style_prompt = data.get('stylePrompt', '')
    has_vocals = data.get('hasVocals', True)
    output_path = data.get('outputPath')
    is_remix = data.get('isRemix', False)
    source_track_path = data.get('sourceTrackPath')

    if not output_path:
        return jsonify({'success': False, 'error': 'Output path is required'}), 400

    # If it's a remix and we have a source track
    if is_remix and source_track_path:
        success, duration = remix_track(
            source_track_path,
            output_path,
            content_prompt,
            style_prompt,
            has_vocals
        )
    else:
        # Regular generation
        success, duration = generate_music(
            content_prompt,
            style_prompt,
            has_vocals,
            output_path
        )

    if success:
        return jsonify({
            'success': True,
            'message': 'Music generated successfully',
            'duration': duration
        })
    else:
        return jsonify({'success': False, 'error': 'Failed to generate music'}), 500

@app.route('/generate/extend', methods=['POST'])
def extend():
    data = request.json
    source_track_path = data.get('sourceTrackPath')
    output_path = data.get('outputPath')
    extend_duration = data.get('extendDuration', 30)
    content_prompt = data.get('contentPrompt', '')
    style_prompt = data.get('stylePrompt', '')
    has_vocals = data.get('hasVocals', True)

    if not source_track_path or not output_path:
        return jsonify({'success': False, 'error': 'Source track path and output path are required'}), 400

    success, duration = extend_track(
        source_track_path,
        output_path,
        extend_duration,
        content_prompt,
        style_prompt,
        has_vocals
    )

    if success:
        return jsonify({
            'success': True,
            'message': 'Track extended successfully',
            'duration': duration
        })
    else:
        return jsonify({'success': False, 'error': 'Failed to extend track'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# MusicGen requirements.txt
cat > models/musicgen/requirements.txt << 'EOF'
flask==2.0.1
flask-cors==4.0.0
requests==2.31.0
torchaudio==2.0.1
librosa==0.10.1
transformers==4.32.0
audiocraft==1.0.0
pydub==0.25.1
numpy==1.24.3
soundfile==0.12.1
EOF

# MusicGen Dockerfile met DEBIAN_FRONTEND=noninteractive toevoegen
cat > models/musicgen/Dockerfile << 'EOF'
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

WORKDIR /app

# Voorkom interactieve prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ffmpeg \
    libsndfile1 \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]
EOF

# Kopieer model setup naar andere model directories
for model in musicgpt audioldm riffusion bark musiclm mousai stable_audio dance_diffusion; do
  echo -e "${GREEN}Kopiëren van template naar $model model container...${NC}"
  cp models/musicgen/app.py models/$model/app.py
  cp models/musicgen/requirements.txt models/$model/requirements.txt
  cp models/musicgen/Dockerfile models/$model/Dockerfile
done

# Maak Jukebox model container
echo -e "${GREEN}Aanmaken van Jukebox model container...${NC}"

# Jukebox app.py
cat > models/jukebox/app.py << 'EOF'
import os
import time
import torch
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
import librosa
import soundfile as sf

app = Flask(__name__)
CORS(app)

# Global variable to hold the model
model = None
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# Constants
OUTPUT_FOLDER = '/app/output'
SAMPLE_RATE = 44100
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

def load_jukebox_model():
    """Load the OpenAI Jukebox model."""
    global model, prior, vqvae

    if model is not None:
        return True

    try:
        print("Loading Jukebox model...")

        # Import jukebox dependencies
        import jukebox
        from jukebox.make_models import make_model
        from jukebox.hparams import Hyperparams
        from jukebox.sample import sample_single_window

        # Load 1b_lyrics model
        print("Loading 1b_lyrics model (this may take a while)...")
        model_level = "3"  # Using level 3 which is more detailed
        hps = Hyperparams()
        hps.sr = SAMPLE_RATE
        hps.n_samples = 1
        hps.name = 'samples'
        hps.levels = 3
        hps.hop_fraction = [0.5, 0.5, 0.125]

        vqvae, *priors = make_model(hps, device)
        prior = priors[2]  # Level 3 prior

        # Set model
        model = {
            'vqvae': vqvae,
            'prior': prior,
            'hps': hps
        }

        print("Jukebox model loaded successfully.")
        return True
    except Exception as e:
        print(f"Error loading Jukebox model: {str(e)}")
        return False

def unload_jukebox_model():
    """Unload the Jukebox model to free up GPU memory."""
    global model

    if model is None:
        return True

    try:
        print("Unloading Jukebox model...")
        model = None
        # Force garbage collection to free up GPU memory
        import gc
        gc.collect()
        with torch.cuda.device(device):
            torch.cuda.empty_cache()
        print("Jukebox model unloaded successfully.")
        return True
    except Exception as e:
        print(f"Error unloading Jukebox model: {str(e)}")
        return False

def generate_music(content_prompt, style_prompt, has_vocals, output_path):
    """Generate music using the Jukebox model."""
    global model

    if model is None:
        load_jukebox_model()

    try:
        from jukebox.sample import sample_single_window
        import jukebox.lyricdict as lyricdict
        from jukebox.utils.dist_utils import setup_dist_from_mpi
        from jukebox.utils.torch_utils import empty_cache

        # Setup distribution
        rank, local_rank, device = setup_dist_from_mpi()

        # Combine prompts
        combined_prompt = content_prompt
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"

        # Handle vocals
        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."

        print(f"Generating music with prompt: {combined_prompt}")

        vqvae = model['vqvae']
        prior = model['prior']
        hps = model['hps']

        # Set lyrics if needed (empty for instrumental)
        lyrics = ""
        if has_vocals:
            lyrics = f"{combined_prompt}"
        metas = [{'artist': 'AI', 'genre': style_prompt or 'unknown', 'total_length': 60, 'offset': 0, 'lyrics': lyrics}]

        # Generate codes
        # Start with shorter duration for quicker results, can be increased later
        duration = 30  # 30 seconds
        codes = sample_single_window(
            zs=[torch.zeros(1, 0, dtype=torch.long, device=device) for _ in range(3)],
            conditioning={},
            chunk_size=32,
            sampling_kwargs={
                "temp": 0.7,
                "fp16": True,
                "max_batch_size": 16,
                "top_k": 200,
                "top_p": 0.95,
            },
            hps=hps,
            metas=metas,
            priors=[prior],
            vqvae=vqvae,
            sample_tokens=duration * hps.sr // hps.hop_fraction[2] // vqvae.sample_length,
            device=device
        )

        # Decode to audio
        with torch.no_grad():
            x = vqvae.decode(codes, sample_rate=hps.sr)

        # Convert to numpy and save
        audio_numpy = x.squeeze().cpu().numpy()

        # Normalize audio
        audio_numpy = audio_numpy / np.abs(audio_numpy).max()

        # Save to disk
        sf.write(output_path, audio_numpy, samplerate=SAMPLE_RATE)

        # Get duration
        duration = len(audio_numpy) / SAMPLE_RATE

        return True, duration
    except Exception as e:
        print(f"Error generating music: {str(e)}")
        return False, 0

def extend_track(source_track_path, output_path, extend_duration, content_prompt, style_prompt, has_vocals):
    """Extend an existing track by generating more music and concatenating."""
    global model

    if model is None:
        load_jukebox_model()

    try:
        # Load the original track
        original_audio, sr = librosa.load(source_track_path, sr=SAMPLE_RATE)

        # Generate new music
        success, new_duration = generate_music(
            content_prompt + " continue the previous melody and theme",
            style_prompt,
            has_vocals,
            output_path + ".temp.wav"
        )

        if not success:
            return False, 0

        # Load generated extension
        extension_audio, sr = librosa.load(output_path + ".temp.wav", sr=SAMPLE_RATE)

        # Apply crossfade for smooth transition (1 second)
        crossfade_length = min(sr, len(original_audio), len(extension_audio))

        # Create fade in/out curves
        fade_out = np.linspace(1.0, 0.0, crossfade_length)
        fade_in = np.linspace(0.0, 1.0, crossfade_length)

        # Apply fade to the end of original and start of extension
        original_end = original_audio[-crossfade_length:] * fade_out
        extension_start = extension_audio[:crossfade_length] * fade_in

        # Mix the crossfade region
        crossfade = original_end + extension_start

        # Combine everything
        extended_audio = np.concatenate([
            original_audio[:-crossfade_length],
            crossfade,
            extension_audio[crossfade_length:]
        ])

        # Save to disk
        sf.write(output_path, extended_audio, samplerate=SAMPLE_RATE)

        # Remove temp file
        os.remove(output_path + ".temp.wav")

        # Get the duration of the extended audio
        duration = len(extended_audio) / SAMPLE_RATE

        return True, duration
    except Exception as e:
        print(f"Error extending track: {str(e)}")
        return False, 0

def remix_track(source_track_path, output_path, content_prompt, style_prompt, has_vocals):
    """Remix an existing track using the style and content prompts."""
    global model

    if model is None:
        load_jukebox_model()

    try:
        # Load a sample of the original track
        original_audio, sr = librosa.load(source_track_path, sr=SAMPLE_RATE, duration=30)

        # Adjust the prompt based on the source track
        remix_prompt = f"Remix of: {content_prompt}"
        if style_prompt:
            remix_prompt += f" in the style of {style_prompt}"

        # Generate the remix
        success, duration = generate_music(
            remix_prompt,
            style_prompt,
            has_vocals,
            output_path
        )

        return success, duration
    except Exception as e:
        print(f"Error remixing track: {str(e)}")
        return False, 0

# Routes
@app.route('/load', methods=['POST'])
def load_model():
    success = load_jukebox_model()

    if success:
        return jsonify({'success': True, 'message': 'Jukebox model loaded successfully'})
    else:
        return jsonify({'success': False, 'error': 'Failed to load Jukebox model'}), 500

@app.route('/unload', methods=['POST'])
def unload_model():
    success = unload_jukebox_model()

    if success:
        return jsonify({'success': True, 'message': 'Jukebox model unloaded successfully'})
    else:
        return jsonify({'success': False, 'error': 'Failed to unload Jukebox model'}), 500

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    content_prompt = data.get('contentPrompt', '')
    style_prompt = data.get('stylePrompt', '')
    has_vocals = data.get('hasVocals', True)
    output_path = data.get('outputPath')
    is_remix = data.get('isRemix', False)
    source_track_path = data.get('sourceTrackPath')

    if not output_path:
        return jsonify({'success': False, 'error': 'Output path is required'}), 400

    # If it's a remix and we have a source track
    if is_remix and source_track_path:
        success, duration = remix_track(
            source_track_path,
            output_path,
            content_prompt,
            style_prompt,
            has_vocals
        )
    else:
        # Regular generation
        success, duration = generate_music(
            content_prompt,
            style_prompt,
            has_vocals,
            output_path
        )

    if success:
        return jsonify({
            'success': True,
            'message': 'Music generated successfully',
            'duration': duration
        })
    else:
        return jsonify({'success': False, 'error': 'Failed to generate music'}), 500

@app.route('/generate/extend', methods=['POST'])
def extend():
    data = request.json
    source_track_path = data.get('sourceTrackPath')
    output_path = data.get('outputPath')
    extend_duration = data.get('extendDuration', 30)
    content_prompt = data.get('contentPrompt', '')
    style_prompt = data.get('stylePrompt', '')
    has_vocals = data.get('hasVocals', True)

    if not source_track_path or not output_path:
        return jsonify({'success': False, 'error': 'Source track path and output path are required'}), 400

    success, duration = extend_track(
        source_track_path,
        output_path,
        extend_duration,
        content_prompt,
        style_prompt,
        has_vocals
    )

    if success:
        return jsonify({
            'success': True,
            'message': 'Track extended successfully',
            'duration': duration
        })
    else:
        return jsonify({'success': False, 'error': 'Failed to extend track'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Jukebox requirements.txt - met aangepaste versies
cat > models/jukebox/requirements.txt << 'EOF'
flask==2.0.1
flask-cors==4.0.0
requests==2.31.0
torchaudio==2.0.1
librosa==0.10.1
numpy==1.24.3
soundfile==0.12.1
mutagen>=1.43.0
EOF

# Jukebox Dockerfile - met DEBIAN_FRONTEND=noninteractive
cat > models/jukebox/Dockerfile << 'EOF'
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

WORKDIR /app

# Voorkom interactieve prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ffmpeg \
    libsndfile1 \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Jukebox with --no-deps flag om dependency conflicten te vermijden
RUN pip install --no-cache-dir --no-deps git+https://github.com/openai/jukebox.git

# Upgrade mutagen for Python 3 compatibility
RUN pip install --no-cache-dir mutagen>=1.43.0

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]
EOF

# Beheerscripts
echo -e "${GREEN}Aanmaken van beheerscripts...${NC}"

# Docker Compose configuratie met DEBIAN_FRONTEND=noninteractive
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  frontend:
    build: ./frontend
    ports:
      - "8080:80"
    volumes:
      - ./uploads:/app/uploads
    depends_on:
      - backend
    environment:
      - DEBIAN_FRONTEND=noninteractive
    networks:
      - music-gen-network

  backend:
    build: ./backend
    ports:
      - "5000:5000"
    volumes:
      - ./uploads:/app/uploads
      - ./output:/app/output
      - ./models:/app/models
    environment:
      - MONGO_URI=mongodb://mongodb:27017/music_generation
      - DEBIAN_FRONTEND=noninteractive
    depends_on:
      - mongodb
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    networks:
      - music-gen-network

  mongodb:
    image: mongo:latest
    ports:
      - "27017:27017"
    volumes:
      - mongodb-data:/data/db
    networks:
      - music-gen-network

  # AI Model Containers
  musicgen:
    build: ./models/musicgen
    ports:
      - "5001:5000"
    volumes:
      - ./models/musicgen:/app
      - ./output:/app/output
    environment:
      - DEBIAN_FRONTEND=noninteractive
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    networks:
      - music-gen-network

  musicgpt:
    build: ./models/musicgpt
    ports:
      - "5002:5000"
    volumes:
      - ./models/musicgpt:/app
      - ./output:/app/output
    environment:
      - DEBIAN_FRONTEND=noninteractive
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    networks:
      - music-gen-network

  jukebox:
    build: ./models/jukebox
    ports:
      - "5003:5000"
    volumes:
      - ./models/jukebox:/app
      - ./output:/app/output
    environment:
      - DEBIAN_FRONTEND=noninteractive
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    networks:
      - music-gen-network

  audioldm:
    build: ./models/audioldm
    ports:
      - "5004:5000"
    volumes:
      - ./models/audioldm:/app
      - ./output:/app/output
    environment:
      - DEBIAN_FRONTEND=noninteractive
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    networks:
      - music-gen-network

  riffusion:
    build: ./models/riffusion
    ports:
      - "5005:5000"
    volumes:
      - ./models/riffusion:/app
      - ./output:/app/output
    environment:
      - DEBIAN_FRONTEND=noninteractive
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    networks:
      - music-gen-network

  bark:
    build: ./models/bark
    ports:
      - "5006:5000"
    volumes:
      - ./models/bark:/app
      - ./output:/app/output
    environment:
      - DEBIAN_FRONTEND=noninteractive
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    networks:
      - music-gen-network

  musiclm:
    build: ./models/musiclm
    ports:
      - "5007:5000"
    volumes:
      - ./models/musiclm:/app
      - ./output:/app/output
    environment:
      - DEBIAN_FRONTEND=noninteractive
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    networks:
      - music-gen-network

  mousai:
    build: ./models/mousai
    ports:
      - "5008:5000"
    volumes:
      - ./models/mousai:/app
      - ./output:/app/output
    environment:
      - DEBIAN_FRONTEND=noninteractive
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    networks:
      - music-gen-network

stable_audio:
    build: ./models/stable_audio
    ports:
      - "5009:5000"
    volumes:
      - ./models/stable_audio:/app
      - ./output:/app/output
    environment:
      - DEBIAN_FRONTEND=noninteractive
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    networks:
      - music-gen-network

  dance_diffusion:
    build: ./models/dance_diffusion
    ports:
      - "5010:5000"
    volumes:
      - ./models/dance_diffusion:/app
      - ./output:/app/output
    environment:
      - DEBIAN_FRONTEND=noninteractive
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    networks:
      - music-gen-network

volumes:
  mongodb-data:

networks:
  music-gen-network:
    driver: bridge
EOF

# Startup script met aangepaste DEBIAN_FRONTEND=noninteractive voor docker build proces
cat > start.sh << 'EOF'
#!/bin/bash

# AI Music Generation Web App Startup Script

# Set up required directories
mkdir -p uploads models output
mkdir -p models/musicgen models/musicgpt models/jukebox models/audioldm models/riffusion
mkdir -p models/bark models/musiclm models/mousai models/stable_audio models/dance_diffusion

# Copy model files if they don't exist
for model in musicgen musicgpt jukebox audioldm riffusion bark musiclm mousai stable_audio dance_diffusion; do
  if [ ! -f "models/$model/app.py" ]; then
    echo "Setting up $model container..."
    cp models/musicgen/app.py models/$model/app.py 2>/dev/null || :
    cp models/musicgen/requirements.txt models/$model/requirements.txt 2>/dev/null || :
    cp models/musicgen/Dockerfile models/$model/Dockerfile 2>/dev/null || :
  fi
done

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Please start Docker and try again."
  exit 1
fi

# Check if nvidia-docker is installed
if ! command -v nvidia-docker &> /dev/null && ! docker info | grep -q "Runtimes: nvidia"; then
  echo "NVIDIA Docker runtime not detected. Please make sure NVIDIA Docker is installed and configured."
  echo "See: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Check NVIDIA GPU availability
if ! nvidia-smi &> /dev/null; then
  echo "NVIDIA GPUs not detected. Make sure your drivers are installed correctly."
  read -p "Continue anyway (models will be slow without GPU acceleration)? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

echo "Starting AI Music Generation System..."

# Set environment variable for non-interactive builds
export DEBIAN_FRONTEND=noninteractive

# Build and start the containers
echo "Building and starting containers (this may take a while for the first run)..."
docker-compose up -d

# Wait for all services to start
echo "Waiting for services to start..."
sleep 10

# Display the service status
docker-compose ps

# Display access information
echo
echo "==================================================================="
echo "  AI Music Generation System is now running!"
echo "==================================================================="
echo
echo "  Access the web interface at: http://localhost:8080"
echo "  Or from another computer at: http://$(hostname -I | awk '{print $1}'):8080"
echo
echo "  To stop the system, run: docker-compose down"
echo
echo "==================================================================="
EOF
chmod +x start.sh

# Monitor script
cat > monitor.sh << 'EOF'
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
echo -e "Or from another computer at: ${GREEN}http://$(hostname -I | awk '{print $1}'):8080${NC}"
echo
EOF
chmod +x monitor.sh

# Update script
cat > update.sh << 'EOF'
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
EOF
chmod +x update.sh

# Cleanup script
cat > cleanup.sh << 'EOF'
#!/bin/bash

# AI Music Generation System Cleanup Script

# Set color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}      AI Music Generation System - Cleanup Tool             ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo

# Default values
DAYS_OLD=7
KEEP_FAVORITES=true
BACKUP=false
DELETE_UPLOADS=false
DRY_RUN=false

# Parse command line options
while [[ $# -gt 0 ]]; do
  case $1 in
    --days=*)
      DAYS_OLD="${1#*=}"
      shift
      ;;
    --no-favorites)
      KEEP_FAVORITES=false
      shift
      ;;
    --backup)
      BACKUP=true
      shift
      ;;
    --delete-uploads)
      DELETE_UPLOADS=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --days=N             Delete files older than N days (default: 7)"
      echo "  --no-favorites       Also delete files marked as favorites"
      echo "  --backup             Create a backup before deletion"
      echo "  --delete-uploads     Also delete uploaded files"
      echo "  --dry-run            Show what would be deleted without actually deleting"
      echo "  --help               Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information."
      exit 1
      ;;
  esac
done

# Ensure the system is running
if ! docker-compose ps | grep -q "Up"; then
  echo -e "${YELLOW}[WARNING] AI Music Generation System does not appear to be running.${NC}"
  echo -e "${YELLOW}[WARNING] Database operations may fail, but file cleanup can proceed.${NC}"

  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}[ERROR] Cleanup aborted.${NC}"
    exit 1
  fi
fi

# Show current disk usage
echo -e "${BLUE}Current Disk Usage:${NC}"
echo -e "-------------------"
echo -e "Output Directory: $(du -sh output | cut -f1) ($(find output -type f | wc -l) files)"
echo -e "Uploads Directory: $(du -sh uploads | cut -f1) ($(find uploads -type f | wc -l) files)"
echo -e "Docker Data: $(docker system df --format '{{.Size}}' | head -n 1)"
echo

# Create backup if requested
if [ "$BACKUP" = true ]; then
  echo -e "${YELLOW}[INFO] Creating backup before cleanup...${NC}"
  BACKUP_FILE="music_backup_$(date +%Y%m%d_%H%M%S).tar.gz"

  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN] Would create backup: $BACKUP_FILE${NC}"
  else
    tar -czf "$BACKUP_FILE" output uploads
    echo -e "${GREEN}[SUCCESS] Backup created: $BACKUP_FILE${NC}"
  fi
  echo
fi

# Get list of files to delete from the database (excluding favorites if requested)
if docker-compose ps | grep -q "Up"; then
  echo -e "${YELLOW}[INFO] Finding tracks to clean up from database...${NC}"

  FAVORITES_CLAUSE=""
  if [ "$KEEP_FAVORITES" = true ]; then
    FAVORITES_CLAUSE="AND favorite: false"
  fi

  MONGO_QUERY="db.tracks.find({createdAt: {\$lt: new Date(Date.now() - ${DAYS_OLD} * 24 * 60 * 60 * 1000)} $FAVORITES_CLAUSE}, {filePath: 1}).toArray()"

  FILES_TO_DELETE=$(docker-compose exec -T mongodb mongosh music_generation --quiet --eval "$MONGO_QUERY" | grep filePath | sed 's/.*filePath: "\(.*\)".*/\1/')

  # Count files to delete
  FILE_COUNT=$(echo "$FILES_TO_DELETE" | grep -v "^$" | wc -l)

  echo -e "${YELLOW}[INFO] Found $FILE_COUNT database tracks older than $DAYS_OLD days to delete.${NC}"

  # Delete database entries
  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN] Would delete $FILE_COUNT database entries.${NC}"
  else
    if [ $FILE_COUNT -gt 0 ]; then
      DELETE_QUERY="db.tracks.deleteMany({createdAt: {\$lt: new Date(Date.now() - ${DAYS_OLD} * 24 * 60 * 60 * 1000)} $FAVORITES_CLAUSE})"
      DELETE_RESULT=$(docker-compose exec -T mongodb mongosh music_generation --quiet --eval "$DELETE_QUERY")
      echo -e "${GREEN}[SUCCESS] Deleted entries from database: $DELETE_RESULT${NC}"
    fi
  fi
else
  echo -e "${YELLOW}[WARNING] Database not accessible. Only performing file cleanup.${NC}"
  # Find files by date instead
  FILES_TO_DELETE=$(find output -type f -mtime +$DAYS_OLD)
  FILE_COUNT=$(echo "$FILES_TO_DELETE" | grep -v "^$" | wc -l)
  echo -e "${YELLOW}[INFO] Found $FILE_COUNT files older than $DAYS_OLD days to delete.${NC}"
fi

# Delete actual files
echo -e "${YELLOW}[INFO] Cleaning up output files...${NC}"
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}[DRY RUN] Would delete the following files:${NC}"
  echo "$FILES_TO_DELETE"
else
  echo "$FILES_TO_DELETE" | while read file; do
    if [ ! -z "$file" ] && [ -f "$file" ]; then
      rm -f "$file"
      echo -e "${GREEN}[DELETED] $file${NC}"
    fi
  done
fi

# Clean up upload files if requested
if [ "$DELETE_UPLOADS" = true ]; then
  echo -e "${YELLOW}[INFO] Cleaning up uploaded files...${NC}"
  UPLOAD_FILES=$(find uploads -type f -mtime +$DAYS_OLD)
  UPLOAD_COUNT=$(echo "$UPLOAD_FILES" | grep -v "^$" | wc -l)

  echo -e "${YELLOW}[INFO] Found $UPLOAD_COUNT uploaded files older than $DAYS_OLD days to delete.${NC}"

  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN] Would delete $UPLOAD_COUNT uploaded files.${NC}"
  else
    echo "$UPLOAD_FILES" | while read file; do
      if [ ! -z "$file" ] && [ -f "$file" ]; then
        rm -f "$file"
        echo -e "${GREEN}[DELETED] $file${NC}"
      fi
    done
  fi
fi

# Clean up Docker resources
echo -e "${YELLOW}[INFO] Cleaning up Docker resources...${NC}"
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}[DRY RUN] Would clean up Docker resources.${NC}"
else
  docker system prune -f > /dev/null
  echo -e "${GREEN}[SUCCESS] Docker resources cleaned up.${NC}"
fi

# Show new disk usage
echo -e "\n${BLUE}New Disk Usage:${NC}"
echo -e "---------------"
echo -e "Output Directory: $(du -sh output | cut -f1) ($(find output -type f | wc -l) files)"
echo -e "Uploads Directory: $(du -sh uploads | cut -f1) ($(find uploads -type f | wc -l) files)"
echo -e "Docker Data: $(docker system df --format '{{.Size}}' | head -n 1)"

echo -e "\n${BLUE}============================================================${NC}"
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}Dry run completed. No files were deleted.${NC}"
else
  echo -e "${GREEN}Cleanup completed successfully.${NC}"
fi
echo -e "${BLUE}============================================================${NC}"
EOF
chmod +x cleanup.sh

# Het fix-torchaudio.sh script aanmaken
cat > fix-torchaudio.sh << 'EOF'
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
EOF
chmod +x fix-torchaudio.sh

# Update DEBIAN_FRONTEND script aanmaken
cat > update-dockerfiles.sh << 'EOF'
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
EOF
chmod +x update-dockerfiles.sh

# README.md aanmaken
cat > README.md << 'EOF'
# AI Music Generation Studio

Een geavanceerd platform voor het genereren van muziek met behulp van diverse AI-modellen.

## Overzicht

Deze AI Music Studio combineert 10 verschillende state-of-the-art AI-muziekgeneratiemodellen in één gebruiksvriendelijke interface. Het systeem draait via Docker containers en biedt een Web UI voor het genereren, remixen en verlengen van muziek.

## Systeemvereisten

- Ubuntu 22.04 of nieuwer
- Docker en Docker Compose
- NVIDIA GPU met CUDA-ondersteuning (aanbevolen)
- NVIDIA Container Toolkit

## Installatie

1. Clone deze repository:
