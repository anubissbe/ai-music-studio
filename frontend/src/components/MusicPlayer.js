// src/components/MusicPlayer.js

import React, { useRef, useEffect } from 'react'

export default function MusicPlayer({ audioUrl }) {
  const audioRef = useRef(null)

  // whenever the URL changes, reload the audio element
  useEffect(() => {
    if (audioUrl && audioRef.current) {
      audioRef.current.load()
    }
  }, [audioUrl])

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <h2 className="text-xl font-semibold mb-3">Afspelen</h2>
      {audioUrl ? (
        <div className="flex flex-col items-start">
          <audio
            controls
            ref={audioRef}
            className="w-full mb-4"
          >
            <source src={audioUrl} type="audio/mpeg" />
            Je browser ondersteunt geen audio-element.
          </audio>
          <a
            href={audioUrl}
            download="generated.mp3"
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Download MP3
          </a>
        </div>
      ) : (
        <p className="text-gray-500">Er is nog niets gegenereerd.</p>
      )}
    </div>
  )
}

