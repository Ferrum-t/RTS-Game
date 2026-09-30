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

## TD-DEPLOY-01 — Optional auto-unpack (UX toggle)

**Status:** IDEA only — not implemented. Manual Unpack is the default (2026-09-28).

**Intent:** Player can **enable/disable** auto-unpack when a mobile building (Watchtower, Town Center, etc.) finishes a move (`ARRIVED`).

**Proposed behavior:**
```
Setting OFF (default)
  Pack → move → ARRIVED → stay MOBILE → player presses Unpack → DEPLOYED

Setting ON
  Pack → move → ARRIVED → auto request_unpack if footprint clear
  → if overlap: stay MOBILE + feedback (same as manual block)
```

**UX:**
- Toggle in settings / options (or later a CommandBar control)
- Scope: all player `MobileBuilding` (TC + Watchtower), not AI unless separate LOCK
- Must not remove manual Pack / Unpack buttons
- Placement validation (`_validate_placement`) stays mandatory before UNPACKING

**OUT of this idea until LOCK:**
- Auto-pack
- Group formation auto-deploy
- AI auto-unpack policy changes

**Why deferred:** Explicit unpack preserves nomad control; auto is convenience. Implement only under a dedicated LOCK after core mobility is stable.

**Related:** `DeploymentComponent` ARRIVED leaves MOBILE; `UnpackButton` gated by `can_unpack()` (not while moving).

## TD-FIRE-MOVE-01 — Ranged fire while moving (idea)

**Status:** IDEA only — not implemented (2026-09-30 discussion).

**Intent (if ever LOCK):**
- Ranged units (Mergen) may strike while `MOVING` (kite)
- Melee stays stop-to-hit
- **Watchtower MOBILE stays mute** (pack/unpack trade-off; no drive-by fortress)

**OUT until LOCK:** mobile-tower full DPS, stance system, attack-move redesign.

## M23.1 — CLOSED (was parked as VFX-only)

Shipped as **real** projectile combat (damage on arrival), not visual-only. See `CURRENT_STATE.md` / `CHANGELOG.md`.
