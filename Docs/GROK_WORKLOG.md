# GROK WORKLOG — Nomad Wars

Ветка: `nomads-wars-grok`

**Scope:** только `Docs/nomad_wars_v1_scope_and_architecture.md`

---

## 2026-08-29 — Doc sync §0 + phases 10–12 closed

### Accepted since last §0 write (F5-backed)

- **Environment Zones v1.0:** 4 blobs, harvest multiplier, priority COLD>DRY>FAVORABLE, visual discs match code priority.
- **Enemy AI:** threat radius, unit priority, wave scaling, `EnemySoldier_N` / `EnemyTownCenter` names.
- **Polish:** `DebugFlags.BUILDING_HOTKEYS = false`; readable building names.
- **Selection-aware control:** select TC/Watchtower → Pack/Unpack/RMB only selected; empty building selection → entire caravan (formation-offsets). Dual-mode confirmed in F5.
- Billboard pack bar: QuadMesh + camera basis (no cube edge).

### Doc action

Updated §0 / §1.4–1.6 / §3.13–3.14 / §4 + pointers (`CURRENT_STATE`, `TODO`, `ROADMAP`).

### Next candidates

1. Balance pass  
2. Zones v1.1  
3. Unpack validation / Raise TC-only  

---

## 2026-08-28 — Formation-offsets ACCEPTED + billboard fix

### F5 formation-offsets (user log)

- `slot 0/2` / `slot 1/2` `spacing=6.3` — разные dest
- оба ARRIVED; Watchtower → DEPLOYED; TC → DEPLOYED
- ноль `footprint overlaps`

**ACCEPTED.** Death spiral log 27 закрыт.

### Billboard

Progress bar: `global_transform.basis = cam.global_transform.basis` (как HealthBar3D).

### Collision MOBILE

Юниты проходят сквозь MOBILE-здания — tech debt, не блокер.

---

## 2026-08-28 earlier — Docs cleanup (Claude audit)

Deleted ARCHITECTURE, PROJECT_ROADMAP, PHASE_8_*, SESSION. Pointers synced.

---

*Older: Phase 7–8.2, polish — see git history.*
