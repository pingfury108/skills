const BASE = '/api'

const authHeaders = () => ({ 'X-Admin-Key': localStorage.getItem('adminKey') || '' })

const get = (url) =>
  fetch(url, { headers: authHeaders() }).then(r => r.json())

const post = (url, body) =>
  fetch(url, {
    method: 'POST',
    headers: { ...authHeaders(), ...(body instanceof FormData ? {} : { 'Content-Type': 'application/json' }) },
    body: body instanceof FormData ? body : JSON.stringify(body),
  }).then(r => r.json())

const del = (url) =>
  fetch(url, { method: 'DELETE', headers: authHeaders() }).then(r => r.json())

export { BASE, get, post, del }
