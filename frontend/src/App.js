import React, { useState, useEffect } from 'react';
import axios from 'axios';

function App() {
  const [models, setModels] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Probeer de API te benaderen om te zien of het werkt
    async function fetchModels() {
      try {
        const response = await axios.get('/api/models');
        setModels(response.data.models || []);
      } catch (error) {
        console.error('Error fetching models:', error);
      } finally {
        setLoading(false);
      }
    }

    fetchModels();
  }, []);

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <header className="bg-gray-800 p-4 shadow-md">
        <div className="container mx-auto">
          <h1 className="text-2xl font-bold">AI Music Studio</h1>
        </div>
      </header>
      
      <main className="container mx-auto p-4">
        <div className="bg-gray-800 rounded-lg p-6 shadow-lg">
          <h2 className="text-xl font-semibold mb-4">Welkom bij de AI Music Studio</h2>
          
          <p className="mb-4">
            Dit is een eenvoudige first-run pagina om te controleren of de webapp correct is opgezet.
          </p>
          
          <div className="mt-6">
            <h3 className="font-medium mb-2">Status:</h3>
            <ul className="space-y-1 text-sm">
              <li className="flex items-center">
                <span className={`w-3 h-3 rounded-full mr-2 ${loading ? 'bg-yellow-500' : 'bg-green-500'}`}></span>
                <span>Frontend: Actief</span>
              </li>
              <li className="flex items-center">
                <span className={`w-3 h-3 rounded-full mr-2 ${models.length > 0 ? 'bg-green-500' : 'bg-red-500'}`}></span>
                <span>Backend API: {models.length > 0 ? 'Verbonden' : 'Niet verbonden'}</span>
              </li>
            </ul>
          </div>
          
          {models.length > 0 && (
            <div className="mt-6">
              <h3 className="font-medium mb-2">Beschikbare AI Modellen:</h3>
              <ul className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {models.map((model) => (
                  <li key={model.id} className="bg-gray-700 p-3 rounded-lg">
                    <h4 className="font-medium">{model.name}</h4>
                    <p className="text-sm text-gray-300">{model.description}</p>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

export default App;
