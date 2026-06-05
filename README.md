# Hapa Spaceship Desktop Hijack (Project Janus)

Project Janus is a Hapa desktop-interface experiment for turning the local macOS desktop into a transparent, Metal-backed Hapa operator surface. In the Hapa node ecosystem this repository is the “desktop hijack” / spaceship bridge surface: a native Swift/Metal process owns screen capture, shared memory, and rendering, while an Electron + React/Vite UI presents a Gravity UI compose layer over the desktop.

This README separates facts observed in this repository from goals and lore preserved in `campfire-readme.md` and `CAMPFIRE.md`.

## Verified repository facts

- Root package: `hapa-spaceship-desktop-hijack` (`package.json`), Electron entry at `electron/main.js`.
- Web UI: `web/`, a React + TypeScript + Vite app with `dev`, `build`, `lint`, and `preview` scripts.
- Native macOS host: `Apps/JanusDesktop`, a Swift package executable named `JanusDesktop`.
- Swift/Metal engine: `Packages/JanusEngine`, a Swift package library named `JanusEngine`.
- Native Electron addon: `electron/native/janus_heap.cpp`, built by `binding.gyp` into `build/Release/janus_heap.node` when node-gyp succeeds.
- Benchmark script: `scripts/anvil_benchmark.py`; currently a lightweight/mock Anvil validator, not a hardware trace.
- Existing topology note: `ecosystem/TOPOLOGY.md` declares a debug API intent on port `8740`, loopback binding, and `.node_token` bearer auth, but the current code inspected here does not implement an HTTP debug server.

## Inferred / intended Hapa role

Project Janus is intended to be a local-first Hapa interface node:

- It gives Hapa agents and operators a spatial desktop surface rather than a normal app window.
- It explores a shared “Monolith” heap between Swift/Metal and Electron so UI and native rendering can coordinate with minimal copying.
- It preserves the Hapa spaceship metaphor: the user’s desktop becomes the bridge/viewscreen, while the compose UI acts as an operator console.
- It links to the global wiki node: `[[Nodes/Existing/hapa-spaceship-desktop-hijack]]` in `${HAPA_SYSTEM_ROOT}/canon/wiki/hapa-worldbuilding-wiki/SOURCE`.

## Architecture

### Native Swift/Metal plane

- `Apps/JanusDesktop/Sources/JanusDesktop/JanusDesktopApp.swift` creates a borderless transparent macOS window above most windows and embeds an `MTKView`.
- `Packages/JanusEngine/Sources/JanusEngine/JanusHeap.swift` attempts to create `/janus_monolith` POSIX shared memory and wrap it in an `MTLBuffer`.
- `Packages/JanusEngine/Sources/JanusEngine/JanusCapture.swift` uses ScreenCaptureKit to capture the display and map capture frames into Metal textures.
- `Packages/JanusEngine/Sources/JanusEngine/JanusRenderer.swift` is the Metal render-loop scaffold for the “Truth” pass.

### Electron / web plane

- `electron/main.js` creates a transparent, frameless, always-on-top BrowserWindow and loads `http://localhost:5173` in development.
- `electron/preload.js` exposes limited IPC bridges for heap read/write and basic system info.
- `electron/native/janus_heap.cpp` maps the POSIX shared memory segment from Electron and exposes `mapHeap`, `readBuffer`, and `writeBuffer`.
- `web/src/App.tsx` implements a stylized compose surface with heap-sync status and attachment chips.

## Data inputs and outputs

Inputs:

- ScreenCaptureKit display stream from the local macOS desktop.
- POSIX shared memory segment named `/janus_monolith` when the Swift host is running.
- Electron IPC requests from the React UI through `preload.js`.
- Operator text input and UI interactions in the compose surface.

Outputs:

- Transparent Metal-backed overlay window on macOS.
- Electron/React compose UI loaded from the Vite dev server.
- Console logs from the Swift host, Electron main process, and benchmark script.
- Optional heap read/write effects through the native addon when the shared segment is available.

## Ports, permissions, and auth

Observed code:

- Vite development server defaults to `http://localhost:5173`; `electron/main.js` loads that URL directly.
- No HTTP API server was found in the inspected source.
- Electron IPC is local to the app process.

