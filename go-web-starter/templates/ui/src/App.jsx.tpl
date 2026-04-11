import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { useEffect, useState } from 'react'
import Login from './pages/Login'
import Home from './pages/Home'

function RequireAuth({ children }) {
  return localStorage.getItem('adminKey') ? children : <Navigate to="/login" replace />
}

function App() {
  const [verified, setVerified] = useState(false)

  useEffect(() => {
    const key = localStorage.getItem('adminKey')
    if (!key) {
      setVerified(true)
      return
    }
    fetch('/api/auth/validate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ key }),
    })
      .then(r => r.json())
      .then(data => {
        if (!data.success || !data.data?.valid) {
          localStorage.removeItem('adminKey')
        }
      })
      .catch(() => {})
      .finally(() => setVerified(true))
  }, [])

  if (!verified) return null

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/" element={<RequireAuth><Home /></RequireAuth>} />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
