import { useEffect, useMemo, useRef } from 'react'
import { fetchNui } from '../utils/fetchNui'

type Opt = { id: number; label: string; count: number }
type Vote = { id: string; title: string; options: Opt[]; endsAt: number }

const Clock = (p: React.SVGProps<SVGSVGElement>) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" {...p}>
        <path fill="currentColor" d="M12 2a10 10 0 1 0 .001 20.001A10 10 0 0 0 12 2m1 5v4.586l3.293 3.293-1.414 1.414L11 12.414V7z" />
    </svg>
)

export default function Widget({
    votes, interact, onHover, max
}: {
    votes: Map<string, Vote>; interact: boolean; onHover: (on: boolean) => void; max: number
}) {
    const ref = useRef<HTMLDivElement>(null)

    const v = useMemo(() => {
        const now = (Date.now() / 1000) | 0
        return [...votes.values()]
            .filter(x => x.endsAt > now)
            .sort((a, b) => (a.endsAt - b.endsAt) || a.title.localeCompare(b.title))[0]
    }, [votes])

    useEffect(() => {
        const el = ref.current
        if (!el) return
        const enter = () => { if (interact) { onHover(true); fetchNui('hoverOn') } }
        const leave = () => { if (interact) { onHover(false); fetchNui('hoverOff') } }
        el.addEventListener('mouseenter', enter)
        el.addEventListener('mouseleave', leave)
        return () => { el.removeEventListener('mouseenter', enter); el.removeEventListener('mouseleave', leave) }
    }, [interact, onHover])

    useEffect(() => {
        if (!v) return
        const t = setInterval(() => {
            const left = Math.max(0, v.endsAt * 1000 - Date.now())
            const s = (left / 1000) | 0
            const m = String((s / 60) | 0).padStart(2, '0')
            const sec = String(s % 60).padStart(2, '0')
            const n = document.getElementById('sideTime')
            if (n) n.textContent = `${m}:${sec}`
            if (left <= 0) clearInterval(t)
        }, 500)
        return () => clearInterval(t)
    }, [v])

    if (!v) return null
    const total = (v.options || []).reduce((a, b) => a + (b.count || 0), 0) || 1
    const list = (v.options || []).slice(0, max)

    return (
        <div id="sideWidget" ref={ref} className={`side-widget show ${interact ? 'clickable' : ''}`}>
            <div className="side-head">
                <span className="side-title">{v.title}</span>
                <div className="side-right">
                    <span className="side-timer">
                        <Clock className="icon" />
                        <span id="sideTime">--:--</span>
                    </span>
                </div>
            </div>

            <div id="sideContent" className="side-content">
                {list.map(o => {
                    const pct = Math.round(((o.count || 0) * 100) / total)
                    return (
                        <div
                            key={o.id}
                            className="side-item"
                            onClick={() => interact && fetchNui('submitVote', { id: v.id, option: o.id })}
                        >
                            <div className="side-left">
                                <div className="side-label">{o.label}</div>
                                <div className="side-bar"><div className="side-fill" style={{ width: `${pct}%` }} /></div>
                            </div>
                            <div className="side-count">{o.count || 0}</div>
                        </div>
                    )
                })}
            </div>
        </div>
    )
}
