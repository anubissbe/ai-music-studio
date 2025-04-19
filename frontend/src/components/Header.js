import React from 'react'

export default function Header({ title }) {
  return (
    <header className="mb-8 flex justify-between items-center">
      <h1 className="text-3xl font-bold">{title}</h1>
    </header>
  )
}
