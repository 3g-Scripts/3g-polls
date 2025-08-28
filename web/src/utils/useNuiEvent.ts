import { useEffect } from 'react'

export const useNuiEvent = <T = any>(action: string, handler: (data: T) => void) => {
  useEffect(() => {
    const l = (e: MessageEvent) => { const m = e.data; if (m && m.action === action) handler(m.data ?? m) }
    window.addEventListener('message', l)
    return () => window.removeEventListener('message', l)
  }, [action, handler])
}
