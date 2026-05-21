import ScreenCaptureKit
import MetalKit
import CoreGraphics

/**
 * JANUS CAPTURE
 * 
 * Hijacks the desktop stream using ScreenCaptureKit.
 * Feeds frames into the Shared Heap as Metal textures.
 */
public final class JanusCapture: NSObject, SCStreamOutput {
    private var stream: SCStream?
    public let device: MTLDevice
    private let heap: JanusHeap
    
    // Handle for the desktop texture in the Shared Heap
    public private(set) var desktopTextureHandle: Int?
    
    private var textureDescriptor: MTLTextureDescriptor?
    private var texture: MTLTexture?
    
    public init(device: MTLDevice, heap: JanusHeap) {
        self.device = device
        self.heap = heap
        super.init()
    }
    
    public func startCapture() async throws {
        let content = try await SCShareableContent.current
        guard let display = content.displays.first else { return }
        
        let filter = SCContentFilter(display: display, excludingWindows: [])
        let config = SCStreamConfiguration()
        config.width = display.width
        config.height = display.height
        config.minimumFrameInterval = CMTime(value: 1, timescale: 60)
        config.pixelFormat = kCVPixelFormatType_32BGRA
        config.queueDepth = 5
        
        // Pre-allocate space in the Heap for the desktop texture
        // RGBA8 = 4 bytes per pixel
        let bytesPerRow = display.width * 4
        let totalBytes = bytesPerRow * display.height
        
        if let handle = heap.allocate(bytes: totalBytes, alignment: 256) {
            self.desktopTextureHandle = handle
            
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                   width: display.width,
                                                                   height: display.height,
                                                                   mipmapped: false)
            descriptor.storageMode = .shared
            descriptor.usage = [.shaderRead, .shaderWrite]
            self.textureDescriptor = descriptor
            
            // Map the texture to the pre-allocated region of the Shared Heap
            self.texture = heap.buffer.makeTexture(descriptor: descriptor, 
                                                  offset: handle, 
                                                  bytesPerRow: bytesPerRow)
        }
        
        stream = SCStream(filter: filter, configuration: config, delegate: nil)
        try stream?.addStreamOutput(self, type: .screen, sampleHandlerQueue: .main)
        try await stream?.startCapture()
        
        print("JanusCapture: Started desktop hijack at \(display.width)x\(display.height) (Heap offset: \(desktopTextureHandle ?? -1))")
    }
    
    public func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Zero-Copy Phase 1: Map IOSurface directly to Metal Texture
        // Instead of memcpy, we use the IOSurface from the pixel buffer.
        guard let surface = CVPixelBufferGetIOSurface(pixelBuffer)?.takeUnretainedValue() else {
            return
        }
        
        let width = IOSurfaceGetWidth(surface)
        let height = IOSurfaceGetHeight(surface)
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                               width: width,
                                                               height: height,
                                                               mipmapped: false)
        descriptor.storageMode = .shared
        descriptor.usage = [.shaderRead, .shaderWrite]
        
        // This is a direct mapping of the IOSurface memory to a Metal texture.
        // No CPU copy is involved.
        if let newTexture = device.makeTexture(descriptor: descriptor, iosurface: surface, plane: 0) {
            self.texture = newTexture
            // We still update the desktopTextureHandle region if other agents 
            // expect the raw bytes, but the renderer can now use the IOSurface texture directly.
        }
    }
}
