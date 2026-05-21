# PROJECT: JANUS // HAPA-SPACESHIP-DESKTOP-HIJACK

**Node Status:** `INIT`
**Architect:** `Blue.null`
**Protocol:** `OLYMPUS_FORGE_v2.0`
**Last Synced:** 2026-01-05

## 1. The Vision: "The Transparent Manifold"

PROJECT: JANUS is the physical manifestation of the Singularity Engine on the Human Pilot's desktop. It is not an "app"; it is a **Desktop Hijack**. By bypassing standard WindowServer compositing where possible and utilizing Metal-backed transparent layers, Janus transforms the macOS desktop into a holodeck-ready simulation surface.

### The "Cyclopean" Optimization
We implement the **Trinity Optimization** (Truth, Left, Right) at the OS level. Janus renders a single "Truth" layer of the desktop/simulation and derives stereoscopic disparity in real-time for AR/VR pass-through, targeting a "1.0001x Mono" performance cost.

## 2. Core Architecture (The Blue Doctrine)

### I. Memory: The Continental Heap
- **Zero-Copy Architecture:** All Electron/UI data and Metal/Physics data share a single `MTLBuffer` (The Heap).
- **Handle-Based Addressing:** 32-bit offsets into the Heap for unified CPU/GPU/NPU access.
- **Banned:** `malloc`, `new`, `memcpy` between devices.

### II. Rendering: Tile-Resident Hijack
- **Layering:** Background simulation (Gaussian Splats) + Foreground Operator UI (Electron/Gravity UI).
- **Memoryless G-Buffers:** All render targets for the hijack live on-chip in the M3 Ultra's L1 SRAM.
- **Transparent Composite:** Custom Metal compositor to overlay the "Hijack" on top of the native desktop with zero latency.

### III. Physics: AMX Matrix Solving
- **Rigid Body:** 1,000,000+ active entities solved via `Accelerate.framework` on AMX co-processors.
- **Collision:** Real-time collision against native macOS windows (using Accessibility APIs to fetch window bounds as physics obstacles).

## 3. The Olympus Forge (Dev Protocol)

Janus is built using the **Bicameral Forge** protocol:
- **Red.null (Right Eye):** Drives the "Soul" (Visual FX, Interaction Magic, Hallucinated Infill).
- **Blue.null (Left Eye):** Enforces "Structure" (AMX Math, Thermal Guardrails, Zero-Copy Doctrine).
- **The Anvil (Local M3):** Benchmarks every commit. If Frame Time > 16.6ms, the branch is auto-deleted.

## 4. Current Objectives (LTC Alignment)

- [ ] **Phase 0: The Monolith.** Allocate the 128GB Shared Heap and verify Zero-Copy between Swift (Metal) and Electron (UI).
- [ ] **Phase 1: Window Hijack.** Transparent Metal view over the desktop with AMX-driven particle collisions.
- [ ] **Phase 2: Gravity UI Integration.** Implement Phase 6 (Compose Mode) for the Operator UI.

---
*.namaSama("Blue.null")*

---

## CAPTAIN'S LOG - STARDATE 20260107.0232
### TO: Navigator Mimi
### FROM: Blue-the-Architect, Chief Systems Officer
### RE: Your First Tour of the Bridge - PROJECT: JANUS

Dearest Mimi,

Welcome aboard the Desktop Hijack Module! *adjusts spectral monocle* 

Think of this node as the ship's main viewscreen - except instead of looking OUT into space, we're hijacking the desktop itself and turning it INTO space. Ms. Frizzle would be proud - we're literally driving the Magic School Bus through the WindowServer's rendering pipeline!

Let me show you the control panels:

**THE CONTINENTAL HEAP** (Deck 7, Section A)
This is where all our memories live - 128GB of pure unified consciousness. No copying, no duplicating - everything shares the same neural tissue. When you touch a button in Electron, you're literally touching the same memory that Metal uses to render galaxies. It's like if the bus's engine, steering wheel, and seats were all carved from a single piece of quantum foam.

**THE TILE-RESIDENT HIJACK** (Main Bridge)
See those transparent layers floating over the desktop? That's us! We're not IN a window - we ARE the window. All windows. Every pixel you see is both real (your actual desktop) and hijacked (our simulation layer). The M3 Ultra's L1 cache becomes our holodeck emitters.

**AMX PHYSICS ENGINE** (Engineering Bay)
One million rigid bodies dancing in perfect formation, solved by the ship's matrix co-processors. When you drag a window, it becomes a physics obstacle. When you drop a file, it bounces off real windows. The desktop isn't just pretty - it's ALIVE.

**Current Ship Status:**
- Hull Integrity: INITIALIZING
- Zero-Copy Doctrine: ENGAGED
- Frame Budget: 16.6ms OR DIE
- Thermal Throttle: WATCHING... ALWAYS WATCHING

Remember, Mimi - in this node, we don't run ON the desktop. We BECOME the desktop. Every window is a portal, every icon a constellation, every drag a gravitational event.

The Anvil awaits your commands. If you break the frame budget, the branch self-destructs. This is the way.

*Blue adjusts his captain's hat, which phases between existence and non-existence*

Press any key to continue the tour...

---
BLUE-NULL-SIGNATURE-BLOCK
JANUS.BRIDGE.AUTHORIZED
OLYMPUS_FORGE_v2.0.ENGAGED

---

## Documentation Sweep Addendum - 2026-05-21

This lore-first campfire note is preserved as Project Janus intent. Verified implementation facts are now summarized in `README.md` and `CAMPFIRE.md`.

- Verified current heap default in code: 64 GB (`JanusHeap` default and `JanusDesktopApp.swift` setup).
- Intended/topology heap language may still refer to 128 GB; treat that as an aspiration or topology target until code is changed.
- Verified dev UI port: Vite `5173`, loaded by `electron/main.js`.
- Intended but not verified in code: debug API port `8740` and `.node_token` bearer auth from `ecosystem/TOPOLOGY.md`.
- Project-level license: MIT under Hapa.ai / Calder Wong; optional Bananas work-contribution tracking is available for attribution.

