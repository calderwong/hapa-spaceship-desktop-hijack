# Hapa Spaceship Desktop Hijack Agent Guide

## Node Role

`hapa-spaceship-desktop-hijack` is the Project Janus desktop-surface prototype. It combines Electron, React/Vite, Swift, Metal, ScreenCaptureKit, and shared-memory experiments to explore a local operator bridge over the macOS desktop.

## Source Of Truth

- `README.md` distinguishes verified repository facts from intended topology.
- `package.json`, `electron/`, and `web/` define the Electron and React/Vite shell.
- `Apps/JanusDesktop/` contains the native macOS host.
- `Packages/JanusEngine/` contains Swift/Metal capture, heap, and renderer scaffolding.
- `ecosystem/TOPOLOGY.md` records intended node topology and ports.
- `CAMPFIRE.md` and `campfire-readme.md` preserve lore, intent, and handoff context.

## Safe Edit Boundaries

- Keep desktop capture, Accessibility, and overlay behavior local and explicitly operator-initiated.
- Do not document or imply a production HTTP control API until it exists and is smoke-tested.
- Do not commit `.node_token`, `.env`, native build outputs, app bundles, `node_modules`, ScreenCaptureKit recordings, logs, or private desktop captures.
- Treat screenshots and recordings as vault assets unless they are deliberately sanitized docs fixtures.
- Preserve the Swift/Electron boundary: native capture/rendering belongs in Swift/Metal; operator UI belongs in Electron/web.

## Hapa Connectivity

- Reads local desktop/surface state, shared-memory state, and operator UI input.
- Produces desktop overlay visuals, compose-surface interactions, benchmark evidence, and Janus integration notes.
- Related nodes: `hapa-janus-world-node`, `hapa-telemetry-node`, `hapa-anvil-node`, `hapa-lance-node`, Hapa wiki, and Overwatch operations.
- Heavy media, capture traces, generated app bundles, and benchmark artifacts should be registered in `hapa-vault`, not committed here.

## Verification

```bash
npm install
cd web && npm install && npm run build
cd ..
npx node-gyp configure
npx node-gyp build
swift build --package-path Packages/JanusEngine
swift build --package-path Apps/JanusDesktop
python3 scripts/anvil_benchmark.py
```

Some native checks may require local macOS permissions and toolchain repair. Record failures honestly in the relevant Quest card instead of softening docs.
