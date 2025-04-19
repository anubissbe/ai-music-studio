import React from 'react'

export default function PromptInput({ prompt, onChange, onGenerate, disabled }) {
  return (
    <section className="bg-white rounded-lg shadow p-6">
      <h2 className="text-xl font-semibold mb-3">Voer je prompt in</h2>
      <textarea
        className="w-full h-32 p-3 border rounded focus:outline-none focus:ring"
        placeholder="Typ je prompt…"
        value={prompt}
        onChange={e => onChange(e.target.value)}
      />
      <button
        onClick={onGenerate}
        disabled={disabled}
        className={
          `mt-4 px-5 py-2 rounded text-white transition ` +
          (disabled
            ? 'bg-gray-400 cursor-not-allowed'
            : 'bg-indigo-600 hover:bg-indigo-700')
        }
      >
        {disabled ? 'Even wachten…' : 'Genereer'}
      </button>
    </section>
  )
}

