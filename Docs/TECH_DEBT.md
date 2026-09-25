# TECH DEBT

Tracked issues that must not be fixed drive-by without a LOCK.

### Climate / zones economic influence

Backend geometry and seasonal state exist (Slice A + 8×r21 port + Seasonal Front v0). Soft harvest pressure, AI migration, and full Stage 1.5 B–G are **parked** — not drive-by wiring. See `CURRENT_STATE.md`.

### Navigation / door / rally

MAP_HALF=100 + rebake and BaseBuilding door/rally architecture accepted (2026-08-31 audit).

---

## Also tracked

EnemySpawner config single source · staggered nav · aggro leashing · data-driven stats · multi-select buildings · MOBILE collision polish

## TD-FOG-01 — Fog visual polish (post–M20.2)

**Not** part of accepted M20.2.

- Optional soft edges / bilinear filter
- Fog color closer to pure black (match minimap)
- cell_size 2.0 if blockiness becomes a play issue

Only open under a dedicated LOCK. Do not reopen M20.2.
