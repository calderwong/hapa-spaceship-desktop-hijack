# JANUS // TOPOLOGY

## Node Definition: `hapa-spaceship-desktop-hijack`

- **Display name:** Hapa Spaceship Desktop Hijack.
- **Codename:** Project Janus.
- **Role:** Physical interface layer / desktop compositor / Hapa spaceship bridge surface.
- **Primary process:** `JanusDesktop` (Swift/Metal scaffold in `Apps/JanusDesktop`).
- **Secondary process:** `JanusUI` (Electron shell + React/Vite UI in `electron/` and `web/`).
- **Global wiki:** `[[Nodes/Existing/hapa-spaceship-desktop-hijack|hapa-spaceship-desktop-hijack]]`.

## Verified Runtime Surfaces

- **Vite dev UI:** `http://localhost:5173`; loaded directly by `electron/main.js`.
- **Shared memory name:** `/janus_monolith` in Swift and Electron native-addon code.
- **Current Swift heap default:** 64 GB.
- **Electron bridge:** local IPC methods for heap read/write through `electron/preload.js`.

## Intended / Not Yet Verified Surfaces

- **Debug API default port:** `8740`.
- **Debug API binding:** loopback-only (`127.0.0.1`).
- **External-control token:** `.node_token` bearer auth.

No HTTP debug server implementation was found during the 2026-05-21 documentation sweep, so consumers should treat the port/auth entries as intended topology rather than an active API contract.

## Data Planes

- **Memory plane:** POSIX shared memory + Metal shared buffer (`/janus_monolith`).
- **Vision plane:** ScreenCaptureKit stream to IOSurface-backed Metal texture.
- **UI plane:** React/Vite compose surface hosted in Electron.
- **Control plane:** currently Electron IPC; future/debug control API still needs implementation or removal from topology.

## Permissions / Security Notes

- ScreenCaptureKit use requires macOS Screen Recording permission.
- Future Accessibility API use for window bounds/physics will require Accessibility permission.
- Keep any future external control API loopback-only by default and require `.node_token` or stronger local auth.

## License / Attribution

Project-level license is MIT under Hapa.ai / Calder Wong. Contributors may opt into Bananas work-contribution tracking for attribution; Bananas is optional provenance metadata and does not replace license obligations.
