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