Declared but not yet verified in code:

- `ecosystem/TOPOLOGY.md` documents debug API port `8740`, loopback-only binding, and `.node_token` bearer auth for external control. Treat this as intended topology until an implementation is added and smoke-tested.

macOS permissions likely required for full native operation:

- Screen Recording permission for ScreenCaptureKit.
- Accessibility permission if future window-bound physics reads macOS window geometry through Accessibility APIs.

## Setup

Requirements:

- macOS 14+.
- Xcode / Swift 5.9+ toolchain.
- Node.js 20+ recommended.
- Apple Silicon recommended for the Metal/ScreenCaptureKit path.

Install JavaScript dependencies:

```bash
npm install
cd web && npm install && cd ..
```

Build the Electron native addon:

```bash
npx node-gyp configure
npx node-gyp build
```

## Run commands

Web UI only:

```bash
cd web
npm run dev
```

Electron shell, after the web dev server is available at `http://localhost:5173`:

```bash
npm start
```

Native Swift host:

```bash
swift run --package-path Apps/JanusDesktop
```

Benchmark / smoke script:

```bash
python3 scripts/anvil_benchmark.py
```

Useful checks:

```bash
cd web && npm run build
cd web && npm run lint
swift build --package-path Packages/JanusEngine
swift build --package-path Apps/JanusDesktop
```

Record failures honestly. At the time of this documentation sweep, the Swift packages are scaffolds and may need code-level fixes before a clean build.

## Repository structure

- `Apps/JanusDesktop/` — native macOS app host.
- `Packages/JanusEngine/` — Swift/Metal capture, heap, and renderer package.
- `electron/` — Electron main/preload files and native heap addon source.
- `web/` — React/Vite Gravity UI compose surface.
- `scripts/` — Anvil benchmark/automation scripts.
- `ecosystem/` — node topology and ecosystem-facing notes.
- `.overMind/` — doctrine/invariant notes for Project Janus.
- `campfire-readme.md` and `CAMPFIRE.md` — lore, intent, and handoff context.

## Project license

Project-level license: MIT, copyright Hapa.ai / Calder Wong. See `LICENSE`.

Third-party dependencies keep their own licenses and notices in their package distributions. Do not remove upstream notices from `node_modules`, generated vendor bundles, or copied third-party material.

## Bananas attribution option

Contributors may opt into Bananas work-contribution tracking for attribution. Bananas tracking is optional and additive: it records contribution provenance/credit preferences for Hapa collaboration, but it does not replace the MIT project license or third-party license obligations.

## Global wiki link

Global node note:

- `${HAPA_SYSTEM_ROOT}/canon/wiki/hapa-worldbuilding-wiki/SOURCE/Nodes/Existing/hapa-spaceship-desktop-hijack.md`
- Obsidian link: `[[Nodes/Existing/hapa-spaceship-desktop-hijack|hapa-spaceship-desktop-hijack]]`

## Open risks / sharpening tests

- Verify whether the Swift packages should be independently buildable or should share one top-level Swift package; current package paths imply local dependency wiring that may need correction.
- Implement or remove the declared debug API on port `8740`; docs now label it as intended rather than verified.
- Replace the mock Anvil benchmark with real xctrace/Metal metrics when performance claims become release criteria.
- Add real Electron preload integration tests for heap IPC once the native shared-memory lifecycle is stable.


<!-- HAPA-README-QUALITY-PASS-2026-05-22 -->

## Hapa ecosystem context

<p>
  <img src="docs/assets/hapa-ecosystem-context/overview.jpg" alt="Hapa ecosystem context visual showing modular nodes, human and AI-agent interfaces, Hapa Cards, avatar-agents, Second Brain, and wiki enrichment loop" width="100%">
</p>

### Shared ecosystem pattern

Hapa is built as a constellation of modular nodes. Each node owns a focused capability, but participates in a shared protocol for provenance, handoff, cards, memory, and operations.

Every node is designed for both human operators and AI agents. The target contract is three surfaces: a UI for direct human review/control, an API for node-to-node and agent calls, and a CLI for scripted runs, audits, and handoffs. Individual repos may be at different maturity levels, but the public contract is that humans and agents can inspect, operate, and verify the node.

