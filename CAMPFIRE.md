# CAMPFIRE — Hapa Spaceship Desktop Hijack / Project Janus

## Campfire purpose

This file is the repository-local campfire note for Project Janus. It preserves the story-facing intent while keeping implementation facts testable. For the older lore-first captain's log, see `campfire-readme.md`.

## Node identity

- Display name: Hapa Spaceship Desktop Hijack.
- Repo key: `hapa-spaceship-desktop-hijack`.
- Project codename: Project Janus.
- Hapa role: desktop manifold / spaceship bridge / local operator surface.
- Global wiki: `[[Nodes/Existing/hapa-spaceship-desktop-hijack|hapa-spaceship-desktop-hijack]]`.

## Verified implementation surface

- Swift host in `Apps/JanusDesktop` creates a transparent, borderless macOS overlay window and embeds an `MTKView`.
- Swift engine in `Packages/JanusEngine` contains scaffolds for POSIX shared memory, ScreenCaptureKit capture, and a Metal render loop.
- Electron shell in `electron/` loads the Vite UI at `http://localhost:5173` and exposes heap IPC through `preload.js`.
- Native addon in `electron/native/janus_heap.cpp` maps `/janus_monolith` and supports raw read/write by offset.
- Web UI in `web/` renders the Gravity UI compose surface.
- `scripts/anvil_benchmark.py` is a mock/lightweight validator, not a hardware performance proof.

## Intended campfire story

Janus is the Hapa bridge-window: a way for the human operator and Phamiliars to treat the desktop as navigable space. Its mythic role is “we do not open an app; we become the desktop.” Its engineering role is to test whether a native Metal plane and Electron UI plane can coordinate through a shared local memory surface.

## Current commands

Install:

```bash
npm install
cd web && npm install && cd ..
```

Run the web UI:

```bash
cd web
npm run dev
```

Run Electron after Vite is serving:

```bash
npm start
```

Run native host:

```bash
swift run --package-path Apps/JanusDesktop
```

Run cheap benchmark:

```bash
python3 scripts/anvil_benchmark.py
```

Run checks:

```bash
cd web && npm run build
cd web && npm run lint
swift build --package-path Packages/JanusEngine
swift build --package-path Apps/JanusDesktop
```

## Ports, auth, and permissions

- Verified dev port: Vite defaults to `5173`, and Electron loads `http://localhost:5173`.
- Intended topology: `ecosystem/TOPOLOGY.md` declares debug API port `8740`, loopback-only binding, and `.node_token` bearer auth. No matching HTTP server was found during this sweep.
- Likely macOS permissions: Screen Recording for ScreenCaptureKit; Accessibility for future window-geometry/physics interactions.

## Data contracts to sharpen next

- Shared memory name: `/janus_monolith`.
- Default heap size in Swift host: 64 GB in `JanusDesktopApp.swift` / `JanusHeap.swift`; older campfire language mentions 128 GB as an aspiration or topology default.
- Electron heap access: offset + length reads, offset + buffer writes.
- Screen data: ScreenCaptureKit frames become IOSurface-backed Metal textures.

## License and attribution

Project-level license is MIT under Hapa.ai / Calder Wong. Contributors may opt into Bananas work-contribution tracking for attribution. Bananas tracking is optional provenance/credit metadata and does not replace the MIT license or any third-party notices.

## Next sharpening questions

1. Should the debug API on port `8740` be implemented, or should topology docs remove it?
2. Should 64 GB or 128 GB be the actual default heap size?
3. Should the Swift app and engine be merged into a top-level Swift workspace/package so `swift build` can validate the whole native plane?
