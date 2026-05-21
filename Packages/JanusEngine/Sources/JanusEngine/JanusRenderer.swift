import MetalKit
import JanusEngine

/**
 * JANUS RENDERER
 * 
 * Handles the Metal render loop for the hijack surface.
 * Implements the "Truth" pass and prepares for "Trinity" stereo derivation.
 */
public final class JanusRenderer: NSObject, MTKViewDelegate {
    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    private let heap: JanusHeap
    private let capture: JanusCapture
    
    public init(view: MTKView, heap: JanusHeap, capture: JanusCapture) throws {
        self.device = view.device!
        self.commandQueue = device.makeCommandQueue()!
        self.heap = heap
        self.capture = capture
        
        let library = try device.makeDefaultLibrary(bundle: Bundle.module)
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "janus_vertex")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "janus_fragment")
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        super.init()
        view.delegate = self
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    public func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // Phase 1: Draw the "Truth" desktop texture
        // In a real implementation, JanusCapture would provide the current frame texture
        // from the Shared Heap.
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        commandBuffer.commit()
    }
}
