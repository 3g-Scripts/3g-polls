import { useMemo, useState } from 'react'
import { useNuiEvent } from './utils/useNuiEvent'
import { fetchNui } from './utils/fetchNui'
import Widget from './components/Widget'
import CreateModal from './components/CreateModal'
import Toast from './components/Toast'
import './index.css'

type Opt = { id: number; label: string; count: number }
type Vote = { id: string; title: string; options: Opt[]; endsAt: number }

export default function App() {
    const [votes, setVotes] = useState<Map<string, Vote>>(new Map())
    const [widgetOn, setWidgetOn] = useState(true)
    const [interact, setInteract] = useState(false)
    const [max, setMax] = useState(5)
    const [toast, setToast] = useState<string | null>(null)
    const [showCreate, setShowCreate] = useState(false)

    useNuiEvent('config', (d: any) => setMax(Math.max(1, d.widgetMax || 5)))
    useNuiEvent('setWidget', (d: any) => setWidgetOn(!!d.on))
    useNuiEvent('hideWidget', () => { setVotes(new Map()); setWidgetOn(false) })
    useNuiEvent('setInteract', (d: any) => setInteract(!!d.on))
    useNuiEvent('announce', (d: any) => { setToast(d.text || 'New vote — type /vote'); setTimeout(() => setToast(null), 3000) })
    useNuiEvent('syncVote', (m: any) => setVotes(prev => { const v = m.data as Vote; const n = new Map(prev); n.set(v.id, v); return n }))
    useNuiEvent('syncVotes', (m: any) => { const n = new Map<string, Vote>(); (m.data || []).forEach((v: Vote) => n.set(v.id, v)); setVotes(n) })
    useNuiEvent('openCreate', () => setShowCreate(true))
    useNuiEvent('closeAll', () => setShowCreate(false))

    const widget = useMemo(() => (widgetOn ? <Widget votes={votes} interact={interact} onHover={() => { }} max={max} /> : null), [votes, widgetOn, interact, max])

    return (
        <>
            {widget}
            {toast && <Toast text={toast} />}
            {showCreate && <CreateModal onClose={() => { setShowCreate(false); fetchNui('close') }} />}
        </>
    )
}
