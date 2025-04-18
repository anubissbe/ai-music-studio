// frontend/src/components/ModelSelector.js
import React from 'react';

export default function ModelSelector({ models, selected, onChange, loadingLoad }) {
  return (
    <div className="space-y-2">
      {models.map((m) => {
        const isSelected = selected?.id === m.id;
        return (
          <button
            key={m.id}
            onClick={() => onChange(m)}
            disabled={loadingLoad && isSelected}
            className={`block w-full text-left px-4 py-2 rounded-lg transition 
              ${isSelected
                ? m.loaded
                  ? 'bg-green-600 text-white'
                  : 'bg-yellow-500 text-white'
                : 'hover:bg-gray-200 dark:hover:bg-gray-700'}
            `}
          >
            {m.name} {isSelected && !m.loaded && ' (laden…)'}
          </button>
        );
      })}
    </div>
  );
}

