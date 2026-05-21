import { useState, useRef, useEffect } from 'react'
import './App.css'

// IPC bridge for Monolith interaction (if running in Electron)
// (Used within useEffect for sync checks)

interface Attachment {
  id: string;
  name: string;
  type: 'image' | 'video' | 'shader' | 'data';
  size?: string;
}

interface ElectronHeapBridge {
  read: (offset: number, length: number) => Promise<unknown>;
  write: (offset: number, buffer: Uint8Array) => Promise<boolean>;
}

declare global {
  interface Window {
    electron?: {
      heap: ElectronHeapBridge;
      system: {
        getPlatform: () => Promise<string> | string;
        getMemoryInfo: () => Promise<unknown> | unknown;
      };
    };
  }
}

function App() {
  const [text, setText] = useState('')
  const [isFocused, setIsRefocused] = useState(true)
  const [heapSync, setHeapSync] = useState<'LOCKED' | 'DRIFTING' | 'LOST'>('LOCKED')
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  
  const [attachments] = useState<Attachment[]>([
    { id: '1', name: 'SCREEN_TRUTH.PNG', type: 'image', size: '4.2MB' },
    { id: '2', name: 'METAL_SHADER.METALLIB', type: 'shader', size: '12KB' },
    { id: '3', name: 'HEAP_SNAPSHOT.BIN', type: 'data', size: '128GB' }
  ])

  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto'
      textareaRef.current.style.height = `${textareaRef.current.scrollHeight}px`
    }
  }, [text])

  // Check for Monolith Sync on Mount
  useEffect(() => {
    const checkSync = async () => {
      try {
        const result = await window.electron?.heap.read(0, 1);
        if (result !== undefined) {
          setHeapSync('LOCKED');
        } else {
          setHeapSync('LOST');
        }
      } catch {
        setHeapSync('LOST');
      }
    };
    
    checkSync();
    const interval = setInterval(checkSync, 5000);
    return () => clearInterval(interval);
  }, []);

  return (
    <main className="manifold-container">
      {/* Background Manifold Status (Subtle) */}
      <div className="manifold-status-bar reveal-fade">
        <div className="status-item">
          <span className="label">SYNC:</span>
          <span className={`value status-${heapSync.toLowerCase()}`}>{heapSync}</span>
        </div>
        <div className="status-item">
          <span className="label">HEAP:</span>
          <span className="value">128GB / 512GB</span>
        </div>
        <div className="status-item">
          <span className="label">FPS:</span>
          <span className="value">120</span>
        </div>
      </div>

      <div id="janus-compose-surface" className={`${isFocused ? 'focused' : ''} reveal-slide-up`}>
        <div className="compose-header">
          <div className="brand">
            <span className="sigil animate-neon-breathe">⌬</span>
            <span>PROJECT: JANUS // COMPOSE</span>
          </div>
          <div className="mode-indicator">PHASE 6 // GRAVITY_UI</div>
        </div>
        
        <div className="compose-container">
          <textarea 
            ref={textareaRef}
            className="compose-input-area"
            placeholder="Type to cast into the manifold..."
            value={text}
            onChange={(e) => setText(e.target.value)}
            onFocus={() => setIsRefocused(true)}
            onBlur={() => setIsRefocused(false)}
            autoFocus
          />
          
          <div className="attachment-ribbon">
            {attachments.map(at => (
              <div key={at.id} className="attachment-token" title={`${at.name} (${at.size})`}>
                <AttachmentIcon type={at.type} />
                <span className="at-name">{at.name}</span>
                <span className="at-size">{at.size}</span>
              </div>
            ))}
            <button className="add-attachment-btn" data-tooltip="Add context (⌘+I)">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                <line x1="12" y1="5" x2="12" y2="19" />
                <line x1="5" y1="12" x2="19" y2="12" />
              </svg>
            </button>
          </div>
        </div>

        <div className="compose-footer">
          <div className="shortcuts">
            <kbd>⌘</kbd> + <kbd>↵</kbd> CAST
          </div>
          <div className="token-count">
            {text.length > 0 ? `${text.length} chars` : '0 tokens'}
          </div>
        </div>
      </div>
      
      {/* Subtle Hallucination Grid (Decoration) */}
      <div className="manifold-grid-overlay" />
    </main>
  )
}

function AttachmentIcon({ type }: { type: Attachment['type'] }) {
  switch (type) {
    case 'image':
      return (
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
          <circle cx="8.5" cy="8.5" r="1.5" />
          <polyline points="21 15 16 10 5 21" />
        </svg>
      )
    case 'shader':
      return (
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <polygon points="12 2 2 7 12 12 22 7 12 2" />
          <polyline points="2 17 12 22 22 17" />
          <polyline points="2 12 12 17 22 12" />
        </svg>
      )
    case 'data':
      return (
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <ellipse cx="12" cy="5" rx="9" ry="3" />
          <path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3" />
          <path d="M3 5v14c0 1.66 4 3 9 3s9-1.34-9-3V5" />
        </svg>
      )
    default:
      return null
  }
}

export default App
