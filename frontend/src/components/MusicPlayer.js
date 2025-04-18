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
        backend: 'WebAudio',
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
