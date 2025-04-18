import React from 'react';

export default function Header() {
  return (
    <header className="bg-white dark:bg-gray-800 shadow">
      <div className="container mx-auto px-4 py-4 flex items-center justify-between">
        <h1 className="text-2xl font-bold">🎵 AI Music Studio</h1>
        <nav className="space-x-4">
          <a href="#" className="hover:text-indigo-600">Home</a>
          <a href="#" className="hover:text-indigo-600">Docs</a>
          <a href="#" className="hover:text-indigo-600">About</a>
        </nav>
      </div>
    </header>
  );
}
