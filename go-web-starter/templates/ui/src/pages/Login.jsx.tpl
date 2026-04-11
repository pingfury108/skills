import { useState } from 'react'
import { useNavigate } from 'react-router-dom'

export default function Login() {
  const [key, setKey] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const navigate = useNavigate()

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      const r = await fetch('/api/auth/validate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ key }),
      })
      const data = await r.json()
      if (data.success && data.data?.valid) {
        localStorage.setItem('adminKey', key)
        navigate('/')
      } else {
        setError('密钥无效')
      }
    } catch {
      setError('请求失败，请重试')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-base-200">
      <div className="card w-96 bg-base-100 shadow-xl">
        <div className="card-body">
          <h2 className="card-title justify-center">{{name}}</h2>
          <form onSubmit={handleSubmit} className="flex flex-col gap-4 mt-4">
            <input
              type="password"
              placeholder="Admin Key"
              className="input input-bordered w-full"
              value={key}
              onChange={e => setKey(e.target.value)}
              required
            />
            {error && <p className="text-error text-sm">{error}</p>}
            <button type="submit" className="btn btn-primary" disabled={loading}>
              {loading ? <span className="loading loading-spinner" /> : '登录'}
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}
