// frontend/src/App.js

import React, { useState, useEffect } from 'react'
import axios from 'axios'
import './App.css'

function App() {
  const [models, setModels] = useState([])
  const [selectedModel, setSelectedModel] = useState('')

  useEffect(() => {
    axios.get('/api/models')
      .then(({ data }) => {
        console.log('Fetched models:', data)
        setModels(data)
      })
      .catch(err => {
        console.error('Error fetching models:', err)
      })
  }, [])

  return (
    <div className="App">
      <header className="App-header">
        <h1>AI Music Studio</h1>
      </header>

      <main>
        <label htmlFor="model-select">Kies een model:</label>
        <select
          id="model-select"
          value={selectedModel}
          onChange={e => setSelectedModel(e.target.value)}
        >
          <option value="" disabled>– selecteer hier –</option>
          {models.map(model => (
            <option key={model.id} value={model.id}>
              {model.name}
            </option>
          ))}
        </select>

        {selectedModel && (
          <p>
            Je hebt gekozen: <strong>{selectedModel}</strong>
          </p>
        )}
      </main>
    </div>
  )
}

export default App

