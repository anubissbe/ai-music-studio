import React from 'react';

export default function MusicPlayer({ src, loading }) {
  if (loading) return <div>Laden…</div>;
  if (!src)   return <div>Er is nog niets gegenereerd.</div>;
  return (
    <audio controls src={src} className="w-full">
      Je browser ondersteunt geen audio.
    </audio>
  );
}
