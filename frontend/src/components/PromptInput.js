import React, { useState } from 'react';

export default function PromptInput({ onGenerate, disabled }) {
  const [text, setText] = useState('');
  return (
    <div>
      <textarea
        value={text}
        onChange={e => setText(e.target.value)}
        className="w-full h-32 p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-400
          dark:bg-gray-700 dark:border-gray-600"
        placeholder="Typ je prompt..."
        disabled={disabled}
      />
      <button
        onClick={() => onGenerate(text)}
        disabled={disabled || !text.trim()}
        className="mt-4 px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition disabled:opacity-50"
      >
        Genereer
      </button>
    </div>
  );
}
