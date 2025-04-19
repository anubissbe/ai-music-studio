import React from 'react'

export default function MusicPlayer({ audioUrl }) {
  return (
    <div className="bg-white rounded-lg shadow p-6">
      <h2 className="text-xl font-semibold mb-3">Afspelen</h2>
      {audioUrl ? (
        <audio controls src={audioUrl} className="w-full" />
      ) : (
        <p className="text-gray-500">Er is nog niets gegenereerd.</p>
      )}
    </div>
  )
}
