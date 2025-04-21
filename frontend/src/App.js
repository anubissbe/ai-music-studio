import React, { useState, useEffect } from 'react'
import axios from 'axios'

function App() {
  const [models, setModels]             = useState([])
  const [selectedModel, setSelectedModel] = useState(null)
  const [prompt, setPrompt]             = useState('')
  const [duration, setDuration]         = useState(30)
  const [vocals, setVocals]             = useState(true)
  const [selectedFile, setSelectedFile] = useState(null)
  const [audioUrl, setAudioUrl]         = useState(null)
  const [loading, setLoading]           = useState(false)
  const [error, setError]               = useState(null)

  useEffect(() => {
    axios.get('/api/models')
      .then(res => setModels(res.data))
      .catch(err => {
        console.error('Models ophalen mislukt:', err);
        setError('Failed to fetch models');
      })
  }, [])

  const selectModel = async (id) => {
    if (selectedModel) {
      try { await axios.post('/api/models/unload', { id: selectedModel }) }
      catch (_) {}
    }
    try {
      await axios.post('/api/models/load', { id })
      setSelectedModel(id)
      setError(null)
    } catch (e) {
      console.error('Load failed for', id, e)
      setSelectedModel(null)
      setError(`Failed to load model: ${id}`)
    }
  }

  const generate = async () => {
    if (!selectedModel || !prompt.trim()) return
    setLoading(true)
    setError(null)
    
    // Make sure filename includes the .wav extension
    const filename = `${selectedModel}-${Date.now()}.wav`

    try {
      console.log("Sending generation request with filename:", filename)
      const res = await axios.post('/api/generate', {
        contentPrompt: prompt,
        stylePrompt:    '',
        hasVocals:      vocals,
        outputPath:     filename
      })
      
      console.log("Generation response:", res.data)
      
      if (res.data.error) {
        throw new Error(res.data.error)
      }
      
      // Check both possible response formats
      const outputPath = res.data.outputPath || filename
      console.log("Setting audio URL to:", `/api/output/${outputPath}`)
      
      // Add a small delay to ensure file is written to disk
      setTimeout(() => {
        setAudioUrl(`/api/output/${outputPath}`)
      }, 1000)
      
    } catch (e) {
      console.error('Genereren mislukt:', e)
      setError(`Generation failed: ${e.message}`)
      setAudioUrl(null)
    } finally {
      setLoading(false)
    }
  }

  const remix = async () => {
    if (!selectedModel || !selectedFile) return
    setLoading(true)
    setError(null)
    
    const form = new FormData()
    form.append('file',     selectedFile)
    form.append('prompt',   prompt)
    form.append('duration', duration)
    form.append('vocals',   vocals)

    try {
      const res = await axios.post('/api/remix', form)
      console.log("Remix response:", res.data)
      
      if (res.data.error) {
        throw new Error(res.data.error)
      }
      
      // Check both possible response formats
      const outputPath = res.data.outputPath || `${selectedModel}-remix-${Date.now()}.wav`
      
      // Add a small delay to ensure file is written to disk
      setTimeout(() => {
        setAudioUrl(`/api/output/${outputPath}`)
      }, 1000)
    } catch (e) {
      console.error('Remixen mislukt:', e)
      setError(`Remix failed: ${e.message}`)
      setAudioUrl(null)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-100 p-6">
      <header className="mb-8 flex justify-between items-center">
        <h1 className="text-3xl font-bold">🎵 AI Music Studio</h1>
      </header>

      <div className="grid grid-cols-4 gap-6">
        <nav className="col-span-1 bg-white rounded-lg shadow p-4">
          <h2 className="font-semibold mb-4">Selecteer model</h2>
          <ul>
            {models.map(id => (
              <li key={id} className="mb-2">
                <button
                  onClick={() => selectModel(id)}
                  className={`w-full text-left py-2 px-3 rounded transition ${
                    selectedModel === id
                      ? 'bg-indigo-200 font-semibold'
                      : 'hover:bg-indigo-50'
                  }`}
                >{id}</button>
              </li>
            ))}
          </ul>
        </nav>

        <main className="col-span-3 space-y-6">
          {error && (
            <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
              <p>{error}</p>
            </div>
          )}
          
          <section className="bg-white rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-3">Voer je prompt in</h2>
            <textarea
              className="w-full h-32 p-3 border rounded focus:outline-none focus:ring"
              placeholder="Bijv: a summer dance hit"
              value={prompt}
              onChange={e => setPrompt(e.target.value)}
            />
            <div className="mt-2 flex gap-4 items-center">
              <input
                type="number"
                min="5" max="120"
                value={duration}
                onChange={e => setDuration(+e.target.value)}
                className="w-24 border rounded px-2 py-1"
              />
              <label className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={vocals}
                  onChange={e => setVocals(e.target.checked)}
                />
                Met zang
              </label>
              <input
                type="file"
                accept="audio/*"
                onChange={e => setSelectedFile(e.target.files[0])}
              />
            </div>

            <div className="mt-4 flex gap-4">
              <button
                onClick={generate}
                disabled={loading || !selectedModel || !prompt.trim()}
                className={`px-5 py-2 rounded text-white transition ${
                  loading
                    ? 'bg-gray-400 cursor-not-allowed'
                    : 'bg-indigo-600 hover:bg-indigo-700'
                }`}
              >
                {loading ? 'Genereren…' : 'Genereer'}
              </button>
              <button
                onClick={remix}
                disabled={loading || !selectedModel || !selectedFile}
                className={`px-5 py-2 rounded text-white transition ${
                  loading
                    ? 'bg-gray-400 cursor-not-allowed'
                    : 'bg-green-600 hover:bg-green-700'
                }`}
              >
                Remix
              </button>
            </div>
          </section>

          <section className="bg-white rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-3">Afspelen</h2>
            {audioUrl ? (
              <div>
                <audio controls src={audioUrl} className="w-full" />
                <p className="mt-2 text-sm text-gray-500">
                  Audio URL: {audioUrl} - If audio doesn't play, check the server logs
                </p>
              </div>
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
