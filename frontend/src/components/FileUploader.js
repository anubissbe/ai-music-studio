import React, { useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { DocumentIcon, CheckCircleIcon, XMarkIcon } from '@heroicons/react/24/outline';

const FileUploader = ({ onFileUpload, uploadedFile }) => {
  const onDrop = useCallback((acceptedFiles) => {
    if (acceptedFiles.length > 0) {
      onFileUpload(acceptedFiles[0]);
    }
  }, [onFileUpload]);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'audio/mpeg': ['.mp3'],
      'audio/wav': ['.wav'],
      'audio/x-m4a': ['.m4a'],
      'audio/ogg': ['.ogg']
    },
    maxFiles: 1
  });

  return (
    <div className="space-y-4">
      {!uploadedFile ? (
        <div 
          {...getRootProps()} 
          className={`border-2 border-dashed rounded-lg p-6 text-center transition cursor-pointer ${
            isDragActive 
              ? 'border-primary-500 bg-primary-900 bg-opacity-20' 
              : 'border-gray-700 hover:border-gray-500 bg-gray-800 bg-opacity-50'
          }`}
        >
          <input {...getInputProps()} />
          <DocumentIcon className="h-12 w-12 mx-auto text-gray-400" />
          <p className="mt-2 text-sm text-gray-300">
            {isDragActive
              ? "Drop the audio file here..."
              : "Drag & drop an audio file here, or click to select"}
          </p>
          <p className="mt-1 text-xs text-gray-500">
            Supported formats: MP3, WAV, M4A, OGG
          </p>
        </div>
      ) : (
        <div className="bg-gray-800 rounded-lg p-4 flex items-center justify-between">
          <div className="flex items-center">
            <CheckCircleIcon className="h-6 w-6 text-green-500 mr-3" />
            <div>
              <h3 className="font-medium">{uploadedFile.name}</h3>
              <p className="text-xs text-gray-400">
                {(uploadedFile.size / 1024 / 1024).toFixed(2)} MB
              </p>
            </div>
          </div>
          
          <button
            onClick={() => onFileUpload(null)}
            className="p-1 rounded-full hover:bg-gray-700 transition"
          >
            <XMarkIcon className="h-5 w-5 text-gray-400" />
          </button>
        </div>
      )}
    </div>
  );
};

export default FileUploader;
