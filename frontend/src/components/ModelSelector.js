import React from 'react'
import axios from 'axios'

export default function ModelSelector({ models, selectedModel, setSelectedModel }) {
  const [loadingId, setLoadingId] = React.useState(null)

  const handleSelect = async (modelId) => {
    try {
      setLoadingId(modelId)
      await axios.post('/api/models/load', { id: modelId })
      setSelectedModel(modelId)
    } catch (err) {
      console.error(`Kon model ${modelId} niet laden:`, err)
      alert('Laden mislukt, zie console voor details.')
    } finally {
      setLoadingId(null)
    }
  }

  return (
    <nav className="col-span-1 bg-white rounded-lg shadow p-4">
      <h2 className="font-semibold mb-4">Selecteer model</h2>
      <ul>
        {models.map(m => (
          <li key={m.id} className="mb-2">
            <button
              onClick={() => handleSelect(m.id)}
              disabled={loadingId === m.id}
              className={
                `w-full text-left py-2 px-3 rounded transition ` +
                (selectedModel === m.id
                  ? 'bg-indigo-200 font-semibold'
                  : 'hover:bg-indigo-50')
              }
            >
              {m.name}
              {loadingId === m.id && ' (laden…)'}
            </button>
          </li>
        ))}
      </ul>
    </nav>
  )
}

