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
