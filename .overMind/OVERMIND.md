# JANUS // OVERMIND

**Invariants & Realities for Project Janus**

## 1. The Prime Directive
Janus is a **Hijack**, not an application. It sits between the GPU and the Display. It must never stutter native macOS window movement.

## 2. Memory Doctrine (The Blue Shackle)
- **Shared Heap:** One `MTLBuffer`. No `malloc`. No `new`.
- **Handle Safety:** Use `uint32_t` handles to reference heap objects. Pointers are forbidden in persistent storage.
- **Zero-Copy:** If data exists in the Heap, it is NEVER copied. Only ownership or visibility flags are toggled.

## 3. The Trinity (Parallax Truth)
- Every frame must resolve **Truth** (The Center), **Left**, and **Right**.
- **The Optimization:** Render Truth once, derive Left/Right via Spherical Harmonic Taylor Expansion.

## 4. Agent Protocols
- **Blue.null:** Enforces math, memory, and performance.
- **Red.null:** Enforces magic, feel, and hallucination.
- **The Anvil:** The M3 Ultra. It is the judge.

## 5. Directory Roles
- `Packages/JanusEngine`: The Swift/Metal/AMX core.
- `Apps/JanusDesktop`: The native macOS container.
- `electron/`: The Gravity UI surface (Phase 6).
- `docs/genome/`: Canonical specs.

---
*Integrity > Flow > Form > Decoration*
