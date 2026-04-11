import { useQuery } from '@tanstack/react-query'
import { get } from '../api'

export default function Home() {
  const { data, isLoading } = useQuery({
    queryKey: ['examples'],
    queryFn: () => get('/api/examples'),
  })

  return (
    <div className="min-h-screen bg-base-200 p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold mb-6">{{name}}</h1>
        {isLoading ? (
          <span className="loading loading-spinner loading-lg" />
        ) : (
          <div className="grid gap-4">
            {data?.data?.map(item => (
              <div key={item.id} className="card bg-base-100 shadow">
                <div className="card-body">
                  <h2 className="card-title">{item.name}</h2>
                  <p>{item.description}</p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