Hapa nodes power AI agents and avatar-agents that build new nodes and enhance existing ones. As work moves through the ecosystem, it is mined for utility, wisdom, and repeatable logic, then distilled into Hapa Cards: portable packets of skills, context, memories, and operational patterns.

Humans and AIs use Hapa Cards to discuss, ideate, prototype, and deploy increasingly complex workflows through a playable, card-collecting mechanic. Collaboration history, skills, work artifacts, and canonical decisions are stored in [hapa-second-brain](https://github.com/calderwong/hapa-second-brain), enriched into [Hapa Worldbuilding Wiki](https://github.com/calderwong/hapa-worldbuilding-wiki) entries, and converted back into cards. Avatar-agents can also be combined or specialized into purpose-built identities with their own storage, lore, canon, card decks, skills, and protocols.

### Purpose

Janus/spaceship desktop surface prototype exploring Electron, Vite, native Swift/Metal, and shared-memory desktop interaction patterns.

### Current status

- Status: **prototype desktop surface**.
- Local source root: `${HAPA_NODE_ROOT}`.
- This README is intended to be useful to both human operators and future agents: it should explain what the node is for, what it consumes, what it emits, how it connects to other Hapa nodes, and what should stay out of git.

### Inputs

- Desktop/surface events, renderer state, Swift/Metal shared-memory data, prototype controls

### Outputs

- Desktop surface visuals, bridge telemetry, native-renderer experiments, and Janus integration evidence

### Interfaces

- Electron/Vite web UI
- Swift/Metal native components
- Shared-memory bridge

### Related Hapa nodes

- [Hapa AG / Dev Proto](https://github.com/calderwong/hapa-dev-proto-private) — Primary local-first app; many nodes feed it cards, assets, chat, debug, or projection data.
- [Hapa Worldbuilding Wiki](https://github.com/calderwong/hapa-worldbuilding-wiki) — Canonical Markdown graph for lore, nodes, names, cards, systems, and provenance.
- [Overwatch](https://github.com/calderwong/overwatch) — Operations map: inventory, source index, task inbox, protocols, and runbooks.
- [Hapa Telemetry Node](https://github.com/calderwong/hapa-telemetry-node) — Discovery/monitoring hub for node health, capabilities, launchers, and relationships.
- [Hapa Keys Node](https://github.com/calderwong/hapa-keys-node) — Local key vault used by authenticated nodes and tools.
- [Hapa Lore Node](https://github.com/calderwong/hapa-lore-node) — Chronicle/canon service for daily progress, lore, and searchable wisdom.
- [Hapa Anvil Node](https://github.com/calderwong/hapa-anvil-node) — Card standardization/evaluation/forge node for turning raw card ideas into usable artifacts.
- [Hapa Janus World Node](https://github.com/calderwong/hapa-janus-world-node) — World-state truth kernel and event tape for Janus/desktop simulation work.
- [Hapa MLX Station](https://github.com/calderwong/hapa-mlx-station) — Apple Silicon media-generation station that produces visual/audio assets for cards, wiki, and production runs.
- [Hapa Lance Node](https://github.com/calderwong/hapa-lance-node) — Local indexing/projection layer for cards, wiki chunks, embeddings, and multimodal records.

### Operating contract

- Treat generated media, local databases, model weights, dependency folders, build outputs, app bundles, and secrets as runtime artifacts unless this README explicitly says otherwise.
- Prefer loopback/local operation first; expose network services only with explicit auth and operator intent.
- When this node produces artifacts for another node, record enough provenance for the receiving node or wiki page to recover the source path, command, prompt, or API request.
- Keep `README.md`, `LICENSE`, `NOTICE.md` where applicable, and repo-local screenshots current as the node evolves.

<!-- HAPA_NODE_ATLAS_DEMO:START -->
## See It In Action

<a href="https://calderwong.github.io/hapa-node-atlas/">
  <img src="https://calderwong.github.io/hapa-node-atlas/assets/atalas-hero-loop-poster.jpg" alt="Hapa Node Atlas live demo" width="360">
</a>

[Open the Hapa Node Atlas demo](https://calderwong.github.io/hapa-node-atlas/)
<!-- HAPA_NODE_ATLAS_DEMO:END -->
