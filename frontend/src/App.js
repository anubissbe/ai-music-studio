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
