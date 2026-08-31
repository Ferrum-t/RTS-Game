# GROK WORKLOG — Nomad Wars

Ветка: `nomads-wars-grok`

**Scope:** только `Docs/nomad_wars_v1_scope_and_architecture.md`  
**Tech debt:** `Docs/TECH_DEBT.md`

---

## 2026-08-31 — Stage 1 F5 + GPT audit start

### Code

- Rally: door + farther default offset (12), grid slots, flag on select, RMB set rally.
- Yellow `BuildingSelectRing` on all `BaseBuilding` (Barracks included).
- **AI attack spam fixed:** `EconomicAIController` issues army attack **once** at threshold; late joiners get AI only if missing component (`attack reinforcements +N`). Reset when army < threshold.

### Docs

- Created **`Docs/TECH_DEBT.md`**.
- **TD-01 (open):** AI construction does **not** share player `Ghost.can_build` / collision validation. AI uses `tc + barracks_offset` → `place_building_for_team` (cost/team only). Hand-tuned offset works for Stage 1; not a shared placement pipeline. Fix sketch: shared `can_place` + AI site sampling.
- **TD-02 (open, design):** After Barracks, wood=0 while stone high → spam `not enough wood for Soldier`. Heuristic `stone < 50 ? stone : wood` is correct for itself but not demand-driven. **Next step after Stage 1 = AI Economy 1.5** (BUILDING_GOAL → PRODUCTION_GOAL → RESOURCE_REQUIREMENT → WORKER_ASSIGNMENT), **not T2**. See `TECH_DEBT.md`.
- **TD-03 (open, do not fix Stage 1):** After Enemy TC destroy, workers keep inventory (no drop-off). Barracks/soldiers can theoretically keep going. OK while match ends on TC; revisit when victory conditions change.

### Next

- Further GPT audit items → TD-04+ in `TECH_DEBT.md`.
- Do not claim “same placement pipeline” until TD-01 closed.
- Prefer Economy 1.5 over T2 content when Stage 1 is closed.

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
