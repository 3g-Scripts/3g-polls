export default function Toast({ text }: { text: string }) {
    return (
        <div className="toast show">
            <div className="toast-title">{text}</div>
        </div>
    )
}
