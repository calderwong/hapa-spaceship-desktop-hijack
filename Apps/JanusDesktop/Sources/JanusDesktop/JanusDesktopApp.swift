import SwiftUI
import JanusEngine
import MetalKit

@main
struct JanusDesktopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // We use a dummy Scene because we manage our windows manually in AppDelegate
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var hijackWindow: JanusWindow?
    var appState = AppState()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        appState.setup()
        
        let screen = NSScreen.main!
        let window = JanusWindow(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.level = .mainMenu + 1 // Sit above almost everything
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true // Passthrough by default
        
        let metalView = MTKView(frame: screen.frame)
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        metalView.isPaused = false
        metalView.enableSetNeedsDisplay = false
        
        if let device = metalView.device,
           let heap = appState.heap,
           let capture = appState.capture {
            do {
                let renderer = try JanusRenderer(view: metalView, heap: heap, capture: capture)
                appState.renderer = renderer
            } catch {
                print("Renderer failed: \(error)")
            }
        }
        
        window.contentView = metalView
        window.makeKeyAndOrderFront(nil)
        self.hijackWindow = window
        
        print("Janus: Hijack window deployed.")
    }
}

class JanusWindow: NSWindow {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

class AppState: ObservableObject {
    var heap: JanusHeap?
    var capture: JanusCapture?
    var renderer: JanusRenderer?
    
    func setup() {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        
        do {
            let heap = try JanusHeap(device: device, capacityInGB: 64)
            self.heap = heap
            self.capture = JanusCapture(device: device, heap: heap)
            
            Task {
                try? await capture?.startCapture()
            }
        } catch {
            print("Janus Setup Failed: \(error)")
        }
    }
}
