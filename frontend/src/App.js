import React, { useState, useEffect } from 'react'
import axios from 'axios'
import ModelSelector from './components/ModelSelector'
import PromptInput   from './components/PromptInput'
import MusicPlayer   from './components/MusicPlayer'
import Header        from './components/Header'

function App() {
  const [models, setModels] = useState([])
  const [selectedModel, setSelectedModel] = useState(null)
  const [prompt, setPrompt] = useState('')
  const [trackId, setTrackId] = useState(null)
  const [audioUrl, setAudioUrl] = useState(null)
  const [generating, setGenerating] = useState(false)

  // 1) bij mount: haal alle modellen op
  useEffect(() => {
    axios
      .get('/api/models')
      .then(res => setModels(res.data))
      .catch(err => console.error('Models ophalen mislukt:', err))
  }, [])

  // 2) genereer muziek
  const generate = async () => {
    if (!selectedModel || !prompt) return
    try {
      setGenerating(true)
      // a) POST naar generate => track ID
      const res = await axios.post('/api/generate', { model: selectedModel, prompt })
      const id  = res.data.id
      setTrackId(id)
      // b) GET audio als Blob
      const audioRes = await axios.get(`/api/tracks/${id}/audio?format=wav`, { responseType: 'blob' })
      setAudioUrl(URL.createObjectURL(audioRes.data))
    } catch (err) {
      console.error('Genereren mislukt:', err)
      alert('Genereren mislukt, zie console.')
    } finally {
      setGenerating(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-100 p-6">
      <Header title="🎵 AI Music Studio" />

      <div className="grid grid-cols-4 gap-6">
        <ModelSelector
          models={models}
          selectedModel={selectedModel}
          setSelectedModel={setSelectedModel}
        />

        <main className="col-span-3 space-y-6">
          <PromptInput
            prompt={prompt}
            onChange={setPrompt}
            onGenerate={generate}
            disabled={!selectedModel || generating}
          />

          <MusicPlayer audioUrl={audioUrl} />
        </main>
      </div>
    </div>
  )
}

export default App

