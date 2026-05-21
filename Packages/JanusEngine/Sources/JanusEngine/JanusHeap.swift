import Metal
import Foundation
import POSIX

/**
 * THE MONOLITH
 * 
 * Canonical Shared Heap for Project Janus.
 * Implements Zero-Copy doctrine via a single large MTLBuffer
 * backed by a POSIX shared memory segment for multi-process access.
 */
public final class JanusHeap {
    public let device: MTLDevice
    public let buffer: MTLBuffer
    public let capacity: Int
    public let shmName: String
    
    private let allocationLock = NSLock()
    private var offset: Int = 0
    private let baseAddress: UnsafeMutableRawPointer
    
    public init(device: MTLDevice, capacityInGB: Int = 64, name: String = "/janus_monolith") throws {
        self.device = device
        self.capacity = capacityInGB * 1024 * 1024 * 1024
        self.shmName = name
        
        // 1. Create/Open POSIX shared memory
        let fd = shm_open(shmName, O_RDWR | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR)
        guard fd != -1 else {
            throw JanusError.shmOpenFailed(Int32(errno))
        }
        
        // 2. Set size
        guard ftruncate(fd, off_t(capacity)) == 0 else {
            throw JanusError.shmTruncateFailed(Int32(errno))
        }
        
        // 3. Map into process
        guard let address = mmap(nil, capacity, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0),
              address != MAP_FAILED else {
            throw JanusError.mmapFailed(Int32(errno))
        }
        self.baseAddress = address
        
        // 4. Create Metal Buffer from shared memory pointer
        guard let buffer = device.makeBuffer(bytes: address, length: capacity, options: .storageModeShared, deallocator: nil) else {
            throw JanusError.heapAllocationFailed
        }
        self.buffer = buffer
        
        // 5. Export to C++ bridge for local process access
        janus_set_heap_info(address, UInt64(capacity))
        
        print("JanusHeap: Allocated \(capacityInGB)GB Monolith at \(address) [SHM: \(shmName)]")
    }
    
    public func allocate(bytes: Int, alignment: Int = 16) -> Int? {
        allocationLock.lock()
        defer { allocationLock.unlock() }
        
        let alignedOffset = (offset + alignment - 1) & ~(alignment - 1)
        if alignedOffset + bytes > capacity {
            return nil
        }
        
        let result = alignedOffset
        offset = alignedOffset + bytes
        return result
    }
    
    public enum JanusError: Error {
        case shmOpenFailed(Int32)
        case shmTruncateFailed(Int32)
        case mmapFailed(Int32)
        case heapAllocationFailed
    }
}
