export const fetchNui = <T = any>(eventName: string, data?: any): Promise<T> =>
  new Promise((resolve) => {
    if (!('GetParentResourceName' in window)) return resolve({} as T)
    fetch(`https://${(window as any).GetParentResourceName()}/${eventName}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data ?? {})
    })
      .then(r => r.json())
      .then(resolve)
      .catch(() => resolve({} as T))
  })
