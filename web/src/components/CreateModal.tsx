import { useState } from 'react'
import { fetchNui } from '../utils/fetchNui'

const Plus = (p: React.SVGProps<SVGSVGElement>) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" {...p}>
        <path fill="currentColor" d="M11 11V5h2v6h6v2h-6v6h-2v-6H5v-2z" />
    </svg>
)
const Check = (p: React.SVGProps<SVGSVGElement>) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" {...p}>
        <path fill="currentColor" d="m9 16.17-3.88-3.88L3.71 13.7 9 19l12-12-1.41-1.41z" />
    </svg>
)
const Trash = (p: React.SVGProps<SVGSVGElement>) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" {...p}>
        <path fill="currentColor" d="M6 7h12v13a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2zm3-5h6l1 2h4v2H4V4h4z" />
    </svg>
)
const Close = (p: React.SVGProps<SVGSVGElement>) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" {...p}>
        <path fill="currentColor" d="m18.3 5.7-12.6 12.6 1.4 1.4L19.7 7.1zM7.1 5.7 5.7 7.1 18.3 19.7l1.4-1.4z" />
    </svg>
)

export default function CreateModal({ onClose }: { onClose: () => void }) {
    const [title, setTitle] = useState('')
    const [duration, setDuration] = useState(300)
    const [opts, setOpts] = useState<string[]>(['', ''])

    const add = () => setOpts((p) => [...p, ''])
    const setAt = (i: number, v: string) => setOpts((p) => p.map((x, k) => (k === i ? v : x)))
    const rem = (i: number) => setOpts((p) => (p.length > 2 ? p.filter((_, k) => k !== i) : p))

    const create = async () => {
        const options = opts.map(s => s.trim()).filter(Boolean)
        if (!title.trim() || options.length < 2) return
        await fetchNui('createVote', { title: title.trim(), duration, options })
        onClose()
    }

    return (
        <div className="create-overlay active">
            <div className="create-modal">
                <div className="create-header">
                    <h2>Create Vote</h2>
                    <button className="create-close" onClick={onClose} aria-label="Close">
                        <Close />
                    </button>
                </div>
                <div className="create-body">
                    <div className="form-grid">
                        <div className="form-group">
                            <label>Title</label>
                            <input value={title} onChange={e => setTitle(e.target.value)} placeholder="Enter vote title" />
                        </div>
                        <div className="form-group">
                            <label>Duration (sec)</label>
                            <input
                                type="number" min={30} max={3600}
                                value={duration}
                                onChange={e => setDuration(parseInt(e.target.value || '0', 10))}
                            />
                        </div>
                    </div>

                    <div className="options-container">
                        {opts.map((v, i) => (
                            <div key={i} className="option-row">
                                <input value={v} onChange={e => setAt(i, e.target.value)} placeholder="Option" />
                                <button className="remove" onClick={() => rem(i)} aria-label="Remove">
                                    <Trash />
                                </button>
                            </div>
                        ))}
                    </div>

                    <div className="panel-actions">
                        <button className="btn secondary" onClick={add}><Plus />Add</button>
                        <button className="btn primary" onClick={create}><Check />Create</button>
                    </div>
                </div>
            </div>
        </div>
    )
}
