#ifndef JANUS_HEAP_BRIDGE_H
#define JANUS_HEAP_BRIDGE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    void* base_address;
    uint64_t capacity;
} JanusHeapInfo;

JanusHeapInfo janus_get_heap_info(void);
void* janus_heap_resolve(uint32_t handle);

#ifdef __cplusplus
}
#endif

#endif /* JANUS_HEAP_BRIDGE_H */
