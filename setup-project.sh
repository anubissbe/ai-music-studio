#!/bin/bash

# Set color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}AI Music Studio - Project Setup${NC}"
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

# Frontend Dockerfile
cat > frontend/Dockerfile << 'EOF'
FROM node:18-alpine as build

WORKDIR /app

COPY package*.json ./
RUN npm install --legacy-peer-deps

# Ensure public directory exists with required files
RUN mkdir -p public
RUN echo '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><rect width="32" height="32" fill="#3B82F6"/><text x="16" y="20" font-family="Arial" font-size="12" text-anchor="middle" fill="white">M</text></svg>' > public/favicon.svg
RUN echo '<svg xmlns="http://www.w3.org/2000/svg" width="192" height="192"><rect width="192" height="192" fill="#3B82F6"/><text x="96" y="108" font-family="Arial" font-size="72" text-anchor="middle" fill="white">M</text></svg>' > public/logo192.svg
RUN echo '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512"><rect width="512" height="512" fill="#3B82F6"/><text x="256" y="280" font-family="Arial" font-size="180" text-anchor="middle" fill="white">M</text></svg>' > public/logo512.svg

COPY . .
RUN npm run build

FROM nginx:stable-alpine

COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

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

# Frontend package.json
cat > frontend/package.json << 'EOF'
{
  "name": "music-generation-ui",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@headlessui/react": "^1.7.17",
    "@heroicons/react": "^2.0.18",
    "@testing-library/jest-dom": "^5.17.0",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^13.5.0",
    "axios": "^1.6.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-dropzone": "^14.2.3",
    "react-scripts": "5.0.1",
    "wavesurfer.js": "^7.3.2",
    "web-vitals": "^2.1.4"
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
touch frontend/public/favicon.ico
touch frontend/public/logo192.png
touch frontend/public/logo512.png

# Frontend src/index.js
cat > frontend/src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
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
import { HeadphonesIcon, MusicalNoteIcon, ArrowPathIcon } from '@heroicons/react/24/outline';
import ModelSelector from './components/ModelSelector';
import PromptInput from './components/PromptInput';
import MusicPlayer from './components/MusicPlayer';
import FileUploader from './components/FileUploader';

function App() {
  const [selectedModel, setSelectedModel] = useState(null);
  const [availableModels, setAvailableModels] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isModelLoading, setIsModelLoading] = useState(false);
  const [contentPrompt, setContentPrompt] = useState('');
  const [stylePrompt, setStylePrompt] = useState('');
  const [hasVocals, setHasVocals] = useState(true);
  const [generatedTracks, setGeneratedTracks] = useState([]);
  const [currentTrack, setCurrentTrack] = useState(null);
  const [uploadedFile, setUploadedFile] = useState(null);
  const [isRemixMode, setIsRemixMode] = useState(false);

  // Fetch available models on component mount
  useEffect(() => {
    fetchAvailableModels();
  }, []);

  const fetchAvailableModels = async () => {
    try {
      const response = await axios.get('/api/models');
      setAvailableModels(response.data.models);
    } catch (error) {
      console.error('Error fetching models:', error);
    }
  };

  const handleModelSelect = async (model) => {
    if (selectedModel && selectedModel.id === model.id) return;
    
    setIsModelLoading(true);
    try {
      // Unload current model if there is one
      if (selectedModel) {
        await axios.post('/api/models/unload', { modelId: selectedModel.id });
      }
      
      // Load new model
      await axios.post('/api/models/load', { modelId: model.id });
      setSelectedModel(model);
    } catch (error) {
      console.error('Error switching models:', error);
    } finally {
      setIsModelLoading(false);
    }
  };

  const handleGenerateMusic = async () => {
    if (!selectedModel) return;
    
    setIsLoading(true);
    try {
      const payload = {
        modelId: selectedModel.id,
        contentPrompt,
        stylePrompt,
        hasVocals,
        isRemix: isRemixMode,
        sourceTrackId: isRemixMode && uploadedFile ? uploadedFile.id : null
      };
      
      const response = await axios.post('/api/generate', payload);
      const newTrack = response.data.track;
      
      setGeneratedTracks([newTrack, ...generatedTracks]);
      setCurrentTrack(newTrack);
    } catch (error) {
      console.error('Error generating music:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleFileUpload = async (file) => {
    const formData = new FormData();
    formData.append('file', file);
    
    try {
      const response = await axios.post('/api/upload', formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });
      
      setUploadedFile(response.data.file);
      setIsRemixMode(true);
    } catch (error) {
      console.error('Error uploading file:', error);
    }
  };

  const handleExtendTrack = async () => {
    if (!currentTrack) return;
    
    setIsLoading(true);
    try {
      const response = await axios.post('/api/extend', {
        trackId: currentTrack.id,
        modelId: selectedModel.id,
        duration: 30 // Extend by 30 seconds
      });
      
      const extendedTrack = response.data.track;
      
      // Replace the original track with the extended one
      const updatedTracks = generatedTracks.map(track => 
        track.id === currentTrack.id ? extendedTrack : track
      );
      
      setGeneratedTracks(updatedTracks);
      setCurrentTrack(extendedTrack);
    } catch (error) {
      console.error('Error extending track:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const toggleRemixMode = () => {
    setIsRemixMode(!isRemixMode);
    if (!isRemixMode) {
      setUploadedFile(null);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 to-gray-800 text-white">
      <header className="border-b border-gray-700 bg-black bg-opacity-30 backdrop-blur-lg">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <HeadphonesIcon className="h-8 w-8 text-primary-400" />
            <h1 className="text-2xl font-bold text-white">AI Music Studio</h1>
          </div>
          
          <div className="flex items-center space-x-4">
            <button
              onClick={toggleRemixMode}
              className={`px-4 py-2 rounded-lg transition ${isRemixMode ? 'bg-secondary-600 text-white' : 'bg-gray-700 text-gray-300 hover:bg-gray-600'}`}
            >
              {isRemixMode ? 'Remix Mode Active' : 'Remix Mode'}
            </button>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-4 py-8 grid grid-cols-1 lg:grid-cols-12 gap-8">
        <div className="lg:col-span-3">
          <div className="bg-black bg-opacity-40 backdrop-blur-md rounded-xl p-6 sticky top-8">
            <h2 className="text-xl font-bold mb-4 flex items-center">
              <MusicalNoteIcon className="h-5 w-5 mr-2 text-primary-400" />
              AI Models
            </h2>
            
            <ModelSelector 
              models={availableModels}
              selectedModel={selectedModel}
              onSelectModel={handleModelSelect}
              isLoading={isModelLoading}
            />

            {isModelLoading && (
              <div className="mt-4 text-center text-sm text-gray-400 flex items-center justify-center">
                <ArrowPathIcon className="h-4 w-4 mr-2 animate-spin" />
                Loading model...
              </div>
            )}
          </div>
        </div>

        <div className="lg:col-span-9 space-y-8">
          <div className="bg-black bg-opacity-40 backdrop-blur-md rounded-xl p-6">
            {isRemixMode ? (
              <>
                <h2 className="text-xl font-bold mb-4">Remix a Track</h2>
                <FileUploader 
                  onFileUpload={handleFileUpload} 
                  uploadedFile={uploadedFile}
                />
                
                {uploadedFile && (
                  <div className="mt-4">
                    <PromptInput
                      contentPrompt={contentPrompt}
                      stylePrompt={stylePrompt}
                      hasVocals={hasVocals}
                      onContentChange={setContentPrompt}
                      onStyleChange={setStylePrompt}
                      onVocalsChange={setHasVocals}
                    />
                    
                    <button
                      onClick={handleGenerateMusic}
                      disabled={isLoading || !selectedModel}
                      className="mt-4 w-full bg-gradient-to-r from-primary-600 to-secondary-600 hover:from-primary-700 hover:to-secondary-700 text-white font-bold py-3 px-6 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition flex items-center justify-center"
                    >
                      {isLoading ? (
                        <>
                          <ArrowPathIcon className="h-5 w-5 mr-2 animate-spin" />
                          Creating Remix...
                        </>
                      ) : (
                        'Create Remix'
                      )}
                    </button>
                  </div>
                )}
              </>
            ) : (
              <>
                <h2 className="text-xl font-bold mb-4">Generate New Music</h2>
                <PromptInput
                  contentPrompt={contentPrompt}
                  stylePrompt={stylePrompt}
                  hasVocals={hasVocals}
                  onContentChange={setContentPrompt}
                  onStyleChange={setStylePrompt}
                  onVocalsChange={setHasVocals}
                />
                
                <button
                  onClick={handleGenerateMusic}
                  disabled={isLoading || !selectedModel || !contentPrompt}
                  className="mt-4 w-full bg-gradient-to-r from-primary-600 to-secondary-600 hover:from-primary-700 hover:to-secondary-700 text-white font-bold py-3 px-6 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition flex items-center justify-center"
                >
                  {isLoading ? (
                    <>
                      <ArrowPathIcon className="h-5 w-5 mr-2 animate-spin" />
                      Generating Music...
                    </>
                  ) : (
                    'Generate Music'
                  )}
                </button>
              </>
            )}
          </div>

          {currentTrack && (
            <div className="bg-black bg-opacity-40 backdrop-blur-md rounded-xl p-6">
              <h2 className="text-xl font-bold mb-4">Music Player</h2>
              <MusicPlayer 
                track={currentTrack} 
                onExtend={handleExtendTrack}
                isExtending={isLoading}
              />
            </div>
          )}

          {generatedTracks.length > 0 && (
            <div className="bg-black bg-opacity-40 backdrop-blur-md rounded-xl p-6">
              <h2 className="text-xl font-bold mb-4">Generated Tracks</h2>
              <div className="space-y-2">
                {generatedTracks.map(track => (
                  <div 
                    key={track.id}
                    onClick={() => setCurrentTrack(track)}
                    className={`p-3 rounded-lg cursor-pointer transition ${
                      currentTrack && currentTrack.id === track.id 
                        ? 'bg-primary-900 border border-primary-700' 
                        : 'bg-gray-800 hover:bg-gray-700'
                    }`}
                  >
                    <div className="flex justify-between items-center">
                      <div>
                        <h3 className="font-medium">{track.name || 'Untitled Track'}</h3>
                        <p className="text-sm text-gray-400">
                          {track.duration}s • {track.model} • {new Date(track.createdAt).toLocaleString()}
                        </p>
                      </div>
                      <MusicalNoteIcon className={`h-5 w-5 ${
                        currentTrack && currentTrack.id === track.id 
                          ? 'text-primary-400' 
                          : 'text-gray-400'
                      }`} />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

export default App;
EOF

# Component bestanden
echo -e "${GREEN}Aanmaken van React componenten...${NC}"

# ModelSelector.js
cat > frontend/src/components/ModelSelector.js << 'EOF'
import React from 'react';
import { CheckCircleIcon } from '@heroicons/react/24/solid';

const ModelSelector = ({ models, selectedModel, onSelectModel, isLoading }) => {
  return (
    <div className="space-y-2">
      {models.map(model => (
        <div
          key={model.id}
          onClick={() => !isLoading && onSelectModel(model)}
          className={`p-3 rounded-lg cursor-pointer transition flex items-center justify-between ${
            isLoading ? 'opacity-50 cursor-not-allowed' : ''
          } ${
            selectedModel && selectedModel.id === model.id
              ? 'bg-gradient-to-r from-primary-900 to-secondary-900 border border-primary-700'
              : 'bg-gray-800 hover:bg-gray-700'
          }`}
        >
          <div>
            <h3 className={`font-medium ${
              selectedModel && selectedModel.id === model.id ? 'text-primary-300' : 'text-white'
            }`}>
              {model.name}
            </h3>
            <p className="text-sm text-gray-400">{model.description}</p>
          </div>
          
          {selectedModel && selectedModel.id === model.id && (
            <CheckCircleIcon className="h-5 w-5 text-primary-400" />
          )}
        </div>
      ))}

      {models.length === 0 && (
        <div className="text-center text-gray-400 py-8">
          Loading models...
        </div>
      )}
    </div>
  );
};

export default ModelSelector;
EOF

# PromptInput.js
cat > frontend/src/components/PromptInput.js << 'EOF'
import React from 'react';
import { Switch } from '@headlessui/react';
import { MicrophoneIcon, MusicalNoteIcon } from '@heroicons/react/24/outline';

const PromptInput = ({ 
  contentPrompt, 
  stylePrompt, 
  hasVocals, 
  onContentChange, 
  onStyleChange, 
  onVocalsChange 
}) => {
  const musicStyles = [
    'Classical',
    'Jazz',
    'Rock',
    'Pop',
    'Hip Hop',
    'Electronic',
    'Folk',
    'Reggae',
    'Country',
    'Blues',
    'Metal',
    'Funk',
    'Soul',
    'Ambient',
    'R&B'
  ];

  return (
    <div className="space-y-4">
      <div>
        <label htmlFor="contentPrompt" className="block text-sm font-medium text-gray-300 mb-1">
          What should the music be about?
        </label>
        <textarea
          id="contentPrompt"
          value={contentPrompt}
          onChange={(e) => onContentChange(e.target.value)}
          placeholder="Describe what you want the music to be about (e.g., 'A journey through a mystical forest' or 'A remix of John Lennon's Give Peace a Chance')"
          className="w-full px-4 py-2 rounded-lg bg-gray-800 border border-gray-700 text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent"
          rows={3}
        />
      </div>
      
      <div>
        <label htmlFor="stylePrompt" className="block text-sm font-medium text-gray-300 mb-1">
          Music Style
        </label>
        <div className="mb-3 flex flex-wrap gap-2">
          {musicStyles.map(style => (
            <button
              key={style}
              type="button"
              onClick={() => onStyleChange(stylePrompt ? `${stylePrompt}, ${style}` : style)}
              className="px-3 py-1 text-sm rounded-full bg-gray-700 hover:bg-gray-600 text-white transition"
            >
              {style}
            </button>
          ))}
        </div>
        <textarea
          id="stylePrompt"
          value={stylePrompt}
          onChange={(e) => onStyleChange(e.target.value)}
          placeholder="Describe the musical style (e.g., 'Upbeat jazz with piano' or 'Hardstyle remix')"
          className="w-full px-4 py-2 rounded-lg bg-gray-800 border border-gray-700 text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent"
          rows={2}
        />
      </div>
      
      <div className="flex items-center justify-between">
        <div className="flex items-center">
          <Switch
            checked={hasVocals}
            onChange={onVocalsChange}
            className={`${
              hasVocals ? 'bg-primary-600' : 'bg-gray-700'
            } relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 focus:ring-offset-gray-800`}
          >
            <span
              className={`${
                hasVocals ? 'translate-x-6' : 'translate-x-1'
              } inline-block h-4 w-4 transform rounded-full bg-white transition-transform`}
            />
          </Switch>
          <div className="ml-3 flex items-center">
            {hasVocals ? (
              <>
                <MicrophoneIcon className="h-5 w-5 text-primary-400 mr-1" />
                <span className="text-sm text-gray-300">Include vocals</span>
              </>
            ) : (
              <>
                <MusicalNoteIcon className="h-5 w-5 text-gray-400 mr-1" />
                <span className="text-sm text-gray-400">Instrumental only</span>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default PromptInput;
EOF

# MusicPlayer.js
cat > frontend/src/components/MusicPlayer.js << 'EOF'
import React, { useEffect, useRef, useState } from 'react';
import { 
  PlayIcon, 
  PauseIcon, 
  ArrowPathIcon,
  ArrowDownTrayIcon
} from '@heroicons/react/24/solid';
import WaveSurfer from 'wavesurfer.js';

const MusicPlayer = ({ track, onExtend, isExtending }) => {
  const waveformRef = useRef(null);
  const wavesurfer = useRef(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);

  useEffect(() => {
    if (waveformRef.current && track) {
      // Destroy previous instance
      if (wavesurfer.current) {
        wavesurfer.current.destroy();
      }

      // Create WaveSurfer instance
      const ws = WaveSurfer.create({
        container: waveformRef.current,
        waveColor: '#8b5cf6',
        progressColor: '#6d28d9',
        cursorColor: '#f3f4f6',
        barWidth: 2,
        barRadius: 3,
        cursorWidth: 1,
        height: 80,
        barGap: 2,
        responsive: true,
        normalize: true,
      });

      // Load audio
      ws.load(track.url);

      // Set up event listeners
      ws.on('ready', () => {
        setDuration(ws.getDuration());
      });

      ws.on('audioprocess', () => {
        setCurrentTime(ws.getCurrentTime());
      });

      ws.on('finish', () => {
        setIsPlaying(false);
      });

      wavesurfer.current = ws;
    }

    // Cleanup function
    return () => {
      if (wavesurfer.current) {
        wavesurfer.current.destroy();
      }
    };
  }, [track]);

  const handlePlayPause = () => {
    if (wavesurfer.current) {
      wavesurfer.current.playPause();
      setIsPlaying(!isPlaying);
    }
  };

  const formatTime = (time) => {
    if (!time) return '0:00';
    
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  const handleDownload = () => {
    if (track && track.url) {
      const link = document.createElement('a');
      link.href = track.url;
      link.download = track.name || 'generated-music.mp3';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
  };

  return (
    <div className="bg-gray-800 rounded-lg p-4 backdrop-blur-sm">
      <div className="flex items-center justify-between mb-3">
        <div>
          <h3 className="font-medium text-lg">{track.name || 'Generated Track'}</h3>
          <p className="text-sm text-gray-400">
            {track.model} • {track.hasVocals ? 'Vocals' : 'Instrumental'} • {formatTime(duration)}
          </p>
        </div>
        <div className="flex space-x-2">
          <button 
            onClick={onExtend}
            disabled={isExtending}
            className="p-2 rounded-lg bg-secondary-700 hover:bg-secondary-600 disabled:opacity-50 disabled:cursor-not-allowed transition text-white"
            title="Extend track"
          >
            {isExtending ? (
              <ArrowPathIcon className="h-5 w-5 animate-spin" />
            ) : (
              <ArrowPathIcon className="h-5 w-5" />
            )}
          </button>
          <button 
            onClick={handleDownload}
            className="p-2 rounded-lg bg-primary-700 hover:bg-primary-600 text-white transition"
            title="Download track"
          >
            <ArrowDownTrayIcon className="h-5 w-5" />
          </button>
        </div>
      </div>

      <div className="mb-2">
        <div 
          ref={waveformRef} 
          className="w-full"
        />
      </div>

      <div className="flex items-center justify-between">
        <button
          onClick={handlePlayPause}
          className="p-3 rounded-full bg-gradient-to-r from-primary-600 to-secondary-600 hover:from-primary-700 hover:to-secondary-700 text-white transition"
        >
          {isPlaying ? (
            <PauseIcon className="h-5 w-5" />
          ) : (
            <PlayIcon className="h-5 w-5" />
          )}
        </button>
        
        <div className="text-sm text-gray-400">
          {formatTime(currentTime)} / {formatTime(duration)}
        </div>
      </div>
      
      <div className="mt-4 text-sm text-gray-500">
        <div className="flex items-start space-x-2">
          <span className="font-medium">Content:</span>
          <span>{track.contentPrompt}</span>
        </div>
        {track.stylePrompt && (
          <div className="flex items-start space-x-2 mt-1">
            <span className="font-medium">Style:</span>
            <span>{track.stylePrompt}</span>
          </div>
        )}
      </div>
    </div>
  );
};

export default MusicPlayer;
EOF

# FileUploader.js
cat > frontend/src/components/FileUploader.js << 'EOF'
import React, { useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { DocumentIcon, CheckCircleIcon, XMarkIcon } from '@heroicons/react/24/outline';

const FileUploader = ({ onFileUpload, uploadedFile }) => {
  const onDrop = useCallback((acceptedFiles) => {
    if (acceptedFiles.length > 0) {
      onFileUpload(acceptedFiles[0]);
    }
  }, [onFileUpload]);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'audio/mpeg': ['.mp3'],
      'audio/wav': ['.wav'],
      'audio/x-m4a': ['.m4a'],
      'audio/ogg': ['.ogg']
    },
    maxFiles: 1
  });

  return (
    <div className="space-y-4">
      {!uploadedFile ? (
        <div 
          {...getRootProps()} 
          className={`border-2 border-dashed rounded-lg p-6 text-center transition cursor-pointer ${
            isDragActive 
              ? 'border-primary-500 bg-primary-900 bg-opacity-20' 
              : 'border-gray-700 hover:border-gray-500 bg-gray-800 bg-opacity-50'
          }`}
        >
          <input {...getInputProps()} />
          <DocumentIcon className="h-12 w-12 mx-auto text-gray-400" />
          <p className="mt-2 text-sm text-gray-300">
            {isDragActive
              ? "Drop the audio file here..."
              : "Drag & drop an audio file here, or click to select"}
          </p>
          <p className="mt-1 text-xs text-gray-500">
            Supported formats: MP3, WAV, M4A, OGG
          </p>
        </div>
      ) : (
        <div className="bg-gray-800 rounded-lg p-4 flex items-center justify-between">
          <div className="flex items-center">
            <CheckCircleIcon className="h-6 w-6 text-green-500 mr-3" />
            <div>
              <h3 className="font-medium">{uploadedFile.name}</h3>
              <p className="text-xs text-gray-400">
                {(uploadedFile.size / 1024 / 1024).toFixed(2)} MB
              </p>
            </div>
          </div>
          
          <button
            onClick={() => onFileUpload(null)}
            className="p-1 rounded-full hover:bg-gray-700 transition"
          >
            <XMarkIcon className="h-5 w-5 text-gray-400" />
          </button>
        </div>
      )}
    </div>
  );
};

export default FileUploader;
EOF

# Backend bestanden aanmaken
echo -e "${GREEN}Aanmaken van backend bestanden...${NC}"

# Backend Dockerfile
cat > backend/Dockerfile << 'EOF'
FROM python:3.10-slim

WORKDIR /app

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
flask==2.3.3
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

# Backend app.py
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

# Initialize the app
@app.before_first_request
def initialize():
    init_models()

if __name__ == '__main__':
    # Initialize the models
    init_models()
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
flask==2.3.3
flask-cors==4.0.0
requests==2.31.0
torchaudio==2.0.2
librosa==0.10.1
transformers==4.32.0
audiocraft==1.0.0
pydub==0.25.1
numpy==1.24.3
soundfile==0.12.1
EOF

# MusicGen Dockerfile
cat > models/musicgen/Dockerfile << 'EOF'
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

WORKDIR /app

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

# Jukebox requirements.txt
cat > models/jukebox/requirements.txt << 'EOF'
flask==2.3.3
flask-cors==4.0.0
requests==2.31.0
torchaudio==2.0.2
librosa==0.10.1
numpy==1.24.3
soundfile==0.12.1
jukebox
EOF

# Jukebox Dockerfile
cat > models/jukebox/Dockerfile << 'EOF'
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

WORKDIR /app

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

# Install Jukebox directly from Github
RUN pip install --no-cache-dir git+https://github.com/openai/jukebox.git

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]
EOF

# Beheerscripts
echo -e "${GREEN}Aanmaken van beheerscripts...${NC}"

# Docker Compose configuratie
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

# Startup script
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
echo
echo "  To stop the system, run: docker-compose down"
echo
echo "==================================================================="
EOF
chmod +x start.sh

# Beheerbestanden
echo -e "${GREEN}Aanmaken van configuratie- en beheerbestanden...${NC}"

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
EOF
chmod +x monitor.sh

# Config file
cat > config.yml << 'EOF'
# AI Music Generation Studio - Configuration File

# System Settings
system:
  # Set to true to enable debug logging
  debug: false
  # Maximum file upload size in MB
  max_upload_size: 50
  # Number of tracks to keep in history
  history_size: 50
  # Default output audio format (mp3, wav, ogg)
  output_format: "mp3"
  # Output audio quality (0-100 for mp3, 0-10 for ogg)
  output_quality: 96
  # Default output sample rate
  sample_rate: 44100

# GPU Settings
gpu:
  # GPU memory allocation strategy (dynamic or fixed)
  memory_allocation: "dynamic"
  # Percentage of GPU memory to reserve for models when fixed
  memory_percentage: 90
  # Enable GPU monitoring
  enable_monitoring: true
  # Automatic model unloading when low on memory
  auto_unload: true
  # GPU memory threshold for auto unloading (percentage)
  unload_threshold: 85

# AI Models Settings
models:
  # Default model to load on startup (leave empty for none)
  default_model: "musicgen"
  # Time in seconds to wait before unloading an unused model
  unload_timeout: 300
  # Max number of models to keep loaded simultaneously
  max_loaded_models: 2
  # Model loading timeout in seconds
  loading_timeout: 120

  # Model-specific settings
  musicgen:
    # Model size (melody, medium, small, large)
    size: "melody"
    # Default generation duration in seconds
    duration: 30
    # Temperature for sampling (higher = more random)
    temperature: 0.95

  jukebox:
    # Model level (1, 2, 3)
    level: 3
    # Top k for sampling
    top_k: 200
    # Top p for sampling
    top_p: 0.95
    # Temperature for sampling
    temperature: 0.98

  # Other model settings...

# Audio Processing Settings
audio:
  # Normalize output audio
  normalize: true
  # Apply fade in/out (in milliseconds)
  fade_in: 100
  fade_out: 500
  # When extending tracks, crossfade duration in milliseconds
  crossfade_duration: 1000
  # Apply loudness normalization to match commercial music
  loudness_normalization: true
  # Target loudness in LUFS
  target_loudness: -14

# Web Interface Settings
web:
  # Enable dark mode by default
  dark_mode: true
  # Auto-play generated tracks
  auto_play: true
  # Show advanced options
  show_advanced: false
  # Number of tracks to show in history
  display_history_count: 10
  # Enable audio visualization
  enable_visualization: true
  # Enable keyboard shortcuts
  enable_shortcuts: true

# Security Settings
security:
  # Require authentication
  require_auth: false
  # Username for basic auth
  username: "admin"
  # Password for basic auth (change this!)
  password: "musicai"
  # Allow remote access (not just localhost)
  allow_remote: false
  # Rate limiting for generation requests (per minute)
  rate_limit: 10
EOF

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

echo -e "${GREEN}Alle bestanden en directories zijn succesvol aangemaakt!${NC}"
echo -e "Je kunt nu het systeem starten met: ${YELLOW}./start.sh${NC}"
echo -e "Gebruik ${YELLOW}./monitor.sh${NC} om het systeem te monitoren"
echo -e "Gebruik ${YELLOW}./update.sh${NC} om het systeem bij te werken"
echo -e "Gebruik ${YELLOW}./cleanup.sh${NC} om oude muziekbestanden op te ruimen"
echo -e "\n${BLUE}============================================================${NC}"
echo -e "${GREEN}AI Music Generation Studio setup voltooid!${NC}"
echo -e "${BLUE}============================================================${NC}"
