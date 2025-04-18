import React, { useState, useEffect } from 'react'
import axios from 'axios'

function App() {
  const [models, setModels] = useState([])
  const [selectedModel, setSelectedModel] = useState(null)
  const [prompt, setPrompt] = useState('')
  const [audioUrl, setAudioUrl] = useState(null)
  const [loading, setLoading] = useState(false)

  // bij load: haal alle modellen op
  useEffect(() => {
    axios
      .get('/api/models')
      .then(res => setModels(res.data))
      .catch(err => console.error('Models ophalen mislukt:', err))
  }, [])

  const generate = () => {
    if (!selectedModel || !prompt) return
    setLoading(true)
    axios
      .post(
        '/api/generate',
        { model: selectedModel, prompt },
        { responseType: 'arraybuffer' }
      )
      .then(res => {
        const blob = new Blob([res.data], { type: 'audio/wav' })
        setAudioUrl(URL.createObjectURL(blob))
      })
      .catch(err => console.error('Genereren mislukt:', err))
      .finally(() => setLoading(false))
  }

  return (
    <div className="min-h-screen bg-gray-100 p-6">
      <header className="mb-8 flex justify-between items-center">
        <h1 className="text-3xl font-bold">🎵 AI Music Studio</h1>
      </header>

      <div className="grid grid-cols-4 gap-6">
        {/* SIDEBAR */}
        <nav className="col-span-1 bg-white rounded-lg shadow p-4">
          <h2 className="font-semibold mb-4">Selecteer model</h2>
          <ul>
            {models.map(m => (
              <li key={m.id} className="mb-2">
                <button
                  onClick={() => setSelectedModel(m.id)}
                  className={
                    `w-full text-left py-2 px-3 rounded transition ` +
                    (selectedModel === m.id
                      ? 'bg-indigo-200 font-semibold'
                      : 'hover:bg-indigo-50')
                  }
                >
                  {m.name}
                </button>
              </li>
            ))}
          </ul>
        </nav>

        {/* MAIN CONTENT */}
        <main className="col-span-3 space-y-6">
          {/* PROMPT SECTION */}
          <section className="bg-white rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-3">Voer je prompt in</h2>
            <textarea
              className="w-full h-32 p-3 border rounded focus:outline-none focus:ring"
              placeholder="Typ je prompt…"
              value={prompt}
              onChange={e => setPrompt(e.target.value)}
            />
            <button
              onClick={generate}
              disabled={loading || !selectedModel || !prompt}
              className={
                `mt-4 px-5 py-2 rounded text-white transition ` +
                (loading
                  ? 'bg-gray-400 cursor-not-allowed'
                  : 'bg-indigo-600 hover:bg-indigo-700')
              }
            >
              {loading ? 'Genereren…' : 'Genereer'}
            </button>
          </section>

          {/* AUDIO PLAYER SECTION */}
          <section className="bg-white rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-3">Afspelen</h2>
            {audioUrl ? (
              <audio controls src={audioUrl} className="w-full" />
            ) : (
              <p className="text-gray-500">Er is nog niets gegenereerd.</p>
            )}
          </section>
        </main>
      </div>
    </div>
  )
}

export default App

