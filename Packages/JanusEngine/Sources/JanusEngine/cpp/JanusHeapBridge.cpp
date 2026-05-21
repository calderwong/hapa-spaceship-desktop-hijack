#include "JanusHeapBridge.h"
#include <mutex>

static JanusHeapInfo global_heap_info = {nullptr, 0};
static std::mutex heap_mutex;

extern "C" void janus_set_heap_info(void* base, uint64_t cap) {
    std::lock_guard<std::mutex> lock(heap_mutex);
    global_heap_info.base_address = base;
    global_heap_info.capacity = cap;
}

JanusHeapInfo janus_get_heap_info() {
    std::lock_guard<std::mutex> lock(heap_mutex);
    return global_heap_info;
}

void* janus_heap_resolve(uint32_t handle) {
    std::lock_guard<std::mutex> lock(heap_mutex);
    if (!global_heap_info.base_address || handle >= global_heap_info.capacity) {
        return nullptr;
    }
    return (uint8_t*)global_heap_info.base_address + handle;
}
